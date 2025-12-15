function results = test_complete_pipeline()
% TEST_COMPLETE_PIPELINE End-to-end integration test for classification system
%
% This function tests the complete classification pipeline from label generation
% through training, evaluation, and visualization using synthetic test data.
%
% Requirements tested: 8.1, 8.2, 8.3, 8.4, 8.5
%
% Usage:
%   results = test_complete_pipeline()
%
% Output:
%   results - Struct containing test results and validation status

    fprintf('=== COMPLETE PIPELINE INTEGRATION TEST ===\n\n');
    
    % Initialize results structure
    results = struct();
    results.timestamp = datetime('now');
    results.phases = struct();
    results.allPassed = true;
    
    % Test configuration
    syntheticDataDir = fullfile('tests', 'integration', 'synthetic_data');
    testOutputDir = fullfile('tests', 'integration', 'test_output');
    
    % Ensure synthetic data exists
    if ~exist(fullfile(syntheticDataDir, 'images'), 'dir')
        fprintf('Synthetic data not found. Generating...\n');
        try
            generate_synthetic_test_dataset();
        catch ME
            fprintf('ERROR: Failed to generate synthetic data: %s\n', ME.message);
            results.allPassed = false;
            return;
        end
    end
    
    % Create test output directory
    if ~exist(testOutputDir, 'dir')
        mkdir(testOutputDir);
    end
    
    % Phase 1: Test Label Generation
    fprintf('\n--- Phase 1: Label Generation ---\n');
    try
        [phase1Pass, phase1Results] = testLabelGeneration(syntheticDataDir, testOutputDir);
        results.phases.labelGeneration = phase1Results;
        results.allPassed = results.allPassed && phase1Pass;
        fprintf('Phase 1: %s\n', iif(phase1Pass, 'PASSED', 'FAILED'));
    catch ME
        fprintf('Phase 1: FAILED - %s\n', ME.message);
        results.phases.labelGeneration.error = ME.message;
        results.allPassed = false;
    end
    
    % Phase 2: Test Dataset Preparation
    fprintf('\n--- Phase 2: Dataset Preparation ---\n');
    try
        [phase2Pass, phase2Results] = testDatasetPreparation(syntheticDataDir, testOutputDir);
        results.phases.datasetPreparation = phase2Results;
        results.allPassed = results.allPassed && phase2Pass;
        fprintf('Phase 2: %s\n', iif(phase2Pass, 'PASSED', 'FAILED'));
    catch ME
        fprintf('Phase 2: FAILED - %s\n', ME.message);
        results.phases.datasetPreparation.error = ME.message;
        results.allPassed = false;
    end
    
    % Phase 3: Test Training Pipeline (Quick training with 1 epoch)
    fprintf('\n--- Phase 3: Training Pipeline (Quick Test) ---\n');
    try
        [phase3Pass, phase3Results] = testTrainingPipeline(testOutputDir);
        results.phases.training = phase3Results;
        results.allPassed = results.allPassed && phase3Pass;
        fprintf('Phase 3: %s\n', iif(phase3Pass, 'PASSED', 'FAILED'));
    catch ME
        fprintf('Phase 3: FAILED - %s\n', ME.message);
        results.phases.training.error = ME.message;
        results.allPassed = false;
    end
    
    % Phase 4: Test Evaluation
    fprintf('\n--- Phase 4: Evaluation ---\n');
    try
        [phase4Pass, phase4Results] = testEvaluation(testOutputDir);
        results.phases.evaluation = phase4Results;
        results.allPassed = results.allPassed && phase4Pass;
        fprintf('Phase 4: %s\n', iif(phase4Pass, 'PASSED', 'FAILED'));
    catch ME
        fprintf('Phase 4: FAILED - %s\n', ME.message);
        results.phases.evaluation.error = ME.message;
        results.allPassed = false;
    end
    
    % Phase 5: Test Visualization and Export
    fprintf('\n--- Phase 5: Visualization and Export ---\n');
    try
        [phase5Pass, phase5Results] = testVisualizationExport(testOutputDir);
        results.phases.visualization = phase5Results;
        results.allPassed = results.allPassed && phase5Pass;
        fprintf('Phase 5: %s\n', iif(phase5Pass, 'PASSED', 'FAILED'));
    catch ME
        fprintf('Phase 5: FAILED - %s\n', ME.message);
        results.phases.visualization.error = ME.message;
        results.allPassed = false;
    end
    
    % Generate final report
    fprintf('\n=== PIPELINE TEST SUMMARY ===\n');
    fprintf('Overall Status: %s\n', iif(results.allPassed, '✓ PASSED', '✗ FAILED'));
    fprintf('Timestamp: %s\n', char(results.timestamp));
    fprintf('\nPhase Results:\n');
    fprintf('  1. Label Generation: %s\n', getPhaseStatus(results.phases, 'labelGeneration'));
    fprintf('  2. Dataset Preparation: %s\n', getPhaseStatus(results.phases, 'datasetPreparation'));
    fprintf('  3. Training Pipeline: %s\n', getPhaseStatus(results.phases, 'training'));
    fprintf('  4. Evaluation: %s\n', getPhaseStatus(results.phases, 'evaluation'));
    fprintf('  5. Visualization: %s\n', getPhaseStatus(results.phases, 'visualization'));
    
    % Save results
    resultsFile = fullfile(testOutputDir, 'pipeline_test_results.mat');
    save(resultsFile, 'results');
    fprintf('\nResults saved to: %s\n', resultsFile);
    
    % Generate text report
    reportFile = fullfile(testOutputDir, 'pipeline_test_report.txt');
    generateTextReport(results, reportFile);
    fprintf('Report saved to: %s\n', reportFile);
end

function [passed, phaseResults] = testLabelGeneration(dataDir, outputDir)
% Test label generation phase
    
    phaseResults = struct();
    passed = true;
    
    maskDir = fullfile(dataDir, 'masks');
    labelCSV = fullfile(outputDir, 'test_labels.csv');
    
    % Generate labels
    fprintf('  Generating labels from masks...\n');
    labels = LabelGenerator.generateLabelsFromMasks(maskDir, labelCSV, [10, 30]);
    
    % Validate CSV exists
    if ~exist(labelCSV, 'file')
        fprintf('  ERROR: Label CSV not created\n');
        passed = false;
        return;
    end
    
    % Validate CSV content
    labelData = readtable(labelCSV);
    phaseResults.numLabels = height(labelData);
    phaseResults.labelFile = labelCSV;
    
    % Check expected columns
    expectedCols = {'filename', 'corroded_percentage', 'severity_class'};
    if ~all(ismember(expectedCols, labelData.Properties.VariableNames))
        fprintf('  ERROR: CSV missing expected columns\n');
        passed = false;
        return;
    end
    
    % Validate class distribution
    class0Count = sum(labelData.severity_class == 0);
    class1Count = sum(labelData.severity_class == 1);
    class2Count = sum(labelData.severity_class == 2);
    
    phaseResults.class0Count = class0Count;
    phaseResults.class1Count = class1Count;
    phaseResults.class2Count = class2Count;
    
    fprintf('  Labels generated: %d total\n', phaseResults.numLabels);
    fprintf('    Class 0: %d, Class 1: %d, Class 2: %d\n', ...
        class0Count, class1Count, class2Count);
    
    % Validate reasonable distribution (should be ~10 per class)
    if class0Count < 5 || class1Count < 5 || class2Count < 5
        fprintf('  WARNING: Unbalanced class distribution\n');
    end
    
    phaseResults.passed = passed;
end

function [passed, phaseResults] = testDatasetPreparation(dataDir, outputDir)
% Test dataset preparation phase
    
    phaseResults = struct();
    passed = true;
    
    imageDir = fullfile(dataDir, 'images');
    labelCSV = fullfile(outputDir, 'test_labels.csv');
    
    % Create config
    config = struct();
    config.imageDir = imageDir;
    config.labelCSV = labelCSV;
    config.splitRatios = [0.7, 0.15, 0.15];
    config.inputSize = [224, 224];
    config.augmentation = false; % Disable for testing
    
    % Create DatasetManager
    fprintf('  Creating DatasetManager...\n');
    dm = DatasetManager(config);
    
    % Prepare datasets
    fprintf('  Preparing train/val/test splits...\n');
    [trainDS, valDS, testDS] = dm.prepareDatasets();
    
    % Get statistics
    stats = dm.getDatasetStatistics();
    phaseResults.stats = stats;
    
    fprintf('  Dataset splits:\n');
    fprintf('    Train: %d samples\n', stats.trainCount);
    fprintf('    Val: %d samples\n', stats.valCount);
    fprintf('    Test: %d samples\n', stats.testCount);
    
    % Validate splits
    totalSamples = stats.trainCount + stats.valCount + stats.testCount;
    if totalSamples == 0
        fprintf('  ERROR: No samples in dataset\n');
        passed = false;
        return;
    end
    
    % Check split ratios are approximately correct
    expectedTrain = round(totalSamples * 0.7);
    if abs(stats.trainCount - expectedTrain) > 3
        fprintf('  WARNING: Train split ratio off target\n');
    end
    
    phaseResults.passed = passed;
end

function [passed, phaseResults] = testTrainingPipeline(outputDir)
% Test training pipeline with minimal epochs
    
    phaseResults = struct();
    passed = true;
    
    % Load prepared datasets
    imageDir = fullfile('tests', 'integration', 'synthetic_data', 'images');
    labelCSV = fullfile(outputDir, 'test_labels.csv');
    
    config = struct();
    config.imageDir = imageDir;
    config.labelCSV = labelCSV;
    config.splitRatios = [0.7, 0.15, 0.15];
    config.inputSize = [224, 224];
    config.augmentation = false;
    
    dm = DatasetManager(config);
    [trainDS, valDS, ~] = dm.prepareDatasets();
    
    % Create a simple model for testing
    fprintf('  Creating test model (Custom CNN)...\n');
    net = ModelFactory.createCustomCNN(3, [224, 224]);
    
    % Configure minimal training
    trainConfig = struct();
    trainConfig.maxEpochs = 2; % Very short for testing
    trainConfig.miniBatchSize = 4;
    trainConfig.initialLearnRate = 1e-3;
    trainConfig.validationPatience = 10;
    trainConfig.checkpointDir = fullfile(outputDir, 'checkpoints');
    
    % Create training engine
    fprintf('  Training for %d epochs (test mode)...\n', trainConfig.maxEpochs);
    engine = TrainingEngine(net, trainConfig);
    
    % Train
    tic;
    [trainedNet, history] = engine.train(trainDS, valDS);
    trainingTime = toc;
    
    phaseResults.trainingTime = trainingTime;
    phaseResults.epochs = length(history.epoch);
    phaseResults.finalTrainLoss = history.trainLoss(end);
    phaseResults.finalValLoss = history.valLoss(end);
    
    fprintf('  Training completed in %.2f seconds\n', trainingTime);
    fprintf('  Final train loss: %.4f\n', history.trainLoss(end));
    fprintf('  Final val loss: %.4f\n', history.valLoss(end));
    
    % Validate checkpoint was saved
    checkpointFile = fullfile(trainConfig.checkpointDir, 'best_model.mat');
    if ~exist(checkpointFile, 'file')
        fprintf('  WARNING: Checkpoint file not found\n');
    else
        phaseResults.checkpointSaved = true;
    end
    
    % Save trained model for evaluation phase
    testModelFile = fullfile(outputDir, 'test_trained_model.mat');
    save(testModelFile, 'trainedNet', 'history');
    phaseResults.modelFile = testModelFile;
    
    phaseResults.passed = passed;
end

function [passed, phaseResults] = testEvaluation(outputDir)
% Test evaluation phase
    
    phaseResults = struct();
    passed = true;
    
    % Load trained model
    modelFile = fullfile(outputDir, 'test_trained_model.mat');
    if ~exist(modelFile, 'file')
        fprintf('  ERROR: Trained model not found\n');
        passed = false;
        return;
    end
    
    load(modelFile, 'trainedNet');
    
    % Load test dataset
    imageDir = fullfile('tests', 'integration', 'synthetic_data', 'images');
    labelCSV = fullfile(outputDir, 'test_labels.csv');
    
    config = struct();
    config.imageDir = imageDir;
    config.labelCSV = labelCSV;
    config.splitRatios = [0.7, 0.15, 0.15];
    config.inputSize = [224, 224];
    config.augmentation = false;
    
    dm = DatasetManager(config);
    [~, ~, testDS] = dm.prepareDatasets();
    
    % Create evaluation engine
    fprintf('  Creating evaluation engine...\n');
    classNames = {'None/Light', 'Moderate', 'Severe'};
    evalEngine = EvaluationEngine(trainedNet, testDS, classNames);
    
    % Compute metrics
    fprintf('  Computing metrics...\n');
    metrics = evalEngine.computeMetrics();
    phaseResults.metrics = metrics;
    
    fprintf('  Overall Accuracy: %.4f\n', metrics.accuracy);
    fprintf('  Macro F1: %.4f\n', metrics.macroF1);
    
    % Generate confusion matrix
    fprintf('  Generating confusion matrix...\n');
    confMat = evalEngine.generateConfusionMatrix();
    phaseResults.confusionMatrix = confMat;
    
    % Measure inference speed
    fprintf('  Measuring inference speed...\n');
    inferenceTime = evalEngine.measureInferenceSpeed(10);
    phaseResults.inferenceTime = inferenceTime;
    
    fprintf('  Inference time: %.2f ms/image\n', inferenceTime);
    
    % Save evaluation results
    evalResultsFile = fullfile(outputDir, 'evaluation_results.mat');
    save(evalResultsFile, 'metrics', 'confMat', 'inferenceTime');
    phaseResults.resultsFile = evalResultsFile;
    
    phaseResults.passed = passed;
end

function [passed, phaseResults] = testVisualizationExport(outputDir)
% Test visualization and export phase
    
    phaseResults = struct();
    passed = true;
    
    % Load evaluation results
    evalResultsFile = fullfile(outputDir, 'evaluation_results.mat');
    if ~exist(evalResultsFile, 'file')
        fprintf('  ERROR: Evaluation results not found\n');
        passed = false;
        return;
    end
    
    load(evalResultsFile, 'metrics', 'confMat', 'inferenceTime');
    
    % Create figures directory
    figuresDir = fullfile(outputDir, 'figures');
    if ~exist(figuresDir, 'dir')
        mkdir(figuresDir);
    end
    
    % Test confusion matrix visualization
    fprintf('  Generating confusion matrix plot...\n');
    classNames = {'None/Light', 'Moderate', 'Severe'};
    confMatFile = fullfile(figuresDir, 'test_confusion_matrix.png');
    
    try
        VisualizationEngine.plotConfusionMatrix(confMat, classNames, confMatFile);
        if exist(confMatFile, 'file')
            phaseResults.confusionMatrixPlot = confMatFile;
            fprintf('    ✓ Confusion matrix saved\n');
        else
            fprintf('    WARNING: Confusion matrix file not created\n');
        end
    catch ME
        fprintf('    ERROR: Failed to create confusion matrix: %s\n', ME.message);
        passed = false;
    end
    
    % Test training curves (using dummy data)
    fprintf('  Generating training curves plot...\n');
    history = struct();
    history.epoch = 1:2;
    history.trainLoss = [0.8, 0.6];
    history.valLoss = [0.85, 0.65];
    history.trainAccuracy = [0.6, 0.7];
    history.valAccuracy = [0.58, 0.68];
    
    histories = {history};
    modelNames = {'TestModel'};
    curvesFile = fullfile(figuresDir, 'test_training_curves.png');
    
    try
        VisualizationEngine.plotTrainingCurves(histories, modelNames, curvesFile);
        if exist(curvesFile, 'file')
            phaseResults.trainingCurvesPlot = curvesFile;
            fprintf('    ✓ Training curves saved\n');
        else
            fprintf('    WARNING: Training curves file not created\n');
        end
    catch ME
        fprintf('    ERROR: Failed to create training curves: %s\n', ME.message);
        passed = false;
    end
    
    % Count generated files
    figFiles = dir(fullfile(figuresDir, '*.png'));
    phaseResults.numFigures = length(figFiles);
    fprintf('  Total figures generated: %d\n', phaseResults.numFigures);
    
    phaseResults.passed = passed;
end

function status = getPhaseStatus(phases, phaseName)
% Get status string for a phase
    if isfield(phases, phaseName)
        if isfield(phases.(phaseName), 'passed') && phases.(phaseName).passed
            status = '✓ PASSED';
        else
            status = '✗ FAILED';
        end
    else
        status = '- NOT RUN';
    end
end

function generateTextReport(results, reportFile)
% Generate a text report of test results
    
    fid = fopen(reportFile, 'w');
    
    fprintf(fid, '=== COMPLETE PIPELINE INTEGRATION TEST REPORT ===\n\n');
    fprintf(fid, 'Timestamp: %s\n', char(results.timestamp));
    fprintf(fid, 'Overall Status: %s\n\n', iif(results.allPassed, 'PASSED', 'FAILED'));
    
    fprintf(fid, '--- Phase Results ---\n\n');
    
    % Label Generation
    if isfield(results.phases, 'labelGeneration')
        fprintf(fid, '1. Label Generation: %s\n', iif(results.phases.labelGeneration.passed, 'PASSED', 'FAILED'));
        fprintf(fid, '   Labels generated: %d\n', results.phases.labelGeneration.numLabels);
        fprintf(fid, '   Class distribution: 0=%d, 1=%d, 2=%d\n\n', ...
            results.phases.labelGeneration.class0Count, ...
            results.phases.labelGeneration.class1Count, ...
            results.phases.labelGeneration.class2Count);
    end
    
    % Dataset Preparation
    if isfield(results.phases, 'datasetPreparation')
        fprintf(fid, '2. Dataset Preparation: %s\n', iif(results.phases.datasetPreparation.passed, 'PASSED', 'FAILED'));
        stats = results.phases.datasetPreparation.stats;
        fprintf(fid, '   Train: %d, Val: %d, Test: %d\n\n', ...
            stats.trainCount, stats.valCount, stats.testCount);
    end
    
    % Training
    if isfield(results.phases, 'training')
        fprintf(fid, '3. Training Pipeline: %s\n', iif(results.phases.training.passed, 'PASSED', 'FAILED'));
        fprintf(fid, '   Training time: %.2f seconds\n', results.phases.training.trainingTime);
        fprintf(fid, '   Epochs: %d\n', results.phases.training.epochs);
        fprintf(fid, '   Final train loss: %.4f\n', results.phases.training.finalTrainLoss);
        fprintf(fid, '   Final val loss: %.4f\n\n', results.phases.training.finalValLoss);
    end
    
    % Evaluation
    if isfield(results.phases, 'evaluation')
        fprintf(fid, '4. Evaluation: %s\n', iif(results.phases.evaluation.passed, 'PASSED', 'FAILED'));
        fprintf(fid, '   Accuracy: %.4f\n', results.phases.evaluation.metrics.accuracy);
        fprintf(fid, '   Macro F1: %.4f\n', results.phases.evaluation.metrics.macroF1);
        fprintf(fid, '   Inference time: %.2f ms/image\n\n', results.phases.evaluation.inferenceTime);
    end
    
    % Visualization
    if isfield(results.phases, 'visualization')
        fprintf(fid, '5. Visualization: %s\n', iif(results.phases.visualization.passed, 'PASSED', 'FAILED'));
        fprintf(fid, '   Figures generated: %d\n\n', results.phases.visualization.numFigures);
    end
    
    fprintf(fid, '--- End of Report ---\n');
    fclose(fid);
end

function result = iif(condition, trueVal, falseVal)
% Inline if function
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end
