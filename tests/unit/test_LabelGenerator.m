function test_LabelGenerator()
    % Comprehensive test suite for LabelGenerator class
    % Tests corroded percentage calculation, class assignment, CSV generation,
    % and error handling with synthetic masks
    %
    % Requirements: 1.1, 1.2, 1.3, 1.4
    
    fprintf('=== LabelGenerator Test Suite ===\n\n');
    
    try
        % Setup
        fprintf('Setting up test environment...\n');
        addpath(genpath('src/classification'));
        addpath('src/utils');
        
        % Test 1: Corroded percentage calculation with synthetic masks
        fprintf('\nTest 1: Corroded percentage calculation...\n');
        test_corroded_percentage_calculation();
        
        % Test 2: Class assignment with boundary values
        fprintf('\nTest 2: Class assignment with boundary values...\n');
        test_class_assignment_boundaries();
        
        % Test 3: CSV format validation
        fprintf('\nTest 3: CSV format validation...\n');
        test_csv_format_validation();
        
        % Test 4: Error handling for invalid masks
        fprintf('\nTest 4: Error handling for invalid masks...\n');
        test_error_handling();
        
        % Test 5: Batch processing
        fprintf('\nTest 5: Batch processing...\n');
        test_batch_processing();
        
        fprintf('\n=== All LabelGenerator tests passed! ===\n');
        
    catch ME
        fprintf(2, '\nTest failed: %s\n', ME.message);
        fprintf(2, 'Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf(2, '  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        rethrow(ME);
    end
end

function test_corroded_percentage_calculation()
    % Test corroded percentage calculation with synthetic masks (0%, 50%, 100%)
    % Requirement: 1.1
    
    fprintf('  Testing 0%% corroded mask...\n');
    mask_0 = zeros(100, 100, 'uint8');
    percentage_0 = LabelGenerator.computeCorrodedPercentage(mask_0);
    assert(abs(percentage_0 - 0) < 1e-6, 'Expected 0%% corroded');
    fprintf('    ✓ 0%% mask: %.2f%%\n', percentage_0);
    
    fprintf('  Testing 50%% corroded mask...\n');
    mask_50 = zeros(100, 100, 'uint8');
    mask_50(1:50, :) = 255;
    percentage_50 = LabelGenerator.computeCorrodedPercentage(mask_50);
    assert(abs(percentage_50 - 50) < 1e-6, 'Expected 50%% corroded');
    fprintf('    ✓ 50%% mask: %.2f%%\n', percentage_50);
    
    fprintf('  Testing 100%% corroded mask...\n');
    mask_100 = ones(100, 100, 'uint8') * 255;
    percentage_100 = LabelGenerator.computeCorrodedPercentage(mask_100);
    assert(abs(percentage_100 - 100) < 1e-6, 'Expected 100%% corroded');
    fprintf('    ✓ 100%% mask: %.2f%%\n', percentage_100);
    
    fprintf('  Testing logical mask...\n');
    mask_logical = false(100, 100);
    mask_logical(1:25, :) = true;
    percentage_logical = LabelGenerator.computeCorrodedPercentage(mask_logical);
    assert(abs(percentage_logical - 25) < 1e-6, 'Expected 25%% corroded');
    fprintf('    ✓ Logical mask: %.2f%%\n', percentage_logical);
    
    fprintf('  Testing normalized mask (0-1 range)...\n');
    mask_normalized = zeros(100, 100);
    mask_normalized(1:75, :) = 1.0;
    percentage_normalized = LabelGenerator.computeCorrodedPercentage(mask_normalized);
    assert(abs(percentage_normalized - 75) < 1e-6, 'Expected 75%% corroded');
    fprintf('    ✓ Normalized mask: %.2f%%\n', percentage_normalized);
    
    fprintf('  ✓ Corroded percentage calculation tests passed\n');
end

function test_class_assignment_boundaries()
    % Test class assignment with boundary values (9.9%, 10.0%, 29.9%, 30.0%)
    % Requirements: 1.2, 1.3, 1.4
    
    thresholds = [10, 30];
    
    fprintf('  Testing boundary value 9.9%% (should be Class 0)...\n');
    class_9_9 = LabelGenerator.assignSeverityClass(9.9, thresholds);
    assert(class_9_9 == 0, 'Expected Class 0 for 9.9%%');
    fprintf('    ✓ 9.9%% → Class %d (None/Light)\n', class_9_9);
    
    fprintf('  Testing boundary value 10.0%% (should be Class 1)...\n');
    class_10_0 = LabelGenerator.assignSeverityClass(10.0, thresholds);
    assert(class_10_0 == 1, 'Expected Class 1 for 10.0%%');
    fprintf('    ✓ 10.0%% → Class %d (Moderate)\n', class_10_0);
    
    fprintf('  Testing boundary value 29.9%% (should be Class 1)...\n');
    class_29_9 = LabelGenerator.assignSeverityClass(29.9, thresholds);
    assert(class_29_9 == 1, 'Expected Class 1 for 29.9%%');
    fprintf('    ✓ 29.9%% → Class %d (Moderate)\n', class_29_9);
    
    fprintf('  Testing boundary value 30.0%% (should be Class 2)...\n');
    class_30_0 = LabelGenerator.assignSeverityClass(30.0, thresholds);
    assert(class_30_0 == 2, 'Expected Class 2 for 30.0%%');
    fprintf('    ✓ 30.0%% → Class %d (Severe)\n', class_30_0);
    
    fprintf('  Testing extreme values...\n');
    class_0 = LabelGenerator.assignSeverityClass(0.0, thresholds);
    assert(class_0 == 0, 'Expected Class 0 for 0%%');
    fprintf('    ✓ 0.0%% → Class %d\n', class_0);
    
    class_100 = LabelGenerator.assignSeverityClass(100.0, thresholds);
    assert(class_100 == 2, 'Expected Class 2 for 100%%');
    fprintf('    ✓ 100.0%% → Class %d\n', class_100);
    
    fprintf('  Testing mid-range values...\n');
    class_5 = LabelGenerator.assignSeverityClass(5.0, thresholds);
    assert(class_5 == 0, 'Expected Class 0 for 5%%');
    fprintf('    ✓ 5.0%% → Class %d\n', class_5);
    
    class_20 = LabelGenerator.assignSeverityClass(20.0, thresholds);
    assert(class_20 == 1, 'Expected Class 1 for 20%%');
    fprintf('    ✓ 20.0%% → Class %d\n', class_20);
    
    class_50 = LabelGenerator.assignSeverityClass(50.0, thresholds);
    assert(class_50 == 2, 'Expected Class 2 for 50%%');
    fprintf('    ✓ 50.0%% → Class %d\n', class_50);
    
    fprintf('  ✓ Class assignment boundary tests passed\n');
end

function test_csv_format_validation()
    % Test CSV format validation
    % Requirement: 1.5
    
    fprintf('  Creating test directory and synthetic masks...\n');
    
    % Create temporary test directory
    testDir = fullfile(tempdir, 'test_label_generator');
    if exist(testDir, 'dir')
        rmdir(testDir, 's');
    end
    mkdir(testDir);
    
    % Create synthetic masks with known percentages
    masks = struct();
    masks(1).name = 'mask_class0.png';
    masks(1).percentage = 5.0;
    masks(1).expectedClass = 0;
    
    masks(2).name = 'mask_class1.png';
    masks(2).percentage = 20.0;
    masks(2).expectedClass = 1;
    
    masks(3).name = 'mask_class2.png';
    masks(3).percentage = 50.0;
    masks(3).expectedClass = 2;
    
    % Generate masks
    for i = 1:length(masks)
        mask = zeros(100, 100, 'uint8');
        numCorrodedPixels = round(masks(i).percentage / 100 * 10000);
        mask(1:numCorrodedPixels) = 255;
        imwrite(mask, fullfile(testDir, masks(i).name));
    end
    
    fprintf('  Generating labels...\n');
    
    % Create LabelGenerator
    errorHandler = ErrorHandler.getInstance();
    errorHandler.enableConsole(false);  % Suppress console output during test
    
    labelGenerator = LabelGenerator([10, 30], errorHandler);
    
    % Generate labels
    outputCSV = fullfile(testDir, 'labels.csv');
    [labels, stats] = labelGenerator.generateLabelsFromMasks(testDir, outputCSV);
    
    errorHandler.enableConsole(true);  % Re-enable console output
    
    fprintf('  Validating CSV format...\n');
    
    % Validate CSV file exists
    assert(isfile(outputCSV), 'CSV file should exist');
    fprintf('    ✓ CSV file created\n');
    
    % Validate table structure
    assert(istable(labels), 'Output should be a table');
    fprintf('    ✓ Output is a table\n');
    
    % Validate column names
    expectedColumns = {'filename', 'corroded_percentage', 'severity_class'};
    actualColumns = labels.Properties.VariableNames;
    assert(isequal(actualColumns, expectedColumns), 'Column names mismatch');
    fprintf('    ✓ Column names correct: %s\n', strjoin(actualColumns, ', '));
    
    % Validate number of rows
    assert(height(labels) == 3, 'Expected 3 rows');
    fprintf('    ✓ Correct number of rows: %d\n', height(labels));
    
    % Validate data types
    assert(iscell(labels.filename), 'filename should be cell array');
    assert(isnumeric(labels.corroded_percentage), 'corroded_percentage should be numeric');
    assert(isnumeric(labels.severity_class), 'severity_class should be numeric');
    fprintf('    ✓ Data types correct\n');
    
    % Validate values
    for i = 1:height(labels)
        % Find corresponding mask
        idx = find(strcmp({masks.name}, labels.filename{i}));
        assert(~isempty(idx), 'Filename not found in expected masks');
        
        % Check percentage (allow small tolerance)
        expectedPercentage = masks(idx).percentage;
        actualPercentage = labels.corroded_percentage(i);
        assert(abs(actualPercentage - expectedPercentage) < 1.0, ...
            sprintf('Percentage mismatch for %s', labels.filename{i}));
        
        % Check class
        expectedClass = masks(idx).expectedClass;
        actualClass = labels.severity_class(i);
        assert(actualClass == expectedClass, ...
            sprintf('Class mismatch for %s', labels.filename{i}));
        
        fprintf('    ✓ %s: %.1f%% → Class %d\n', ...
            labels.filename{i}, actualPercentage, actualClass);
    end
    
    % Validate statistics
    assert(stats.successCount == 3, 'Expected 3 successful conversions');
    assert(stats.failureCount == 0, 'Expected 0 failures');
    fprintf('    ✓ Statistics correct\n');
    
    % Cleanup
    rmdir(testDir, 's');
    
    fprintf('  ✓ CSV format validation tests passed\n');
end

function test_error_handling()
    % Test error handling for invalid masks
    % Requirement: 1.1, 1.2, 1.3, 1.4
    
    fprintf('  Testing empty mask error...\n');
    try
        LabelGenerator.computeCorrodedPercentage([]);
        error('Should have thrown error for empty mask');
    catch ME
        assert(strcmp(ME.identifier, 'LabelGenerator:EmptyMask'), ...
            'Expected EmptyMask error');
        fprintf('    ✓ Empty mask error caught\n');
    end
    
    fprintf('  Testing invalid percentage error...\n');
    try
        LabelGenerator.assignSeverityClass(-5, [10, 30]);
        error('Should have thrown error for negative percentage');
    catch ME
        assert(strcmp(ME.identifier, 'LabelGenerator:InvalidPercentage'), ...
            'Expected InvalidPercentage error');
        fprintf('    ✓ Invalid percentage error caught\n');
    end
    
    fprintf('  Testing invalid thresholds error...\n');
    try
        LabelGenerator.assignSeverityClass(50, [30, 10]);
        error('Should have thrown error for invalid thresholds');
    catch ME
        assert(strcmp(ME.identifier, 'LabelGenerator:InvalidThresholds'), ...
            'Expected InvalidThresholds error');
        fprintf('    ✓ Invalid thresholds error caught\n');
    end
    
    fprintf('  Testing non-existent directory error...\n');
    errorHandler = ErrorHandler.getInstance();
    errorHandler.enableConsole(false);
    
    labelGenerator = LabelGenerator([10, 30], errorHandler);
    
    try
        labelGenerator.generateLabelsFromMasks('/nonexistent/directory', '');
        error('Should have thrown error for non-existent directory');
    catch ME
        assert(strcmp(ME.identifier, 'LabelGenerator:DirectoryNotFound'), ...
            'Expected DirectoryNotFound error');
        fprintf('    ✓ Non-existent directory error caught\n');
    end
    
    errorHandler.enableConsole(true);
    
    fprintf('  Testing corrupted mask handling...\n');
    
    % Create test directory with corrupted mask
    testDir = fullfile(tempdir, 'test_corrupted_masks');
    if exist(testDir, 'dir')
        rmdir(testDir, 's');
    end
    mkdir(testDir);
    
    % Create one valid mask
    validMask = zeros(100, 100, 'uint8');
    validMask(1:50, :) = 255;
    imwrite(validMask, fullfile(testDir, 'valid_mask.png'));
    
    % Create a corrupted file (empty file)
    fid = fopen(fullfile(testDir, 'corrupted_mask.png'), 'w');
    fclose(fid);
    
    errorHandler.enableConsole(false);
    
    % Process directory with corrupted mask
    outputCSV = fullfile(testDir, 'labels.csv');
    [labels, stats] = labelGenerator.generateLabelsFromMasks(testDir, outputCSV);
    
    errorHandler.enableConsole(true);
    
    % Should have 1 success and 1 failure
    assert(stats.successCount == 1, 'Expected 1 successful conversion');
    assert(stats.failureCount == 1, 'Expected 1 failure');
    assert(height(labels) == 1, 'Expected 1 valid label');
    fprintf('    ✓ Corrupted mask handled gracefully\n');
    
    % Cleanup
    rmdir(testDir, 's');
    
    fprintf('  ✓ Error handling tests passed\n');
end

function test_batch_processing()
    % Test batch processing with multiple masks
    
    fprintf('  Creating test dataset with 30 masks...\n');
    
    % Create test directory
    testDir = fullfile(tempdir, 'test_batch_processing');
    if exist(testDir, 'dir')
        rmdir(testDir, 's');
    end
    mkdir(testDir);
    
    % Create 30 masks (10 per class)
    numMasksPerClass = 10;
    expectedDistribution = [numMasksPerClass, numMasksPerClass, numMasksPerClass];
    
    maskIdx = 1;
    
    % Class 0: 0-9% corroded
    for i = 1:numMasksPerClass
        mask = zeros(100, 100, 'uint8');
        percentage = (i - 1) * 1.0;  % 0%, 1%, 2%, ..., 9%
        numPixels = round(percentage / 100 * 10000);
        mask(1:numPixels) = 255;
        imwrite(mask, fullfile(testDir, sprintf('mask_%03d.png', maskIdx)));
        maskIdx = maskIdx + 1;
    end
    
    % Class 1: 10-29% corroded
    for i = 1:numMasksPerClass
        mask = zeros(100, 100, 'uint8');
        percentage = 10 + (i - 1) * 2.0;  % 10%, 12%, 14%, ..., 28%
        numPixels = round(percentage / 100 * 10000);
        mask(1:numPixels) = 255;
        imwrite(mask, fullfile(testDir, sprintf('mask_%03d.png', maskIdx)));
        maskIdx = maskIdx + 1;
    end
    
    % Class 2: 30%+ corroded
    for i = 1:numMasksPerClass
        mask = zeros(100, 100, 'uint8');
        percentage = 30 + (i - 1) * 7.0;  % 30%, 37%, 44%, ..., 93%
        numPixels = round(percentage / 100 * 10000);
        mask(1:numPixels) = 255;
        imwrite(mask, fullfile(testDir, sprintf('mask_%03d.png', maskIdx)));
        maskIdx = maskIdx + 1;
    end
    
    fprintf('  Processing batch...\n');
    
    % Create LabelGenerator
    errorHandler = ErrorHandler.getInstance();
    errorHandler.enableConsole(false);
    
    labelGenerator = LabelGenerator([10, 30], errorHandler);
    
    % Generate labels
    outputCSV = fullfile(testDir, 'labels.csv');
    tic;
    [labels, stats] = labelGenerator.generateLabelsFromMasks(testDir, outputCSV);
    processingTime = toc;
    
    errorHandler.enableConsole(true);
    
    fprintf('  Validating batch results...\n');
    
    % Validate all masks processed
    assert(stats.successCount == 30, 'Expected 30 successful conversions');
    assert(stats.failureCount == 0, 'Expected 0 failures');
    fprintf('    ✓ All 30 masks processed successfully\n');
    
    % Validate class distribution
    assert(isequal(stats.classDistribution, expectedDistribution), ...
        'Class distribution mismatch');
    fprintf('    ✓ Class distribution: [%d, %d, %d]\n', ...
        stats.classDistribution(1), stats.classDistribution(2), stats.classDistribution(3));
    
    % Validate processing time is reasonable
    fprintf('    ✓ Processing time: %.3f seconds (%.1f ms/mask)\n', ...
        processingTime, processingTime * 1000 / 30);
    
    % Validate CSV file
    assert(isfile(outputCSV), 'CSV file should exist');
    loadedLabels = readtable(outputCSV);
    assert(height(loadedLabels) == 30, 'CSV should have 30 rows');
    fprintf('    ✓ CSV file saved and validated\n');
    
    % Cleanup
    rmdir(testDir, 's');
    
    fprintf('  ✓ Batch processing tests passed\n');
end
