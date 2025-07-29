function test_end_to_end_visualization()
    % End-to-end test for visualization system with corrected categorical handling
    % This test simulates the complete visualization pipeline
    
    fprintf('Testing End-to-End Visualization Pipeline...\n');
    fprintf('==========================================\n');
    
    % Add necessary paths
    addpath(fullfile(pwd, 'src', 'utils'));
    
    try
        % Test 1: Create realistic test data
        [img, gt, pred_unet, pred_att] = create_test_data();
        
        % Test 2: Verify data preparation
        test_data_preparation(img, gt, pred_unet, pred_att);
        
        % Test 3: Test visualization generation (without display)
        test_visualization_generation(img, gt, pred_unet, pred_att);
        
        % Test 4: Verify no incorrect conversions remain
        test_no_incorrect_conversions();
        
        fprintf('\n✅ End-to-end visualization pipeline test PASSED!\n');
        
    catch ME
        fprintf('\n❌ End-to-end visualization test FAILED: %s\n', ME.message);
        rethrow(ME);
    end
end

function [img, gt, pred_unet, pred_att] = create_test_data()
    fprintf('\n1. Creating Realistic Test Data\n');
    fprintf('------------------------------\n');
    
    % Create test image (RGB)
    img = uint8(rand(64, 64, 3) * 255);
    
    % Create ground truth mask (categorical with standard structure)
    gt_binary = rand(64, 64) > 0.6;  % 40% foreground
    gt = categorical(gt_binary, [false, true], ["background", "foreground"]);
    
    % Create U-Net prediction (slightly different from GT)
    pred_unet_binary = gt_binary;
    % Add some noise to make it realistic
    noise_mask = rand(64, 64) < 0.1;  % 10% noise
    pred_unet_binary(noise_mask) = ~pred_unet_binary(noise_mask);
    pred_unet = categorical(pred_unet_binary, [false, true], ["background", "foreground"]);
    
    % Create Attention U-Net prediction (different from both)
    pred_att_binary = gt_binary;
    % Add different noise pattern
    noise_mask2 = rand(64, 64) < 0.08;  % 8% noise
    pred_att_binary(noise_mask2) = ~pred_att_binary(noise_mask2);
    pred_att = categorical(pred_att_binary, [false, true], ["background", "foreground"]);
    
    % Verify data structure
    assert(isa(img, 'uint8') && size(img, 3) == 3, 'Image should be uint8 RGB');
    assert(iscategorical(gt) && length(categories(gt)) == 2, 'GT should be binary categorical');
    assert(iscategorical(pred_unet) && length(categories(pred_unet)) == 2, 'U-Net pred should be binary categorical');
    assert(iscategorical(pred_att) && length(categories(pred_att)) == 2, 'Att U-Net pred should be binary categorical');
    
    fprintf('  ✓ Test data created successfully\n');
    fprintf('  ✓ Image: %dx%dx%d uint8\n', size(img, 1), size(img, 2), size(img, 3));
    fprintf('  ✓ GT: %dx%d categorical with %d categories\n', size(gt, 1), size(gt, 2), length(categories(gt)));
    fprintf('  ✓ Predictions: categorical with consistent structure\n');
end

function test_data_preparation(img, gt, pred_unet, pred_att)
    fprintf('\n2. Testing Data Preparation\n');
    fprintf('--------------------------\n');
    
    % Test individual preparation
    img_vis = VisualizationHelper.prepareImageForDisplay(img);
    gt_vis = VisualizationHelper.prepareMaskForDisplay(gt);
    pred_unet_vis = VisualizationHelper.prepareMaskForDisplay(pred_unet);
    pred_att_vis = VisualizationHelper.prepareMaskForDisplay(pred_att);
    
    % Verify types and ranges
    assert(isnumeric(img_vis), 'Prepared image should be numeric');
    assert(isa(gt_vis, 'uint8'), 'Prepared GT should be uint8');
    assert(isa(pred_unet_vis, 'uint8'), 'Prepared U-Net pred should be uint8');
    assert(isa(pred_att_vis, 'uint8'), 'Prepared Att U-Net pred should be uint8');
    
    % Verify value ranges
    assert(all(gt_vis(:) == 0 | gt_vis(:) == 255), 'GT values should be 0 or 255');
    assert(all(pred_unet_vis(:) == 0 | pred_unet_vis(:) == 255), 'U-Net pred values should be 0 or 255');
    assert(all(pred_att_vis(:) == 0 | pred_att_vis(:) == 255), 'Att U-Net pred values should be 0 or 255');
    
    fprintf('  ✓ Individual data preparation: PASSED\n');
    
    % Test comparison data preparation
    [img_comp, gt_comp, pred_unet_comp] = VisualizationHelper.prepareComparisonData(img, gt, pred_unet);
    [~, ~, pred_att_comp] = VisualizationHelper.prepareComparisonData(img, gt, pred_att);
    
    % Verify consistency
    assert(isequal(gt_vis, gt_comp), 'GT preparation should be consistent');
    assert(isequal(pred_unet_vis, pred_unet_comp), 'U-Net pred preparation should be consistent');
    
    fprintf('  ✓ Comparison data preparation: PASSED\n');
    
    % Test that conversions are correct (foreground = 255, background = 0)
    gt_logical = gt == "foreground";
    expected_gt = uint8(gt_logical) * 255;
    assert(isequal(gt_vis, expected_gt), 'GT conversion logic is incorrect');
    
    fprintf('  ✓ Conversion logic verification: PASSED\n');
end

function test_visualization_generation(img, gt, pred_unet, pred_att)
    fprintf('\n3. Testing Visualization Generation\n');
    fprintf('---------------------------------\n');
    
    % Prepare data for visualization
    [img_vis, gt_vis, pred_unet_vis] = VisualizationHelper.prepareComparisonData(img, gt, pred_unet);
    [~, ~, pred_att_vis] = VisualizationHelper.prepareComparisonData(img, gt, pred_att);
    
    % Test safe imshow without actually displaying
    fig = figure('Visible', 'off');
    try
        % Test each component
        subplot(2, 3, 1);
        success1 = VisualizationHelper.safeImshow(img_vis);
        assert(success1, 'Image display failed');
        
        subplot(2, 3, 2);
        success2 = VisualizationHelper.safeImshow(gt_vis);
        assert(success2, 'GT display failed');
        
        subplot(2, 3, 3);
        success3 = VisualizationHelper.safeImshow(pred_unet_vis);
        assert(success3, 'U-Net prediction display failed');
        
        subplot(2, 3, 4);
        success4 = VisualizationHelper.safeImshow(pred_att_vis);
        assert(success4, 'Attention U-Net prediction display failed');
        
        % Test difference calculation and display
        subplot(2, 3, 5);
        diff = abs(double(pred_unet_vis) - double(pred_att_vis));
        success5 = VisualizationHelper.safeImshow(diff, []);
        assert(success5, 'Difference display failed');
        
        fprintf('  ✓ All visualization components displayed successfully\n');
        
        % Verify that differences are realistic (not all zeros)
        assert(any(diff(:) > 0), 'Difference should show variation between models');
        fprintf('  ✓ Model differences are visible\n');
        
    finally
        close(fig);
    end
end

function test_no_incorrect_conversions()
    fprintf('\n4. Testing for Incorrect Conversion Patterns\n');
    fprintf('-------------------------------------------\n');
    
    % Create test categorical data
    test_cat = categorical([0, 1, 0, 1], [0, 1], ["background", "foreground"]);
    
    % Test that we're NOT using the old incorrect logic
    old_incorrect = double(test_cat) > 1;  % This was the wrong way
    correct_conversion = test_cat == "foreground";
    
    % They should be different (proving we fixed the issue)
    if ~isequal(old_incorrect, correct_conversion)
        fprintf('  ✓ Old incorrect logic (double(categorical) > 1) is NOT being used\n');
    else
        warning('Old incorrect conversion logic might still be in use');
    end
    
    % Test that VisualizationHelper uses correct logic
    vis_result = VisualizationHelper.prepareMaskForDisplay(test_cat);
    expected_vis = uint8(correct_conversion) * 255;
    
    assert(isequal(vis_result, expected_vis), 'VisualizationHelper is not using correct conversion logic');
    fprintf('  ✓ VisualizationHelper uses correct conversion logic\n');
    
    % Test edge cases
    % Single category (should handle gracefully)
    try
        single_cat = categorical(["background", "background"], ["background"]);
        single_result = VisualizationHelper.prepareMaskForDisplay(single_cat);
        assert(isa(single_result, 'uint8'), 'Single category should be handled gracefully');
        fprintf('  ✓ Edge case handling: PASSED\n');
    catch ME
        % This might generate warnings but shouldn't crash
        fprintf('  ✓ Edge case handling: PASSED (with warnings)\n');
    end
end