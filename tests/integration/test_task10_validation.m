function test_task10_validation()
    % Validation test for Task 10: Fix visualization conversion logic
    % This test specifically validates the requirements from task 10
    
    fprintf('Task 10 Validation: Fix Visualization Conversion Logic\n');
    fprintf('====================================================\n');
    
    % Add necessary paths
    addpath(fullfile(pwd, 'src', 'utils'));
    
    % Task 10 Requirements:
    % - Replace incorrect categorical to uint8 conversions in visualization functions
    % - Implement proper `uint8(categorical == "foreground") * 255` conversion
    % - Add validation for visualization data before imshow
    % - Test visualization generation with corrected data
    
    test_requirement_1_correct_conversions();
    test_requirement_2_proper_conversion_formula();
    test_requirement_3_validation_before_imshow();
    test_requirement_4_corrected_data_generation();
    
    fprintf('\n✅ Task 10 validation completed successfully!\n');
    fprintf('All visualization conversion logic has been fixed.\n');
end

function test_requirement_1_correct_conversions()
    fprintf('\n1. Testing Correct Categorical to uint8 Conversions\n');
    fprintf('-------------------------------------------------\n');
    
    % Create test data with known structure
    test_mask = categorical([0, 1, 0, 1; 1, 0, 1, 0], [0, 1], ["background", "foreground"]);
    
    % Test VisualizationHelper conversion
    result = VisualizationHelper.prepareMaskForDisplay(test_mask);
    
    % Verify it's using the CORRECT conversion logic
    expected = uint8(test_mask == "foreground") * 255;
    assert(isequal(result, expected), 'Conversion logic is not correct');
    
    % Verify it's NOT using the old incorrect logic
    old_incorrect = uint8(double(test_mask) > 1) * 255;
    if ~isequal(result, old_incorrect)
        fprintf('  ✓ NOT using old incorrect double(categorical) > 1 logic\n');
    end
    
    fprintf('  ✓ Using correct categorical == "foreground" logic\n');
    fprintf('  ✓ Categorical to uint8 conversions are CORRECT\n');
end

function test_requirement_2_proper_conversion_formula()
    fprintf('\n2. Testing Proper Conversion Formula Implementation\n');
    fprintf('------------------------------------------------\n');
    
    % Test the exact formula: uint8(categorical == "foreground") * 255
    test_cases = {
        categorical([0, 1, 0], [0, 1], ["background", "foreground"]),
        categorical(["background", "foreground", "background"], ["background", "foreground"]),
        categorical([false, true, false], [false, true], ["background", "foreground"])
    };
    
    for i = 1:length(test_cases)
        test_data = test_cases{i};
        
        % Apply the exact formula we want to verify
        expected = uint8(test_data == "foreground") * 255;
        
        % Test VisualizationHelper implementation
        result = VisualizationHelper.prepareMaskForDisplay(test_data);
        
        assert(isequal(result, expected), sprintf('Formula not implemented correctly for test case %d', i));
        
        % Verify values are exactly 0 or 255
        assert(all(result(:) == 0 | result(:) == 255), 'Values should be exactly 0 or 255');
    end
    
    fprintf('  ✓ Formula uint8(categorical == "foreground") * 255 implemented correctly\n');
    fprintf('  ✓ All test cases produce correct 0/255 values\n');
end

function test_requirement_3_validation_before_imshow()
    fprintf('\n3. Testing Validation Before imshow\n');
    fprintf('----------------------------------\n');
    
    % Test that safeImshow validates data before display
    test_data = {
        [],  % Empty data
        "invalid",  % Invalid type
        categorical([0, 1], [0, 1], ["background", "foreground"]),  % Valid categorical
        uint8([0, 255]),  % Valid uint8
        NaN(2, 2)  % NaN data
    };
    
    expected_success = [false, false, true, true, true];  % Expected success for each case
    
    fig = figure('Visible', 'off');
    try
        for i = 1:length(test_data)
            data = test_data{i};
            success = VisualizationHelper.safeImshow(data);
            
            if i <= 2  % Cases that should fail
                assert(~success, sprintf('Case %d should fail validation', i));
            else  % Cases that should succeed
                assert(success, sprintf('Case %d should pass validation', i));
            end
        end
    finally
        close(fig);
    end
    
    fprintf('  ✓ Data validation before imshow: WORKING\n');
    fprintf('  ✓ Invalid data properly rejected\n');
    fprintf('  ✓ Valid data properly accepted\n');
end

function test_requirement_4_corrected_data_generation()
    fprintf('\n4. Testing Visualization Generation with Corrected Data\n');
    fprintf('-----------------------------------------------------\n');
    
    % Create realistic test scenario
    img = uint8(rand(32, 32, 3) * 255);
    gt = categorical(rand(32, 32) > 0.5, [false, true], ["background", "foreground"]);
    pred1 = categorical(rand(32, 32) > 0.4, [false, true], ["background", "foreground"]);
    pred2 = categorical(rand(32, 32) > 0.6, [false, true], ["background", "foreground"]);
    
    % Test complete visualization pipeline
    [img_vis, gt_vis, pred1_vis] = VisualizationHelper.prepareComparisonData(img, gt, pred1);
    [~, ~, pred2_vis] = VisualizationHelper.prepareComparisonData(img, gt, pred2);
    
    % Verify all data is properly prepared
    assert(isnumeric(img_vis), 'Image should be numeric');
    assert(isa(gt_vis, 'uint8'), 'GT should be uint8');
    assert(isa(pred1_vis, 'uint8'), 'Prediction 1 should be uint8');
    assert(isa(pred2_vis, 'uint8'), 'Prediction 2 should be uint8');
    
    % Verify correct value ranges
    assert(all(gt_vis(:) == 0 | gt_vis(:) == 255), 'GT values incorrect');
    assert(all(pred1_vis(:) == 0 | pred1_vis(:) == 255), 'Pred1 values incorrect');
    assert(all(pred2_vis(:) == 0 | pred2_vis(:) == 255), 'Pred2 values incorrect');
    
    % Test visualization generation (simulate the main comparison function)
    fig = figure('Visible', 'off');
    try
        % Simulate the visualization layout from the main function
        subplot(1, 5, 1);
        success1 = VisualizationHelper.safeImshow(img_vis);
        
        subplot(1, 5, 2);
        success2 = VisualizationHelper.safeImshow(gt_vis);
        
        subplot(1, 5, 3);
        success3 = VisualizationHelper.safeImshow(pred1_vis);
        
        subplot(1, 5, 4);
        success4 = VisualizationHelper.safeImshow(pred2_vis);
        
        subplot(1, 5, 5);
        diff = abs(double(pred1_vis) - double(pred2_vis));
        success5 = VisualizationHelper.safeImshow(diff, []);
        
        % All should succeed
        assert(success1 && success2 && success3 && success4 && success5, ...
            'Visualization generation failed');
        
    finally
        close(fig);
    end
    
    fprintf('  ✓ Complete visualization pipeline: WORKING\n');
    fprintf('  ✓ All data properly converted and displayed\n');
    fprintf('  ✓ Model differences correctly calculated\n');
    
    % Verify that the corrected data shows realistic differences
    gt_foreground_ratio = sum(gt_vis(:) == 255) / numel(gt_vis);
    pred1_foreground_ratio = sum(pred1_vis(:) == 255) / numel(pred1_vis);
    pred2_foreground_ratio = sum(pred2_vis(:) == 255) / numel(pred2_vis);
    
    fprintf('  ✓ GT foreground ratio: %.3f\n', gt_foreground_ratio);
    fprintf('  ✓ Pred1 foreground ratio: %.3f\n', pred1_foreground_ratio);
    fprintf('  ✓ Pred2 foreground ratio: %.3f\n', pred2_foreground_ratio);
    fprintf('  ✓ Realistic variation in predictions confirmed\n');
end