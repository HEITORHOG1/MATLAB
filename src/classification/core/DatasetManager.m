% DatasetManager.m - Load images, apply labels, split data, and provide augmentation
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This class manages the classification dataset by loading images with their
% corresponding labels, performing stratified train/val/test splits, computing
% dataset statistics, and configuring data augmentation pipelines.
%
% Requirements addressed: 2.1, 2.2, 2.3, 2.4, 7.3

classdef DatasetManager < handle
    % DatasetManager - Load images, apply labels, split data, and provide augmentation
    %
    % This class manages the classification dataset by loading images with their
    % corresponding labels, performing stratified train/val/test splits, computing
    % dataset statistics, and configuring data augmentation pipelines.
    %
    % Requirements addressed: 2.1, 2.2, 2.3, 2.4, 7.3
    
    properties (Access = private)
        imageDir            % Directory containing RGB images
        labelCSV            % Path to CSV file with labels
        splitRatios         % [train, val, test] e.g., [0.7, 0.15, 0.15]
        augmentationConfig  % Configuration struct for data augmentation
        errorHandler        % ErrorHandler instance for logging
        
        % Loaded data
        allImages           % Cell array of image filenames
        allLabels           % Array of severity class labels
        allPercentages      % Array of corroded percentages
    end
    
    properties (Constant)
        DEFAULT_SPLIT_RATIOS = [0.7, 0.15, 0.15];
        DEFAULT_INPUT_SIZE = [224, 224];
        
        % Default augmentation settings
        DEFAULT_AUGMENTATION = struct(...
            'enabled', true, ...
            'horizontalFlip', true, ...
            'verticalFlip', true, ...
            'rotationRange', [-15, 15], ...
            'brightnessRange', [0.8, 1.2], ...
            'contrastRange', [0.8, 1.2] ...
        );
    end
    
    methods
        function obj = DatasetManager(imageDir, labelCSV, config)
            % Constructor
            % Inputs:
            %   imageDir - Directory containing RGB images
            %   labelCSV - Path to CSV file with labels (columns: filename, corroded_percentage, severity_class)
            %   config - Configuration struct (optional) with fields:
            %            - splitRatios: [train, val, test] ratios
            %            - augmentation: augmentation configuration struct
            %            - errorHandler: ErrorHandler instance
            
            % Validate inputs
            if nargin < 2
                error('DatasetManager:InvalidInput', ...
                    'imageDir and labelCSV are required');
            end
            
            if ~exist(imageDir, 'dir')
                error('DatasetManager:DirectoryNotFound', ...
                    'Image directory not found: %s', imageDir);
            end
            
            if ~exist(labelCSV, 'file')
                error('DatasetManager:FileNotFound', ...
                    'Label CSV file not found: %s', labelCSV);
            end
            
            % Initialize properties
            obj.imageDir = imageDir;
            obj.labelCSV = labelCSV;
            
            % Set configuration from config struct or use defaults
            if nargin >= 3 && isstruct(config)
                if isfield(config, 'splitRatios')
                    obj.splitRatios = config.splitRatios;
                else
                    obj.splitRatios = obj.DEFAULT_SPLIT_RATIOS;
                end
                
                if isfield(config, 'augmentation')
                    obj.augmentationConfig = config.augmentation;
                else
                    obj.augmentationConfig = obj.DEFAULT_AUGMENTATION;
                end
                
                if isfield(config, 'errorHandler')
                    obj.errorHandler = config.errorHandler;
                else
                    obj.errorHandler = ErrorHandler.getInstance();
                end
            else
                obj.splitRatios = obj.DEFAULT_SPLIT_RATIOS;
                obj.augmentationConfig = obj.DEFAULT_AUGMENTATION;
                obj.errorHandler = ErrorHandler.getInstance();
            end
            
            % Validate split ratios
            if length(obj.splitRatios) ~= 3 || abs(sum(obj.splitRatios) - 1.0) > 1e-6
                error('DatasetManager:InvalidSplitRatios', ...
                    'Split ratios must be [train, val, test] and sum to 1.0');
            end
            
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Initialized with imageDir=%s, labelCSV=%s', imageDir, labelCSV));
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Split ratios: [%.2f, %.2f, %.2f]', ...
                obj.splitRatios(1), obj.splitRatios(2), obj.splitRatios(3)));
            
            % Load data
            obj.loadData();
        end
        
        function loadData(obj)
            % Load images and labels from CSV
            % Validates that all images have corresponding labels
            % Requirements: 2.1, 2.4
            
            obj.errorHandler.logInfo('DatasetManager', 'Loading labels from CSV...');
            
            % Read CSV file
            try
                labelTable = readtable(obj.labelCSV);
            catch ME
                error('DatasetManager:CSVReadError', ...
                    'Failed to read CSV file: %s', ME.message);
            end
            
            % Validate CSV columns
            requiredCols = {'filename', 'corroded_percentage', 'severity_class'};
            if ~all(ismember(requiredCols, labelTable.Properties.VariableNames))
                error('DatasetManager:InvalidCSV', ...
                    'CSV must contain columns: filename, corroded_percentage, severity_class');
            end
            
            % Extract data
            filenames = labelTable.filename;
            percentages = labelTable.corroded_percentage;
            classes = labelTable.severity_class;
            
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Found %d labels in CSV', length(filenames)));
            
            % Validate that all images exist
            validIdx = true(length(filenames), 1);
            missingFiles = {};
            
            for i = 1:length(filenames)
                % Handle both cell array and string array
                if iscell(filenames)
                    filename = filenames{i};
                else
                    filename = char(filenames(i));
                end
                
                imagePath = fullfile(obj.imageDir, filename);
                
                if ~exist(imagePath, 'file')
                    validIdx(i) = false;
                    missingFiles{end+1} = filename; %#ok<AGROW>
                    obj.errorHandler.logWarning('DatasetManager', ...
                        sprintf('Image not found: %s', filename));
                end
            end
            
            % Report missing files
            if ~isempty(missingFiles)
                obj.errorHandler.logWarning('DatasetManager', ...
                    sprintf('%d images missing from directory', length(missingFiles)));
                obj.errorHandler.logWarning('DatasetManager', ...
                    sprintf('Missing files: %s', strjoin(missingFiles, ', ')));
            end
            
            % Filter to valid entries only
            obj.allImages = filenames(validIdx);
            obj.allLabels = classes(validIdx);
            obj.allPercentages = percentages(validIdx);
            
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Loaded %d valid image-label pairs', length(obj.allImages)));
            
            % Validate we have data
            if isempty(obj.allImages)
                error('DatasetManager:NoValidData', ...
                    'No valid image-label pairs found');
            end
            
            % Log class distribution
            uniqueClasses = unique(obj.allLabels);
            obj.errorHandler.logInfo('DatasetManager', '--- Overall Class Distribution ---');
            for i = 1:length(uniqueClasses)
                classLabel = uniqueClasses(i);
                count = sum(obj.allLabels == classLabel);
                percentage = (count / length(obj.allLabels)) * 100;
                obj.errorHandler.logInfo('DatasetManager', ...
                    sprintf('Class %d: %d samples (%.1f%%)', classLabel, count, percentage));
            end
        end
        
        function [trainDS, valDS, testDS] = prepareDatasets(obj, inputSize)
            % Create stratified train/val/test splits
            % Input:
            %   inputSize - [height, width] for image resizing (default: [224, 224])
            % Outputs:
            %   trainDS - Training imageDatastore with labels
            %   valDS - Validation imageDatastore with labels
            %   testDS - Test imageDatastore with labels
            %
            % Requirements: 2.2, 2.3
            
            if nargin < 2 || isempty(inputSize)
                inputSize = obj.DEFAULT_INPUT_SIZE;
            end
            
            obj.errorHandler.logInfo('DatasetManager', ...
                'Creating stratified train/val/test splits...');
            
            % Get unique classes
            uniqueClasses = unique(obj.allLabels);
            numClasses = length(uniqueClasses);
            
            % Initialize split indices
            trainIdx = [];
            valIdx = [];
            testIdx = [];
            
            % Perform stratified split for each class
            for i = 1:numClasses
                classLabel = uniqueClasses(i);
                classIndices = find(obj.allLabels == classLabel);
                numSamples = length(classIndices);
                
                % Calculate split sizes
                numTrain = round(numSamples * obj.splitRatios(1));
                numVal = round(numSamples * obj.splitRatios(2));
                numTest = numSamples - numTrain - numVal; % Remaining goes to test
                
                % Randomly shuffle indices for this class
                rng(42); % Set seed for reproducibility
                shuffledIndices = classIndices(randperm(numSamples));
                
                % Split indices
                trainIdx = [trainIdx; shuffledIndices(1:numTrain)]; %#ok<AGROW>
                valIdx = [valIdx; shuffledIndices(numTrain+1:numTrain+numVal)]; %#ok<AGROW>
                testIdx = [testIdx; shuffledIndices(numTrain+numVal+1:end)]; %#ok<AGROW>
                
                obj.errorHandler.logInfo('DatasetManager', ...
                    sprintf('Class %d: %d train, %d val, %d test', ...
                    classLabel, numTrain, numVal, numTest));
            end
            
            % Create image datastores for each split
            trainDS = obj.createImageDatastore(trainIdx, inputSize);
            valDS = obj.createImageDatastore(valIdx, inputSize);
            testDS = obj.createImageDatastore(testIdx, inputSize);
            
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Dataset splits created: %d train, %d val, %d test', ...
                length(trainIdx), length(valIdx), length(testIdx)));
            
            % Verify stratification
            obj.verifyStratification(trainIdx, valIdx, testIdx);
        end
        
        function stats = getDatasetStatistics(obj)
            % Compute class distribution and dataset statistics
            % Output:
            %   stats - Struct with dataset statistics
            %
            % Requirements: 2.5
            
            obj.errorHandler.logInfo('DatasetManager', 'Computing dataset statistics...');
            
            stats = struct();
            stats.totalSamples = length(obj.allLabels);
            stats.uniqueClasses = unique(obj.allLabels);
            stats.numClasses = length(stats.uniqueClasses);
            
            % Class distribution
            stats.classDistribution = zeros(1, stats.numClasses);
            stats.classPercentages = zeros(1, stats.numClasses);
            stats.classNames = cell(1, stats.numClasses);
            
            classNameMap = {'None/Light', 'Moderate', 'Severe'};
            
            for i = 1:stats.numClasses
                classLabel = stats.uniqueClasses(i);
                count = sum(obj.allLabels == classLabel);
                stats.classDistribution(i) = count;
                stats.classPercentages(i) = (count / stats.totalSamples) * 100;
                
                % Assign class name
                if classLabel >= 0 && classLabel < length(classNameMap)
                    stats.classNames{i} = classNameMap{classLabel + 1};
                else
                    stats.classNames{i} = sprintf('Class_%d', classLabel);
                end
            end
            
            % Corroded percentage statistics
            stats.percentageRange = [min(obj.allPercentages), max(obj.allPercentages)];
            stats.percentageMean = mean(obj.allPercentages);
            stats.percentageStd = std(obj.allPercentages);
            stats.percentageMedian = median(obj.allPercentages);
            
            % Class imbalance analysis
            maxCount = max(stats.classDistribution);
            minCount = min(stats.classDistribution);
            stats.imbalanceRatio = maxCount / minCount;
            stats.isImbalanced = stats.imbalanceRatio > 3.0;
            
            % Log statistics
            obj.logStatistics(stats);
            
            obj.errorHandler.logInfo('DatasetManager', 'Dataset statistics computed');
        end
        
        function augDS = applyAugmentation(obj, datastore, inputSize)
            % Configure data augmentation for training
            % Inputs:
            %   datastore - imageDatastore to augment
            %   inputSize - [height, width] for output images (optional)
            % Output:
            %   augDS - augmentedImageDatastore with configured augmentation
            %
            % Augmentation includes:
            %   - Random horizontal/vertical flips
            %   - Random rotation (-15° to +15°)
            %   - Random brightness adjustment (±20%)
            %   - Random contrast adjustment (±20%)
            %
            % Requirements: 4.2, 7.3
            
            if ~obj.augmentationConfig.enabled
                obj.errorHandler.logInfo('DatasetManager', ...
                    'Augmentation disabled, returning original datastore');
                augDS = datastore;
                return;
            end
            
            % Get input size
            if nargin < 3 || isempty(inputSize)
                if isprop(datastore, 'ReadSize')
                    inputSize = datastore.ReadSize;
                else
                    inputSize = obj.DEFAULT_INPUT_SIZE;
                end
            end
            
            obj.errorHandler.logInfo('DatasetManager', ...
                'Applying data augmentation...');
            
            % Create image augmenter for geometric transformations
            augmenter = imageDataAugmenter(...
                'RandXReflection', obj.augmentationConfig.horizontalFlip, ...
                'RandYReflection', obj.augmentationConfig.verticalFlip, ...
                'RandRotation', obj.augmentationConfig.rotationRange, ...
                'RandXScale', [1.0, 1.0], ...
                'RandYScale', [1.0, 1.0]);
            
            % Create augmented datastore with geometric transformations
            augDS = augmentedImageDatastore(inputSize, datastore, ...
                'DataAugmentation', augmenter, ...
                'OutputSizeMode', 'centercrop');
            
            % Add brightness and contrast augmentation via preprocessing
            % Store config for use in preprocessing function
            brightnessRange = obj.augmentationConfig.brightnessRange;
            contrastRange = obj.augmentationConfig.contrastRange;
            
            % Wrap the augmented datastore with brightness/contrast preprocessing
            augDS = transform(augDS, @(data) obj.applyColorAugmentation(data, brightnessRange, contrastRange));
            
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Augmentation applied: HFlip=%d, VFlip=%d, Rotation=[%.1f, %.1f]', ...
                obj.augmentationConfig.horizontalFlip, ...
                obj.augmentationConfig.verticalFlip, ...
                obj.augmentationConfig.rotationRange(1), ...
                obj.augmentationConfig.rotationRange(2)));
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Color augmentation: Brightness=[%.2f, %.2f], Contrast=[%.2f, %.2f]', ...
                brightnessRange(1), brightnessRange(2), ...
                contrastRange(1), contrastRange(2)));
        end
        
        function data = applyColorAugmentation(obj, data, brightnessRange, contrastRange)
            % Apply random brightness and contrast adjustments
            % Inputs:
            %   data - Cell array with {image, label} from augmentedImageDatastore
            %   brightnessRange - [min, max] brightness multiplier (e.g., [0.8, 1.2])
            %   contrastRange - [min, max] contrast multiplier (e.g., [0.8, 1.2])
            % Output:
            %   data - Cell array with augmented {image, label}
            %
            % Requirements: 4.2
            
            % Extract image and label
            img = data{1};
            label = data{2};
            
            % Convert to double for processing
            img = im2double(img);
            
            % Apply random brightness adjustment (±20%)
            brightnessFactor = brightnessRange(1) + (brightnessRange(2) - brightnessRange(1)) * rand();
            img = img * brightnessFactor;
            
            % Apply random contrast adjustment (±20%)
            contrastFactor = contrastRange(1) + (contrastRange(2) - contrastRange(1)) * rand();
            % Contrast adjustment: (img - mean) * factor + mean
            imgMean = mean(img(:));
            img = (img - imgMean) * contrastFactor + imgMean;
            
            % Clip values to valid range [0, 1]
            img = max(0, min(1, img));
            
            % Convert back to original data type (uint8)
            img = im2uint8(img);
            
            % Return augmented data
            data = {img, label};
        end
    end
    
    methods (Access = private)
        function imds = createImageDatastore(obj, indices, inputSize)
            % Create imageDatastore from indices
            % Inputs:
            %   indices - Array of indices into obj.allImages
            %   inputSize - [height, width] for resizing
            % Output:
            %   imds - imageDatastore with labels
            
            % Get filenames and labels for these indices
            if iscell(obj.allImages)
                filenames = obj.allImages(indices);
            else
                filenames = cellstr(obj.allImages(indices));
            end
            labels = obj.allLabels(indices);
            
            % Create full paths
            fullPaths = cellfun(@(x) fullfile(obj.imageDir, x), filenames, ...
                'UniformOutput', false);
            
            % Create imageDatastore
            imds = imageDatastore(fullPaths);
            
            % Add labels
            imds.Labels = categorical(labels);
            
            % Configure read function for resizing
            imds.ReadFcn = @(filename) imresize(imread(filename), inputSize);
        end
        
        function verifyStratification(obj, trainIdx, valIdx, testIdx)
            % Verify that stratified split maintains class proportions
            % Inputs:
            %   trainIdx, valIdx, testIdx - Indices for each split
            
            obj.errorHandler.logInfo('DatasetManager', ...
                'Verifying stratification...');
            
            % Get labels for each split
            trainLabels = obj.allLabels(trainIdx);
            valLabels = obj.allLabels(valIdx);
            testLabels = obj.allLabels(testIdx);
            
            % Compute class proportions for each split
            uniqueClasses = unique(obj.allLabels);
            
            overallProportions = zeros(1, length(uniqueClasses));
            trainProportions = zeros(1, length(uniqueClasses));
            valProportions = zeros(1, length(uniqueClasses));
            testProportions = zeros(1, length(uniqueClasses));
            
            for i = 1:length(uniqueClasses)
                classLabel = uniqueClasses(i);
                overallProportions(i) = sum(obj.allLabels == classLabel) / length(obj.allLabels);
                trainProportions(i) = sum(trainLabels == classLabel) / length(trainLabels);
                valProportions(i) = sum(valLabels == classLabel) / length(valLabels);
                testProportions(i) = sum(testLabels == classLabel) / length(testLabels);
            end
            
            % Check if proportions are similar (within 5% tolerance)
            maxDeviation = 0;
            for i = 1:length(uniqueClasses)
                trainDev = abs(trainProportions(i) - overallProportions(i));
                valDev = abs(valProportions(i) - overallProportions(i));
                testDev = abs(testProportions(i) - overallProportions(i));
                
                maxDeviation = max([maxDeviation, trainDev, valDev, testDev]);
                
                obj.errorHandler.logInfo('DatasetManager', ...
                    sprintf('Class %d proportions: Overall=%.3f, Train=%.3f, Val=%.3f, Test=%.3f', ...
                    uniqueClasses(i), overallProportions(i), ...
                    trainProportions(i), valProportions(i), testProportions(i)));
            end
            
            if maxDeviation > 0.05
                obj.errorHandler.logWarning('DatasetManager', ...
                    sprintf('Stratification deviation detected: max=%.3f (>5%%)', maxDeviation));
            else
                obj.errorHandler.logInfo('DatasetManager', ...
                    'Stratification verified: class proportions maintained');
            end
        end
        
        function logStatistics(obj, stats)
            % Log detailed dataset statistics
            % Input: stats - Statistics struct from getDatasetStatistics
            
            obj.errorHandler.logInfo('DatasetManager', '=== Dataset Statistics ===');
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Total samples: %d', stats.totalSamples));
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Number of classes: %d', stats.numClasses));
            
            obj.errorHandler.logInfo('DatasetManager', '--- Class Distribution ---');
            for i = 1:stats.numClasses
                obj.errorHandler.logInfo('DatasetManager', ...
                    sprintf('Class %d (%s): %d samples (%.1f%%)', ...
                    stats.uniqueClasses(i), stats.classNames{i}, ...
                    stats.classDistribution(i), stats.classPercentages(i)));
            end
            
            obj.errorHandler.logInfo('DatasetManager', '--- Corroded Percentage Statistics ---');
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Range: [%.2f%%, %.2f%%]', ...
                stats.percentageRange(1), stats.percentageRange(2)));
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Mean: %.2f%% (±%.2f%%)', ...
                stats.percentageMean, stats.percentageStd));
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Median: %.2f%%', stats.percentageMedian));
            
            obj.errorHandler.logInfo('DatasetManager', '--- Class Balance Analysis ---');
            obj.errorHandler.logInfo('DatasetManager', ...
                sprintf('Imbalance ratio: %.2f:1', stats.imbalanceRatio));
            
            if stats.isImbalanced
                obj.errorHandler.logWarning('DatasetManager', ...
                    'Dataset is imbalanced (ratio > 3:1). Consider using class weights or resampling.');
            else
                obj.errorHandler.logInfo('DatasetManager', ...
                    'Dataset is reasonably balanced');
            end
            
            obj.errorHandler.logInfo('DatasetManager', '=== End Statistics ===');
        end
    end
end
