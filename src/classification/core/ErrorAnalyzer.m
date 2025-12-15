% ErrorAnalyzer.m - Analyze classification errors and provide insights
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This class provides utilities for error analysis:
%   - Identify top-K misclassified images with highest confidence
%   - Calculate correlation between predicted class and actual corroded percentage
%   - Generate error analysis report with sample images
%   - Provide insights for model improvement
%
% Requirements addressed: 10.4, 10.5

classdef ErrorAnalyzer < handle
    % ErrorAnalyzer - Analyze classification errors and provide insights
    %
    % This class provides utilities for error analysis:
    %   - Identify top-K misclassified images with highest confidence
    %   - Calculate correlation between predicted class and actual corroded percentage
    %   - Generate error analysis report with sample images
    %   - Provide insights for model improvement
    %
    % Requirements addressed: 10.4, 10.5
    
    properties (Access = private)
        net                 % Trained network
        testDatastore       % Test datastore
        classNames          % Cell array of class names
        labelCSV            % Path to label CSV with corroded percentages
        errorHandler        % ErrorHandler instance for logging
        
        % Cached results
        predictions         % Predicted labels
        scores              % Prediction scores (probabilities)
        trueLabels          % True labels
        imageFilenames      % Image filenames
        corrodedPercentages % Actual corroded percentages
    end
    
    methods
        function obj = ErrorAnalyzer(net, testDatastore, classNames, labelCSV, errorHandler)
            % Constructor
            % Inputs:
            %   net - Trained network
            %   testDatastore - Test datastore
            %   classNames - Cell array of class names
            %   labelCSV - Path to CSV file with corroded percentages
            %   errorHandler - ErrorHandler instance (optional)
            %
            % Requirements: 10.4, 10.5
            
            if nargin < 4
                error('ErrorAnalyzer:InvalidInput', ...
                    'Network, test datastore, class names, and label CSV are required');
            end
            
            obj.net = net;
            obj.testDatastore = testDatastore;
            obj.classNames = classNames;
            obj.labelCSV = labelCSV;
            
            % Initialize error handler
            if nargin >= 5 && ~isempty(errorHandler)
                obj.errorHandler = errorHandler;
            else
                obj.errorHandler = ErrorHandler.getInstance();
            end
            
            % Initialize cached results
            obj.predictions = [];
            obj.scores = [];
            obj.trueLabels = [];
            obj.imageFilenames = {};
            obj.corrodedPercentages = [];
            
            obj.errorHandler.logInfo('ErrorAnalyzer', 'ErrorAnalyzer initialized');
        end
        
        function topErrors = identifyTopMisclassifications(obj, K)
            % Identify top-K misclassified images with highest confidence
            % Inputs:
            %   K - Number of top errors to return (default: 10)
            % Output:
            %   topErrors - Struct array with misclassification details
            %
            % Requirements: 10.4
            
            if nargin < 2 || isempty(K)
                K = 10;
            end
            
            obj.errorHandler.logInfo('ErrorAnalyzer', ...
                sprintf('Identifying top %d misclassifications...', K));
            
            % Get predictions if not already computed
            if isempty(obj.predictions)
                obj.getPredictions();
            end
            
            try
                % Find misclassified samples
                misclassifiedIdx = find(obj.predictions ~= obj.trueLabels);
                
                if isempty(misclassifiedIdx)
                    obj.errorHandler.logInfo('ErrorAnalyzer', ...
                        'No misclassifications found - perfect accuracy!');
                    topErrors = struct([]);
                    return;
                end
                
                obj.errorHandler.logInfo('ErrorAnalyzer', ...
                    sprintf('Found %d misclassified samples', length(misclassifiedIdx)));
                
                % Get confidence scores for misclassified predictions
                confidences = zeros(length(misclassifiedIdx), 1);
                for i = 1:length(misclassifiedIdx)
                    idx = misclassifiedIdx(i);
                    predClass = double(obj.predictions(idx));
                    confidences(i) = obj.scores(idx, predClass);
                end
                
                % Sort by confidence (highest first)
                [sortedConfidences, sortIdx] = sort(confidences, 'descend');
                sortedMisclassifiedIdx = misclassifiedIdx(sortIdx);
                
                % Get top K
                numErrors = min(K, length(sortedMisclassifiedIdx));
                topErrors = struct([]);
                
                for i = 1:numErrors
                    idx = sortedMisclassifiedIdx(i);
                    
                    topErrors(i).filename = obj.imageFilenames{idx};
                    topErrors(i).trueLabel = obj.classNames{double(obj.trueLabels(idx))};
                    topErrors(i).predictedLabel = obj.classNames{double(obj.predictions(idx))};
                    topErrors(i).confidence = sortedConfidences(i);
                    topErrors(i).trueClass = double(obj.trueLabels(idx));
                    topErrors(i).predictedClass = double(obj.predictions(idx));
                    topErrors(i).corrodedPercentage = obj.corrodedPercentages(idx);
                    topErrors(i).scores = obj.scores(idx, :);
                    
                    obj.errorHandler.logInfo('ErrorAnalyzer', ...
                        sprintf('#%d: %s - True: %s, Pred: %s (%.2f%% conf, %.2f%% corroded)', ...
                        i, topErrors(i).filename, topErrors(i).trueLabel, ...
                        topErrors(i).predictedLabel, topErrors(i).confidence * 100, ...
                        topErrors(i).corrodedPercentage));
                end
                
            catch ME
                obj.errorHandler.logError('ErrorAnalyzer', ...
                    sprintf('Failed to identify misclassifications: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function correlation = calculateCorrelation(obj)
            % Calculate correlation between predicted class and actual corroded percentage
            % Output:
            %   correlation - Struct with correlation metrics
            %
            % Requirements: 10.5
            
            obj.errorHandler.logInfo('ErrorAnalyzer', ...
                'Calculating correlation between predictions and corroded percentages...');
            
            % Get predictions if not already computed
            if isempty(obj.predictions)
                obj.getPredictions();
            end
            
            try
                % Convert categorical labels to numeric
                trueLabelNumeric = double(obj.trueLabels);
                predLabelNumeric = double(obj.predictions);
                
                % Calculate Pearson correlation
                % Between true class and corroded percentage
                corrTrueVsPercentage = corr(trueLabelNumeric, obj.corrodedPercentages);
                
                % Between predicted class and corroded percentage
                corrPredVsPercentage = corr(predLabelNumeric, obj.corrodedPercentages);
                
                % Between true and predicted class
                corrTrueVsPred = corr(trueLabelNumeric, predLabelNumeric);
                
                % Calculate mean corroded percentage per class
                meanPercentagePerClass = zeros(length(obj.classNames), 1);
                stdPercentagePerClass = zeros(length(obj.classNames), 1);
                
                for i = 1:length(obj.classNames)
                    classIdx = trueLabelNumeric == i;
                    if any(classIdx)
                        meanPercentagePerClass(i) = mean(obj.corrodedPercentages(classIdx));
                        stdPercentagePerClass(i) = std(obj.corrodedPercentages(classIdx));
                    end
                end
                
                % Store correlation results
                correlation = struct();
                correlation.trueClassVsPercentage = corrTrueVsPercentage;
                correlation.predictedClassVsPercentage = corrPredVsPercentage;
                correlation.trueVsPredicted = corrTrueVsPred;
                correlation.meanPercentagePerClass = meanPercentagePerClass;
                correlation.stdPercentagePerClass = stdPercentagePerClass;
                
                obj.errorHandler.logInfo('ErrorAnalyzer', '=== Correlation Analysis ===');
                obj.errorHandler.logInfo('ErrorAnalyzer', ...
                    sprintf('True class vs corroded %%: r = %.4f', corrTrueVsPercentage));
                obj.errorHandler.logInfo('ErrorAnalyzer', ...
                    sprintf('Predicted class vs corroded %%: r = %.4f', corrPredVsPercentage));
                obj.errorHandler.logInfo('ErrorAnalyzer', ...
                    sprintf('True vs predicted class: r = %.4f', corrTrueVsPred));
                
                obj.errorHandler.logInfo('ErrorAnalyzer', '=== Mean Corroded % per Class ===');
                for i = 1:length(obj.classNames)
                    obj.errorHandler.logInfo('ErrorAnalyzer', ...
                        sprintf('%s: %.2f%% ± %.2f%%', obj.classNames{i}, ...
                        meanPercentagePerClass(i), stdPercentagePerClass(i)));
                end
                
            catch ME
                obj.errorHandler.logError('ErrorAnalyzer', ...
                    sprintf('Failed to calculate correlation: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function report = generateErrorAnalysisReport(obj, modelName, outputDir, K)
            % Generate comprehensive error analysis report
            % Inputs:
            %   modelName - Name of the model being analyzed
            %   outputDir - Directory to save report and sample images
            %   K - Number of top errors to include (default: 10)
            % Output:
            %   report - Struct containing error analysis results
            %
            % Requirements: 10.4, 10.5
            
            if nargin < 4 || isempty(K)
                K = 10;
            end
            
            if nargin < 2 || isempty(modelName)
                modelName = 'model';
            end
            
            obj.errorHandler.logInfo('ErrorAnalyzer', ...
                sprintf('Generating error analysis report for: %s', modelName));
            
            try
                % Initialize report
                report = struct();
                report.modelName = modelName;
                report.timestamp = datetime('now');
                
                % Get predictions if not already computed
                if isempty(obj.predictions)
                    obj.getPredictions();
                end
                
                % Calculate basic error statistics
                numSamples = length(obj.trueLabels);
                numCorrect = sum(obj.predictions == obj.trueLabels);
                numIncorrect = numSamples - numCorrect;
                accuracy = numCorrect / numSamples;
                
                report.totalSamples = numSamples;
                report.correctPredictions = numCorrect;
                report.incorrectPredictions = numIncorrect;
                report.accuracy = accuracy;
                
                % Identify top misclassifications
                report.topMisclassifications = obj.identifyTopMisclassifications(K);
                
                % Calculate correlation
                report.correlation = obj.calculateCorrelation();
                
                % Analyze confusion patterns
                report.confusionPatterns = obj.analyzeConfusionPatterns();
                
                % Generate insights
                report.insights = obj.generateInsights(report);
                
                obj.errorHandler.logInfo('ErrorAnalyzer', '=== Error Analysis Summary ===');
                obj.errorHandler.logInfo('ErrorAnalyzer', ...
                    sprintf('Total samples: %d', numSamples));
                obj.errorHandler.logInfo('ErrorAnalyzer', ...
                    sprintf('Correct: %d (%.2f%%)', numCorrect, accuracy * 100));
                obj.errorHandler.logInfo('ErrorAnalyzer', ...
                    sprintf('Incorrect: %d (%.2f%%)', numIncorrect, (1 - accuracy) * 100));
                
                % Save report if output directory provided
                if nargin >= 3 && ~isempty(outputDir)
                    if ~exist(outputDir, 'dir')
                        mkdir(outputDir);
                    end
                    
                    % Save to MAT file
                    reportPath = fullfile(outputDir, sprintf('%s_error_analysis.mat', modelName));
                    save(reportPath, 'report', '-v7.3');
                    obj.errorHandler.logInfo('ErrorAnalyzer', ...
                        sprintf('Error analysis saved: %s', reportPath));
                    
                    % Save to text file
                    txtPath = fullfile(outputDir, sprintf('%s_error_analysis.txt', modelName));
                    obj.saveReportAsText(report, txtPath);
                    
                    % Save sample images of top errors
                    obj.saveSampleImages(report.topMisclassifications, outputDir, modelName);
                end
                
            catch ME
                obj.errorHandler.logError('ErrorAnalyzer', ...
                    sprintf('Failed to generate error analysis report: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function insights = generateInsights(obj, report)
            % Generate insights for model improvement
            % Input:
            %   report - Error analysis report struct
            % Output:
            %   insights - Cell array of insight strings
            %
            % Requirements: 10.4, 10.5
            
            insights = {};
            
            % Insight 1: Overall accuracy
            if report.accuracy >= 0.95
                insights{end+1} = 'Excellent accuracy (>95%). Model is performing very well.';
            elseif report.accuracy >= 0.85
                insights{end+1} = 'Good accuracy (85-95%). Minor improvements possible.';
            elseif report.accuracy >= 0.70
                insights{end+1} = 'Moderate accuracy (70-85%). Significant room for improvement.';
            else
                insights{end+1} = 'Low accuracy (<70%). Major improvements needed.';
            end
            
            % Insight 2: Correlation analysis
            if report.correlation.predictedClassVsPercentage > 0.9
                insights{end+1} = 'Strong correlation between predictions and corroded percentage. Model is learning the right features.';
            elseif report.correlation.predictedClassVsPercentage > 0.7
                insights{end+1} = 'Moderate correlation between predictions and corroded percentage. Model could benefit from more training data.';
            else
                insights{end+1} = 'Weak correlation between predictions and corroded percentage. Model may be learning spurious features.';
            end
            
            % Insight 3: Confusion patterns
            if ~isempty(report.confusionPatterns)
                mostCommonError = report.confusionPatterns(1);
                insights{end+1} = sprintf('Most common error: %s confused as %s (%d cases)', ...
                    mostCommonError.trueClass, mostCommonError.predictedClass, mostCommonError.count);
                
                % Check if errors are adjacent classes
                if abs(mostCommonError.trueClassIdx - mostCommonError.predictedClassIdx) == 1
                    insights{end+1} = 'Most errors are between adjacent severity classes. Consider refining class boundaries or using more training data near thresholds.';
                end
            end
            
            % Insight 4: High confidence errors
            if ~isempty(report.topMisclassifications)
                highConfErrors = sum([report.topMisclassifications.confidence] > 0.8);
                if highConfErrors > 0
                    insights{end+1} = sprintf('%d high-confidence errors (>80%%) detected. These may indicate labeling issues or ambiguous cases.', highConfErrors);
                end
            end
            
            % Insight 5: Class-specific performance
            meanPercentages = report.correlation.meanPercentagePerClass;
            stdPercentages = report.correlation.stdPercentagePerClass;
            
            % Check for high variance in any class
            for i = 1:length(stdPercentages)
                if stdPercentages(i) > 10  % High variance
                    insights{end+1} = sprintf('Class "%s" has high variance in corroded percentage (±%.2f%%). Consider splitting into sub-classes.', ...
                        obj.classNames{i}, stdPercentages(i));
                end
            end
            
            obj.errorHandler.logInfo('ErrorAnalyzer', '=== Insights for Model Improvement ===');
            for i = 1:length(insights)
                obj.errorHandler.logInfo('ErrorAnalyzer', sprintf('%d. %s', i, insights{i}));
            end
        end
    end
    
    methods (Access = private)
        function getPredictions(obj)
            % Get predictions and scores for all test samples
            % This method caches predictions to avoid recomputation
            
            obj.errorHandler.logInfo('ErrorAnalyzer', 'Computing predictions for test set...');
            
            try
                % Load label data
                obj.loadLabelData();
                
                % Reset datastore
                reset(obj.testDatastore);
                
                % Initialize arrays
                predictions = [];
                scores = [];
                trueLabels = [];
                imageFilenames = {};
                
                % Get predictions for all samples
                count = 0;
                while hasdata(obj.testDatastore)
                    data = read(obj.testDatastore);
                    
                    % Extract image and label
                    if iscell(data)
                        img = data{1};
                        label = data{2};
                    else
                        img = data;
                        label = categorical(NaN);
                    end
                    
                    % Get filename from datastore
                    if count < length(obj.testDatastore.Files)
                        [~, fname, ext] = fileparts(obj.testDatastore.Files{count + 1});
                        imageFilenames{end+1} = [fname ext];
                    else
                        imageFilenames{end+1} = sprintf('image_%d', count + 1);
                    end
                    
                    % Classify image
                    [pred, score] = classify(obj.net, img);
                    
                    % Store results
                    predictions = [predictions; pred];
                    scores = [scores; score];
                    trueLabels = [trueLabels; label];
                    
                    count = count + 1;
                    
                    % Log progress every 100 samples
                    if mod(count, 100) == 0
                        obj.errorHandler.logInfo('ErrorAnalyzer', ...
                            sprintf('Processed %d samples...', count));
                    end
                end
                
                % Store cached results
                obj.predictions = predictions;
                obj.scores = scores;
                obj.trueLabels = trueLabels;
                obj.imageFilenames = imageFilenames;
                
                obj.errorHandler.logInfo('ErrorAnalyzer', ...
                    sprintf('Predictions computed for %d samples', count));
                
                % Reset datastore
                reset(obj.testDatastore);
                
            catch ME
                obj.errorHandler.logError('ErrorAnalyzer', ...
                    sprintf('Failed to get predictions: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function loadLabelData(obj)
            % Load corroded percentages from label CSV
            
            obj.errorHandler.logInfo('ErrorAnalyzer', ...
                sprintf('Loading label data from: %s', obj.labelCSV));
            
            try
                % Read CSV file
                labelTable = readtable(obj.labelCSV);
                
                % Extract filenames and percentages
                if ismember('filename', labelTable.Properties.VariableNames)
                    csvFilenames = labelTable.filename;
                else
                    error('CSV file must contain "filename" column');
                end
                
                if ismember('corroded_percentage', labelTable.Properties.VariableNames)
                    csvPercentages = labelTable.corroded_percentage;
                else
                    error('CSV file must contain "corroded_percentage" column');
                end
                
                % Match test images with CSV data
                obj.corrodedPercentages = zeros(length(obj.testDatastore.Files), 1);
                
                for i = 1:length(obj.testDatastore.Files)
                    [~, fname, ext] = fileparts(obj.testDatastore.Files{i});
                    fullname = [fname ext];
                    
                    % Find matching entry in CSV
                    idx = find(strcmp(csvFilenames, fullname), 1);
                    if ~isempty(idx)
                        obj.corrodedPercentages(i) = csvPercentages(idx);
                    else
                        obj.errorHandler.logWarning('ErrorAnalyzer', ...
                            sprintf('No label found for: %s', fullname));
                        obj.corrodedPercentages(i) = NaN;
                    end
                end
                
                obj.errorHandler.logInfo('ErrorAnalyzer', ...
                    sprintf('Loaded corroded percentages for %d images', ...
                    sum(~isnan(obj.corrodedPercentages))));
                
            catch ME
                obj.errorHandler.logError('ErrorAnalyzer', ...
                    sprintf('Failed to load label data: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function patterns = analyzeConfusionPatterns(obj)
            % Analyze common confusion patterns
            % Output:
            %   patterns - Struct array with confusion pattern details
            
            obj.errorHandler.logInfo('ErrorAnalyzer', 'Analyzing confusion patterns...');
            
            try
                numClasses = length(obj.classNames);
                
                % Build confusion matrix
                confMat = zeros(numClasses, numClasses);
                for i = 1:length(obj.trueLabels)
                    trueIdx = double(obj.trueLabels(i));
                    predIdx = double(obj.predictions(i));
                    confMat(trueIdx, predIdx) = confMat(trueIdx, predIdx) + 1;
                end
                
                % Find all confusion pairs (excluding diagonal)
                patterns = struct([]);
                for i = 1:numClasses
                    for j = 1:numClasses
                        if i ~= j && confMat(i, j) > 0
                            patterns(end+1).trueClass = obj.classNames{i};
                            patterns(end).predictedClass = obj.classNames{j};
                            patterns(end).trueClassIdx = i;
                            patterns(end).predictedClassIdx = j;
                            patterns(end).count = confMat(i, j);
                            patterns(end).percentage = confMat(i, j) / sum(confMat(i, :)) * 100;
                        end
                    end
                end
                
                % Sort by count (most common first)
                if ~isempty(patterns)
                    [~, sortIdx] = sort([patterns.count], 'descend');
                    patterns = patterns(sortIdx);
                    
                    obj.errorHandler.logInfo('ErrorAnalyzer', '=== Confusion Patterns ===');
                    for i = 1:min(5, length(patterns))
                        obj.errorHandler.logInfo('ErrorAnalyzer', ...
                            sprintf('%s → %s: %d cases (%.2f%%)', ...
                            patterns(i).trueClass, patterns(i).predictedClass, ...
                            patterns(i).count, patterns(i).percentage));
                    end
                end
                
            catch ME
                obj.errorHandler.logError('ErrorAnalyzer', ...
                    sprintf('Failed to analyze confusion patterns: %s', ME.message));
                patterns = struct([]);
            end
        end
        
        function saveSampleImages(obj, topErrors, outputDir, modelName)
            % Save sample images of top misclassifications
            % Inputs:
            %   topErrors - Top misclassification struct array
            %   outputDir - Directory to save images
            %   modelName - Model name for filename prefix
            
            if isempty(topErrors)
                return;
            end
            
            obj.errorHandler.logInfo('ErrorAnalyzer', ...
                sprintf('Saving sample images of top %d errors...', length(topErrors)));
            
            try
                % Create subdirectory for error samples
                sampleDir = fullfile(outputDir, sprintf('%s_error_samples', modelName));
                if ~exist(sampleDir, 'dir')
                    mkdir(sampleDir);
                end
                
                % Create a figure showing top errors
                numErrors = min(10, length(topErrors));
                numRows = ceil(numErrors / 5);
                numCols = min(5, numErrors);
                
                fig = figure('Position', [100, 100, 300*numCols, 300*numRows]);
                
                for i = 1:numErrors
                    error_info = topErrors(i);
                    
                    % Find image in datastore
                    imgIdx = find(strcmp(obj.imageFilenames, error_info.filename), 1);
                    if isempty(imgIdx)
                        continue;
                    end
                    
                    % Read image
                    reset(obj.testDatastore);
                    for j = 1:imgIdx
                        data = read(obj.testDatastore);
                    end
                    
                    if iscell(data)
                        img = data{1};
                    else
                        img = data;
                    end
                    
                    % Display in subplot
                    subplot(numRows, numCols, i);
                    imshow(img);
                    title(sprintf('True: %s\nPred: %s (%.1f%%)\nCorroded: %.1f%%', ...
                        error_info.trueLabel, error_info.predictedLabel, ...
                        error_info.confidence * 100, error_info.corrodedPercentage), ...
                        'FontSize', 8, 'Interpreter', 'none');
                end
                
                % Save figure
                figPath = fullfile(sampleDir, sprintf('%s_top_errors.png', modelName));
                saveas(fig, figPath);
                obj.errorHandler.logInfo('ErrorAnalyzer', ...
                    sprintf('Error samples saved: %s', figPath));
                
                close(fig);
                
            catch ME
                obj.errorHandler.logError('ErrorAnalyzer', ...
                    sprintf('Failed to save sample images: %s', ME.message));
            end
        end
        
        function saveReportAsText(obj, report, filepath)
            % Save error analysis report as text file
            % Inputs:
            %   report - Report struct
            %   filepath - Path to save text file
            
            try
                fid = fopen(filepath, 'w');
                if fid == -1
                    error('Cannot open file: %s', filepath);
                end
                
                % Write header
                fprintf(fid, '=================================================\n');
                fprintf(fid, 'ERROR ANALYSIS REPORT\n');
                fprintf(fid, '=================================================\n\n');
                
                fprintf(fid, 'Model: %s\n', report.modelName);
                fprintf(fid, 'Timestamp: %s\n\n', char(report.timestamp));
                
                % Overall statistics
                fprintf(fid, '=== Overall Statistics ===\n');
                fprintf(fid, 'Total samples: %d\n', report.totalSamples);
                fprintf(fid, 'Correct predictions: %d (%.2f%%)\n', ...
                    report.correctPredictions, report.accuracy * 100);
                fprintf(fid, 'Incorrect predictions: %d (%.2f%%)\n\n', ...
                    report.incorrectPredictions, (1 - report.accuracy) * 100);
                
                % Correlation analysis
                fprintf(fid, '=== Correlation Analysis ===\n');
                fprintf(fid, 'True class vs corroded %%: r = %.4f\n', ...
                    report.correlation.trueClassVsPercentage);
                fprintf(fid, 'Predicted class vs corroded %%: r = %.4f\n', ...
                    report.correlation.predictedClassVsPercentage);
                fprintf(fid, 'True vs predicted class: r = %.4f\n\n', ...
                    report.correlation.trueVsPredicted);
                
                fprintf(fid, 'Mean corroded %% per class:\n');
                for i = 1:length(report.correlation.meanPercentagePerClass)
                    fprintf(fid, '  %s: %.2f%% ± %.2f%%\n', ...
                        obj.classNames{i}, ...
                        report.correlation.meanPercentagePerClass(i), ...
                        report.correlation.stdPercentagePerClass(i));
                end
                fprintf(fid, '\n');
                
                % Top misclassifications
                fprintf(fid, '=== Top Misclassifications ===\n');
                if ~isempty(report.topMisclassifications)
                    for i = 1:length(report.topMisclassifications)
                        error_info = report.topMisclassifications(i);
                        fprintf(fid, '%d. %s\n', i, error_info.filename);
                        fprintf(fid, '   True: %s, Predicted: %s\n', ...
                            error_info.trueLabel, error_info.predictedLabel);
                        fprintf(fid, '   Confidence: %.2f%%\n', error_info.confidence * 100);
                        fprintf(fid, '   Corroded %%: %.2f%%\n\n', error_info.corrodedPercentage);
                    end
                else
                    fprintf(fid, 'No misclassifications found!\n\n');
                end
                
                % Confusion patterns
                fprintf(fid, '=== Confusion Patterns ===\n');
                if ~isempty(report.confusionPatterns)
                    for i = 1:min(10, length(report.confusionPatterns))
                        pattern = report.confusionPatterns(i);
                        fprintf(fid, '%s → %s: %d cases (%.2f%%)\n', ...
                            pattern.trueClass, pattern.predictedClass, ...
                            pattern.count, pattern.percentage);
                    end
                else
                    fprintf(fid, 'No confusion patterns found!\n');
                end
                fprintf(fid, '\n');
                
                % Insights
                fprintf(fid, '=== Insights for Model Improvement ===\n');
                for i = 1:length(report.insights)
                    fprintf(fid, '%d. %s\n', i, report.insights{i});
                end
                fprintf(fid, '\n');
                
                fclose(fid);
                
                obj.errorHandler.logInfo('ErrorAnalyzer', ...
                    sprintf('Text report saved: %s', filepath));
                
            catch ME
                if fid ~= -1
                    fclose(fid);
                end
                obj.errorHandler.logError('ErrorAnalyzer', ...
                    sprintf('Failed to save text report: %s', ME.message));
            end
        end
    end
end
