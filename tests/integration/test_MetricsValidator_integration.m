function test_MetricsValidator_integration()
    % Integration test for MetricsValidator with existing system components
    % Tests interaction with DataTypeConverter and real categorical data
    
    fprintf('Running MetricsValidator integration tests...\n');
    
    % Add paths
    addpath('src/utils');
    addpath('utils');
    
    % Test 1: Integration with DataTypeConverter
    test_integration_with_DataTypeConverter();
    
    % Test 2: Validate metrics from actual calculation functions
    test_integration_with_metric_functions();
    
    % Test 3: Test with problematic categorical data patterns
    test_problematic_categorical_patterns();
    
    fprintf('All MetricsValidator integration tests passed!\n');
end

function test_integration_with_DataTypeConverter()
    fprintf('  Testing integration with DataTypeConverter...\n');
    
    % Create test data using DataTypeConverter
    logical_mask = [true, false, true, false, true];
    categorical_mask = DataTypeConverter.numericToCategorical(...
        logical_mask, ["background", "foreground"], [false, true]);
    
    % Validate the categorical structure
    validated = MetricsValidator.validateCategoricalStructure(categorical_mask);
    assert(validated.isValid, 'DataTypeConverter output should be valid');
    assert(validated.debugInfo.isStandardBinary, 'Should be standard binary');
    
    % Test conversion correction
    corrected = MetricsValidator.correctCategoricalConversion(categorical_mask);
    expected = double(logical_mask);
    assert(isequal(corrected, expected), 'Conversion should match original logical');
end

function test_integration_with_metric_functions()
    fprintf('  Testing integration with metric calculation functions...\n');
    
    % Create test predictions and ground truth
    gt = categorical([0, 1, 0, 1, 1, 0, 1], [0, 1], ["background", "foreground"]);
    pred = categorical([0, 1, 1, 1, 0, 0, 1], [0, 1], ["background", "foreground"]);
    
    % Debug the categorical data
    MetricsValidator.debugCategoricalData(gt, 'Ground Truth');
    MetricsValidator.debugCategoricalData(pred, 'Predictions');
    
    % Convert using MetricsValidator
    gt_corrected = MetricsValidator.correctCategoricalConversion(gt);
    pred_corrected = MetricsValidator.correctCategoricalConversion(pred);
    
    % Calculate metrics manually to test
    intersection = sum(gt_corrected & pred_corrected);
    union_area = sum(gt_corrected | pred_corrected);
    iou = intersection / union_area;
    
    dice = 2 * intersection / (sum(gt_corrected) + sum(pred_corrected));
    accuracy = sum(gt_corrected == pred_corrected) / length(gt_corrected);
    
    fprintf('    Calculated IoU: %.4f\n', iou);
    fprintf('    Calculated Dice: %.4f\n', dice);
    fprintf('    Calculated Accuracy: %.4f\n', accuracy);
    
    % These should be realistic values, not perfect
    assert(iou < 0.99, 'IoU should not be artificially perfect');
    assert(dice < 0.99, 'Dice should not be artificially perfect');
    
    % Test with perfect overlap (should be detected as suspicious)
    gt_perfect = categorical([0, 1, 0, 1], [0, 1], ["background", "foreground"]);
    pred_perfect = gt_perfect; % Identical
    
    warnings = MetricsValidator.checkPerfectMetrics([1.0], [1.0], [1.0]);
    assert(length(warnings) > 0, 'Perfect metrics should generate warnings');
end

function test_problematic_categorical_patterns()
    fprintf('  Testing problematic categorical patterns...\n');
    
    % Test 1: Categorical with wrong labelIDs (common error)
    wrong_categorical = categorical([1, 2, 1, 2], [1, 2], ["background", "foreground"]);
    validated = MetricsValidator.validateCategoricalStructure(wrong_categorical);
    
    % This should still work but might generate warnings
    corrected = MetricsValidator.correctCategoricalConversion(wrong_categorical);
    assert(all(corrected >= 0 & corrected <= 1), 'Correction should produce binary values');
    
    % Test 2: Single category (degenerate case)
    single_cat = categorical(ones(5, 1), 1, "foreground");
    validated = MetricsValidator.validateCategoricalStructure(single_cat);
    assert(length(validated.warnings) > 0, 'Single category should generate warnings');
    
    % Test 3: Empty categories
    empty_cat = categorical([1, 1, 1], [1, 2], ["foreground", "unused"]);
    validated = MetricsValidator.validateCategoricalStructure(empty_cat);
    assert(length(validated.warnings) > 0, 'Empty categories should generate warnings');
    
    % Test 4: Non-standard category names
    nonstandard = categorical([0, 1, 0, 1], [0, 1], ["neg", "pos"]);
    validated = MetricsValidator.validateCategoricalStructure(nonstandard);
    assert(~validated.debugInfo.isStandardBinary, 'Non-standard names should not be detected as standard');
    
    % But conversion should still work
    corrected = MetricsValidator.correctCategoricalConversion(nonstandard);
    assert(all(corrected >= 0 & corrected <= 1), 'Non-standard names should still convert correctly');
end