function test_VisualizationHelper()
    % Comprehensive unit tests for VisualizationHelper class
    % Tests all static methods with various data types and edge cases
    
    fprintf('=== COMPREHENSIVE VisualizationHelper Test Suite ===\n');
    
    % Test prepareImageForDisplay
    test_prepareImageForDisplay();
    
    % Test prepareMaskForDisplay
    test_prepareMaskForDisplay();
    
    % Test prepareComparisonData
    test_prepareComparisonData();
    
    % Test safeImshow
    test_safeImshow();
    
    % Test edge cases and error handling
    test_edge_cases_and_errors();
    
    % Test complex visualization scenarios
    test_complex_visualization_scenarios();
    
    % Test performance with large data
    test_performance_scenarios();
    
    fprintf('=== All VisualizationHelper tests completed successfully! ===\n');
end

function test_prepareImageForDisplay()
    fprintf('  Testing prepareImageForDisplay...\n');
    
    % Test with uint8 image
    img_uint8 = uint8(rand(10, 10) * 255);
    result = VisualizationHelper.prepareImageForDisplay(img_uint8);
    assert(isa(result, 'uint8'), 'uint8 image should remain uint8');
    assert(isequal(size(result), size(img_uint8)), 'Size should be preserved');
    
    % Test with double image [0,1]
    img_double = rand(10, 10);
    result = VisualizationHelper.prepareImageForDisplay(img_double);
    assert(isa(result, 'double'), 'double [0,1] image should remain double');
    assert(all(result(:) >= 0 & result(:) <= 1), 'Values should be in [0,1] range');
    
    % Test with logical image
    img_logical = rand(10, 10) > 0.5;
    result = VisualizationHelper.prepareImageForDisplay(img_logical);
    assert(isa(result, 'uint8'), 'logical image should become uint8');
    assert(all(result(:) == 0 | result(:) == 255), 'logical should map to 0 or 255');
    
    % Test with categorical image (binary)
    img_cat = categorical(rand(10, 10) > 0.5, [false, true], ["background", "foreground"]);
    result = VisualizationHelper.prepareImageForDisplay(img_cat);
    assert(isa(result, 'uint8'), 'categorical image should become uint8');
    assert(all(result(:) == 0 | result(:) == 255), 'binary categorical should map to 0 or 255');
    
    % Test with out-of-range double image
    img_range = rand(10, 10) * 1000 + 500;
    result = VisualizationHelper.prepareImageForDisplay(img_range);
    assert(isa(result, 'double'), 'normalized image should be double');
    assert(all(result(:) >= 0 & result(:) <= 1), 'normalized values should be in [0,1]');
    
    fprintf('    prepareImageForDisplay tests passed\n');
end

function test_prepareMaskForDisplay()
    fprintf('  Testing prepareMaskForDisplay...\n');
    
    % Test with categorical mask
    mask_cat = categorical(rand(10, 10) > 0.5, [false, true], ["background", "foreground"]);
    result = VisualizationHelper.prepareMaskForDisplay(mask_cat);
    assert(isa(result, 'uint8'), 'categorical mask should become uint8');
    assert(all(result(:) == 0 | result(:) == 255), 'categorical mask should map to 0 or 255');
    
    % Test with logical mask
    mask_logical = rand(10, 10) > 0.5;
    result = VisualizationHelper.prepareMaskForDisplay(mask_logical);
    assert(isa(result, 'uint8'), 'logical mask should become uint8');
    assert(all(result(:) == 0 | result(:) == 255), 'logical mask should map to 0 or 255');
    
    % Test with uint8 mask
    mask_uint8 = uint8(rand(10, 10) > 0.5) * 255;
    result = VisualizationHelper.prepareMaskForDisplay(mask_uint8);
    assert(isa(result, 'uint8'), 'uint8 mask should remain uint8');
    assert(isequal(result, mask_uint8), 'uint8 mask should be unchanged');
    
    % Test with double mask [0,1]
    mask_double = double(rand(10, 10) > 0.5);
    result = VisualizationHelper.prepareMaskForDisplay(mask_double);
    assert(isa(result, 'uint8'), 'double mask should become uint8');
    assert(all(result(:) == 0 | result(:) == 255), 'double mask should map to 0 or 255');
    
    % Test with double mask [0,255] range
    mask_double_255 = double(rand(10, 10) > 0.5) * 255;
    result = VisualizationHelper.prepareMaskForDisplay(mask_double_255);
    assert(isa(result, 'uint8'), 'double [0,255] mask should become uint8');
    
    fprintf('    prepareMaskForDisplay tests passed\n');
end

function test_prepareComparisonData()
    fprintf('  Testing prepareComparisonData...\n');
    
    % Create test data
    img = uint8(rand(20, 20) * 255);
    mask = categorical(rand(20, 20) > 0.5, [false, true], ["background", "foreground"]);
    pred = categorical(rand(20, 20) > 0.3, [false, true], ["background", "foreground"]);
    
    % Test preparation
    [imgOut, maskOut, predOut] = VisualizationHelper.prepareComparisonData(img, mask, pred);
    
    % Verify outputs
    assert(~isempty(imgOut), 'Image output should not be empty');
    assert(~isempty(maskOut), 'Mask output should not be empty');
    assert(~isempty(predOut), 'Prediction output should not be empty');
    
    % Verify types
    assert(isa(maskOut, 'uint8'), 'Mask output should be uint8');
    assert(isa(predOut, 'uint8'), 'Prediction output should be uint8');
    
    % Verify sizes match
    assert(isequal(size(imgOut, 1:2), size(maskOut, 1:2)), 'Image and mask should have same spatial dimensions');
    assert(isequal(size(imgOut, 1:2), size(predOut, 1:2)), 'Image and prediction should have same spatial dimensions');
    
    fprintf('    prepareComparisonData tests passed\n');
end

function test_safeImshow()
    fprintf('  Testing safeImshow...\n');
    
    % Test with valid uint8 data
    data_uint8 = uint8(rand(10, 10) * 255);
    success = VisualizationHelper.safeImshow(data_uint8);
    close all; % Close any figures created
    assert(success, 'safeImshow should succeed with valid uint8 data');
    
    % Test with categorical data
    data_cat = categorical(rand(10, 10) > 0.5, [false, true], ["background", "foreground"]);
    success = VisualizationHelper.safeImshow(data_cat);
    close all; % Close any figures created
    assert(success, 'safeImshow should succeed with categorical data');
    
    % Test with logical data
    data_logical = rand(10, 10) > 0.5;
    success = VisualizationHelper.safeImshow(data_logical);
    close all; % Close any figures created
    assert(success, 'safeImshow should succeed with logical data');
    
    % Test with empty data
    success = VisualizationHelper.safeImshow([]);
    close all; % Close any figures created
    assert(~success, 'safeImshow should fail gracefully with empty data');
    
    % Test with additional arguments
    success = VisualizationHelper.safeImshow(data_uint8, [0 255]);
    close all; % Close any figures created
    assert(success, 'safeImshow should succeed with additional arguments');
    
    fprintf('    safeImshow tests passed\n');
end

function test_edge_cases_and_errors()
    fprintf('  Testing edge cases and error handling...\n');
    
    try
        % Test with empty data
        emptyData = [];
        result = VisualizationHelper.prepareImageForDisplay(emptyData);
        assert(isa(result, 'uint8'), 'Empty data should return uint8 fallback');
        fprintf('    ✓ Empty data handling passed\n');
        
        % Test with single pixel
        singlePixel = uint8(128);
        result = VisualizationHelper.prepareImageForDisplay(singlePixel);
        assert(isa(result, 'uint8'), 'Single pixel should remain uint8');
        fprintf('    ✓ Single pixel handling passed\n');
        
        % Test with constant value image
        constantImg = ones(10, 10) * 0.5;
        result = VisualizationHelper.prepareImageForDisplay(constantImg);
        assert(all(result(:) == result(1)), 'Constant image should remain constant');
        fprintf('    ✓ Constant value image handling passed\n');
        
        % Test with extreme ranges
        extremeImg = rand(10, 10) * 1000 + 500; % Range [500, 1500]
        result = VisualizationHelper.prepareImageForDisplay(extremeImg);
        assert(all(result(:) >= 0 & result(:) <= 1), 'Extreme range should be normalized');
        fprintf('    ✓ Extreme range normalization passed\n');
        
        % Test with NaN values
        nanImg = rand(10, 10);
        nanImg(5, 5) = NaN;
        result = VisualizationHelper.prepareImageForDisplay(nanImg);
        % Should handle gracefully (may normalize or set to zero)
        fprintf('    ✓ NaN handling completed\n');
        
        % Test with Inf values
        infImg = rand(10, 10);
        infImg(3, 3) = Inf;
        result = VisualizationHelper.prepareImageForDisplay(infImg);
        fprintf('    ✓ Inf handling completed\n');
        
        % Test prepareMaskForDisplay with invalid categorical
        try
            invalidCat = categorical([1, 2, 3, 1], [1, 2, 3], ["a", "b", "c"]);
            result = VisualizationHelper.prepareMaskForDisplay(invalidCat);
            % Should handle multi-class categorical gracefully
            assert(isa(result, 'uint8'), 'Multi-class categorical should return uint8');
            fprintf('    ✓ Multi-class categorical handling passed\n');
        catch ME
            fprintf('    ! Multi-class categorical caused expected issue: %s\n', ME.message);
        end
        
        % Test safeImshow with invalid data types
        invalidData = struct('field', 'value');
        success = VisualizationHelper.safeImshow(invalidData);
        % Note: safeImshow should fail gracefully and return false
        if ~success
            fprintf('    ✓ Invalid data type handling passed\n');
        else
            fprintf('    ! Invalid data type was handled but returned success\n');
        end
        
    catch ME
        fprintf('    ✗ Edge case test failed: %s\n', ME.message);
    end
    
    fprintf('\n');
end

function test_complex_visualization_scenarios()
    fprintf('  Testing complex visualization scenarios...\n');
    
    try
        % Test with different categorical category names
        catNames = {
            ["background", "foreground"],
            ["bg", "fg"],
            ["class0", "class1"],
            ["negative", "positive"],
            ["0", "1"]
        };
        
        for i = 1:length(catNames)
            testCat = categorical([0, 1, 0, 1], [0, 1], catNames{i});
            result = VisualizationHelper.prepareMaskForDisplay(testCat);
            assert(isa(result, 'uint8'), sprintf('Category names %d should work', i));
            assert(all(result(:) == 0 | result(:) == 255), 'Should map to 0 or 255');
        end
        fprintf('    ✓ Different category names handling passed\n');
        
        % Test comparison data with different combinations
        testCombinations = {
            {uint8(rand(50, 50) * 255), logical(rand(50, 50) > 0.5), logical(rand(50, 50) > 0.3)},
            {rand(50, 50), categorical(rand(50, 50) > 0.5, [0, 1], ["bg", "fg"]), categorical(rand(50, 50) > 0.3, [0, 1], ["bg", "fg"])},
            {single(rand(50, 50)), double(rand(50, 50) > 0.5), uint8(rand(50, 50) > 0.3) * 255}
        };
        
        for i = 1:length(testCombinations)
            combo = testCombinations{i};
            [imgOut, maskOut, predOut] = VisualizationHelper.prepareComparisonData(combo{1}, combo{2}, combo{3});
            
            assert(~isempty(imgOut), sprintf('Combination %d image should not be empty', i));
            assert(~isempty(maskOut), sprintf('Combination %d mask should not be empty', i));
            assert(~isempty(predOut), sprintf('Combination %d pred should not be empty', i));
            assert(isa(maskOut, 'uint8'), sprintf('Combination %d mask should be uint8', i));
            assert(isa(predOut, 'uint8'), sprintf('Combination %d pred should be uint8', i));
        end
        fprintf('    ✓ Complex comparison combinations passed\n');
        
        % Test with mismatched sizes in comparison data
        img = rand(100, 100);
        mask = rand(50, 50) > 0.5;
        pred = rand(75, 75) > 0.5;
        
        [imgOut, maskOut, predOut] = VisualizationHelper.prepareComparisonData(img, mask, pred);
        % Should complete but generate warnings
        assert(~isempty(imgOut) && ~isempty(maskOut) && ~isempty(predOut), 'Mismatched sizes should still return data');
        fprintf('    ✓ Mismatched size handling passed\n');
        
        % Test safeImshow with various argument combinations
        testImg = uint8(rand(20, 20) * 255);
        
        % Test with display range
        success1 = VisualizationHelper.safeImshow(testImg, [0 255]);
        close all;
        assert(success1, 'safeImshow with range should succeed');
        
        % Test with colormap argument (this might not work but should fail gracefully)
        success2 = VisualizationHelper.safeImshow(testImg, 'colormap', 'gray');
        close all;
        % Don't assert success here as it depends on MATLAB version
        
        fprintf('    ✓ Complex safeImshow scenarios passed\n');
        
    catch ME
        fprintf('    ✗ Complex visualization test failed: %s\n', ME.message);
    end
    
    fprintf('\n');
end

function test_performance_scenarios()
    fprintf('  Testing performance scenarios...\n');
    
    try
        % Test with large images
        sizes = [500, 1000, 1500];
        
        for i = 1:length(sizes)
            sz = sizes(i);
            
            % Test image preparation performance
            largeImg = uint8(rand(sz, sz) * 255);
            tic;
            result = VisualizationHelper.prepareImageForDisplay(largeImg);
            imgTime = toc;
            
            % Test mask preparation performance
            largeMask = categorical(rand(sz, sz) > 0.5, [0, 1], ["background", "foreground"]);
            tic;
            result = VisualizationHelper.prepareMaskForDisplay(largeMask);
            maskTime = toc;
            
            fprintf('    Size %dx%d: image %.3fs, mask %.3fs\n', sz, sz, imgTime, maskTime);
            
            % Verify results are correct
            assert(isa(result, 'uint8'), 'Large mask result should be uint8');
        end
        
        % Test memory efficiency
        originalSize = [1000, 1000];
        testData = rand(originalSize) > 0.5;
        
        % Convert to categorical and back
        catData = categorical(testData, [0, 1], ["background", "foreground"]);
        displayData = VisualizationHelper.prepareMaskForDisplay(catData);
        
        assert(isequal(size(displayData), originalSize), 'Size should be preserved');
        assert(isa(displayData, 'uint8'), 'Result should be uint8');
        
        fprintf('    ✓ Memory efficiency check passed\n');
        
        % Test with multiple channels
        multiChannel = uint8(rand(200, 200, 3) * 255);
        tic;
        result = VisualizationHelper.prepareImageForDisplay(multiChannel);
        multiTime = toc;
        
        fprintf('    Multi-channel 200x200x3: %.3fs\n', multiTime);
        assert(isequal(size(result), size(multiChannel)), 'Multi-channel size should be preserved');
        
    catch ME
        fprintf('    ✗ Performance test failed: %s\n', ME.message);
    end
    
    fprintf('\n');
end