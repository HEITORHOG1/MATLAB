% ClassificationConfig.m - Centralized configuration management for classification system
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This class provides centralized configuration for the corrosion severity
% classification system, including paths, hyperparameters, and model settings.
%
% Usage:
%   config = ClassificationConfig();
%   config = ClassificationConfig('custom_config.mat');
%
% Requirements: 7.4, 8.1

classdef ClassificationConfig < handle
    % ClassificationConfig - Centralized configuration management for classification system
    %
    % This class provides centralized configuration for the corrosion severity
    % classification system, including paths, hyperparameters, and model settings.
    %
    % Usage:
    %   config = ClassificationConfig();
    %   config = ClassificationConfig('custom_config.mat');
    %
    % Requirements: 7.4, 8.1
    
    properties (Access = public)
        % Path Configuration
        paths
        
        % Label Generation Configuration
        labelGeneration
        
        % Dataset Configuration
        dataset
        
        % Training Configuration
        training
        
        % Model Configuration
        models
        
        % Evaluation Configuration
        evaluation
        
        % Visualization Configuration
        visualization
    end
    
    methods
        function obj = ClassificationConfig(configFile)
            % Constructor - Initialize configuration with default values
            %
            % Args:
            %   configFile (optional): Path to custom configuration file
            
            if nargin < 1
                configFile = '';
            end
            
            % Initialize default configuration
            obj.initializeDefaults();
            
            % Load custom configuration if provided
            if ~isempty(configFile) && isfile(configFile)
                obj.loadFromFile(configFile);
            end
            
            % Validate configuration
            obj.validateConfig();
        end
        
        function initializeDefaults(obj)
            % Initialize default configuration values
            
            % Path Configuration
            obj.paths = struct(...
                'imageDir', 'img/original', ...
                'maskDir', 'img/masks', ...
                'outputDir', 'output/classification', ...
                'checkpointDir', 'output/classification/checkpoints', ...
                'resultsDir', 'output/classification/results', ...
                'figuresDir', 'output/classification/figures', ...
                'latexDir', 'output/classification/latex', ...
                'logsDir', 'output/classification/logs' ...
            );
            
            % Label Generation Configuration
            obj.labelGeneration = struct(...
                'thresholds', [10, 30], ...  % [light_threshold, moderate_threshold]
                'outputCSV', 'output/classification/labels.csv', ...
                'classNames', {{'None/Light', 'Moderate', 'Severe'}}, ...
                'numClasses', 3 ...
            );
            
            % Dataset Configuration
            obj.dataset = struct(...
                'splitRatios', [0.7, 0.15, 0.15], ...  % [train, val, test]
                'inputSize', [224, 224], ...
                'augmentation', true, ...
                'augmentationConfig', struct(...
                    'horizontalFlip', true, ...
                    'verticalFlip', true, ...
                    'rotationRange', [-15, 15], ...  % degrees
                    'brightnessRange', [0.8, 1.2], ...  % ±20%
                    'contrastRange', [0.8, 1.2] ...     % ±20%
                ), ...
                'shuffle', true, ...
                'seed', 42 ...  % For reproducibility
            );
            
            % Training Configuration
            obj.training = struct(...
                'maxEpochs', 50, ...
                'miniBatchSize', 32, ...
                'initialLearnRate', 1e-4, ...
                'learnRateSchedule', 'piecewise', ...
                'learnRateDropFactor', 0.1, ...
                'learnRateDropPeriod', 10, ...
                'validationFrequency', 50, ...
                'validationPatience', 10, ...
                'shuffleEveryEpoch', true, ...
                'verbose', true, ...
                'plots', 'training-progress', ...
                'executionEnvironment', 'auto', ...  % 'auto', 'gpu', 'cpu'
                'checkpointFrequency', 5 ...  % Save checkpoint every N epochs
            );
            
            % Model Configuration
            obj.models = struct(...
                'architectures', {{'ResNet50', 'EfficientNetB0', 'CustomCNN'}}, ...
                'transferLearning', true, ...
                'freezeEarlyLayers', true, ...
                'numLayersToFineTune', 10 ...  % Number of layers from end to fine-tune
            );
            
            % Evaluation Configuration
            obj.evaluation = struct(...
                'generateROC', true, ...
                'generateConfusionMatrix', true, ...
                'measureInferenceTime', true, ...
                'numInferenceSamples', 100, ...  % For speed measurement
                'warmupIterations', 10, ...
                'computePerClassMetrics', true, ...
                'saveDetailedResults', true ...
            );
            
            % Visualization Configuration
            obj.visualization = struct(...
                'figureSize', [8, 6], ...  % inches
                'dpi', 300, ...
                'colormap', 'Blues', ...
                'exportFormats', {{'png', 'pdf'}}, ...
                'fontSize', 12, ...
                'lineWidth', 2, ...
                'showGrid', true ...
            );
        end
        
        function loadFromFile(obj, configFile)
            % Load configuration from MAT file
            %
            % Args:
            %   configFile: Path to configuration MAT file
            
            try
                loadedConfig = load(configFile);
                
                % Update configuration fields if they exist
                if isfield(loadedConfig, 'paths')
                    obj.paths = obj.mergeStructs(obj.paths, loadedConfig.paths);
                end
                if isfield(loadedConfig, 'labelGeneration')
                    obj.labelGeneration = obj.mergeStructs(obj.labelGeneration, loadedConfig.labelGeneration);
                end
                if isfield(loadedConfig, 'dataset')
                    obj.dataset = obj.mergeStructs(obj.dataset, loadedConfig.dataset);
                end
                if isfield(loadedConfig, 'training')
                    obj.training = obj.mergeStructs(obj.training, loadedConfig.training);
                end
                if isfield(loadedConfig, 'models')
                    obj.models = obj.mergeStructs(obj.models, loadedConfig.models);
                end
                if isfield(loadedConfig, 'evaluation')
                    obj.evaluation = obj.mergeStructs(obj.evaluation, loadedConfig.evaluation);
                end
                if isfield(loadedConfig, 'visualization')
                    obj.visualization = obj.mergeStructs(obj.visualization, loadedConfig.visualization);
                end
                
                fprintf('Configuration loaded from: %s\n', configFile);
            catch ME
                warning('Failed to load configuration file: %s\nUsing default configuration.', ME.message);
            end
        end
        
        function saveToFile(obj, configFile)
            % Save current configuration to MAT file
            %
            % Args:
            %   configFile: Path to save configuration
            
            try
                paths = obj.paths;
                labelGeneration = obj.labelGeneration;
                dataset = obj.dataset;
                training = obj.training;
                models = obj.models;
                evaluation = obj.evaluation;
                visualization = obj.visualization;
                
                save(configFile, 'paths', 'labelGeneration', 'dataset', ...
                     'training', 'models', 'evaluation', 'visualization');
                
                fprintf('Configuration saved to: %s\n', configFile);
            catch ME
                error('Failed to save configuration file: %s', ME.message);
            end
        end
        
        function validateConfig(obj)
            % Validate configuration parameters
            
            % Validate paths exist or can be created
            obj.validatePaths();
            
            % Validate label generation parameters
            assert(length(obj.labelGeneration.thresholds) == 2, ...
                'Label generation thresholds must have exactly 2 values');
            assert(obj.labelGeneration.thresholds(1) < obj.labelGeneration.thresholds(2), ...
                'First threshold must be less than second threshold');
            assert(obj.labelGeneration.numClasses == 3, ...
                'Number of classes must be 3 for this system');
            
            % Validate dataset parameters
            assert(abs(sum(obj.dataset.splitRatios) - 1.0) < 1e-6, ...
                'Dataset split ratios must sum to 1.0');
            assert(all(obj.dataset.splitRatios > 0), ...
                'All split ratios must be positive');
            assert(length(obj.dataset.inputSize) == 2, ...
                'Input size must be [height, width]');
            
            % Validate training parameters
            assert(obj.training.maxEpochs > 0, 'Max epochs must be positive');
            assert(obj.training.miniBatchSize > 0, 'Mini batch size must be positive');
            assert(obj.training.initialLearnRate > 0, 'Initial learn rate must be positive');
            assert(obj.training.validationPatience > 0, 'Validation patience must be positive');
            
            % Validate model parameters
            assert(~isempty(obj.models.architectures), ...
                'At least one model architecture must be specified');
            
            fprintf('Configuration validation passed.\n');
        end
        
        function validatePaths(obj)
            % Validate and create necessary directories
            
            % Create output directories if they don't exist
            dirs = {obj.paths.outputDir, obj.paths.checkpointDir, ...
                    obj.paths.resultsDir, obj.paths.figuresDir, ...
                    obj.paths.latexDir, obj.paths.logsDir};
            
            for i = 1:length(dirs)
                if ~isfolder(dirs{i})
                    mkdir(dirs{i});
                    fprintf('Created directory: %s\n', dirs{i});
                end
            end
            
            % Validate input directories exist
            if ~isfolder(obj.paths.imageDir)
                warning('Image directory does not exist: %s', obj.paths.imageDir);
            end
            if ~isfolder(obj.paths.maskDir)
                warning('Mask directory does not exist: %s', obj.paths.maskDir);
            end
        end
        
        function merged = mergeStructs(~, base, override)
            % Merge two structs, with override taking precedence
            %
            % Args:
            %   base: Base struct with default values
            %   override: Struct with override values
            %
            % Returns:
            %   merged: Merged struct
            
            merged = base;
            fields = fieldnames(override);
            
            for i = 1:length(fields)
                merged.(fields{i}) = override.(fields{i});
            end
        end
        
        function displayConfig(obj)
            % Display current configuration
            
            fprintf('\n=== Classification System Configuration ===\n\n');
            
            fprintf('Paths:\n');
            disp(obj.paths);
            
            fprintf('\nLabel Generation:\n');
            disp(obj.labelGeneration);
            
            fprintf('\nDataset:\n');
            disp(obj.dataset);
            
            fprintf('\nTraining:\n');
            disp(obj.training);
            
            fprintf('\nModels:\n');
            disp(obj.models);
            
            fprintf('\nEvaluation:\n');
            disp(obj.evaluation);
            
            fprintf('\nVisualization:\n');
            disp(obj.visualization);
            
            fprintf('\n==========================================\n\n');
        end
        
        function config = getConfig(obj)
            % Get configuration as a single struct
            %
            % Returns:
            %   config: Struct containing all configuration
            
            config = struct(...
                'paths', obj.paths, ...
                'labelGeneration', obj.labelGeneration, ...
                'dataset', obj.dataset, ...
                'training', obj.training, ...
                'models', obj.models, ...
                'evaluation', obj.evaluation, ...
                'visualization', obj.visualization ...
            );
        end
    end
end
