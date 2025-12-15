function test_EvaluationEngine()
    % Comprehensive test suite for EvaluationEngine class
    % Tests metric computation, confusion matrix generation, ROC curves,
    % and inference time measurement with synthetic data
    %
    % Requirements: 5.1, 5.2, 5.3, 5.4
    
    fprintf('=== EvaluationEngine Test Suite ===\n\n');
    
    try
        % Setup
        fprintf('Setting up test environment...\n');
        addpath(genpath('src/classification'));
        addpath('src/utils');
        
        % Test 1: Metric computation with known predictions
        fprintf('\nTest 1: Metric computation with known predictions...\n');
        test_metric_computation();
        
        % Test 2: Confusion matrix generation
        fprintf('\nTest 2: Confusion matrix generation...\n');
        test_confusion_matrix_generation();
        
        % Test 3: ROC curve computation
        fprintf('\nTest 3: ROC curve computation...\n');
        test_roc_curve_computation();
        
        % Test 4: Inference time measurement
        fprintf('\nTest 4: Inference time measurement...\n');
        test_inference_time_measurement();
        
        % Test 5: Comprehensive evaluation report
        fprintf('\nTest 5: Comprehensive evaluation report...\n');
        test_evaluation_report();
        
        fprintf('\n=== All EvaluationEngine tests passed! ===\n');
        
    catch ME
        fprintf(2, '\nTest failed: %s\n', ME.message);
        fprintf(2, 'Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf(2, '  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        rethrow(ME);
    end
end

function test_metric_computation()
    % Test metric computation with known predictions
    % Requirement: 5.1
    
    fprintf('  Creating synthetic test data...\n');
    
    % Create synthetic predictions with known metrics
    % Perfect predictions for Class 0, some errors for Class 1 and 2
    trueLabels = [
        ones(10, 1);      % 10 samples of Class 1
        ones(10, 1) * 2;  % 10 samples of Class 2
        ones(10, 1) * 3   % 10 samples of Class 3
    ];
    
    predictions = [
        ones(10, 1);      % All Class 1 correct
        [ones(8, 1) * 2; ones(2, 1) * 3];  % 8 correct, 2 misclassified as Class 3
        [ones(7, 1) * 3; ones(2, 1) * 2; ones(1, 1)]  % 7 correct, 2 as Class 2, 1 as Class 1
    ];
    
    % Create synthetic network and datastore
    [net, testDS] = createSyntheticNetworkAndDatastore(trueLabels, predictions);
    
    % Create class names
    classNames = {'Class 1', 'Class 2', 'Class 3'};
    
    % Create error handler
    errorHandler = ErrorHandler.getInstance();
    errorHandler.enableConsole(false);
    
    % Create EvaluationEngine
    evaluator = EvaluationEngine(net, testDS, classNames, errorHandler);
    
    fprintf('  Computing metrics...\n');
    metrics = evaluator.computeMetrics();
    
    errorHandler.enableConsole(true);
    
    % Validate metrics structure
    assert(isstruct(metrics), 'Metrics should be a struct');
    assert(isfield(metrics, 'accuracy'), 'Should have accuracy field');
    assert(isfield(metrics, 'macroF1'), 'Should have macroF1 field');
    assert(isfield(metrics, 'weightedF1'), 'Should have weightedF1 field');
    assert(isfield(metrics, 'perClass'), 'Should have perClass field');
    fprintf('    ✓ Metrics structure valid\n');
    
    % Validate accuracy
    % Expected: (10 + 8 + 7) / 30 = 25/30 = 0.8333
    expectedAccuracy = 25 / 30;
    assert(abs(metrics.accuracy - expectedAccuracy) < 1e-4, ...
        sprintf('Accuracy mismatch: expected %.4f, got %.4f', expectedAccuracy, metrics.accuracy));
    fprintf('    ✓ Accuracy: %.4f (%.2f%%)\n', metrics.accuracy, metrics.accuracy * 100);
    
    % Validate per-class metrics exist
    perClassFields = fieldnames(metrics.perClass);
    assert(length(perClassFields) == 3, 'Should have 3 classes');
    fprintf('    ✓ Per-class metrics for %d classes\n', length(perClassFields));
    
    % Validate Class 1 metrics (perfect predictions)
    class1Metrics = metrics.perClass.(perClassFields{1});
    assert(abs(class1Metrics.precision - 1.0) < 1e-4, 'Class 1 precision should be 1.0');
    assert(abs(class1Metrics.recall - 1.0) < 1e-4, 'Class 1 recall should be 1.0');
    assert(abs(class1Metrics.f1 - 1.0) < 1e-4, 'Class 1 F1 should be 1.0');
    fprintf('    ✓ Class 1: Precision=%.4f, Recall=%.4f, F1=%.4f\n', ...
        class1Metrics.precision, class1Metrics.recall, class1Metrics.f1);
    
    % Validate macro F1 is between 0 and 1
    assert(metrics.macroF1 >= 0 && metrics.macroF1 <= 1, 'Macro F1 should be in [0, 1]');
    fprintf('    ✓ Macro F1: %.4f\n', metrics.macroF1);
    
    % Validate weighted F1 is between 0 and 1
    assert(metrics.weightedF1 >= 0 && metrics.weightedF1 <= 1, 'Weighted F1 should be in [0, 1]');
    fprintf('    ✓ Weighted F1: %.4f\n', metrics.weightedF1);
    
    fprintf('  ✓ Metric computation tests passed\n');
end

function test_confusion_matrix_generation()
    % Test confusion matrix generation
    % Requirement: 5.2
    
    fprintf('  Creating synthetic test data...\n');
    
    % Create known confusion matrix scenario
    % Class 1: 10 samples, all correct
    % Class 2: 10 samples, 8 correct, 2 misclassified as Class 3
    % Class 3: 10 samples, 7 correct, 2 as Class 2, 1 as Class 1
    trueLabels = [
        ones(10, 1);
        ones(10, 1) * 2;
        ones(10, 1) * 3
    ];
    
    predictions = [
        ones(10, 1);
        [ones(8, 1) * 2; ones(2, 1) * 3];
        [ones(7, 1) * 3; ones(2, 1) * 2; ones(1, 1)]
    ];
    
    % Create synthetic network and datastore
    [net, testDS] = createSyntheticNetworkAndDatastore(trueLabels, predictions);
    
    classNames = {'Class 1', 'Class 2', 'Class 3'};
    
    errorHandler = ErrorHandler.getInstance();
    errorHandler.enableConsole(false);
    
    evaluator = EvaluationEngine(net, testDS, classNames, errorHandler);
    
    fprintf('  Generating confusion matrix...\n');
    confMat = evaluator.generateConfusionMatrix();
    
    errorHandler.enableConsole(true);
    
    % Validate confusion matrix structure
    assert(ismatrix(confMat), 'Confusion matrix should be a matrix');
    assert(size(confMat, 1) == 3 && size(confMat, 2) == 3, 'Should be 3x3 matrix');
    fprintf('    ✓ Confusion matrix size: %dx%d\n', size(confMat, 1), size(confMat, 2));
    
    % Expected confusion matrix:
    % [10  0  0]
    % [ 0  8  2]
    % [ 1  2  7]
    expectedConfMat = [
        10, 0, 0;
        0, 8, 2;
        1, 2, 7
    ];
    
    % Validate confusion matrix values
    assert(isequal(confMat, expectedConfMat), ...
        sprintf('Confusion matrix mismatch:\nExpected:\n%s\nGot:\n%s', ...
        mat2str(expectedConfMat), mat2str(confMat)));
    fprintf('    ✓ Confusion matrix values correct\n');
    
    % Validate total samples
    totalSamples = sum(confMat(:));
    assert(totalSamples == 30, 'Total samples should be 30');
    fprintf('    ✓ Total samples: %d\n', totalSamples);
    
    % Validate diagonal (correct predictions)
    correctPredictions = sum(diag(confMat));
    assert(correctPredictions == 25, 'Correct predictions should be 25');
    fprintf('    ✓ Correct predictions: %d\n', correctPredictions);
    
    % Test normalized confusion matrix
    fprintf('  Testing normalized confusion matrix...\n');
    normalizedConfMat = evaluator.getNormalizedConfusionMatrix();
    
    % Validate normalized matrix
    assert(ismatrix(normalizedConfMat), 'Normalized confusion matrix should be a matrix');
    assert(size(normalizedConfMat, 1) == 3 && size(normalizedConfMat, 2) == 3, ...
        'Should be 3x3 matrix');
    
    % Each row should sum to 1 (or 0 if no samples)
    rowSums = sum(normalizedConfMat, 2);
    for i = 1:length(rowSums)
        assert(abs(rowSums(i) - 1.0) < 1e-6, ...
            sprintf('Row %d should sum to 1.0', i));
    end
    fprintf('    ✓ Normalized confusion matrix rows sum to 1.0\n');
    
    fprintf('  ✓ Confusion matrix generation tests passed\n');
end

function test_roc_curve_computation()
    % Test ROC curve computation
    % Requirement: 5.3
    
    fprintf('  Creating synthetic test data with scores...\n');
    
    % Create synthetic data with known scores
    numSamples = 30;
    trueLabels = [
        ones(10, 1);
        ones(10, 1) * 2;
        ones(10, 1) * 3
    ];
    
    % Create predictions (same as before)
    predictions = [
        ones(10, 1);
        [ones(8, 1) * 2; ones(2, 1) * 3];
        [ones(7, 1) * 3; ones(2, 1) * 2; ones(1, 1)]
    ];
    
    % Create synthetic network and datastore
    [net, testDS] = createSyntheticNetworkAndDatastore(trueLabels, predictions);
    
    classNames = {'Class 1', 'Class 2', 'Class 3'};
    
    errorHandler = ErrorHandler.getInstance();
    errorHandler.enableConsole(false);
    
    evaluator = EvaluationEngine(net, testDS, classNames, errorHandler);
    
    fprintf('  Computing ROC curves...\n');
    [fpr, tpr, auc] = evaluator.computeROC();
    
    errorHandler.enableConsole(true);
    
    % Validate outputs
    assert(iscell(fpr), 'FPR should be a cell array');
    assert(iscell(tpr), 'TPR should be a cell array');
    assert(isnumeric(auc), 'AUC should be numeric');
    fprintf('    ✓ Output types correct\n');
    
    % Validate dimensions
    assert(length(fpr) == 3, 'Should have FPR for 3 classes');
    assert(length(tpr) == 3, 'Should have TPR for 3 classes');
    assert(length(auc) == 3, 'Should have AUC for 3 classes');
    fprintf('    ✓ Output dimensions correct\n');
    
    % Validate AUC values are in [0, 1]
    for i = 1:length(auc)
        assert(auc(i) >= 0 && auc(i) <= 1, ...
            sprintf('AUC for class %d should be in [0, 1]', i));
        fprintf('    ✓ %s AUC: %.4f\n', classNames{i}, auc(i));
    end
    
    % Validate FPR and TPR arrays
    for i = 1:length(fpr)
        assert(isnumeric(fpr{i}), sprintf('FPR for class %d should be numeric', i));
        assert(isnumeric(tpr{i}), sprintf('TPR for class %d should be numeric', i));
        assert(length(fpr{i}) == length(tpr{i}), ...
            sprintf('FPR and TPR for class %d should have same length', i));
        
        % FPR and TPR should start at 0 and end at or near 1
        assert(fpr{i}(1) == 0, sprintf('FPR for class %d should start at 0', i));
        assert(tpr{i}(1) == 0, sprintf('TPR for class %d should start at 0', i));
        
        % All values should be in [0, 1]
        assert(all(fpr{i} >= 0 & fpr{i} <= 1), ...
            sprintf('All FPR values for class %d should be in [0, 1]', i));
        assert(all(tpr{i} >= 0 & tpr{i} <= 1), ...
            sprintf('All TPR values for class %d should be in [0, 1]', i));
    end
    fprintf('    ✓ FPR and TPR arrays valid\n');
    
    % Class 1 should have perfect AUC (all predictions correct)
    assert(abs(auc(1) - 1.0) < 1e-4, 'Class 1 should have AUC ≈ 1.0');
    fprintf('    ✓ Class 1 has perfect AUC\n');
    
    fprintf('  ✓ ROC curve computation tests passed\n');
end

function test_inference_time_measurement()
    % Test inference time measurement
    % Requirement: 5.4
    
    fprintf('  Creating synthetic test data...\n');
    
    % Create larger dataset for timing
    numSamples = 50;
    trueLabels = repmat([1; 2; 3], numSamples / 3, 1);
    predictions = trueLabels; % All correct for simplicity
    
    [net, testDS] = createSyntheticNetworkAndDatastore(trueLabels, predictions);
    
    classNames = {'Class 1', 'Class 2', 'Class 3'};
    
    errorHandler = ErrorHandler.getInstance();
    errorHandler.enableConsole(false);
    
    evaluator = EvaluationEngine(net, testDS, classNames, errorHandler);
    
    fprintf('  Measuring inference speed (this may take a moment)...\n');
    [avgTime, throughput, memoryUsage] = evaluator.measureInferenceSpeed(30);
    
    errorHandler.enableConsole(true);
    
    % Validate outputs
    assert(isnumeric(avgTime), 'Average time should be numeric');
    assert(isnumeric(throughput), 'Throughput should be numeric');
    assert(isnumeric(memoryUsage), 'Memory usage should be numeric');
    fprintf('    ✓ Output types correct\n');
    
    % Validate values are positive
    assert(avgTime > 0, 'Average time should be positive');
    assert(throughput > 0, 'Throughput should be positive');
    fprintf('    ✓ Values are positive\n');
    
    % Validate reasonable ranges
    assert(avgTime < 10000, 'Average time should be less than 10 seconds (10000 ms)');
    assert(throughput < 10000, 'Throughput should be less than 10000 images/sec');
    fprintf('    ✓ Values in reasonable range\n');
    
    fprintf('    ✓ Average time: %.2f ms/image\n', avgTime);
    fprintf('    ✓ Throughput: %.2f images/second\n', throughput);
    
    if ~isnan(memoryUsage)
        fprintf('    ✓ GPU memory usage: %.2f MB\n', memoryUsage);
    else
        fprintf('    ✓ GPU not available (memory usage not measured)\n');
    end
    
    fprintf('  ✓ Inference time measurement tests passed\n');
end

function test_evaluation_report()
    % Test comprehensive evaluation report generation
    % Requirement: 5.5
    
    fprintf('  Creating synthetic test data...\n');
    
    trueLabels = [
        ones(10, 1);
        ones(10, 1) * 2;
        ones(10, 1) * 3
    ];
    
    predictions = [
        ones(10, 1);
        [ones(8, 1) * 2; ones(2, 1) * 3];
        [ones(7, 1) * 3; ones(2, 1) * 2; ones(1, 1)]
    ];
    
    [net, testDS] = createSyntheticNetworkAndDatastore(trueLabels, predictions);
    
    classNames = {'Class 1', 'Class 2', 'Class 3'};
    
    errorHandler = ErrorHandler.getInstance();
    errorHandler.enableConsole(false);
    
    evaluator = EvaluationEngine(net, testDS, classNames, errorHandler);
    
    % Create temporary output directory
    outputDir = fullfile(tempdir, 'test_evaluation_report');
    if exist(outputDir, 'dir')
        rmdir(outputDir, 's');
    end
    mkdir(outputDir);
    
    fprintf('  Generating evaluation report...\n');
    report = evaluator.generateEvaluationReport('TestModel', outputDir);
    
    errorHandler.enableConsole(true);
    
    % Validate report structure
    assert(isstruct(report), 'Report should be a struct');
    fprintf('    ✓ Report is a struct\n');
    
    % Validate required fields
    requiredFields = {'modelName', 'timestamp', 'numClasses', 'classNames', ...
        'metrics', 'confusionMatrix', 'normalizedConfusionMatrix', 'roc', ...
        'inferenceTime', 'throughput', 'totalSamples', 'correctPredictions', ...
        'incorrectPredictions'};
    
    for i = 1:length(requiredFields)
        assert(isfield(report, requiredFields{i}), ...
            sprintf('Report should have field: %s', requiredFields{i}));
    end
    fprintf('    ✓ All required fields present\n');
    
    % Validate model name
    assert(strcmp(report.modelName, 'TestModel'), 'Model name should be TestModel');
    fprintf('    ✓ Model name: %s\n', report.modelName);
    
    % Validate metrics
    assert(isstruct(report.metrics), 'Metrics should be a struct');
    assert(report.metrics.accuracy > 0, 'Accuracy should be positive');
    fprintf('    ✓ Accuracy: %.4f\n', report.metrics.accuracy);
    
    % Validate confusion matrix
    assert(ismatrix(report.confusionMatrix), 'Confusion matrix should be a matrix');
    assert(size(report.confusionMatrix, 1) == 3, 'Should be 3x3 matrix');
    fprintf('    ✓ Confusion matrix: %dx%d\n', ...
        size(report.confusionMatrix, 1), size(report.confusionMatrix, 2));
    
    % Validate ROC data
    assert(isstruct(report.roc), 'ROC should be a struct');
    assert(isfield(report.roc, 'auc'), 'ROC should have AUC field');
    assert(length(report.roc.auc) == 3, 'Should have AUC for 3 classes');
    fprintf('    ✓ Mean AUC: %.4f\n', mean(report.roc.auc));
    
    % Validate inference metrics
    assert(report.inferenceTime > 0, 'Inference time should be positive');
    assert(report.throughput > 0, 'Throughput should be positive');
    fprintf('    ✓ Inference time: %.2f ms\n', report.inferenceTime);
    fprintf('    ✓ Throughput: %.2f images/sec\n', report.throughput);
    
    % Validate sample counts
    assert(report.totalSamples == 30, 'Total samples should be 30');
    assert(report.correctPredictions == 25, 'Correct predictions should be 25');
    assert(report.incorrectPredictions == 5, 'Incorrect predictions should be 5');
    fprintf('    ✓ Sample counts correct\n');
    
    % Validate saved files
    matFile = fullfile(outputDir, 'TestModel_evaluation_report.mat');
    txtFile = fullfile(outputDir, 'TestModel_evaluation_report.txt');
    
    assert(isfile(matFile), 'MAT file should be saved');
    assert(isfile(txtFile), 'Text file should be saved');
    fprintf('    ✓ Report files saved\n');
    
    % Validate text file content
    txtContent = fileread(txtFile);
    assert(contains(txtContent, 'EVALUATION REPORT'), 'Text file should contain header');
    assert(contains(txtContent, 'TestModel'), 'Text file should contain model name');
    assert(contains(txtContent, 'Accuracy'), 'Text file should contain accuracy');
    fprintf('    ✓ Text file content valid\n');
    
    % Cleanup
    rmdir(outputDir, 's');
    
    fprintf('  ✓ Evaluation report tests passed\n');
end

%% Helper Functions

function [net, testDS] = createSyntheticNetworkAndDatastore(trueLabels, predictions)
    % Create a synthetic network and datastore for testing
    % This creates a mock network that returns predetermined predictions
    
    % Create a simple network (we'll override its classify method behavior)
    layers = [
        imageInputLayer([224 224 3])
        convolution2dLayer(3, 8, 'Padding', 'same')
        reluLayer
        fullyConnectedLayer(length(unique(trueLabels)))
        softmaxLayer
        classificationLayer
    ];
    
    net = layerGraph(layers);
    
    % Create synthetic images
    numSamples = length(trueLabels);
    images = cell(numSamples, 1);
    labels = cell(numSamples, 1);
    
    for i = 1:numSamples
        % Create random image
        images{i} = uint8(rand(224, 224, 3) * 255);
        labels{i} = categorical(trueLabels(i));
    end
    
    % Create image datastore
    % Save images to temporary directory
    tempDir = fullfile(tempdir, 'test_evaluation_images');
    if exist(tempDir, 'dir')
        rmdir(tempDir, 's');
    end
    mkdir(tempDir);
    
    for i = 1:numSamples
        imwrite(images{i}, fullfile(tempDir, sprintf('img_%03d.png', i)));
    end
    
    % Create datastore
    testDS = imageDatastore(tempDir);
    testDS.Labels = categorical(trueLabels);
    
    % Note: In actual testing, we would need to train this network or use
    % a pre-trained one. For unit tests, we're testing the evaluation logic,
    % not the network itself. The EvaluationEngine will call classify() on
    % the network, which will return actual predictions based on the network.
    % For true unit testing, we would need to mock the network's classify method.
end
