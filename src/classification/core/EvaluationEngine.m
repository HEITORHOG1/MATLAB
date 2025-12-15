% EvaluationEngine.m - Comprehensive model evaluation with metrics and visualizations
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This class provides comprehensive evaluation capabilities including:
%   - Overall and per-class metrics (accuracy, precision, recall, F1)
%   - Confusion matrix generation and visualization
%   - ROC curves and AUC scores (one-vs-rest for multi-class)
%   - Inference speed benchmarking
%   - Comprehensive evaluation reports
%
% Requirements addressed: 5.1, 5.2, 5.3, 5.4, 5.5

classdef EvaluationEngine < handle
    % EvaluationEngine - Comprehensive model evaluation with metrics and visualizations
    %
    % This class provides comprehensive evaluation capabilities including:
    %   - Overall and per-class metrics (accuracy, precision, recall, F1)
    %   - Confusion matrix generation and visualization
    %   - ROC curves and AUC scores (one-vs-rest for multi-class)
    %   - Inference speed benchmarking
    %   - Comprehensive evaluation reports
    %
    % Requirements addressed: 5.1, 5.2, 5.3, 5.4, 5.5
    
    properties (Access = private)
        net                 % Trained network
        testDatastore       % Test datastore
        classNames          % Cell array of class names
        errorHandler        % ErrorHandler instance for logging
        
        % Cached results
        predictions         % Predicted labels
        scores              % Prediction scores (probabilities)
        trueLabels          % True labels
        confusionMatrix     % Confusion matrix
        metrics             % Computed metrics struct
    end
    
    methods
        function obj = EvaluationEngine(net, testDatastore, classNames, errorHandler)
            % Constructor
            % Inputs:
            %   net - Trained network (SeriesNetwork, DAGNetwork, or dlnetwork)
            %   testDatastore - Test datastore (imageDatastore or augmentedImageDatastore)
            %   classNames - Cell array of class names (e.g., {'Class 0', 'Class 1', 'Class 2'})
            %   errorHandler - ErrorHandler instance (optional)
            %
            % Requirements: 5.1
            
            if nargin < 3
                error('EvaluationEngine:InvalidInput', ...
                    'Network, test datastore, and class names are required');
            end
            
            obj.net = net;
            obj.testDatastore = testDatastore;
            obj.classNames = classNames;
            
            % Initialize error handler
            if nargin >= 4 && ~isempty(errorHandler)
                obj.errorHandler = errorHandler;
            else
                obj.errorHandler = ErrorHandler.getInstance();
            end
            
            % Initialize cached results
            obj.predictions = [];
            obj.scores = [];
            obj.trueLabels = [];
            obj.confusionMatrix = [];
            obj.metrics = struct();
            
            obj.errorHandler.logInfo('EvaluationEngine', 'EvaluationEngine initialized');
            obj.errorHandler.logInfo('EvaluationEngine', ...
                sprintf('Number of classes: %d', length(classNames)));
        end
        
        function metrics = computeMetrics(obj)
            % Compute overall and per-class metrics
            % Output:
            %   metrics - Struct containing:
            %             - accuracy: overall accuracy
            %             - macroF1: macro-averaged F1 score
            %             - weightedF1: weighted F1 score
            %             - perClass: struct with per-class precision, recall, F1
            %
            % Requirements: 5.1
            
            obj.errorHandler.logInfo('EvaluationEngine', 'Computing evaluation metrics...');
            
            % Get predictions if not already computed
            if isempty(obj.predictions)
                obj.getPredictions();
            end
            
            try
                numClasses = length(obj.classNames);
                
                % Initialize per-class metrics
                precision = zeros(numClasses, 1);
                recall = zeros(numClasses, 1);
                f1Score = zeros(numClasses, 1);
                support = zeros(numClasses, 1);
                
                % Compute confusion matrix if not already done
                if isempty(obj.confusionMatrix)
                    obj.generateConfusionMatrix();
                end
                
                % Compute per-class metrics
                for i = 1:numClasses
                    % True Positives: diagonal element
                    TP = obj.confusionMatrix(i, i);
                    
                    % False Positives: sum of column i excluding diagonal
                    FP = sum(obj.confusionMatrix(:, i)) - TP;
                    
                    % False Negatives: sum of row i excluding diagonal
                    FN = sum(obj.confusionMatrix(i, :)) - TP;
                    
                    % True Negatives: sum of all elements except row i and column i
                    TN = sum(obj.confusionMatrix(:)) - TP - FP - FN;
                    
                    % Support: number of true samples for this class
                    support(i) = sum(obj.confusionMatrix(i, :));
                    
                    % Precision: TP / (TP + FP)
                    if (TP + FP) > 0
                        precision(i) = TP / (TP + FP);
                    else
                        precision(i) = 0;
                    end
                    
                    % Recall: TP / (TP + FN)
                    if (TP + FN) > 0
                        recall(i) = TP / (TP + FN);
                    else
                        recall(i) = 0;
                    end
                    
                    % F1-Score: 2 × (Precision × Recall) / (Precision + Recall)
                    if (precision(i) + recall(i)) > 0
                        f1Score(i) = 2 * (precision(i) * recall(i)) / (precision(i) + recall(i));
                    else
                        f1Score(i) = 0;
                    end
                    
                    obj.errorHandler.logInfo('EvaluationEngine', ...
                        sprintf('%s - Precision: %.4f, Recall: %.4f, F1: %.4f (n=%d)', ...
                        obj.classNames{i}, precision(i), recall(i), f1Score(i), support(i)));
                end
                
                % Overall accuracy: (TP + TN) / Total
                % For multi-class, this is sum of diagonal / total samples
                accuracy = sum(diag(obj.confusionMatrix)) / sum(obj.confusionMatrix(:));
                
                % Macro-averaged F1: mean of per-class F1 scores
                macroF1 = mean(f1Score);
                
                % Weighted F1: weighted average by support
                totalSupport = sum(support);
                if totalSupport > 0
                    weightedF1 = sum(f1Score .* support) / totalSupport;
                else
                    weightedF1 = 0;
                end
                
                % Store metrics
                metrics = struct();
                metrics.accuracy = accuracy;
                metrics.macroF1 = macroF1;
                metrics.weightedF1 = weightedF1;
                
                % Per-class metrics
                metrics.perClass = struct();
                for i = 1:numClasses
                    className = obj.classNames{i};
                    % Remove spaces and special characters for field name
                    fieldName = matlab.lang.makeValidName(className);
                    
                    metrics.perClass.(fieldName) = struct(...
                        'precision', precision(i), ...
                        'recall', recall(i), ...
                        'f1', f1Score(i), ...
                        'support', support(i));
                end
                
                obj.metrics = metrics;
                
                obj.errorHandler.logInfo('EvaluationEngine', '=== Overall Metrics ===');
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Accuracy: %.4f (%.2f%%)', accuracy, accuracy * 100));
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Macro F1: %.4f', macroF1));
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Weighted F1: %.4f', weightedF1));
                
            catch ME
                obj.errorHandler.logError('EvaluationEngine', ...
                    sprintf('Failed to compute metrics: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function confMat = generateConfusionMatrix(obj)
            % Generate confusion matrix
            % Output:
            %   confMat - Confusion matrix (rows=true, cols=predicted)
            %
            % Requirements: 5.2
            
            obj.errorHandler.logInfo('EvaluationEngine', 'Generating confusion matrix...');
            
            % Get predictions if not already computed
            if isempty(obj.predictions)
                obj.getPredictions();
            end
            
            try
                numClasses = length(obj.classNames);
                
                % Initialize confusion matrix
                confMat = zeros(numClasses, numClasses);
                
                % Build confusion matrix
                for i = 1:length(obj.trueLabels)
                    trueIdx = double(obj.trueLabels(i));
                    predIdx = double(obj.predictions(i));
                    confMat(trueIdx, predIdx) = confMat(trueIdx, predIdx) + 1;
                end
                
                obj.confusionMatrix = confMat;
                
                obj.errorHandler.logInfo('EvaluationEngine', 'Confusion matrix generated');
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Total samples: %d', sum(confMat(:))));
                
                % Log confusion matrix
                obj.errorHandler.logInfo('EvaluationEngine', '=== Confusion Matrix ===');
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Rows: True labels, Columns: Predicted labels'));
                
                for i = 1:numClasses
                    rowStr = sprintf('%s: ', obj.classNames{i});
                    for j = 1:numClasses
                        rowStr = sprintf('%s %6d', rowStr, confMat(i, j));
                    end
                    obj.errorHandler.logInfo('EvaluationEngine', rowStr);
                end
                
            catch ME
                obj.errorHandler.logError('EvaluationEngine', ...
                    sprintf('Failed to generate confusion matrix: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function [fpr, tpr, auc] = computeROC(obj)
            % Compute ROC curves and AUC scores using one-vs-rest strategy
            % Outputs:
            %   fpr - Cell array of false positive rates for each class
            %   tpr - Cell array of true positive rates for each class
            %   auc - Array of AUC scores for each class
            %
            % Requirements: 5.3
            
            obj.errorHandler.logInfo('EvaluationEngine', 'Computing ROC curves and AUC scores...');
            
            % Get predictions if not already computed
            if isempty(obj.scores)
                obj.getPredictions();
            end
            
            try
                numClasses = length(obj.classNames);
                
                % Initialize outputs
                fpr = cell(numClasses, 1);
                tpr = cell(numClasses, 1);
                auc = zeros(numClasses, 1);
                
                % Compute ROC for each class using one-vs-rest
                for i = 1:numClasses
                    % Binary labels: 1 if true class is i, 0 otherwise
                    binaryTrue = double(obj.trueLabels == i);
                    
                    % Scores for class i
                    classScores = obj.scores(:, i);
                    
                    % Sort by scores in descending order
                    [sortedScores, sortIdx] = sort(classScores, 'descend');
                    sortedTrue = binaryTrue(sortIdx);
                    
                    % Compute cumulative TP and FP
                    numPositives = sum(binaryTrue);
                    numNegatives = length(binaryTrue) - numPositives;
                    
                    % Initialize arrays
                    tprArray = zeros(length(sortedTrue) + 1, 1);
                    fprArray = zeros(length(sortedTrue) + 1, 1);
                    
                    % Start at (0, 0)
                    tprArray(1) = 0;
                    fprArray(1) = 0;
                    
                    % Compute TPR and FPR at each threshold
                    TP = 0;
                    FP = 0;
                    for j = 1:length(sortedTrue)
                        if sortedTrue(j) == 1
                            TP = TP + 1;
                        else
                            FP = FP + 1;
                        end
                        
                        if numPositives > 0
                            tprArray(j + 1) = TP / numPositives;
                        else
                            tprArray(j + 1) = 0;
                        end
                        
                        if numNegatives > 0
                            fprArray(j + 1) = FP / numNegatives;
                        else
                            fprArray(j + 1) = 0;
                        end
                    end
                    
                    % Store results
                    fpr{i} = fprArray;
                    tpr{i} = tprArray;
                    
                    % Compute AUC using trapezoidal rule
                    auc(i) = trapz(fprArray, tprArray);
                    
                    obj.errorHandler.logInfo('EvaluationEngine', ...
                        sprintf('%s - AUC: %.4f', obj.classNames{i}, auc(i)));
                end
                
                % Compute micro-averaged ROC (treating all classes together)
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Mean AUC: %.4f', mean(auc)));
                
            catch ME
                obj.errorHandler.logError('EvaluationEngine', ...
                    sprintf('Failed to compute ROC curves: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function [avgTime, throughput, memoryUsage] = measureInferenceSpeed(obj, numSamples)
            % Measure inference speed and memory usage
            % Inputs:
            %   numSamples - Number of samples to use for measurement (default: 100)
            % Outputs:
            %   avgTime - Average inference time per image in milliseconds
            %   throughput - Throughput in images per second
            %   memoryUsage - GPU memory usage in MB (if GPU available)
            %
            % Requirements: 5.4, 10.1, 10.2
            
            if nargin < 2 || isempty(numSamples)
                numSamples = 100;
            end
            
            obj.errorHandler.logInfo('EvaluationEngine', ...
                sprintf('Measuring inference speed with %d samples...', numSamples));
            
            try
                % Reset datastore
                reset(obj.testDatastore);
                
                % Get sample images
                sampleImages = {};
                count = 0;
                while hasdata(obj.testDatastore) && count < numSamples
                    data = read(obj.testDatastore);
                    if iscell(data)
                        sampleImages{end+1} = data{1};
                    else
                        sampleImages{end+1} = data;
                    end
                    count = count + 1;
                end
                
                if isempty(sampleImages)
                    error('EvaluationEngine:NoData', 'No samples available for inference speed measurement');
                end
                
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Loaded %d samples for benchmarking', length(sampleImages)));
                
                % Warm-up: run 10 inference passes
                obj.errorHandler.logInfo('EvaluationEngine', 'Warming up model (10 passes)...');
                for i = 1:min(10, length(sampleImages))
                    classify(obj.net, sampleImages{i});
                end
                
                % Measure inference time
                obj.errorHandler.logInfo('EvaluationEngine', 'Measuring inference time...');
                
                % Check if GPU is available
                gpuAvailable = canUseGPU();
                if gpuAvailable
                    obj.errorHandler.logInfo('EvaluationEngine', 'GPU detected - using GPU for inference');
                    
                    % Measure GPU memory before inference
                    gpuDevice();
                    memBefore = gpuDevice().AvailableMemory / (1024^2); % Convert to MB
                end
                
                % Time the inference
                tic;
                for i = 1:length(sampleImages)
                    classify(obj.net, sampleImages{i});
                end
                totalTime = toc;
                
                % Calculate metrics
                avgTime = (totalTime / length(sampleImages)) * 1000; % Convert to milliseconds
                throughput = length(sampleImages) / totalTime; % Images per second
                
                % Measure GPU memory after inference
                if gpuAvailable
                    memAfter = gpuDevice().AvailableMemory / (1024^2); % Convert to MB
                    memoryUsage = memBefore - memAfter;
                    
                    obj.errorHandler.logInfo('EvaluationEngine', ...
                        sprintf('GPU memory usage: %.2f MB', memoryUsage));
                else
                    memoryUsage = NaN;
                    obj.errorHandler.logInfo('EvaluationEngine', 'GPU not available - memory usage not measured');
                end
                
                obj.errorHandler.logInfo('EvaluationEngine', '=== Inference Speed Results ===');
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Average time per image: %.2f ms', avgTime));
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Throughput: %.2f images/second', throughput));
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Total time for %d images: %.2f seconds', length(sampleImages), totalTime));
                
                % Check against real-time threshold (30 fps = 33.33 ms per frame)
                realtimeThreshold = 33.33;
                if avgTime < realtimeThreshold
                    obj.errorHandler.logInfo('EvaluationEngine', ...
                        sprintf('✓ Model meets real-time requirement (< %.2f ms)', realtimeThreshold));
                else
                    obj.errorHandler.logWarning('EvaluationEngine', ...
                        sprintf('✗ Model does not meet real-time requirement (< %.2f ms)', realtimeThreshold));
                end
                
                % Reset datastore
                reset(obj.testDatastore);
                
            catch ME
                obj.errorHandler.logError('EvaluationEngine', ...
                    sprintf('Failed to measure inference speed: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function report = generateEvaluationReport(obj, modelName, outputDir)
            % Generate comprehensive evaluation report
            % Inputs:
            %   modelName - Name of the model being evaluated
            %   outputDir - Directory to save report (optional)
            % Output:
            %   report - Struct containing all evaluation results
            %
            % Requirements: 5.5
            
            if nargin < 2 || isempty(modelName)
                modelName = 'model';
            end
            
            obj.errorHandler.logInfo('EvaluationEngine', ...
                sprintf('Generating evaluation report for: %s', modelName));
            
            try
                % Initialize report
                report = struct();
                report.modelName = modelName;
                report.timestamp = datetime('now');
                report.numClasses = length(obj.classNames);
                report.classNames = obj.classNames;
                
                % Compute all metrics if not already done
                if isempty(obj.metrics)
                    obj.computeMetrics();
                end
                report.metrics = obj.metrics;
                
                % Generate confusion matrix if not already done
                if isempty(obj.confusionMatrix)
                    obj.generateConfusionMatrix();
                end
                report.confusionMatrix = obj.confusionMatrix;
                
                % Compute normalized confusion matrix (percentages)
                rowSums = sum(obj.confusionMatrix, 2);
                normalizedConfMat = obj.confusionMatrix ./ rowSums;
                normalizedConfMat(isnan(normalizedConfMat)) = 0; % Handle division by zero
                report.normalizedConfusionMatrix = normalizedConfMat;
                
                % Compute ROC curves
                [fpr, tpr, auc] = obj.computeROC();
                report.roc = struct('fpr', {fpr}, 'tpr', {tpr}, 'auc', auc);
                
                % Measure inference speed
                [avgTime, throughput, memoryUsage] = obj.measureInferenceSpeed();
                report.inferenceTime = avgTime;
                report.throughput = throughput;
                report.memoryUsage = memoryUsage;
                
                % Add summary statistics
                report.totalSamples = length(obj.trueLabels);
                report.correctPredictions = sum(obj.predictions == obj.trueLabels);
                report.incorrectPredictions = sum(obj.predictions ~= obj.trueLabels);
                
                obj.errorHandler.logInfo('EvaluationEngine', '=== Evaluation Report Summary ===');
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Model: %s', modelName));
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Total samples: %d', report.totalSamples));
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Correct predictions: %d (%.2f%%)', ...
                    report.correctPredictions, report.metrics.accuracy * 100));
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Macro F1: %.4f', report.metrics.macroF1));
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Mean AUC: %.4f', mean(report.roc.auc)));
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Inference time: %.2f ms/image', report.inferenceTime));
                
                % Save report if output directory provided
                if nargin >= 3 && ~isempty(outputDir)
                    if ~exist(outputDir, 'dir')
                        mkdir(outputDir);
                    end
                    
                    reportPath = fullfile(outputDir, sprintf('%s_evaluation_report.mat', modelName));
                    save(reportPath, 'report', '-v7.3');
                    
                    obj.errorHandler.logInfo('EvaluationEngine', ...
                        sprintf('Evaluation report saved: %s', reportPath));
                    
                    % Also save as text file
                    txtPath = fullfile(outputDir, sprintf('%s_evaluation_report.txt', modelName));
                    obj.saveReportAsText(report, txtPath);
                end
                
            catch ME
                obj.errorHandler.logError('EvaluationEngine', ...
                    sprintf('Failed to generate evaluation report: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function normalizedConfMat = getNormalizedConfusionMatrix(obj)
            % Get normalized confusion matrix (percentages by row)
            % Output:
            %   normalizedConfMat - Normalized confusion matrix
            %
            % Requirements: 5.2
            
            if isempty(obj.confusionMatrix)
                obj.generateConfusionMatrix();
            end
            
            rowSums = sum(obj.confusionMatrix, 2);
            normalizedConfMat = obj.confusionMatrix ./ rowSums;
            normalizedConfMat(isnan(normalizedConfMat)) = 0; % Handle division by zero
        end
    end
    
    methods (Access = private)
        function getPredictions(obj)
            % Get predictions and scores for all test samples
            % This method caches predictions to avoid recomputation
            
            obj.errorHandler.logInfo('EvaluationEngine', 'Computing predictions for test set...');
            
            try
                % Reset datastore
                reset(obj.testDatastore);
                
                % Initialize arrays
                predictions = [];
                scores = [];
                trueLabels = [];
                
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
                        label = categorical(NaN); % No label available
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
                        obj.errorHandler.logInfo('EvaluationEngine', ...
                            sprintf('Processed %d samples...', count));
                    end
                end
                
                % Store cached results
                obj.predictions = predictions;
                obj.scores = scores;
                obj.trueLabels = trueLabels;
                
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Predictions computed for %d samples', count));
                
                % Reset datastore
                reset(obj.testDatastore);
                
            catch ME
                obj.errorHandler.logError('EvaluationEngine', ...
                    sprintf('Failed to get predictions: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function saveReportAsText(obj, report, filepath)
            % Save evaluation report as text file
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
                fprintf(fid, 'EVALUATION REPORT\n');
                fprintf(fid, '=================================================\n\n');
                
                fprintf(fid, 'Model: %s\n', report.modelName);
                fprintf(fid, 'Timestamp: %s\n', char(report.timestamp));
                fprintf(fid, 'Number of classes: %d\n', report.numClasses);
                fprintf(fid, 'Class names: %s\n\n', strjoin(report.classNames, ', '));
                
                % Overall metrics
                fprintf(fid, '=== Overall Metrics ===\n');
                fprintf(fid, 'Accuracy: %.4f (%.2f%%)\n', report.metrics.accuracy, report.metrics.accuracy * 100);
                fprintf(fid, 'Macro F1: %.4f\n', report.metrics.macroF1);
                fprintf(fid, 'Weighted F1: %.4f\n\n', report.metrics.weightedF1);
                
                % Per-class metrics
                fprintf(fid, '=== Per-Class Metrics ===\n');
                fields = fieldnames(report.metrics.perClass);
                for i = 1:length(fields)
                    classMetrics = report.metrics.perClass.(fields{i});
                    fprintf(fid, '%s:\n', report.classNames{i});
                    fprintf(fid, '  Precision: %.4f\n', classMetrics.precision);
                    fprintf(fid, '  Recall: %.4f\n', classMetrics.recall);
                    fprintf(fid, '  F1-Score: %.4f\n', classMetrics.f1);
                    fprintf(fid, '  Support: %d\n', classMetrics.support);
                end
                fprintf(fid, '\n');
                
                % Confusion matrix
                fprintf(fid, '=== Confusion Matrix ===\n');
                fprintf(fid, 'Rows: True labels, Columns: Predicted labels\n');
                for i = 1:report.numClasses
                    fprintf(fid, '%s: ', report.classNames{i});
                    for j = 1:report.numClasses
                        fprintf(fid, '%6d ', report.confusionMatrix(i, j));
                    end
                    fprintf(fid, '\n');
                end
                fprintf(fid, '\n');
                
                % Normalized confusion matrix
                fprintf(fid, '=== Normalized Confusion Matrix (Percentages) ===\n');
                for i = 1:report.numClasses
                    fprintf(fid, '%s: ', report.classNames{i});
                    for j = 1:report.numClasses
                        fprintf(fid, '%6.2f%% ', report.normalizedConfusionMatrix(i, j) * 100);
                    end
                    fprintf(fid, '\n');
                end
                fprintf(fid, '\n');
                
                % ROC/AUC
                fprintf(fid, '=== ROC/AUC Scores ===\n');
                for i = 1:report.numClasses
                    fprintf(fid, '%s: %.4f\n', report.classNames{i}, report.roc.auc(i));
                end
                fprintf(fid, 'Mean AUC: %.4f\n\n', mean(report.roc.auc));
                
                % Inference speed
                fprintf(fid, '=== Inference Speed ===\n');
                fprintf(fid, 'Average time per image: %.2f ms\n', report.inferenceTime);
                fprintf(fid, 'Throughput: %.2f images/second\n', report.throughput);
                if ~isnan(report.memoryUsage)
                    fprintf(fid, 'GPU memory usage: %.2f MB\n', report.memoryUsage);
                end
                fprintf(fid, '\n');
                
                % Summary
                fprintf(fid, '=== Summary ===\n');
                fprintf(fid, 'Total samples: %d\n', report.totalSamples);
                fprintf(fid, 'Correct predictions: %d (%.2f%%)\n', ...
                    report.correctPredictions, report.metrics.accuracy * 100);
                fprintf(fid, 'Incorrect predictions: %d (%.2f%%)\n', ...
                    report.incorrectPredictions, (1 - report.metrics.accuracy) * 100);
                
                fclose(fid);
                
                obj.errorHandler.logInfo('EvaluationEngine', ...
                    sprintf('Text report saved: %s', filepath));
                
            catch ME
                if fid ~= -1
                    fclose(fid);
                end
                obj.errorHandler.logError('EvaluationEngine', ...
                    sprintf('Failed to save text report: %s', ME.message));
            end
        end
    end
end
