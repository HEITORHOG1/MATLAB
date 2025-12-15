% validate_label_generator.m
% Quick validation script for LabelGenerator implementation
%
% This script performs basic validation to ensure the LabelGenerator
% class is properly implemented and can be instantiated.

clear;
clc;

fprintf('=== LabelGenerator Implementation Validation ===\n\n');

% Add paths
addpath(genpath('src/classification'));
addpath('src/utils');

try
    %% Test 1: Class instantiation
    fprintf('Test 1: Instantiating LabelGenerator...\n');
    errorHandler = ErrorHandler.getInstance();
    labelGenerator = LabelGenerator([10, 30], errorHandler);
    fprintf('  ✓ LabelGenerator instantiated successfully\n');
    
    %% Test 2: Static method - computeCorrodedPercentage
    fprintf('\nTest 2: Testing computeCorrodedPercentage...\n');
    
    % Test with 0% mask
    mask_0 = zeros(100, 100, 'uint8');
    percentage_0 = LabelGenerator.computeCorrodedPercentage(mask_0);
    fprintf('  ✓ 0%% mask: %.2f%%\n', percentage_0);
    assert(abs(percentage_0 - 0) < 1e-6, 'Expected 0%%');
    
    % Test with 50% mask
    mask_50 = zeros(100, 100, 'uint8');
    mask_50(1:50, :) = 255;
    percentage_50 = LabelGenerator.computeCorrodedPercentage(mask_50);
    fprintf('  ✓ 50%% mask: %.2f%%\n', percentage_50);
    assert(abs(percentage_50 - 50) < 1e-6, 'Expected 50%%');
    
    % Test with 100% mask
    mask_100 = ones(100, 100, 'uint8') * 255;
    percentage_100 = LabelGenerator.computeCorrodedPercentage(mask_100);
    fprintf('  ✓ 100%% mask: %.2f%%\n', percentage_100);
    assert(abs(percentage_100 - 100) < 1e-6, 'Expected 100%%');
    
    %% Test 3: Static method - assignSeverityClass
    fprintf('\nTest 3: Testing assignSeverityClass...\n');
    
    thresholds = [10, 30];
    
    class_5 = LabelGenerator.assignSeverityClass(5.0, thresholds);
    fprintf('  ✓ 5.0%% → Class %d (None/Light)\n', class_5);
    assert(class_5 == 0, 'Expected Class 0');
    
    class_20 = LabelGenerator.assignSeverityClass(20.0, thresholds);
    fprintf('  ✓ 20.0%% → Class %d (Moderate)\n', class_20);
    assert(class_20 == 1, 'Expected Class 1');
    
    class_50 = LabelGenerator.assignSeverityClass(50.0, thresholds);
    fprintf('  ✓ 50.0%% → Class %d (Severe)\n', class_50);
    assert(class_50 == 2, 'Expected Class 2');
    
    %% Test 4: Boundary values
    fprintf('\nTest 4: Testing boundary values...\n');
    
    class_9_9 = LabelGenerator.assignSeverityClass(9.9, thresholds);
    fprintf('  ✓ 9.9%% → Class %d\n', class_9_9);
    assert(class_9_9 == 0, 'Expected Class 0');
    
    class_10_0 = LabelGenerator.assignSeverityClass(10.0, thresholds);
    fprintf('  ✓ 10.0%% → Class %d\n', class_10_0);
    assert(class_10_0 == 1, 'Expected Class 1');
    
    class_29_9 = LabelGenerator.assignSeverityClass(29.9, thresholds);
    fprintf('  ✓ 29.9%% → Class %d\n', class_29_9);
    assert(class_29_9 == 1, 'Expected Class 1');
    
    class_30_0 = LabelGenerator.assignSeverityClass(30.0, thresholds);
    fprintf('  ✓ 30.0%% → Class %d\n', class_30_0);
    assert(class_30_0 == 2, 'Expected Class 2');
    
    %% Test 5: Error handling
    fprintf('\nTest 5: Testing error handling...\n');
    
    % Test empty mask error
    try
        LabelGenerator.computeCorrodedPercentage([]);
        error('Should have thrown error');
    catch ME
        if strcmp(ME.identifier, 'LabelGenerator:EmptyMask')
            fprintf('  ✓ Empty mask error caught correctly\n');
        else
            rethrow(ME);
        end
    end
    
    % Test invalid percentage error
    try
        LabelGenerator.assignSeverityClass(-5, thresholds);
        error('Should have thrown error');
    catch ME
        if strcmp(ME.identifier, 'LabelGenerator:InvalidPercentage')
            fprintf('  ✓ Invalid percentage error caught correctly\n');
        else
            rethrow(ME);
        end
    end
    
    % Test invalid thresholds error
    try
        LabelGenerator.assignSeverityClass(50, [30, 10]);
        error('Should have thrown error');
    catch ME
        if strcmp(ME.identifier, 'LabelGenerator:InvalidThresholds')
            fprintf('  ✓ Invalid thresholds error caught correctly\n');
        else
            rethrow(ME);
        end
    end
    
    %% Test 6: Mini batch processing test
    fprintf('\nTest 6: Testing mini batch processing...\n');
    
    % Create temporary test directory
    testDir = fullfile(tempdir, 'validate_label_generator');
    if exist(testDir, 'dir')
        rmdir(testDir, 's');
    end
    mkdir(testDir);
    
    % Create 3 test masks
    mask1 = zeros(100, 100, 'uint8');
    mask1(1:5, :) = 255;  % 5% corroded
    imwrite(mask1, fullfile(testDir, 'mask1.png'));
    
    mask2 = zeros(100, 100, 'uint8');
    mask2(1:20, :) = 255;  % 20% corroded
    imwrite(mask2, fullfile(testDir, 'mask2.png'));
    
    mask3 = zeros(100, 100, 'uint8');
    mask3(1:50, :) = 255;  % 50% corroded
    imwrite(mask3, fullfile(testDir, 'mask3.png'));
    
    % Process masks
    errorHandler.enableConsole(false);
    outputCSV = fullfile(testDir, 'labels.csv');
    [labels, stats] = labelGenerator.generateLabelsFromMasks(testDir, outputCSV);
    errorHandler.enableConsole(true);
    
    fprintf('  ✓ Processed %d masks\n', stats.successCount);
    fprintf('  ✓ Class distribution: [%d, %d, %d]\n', ...
        stats.classDistribution(1), stats.classDistribution(2), stats.classDistribution(3));
    fprintf('  ✓ CSV file created: %s\n', outputCSV);
    
    % Validate results
    assert(stats.successCount == 3, 'Expected 3 successful conversions');
    assert(stats.failureCount == 0, 'Expected 0 failures');
    assert(isfile(outputCSV), 'CSV file should exist');
    assert(height(labels) == 3, 'Expected 3 labels');
    
    % Cleanup
    rmdir(testDir, 's');
    
    fprintf('\n=== All Validation Tests Passed! ===\n');
    fprintf('\nThe LabelGenerator implementation is working correctly.\n');
    fprintf('You can now run the full test suite with: test_LabelGenerator()\n');
    fprintf('Or use the label generation script: gerar_labels_classificacao.m\n');
    
catch ME
    fprintf(2, '\n✗ Validation failed: %s\n', ME.message);
    fprintf(2, 'Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf(2, '  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
    
    % Cleanup on error
    if exist('testDir', 'var') && exist(testDir, 'dir')
        rmdir(testDir, 's');
    end
    
    rethrow(ME);
end
