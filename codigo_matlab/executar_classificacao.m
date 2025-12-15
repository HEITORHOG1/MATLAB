% executar_classificacao.m - Main execution script for classification system
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This script executes the complete classification workflow:
%   1. Load configuration
%   2. Generate labels from segmentation masks
%   3. Prepare dataset splits
%   4. Train all configured models
%   5. Evaluate all models
%   6. Generate visualizations and export results
%   7. Create final summary report
%
% Requirements: 8.1, 8.2, 8.3, 8.4, 8.5
%
% Usage:
%   executar_classificacao()           % Use default configuration
%   executar_classificacao(configFile) % Use custom configuration
%
% Author: Classification System
% Date: 2025

function executar_classificacao(configFile)
    %% Initialize
    fprintf('\n');
    fprintf('========================================================\n');
    fprintf('  CORROSION CLASSIFICATION SYSTEM - MAIN EXECUTION\n');
    fprintf('========================================================\n\n');
    
    % Start timing
    totalStartTime = tic;
    
    % Initialize error handler
    errorHandler = ErrorHandler.getInstance();
    
    % Create timestamped log file
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    logDir = fullfile('output', 'classification', 'logs');
    if ~exist(logDir, 'dir')
        mkdir(logDir);
    end
    logFile = fullfile(logDir, sprintf('classification_execution_%s.txt', timestamp));
    errorHandler.setLogFile(logFile);
    
    errorHandler.logInfo('Main', '=== CLASSIFICATION SYSTEM EXECUTION STARTED ===');
    errorHandler.logInfo('Main', sprintf('Timestamp: %s', datestr(now)));
    errorHandler.logInfo('Main', sprintf('Log file: %s', logFile));
    
    %% Phase 1: Load Configuration
    fprintf('\n[Phase 1/7] Loading Configuration...\n');
    fprintf('----------------------------------------\n');
    phaseStartTime = tic;
    
    try
        if nargin < 1 || isempty(configFile)
            config = ClassificationConfig();
            errorHandler.logInfo('Main', 'Using default configuration');
        else
            config = ClassificationConfig(configFile);
            errorHandler.logInfo('Main', sprintf('Loaded configuration from: %s', configFile));
        end
        
        % Display configuration
        config.displayConfig();
        
        % Detect and validate paths
        detectAndValidatePaths(config, errorHandler);
        
        phaseTime = toc(phaseStartTime);
        fprintf('✓ Configuration loaded successfully (%.2f seconds)\n', phaseTime);
        errorHandler.logInfo('Main', sprintf('Phase 1 completed in %.2f seconds', phaseTime));
        
    catch ME
        errorHandler.logError('Main', sprintf('Phase 1 failed: %s', ME.message));
        errorHandler.logError('Main', ME.getReport());
        rethrow(ME);
    end
    
    %% Phase 2: Generate Labels from Masks
    fprintf('\n[Phase 2/7] Generating Labels from Segmentation Masks...\n');
    fprintf('----------------------------------------\n');
    phaseStartTime = tic;
    
    try
        % Check if labels already exist
        if exist(config.labelGeneration.outputCSV, 'file')
            response = input('Labels file already exists. Regenerate? (y/n): ', 's');
            if ~strcmpi(response, 'y')
                errorHandler.logInfo('Main', 'Using existing labels file');
                fprintf('Using existing labels file: %s\n', config.labelGeneration.outputCSV);
                phaseTime = toc(phaseStartTime);
                fprintf('✓ Labels loaded (%.2f seconds)\n', phaseTime);
                errorHandler.logInfo('Main', sprintf('Phase 2 completed in %.2f seconds', phaseTime));
            else
                [labels, stats] = generateLabels(config, errorHandler);
                phaseTime = toc(phaseStartTime);
                fprintf('✓ Labels generated successfully (%.2f seconds)\n', phaseTime);
                fprintf('  - Total samples: %d\n', stats.successCount);
                fprintf('  - Class distribution: [%d, %d, %d]\n', ...
                    stats.classDistribution(1), stats.classDistribution(2), stats.classDistribution(3));
                errorHandler.logInfo('Main', sprintf('Phase 2 completed in %.2f seconds', phaseTime));
            end
        else
            [labels, stats] = generateLabels(config, errorHandler);
            phaseTime = toc(phaseStartTime);
            fprintf('✓ Labels generated successfully (%.2f seconds)\n', phaseTime);
            fprintf('  - Total samples: %d\n', stats.successCount);
            fprintf('  - Class distribution: [%d, %d, %d]\n', ...
                stats.classDistribution(1), stats.classDistribution(2), stats.classDistribution(3));
            errorHandler.logInfo('Main', sprintf('Phase 2 completed in %.2f seconds', phaseTime));
        end
        
    catch ME
        errorHandler.logError('Main', sprintf('Phase 2 failed: %s', ME.message));
        errorHandler.logError('Main', ME.getReport());
        fprintf('✗ Label generation failed. Check log file for details.\n');
        rethrow(ME);
    end
    
    %% Phase 3: Prepare Dataset Splits
    fprintf('\n[Phase 3/7] Preparing Dataset Splits...\n');
    fprintf('----------------------------------------\n');
    phaseStartTime = tic;
    
    try
        [trainDS, valDS, testDS, datasetStats] = prepareDatasets(config, errorHandler);
        
        phaseTime = toc(phaseStartTime);
        fprintf('✓ Dataset prepared successfully (%.2f seconds)\n', phaseTime);
        fprintf('  - Training samples: %d\n', datasetStats.numTrain);
        fprintf('  - Validation samples: %d\n', datasetStats.numVal);
        fprintf('  - Test samples: %d\n', datasetStats.numTest);
        fprintf('  - Class balance: %.2f:1\n', datasetStats.imbalanceRatio);
        errorHandler.logInfo('Main', sprintf('Phase 3 completed in %.2f seconds', phaseTime));
        
    catch ME
        errorHandler.logError('Main', sprintf('Phase 3 failed: %s', ME.message));
        errorHandler.logError('Main', ME.getReport());
        fprintf('✗ Dataset preparation failed. Check log file for details.\n');
        rethrow(ME);
    end
    
    %% Phase 4: Train All Models
    fprintf('\n[Phase 4/7] Training Models...\n');
    fprintf('----------------------------------------\n');
    phaseStartTime = tic;
    
    trainedModels = {};
    trainingHistories = {};
    modelNames = config.models.architectures;
    trainingErrors = {};
    
    for i = 1:length(modelNames)
        modelName = modelNames{i};
        fprintf('\n--- Training Model %d/%d: %s ---\n', i, length(modelNames), modelName);
        
        try
            [net, history] = trainModel(modelName, trainDS, valDS, config, errorHandler);
            trainedModels{end+1} = net;
            trainingHistories{end+1} = history;
            trainingErrors{end+1} = [];
            
            fprintf('✓ %s training completed\n', modelName);
            fprintf('  - Best validation accuracy: %.4f\n', max(history.valAccuracy));
            fprintf('  - Training epochs: %d\n', length(history.epoch));
            
        catch ME
            errorHandler.logError('Main', sprintf('Training failed for %s: %s', modelName, ME.message));
            fprintf('✗ %s training failed: %s\n', modelName, ME.message);
            fprintf('  Continuing with remaining models...\n');
            
            trainedModels{end+1} = [];
            trainingHistories{end+1} = [];
            trainingErrors{end+1} = ME;
        end
    end
    
    phaseTime = toc(phaseStartTime);
    successfulModels = sum(cellfun(@(x) ~isempty(x), trainedModels));
    fprintf('\n✓ Training phase completed (%.2f seconds)\n', phaseTime);
    fprintf('  - Successfully trained: %d/%d models\n', successfulModels, length(modelNames));
    errorHandler.logInfo('Main', sprintf('Phase 4 completed in %.2f seconds', phaseTime));
    
    if successfulModels == 0
        error('All models failed to train. Cannot proceed with evaluation.');
    end
    
    %% Phase 5: Evaluate All Models
    fprintf('\n[Phase 5/7] Evaluating Models...\n');
    fprintf('----------------------------------------\n');
    phaseStartTime = tic;
    
    evaluationReports = {};
    
    for i = 1:length(trainedModels)
        if isempty(trainedModels{i})
            fprintf('Skipping evaluation for %s (training failed)\n', modelNames{i});
            evaluationReports{end+1} = [];
            continue;
        end
        
        modelName = modelNames{i};
        fprintf('\n--- Evaluating Model %d/%d: %s ---\n', i, length(modelNames), modelName);
        
        try
            report = evaluateModel(trainedModels{i}, testDS, modelName, config, errorHandler);
            evaluationReports{end+1} = report;
            
            fprintf('✓ %s evaluation completed\n', modelName);
            fprintf('  - Accuracy: %.4f (%.2f%%)\n', report.metrics.accuracy, report.metrics.accuracy * 100);
            fprintf('  - Macro F1: %.4f\n', report.metrics.macroF1);
            fprintf('  - Mean AUC: %.4f\n', mean(report.roc.auc));
            fprintf('  - Inference time: %.2f ms\n', report.inferenceTime);
            
        catch ME
            errorHandler.logError('Main', sprintf('Evaluation failed for %s: %s', modelName, ME.message));
            fprintf('✗ %s evaluation failed: %s\n', modelName, ME.message);
            evaluationReports{end+1} = [];
        end
    end
    
    phaseTime = toc(phaseStartTime);
    successfulEvaluations = sum(cellfun(@(x) ~isempty(x), evaluationReports));
    fprintf('\n✓ Evaluation phase completed (%.2f seconds)\n', phaseTime);
    fprintf('  - Successfully evaluated: %d/%d models\n', successfulEvaluations, length(modelNames));
    errorHandler.logInfo('Main', sprintf('Phase 5 completed in %.2f seconds', phaseTime));
    
    %% Phase 6: Generate Visualizations and Export
    fprintf('\n[Phase 6/7] Generating Visualizations...\n');
    fprintf('----------------------------------------\n');
    phaseStartTime = tic;
    
    try
        generateVisualizations(evaluationReports, trainingHistories, modelNames, config, errorHandler);
        
        phaseTime = toc(phaseStartTime);
        fprintf('✓ Visualizations generated successfully (%.2f seconds)\n', phaseTime);
        fprintf('  - Figures saved to: %s\n', config.paths.figuresDir);
        fprintf('  - LaTeX tables saved to: %s\n', config.paths.latexDir);
        errorHandler.logInfo('Main', sprintf('Phase 6 completed in %.2f seconds', phaseTime));
        
    catch ME
        errorHandler.logError('Main', sprintf('Phase 6 failed: %s', ME.message));
        errorHandler.logError('Main', ME.getReport());
        fprintf('✗ Visualization generation failed. Check log file for details.\n');
        % Don't rethrow - continue to summary
    end
    
    %% Phase 7: Generate Final Summary Report
    fprintf('\n[Phase 7/7] Generating Final Summary Report...\n');
    fprintf('----------------------------------------\n');
    phaseStartTime = tic;
    
    try
        generateFinalSummary(evaluationReports, trainingHistories, trainingErrors, ...
            modelNames, config, errorHandler, timestamp);
        
        phaseTime = toc(phaseStartTime);
        fprintf('✓ Summary report generated successfully (%.2f seconds)\n', phaseTime);
        errorHandler.logInfo('Main', sprintf('Phase 7 completed in %.2f seconds', phaseTime));
        
    catch ME
        errorHandler.logError('Main', sprintf('Phase 7 failed: %s', ME.message));
        fprintf('✗ Summary generation failed. Check log file for details.\n');
    end
    
    %% Completion
    totalTime = toc(totalStartTime);
    
    fprintf('\n');
    fprintf('========================================================\n');
    fprintf('  EXECUTION COMPLETED SUCCESSFULLY\n');
    fprintf('========================================================\n');
    fprintf('Total execution time: %.2f seconds (%.2f minutes)\n', totalTime, totalTime/60);
    fprintf('Log file: %s\n', logFile);
    fprintf('Results directory: %s\n', config.paths.outputDir);
    fprintf('\n');
    
    errorHandler.logInfo('Main', '=== CLASSIFICATION SYSTEM EXECUTION COMPLETED ===');
    errorHandler.logInfo('Main', sprintf('Total execution time: %.2f seconds', totalTime));
    
    % Display final results summary
    displayFinalResults(evaluationReports, modelNames);
end

%% Helper Functions

function detectAndValidatePaths(config, errorHandler)
    % Detect segmentation dataset location and validate paths
    % Requirements: 8.2
    
    errorHandler.logInfo('PathDetection', 'Detecting and validating paths...');
    
    % Check if image directory exists
    if ~exist(config.paths.imageDir, 'dir')
        errorHandler.logWarning('PathDetection', ...
            sprintf('Image directory not found: %s', config.paths.imageDir));
        
        % Try alternative locations
        alternativePaths = {'img/original', 'data/images', 'images'};
        found = false;
        
        for i = 1:length(alternativePaths)
            if exist(alternativePaths{i}, 'dir')
                config.paths.imageDir = alternativePaths{i};
                errorHandler.logInfo('PathDetection', ...
                    sprintf('Found images at: %s', alternativePaths{i}));
                found = true;
                break;
            end
        end
        
        if ~found
            error('PathDetection:ImageDirNotFound', ...
                'Could not find image directory. Please check configuration.');
        end
    end
    
    % Check if mask directory exists
    if ~exist(config.paths.maskDir, 'dir')
        errorHandler.logWarning('PathDetection', ...
            sprintf('Mask directory not found: %s', config.paths.maskDir));
        
        % Try alternative locations
        alternativePaths = {'img/masks', 'data/masks', 'masks'};
        found = false;
        
        for i = 1:length(alternativePaths)
            if exist(alternativePaths{i}, 'dir')
                config.paths.maskDir = alternativePaths{i};
                errorHandler.logInfo('PathDetection', ...
                    sprintf('Found masks at: %s', alternativePaths{i}));
                found = true;
                break;
            end
        end
        
        if ~found
            error('PathDetection:MaskDirNotFound', ...
                'Could not find mask directory. Please check configuration.');
        end
    end
    
    % Create output directories if they don't exist
    outputDirs = {config.paths.outputDir, config.paths.checkpointDir, ...
                  config.paths.resultsDir, config.paths.figuresDir, ...
                  config.paths.latexDir, config.paths.logsDir};
    
    for i = 1:length(outputDirs)
        if ~exist(outputDirs{i}, 'dir')
            mkdir(outputDirs{i});
            errorHandler.logInfo('PathDetection', ...
                sprintf('Created directory: %s', outputDirs{i}));
        end
    end
    
    errorHandler.logInfo('PathDetection', 'All paths validated successfully');
    errorHandler.logInfo('PathDetection', sprintf('Image directory: %s', config.paths.imageDir));
    errorHandler.logInfo('PathDetection', sprintf('Mask directory: %s', config.paths.maskDir));
    errorHandler.logInfo('PathDetection', sprintf('Output directory: %s', config.paths.outputDir));
end


function [labels, stats] = generateLabels(config, errorHandler)
    % Generate labels from segmentation masks
    % Requirements: 1.1, 1.2, 1.3, 1.4, 1.5
    
    errorHandler.logInfo('LabelGeneration', 'Starting label generation...');
    
    % Create label generator
    labelGen = LabelGenerator(config.labelGeneration.thresholds, errorHandler);
    
    % Generate labels
    [labels, stats] = labelGen.generateLabelsFromMasks(...
        config.paths.maskDir, ...
        config.labelGeneration.outputCSV);
    
    errorHandler.logInfo('LabelGeneration', 'Label generation completed');
end

function [trainDS, valDS, testDS, stats] = prepareDatasets(config, errorHandler)
    % Prepare dataset splits with augmentation
    % Requirements: 2.1, 2.2, 2.3, 2.4
    
    errorHandler.logInfo('DatasetPreparation', 'Preparing datasets...');
    
    % Create dataset manager configuration
    datasetConfig = struct();
    datasetConfig.splitRatios = config.dataset.splitRatios;
    datasetConfig.augmentation = config.dataset.augmentationConfig;
    datasetConfig.errorHandler = errorHandler;
    
    % Create dataset manager
    datasetManager = DatasetManager(...
        config.paths.imageDir, ...
        config.labelGeneration.outputCSV, ...
        datasetConfig);
    
    % Get dataset statistics
    stats = datasetManager.getDatasetStatistics();
    
    % Prepare splits
    [trainDS, valDS, testDS] = datasetManager.prepareDatasets(config.dataset.inputSize);
    
    % Apply augmentation to training set
    if config.dataset.augmentation
        trainDS = datasetManager.applyAugmentation(trainDS, config.dataset.inputSize);
        errorHandler.logInfo('DatasetPreparation', 'Data augmentation applied to training set');
    end
    
    % Add statistics
    stats.numTrain = numel(trainDS.Files);
    stats.numVal = numel(valDS.Files);
    stats.numTest = numel(testDS.Files);
    
    errorHandler.logInfo('DatasetPreparation', 'Dataset preparation completed');
end

function [net, history] = trainModel(modelName, trainDS, valDS, config, errorHandler)
    % Train a single model
    % Requirements: 3.1, 3.2, 3.3, 4.1, 4.3, 4.4
    
    errorHandler.logInfo('Training', sprintf('Training %s...', modelName));
    
    % Create model
    numClasses = config.labelGeneration.numClasses;
    inputSize = [config.dataset.inputSize, 3];
    
    switch modelName
        case 'ResNet50'
            lgraph = ModelFactory.createResNet50(numClasses, inputSize);
        case 'EfficientNetB0'
            lgraph = ModelFactory.createEfficientNetB0(numClasses, inputSize);
        case 'CustomCNN'
            lgraph = ModelFactory.createCustomCNN(numClasses, inputSize);
        otherwise
            error('Unknown model architecture: %s', modelName);
    end
    
    % Configure transfer learning for pre-trained models
    if config.models.transferLearning && ~strcmp(modelName, 'CustomCNN')
        lgraph = ModelFactory.configureTransferLearning(lgraph, config.models.numLayersToFineTune);
    end
    
    % Create training engine configuration
    trainingConfig = struct();
    trainingConfig.trainingOptions = config.training;
    trainingConfig.checkpointDir = config.paths.checkpointDir;
    trainingConfig.errorHandler = errorHandler;
    
    % Create training engine
    trainer = TrainingEngine(lgraph, trainingConfig);
    
    % Train model
    [net, history] = trainer.train(trainDS, valDS, modelName);
    
    % Plot training history
    historyPlotPath = fullfile(config.paths.figuresDir, ...
        sprintf('training_history_%s', modelName));
    trainer.plotTrainingHistory(history, historyPlotPath);
    
    errorHandler.logInfo('Training', sprintf('%s training completed', modelName));
end

function report = evaluateModel(net, testDS, modelName, config, errorHandler)
    % Evaluate a single model
    % Requirements: 5.1, 5.2, 5.3, 5.4, 5.5
    
    errorHandler.logInfo('Evaluation', sprintf('Evaluating %s...', modelName));
    
    % Create evaluation engine
    evaluator = EvaluationEngine(net, testDS, ...
        config.labelGeneration.classNames, errorHandler);
    
    % Generate comprehensive evaluation report
    report = evaluator.generateEvaluationReport(modelName, config.paths.resultsDir);
    
    errorHandler.logInfo('Evaluation', sprintf('%s evaluation completed', modelName));
end

function generateVisualizations(reports, histories, modelNames, config, errorHandler)
    % Generate all visualizations and LaTeX tables
    % Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 9.1, 9.2, 9.3
    
    errorHandler.logInfo('Visualization', 'Generating visualizations...');
    
    % Filter out failed models
    validReports = {};
    validHistories = {};
    validModelNames = {};
    
    for i = 1:length(reports)
        if ~isempty(reports{i})
            validReports{end+1} = reports{i};
            validHistories{end+1} = histories{i};
            validModelNames{end+1} = modelNames{i};
        end
    end
    
    if isempty(validReports)
        errorHandler.logWarning('Visualization', 'No valid reports to visualize');
        return;
    end
    
    % Generate confusion matrices for each model
    for i = 1:length(validReports)
        report = validReports{i};
        modelName = validModelNames{i};
        
        outputPath = fullfile(config.paths.figuresDir, ...
            sprintf('confusion_matrix_%s', modelName));
        
        VisualizationEngine.plotConfusionMatrix(...
            report.confusionMatrix, ...
            config.labelGeneration.classNames, ...
            outputPath, ...
            modelName);
    end
    
    % Generate training curves comparison
    if ~isempty(validHistories)
        outputPath = fullfile(config.paths.figuresDir, 'training_curves_comparison');
        VisualizationEngine.plotTrainingCurves(validHistories, validModelNames, outputPath);
    end
    
    % Generate ROC curves for each model
    for i = 1:length(validReports)
        report = validReports{i};
        modelName = validModelNames{i};
        
        outputPath = fullfile(config.paths.figuresDir, ...
            sprintf('roc_curves_%s', modelName));
        
        VisualizationEngine.plotROCCurves(...
            report.roc, ...
            config.labelGeneration.classNames, ...
            outputPath, ...
            modelName);
    end
    
    % Generate inference time comparison
    inferenceTimes = cellfun(@(r) r.inferenceTime, validReports);
    outputPath = fullfile(config.paths.figuresDir, 'inference_time_comparison');
    VisualizationEngine.plotInferenceComparison(inferenceTimes, validModelNames, outputPath);
    
    % Generate LaTeX tables
    
    % Metrics comparison table
    metricsTablePath = fullfile(config.paths.latexDir, 'metrics_comparison_table.tex');
    VisualizationEngine.generateLatexTable(validReports, 'metrics', ...
        metricsTablePath, validModelNames);
    
    % Confusion matrix tables for each model
    for i = 1:length(validReports)
        report = validReports{i};
        modelName = validModelNames{i};
        
        confusionTablePath = fullfile(config.paths.latexDir, ...
            sprintf('confusion_matrix_%s.tex', modelName));
        
        VisualizationEngine.generateLatexTable(report.confusionMatrix, 'confusion', ...
            confusionTablePath, config.labelGeneration.classNames, modelName);
    end
    
    % Summary document
    summaryPath = fullfile(config.paths.latexDir, 'results_summary.tex');
    VisualizationEngine.generateLatexTable(validReports, 'summary', ...
        summaryPath, validModelNames, config.labelGeneration.classNames);
    
    errorHandler.logInfo('Visualization', 'All visualizations generated successfully');
end

function generateFinalSummary(reports, histories, errors, modelNames, config, errorHandler, timestamp)
    % Generate final summary report
    % Requirements: 8.5
    
    errorHandler.logInfo('Summary', 'Generating final summary report...');
    
    % Create summary file
    summaryPath = fullfile(config.paths.resultsDir, ...
        sprintf('execution_summary_%s.txt', timestamp));
    
    fid = fopen(summaryPath, 'w');
    if fid == -1
        error('Cannot create summary file: %s', summaryPath);
    end
    
    try
        % Write header
        fprintf(fid, '================================================================\n');
        fprintf(fid, '  CLASSIFICATION SYSTEM EXECUTION SUMMARY\n');
        fprintf(fid, '================================================================\n\n');
        
        fprintf(fid, 'Execution Date: %s\n', datestr(now));
        fprintf(fid, 'Timestamp: %s\n\n', timestamp);
        
        % Configuration summary
        fprintf(fid, '--- Configuration ---\n');
        fprintf(fid, 'Image Directory: %s\n', config.paths.imageDir);
        fprintf(fid, 'Mask Directory: %s\n', config.paths.maskDir);
        fprintf(fid, 'Output Directory: %s\n', config.paths.outputDir);
        fprintf(fid, 'Label Thresholds: [%.1f, %.1f]\n', ...
            config.labelGeneration.thresholds(1), config.labelGeneration.thresholds(2));
        fprintf(fid, 'Dataset Split Ratios: [%.2f, %.2f, %.2f]\n', ...
            config.dataset.splitRatios(1), config.dataset.splitRatios(2), config.dataset.splitRatios(3));
        fprintf(fid, 'Input Size: [%d, %d]\n', ...
            config.dataset.inputSize(1), config.dataset.inputSize(2));
        fprintf(fid, 'Max Epochs: %d\n', config.training.maxEpochs);
        fprintf(fid, 'Mini-batch Size: %d\n', config.training.miniBatchSize);
        fprintf(fid, 'Initial Learning Rate: %.6f\n\n', config.training.initialLearnRate);
        
        % Model training summary
        fprintf(fid, '--- Model Training Summary ---\n');
        fprintf(fid, 'Total models: %d\n', length(modelNames));
        
        successCount = 0;
        failureCount = 0;
        
        for i = 1:length(modelNames)
            modelName = modelNames{i};
            
            if ~isempty(errors{i})
                fprintf(fid, '\n%s: FAILED\n', modelName);
                fprintf(fid, '  Error: %s\n', errors{i}.message);
                failureCount = failureCount + 1;
            else
                fprintf(fid, '\n%s: SUCCESS\n', modelName);
                
                if ~isempty(histories{i})
                    history = histories{i};
                    fprintf(fid, '  Training epochs: %d\n', length(history.epoch));
                    fprintf(fid, '  Best validation accuracy: %.4f\n', max(history.valAccuracy));
                    fprintf(fid, '  Final training loss: %.4f\n', history.trainLoss(end));
                    fprintf(fid, '  Final validation loss: %.4f\n', history.valLoss(end));
                end
                
                successCount = successCount + 1;
            end
        end
        
        fprintf(fid, '\nSuccessful: %d/%d\n', successCount, length(modelNames));
        fprintf(fid, 'Failed: %d/%d\n\n', failureCount, length(modelNames));
        
        % Evaluation results summary
        fprintf(fid, '--- Evaluation Results Summary ---\n');
        
        if successCount > 0
            % Find best model for each metric
            validReports = {};
            validNames = {};
            
            for i = 1:length(reports)
                if ~isempty(reports{i})
                    validReports{end+1} = reports{i};
                    validNames{end+1} = modelNames{i};
                end
            end
            
            if ~isempty(validReports)
                accuracies = cellfun(@(r) r.metrics.accuracy, validReports);
                f1Scores = cellfun(@(r) r.metrics.macroF1, validReports);
                aucScores = cellfun(@(r) mean(r.roc.auc), validReports);
                inferenceTimes = cellfun(@(r) r.inferenceTime, validReports);
                
                [bestAcc, bestAccIdx] = max(accuracies);
                [bestF1, bestF1Idx] = max(f1Scores);
                [bestAUC, bestAUCIdx] = max(aucScores);
                [fastestTime, fastestIdx] = min(inferenceTimes);
                
                fprintf(fid, '\nBest Accuracy: %s (%.4f / %.2f%%)\n', ...
                    validNames{bestAccIdx}, bestAcc, bestAcc * 100);
                fprintf(fid, 'Best Macro F1: %s (%.4f)\n', ...
                    validNames{bestF1Idx}, bestF1);
                fprintf(fid, 'Best Mean AUC: %s (%.4f)\n', ...
                    validNames{bestAUCIdx}, bestAUC);
                fprintf(fid, 'Fastest Inference: %s (%.2f ms)\n', ...
                    validNames{fastestIdx}, fastestTime);
                
                fprintf(fid, '\n--- Detailed Results by Model ---\n');
                
                for i = 1:length(validReports)
                    report = validReports{i};
                    modelName = validNames{i};
                    
                    fprintf(fid, '\n%s:\n', modelName);
                    fprintf(fid, '  Accuracy: %.4f (%.2f%%)\n', ...
                        report.metrics.accuracy, report.metrics.accuracy * 100);
                    fprintf(fid, '  Macro F1: %.4f\n', report.metrics.macroF1);
                    fprintf(fid, '  Weighted F1: %.4f\n', report.metrics.weightedF1);
                    fprintf(fid, '  Mean AUC: %.4f\n', mean(report.roc.auc));
                    fprintf(fid, '  Inference Time: %.2f ms\n', report.inferenceTime);
                    fprintf(fid, '  Throughput: %.2f images/second\n', report.throughput);
                    
                    % Per-class metrics
                    fprintf(fid, '  Per-class metrics:\n');
                    fields = fieldnames(report.metrics.perClass);
                    for j = 1:length(fields)
                        classMetrics = report.metrics.perClass.(fields{j});
                        fprintf(fid, '    %s: P=%.4f, R=%.4f, F1=%.4f\n', ...
                            config.labelGeneration.classNames{j}, ...
                            classMetrics.precision, classMetrics.recall, classMetrics.f1);
                    end
                end
            end
        else
            fprintf(fid, 'No successful evaluations to report.\n');
        end
        
        % Output files summary
        fprintf(fid, '\n--- Output Files ---\n');
        fprintf(fid, 'Labels CSV: %s\n', config.labelGeneration.outputCSV);
        fprintf(fid, 'Checkpoints: %s\n', config.paths.checkpointDir);
        fprintf(fid, 'Results: %s\n', config.paths.resultsDir);
        fprintf(fid, 'Figures: %s\n', config.paths.figuresDir);
        fprintf(fid, 'LaTeX Tables: %s\n', config.paths.latexDir);
        fprintf(fid, 'Logs: %s\n', config.paths.logsDir);
        
        fprintf(fid, '\n================================================================\n');
        fprintf(fid, '  END OF SUMMARY\n');
        fprintf(fid, '================================================================\n');
        
        fclose(fid);
        
        errorHandler.logInfo('Summary', sprintf('Summary report saved: %s', summaryPath));
        
    catch ME
        if fid ~= -1
            fclose(fid);
        end
        errorHandler.logError('Summary', sprintf('Failed to generate summary: %s', ME.message));
        rethrow(ME);
    end
end

function displayFinalResults(reports, modelNames)
    % Display final results summary in console
    
    fprintf('\n');
    fprintf('========================================================\n');
    fprintf('  FINAL RESULTS SUMMARY\n');
    fprintf('========================================================\n\n');
    
    % Filter valid reports
    validReports = {};
    validNames = {};
    
    for i = 1:length(reports)
        if ~isempty(reports{i})
            validReports{end+1} = reports{i};
            validNames{end+1} = modelNames{i};
        end
    end
    
    if isempty(validReports)
        fprintf('No successful evaluations to display.\n');
        return;
    end
    
    % Display results table
    fprintf('%-20s %10s %10s %10s %10s %15s\n', ...
        'Model', 'Accuracy', 'Macro F1', 'Mean AUC', 'Inf. Time', 'Throughput');
    fprintf('%-20s %10s %10s %10s %10s %15s\n', ...
        '', '(%)', '', '', '(ms)', '(img/s)');
    fprintf('------------------------------------------------------------------------\n');
    
    for i = 1:length(validReports)
        report = validReports{i};
        fprintf('%-20s %9.2f%% %10.4f %10.4f %10.2f %15.2f\n', ...
            validNames{i}, ...
            report.metrics.accuracy * 100, ...
            report.metrics.macroF1, ...
            mean(report.roc.auc), ...
            report.inferenceTime, ...
            report.throughput);
    end
    
    fprintf('------------------------------------------------------------------------\n');
    
    % Highlight best models
    accuracies = cellfun(@(r) r.metrics.accuracy, validReports);
    f1Scores = cellfun(@(r) r.metrics.macroF1, validReports);
    inferenceTimes = cellfun(@(r) r.inferenceTime, validReports);
    
    [~, bestAccIdx] = max(accuracies);
    [~, bestF1Idx] = max(f1Scores);
    [~, fastestIdx] = min(inferenceTimes);
    
    fprintf('\n');
    fprintf('Best Accuracy:      %s (%.2f%%)\n', validNames{bestAccIdx}, accuracies(bestAccIdx) * 100);
    fprintf('Best F1 Score:      %s (%.4f)\n', validNames{bestF1Idx}, f1Scores(bestF1Idx));
    fprintf('Fastest Inference:  %s (%.2f ms)\n', validNames{fastestIdx}, inferenceTimes(fastestIdx));
    fprintf('\n');
end
