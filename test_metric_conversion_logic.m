function test_metric_conversion_logic()
    % Test script to verify the corrected categorical conversion logic in metrics
    
    fprintf('=== Testing Metric Conversion Logic ===\n');
    
    % Add paths
    addpath('src/utils');
    addpath('utils');
    
    % Create test categorical data with known structure
    testData = [0, 1, 0, 1; 1, 0, 1, 0];
    catData = DataTypeConverter.numericToCategorical(testData, ["background", "foreground"], [0, 1]);
    
    fprintf('Test data structure:\n');
    fprintf('  Categories: [%s]\n', strjoin(categories(catData), ', '));
    fprintf('  double() values: [%s]\n', mat2str(unique(double(catData))));
    
    % Test the OLD INCORRECT logic (should give wrong results)
    fprintf('\n1. Testing OLD INCORRECT logic: double(categorical) > 1\n');
    oldLogicResult = double(catData) > 1;
    fprintf('  Result: %s\n', mat2str(oldLogicResult));
    fprintf('  Expected foreground positions: %s\n', mat2str(testData == 1));
    if isequal(oldLogicResult, testData == 1)
        fprintf('  ❌ Old logic accidentally works (this should not happen with [0,1] labelIDs)\n');
    else
        fprintf('  ✓ Old logic gives incorrect results (as expected)\n');
    end
    
    % Test the NEW CORRECT logic
    fprintf('\n2. Testing NEW CORRECT logic: categorical == "foreground"\n');
    newLogicResult = catData == "foreground";
    fprintf('  Result: %s\n', mat2str(newLogicResult));
    fprintf('  Expected foreground positions: %s\n', mat2str(testData == 1));
    if isequal(newLogicResult, testData == 1)
        fprintf('  ✓ New logic gives correct results\n');
    else
        fprintf('  ❌ New logic gives incorrect results\n');
    end
    
    % Test metric functions if available
    fprintf('\n3. Testing metric functions with corrected logic...\n');
    
    % Create two slightly different categorical masks for testing
    pred = catData;
    gt = catData;
    gt(1,1) = categorical(1, [0, 1], ["background", "foreground"]); % Make one difference
    
    try
        if exist('calcular_iou_simples', 'file')
            iou = calcular_iou_simples(pred, gt);
            fprintf('  IoU calculation: %.4f\n', iou);
            if iou > 0 && iou < 1
                fprintf('  ✓ IoU shows realistic variation (not perfect 1.0)\n');
            else
                fprintf('  ⚠ IoU result may indicate issues: %.4f\n', iou);
            end
        end
    catch ME
        fprintf('  ⚠ IoU test failed: %s\n', ME.message);
    end
    
    try
        if exist('calcular_dice_simples', 'file')
            dice = calcular_dice_simples(pred, gt);
            fprintf('  Dice calculation: %.4f\n', dice);
            if dice > 0 && dice < 1
                fprintf('  ✓ Dice shows realistic variation (not perfect 1.0)\n');
            else
                fprintf('  ⚠ Dice result may indicate issues: %.4f\n', dice);
            end
        end
    catch ME
        fprintf('  ⚠ Dice test failed: %s\n', ME.message);
    end
    
    try
        if exist('calcular_accuracy_simples', 'file')
            acc = calcular_accuracy_simples(pred, gt);
            fprintf('  Accuracy calculation: %.4f\n', acc);
            if acc > 0 && acc < 1
                fprintf('  ✓ Accuracy shows realistic variation (not perfect 1.0)\n');
            else
                fprintf('  ⚠ Accuracy result may indicate issues: %.4f\n', acc);
            end
        end
    catch ME
        fprintf('  ⚠ Accuracy test failed: %s\n', ME.message);
    end
    
    fprintf('\n=== Metric Conversion Logic Test Complete ===\n');
end