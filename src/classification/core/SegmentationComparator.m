% SegmentationComparator.m - Compare classification vs segmentation approaches
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This class provides utilities for comparing classification and segmentation:
%   - Load segmentation model inference times
%   - Compare classification vs segmentation inference times
%   - Calculate speedup factors
%   - Generate comparison tables and visualizations
%
% Requirements addressed: 10.3

classdef SegmentationComparator < handle
    % SegmentationComparator - Compare classification vs segmentation approaches
    %
    % This class provides utilities for comparing classification and segmentation:
    %   - Load segmentation model inference times
    %   - Compare classification vs segmentation inference times
    %   - Calculate speedup factors
    %   - Generate comparison tables and visualizations
    %
    % Requirements addressed: 10.3
    
    properties (Access = private)
        classificationResults   % Classification model results
        segmentationResults     % Segmentation model results
        errorHandler            % ErrorHandler instance for logging
    end
    
    methods
        function obj = SegmentationComparator(errorHandler)
            % Constructor
            % Inputs:
            %   errorHandler - ErrorHandler instance (optional)
            %
            % Requirements: 10.3
            
            obj.classificationResults = struct();
            obj.segmentationResults = struct();
            
            % Initialize error handler
            if nargin >= 1 && ~isempty(errorHandler)
                obj.errorHandler = errorHandler;
            else
                obj.errorHandler = ErrorHandler.getInstance();
            end
            
            obj.errorHandler.logInfo('SegmentationComparator', 'SegmentationComparator initialized');
        end
        
        function loadClassificationResults(obj, resultsDir)
            % Load classification model results
            % Inputs:
            %   resultsDir - Directory containing classification evaluation reports
            %
            % Requirements: 10.3
            
            obj.errorHandler.logInfo('SegmentationComparator', ...
                sprintf('Loading classification results from: %s', resultsDir));
            
            if ~isfolder(resultsDir)
                error('SegmentationComparator:InvalidPath', ...
                    'Results directory does not exist: %s', resultsDir);
            end
            
            % Find all evaluation report files
            files = dir(fullfile(resultsDir, '*_evaluation_report.mat'));
            
            if isempty(files)
                obj.errorHandler.logWarning('SegmentationComparator', ...
                    'No classification evaluation report files found');
                return;
            end
            
            % Load each result
            for i = 1:length(files)
                filepath = fullfile(files(i).folder, files(i).name);
                
                try
                    data = load(filepath);
                    if isfield(data, 'report')
                        result = data.report;
                        modelName = result.modelName;
                        
                        % Extract relevant metrics
                        obj.classificationResults.(modelName) = struct(...
                            'inferenceTime', result.inferenceTime, ...
                            'throughput', result.throughput, ...
                            'accuracy', result.metrics.accuracy, ...
                            'macroF1', result.metrics.macroF1, ...
                            'memoryUsage', result.memoryUsage);
                        
                        obj.errorHandler.logInfo('SegmentationComparator', ...
                            sprintf('Loaded classification result: %s', modelName));
                    end
                catch ME
                    obj.errorHandler.logError('SegmentationComparator', ...
                        sprintf('Failed to load file %s: %s', files(i).name, ME.message));
                end
            end
            
            obj.errorHandler.logInfo('SegmentationComparator', ...
                sprintf('Loaded %d classification model results', ...
                length(fieldnames(obj.classificationResults))));
        end
        
        function loadSegmentationResults(obj, resultsDir)
            % Load segmentation model results
            % Inputs:
            %   resultsDir - Directory containing segmentation results
            %
            % Note: This method attempts to load existing segmentation results.
            % If timing data is not available, it will use estimated values.
            %
            % Requirements: 10.3
            
            obj.errorHandler.logInfo('SegmentationComparator', ...
                sprintf('Loading segmentation results from: %s', resultsDir));
            
            if ~isfolder(resultsDir)
                obj.errorHandler.logWarning('SegmentationComparator', ...
                    sprintf('Segmentation results directory does not exist: %s', resultsDir));
                obj.useEstimatedSegmentationTimes();
                return;
            end
            
            % Try to find segmentation timing results
            % Look for MAT files with timing information
            files = dir(fullfile(resultsDir, '*.mat'));
            
            foundTiming = false;
            for i = 1:length(files)
                filepath = fullfile(files(i).folder, files(i).name);
                
                try
                    data = load(filepath);
                    
                    % Check for timing fields
                    if isfield(data, 'inferenceTime') || isfield(data, 'avgInferenceTime')
                        % Extract timing data
                        if isfield(data, 'modelName')
                            modelName = data.modelName;
                        else
                            % Infer model name from filename
                            [~, modelName, ~] = fileparts(files(i).name);
                        end
                        
                        if isfield(data, 'inferenceTime')
                            inferenceTime = data.inferenceTime;
                        elseif isfield(data, 'avgInferenceTime')
                            inferenceTime = data.avgInferenceTime;
                        end
                        
                        obj.segmentationResults.(modelName) = struct(...
                            'inferenceTime', inferenceTime, ...
                            'throughput', 1000 / inferenceTime);
                        
                        foundTiming = true;
                        obj.errorHandler.logInfo('SegmentationComparator', ...
                            sprintf('Loaded segmentation result: %s', modelName));
                    end
                catch ME
                    % Continue to next file
                    continue;
                end
            end
            
            % If no timing data found, use estimated values
            if ~foundTiming
                obj.errorHandler.logWarning('SegmentationComparator', ...
                    'No segmentation timing data found. Using estimated values.');
                obj.useEstimatedSegmentationTimes();
            end
        end
        
        function useEstimatedSegmentationTimes(obj)
            % Use estimated segmentation inference times
            % Based on typical U-Net and Attention U-Net performance
            %
            % Requirements: 10.3
            
            obj.errorHandler.logInfo('SegmentationComparator', ...
                'Using estimated segmentation inference times');
            
            % Typical segmentation model inference times (in milliseconds)
            % These are conservative estimates for 224x224 images
            obj.segmentationResults.UNet = struct(...
                'inferenceTime', 150, ...  % ~150ms per image
                'throughput', 1000 / 150, ...
                'estimated', true);
            
            obj.segmentationResults.AttentionUNet = struct(...
                'inferenceTime', 200, ...  % ~200ms per image (slower due to attention)
                'throughput', 1000 / 200, ...
                'estimated', true);
            
            obj.errorHandler.logWarning('SegmentationComparator', ...
                'Using estimated times: U-Net=150ms, Attention U-Net=200ms');
        end
        
        function compTable = createComparisonTable(obj)
            % Create comparison table between classification and segmentation
            % Output:
            %   compTable - Table with columns: Model, Type, InferenceTime, 
            %               Throughput, Speedup
            %
            % Requirements: 10.3
            
            obj.errorHandler.logInfo('SegmentationComparator', ...
                'Creating classification vs segmentation comparison table...');
            
            if isempty(fieldnames(obj.classificationResults)) && ...
               isempty(fieldnames(obj.segmentationResults))
                error('SegmentationComparator:NoResults', ...
                    'No results available for comparison');
            end
            
            % Collect all models
            modelNames = {};
            modelTypes = {};
            inferenceTimes = [];
            throughputs = [];
            
            % Add classification models
            classModels = fieldnames(obj.classificationResults);
            for i = 1:length(classModels)
                modelName = classModels{i};
                result = obj.classificationResults.(modelName);
                
                modelNames{end+1} = modelName;
                modelTypes{end+1} = 'Classification';
                inferenceTimes(end+1) = result.inferenceTime;
                throughputs(end+1) = result.throughput;
            end
            
            % Add segmentation models
            segModels = fieldnames(obj.segmentationResults);
            for i = 1:length(segModels)
                modelName = segModels{i};
                result = obj.segmentationResults.(modelName);
                
                modelNames{end+1} = modelName;
                modelTypes{end+1} = 'Segmentation';
                inferenceTimes(end+1) = result.inferenceTime;
                throughputs(end+1) = result.throughput;
            end
            
            % Calculate speedup relative to slowest segmentation model
            if ~isempty(segModels)
                % Find slowest segmentation time as baseline
                segTimes = [];
                for i = 1:length(segModels)
                    segTimes(end+1) = obj.segmentationResults.(segModels{i}).inferenceTime;
                end
                baselineTime = max(segTimes);
                
                % Calculate speedup for each model
                speedups = baselineTime ./ inferenceTimes;
            else
                % No segmentation baseline, use 1.0 for all
                speedups = ones(size(inferenceTimes));
            end
            
            % Create table
            compTable = table(modelNames', modelTypes', inferenceTimes', ...
                throughputs', speedups', ...
                'VariableNames', {'Model', 'Type', 'InferenceTime_ms', ...
                'Throughput_imgs_per_sec', 'SpeedupVsSegmentation'});
            
            % Sort by inference time
            compTable = sortrows(compTable, 'InferenceTime_ms');
            
            obj.errorHandler.logInfo('SegmentationComparator', ...
                '=== Classification vs Segmentation Comparison ===');
            disp(compTable);
        end
        
        function speedupFactors = calculateSpeedupFactors(obj)
            % Calculate speedup factors for classification vs segmentation
            % Output:
            %   speedupFactors - Struct with speedup factors for each classification model
            %
            % Requirements: 10.3
            
            obj.errorHandler.logInfo('SegmentationComparator', ...
                'Calculating speedup factors...');
            
            if isempty(fieldnames(obj.classificationResults))
                error('SegmentationComparator:NoResults', ...
                    'No classification results available');
            end
            
            if isempty(fieldnames(obj.segmentationResults))
                error('SegmentationComparator:NoResults', ...
                    'No segmentation results available');
            end
            
            speedupFactors = struct();
            
            % Get average segmentation time as baseline
            segModels = fieldnames(obj.segmentationResults);
            segTimes = [];
            for i = 1:length(segModels)
                segTimes(end+1) = obj.segmentationResults.(segModels{i}).inferenceTime;
            end
            avgSegTime = mean(segTimes);
            maxSegTime = max(segTimes);
            minSegTime = min(segTimes);
            
            obj.errorHandler.logInfo('SegmentationComparator', ...
                sprintf('Segmentation baseline - Avg: %.2f ms, Min: %.2f ms, Max: %.2f ms', ...
                avgSegTime, minSegTime, maxSegTime));
            
            % Calculate speedup for each classification model
            classModels = fieldnames(obj.classificationResults);
            for i = 1:length(classModels)
                modelName = classModels{i};
                classTime = obj.classificationResults.(modelName).inferenceTime;
                
                speedupFactors.(modelName) = struct(...
                    'vsAverage', avgSegTime / classTime, ...
                    'vsMin', minSegTime / classTime, ...
                    'vsMax', maxSegTime / classTime, ...
                    'classificationTime', classTime, ...
                    'segmentationAvgTime', avgSegTime);
                
                obj.errorHandler.logInfo('SegmentationComparator', ...
                    sprintf('%s: %.2fx faster than avg segmentation (%.2f ms vs %.2f ms)', ...
                    modelName, speedupFactors.(modelName).vsAverage, classTime, avgSegTime));
            end
        end
        
        function generateComparisonVisualization(obj, outputDir, filename)
            % Generate comparison visualization
            % Inputs:
            %   outputDir - Directory to save figure
            %   filename - Base filename (without extension)
            %
            % Requirements: 10.3
            
            if nargin < 3
                filename = 'classification_vs_segmentation';
            end
            
            obj.errorHandler.logInfo('SegmentationComparator', ...
                'Generating comparison visualization...');
            
            if ~isfolder(outputDir)
                mkdir(outputDir);
            end
            
            try
                % Create comparison table
                compTable = obj.createComparisonTable();
                
                % Create figure
                fig = figure('Position', [100, 100, 1200, 600]);
                
                % Subplot 1: Inference time comparison
                subplot(1, 2, 1);
                
                % Separate classification and segmentation models
                classIdx = strcmp(compTable.Type, 'Classification');
                segIdx = strcmp(compTable.Type, 'Segmentation');
                
                % Create bar chart
                hold on;
                classModels = compTable.Model(classIdx);
                classTimes = compTable.InferenceTime_ms(classIdx);
                segModels = compTable.Model(segIdx);
                segTimes = compTable.InferenceTime_ms(segIdx);
                
                numClass = length(classModels);
                numSeg = length(segModels);
                
                % Plot bars
                if numClass > 0
                    bar(1:numClass, classTimes, 'FaceColor', [0.2, 0.6, 0.8]);
                end
                if numSeg > 0
                    bar((numClass+1):(numClass+numSeg), segTimes, 'FaceColor', [0.8, 0.4, 0.2]);
                end
                
                % Add real-time threshold line (30 fps = 33.33 ms)
                yline(33.33, 'r--', 'LineWidth', 2, 'Label', 'Real-time (30 fps)');
                
                % Labels and formatting
                allModels = [classModels; segModels];
                xticks(1:length(allModels));
                xticklabels(allModels);
                xtickangle(45);
                ylabel('Inference Time (ms)');
                title('Inference Time Comparison');
                grid on;
                legend('Classification', 'Segmentation', 'Real-time threshold', 'Location', 'best');
                hold off;
                
                % Subplot 2: Throughput comparison
                subplot(1, 2, 2);
                
                hold on;
                classThroughput = compTable.Throughput_imgs_per_sec(classIdx);
                segThroughput = compTable.Throughput_imgs_per_sec(segIdx);
                
                % Plot bars
                if numClass > 0
                    bar(1:numClass, classThroughput, 'FaceColor', [0.2, 0.6, 0.8]);
                end
                if numSeg > 0
                    bar((numClass+1):(numClass+numSeg), segThroughput, 'FaceColor', [0.8, 0.4, 0.2]);
                end
                
                % Labels and formatting
                xticks(1:length(allModels));
                xticklabels(allModels);
                xtickangle(45);
                ylabel('Throughput (images/second)');
                title('Throughput Comparison');
                grid on;
                legend('Classification', 'Segmentation', 'Location', 'best');
                hold off;
                
                % Save figure
                pngPath = fullfile(outputDir, [filename '.png']);
                saveas(fig, pngPath);
                obj.errorHandler.logInfo('SegmentationComparator', ...
                    sprintf('Visualization saved: %s', pngPath));
                
                pdfPath = fullfile(outputDir, [filename '.pdf']);
                saveas(fig, pdfPath);
                obj.errorHandler.logInfo('SegmentationComparator', ...
                    sprintf('Visualization saved: %s', pdfPath));
                
                close(fig);
                
            catch ME
                obj.errorHandler.logError('SegmentationComparator', ...
                    sprintf('Failed to generate visualization: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function saveComparison(obj, outputDir, filename)
            % Save comparison results to file
            % Inputs:
            %   outputDir - Directory to save results
            %   filename - Base filename (without extension)
            %
            % Requirements: 10.3
            
            if nargin < 3
                filename = 'segmentation_comparison';
            end
            
            obj.errorHandler.logInfo('SegmentationComparator', ...
                sprintf('Saving comparison results to: %s', outputDir));
            
            if ~isfolder(outputDir)
                mkdir(outputDir);
            end
            
            try
                % Create comparison table
                compTable = obj.createComparisonTable();
                
                % Calculate speedup factors
                speedupFactors = obj.calculateSpeedupFactors();
                
                % Save to MAT file
                matPath = fullfile(outputDir, [filename '.mat']);
                save(matPath, 'compTable', 'speedupFactors', '-v7.3');
                obj.errorHandler.logInfo('SegmentationComparator', ...
                    sprintf('Comparison saved to MAT file: %s', matPath));
                
                % Save to CSV
                csvPath = fullfile(outputDir, [filename '.csv']);
                writetable(compTable, csvPath);
                obj.errorHandler.logInfo('SegmentationComparator', ...
                    sprintf('Comparison table saved to CSV: %s', csvPath));
                
                % Save to text file
                txtPath = fullfile(outputDir, [filename '.txt']);
                obj.saveComparisonAsText(compTable, speedupFactors, txtPath);
                
                % Generate visualization
                obj.generateComparisonVisualization(outputDir, filename);
                
            catch ME
                obj.errorHandler.logError('SegmentationComparator', ...
                    sprintf('Failed to save comparison: %s', ME.message));
                rethrow(ME);
            end
        end
    end
    
    methods (Access = private)
        function saveComparisonAsText(obj, compTable, speedupFactors, filepath)
            % Save comparison results as text file
            % Inputs:
            %   compTable - Comparison table
            %   speedupFactors - Speedup factors struct
            %   filepath - Path to save text file
            
            try
                fid = fopen(filepath, 'w');
                if fid == -1
                    error('Cannot open file: %s', filepath);
                end
                
                % Write header
                fprintf(fid, '=================================================\n');
                fprintf(fid, 'CLASSIFICATION VS SEGMENTATION COMPARISON\n');
                fprintf(fid, '=================================================\n\n');
                fprintf(fid, 'Generated: %s\n\n', char(datetime('now')));
                
                % Write comparison table
                fprintf(fid, '=== Performance Comparison ===\n\n');
                fprintf(fid, '%-25s %-15s %15s %20s %20s\n', ...
                    'Model', 'Type', 'Time(ms)', 'Throughput(img/s)', 'Speedup');
                fprintf(fid, '%s\n', repmat('-', 1, 100));
                
                for i = 1:height(compTable)
                    fprintf(fid, '%-25s %-15s %15.2f %20.2f %20.2fx\n', ...
                        compTable.Model{i}, compTable.Type{i}, ...
                        compTable.InferenceTime_ms(i), ...
                        compTable.Throughput_imgs_per_sec(i), ...
                        compTable.SpeedupVsSegmentation(i));
                end
                fprintf(fid, '\n');
                
                % Write speedup factors
                fprintf(fid, '=== Speedup Factors (Classification vs Segmentation) ===\n\n');
                
                classModels = fieldnames(speedupFactors);
                for i = 1:length(classModels)
                    modelName = classModels{i};
                    factors = speedupFactors.(modelName);
                    
                    fprintf(fid, '%s:\n', modelName);
                    fprintf(fid, '  Classification time: %.2f ms\n', factors.classificationTime);
                    fprintf(fid, '  Segmentation avg time: %.2f ms\n', factors.segmentationAvgTime);
                    fprintf(fid, '  Speedup vs average: %.2fx\n', factors.vsAverage);
                    fprintf(fid, '  Speedup vs fastest: %.2fx\n', factors.vsMin);
                    fprintf(fid, '  Speedup vs slowest: %.2fx\n', factors.vsMax);
                    fprintf(fid, '\n');
                end
                
                % Write summary
                fprintf(fid, '=== Summary ===\n\n');
                
                % Find fastest classification model
                classIdx = strcmp(compTable.Type, 'Classification');
                if any(classIdx)
                    classTimes = compTable.InferenceTime_ms(classIdx);
                    classModels = compTable.Model(classIdx);
                    [minTime, minIdx] = min(classTimes);
                    
                    fprintf(fid, 'Fastest classification model: %s (%.2f ms)\n', ...
                        classModels{minIdx}, minTime);
                end
                
                % Find fastest segmentation model
                segIdx = strcmp(compTable.Type, 'Segmentation');
                if any(segIdx)
                    segTimes = compTable.InferenceTime_ms(segIdx);
                    segModels = compTable.Model(segIdx);
                    [minTime, minIdx] = min(segTimes);
                    
                    fprintf(fid, 'Fastest segmentation model: %s (%.2f ms)\n', ...
                        segModels{minIdx}, minTime);
                end
                
                % Real-time capability
                fprintf(fid, '\nReal-time capability (< 33.33 ms for 30 fps):\n');
                realtimeModels = compTable.Model(compTable.InferenceTime_ms < 33.33);
                if ~isempty(realtimeModels)
                    for i = 1:length(realtimeModels)
                        fprintf(fid, '  ✓ %s\n', realtimeModels{i});
                    end
                else
                    fprintf(fid, '  No models meet real-time requirement\n');
                end
                
                fclose(fid);
                
                obj.errorHandler.logInfo('SegmentationComparator', ...
                    sprintf('Text report saved: %s', filepath));
                
            catch ME
                if fid ~= -1
                    fclose(fid);
                end
                obj.errorHandler.logError('SegmentationComparator', ...
                    sprintf('Failed to save text report: %s', ME.message));
            end
        end
    end
end
