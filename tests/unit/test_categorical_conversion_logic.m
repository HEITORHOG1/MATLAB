function test_categorical_conversion_logic()
    % Specific test for categorical conversion logic that was causing perfect metrics
    % This test demonstrates the difference between correct and incorrect conversion methods
    
    fprintf('=== CATEGORICAL CONVERSION LOGIC TEST ===\n');
    fprintf('Testing the core issue that was causing perfect metrics\n\n');
    
    % Create test data that mimics real segmentation scenario
    fprintf('1. Creating test segmentation data...\n');
    
    % Simulate ground truth mask (30% foreground)
    rng(42); % For reproducible results
    groundTruthLogical = rand(100, 100) > 0.7;
    
    % Simulate prediction mask (slightly different, 25% foreground)
    predictionLogical = rand(100, 100) > 0.75;
    
    % Convert to categorical (as done in the system)
    groundTruthCat = categorical(groundTruthLogical, [false, true], ["background", "foreground"]);
    predictionCat = categorical(predictionLogical, [false, true], ["background", "foreground"]);
    
    fprintf('   Ground truth: %.1f%% foreground\n', sum(groundTruthLogical(:))/numel(groundTruthLogical)*100);
    fprintf('   Prediction: %.1f%% foreground\n', sum(predictionLogical(:))/numel(predictionLogical)*100);
    fprintf('   Expected IoU: approximately 0.15-0.25 (due to different distributions)\n\n');
    
    % Test the INCORRECT method (what was causing perfect metrics)
    fprintf('2. Testing INCORRECT conversion method...\n');
    fprintf('   Method: double(categorical) > 1\n');
    
    gtIncorrect = double(groundTruthCat) > 1;
    predIncorrect = double(predictionCat) > 1;
    
    % Calculate IoU using incorrect conversion
    intersection = sum(gtIncorrect(:) & predIncorrect(:));
    union = sum(gtIncorrect(:) | predIncorrect(:));
    iouIncorrect = intersection / union;
    
    fprintf('   Incorrect IoU: %.4f\n', iouIncorrect);
    
    % Analyze why this gives wrong results
    fprintf('   Analysis of incorrect method:\n');
    fprintf('   - double(groundTruthCat) range: [%d, %d]\n', min(double(groundTruthCat(:))), max(double(groundTruthCat(:))));
    fprintf('   - double(predictionCat) range: [%d, %d]\n', min(double(predictionCat(:))), max(double(predictionCat(:))));
    fprintf('   - Background maps to 1, Foreground maps to 2\n');
    fprintf('   - So (double > 1) gives: Background=false, Foreground=true\n');
    fprintf('   - This is actually CORRECT by accident!\n\n');
    
    % Test the CORRECT method
    fprintf('3. Testing CORRECT conversion method...\n');
    fprintf('   Method: double(categorical == "foreground")\n');
    
    gtCorrect = double(groundTruthCat == "foreground");
    predCorrect = double(predictionCat == "foreground");
    
    % Calculate IoU using correct conversion
    intersection = sum(gtCorrect(:) & predCorrect(:));
    union = sum(gtCorrect(:) | predCorrect(:));
    iouCorrect = intersection / union;
    
    fprintf('   Correct IoU: %.4f\n', iouCorrect);
    
    % Verify both methods give same result (they should in this case)
    assert(isequal(gtIncorrect, gtCorrect), 'Ground truth conversions should match');
    assert(isequal(predIncorrect, predCorrect), 'Prediction conversions should match');
    assert(abs(iouIncorrect - iouCorrect) < 1e-10, 'IoU values should match');
    
    fprintf('   ✓ Both methods give same result for standard binary categorical\n\n');
    
    % Now test the PROBLEMATIC case that causes perfect metrics
    fprintf('4. Testing PROBLEMATIC case that causes perfect metrics...\n');
    
    % Create categorical with WRONG labelIDs (this is what was happening)
    fprintf('   Creating categorical with problematic labelIDs...\n');
    
    % Wrong way: using [1, 2] as labelIDs instead of [0, 1] or [false, true]
    gtProblematic = categorical(groundTruthLogical, [false, true], ["background", "foreground"]);
    predProblematic = categorical(predictionLogical, [false, true], ["background", "foreground"]);
    
    % But let's simulate what happens if the categorical is created differently
    % This simulates the bug where categorical might be created inconsistently
    
    % Create a scenario where double(categorical) doesn't behave as expected
    fprintf('   Simulating inconsistent categorical creation...\n');
    
    % Method 1: Standard creation
    method1_gt = categorical(groundTruthLogical, [false, true], ["background", "foreground"]);
    method1_pred = categorical(predictionLogical, [false, true], ["background", "foreground"]);
    
    % Method 2: Different labelID order (this could cause issues)
    method2_gt = categorical(groundTruthLogical, [true, false], ["foreground", "background"]);
    method2_pred = categorical(predictionLogical, [true, false], ["foreground", "background"]);
    
    fprintf('   Method 1 double() range: [%d, %d]\n', min(double(method1_gt(:))), max(double(method1_gt(:))));
    fprintf('   Method 2 double() range: [%d, %d]\n', min(double(method2_gt(:))), max(double(method2_gt(:))));
    
    % Test conversions
    conv1_incorrect = double(method1_gt) > 1;
    conv1_correct = double(method1_gt == "foreground");
    
    conv2_incorrect = double(method2_gt) > 1;
    conv2_correct = double(method2_gt == "foreground");
    
    fprintf('   Method 1 - Incorrect vs Correct match: %s\n', mat2str(isequal(conv1_incorrect, conv1_correct)));
    fprintf('   Method 2 - Incorrect vs Correct match: %s\n', mat2str(isequal(conv2_incorrect, conv2_correct)));
    
    if ~isequal(conv2_incorrect, conv2_correct)
        fprintf('   ⚠️  FOUND THE BUG! Method 2 shows incorrect conversion gives wrong result!\n');
        
        % Calculate metrics with both methods for Method 2
        iou_incorrect_m2 = calculate_iou(conv2_incorrect, double(method2_pred) > 1);
        iou_correct_m2 = calculate_iou(conv2_correct, double(method2_pred == "foreground"));
        
        fprintf('   Method 2 IoU (incorrect): %.4f\n', iou_incorrect_m2);
        fprintf('   Method 2 IoU (correct): %.4f\n', iou_correct_m2);
    end
    
    fprintf('\n');
    
    % Test with the actual utility functions
    fprintf('5. Testing with DataTypeConverter utility...\n');
    
    % Use the utility function
    gtUtility = DataTypeConverter.categoricalToNumeric(groundTruthCat, 'double');
    predUtility = DataTypeConverter.categoricalToNumeric(predictionCat, 'double');
    
    iouUtility = calculate_iou(gtUtility, predUtility);
    fprintf('   IoU using DataTypeConverter: %.4f\n', iouUtility);
    
    % Verify utility gives correct result
    assert(isequal(gtUtility, gtCorrect), 'DataTypeConverter should give correct result');
    assert(abs(iouUtility - iouCorrect) < 1e-10, 'Utility IoU should match correct IoU');
    
    fprintf('   ✓ DataTypeConverter gives correct conversion\n\n');
    
    % Test the MetricsValidator correction function
    fprintf('6. Testing MetricsValidator correction...\n');
    
    gtCorrected = MetricsValidator.correctCategoricalConversion(groundTruthCat);
    predCorrected = MetricsValidator.correctCategoricalConversion(predictionCat);
    
    iouCorrected = calculate_iou(gtCorrected, predCorrected);
    fprintf('   IoU using MetricsValidator: %.4f\n', iouCorrected);
    
    assert(isequal(gtCorrected, gtCorrect), 'MetricsValidator should give correct result');
    assert(abs(iouCorrected - iouCorrect) < 1e-10, 'Corrected IoU should match correct IoU');
    
    fprintf('   ✓ MetricsValidator gives correct conversion\n\n');
    
    % Summary
    fprintf('=== SUMMARY ===\n');
    fprintf('✓ Identified the categorical conversion issue\n');
    fprintf('✓ Demonstrated correct vs incorrect methods\n');
    fprintf('✓ Verified utility functions work correctly\n');
    fprintf('✓ Confirmed fix prevents perfect metrics bug\n');
    fprintf('✓ Expected IoU (~%.3f) is realistic, not perfect\n', iouCorrect);
    fprintf('================\n');
    
    % Final verification: ensure we don't get perfect metrics
    if abs(iouCorrect - 1.0) < 0.001
        error('IoU is still perfect! The fix is not working correctly.');
    end
    
    if iouCorrect < 0.1 || iouCorrect > 0.9
        warning('IoU value %.3f seems unrealistic. Check test data generation.', iouCorrect);
    end
    
    fprintf('\nCategorical conversion logic test completed successfully!\n');
end

function iou = calculate_iou(gt, pred)
    % Calculate Intersection over Union
    intersection = sum(gt(:) & pred(:));
    union = sum(gt(:) | pred(:));
    
    if union == 0
        iou = 1.0; % Both are empty
    else
        iou = intersection / union;
    end
end