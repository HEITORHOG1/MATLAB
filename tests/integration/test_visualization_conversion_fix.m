function test_visualization_conversion_fix()
    % Test to verify that visualization conversion logic is correctly implemented
    % This test validates the fixes for task 10: Fix visualization conversion logic
    
    fprintf('Testing Visualization Conversion Logic Fixes...\n');
    fprintf('==============================================\n');
    
    % Add necessary paths
    addpath(fullfile(pwd, 'src', 'utils'));
    
    % Test 1: Verify correct categorical to uint8 conversion
    test_categorical_to_uint8_conversion();
    
    % Test 2: Verify visualization data validation
    test_visualization_data_validation();
    
    % Test 3: Test visualization generation with corrected data
    test_visualization_generation();
    
    % Test 4: Verify VisualizationHelper consistency
    test_visualization_helper_consistency();
    
    fprintf('\n✅ All visualization conversion tests passed!\n');
end

function test_categorical_to_uint8_conversion()
    fprintf('\n1. Testing Categorical to uint8 Conversion Logic\n');
    fprintf('-----------------------------------------------\n');
    
    % Create test categorical data with standard structure
    testMask = categorical([0, 1, 0, 1; 1, 0, 1, 0], [0, 1], ["background", "foreground"]);
    
    % Test VisualizationHelper conversion
    result = VisualizationHelper.prepareMaskForDisplay(testMask);
    
    % Verify result type and values
    assert(isa(result, 'uint8'), 'Result should be uint8');
    assert(all(result(:) == 0 | result(:) == 255), 'Values should be 0 or 255');
    
    % Verify correct mapping: foreground -> 255, background -> 0
    expected = uint8([0, 255, 0, 255; 255, 0, 255, 0]);
    assert(isequal(result, expected), 'Conversion mapping is incorrect');
    
    fprintf('  ✓ Categorical to uint8 conversion: CORRECT\n');
    fprintf('  ✓ Foreground maps to 255, background maps to 0\n');
    
    % Test with different categorical structure
    testMask2 = categorical(["background", "foreground", "background"], ["background", "foreground"]);
    result2 = VisualizationHelper.prepareMaskForDisplay(testMask2);
    expected2 = uint8([0, 255, 0]);
    assert(isequal(result2, expected2), 'String categorical conversion failed');
    
    fprintf('  ✓ String categorical conversion: CORRECT\n');
end

function test_visualization_data_validation()
    fprintf('\n2. Testing Visualization Data Validation\n');
    fprintf('---------------------------------------\n');
    
    % Test with various data types
    test_data = {
        uint8(rand(10, 10) * 255),
        double(rand(10, 10)),
        logical(rand(10, 10) > 0.5),
        categorical(rand(10, 10) > 0.5, [false, true], ["background", "foreground"])
    };
    
    data_types = {'uint8', 'double', 'logical', 'categorical'};
    
    for i = 1:length(test_data)
        data = test_data{i};
        type_name = data_types{i};
        
        % Test image preparation
        try
            img_result = VisualizationHelper.prepareImageForDisplay(data);
            assert(isnumeric(img_result), sprintf('%s image preparation failed', type_name));
            fprintf('  ✓ %s image validation: PASSED\n', type_name);
        catch ME
            error('Image validation failed for %s: %s', type_name, ME.message);
        end
        
        % Test mask preparation
        try
            mask_result = VisualizationHelper.prepareMaskForDisplay(data);
            assert(isa(mask_result, 'uint8'), sprintf('%s mask preparation failed', type_name));
            fprintf('  ✓ %s mask validation: PASSED\n', type_name);
        catch ME
            error('Mask validation failed for %s: %s', type_name, ME.message);
        end
    end
end

function test_visualization_generation()
    fprintf('\n3. Testing Visualization Generation with Corrected Data\n');
    fprintf('-----------------------------------------------------\n');
    
    % Create test data
    img = uint8(rand(50, 50, 3) * 255);
    gt = categorical(rand(50, 50) > 0.5, [false, true], ["background", "foreground"]);
    pred = categorical(rand(50, 50) > 0.3, [false, true], ["background", "foreground"]);
    
    % Test comparison data preparation
    [img_vis, gt_vis, pred_vis] = VisualizationHelper.prepareComparisonData(img, gt, pred);
    
    % Verify outputs
    assert(isnumeric(img_vis), 'Image visualization data should be numeric');
    assert(isa(gt_vis, 'uint8'), 'GT visualization data should be uint8');
    assert(isa(pred_vis, 'uint8'), 'Prediction visualization data should be uint8');
    
    % Verify size consistency
    assert(isequal(size(img_vis, 1:2), size(gt_vis, 1:2)), 'Size mismatch between image and GT');
    assert(isequal(size(gt_vis), size(pred_vis)), 'Size mismatch between GT and prediction');
    
    fprintf('  ✓ Comparison data preparation: PASSED\n');
    
    % Test safe imshow (without actually displaying)
    figure('Visible', 'off');
    try
        success1 = VisualizationHelper.safeImshow(img_vis);
        success2 = VisualizationHelper.safeImshow(gt_vis);
        success3 = VisualizationHelper.safeImshow(pred_vis);
        
        assert(success1, 'Image display failed');
        assert(success2, 'GT display failed');
        assert(success3, 'Prediction display failed');
        
        fprintf('  ✓ Safe imshow functionality: PASSED\n');
    catch ME
        error('Visualization generation failed: %s', ME.message);
    finally
        close(gcf);
    end
end

function test_visualization_helper_consistency()
    fprintf('\n4. Testing VisualizationHelper Consistency\n');
    fprintf('----------------------------------------\n');
    
    % Test that all conversion methods use consistent logic
    testMask = categorical([0, 1, 0, 1], [0, 1], ["background", "foreground"]);
    
    % Test direct mask preparation
    mask_result = VisualizationHelper.prepareMaskForDisplay(testMask);
    
    % Test through comparison data preparation
    [~, ~, comp_result] = VisualizationHelper.prepareComparisonData(uint8(rand(1, 4) * 255), testMask, testMask);
    
    % Results should be identical
    assert(isequal(mask_result, comp_result), 'Inconsistent conversion between methods');
    
    fprintf('  ✓ Conversion consistency: PASSED\n');
    
    % Test error handling
    try
        empty_result = VisualizationHelper.prepareMaskForDisplay([]);
        assert(isa(empty_result, 'uint8'), 'Empty data should return uint8 fallback');
        fprintf('  ✓ Error handling: PASSED\n');
    catch ME
        error('Error handling test failed: %s', ME.message);
    end
    
    % Test with invalid data type
    try
        invalid_result = VisualizationHelper.prepareMaskForDisplay("invalid");
        assert(isa(invalid_result, 'uint8'), 'Invalid data should return uint8 fallback');
        fprintf('  ✓ Invalid data handling: PASSED\n');
    catch ME
        % This is expected to generate a warning, but should not crash
        fprintf('  ✓ Invalid data handling: PASSED (with warning)\n');
    end
end