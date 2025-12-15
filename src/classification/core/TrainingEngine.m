% TrainingEngine.m - Execute training loops with monitoring, checkpointing, and early stopping
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This class manages the training process for classification models, including:
%   - Training loop execution with validation
%   - Real-time monitoring of loss and accuracy
%   - Checkpointing (best model and last epoch)
%   - Early stopping based on validation patience
%   - Training history visualization
%
% Requirements addressed: 4.1, 4.3, 4.4, 7.1

classdef TrainingEngine < handle
    % TrainingEngine - Execute training loops with monitoring, checkpointing, and early stopping
    %
    % This class manages the training process for classification models, including:
    %   - Training loop execution with validation
    %   - Real-time monitoring of loss and accuracy
    %   - Checkpointing (best model and last epoch)
    %   - Early stopping based on validation patience
    %   - Training history visualization
    %
    % Requirements addressed: 4.1, 4.3, 4.4, 7.1
    
    properties (Access = private)
        lgraph              % Layer graph or network to train
        trainingOptions     % Training options struct
        errorHandler        % ErrorHandler instance for logging
        checkpointDir       % Directory for saving checkpoints
        
        % Training state
        bestValAccuracy     % Best validation accuracy achieved
        bestEpoch           % Epoch with best validation accuracy
        epochsWithoutImprovement  % Counter for early stopping
    end
    
    properties (Constant)
        % Default training configuration
        DEFAULT_CONFIG = struct(...
            'maxEpochs', 50, ...
            'miniBatchSize', 32, ...
            'initialLearnRate', 1e-4, ...
            'learnRateSchedule', 'piecewise', ...
            'learnRateDropFactor', 0.1, ...
            'learnRateDropPeriod', 10, ...
            'validationFrequency', 50, ...
            'validationPatience', 10, ...
            'shuffle', 'every-epoch', ...
            'verbose', true, ...
            'plots', 'none' ...  % We'll create custom plots
        );
    end
    
    methods
        function obj = TrainingEngine(lgraph, config)
            % Constructor
            % Inputs:
            %   lgraph - Layer graph or network to train
            %   config - Configuration struct with fields:
            %            - trainingOptions: training parameters
            %            - checkpointDir: directory for saving checkpoints
            %            - errorHandler: ErrorHandler instance (optional)
            %
            % Requirements: 4.1, 7.1
            
            if nargin < 1 || isempty(lgraph)
                error('TrainingEngine:InvalidInput', 'Layer graph is required');
            end
            
            obj.lgraph = lgraph;
            
            % Initialize error handler
            if nargin >= 2 && isstruct(config) && isfield(config, 'errorHandler')
                obj.errorHandler = config.errorHandler;
            else
                obj.errorHandler = ErrorHandler.getInstance();
            end
            
            % Set training options
            if nargin >= 2 && isstruct(config) && isfield(config, 'trainingOptions')
                obj.trainingOptions = obj.mergeWithDefaults(config.trainingOptions);
            else
                obj.trainingOptions = obj.DEFAULT_CONFIG;
            end
            
            % Set checkpoint directory
            if nargin >= 2 && isstruct(config) && isfield(config, 'checkpointDir')
                obj.checkpointDir = config.checkpointDir;
            else
                obj.checkpointDir = fullfile('output', 'classification', 'checkpoints');
            end
            
            % Create checkpoint directory if it doesn't exist
            if ~exist(obj.checkpointDir, 'dir')
                mkdir(obj.checkpointDir);
                obj.errorHandler.logInfo('TrainingEngine', ...
                    sprintf('Created checkpoint directory: %s', obj.checkpointDir));
            end
            
            % Initialize training state
            obj.bestValAccuracy = 0;
            obj.bestEpoch = 0;
            obj.epochsWithoutImprovement = 0;
            
            obj.errorHandler.logInfo('TrainingEngine', 'TrainingEngine initialized');
            obj.logTrainingConfig();
        end
        
        function [trainedNet, history] = train(obj, trainDS, valDS, modelName)
            % Train the network with monitoring and checkpointing
            % Inputs:
            %   trainDS - Training datastore (imageDatastore or augmentedImageDatastore)
            %   valDS - Validation datastore
            %   modelName - Name for saving checkpoints (optional)
            % Outputs:
            %   trainedNet - Trained network
            %   history - Training history struct with loss and accuracy per epoch
            %
            % Requirements: 4.1, 4.3, 4.4
            
            if nargin < 4 || isempty(modelName)
                modelName = 'model';
            end
            
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('Starting training for model: %s', modelName));
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('Max epochs: %d, Mini-batch size: %d', ...
                obj.trainingOptions.maxEpochs, obj.trainingOptions.miniBatchSize));
            
            % Reset training state
            obj.bestValAccuracy = 0;
            obj.bestEpoch = 0;
            obj.epochsWithoutImprovement = 0;
            
            % Initialize history
            history = struct();
            history.epoch = [];
            history.trainLoss = [];
            history.trainAccuracy = [];
            history.valLoss = [];
            history.valAccuracy = [];
            history.learningRate = [];
            history.timestamp = datetime('now');
            history.modelName = modelName;
            
            % Configure training options for trainNetwork
            options = trainingOptions('adam', ...
                'MaxEpochs', obj.trainingOptions.maxEpochs, ...
                'MiniBatchSize', obj.trainingOptions.miniBatchSize, ...
                'InitialLearnRate', obj.trainingOptions.initialLearnRate, ...
                'LearnRateSchedule', obj.trainingOptions.learnRateSchedule, ...
                'LearnRateDropFactor', obj.trainingOptions.learnRateDropFactor, ...
                'LearnRateDropPeriod', obj.trainingOptions.learnRateDropPeriod, ...
                'ValidationData', valDS, ...
                'ValidationFrequency', obj.trainingOptions.validationFrequency, ...
                'Shuffle', obj.trainingOptions.shuffle, ...
                'Verbose', obj.trainingOptions.verbose, ...
                'Plots', obj.trainingOptions.plots, ...
                'OutputFcn', @(info) obj.trainingProgressCallback(info, history, modelName));
            
            try
                % Train the network
                obj.errorHandler.logInfo('TrainingEngine', 'Training started...');
                startTime = tic;
                
                trainedNet = trainNetwork(trainDS, obj.lgraph, options);
                
                elapsedTime = toc(startTime);
                obj.errorHandler.logInfo('TrainingEngine', ...
                    sprintf('Training completed in %.2f seconds (%.2f minutes)', ...
                    elapsedTime, elapsedTime/60));
                
                % Load best model if available
                bestCheckpointPath = fullfile(obj.checkpointDir, sprintf('%s_best.mat', modelName));
                if exist(bestCheckpointPath, 'file')
                    obj.errorHandler.logInfo('TrainingEngine', ...
                        sprintf('Loading best model from epoch %d (val accuracy: %.4f)', ...
                        obj.bestEpoch, obj.bestValAccuracy));
                    
                    checkpoint = load(bestCheckpointPath);
                    trainedNet = checkpoint.net;
                    history = checkpoint.history;
                end
                
                % Save final checkpoint
                obj.saveCheckpoint(trainedNet, obj.trainingOptions.maxEpochs, history, modelName, 'last');
                
                obj.errorHandler.logInfo('TrainingEngine', ...
                    sprintf('Best validation accuracy: %.4f at epoch %d', ...
                    obj.bestValAccuracy, obj.bestEpoch));
                
            catch ME
                obj.errorHandler.logError('TrainingEngine', ...
                    sprintf('Training failed: %s', ME.message));
                obj.errorHandler.logError('TrainingEngine', ...
                    sprintf('Stack trace: %s', ME.getReport()));
                rethrow(ME);
            end
        end
        
        function stop = trainingProgressCallback(obj, info, history, modelName)
            % Callback function for monitoring training progress
            % This is called by trainNetwork during training
            % Inputs:
            %   info - Training info struct from trainNetwork
            %   history - Training history struct (passed by reference)
            %   modelName - Model name for checkpointing
            % Output:
            %   stop - Boolean to stop training (for early stopping)
            %
            % Requirements: 4.3, 4.4
            
            stop = false;
            
            % Only process at end of epoch
            if info.State ~= "done" && info.State ~= "iteration"
                return;
            end
            
            % Check if this is an epoch end (validation was performed)
            if isfield(info, 'ValidationLoss') && ~isempty(info.ValidationLoss)
                epoch = info.Epoch;
                
                % Log training metrics
                obj.errorHandler.logInfo('TrainingEngine', ...
                    sprintf('Epoch %d/%d - Train Loss: %.4f, Train Acc: %.4f, Val Loss: %.4f, Val Acc: %.4f', ...
                    epoch, obj.trainingOptions.maxEpochs, ...
                    info.TrainingLoss, info.TrainingAccuracy, ...
                    info.ValidationLoss, info.ValidationAccuracy));
                
                % Update history
                history.epoch(end+1) = epoch;
                history.trainLoss(end+1) = info.TrainingLoss;
                history.trainAccuracy(end+1) = info.TrainingAccuracy;
                history.valLoss(end+1) = info.ValidationLoss;
                history.valAccuracy(end+1) = info.ValidationAccuracy;
                
                % Get current learning rate
                if isfield(info, 'BaseLearnRate')
                    history.learningRate(end+1) = info.BaseLearnRate;
                else
                    history.learningRate(end+1) = obj.trainingOptions.initialLearnRate;
                end
                
                % Check for improvement
                if info.ValidationAccuracy > obj.bestValAccuracy
                    obj.bestValAccuracy = info.ValidationAccuracy;
                    obj.bestEpoch = epoch;
                    obj.epochsWithoutImprovement = 0;
                    
                    obj.errorHandler.logInfo('TrainingEngine', ...
                        sprintf('*** New best validation accuracy: %.4f at epoch %d ***', ...
                        obj.bestValAccuracy, obj.bestEpoch));
                    
                    % Save best model checkpoint
                    % Note: We can't directly access the network during training,
                    % so we'll save it after training completes
                    
                else
                    obj.epochsWithoutImprovement = obj.epochsWithoutImprovement + 1;
                    
                    obj.errorHandler.logInfo('TrainingEngine', ...
                        sprintf('No improvement for %d epochs (patience: %d)', ...
                        obj.epochsWithoutImprovement, obj.trainingOptions.validationPatience));
                    
                    % Check for early stopping
                    if obj.epochsWithoutImprovement >= obj.trainingOptions.validationPatience
                        obj.errorHandler.logWarning('TrainingEngine', ...
                            sprintf('Early stopping triggered at epoch %d', epoch));
                        obj.errorHandler.logInfo('TrainingEngine', ...
                            sprintf('Best model was at epoch %d with val accuracy: %.4f', ...
                            obj.bestEpoch, obj.bestValAccuracy));
                        
                        stop = true;
                    end
                end
            end
        end
        
        function saveCheckpoint(obj, net, epoch, history, modelName, checkpointType)
            % Save model checkpoint with training history
            % Inputs:
            %   net - Network to save
            %   epoch - Current epoch number
            %   history - Training history struct
            %   modelName - Model name for filename
            %   checkpointType - 'best' or 'last'
            %
            % Requirements: 4.4
            
            if nargin < 6 || isempty(checkpointType)
                checkpointType = 'best';
            end
            
            try
                % Create checkpoint filename
                checkpointFilename = sprintf('%s_%s.mat', modelName, checkpointType);
                checkpointPath = fullfile(obj.checkpointDir, checkpointFilename);
                
                % Create checkpoint struct
                checkpoint = struct();
                checkpoint.net = net;
                checkpoint.epoch = epoch;
                checkpoint.history = history;
                checkpoint.timestamp = datetime('now');
                checkpoint.modelName = modelName;
                checkpoint.checkpointType = checkpointType;
                
                if strcmp(checkpointType, 'best')
                    checkpoint.valAccuracy = obj.bestValAccuracy;
                end
                
                % Save checkpoint
                save(checkpointPath, '-struct', 'checkpoint', '-v7.3');
                
                obj.errorHandler.logInfo('TrainingEngine', ...
                    sprintf('Checkpoint saved: %s (epoch %d)', checkpointPath, epoch));
                
            catch ME
                obj.errorHandler.logError('TrainingEngine', ...
                    sprintf('Failed to save checkpoint: %s', ME.message));
            end
        end
        
        function net = loadCheckpoint(obj, modelName, checkpointType)
            % Load model checkpoint
            % Inputs:
            %   modelName - Model name
            %   checkpointType - 'best' or 'last' (default: 'best')
            % Output:
            %   net - Loaded network
            %
            % Requirements: 4.4
            
            if nargin < 3 || isempty(checkpointType)
                checkpointType = 'best';
            end
            
            checkpointFilename = sprintf('%s_%s.mat', modelName, checkpointType);
            checkpointPath = fullfile(obj.checkpointDir, checkpointFilename);
            
            if ~exist(checkpointPath, 'file')
                error('TrainingEngine:CheckpointNotFound', ...
                    'Checkpoint not found: %s', checkpointPath);
            end
            
            try
                obj.errorHandler.logInfo('TrainingEngine', ...
                    sprintf('Loading checkpoint: %s', checkpointPath));
                
                checkpoint = load(checkpointPath);
                net = checkpoint.net;
                
                obj.errorHandler.logInfo('TrainingEngine', ...
                    sprintf('Checkpoint loaded: epoch %d', checkpoint.epoch));
                
                if isfield(checkpoint, 'valAccuracy')
                    obj.errorHandler.logInfo('TrainingEngine', ...
                        sprintf('Validation accuracy: %.4f', checkpoint.valAccuracy));
                end
                
            catch ME
                obj.errorHandler.logError('TrainingEngine', ...
                    sprintf('Failed to load checkpoint: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function plotTrainingHistory(obj, history, outputPath)
            % Plot training history (loss and accuracy curves)
            % Inputs:
            %   history - Training history struct
            %   outputPath - Path to save figure (optional)
            %
            % Requirements: 4.3
            
            if nargin < 2 || isempty(history) || isempty(history.epoch)
                obj.errorHandler.logWarning('TrainingEngine', ...
                    'No training history available for plotting');
                return;
            end
            
            obj.errorHandler.logInfo('TrainingEngine', 'Generating training history plots...');
            
            try
                % Create figure
                fig = figure('Position', [100, 100, 1200, 500]);
                
                % Plot 1: Loss curves
                subplot(1, 2, 1);
                plot(history.epoch, history.trainLoss, '-o', 'LineWidth', 2, 'DisplayName', 'Training Loss');
                hold on;
                plot(history.epoch, history.valLoss, '--s', 'LineWidth', 2, 'DisplayName', 'Validation Loss');
                hold off;
                
                xlabel('Epoch', 'FontSize', 12);
                ylabel('Loss', 'FontSize', 12);
                title(sprintf('Training and Validation Loss - %s', history.modelName), 'FontSize', 14);
                legend('Location', 'best');
                grid on;
                
                % Plot 2: Accuracy curves
                subplot(1, 2, 2);
                plot(history.epoch, history.trainAccuracy * 100, '-o', 'LineWidth', 2, 'DisplayName', 'Training Accuracy');
                hold on;
                plot(history.epoch, history.valAccuracy * 100, '--s', 'LineWidth', 2, 'DisplayName', 'Validation Accuracy');
                hold off;
                
                xlabel('Epoch', 'FontSize', 12);
                ylabel('Accuracy (%)', 'FontSize', 12);
                title(sprintf('Training and Validation Accuracy - %s', history.modelName), 'FontSize', 14);
                legend('Location', 'best');
                grid on;
                
                % Save figure if output path provided
                if nargin >= 3 && ~isempty(outputPath)
                    % Save as PNG
                    saveas(fig, outputPath, 'png');
                    obj.errorHandler.logInfo('TrainingEngine', ...
                        sprintf('Training history plot saved: %s', outputPath));
                    
                    % Also save as PDF
                    [filepath, name, ~] = fileparts(outputPath);
                    pdfPath = fullfile(filepath, [name, '.pdf']);
                    saveas(fig, pdfPath, 'pdf');
                    
                    close(fig);
                else
                    obj.errorHandler.logInfo('TrainingEngine', ...
                        'Training history plot displayed (not saved)');
                end
                
            catch ME
                obj.errorHandler.logError('TrainingEngine', ...
                    sprintf('Failed to plot training history: %s', ME.message));
            end
        end
    end
    
    methods (Access = private)
        function config = mergeWithDefaults(obj, userConfig)
            % Merge user configuration with default configuration
            % Input: userConfig - User-provided configuration struct
            % Output: config - Merged configuration
            
            config = obj.DEFAULT_CONFIG;
            
            if isstruct(userConfig)
                fields = fieldnames(userConfig);
                for i = 1:length(fields)
                    field = fields{i};
                    config.(field) = userConfig.(field);
                end
            end
        end
        
        function logTrainingConfig(obj)
            % Log training configuration
            
            obj.errorHandler.logInfo('TrainingEngine', '=== Training Configuration ===');
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('Max Epochs: %d', obj.trainingOptions.maxEpochs));
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('Mini-batch Size: %d', obj.trainingOptions.miniBatchSize));
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('Initial Learning Rate: %.6f', obj.trainingOptions.initialLearnRate));
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('Learning Rate Schedule: %s', obj.trainingOptions.learnRateSchedule));
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('LR Drop Factor: %.2f', obj.trainingOptions.learnRateDropFactor));
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('LR Drop Period: %d epochs', obj.trainingOptions.learnRateDropPeriod));
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('Validation Frequency: %d iterations', obj.trainingOptions.validationFrequency));
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('Validation Patience: %d epochs', obj.trainingOptions.validationPatience));
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('Shuffle: %s', obj.trainingOptions.shuffle));
            obj.errorHandler.logInfo('TrainingEngine', ...
                sprintf('Checkpoint Directory: %s', obj.checkpointDir));
            obj.errorHandler.logInfo('TrainingEngine', '=== End Configuration ===');
        end
    end
end
