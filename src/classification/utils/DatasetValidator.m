% DatasetValidator.m - Validate dataset integrity and generate reports
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This class provides utilities for validating the classification dataset:
% - Validate image file existence and readability
% - Validate image dimensions and channels (RGB)
% - Check for class imbalance and log warnings
% - Generate dataset statistics report
%
% Requirements addressed: 2.5

classdef DatasetValidator < handle
    % DatasetValidator - Validate dataset integrity and generate reports
    %
    % This class provides utilities for validating the classification dataset:
    % - Validate image file existence and readability
    % - Validate image dimensions and channels (RGB)
    % - Check for class imbalance and log warnings
    % - Generate dataset statistics report
    %
    % Requirements addressed: 2.5
    
    properties (Access = private)
        errorHandler        % ErrorHandler instance for logging
    end
    
    properties (Constant)
        EXPECTED_CHANNELS = 3;  % RGB images
        MIN_IMAGE_SIZE = 50;    % Minimum dimension in pixels
        IMBALANCE_THRESHOLD = 3.0;  % Ratio threshold for imbalance warning
    end
    
    methods
        function obj = DatasetValidator(errorHandler)
            % Constructor
            % Input:
            %   errorHandler - ErrorHandler instance (optional)
            
            if nargin < 1 || isempty(errorHandler)
                obj.errorHandler = ErrorHandler.getInstance();
            else
                obj.errorHandler = errorHandler;
            end
        end
        
        function [isValid, report] = validateDataset(obj, imageDir, labelCSV)
            % Validate complete dataset
            % Inputs:
            %   imageDir - Directory containing images
            %   labelCSV - Path to CSV file with labels
            % Outputs:
            %   isValid - Boolean indicating if dataset is valid
            %   report - Struct with validation results
            %
            % Requirements: 2.5
            
            obj.errorHandler.logInfo('DatasetValidator', ...
                'Starting dataset validation...');
            
            % Initialize report
            report = struct();
            report.timestamp = datetime('now');
            report.imageDir = imageDir;
            report.labelCSV = labelCSV;
            report.errors = {};
            report.warnings = {};
            
            % Validate directory exists
            if ~exist(imageDir, 'dir')
                report.errors{end+1} = sprintf('Image directory not found: %s', imageDir);
                isValid = false;
                return;
            end
            
            % Validate CSV exists
            if ~exist(labelCSV, 'file')
                report.errors{end+1} = sprintf('Label CSV not found: %s', labelCSV);
                isValid = false;
                return;
            end
            
            % Load labels
            try
                labelTable = readtable(labelCSV);
            catch ME
                report.errors{end+1} = sprintf('Failed to read CSV: %s', ME.message);
                isValid = false;
                return;
            end
            
            % Validate CSV format
            requiredCols = {'filename', 'corroded_percentage', 'severity_class'};
            if ~all(ismember(requiredCols, labelTable.Properties.VariableNames))
                report.errors{end+1} = 'CSV missing required columns';
                isValid = false;
                return;
            end
            
            % Extract data
            filenames = labelTable.filename;
            classes = labelTable.severity_class;
            
            report.totalLabels = length(filenames);
            
            % Validate each image
            obj.errorHandler.logInfo('DatasetValidator', ...
                sprintf('Validating %d images...', length(filenames)));
            
            validCount = 0;
            missingFiles = {};
            unreadableFiles = {};
            invalidDimensions = {};
            invalidChannels = {};
            
            for i = 1:length(filenames)
                % Get filename
                if iscell(filenames)
                    filename = filenames{i};
                else
                    filename = char(filenames(i));
                end
                
                imagePath = fullfile(imageDir, filename);
                
                % Check file existence
                if ~exist(imagePath, 'file')
                    missingFiles{end+1} = filename; %#ok<AGROW>
                    continue;
                end
                
                % Try to read image
                try
                    img = imread(imagePath);
                catch ME
                    unreadableFiles{end+1} = sprintf('%s (%s)', filename, ME.message); %#ok<AGROW>
                    continue;
                end
                
                % Validate dimensions
                [h, w, c] = size(img);
                
                if h < obj.MIN_IMAGE_SIZE || w < obj.MIN_IMAGE_SIZE
                    invalidDimensions{end+1} = sprintf('%s (%dx%d)', filename, h, w); %#ok<AGROW>
                end
                
                % Validate channels (RGB)
                if c ~= obj.EXPECTED_CHANNELS
                    invalidChannels{end+1} = sprintf('%s (%d channels)', filename, c); %#ok<AGROW>
                end
                
                % Count as valid if no issues
                if h >= obj.MIN_IMAGE_SIZE && w >= obj.MIN_IMAGE_SIZE && c == obj.EXPECTED_CHANNELS
                    validCount = validCount + 1;
                end
            end
            
            % Store validation results
            report.validImages = validCount;
            report.missingFiles = missingFiles;
            report.unreadableFiles = unreadableFiles;
            report.invalidDimensions = invalidDimensions;
            report.invalidChannels = invalidChannels;
            
            % Log issues
            if ~isempty(missingFiles)
                report.warnings{end+1} = sprintf('%d missing files', length(missingFiles));
                obj.errorHandler.logWarning('DatasetValidator', ...
                    sprintf('%d images not found in directory', length(missingFiles)));
            end
            
            if ~isempty(unreadableFiles)
                report.errors{end+1} = sprintf('%d unreadable files', length(unreadableFiles));
                obj.errorHandler.logError('DatasetValidator', ...
                    sprintf('%d images could not be read', length(unreadableFiles)));
            end
            
            if ~isempty(invalidDimensions)
                report.warnings{end+1} = sprintf('%d images with invalid dimensions', length(invalidDimensions));
                obj.errorHandler.logWarning('DatasetValidator', ...
                    sprintf('%d images smaller than %dx%d', ...
                    length(invalidDimensions), obj.MIN_IMAGE_SIZE, obj.MIN_IMAGE_SIZE));
            end
            
            if ~isempty(invalidChannels)
                report.errors{end+1} = sprintf('%d images with invalid channels', length(invalidChannels));
                obj.errorHandler.logError('DatasetValidator', ...
                    sprintf('%d images do not have %d channels (RGB)', ...
                    length(invalidChannels), obj.EXPECTED_CHANNELS));
            end
            
            % Check class imbalance
            obj.errorHandler.logInfo('DatasetValidator', 'Checking class balance...');
            
            uniqueClasses = unique(classes);
            classCounts = zeros(1, length(uniqueClasses));
            
            for i = 1:length(uniqueClasses)
                classCounts(i) = sum(classes == uniqueClasses(i));
            end
            
            maxCount = max(classCounts);
            minCount = min(classCounts);
            imbalanceRatio = maxCount / minCount;
            
            report.classDistribution = classCounts;
            report.uniqueClasses = uniqueClasses;
            report.imbalanceRatio = imbalanceRatio;
            
            if imbalanceRatio > obj.IMBALANCE_THRESHOLD
                report.warnings{end+1} = sprintf('Class imbalance detected: %.2f:1', imbalanceRatio);
                obj.errorHandler.logWarning('DatasetValidator', ...
                    sprintf('Dataset is imbalanced (ratio %.2f:1 > %.1f:1)', ...
                    imbalanceRatio, obj.IMBALANCE_THRESHOLD));
                obj.errorHandler.logWarning('DatasetValidator', ...
                    'Consider using class weights or resampling techniques');
            else
                obj.errorHandler.logInfo('DatasetValidator', ...
                    sprintf('Dataset is reasonably balanced (ratio %.2f:1)', imbalanceRatio));
            end
            
            % Determine overall validity
            isValid = isempty(report.errors) && validCount > 0;
            
            % Log summary
            obj.errorHandler.logInfo('DatasetValidator', ...
                sprintf('Validation complete: %d/%d images valid', validCount, report.totalLabels));
            
            if isValid
                obj.errorHandler.logInfo('DatasetValidator', 'Dataset validation: PASSED');
            else
                obj.errorHandler.logError('DatasetValidator', 'Dataset validation: FAILED');
            end
        end
        
        function generateReport(obj, report, outputFile)
            % Generate detailed validation report
            % Inputs:
            %   report - Validation report struct from validateDataset
            %   outputFile - Path to save report (optional)
            %
            % Requirements: 2.5
            
            obj.errorHandler.logInfo('DatasetValidator', 'Generating validation report...');
            
            % Create report text
            reportText = {};
            reportText{end+1} = '=== Dataset Validation Report ===';
            reportText{end+1} = sprintf('Generated: %s', datestr(report.timestamp));
            reportText{end+1} = '';
            reportText{end+1} = '--- Configuration ---';
            reportText{end+1} = sprintf('Image Directory: %s', report.imageDir);
            reportText{end+1} = sprintf('Label CSV: %s', report.labelCSV);
            reportText{end+1} = '';
            reportText{end+1} = '--- Validation Results ---';
            reportText{end+1} = sprintf('Total Labels: %d', report.totalLabels);
            reportText{end+1} = sprintf('Valid Images: %d', report.validImages);
            reportText{end+1} = sprintf('Missing Files: %d', length(report.missingFiles));
            reportText{end+1} = sprintf('Unreadable Files: %d', length(report.unreadableFiles));
            reportText{end+1} = sprintf('Invalid Dimensions: %d', length(report.invalidDimensions));
            reportText{end+1} = sprintf('Invalid Channels: %d', length(report.invalidChannels));
            reportText{end+1} = '';
            
            % Class distribution
            reportText{end+1} = '--- Class Distribution ---';
            classNames = {'None/Light', 'Moderate', 'Severe'};
            for i = 1:length(report.uniqueClasses)
                classLabel = report.uniqueClasses(i);
                count = report.classDistribution(i);
                percentage = (count / report.totalLabels) * 100;
                
                if classLabel >= 0 && classLabel < length(classNames)
                    className = classNames{classLabel + 1};
                else
                    className = sprintf('Class_%d', classLabel);
                end
                
                reportText{end+1} = sprintf('Class %d (%s): %d samples (%.1f%%)', ...
                    classLabel, className, count, percentage);
            end
            reportText{end+1} = sprintf('Imbalance Ratio: %.2f:1', report.imbalanceRatio);
            reportText{end+1} = '';
            
            % Errors
            if ~isempty(report.errors)
                reportText{end+1} = '--- ERRORS ---';
                for i = 1:length(report.errors)
                    reportText{end+1} = sprintf('  - %s', report.errors{i});
                end
                reportText{end+1} = '';
            end
            
            % Warnings
            if ~isempty(report.warnings)
                reportText{end+1} = '--- WARNINGS ---';
                for i = 1:length(report.warnings)
                    reportText{end+1} = sprintf('  - %s', report.warnings{i});
                end
                reportText{end+1} = '';
            end
            
            % Detailed issues
            if ~isempty(report.missingFiles)
                reportText{end+1} = '--- Missing Files (first 10) ---';
                numToShow = min(10, length(report.missingFiles));
                for i = 1:numToShow
                    reportText{end+1} = sprintf('  - %s', report.missingFiles{i});
                end
                if length(report.missingFiles) > 10
                    reportText{end+1} = sprintf('  ... and %d more', length(report.missingFiles) - 10);
                end
                reportText{end+1} = '';
            end
            
            if ~isempty(report.unreadableFiles)
                reportText{end+1} = '--- Unreadable Files ---';
                for i = 1:length(report.unreadableFiles)
                    reportText{end+1} = sprintf('  - %s', report.unreadableFiles{i});
                end
                reportText{end+1} = '';
            end
            
            if ~isempty(report.invalidDimensions)
                reportText{end+1} = '--- Invalid Dimensions (first 10) ---';
                numToShow = min(10, length(report.invalidDimensions));
                for i = 1:numToShow
                    reportText{end+1} = sprintf('  - %s', report.invalidDimensions{i});
                end
                if length(report.invalidDimensions) > 10
                    reportText{end+1} = sprintf('  ... and %d more', length(report.invalidDimensions) - 10);
                end
                reportText{end+1} = '';
            end
            
            if ~isempty(report.invalidChannels)
                reportText{end+1} = '--- Invalid Channels ---';
                for i = 1:length(report.invalidChannels)
                    reportText{end+1} = sprintf('  - %s', report.invalidChannels{i});
                end
                reportText{end+1} = '';
            end
            
            % Overall status
            reportText{end+1} = '--- Overall Status ---';
            if isempty(report.errors) && report.validImages > 0
                reportText{end+1} = 'Status: PASSED';
                reportText{end+1} = 'Dataset is valid and ready for training';
            else
                reportText{end+1} = 'Status: FAILED';
                reportText{end+1} = 'Dataset has critical issues that must be resolved';
            end
            reportText{end+1} = '';
            reportText{end+1} = '=== End Report ===';
            
            % Join lines
            reportStr = strjoin(reportText, '\n');
            
            % Display to console
            fprintf('\n%s\n', reportStr);
            
            % Save to file if specified
            if nargin >= 3 && ~isempty(outputFile)
                try
                    % Create directory if needed
                    [outputDir, ~, ~] = fileparts(outputFile);
                    if ~isempty(outputDir) && ~exist(outputDir, 'dir')
                        mkdir(outputDir);
                    end
                    
                    % Write file
                    fid = fopen(outputFile, 'w');
                    fprintf(fid, '%s', reportStr);
                    fclose(fid);
                    
                    obj.errorHandler.logInfo('DatasetValidator', ...
                        sprintf('Report saved to: %s', outputFile));
                catch ME
                    obj.errorHandler.logError('DatasetValidator', ...
                        sprintf('Failed to save report: %s', ME.message));
                end
            end
        end
    end
end
