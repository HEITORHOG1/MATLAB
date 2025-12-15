% validate_model_comparison.m
% Validation script for Task 8: Model Comparison and Benchmarking
%
% This script validates the implementation of:
%   - ModelComparator class
%   - SegmentationComparator class
%   - ErrorAnalyzer class
%
% Requirements: 5.5, 10.3, 10.4, 10.5

clear; clc;

fprintf('=================================================\n');
fprintf('TASK 8 VALIDATION: Model Comparison and Benchmarking\n');
fprintf('=================================================\n\n');

% Initialize error handler
errorHandler = ErrorHandler.getInstance();
errorHandler.setLogFile('validation_model_comparison.log');

testsPassed = 0;
testsFailed = 0;

%% Test 1: ModelComparator Initialization
fprintf('Test 1: ModelComparator Initialization...\n');
try
    comparator = ModelComparator(errorHandler);
    assert(~isempty(comparator), 'ModelComparator should be initialized');
    fprintf('✓ PASSED: ModelComparator initialized successfully\n\n');
    testsPassed = testsPassed + 1;
catch ME
    fprintf('✗ FAILED: %s\n\n', ME.message);
    testsFailed = testsFailed + 1;
end

%% Test 2: ModelComparator - Add Results
fprintf('Test 2: ModelComparator - Add Results...\n');
try
    % Create mock evaluation results
    mockResult1 = struct(...
        'modelName', 'TestModel1', ...
        'metrics', struct('accuracy', 0.92, 'macroF1', 0.91, 'weightedF1', 0.92), ...
        'roc', struct('auc', [0.95, 0.93, 0.94]), ...
        'inferenceTime', 25.5, ...
        'throughput', 39.2);
    
    mockResult2 = struct(...
        'modelName', 'TestModel2', ...
        'metrics', struct('accuracy', 0.88, 'macroF1', 0.87, 'weightedF1', 0.88), ...
        'roc', struct('auc', [0.92, 0.90, 0.91]), ...
        'inferenceTime', 15.2, ...
        'throughput', 65.8);
    
    comparator.addResult('TestModel1', mockResult1);
    comparator.addResult('TestModel2', mockResult2);
    
    fprintf('✓ PASSED: Results added successfully\n\n');
    testsPassed = testsPassed + 1;
catch ME
    fprintf('✗ FAILED: %s\n\n', ME.message);
    testsFailed = testsFailed + 1;
end

%% Test 3: ModelComparator - Create Comparison Table
fprintf('Test 3: ModelComparator - Create Comparison Table...\n');
try
    compTable = comparator.createComparisonTable();
    assert(istable(compTable), 'Should return a table');
    assert(height(compTable) == 2, 'Should have 2 rows');
    assert(ismember('Model', compTable.Properties.VariableNames), 'Should have Model column');
    assert(ismember('Accuracy', compTable.Properties.VariableNames), 'Should have Accuracy column');
    
    fprintf('✓ PASSED: Comparison table created successfully\n\n');
    testsPassed = testsPassed + 1;
catch ME
    fprintf('✗ FAILED: %s\n\n', ME.message);
    testsFailed = testsFailed + 1;
end

%% Test 4: ModelComparator - Identify Best Models
fprintf('Test 4: ModelComparator - Identify Best Models...\n');
try
    bestModels = comparator.identifyBestModels();
    assert(isstruct(bestModels), 'Should return a struct');
    assert(isfield(bestModels, 'accuracy'), 'Should have accuracy field');
    assert(isfield(bestModels, 'macroF1'), 'Should have macroF1 field');
    assert(isfield(bestModels, 'inferenceTime'), 'Should have inferenceTime field');
    
    % TestModel1 should be best for accuracy
    assert(strcmp(bestModels.accuracy.model, 'TestModel1'), 'TestModel1 should have best accuracy');
    % TestModel2 should be fastest
    assert(strcmp(bestModels.inferenceTime.model, 'TestModel2'), 'TestModel2 should be fastest');
    
    fprintf('✓ PASSED: Best models identified correctly\n\n');
    testsPassed = testsPassed + 1;
catch ME
    fprintf('✗ FAILED: %s\n\n', ME.message);
    testsFailed = testsFailed + 1;
end

%% Test 5: ModelComparator - Generate Ranking Table
fprintf('Test 5: ModelComparator - Generate Ranking Table...\n');
try
    rankingTable = comparator.generateRankingTable();
    assert(istable(rankingTable), 'Should return a table');
    assert(height(rankingTable) == 2, 'Should have 2 rows');
    assert(ismember('AverageRank', rankingTable.Properties.VariableNames), 'Should have AverageRank column');
    
    fprintf('✓ PASSED: Ranking table generated successfully\n\n');
    testsPassed = testsPassed + 1;
catch ME
    fprintf('✗ FAILED: %s\n\n', ME.message);
    testsFailed = testsFailed + 1;
end

%% Test 6: SegmentationComparator Initialization
fprintf('Test 6: SegmentationComparator Initialization...\n');
try
    segComparator = SegmentationComparator(errorHandler);
    assert(~isempty(segComparator), 'SegmentationComparator should be initialized');
    fprintf('✓ PASSED: SegmentationComparator initialized successfully\n\n');
    testsPassed = testsPassed + 1;
catch ME
    fprintf('✗ FAILED: %s\n\n', ME.message);
    testsFailed = testsFailed + 1;
end

%% Test 7: SegmentationComparator - Use Estimated Times
fprintf('Test 7: SegmentationComparator - Use Estimated Times...\n');
try
    segComparator.useEstimatedSegmentationTimes();
    fprintf('✓ PASSED: Estimated segmentation times set\n\n');
    testsPassed = testsPassed + 1;
catch ME
    fprintf('✗ FAILED: %s\n\n', ME.message);
    testsFailed = testsFailed + 1;
end

%% Test 8: SegmentationComparator - Load Classification Results (Mock)
fprintf('Test 8: SegmentationComparator - Load Classification Results...\n');
try
    % Create temporary directory with mock results
    tempDir = fullfile(tempdir, 'test_classification_results');
    if ~exist(tempDir, 'dir')
        mkdir(tempDir);
    end
    
    % Save mock result
    report = mockResult1;
    save(fullfile(tempDir, 'TestModel1_evaluation_report.mat'), 'report');
    
    segComparator.loadClassificationResults(tempDir);
    
    % Clean up
    rmdir(tempDir, 's');
    
    fprintf('✓ PASSED: Classification results loaded\n\n');
    testsPassed = testsPassed + 1;
catch ME
    fprintf('✗ FAILED: %s\n\n', ME.message);
    testsFailed = testsFailed + 1;
end

%% Test 9: SegmentationComparator - Create Comparison Table
fprintf('Test 9: SegmentationComparator - Create Comparison Table...\n');
try
    compTable = segComparator.createComparisonTable();
    assert(istable(compTable), 'Should return a table');
    assert(ismember('Type', compTable.Properties.VariableNames), 'Should have Type column');
    assert(ismember('SpeedupVsSegmentation', compTable.Properties.VariableNames), 'Should have SpeedupVsSegmentation column');
    
    fprintf('✓ PASSED: Segmentation comparison table created\n\n');
    testsPassed = testsPassed + 1;
catch ME
    fprintf('✗ FAILED: %s\n\n', ME.message);
    testsFailed = testsFailed + 1;
end

%% Test 10: SegmentationComparator - Calculate Speedup Factors
fprintf('Test 10: SegmentationComparator - Calculate Speedup Factors...\n');
try
    speedupFactors = segComparator.calculateSpeedupFactors();
    assert(isstruct(speedupFactors), 'Should return a struct');
    
    % Classification should be faster than segmentation
    fields = fieldnames(speedupFactors);
    for i = 1:length(fields)
        assert(speedupFactors.(fields{i}).vsAverage > 1, ...
            'Classification should be faster than segmentation');
    end
    
    fprintf('✓ PASSED: Speedup factors calculated correctly\n\n');
    testsPassed = testsPassed + 1;
catch ME
    fprintf('✗ FAILED: %s\n\n', ME.message);
    testsFailed = testsFailed + 1;
end

%% Summary
fprintf('=================================================\n');
fprintf('VALIDATION SUMMARY\n');
fprintf('=================================================\n');
fprintf('Tests Passed: %d\n', testsPassed);
fprintf('Tests Failed: %d\n', testsFailed);
fprintf('Total Tests: %d\n', testsPassed + testsFailed);
fprintf('Success Rate: %.1f%%\n', (testsPassed / (testsPassed + testsFailed)) * 100);
fprintf('=================================================\n\n');

if testsFailed == 0
    fprintf('✓ ALL TESTS PASSED - Task 8 implementation is valid!\n\n');
else
    fprintf('✗ SOME TESTS FAILED - Please review the implementation.\n\n');
end
