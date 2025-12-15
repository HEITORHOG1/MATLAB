% LabelGenerator.m - Convert segmentation masks to severity classification labels
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This class processes binary segmentation masks and generates categorical
% severity labels based on the percentage of corroded pixels. It supports
% batch processing and provides detailed logging of conversion statistics.
%
% Requirements addressed: 1.1, 1.2, 1.3, 1.4, 1.5, 7.1

classdef LabelGenerator < handle
    % LabelGenerator - Convert segmentation masks to severity classification labels
    %
    % This class processes binary segmentation masks and generates categorical
    % severity labels based on the percentage of corroded pixels. It supports
    % batch processing and provides detailed logging of conversion statistics.
    %
    % Requirements addressed: 1.1, 1.2, 1.3, 1.4, 1.5, 7.1
    
    properties (Access = private)
        thresholds      % [light_threshold, moderate_threshold] e.g., [10, 30]
        errorHandler    % ErrorHandler instance for logging
    end
    
    properties (Constant)
        CLASS_NONE_LIGHT = 0;
        CLASS_MODERATE = 1;
        CLASS_SEVERE = 2;
        
        CLASS_NAMES = {'None/Light', 'Moderate', 'Severe'};
    end
    
    methods
        function obj = LabelGenerator(thresholds, errorHandler)
            % Constructor
            % Inputs:
            %   thresholds - [light_threshold, moderate_threshold] (default: [10, 30])
            %   errorHandler - ErrorHandler instance (optional)
            
            if nargin < 1 || isempty(thresholds)
                thresholds = [10, 30];
            end
            
            if nargin < 2 || isempty(errorHandler)
                errorHandler = ErrorHandler.getInstance();
            end
            
            % Validate thresholds
            if length(thresholds) ~= 2 || thresholds(1) >= thresholds(2)
                error('LabelGenerator:InvalidThresholds', ...
                    'Thresholds must be [light, moderate] with light < moderate');
            end
            
            obj.thresholds = thresholds;
            obj.errorHandler = errorHandler;
            
            obj.errorHandler.logInfo('LabelGenerator', ...
                sprintf('Initialized with thresholds: [%.1f, %.1f]', ...
                thresholds(1), thresholds(2)));
        end
    end
    
    methods (Static)
        function percentage = computeCorrodedPercentage(mask)
            % Compute percentage of corroded pixels in binary mask
            % Input:
            %   mask - Binary mask (0=background, 255=corrosion or logical)
            % Output:
            %   percentage - Percentage of corroded pixels (0-100)
            %
            % Requirements: 1.1
            
            % Validate input
            if isempty(mask)
                error('LabelGenerator:EmptyMask', 'Mask cannot be empty');
            end
            
            % Convert to logical if needed
            if ~islogical(mask)
                % Handle different mask formats
                if max(mask(:)) > 1
                    % Assume 255 for foreground
                    mask = mask > 127;
                else
                    % Already in 0-1 range
                    mask = mask > 0.5;
                end
            end
            
            % Calculate percentage
            corrodedPixels = sum(mask(:));
            totalPixels = numel(mask);
            
            if totalPixels == 0
                error('LabelGenerator:InvalidMask', 'Mask has zero pixels');
            end
            
            percentage = (corrodedPixels / totalPixels) * 100;
        end
        
        function severityClass = assignSeverityClass(percentage, thresholds)
            % Assign severity class based on corroded percentage
            % Inputs:
            %   percentage - Corroded percentage (0-100)
            %   thresholds - [light_threshold, moderate_threshold]
            % Output:
            %   severityClass - Integer class (0=None/Light, 1=Moderate, 2=Severe)
            %
            % Requirements: 1.2, 1.3, 1.4
            
            % Validate inputs
            if percentage < 0 || percentage > 100
                error('LabelGenerator:InvalidPercentage', ...
                    'Percentage must be between 0 and 100');
            end
            
            if length(thresholds) ~= 2 || thresholds(1) >= thresholds(2)
                error('LabelGenerator:InvalidThresholds', ...
                    'Thresholds must be [light, moderate] with light < moderate');
            end
            
            % Assign class based on thresholds
            if percentage < thresholds(1)
                severityClass = LabelGenerator.CLASS_NONE_LIGHT;
            elseif percentage < thresholds(2)
                severityClass = LabelGenerator.CLASS_MODERATE;
            else
                severityClass = LabelGenerator.CLASS_SEVERE;
            end
        end
    end
    
    methods
        function [labels, stats] = generateLabelsFromMasks(obj, maskDir, outputCSV)
            % Batch process all masks and generate labels CSV
            % Inputs:
            %   maskDir - Directory containing binary mask images
            %   outputCSV - Path to output CSV file
            % Outputs:
            %   labels - Table with columns: filename, corroded_percentage, severity_class
            %   stats - Statistics struct with conversion summary
            %
            % Requirements: 1.5, 7.1
            
            obj.errorHandler.logInfo('LabelGenerator', ...
                sprintf('Starting label generation from: %s', maskDir));
            
            % Validate mask directory
            if ~exist(maskDir, 'dir')
                error('LabelGenerator:DirectoryNotFound', ...
                    'Mask directory not found: %s', maskDir);
            end
            
            % Find all mask files
            maskFiles = [dir(fullfile(maskDir, '*.png')); ...
                        dir(fullfile(maskDir, '*.jpg')); ...
                        dir(fullfile(maskDir, '*.bmp'))];
            
            if isempty(maskFiles)
                error('LabelGenerator:NoMasks', ...
                    'No mask files found in directory: %s', maskDir);
            end
            
            obj.errorHandler.logInfo('LabelGenerator', ...
                sprintf('Found %d mask files', length(maskFiles)));
            
            % Initialize results
            numFiles = length(maskFiles);
            filenames = cell(numFiles, 1);
            percentages = zeros(numFiles, 1);
            classes = zeros(numFiles, 1);
            
            % Initialize statistics
            stats = struct();
            stats.totalFiles = numFiles;
            stats.successCount = 0;
            stats.failureCount = 0;
            stats.failedFiles = {};
            stats.classDistribution = zeros(1, 3);
            
            % Process each mask
            for i = 1:numFiles
                filename = maskFiles(i).name;
                filepath = fullfile(maskFiles(i).folder, filename);
                
                try
                    % Read mask
                    mask = imread(filepath);
                    
                    % Convert to grayscale if RGB
                    if size(mask, 3) == 3
                        mask = rgb2gray(mask);
                    end
                    
                    % Compute corroded percentage
                    percentage = obj.computeCorrodedPercentage(mask);
                    
                    % Assign severity class
                    severityClass = obj.assignSeverityClass(percentage, obj.thresholds);
                    
                    % Store results
                    filenames{i} = filename;
                    percentages(i) = percentage;
                    classes(i) = severityClass;
                    
                    % Update statistics
                    stats.successCount = stats.successCount + 1;
                    stats.classDistribution(severityClass + 1) = ...
                        stats.classDistribution(severityClass + 1) + 1;
                    
                    % Log progress every 10 files
                    if mod(i, 10) == 0
                        obj.errorHandler.logInfo('LabelGenerator', ...
                            sprintf('Processed %d/%d files', i, numFiles));
                    end
                    
                catch ME
                    obj.errorHandler.logError('LabelGenerator', ...
                        sprintf('Failed to process %s: %s', filename, ME.message));
                    
                    stats.failureCount = stats.failureCount + 1;
                    stats.failedFiles{end+1} = filename;
                    
                    % Store NaN for failed files
                    filenames{i} = filename;
                    percentages(i) = NaN;
                    classes(i) = -1;
                end
            end
            
            % Remove failed entries
            validIdx = classes >= 0;
            filenames = filenames(validIdx);
            percentages = percentages(validIdx);
            classes = classes(validIdx);
            
            % Create results table
            labels = table(filenames, percentages, classes, ...
                'VariableNames', {'filename', 'corroded_percentage', 'severity_class'});
            
            % Save to CSV
            if nargin >= 3 && ~isempty(outputCSV)
                try
                    % Create output directory if needed
                    [outputDir, ~, ~] = fileparts(outputCSV);
                    if ~isempty(outputDir) && ~exist(outputDir, 'dir')
                        mkdir(outputDir);
                    end
                    
                    writetable(labels, outputCSV);
                    obj.errorHandler.logInfo('LabelGenerator', ...
                        sprintf('Labels saved to: %s', outputCSV));
                catch ME
                    obj.errorHandler.logError('LabelGenerator', ...
                        sprintf('Failed to save CSV: %s', ME.message));
                end
            end
            
            % Compute additional statistics
            stats.percentageRange = [min(percentages), max(percentages)];
            stats.percentageMean = mean(percentages);
            stats.percentageStd = std(percentages);
            
            % Log summary statistics
            obj.logSummaryStatistics(stats);
        end
        
        function logSummaryStatistics(obj, stats)
            % Log detailed summary statistics
            % Input: stats - Statistics struct from generateLabelsFromMasks
            
            obj.errorHandler.logInfo('LabelGenerator', '=== Label Generation Summary ===');
            obj.errorHandler.logInfo('LabelGenerator', ...
                sprintf('Total files: %d', stats.totalFiles));
            obj.errorHandler.logInfo('LabelGenerator', ...
                sprintf('Successfully processed: %d', stats.successCount));
            obj.errorHandler.logInfo('LabelGenerator', ...
                sprintf('Failed: %d', stats.failureCount));
            
            if stats.failureCount > 0
                obj.errorHandler.logWarning('LabelGenerator', ...
                    sprintf('Failed files: %s', strjoin(stats.failedFiles, ', ')));
            end
            
            obj.errorHandler.logInfo('LabelGenerator', '--- Class Distribution ---');
            for i = 1:3
                className = obj.CLASS_NAMES{i};
                count = stats.classDistribution(i);
                percentage = (count / stats.successCount) * 100;
                obj.errorHandler.logInfo('LabelGenerator', ...
                    sprintf('Class %d (%s): %d samples (%.1f%%)', ...
                    i-1, className, count, percentage));
            end
            
            obj.errorHandler.logInfo('LabelGenerator', '--- Corroded Percentage Statistics ---');
            obj.errorHandler.logInfo('LabelGenerator', ...
                sprintf('Range: [%.2f%%, %.2f%%]', ...
                stats.percentageRange(1), stats.percentageRange(2)));
            obj.errorHandler.logInfo('LabelGenerator', ...
                sprintf('Mean: %.2f%% (±%.2f%%)', ...
                stats.percentageMean, stats.percentageStd));
            
            % Check for class imbalance
            maxCount = max(stats.classDistribution);
            minCount = min(stats.classDistribution);
            if minCount > 0
                imbalanceRatio = maxCount / minCount;
                if imbalanceRatio > 3
                    obj.errorHandler.logWarning('LabelGenerator', ...
                        sprintf('Class imbalance detected: ratio %.1f:1', imbalanceRatio));
                end
            end
            
            obj.errorHandler.logInfo('LabelGenerator', '=== End Summary ===');
        end
    end
end
