function test_PreprocessingValidator()
    % Comprehensive unit tests for PreprocessingValidator class
    
    fprintf('=== COMPREHENSIVE PreprocessingValidator Test Suite ===\n\n');
    
    % Test image validation
    test_validateImageData();
    
    % Test mask validation  
    test_validateMaskData();
    
    % Test RGB preparation
    test_prepareForRGBOperation();
    
    % Test categorical preparation
    test_prepareForCategoricalOperation();
    
    % Test data compatibility
    test_validateDataCompatibility();
    
    % Test edge cases and error scenarios
    test_edge_cases_and_errors();
    
    % Test validation reporting
    test_validation_reporting();
    
    % Test complex data scenarios
    test_complex_data_scenarios();
    
    fprintf('=== All PreprocessingValidator tests completed! ===\n');
end

function test_validateImageData()
    fprintf('Testing validateImageData...\n');
    
    try
        % Test valid uint8 image
        img_uint8 = uint8(rand(100, 100, 3) * 255);
        PreprocessingValidator.validateImageData(img_uint8);
        fprintf('  ✓ Valid uint8 image passed\n');
        
        % Test valid double image
        img_double = rand(50, 50);
        PreprocessingValidator.validateImageData(img_double);
        fprintf('  ✓ Valid double image passed\n');
        
        % Test valid single image
        img_single = single(rand(75, 75));
        PreprocessingValidator.validateImageData(img_single);
        fprintf('  ✓ Valid single image passed\n');
        
        % Test empty image (should fail)
        try
            PreprocessingValidator.validateImageData([]);
            fprintf('  ✗ Empty image should have failed\n');
        catch ME
            if contains(ME.identifier, 'EmptyImage')
                fprintf('  ✓ Empty image correctly rejected\n');
            else
                fprintf('  ✗ Empty image failed with wrong error: %s\n', ME.identifier);
            end
        end
        
        % Test invalid type (should fail)
        try
            PreprocessingValidator.validateImageData(categorical([1,2,1,2]));
            fprintf('  ✗ Categorical image should have failed\n');
        catch ME
            if contains(ME.identifier, 'InvalidImageType')
                fprintf('  ✓ Categorical image correctly rejected\n');
            else
                fprintf('  ✗ Categorical image failed with wrong error: %s\n', ME.identifier);
            end
        end
        
        % Test image with NaN (should fail)
        try
            img_nan = rand(10, 10);
            img_nan(5, 5) = NaN;
            PreprocessingValidator.validateImageData(img_nan);
            fprintf('  ✗ Image with NaN should have failed\n');
        catch ME
            if contains(ME.identifier, 'NaNValues')
                fprintf('  ✓ Image with NaN correctly rejected\n');
            else
                fprintf('  ✗ Image with NaN failed with wrong error: %s\n', ME.identifier);
            end
        end
        
    catch ME
        fprintf('  ✗ Unexpected error in validateImageData: %s\n', ME.message);
    end
    
    fprintf('\n');
end

function test_validateMaskData()
    fprintf('Testing validateMaskData...\n');
    
    try
        % Test valid uint8 mask
        mask_uint8 = uint8(rand(100, 100) > 0.5) * 255;
        PreprocessingValidator.validateMaskData(mask_uint8);
        fprintf('  ✓ Valid uint8 mask passed\n');
        
        % Test valid double mask
        mask_double = double(rand(50, 50) > 0.5);
        PreprocessingValidator.validateMaskData(mask_double);
        fprintf('  ✓ Valid double mask passed\n');
        
        % Test valid logical mask
        mask_logical = rand(75, 75) > 0.5;
        PreprocessingValidator.validateMaskData(mask_logical);
        fprintf('  ✓ Valid logical mask passed\n');
        
        % Test valid categorical mask
        mask_cat = categorical(rand(30, 30) > 0.5, [0, 1], ["background", "foreground"]);
        PreprocessingValidator.validateMaskData(mask_cat);
        fprintf('  ✓ Valid categorical mask passed\n');
        
        % Test empty mask (should fail)
        try
            PreprocessingValidator.validateMaskData([]);
            fprintf('  ✗ Empty mask should have failed\n');
        catch ME
            if contains(ME.identifier, 'EmptyMask')
                fprintf('  ✓ Empty mask correctly rejected\n');
            else
                fprintf('  ✗ Empty mask failed with wrong error: %s\n', ME.identifier);
            end
        end
        
        % Test invalid type (should fail)
        try
            PreprocessingValidator.validateMaskData("invalid");
            fprintf('  ✗ String mask should have failed\n');
        catch ME
            if contains(ME.identifier, 'InvalidMaskType')
                fprintf('  ✓ String mask correctly rejected\n');
            else
                fprintf('  ✗ String mask failed with wrong error: %s\n', ME.identifier);
            end
        end
        
    catch ME
        fprintf('  ✗ Unexpected error in validateMaskData: %s\n', ME.message);
    end
    
    fprintf('\n');
end

function test_prepareForRGBOperation()
    fprintf('Testing prepareForRGBOperation...\n');
    
    try
        % Test categorical to RGB preparation
        cat_data = categorical(rand(50, 50) > 0.5, [0, 1], ["background", "foreground"]);
        rgb_data = PreprocessingValidator.prepareForRGBOperation(cat_data);
        if isa(rgb_data, 'uint8') && ~iscategorical(rgb_data)
            fprintf('  ✓ Categorical to RGB conversion successful\n');
        else
            fprintf('  ✗ Categorical to RGB conversion failed: got %s\n', class(rgb_data));
        end
        
        % Test logical to RGB preparation
        logical_data = rand(30, 30) > 0.5;
        rgb_logical = PreprocessingValidator.prepareForRGBOperation(logical_data);
        if isa(rgb_logical, 'uint8')
            fprintf('  ✓ Logical to RGB conversion successful\n');
        else
            fprintf('  ✗ Logical to RGB conversion failed: got %s\n', class(rgb_logical));
        end
        
        % Test double to RGB preparation (normalized)
        double_norm = rand(40, 40);
        rgb_double = PreprocessingValidator.prepareForRGBOperation(double_norm);
        if isa(rgb_double, 'double') || isa(rgb_double, 'single')
            fprintf('  ✓ Normalized double RGB preparation successful\n');
        else
            fprintf('  ✗ Normalized double RGB preparation failed: got %s\n', class(rgb_double));
        end
        
        % Test uint8 (should remain unchanged)
        uint8_data = uint8(rand(25, 25) * 255);
        rgb_uint8 = PreprocessingValidator.prepareForRGBOperation(uint8_data);
        if isa(rgb_uint8, 'uint8')
            fprintf('  ✓ uint8 RGB preparation successful (no change needed)\n');
        else
            fprintf('  ✗ uint8 RGB preparation failed: got %s\n', class(rgb_uint8));
        end
        
    catch ME
        fprintf('  ✗ Unexpected error in prepareForRGBOperation: %s\n', ME.message);
    end
    
    fprintf('\n');
end

function test_prepareForCategoricalOperation()
    fprintf('Testing prepareForCategoricalOperation...\n');
    
    try
        % Test double to categorical preparation
        double_data = double(rand(50, 50) > 0.5);
        cat_double = PreprocessingValidator.prepareForCategoricalOperation(double_data);
        if iscategorical(cat_double)
            fprintf('  ✓ Double to categorical conversion successful\n');
        else
            fprintf('  ✗ Double to categorical conversion failed: got %s\n', class(cat_double));
        end
        
        % Test uint8 to categorical preparation
        uint8_data = uint8(rand(30, 30) > 0.5) * 255;
        cat_uint8 = PreprocessingValidator.prepareForCategoricalOperation(uint8_data);
        if iscategorical(cat_uint8)
            fprintf('  ✓ uint8 to categorical conversion successful\n');
        else
            fprintf('  ✗ uint8 to categorical conversion failed: got %s\n', class(cat_uint8));
        end
        
        % Test logical to categorical preparation
        logical_data = rand(40, 40) > 0.5;
        cat_logical = PreprocessingValidator.prepareForCategoricalOperation(logical_data);
        if iscategorical(cat_logical)
            fprintf('  ✓ Logical to categorical conversion successful\n');
        else
            fprintf('  ✗ Logical to categorical conversion failed: got %s\n', class(cat_logical));
        end
        
        % Test categorical (should remain unchanged but validated)
        cat_data = categorical(rand(25, 25) > 0.5, [0, 1], ["background", "foreground"]);
        cat_validated = PreprocessingValidator.prepareForCategoricalOperation(cat_data);
        if iscategorical(cat_validated)
            fprintf('  ✓ Categorical validation successful (no change needed)\n');
        else
            fprintf('  ✗ Categorical validation failed: got %s\n', class(cat_validated));
        end
        
    catch ME
        fprintf('  ✗ Unexpected error in prepareForCategoricalOperation: %s\n', ME.message);
    end
    
    fprintf('\n');
end

function test_validateDataCompatibility()
    fprintf('Testing validateDataCompatibility...\n');
    
    try
        % Test compatible data
        img = rand(100, 100, 3);
        mask = rand(100, 100) > 0.5;
        result = PreprocessingValidator.validateDataCompatibility(img, mask);
        
        if result.isCompatible
            fprintf('  ✓ Compatible data correctly identified\n');
        else
            fprintf('  ✗ Compatible data incorrectly rejected\n');
        end
        
        % Test incompatible dimensions
        img2 = rand(100, 100);
        mask2 = rand(50, 50) > 0.5;
        result2 = PreprocessingValidator.validateDataCompatibility(img2, mask2);
        
        if ~result2.isCompatible
            fprintf('  ✓ Incompatible dimensions correctly identified\n');
        else
            fprintf('  ✗ Incompatible dimensions not detected\n');
        end
        
        % Test mixed types (should generate warnings but be compatible)
        img3 = rand(75, 75);
        mask3 = categorical(rand(75, 75) > 0.5, [0, 1], ["background", "foreground"]);
        result3 = PreprocessingValidator.validateDataCompatibility(img3, mask3);
        
        if result3.isCompatible && ~isempty(result3.warnings)
            fprintf('  ✓ Mixed types correctly handled with warnings\n');
        else
            fprintf('  ✗ Mixed types not properly handled\n');
        end
        
    catch ME
        fprintf('  ✗ Unexpected error in validateDataCompatibility: %s\n', ME.message);
    end
    
    fprintf('\n');
end
f
unction test_edge_cases_and_errors()
    fprintf('Testing edge cases and error scenarios...\n');
    
    % Test validateImageData with various invalid inputs
    try
        % Test with string input
        try
            PreprocessingValidator.validateImageData("invalid");
            fprintf('  ✗ String input should have failed\n');
        catch ME
            if contains(ME.identifier, 'InvalidImageType')
                fprintf('  ✓ String input correctly rejected\n');
            else
                fprintf('  ✗ String input failed with wrong error: %s\n', ME.identifier);
            end
        end
        
        % Test with cell array input
        try
            PreprocessingValidator.validateImageData({1, 2, 3});
            fprintf('  ✗ Cell array input should have failed\n');
        catch ME
            if contains(ME.identifier, 'InvalidImageType')
                fprintf('  ✓ Cell array input correctly rejected\n');
            else
                fprintf('  ✗ Cell array failed with wrong error: %s\n', ME.identifier);
            end
        end
        
        % Test with 1D data
        try
            PreprocessingValidator.validateImageData([1, 2, 3, 4, 5]);
            fprintf('  ✗ 1D data should have failed\n');
        catch ME
            if contains(ME.identifier, 'InvalidDimensions')
                fprintf('  ✓ 1D data correctly rejected\n');
            else
                fprintf('  ✗ 1D data failed with wrong error: %s\n', ME.identifier);
            end
        end
        
        % Test with too many dimensions
        try
            PreprocessingValidator.validateImageData(rand(10, 10, 3, 5, 2));
            fprintf('  ✗ 5D data should have failed\n');
        catch ME
            if contains(ME.identifier, 'TooManyDimensions')
                fprintf('  ✓ 5D data correctly rejected\n');
            else
                fprintf('  ✗ 5D data failed with wrong error: %s\n', ME.identifier);
            end
        end
        
        % Test with zero dimensions
        try
            PreprocessingValidator.validateImageData(zeros(0, 10));
            fprintf('  ✗ Zero height should have failed\n');
        catch ME
            if contains(ME.identifier, 'InvalidSize')
                fprintf('  ✓ Zero height correctly rejected\n');
            else
                fprintf('  ✗ Zero height failed with wrong error: %s\n', ME.identifier);
            end
        end
        
        % Test with out-of-range uint8 values (this shouldn't happen but test anyway)
        invalidUint8 = uint8([100, 200, 50]);
        try
            PreprocessingValidator.validateImageData(invalidUint8);
            fprintf('  ✓ Valid uint8 range accepted\n');
        catch ME
            fprintf('  ✗ Valid uint8 unexpectedly rejected: %s\n', ME.message);
        end
        
    catch ME
        fprintf('  ✗ Unexpected error in edge case testing: %s\n', ME.message);
    end
    
    fprintf('\n');
end

function test_validation_reporting()
    fprintf('Testing validation reporting functionality...\n');
    
    try
        % Test single validation result reporting
        result = struct();
        result.isCompatible = true;
        result.warnings = {'Test warning 1', 'Test warning 2'};
        result.errors = {};
        result.imageSize = [100, 100, 3];
        result.maskSize = [100, 100];
        result.imageType = 'uint8';
        result.maskType = 'logical';
        
        fprintf('  Testing single validation report:\n');
        PreprocessingValidator.reportValidationSummary(result);
        
        % Test multiple validation results
        result2 = struct();
        result2.isValid = false;
        result2.warnings = {};
        result2.errors = {'Critical error'};
        
        results = {result, result2};
        fprintf('  Testing multiple validation reports:\n');
        PreprocessingValidator.reportValidationSummary(results);
        
        % Test invalid input to reporting
        fprintf('  Testing invalid input to reporting:\n');
        PreprocessingValidator.reportValidationSummary('invalid');
        
        fprintf('  ✓ Validation reporting tests passed\n');
        
    catch ME
        fprintf('  ✗ Validation reporting test failed: %s\n', ME.message);
    end
    
    fprintf('\n');
end

function test_complex_data_scenarios()
    fprintf('Testing complex data scenarios...\n');
    
    try
        % Test with very large images
        largeImg = uint8(rand(2000, 2000) * 255);
        PreprocessingValidator.validateImageData(largeImg);
        fprintf('  ✓ Large image validation passed\n');
        
        % Test with multi-channel images
        rgbImg = uint8(rand(100, 100, 3) * 255);
        PreprocessingValidator.validateImageData(rgbImg);
        fprintf('  ✓ RGB image validation passed\n');
        
        % Test with hyperspectral-like data
        hyperImg = single(rand(50, 50, 10));
        PreprocessingValidator.validateImageData(hyperImg);
        fprintf('  ✓ Multi-channel image validation passed\n');
        
        % Test RGB preparation with different input types
        testInputs = {
            uint8(rand(50, 50) * 255),
            rand(50, 50),
            rand(50, 50) > 0.5,
            categorical(rand(50, 50) > 0.5, [0, 1], ["background", "foreground"]),
            single(rand(50, 50))
        };
        
        for i = 1:length(testInputs)
            try
                result = PreprocessingValidator.prepareForRGBOperation(testInputs{i});
                assert(~iscategorical(result), 'RGB preparation should not return categorical');
                fprintf('  ✓ RGB preparation test %d passed\n', i);
            catch ME
                fprintf('  ✗ RGB preparation test %d failed: %s\n', i, ME.message);
            end
        end
        
        % Test categorical preparation with different input types
        for i = 1:length(testInputs)
            try
                result = PreprocessingValidator.prepareForCategoricalOperation(testInputs{i});
                assert(iscategorical(result), 'Categorical preparation should return categorical');
                fprintf('  ✓ Categorical preparation test %d passed\n', i);
            catch ME
                fprintf('  ✗ Categorical preparation test %d failed: %s\n', i, ME.message);
            end
        end
        
        % Test compatibility with mismatched sizes
        img1 = rand(100, 100);
        mask1 = rand(50, 50) > 0.5;
        result = PreprocessingValidator.validateDataCompatibility(img1, mask1);
        assert(~result.isCompatible, 'Mismatched sizes should be incompatible');
        fprintf('  ✓ Size mismatch detection passed\n');
        
        % Test compatibility with matched sizes but different types
        img2 = uint8(rand(75, 75) * 255);
        mask2 = categorical(rand(75, 75) > 0.5, [0, 1], ["background", "foreground"]);
        result = PreprocessingValidator.validateDataCompatibility(img2, mask2);
        assert(result.isCompatible, 'Same size different types should be compatible');
        assert(~isempty(result.warnings), 'Should generate warnings for type mismatch');
        fprintf('  ✓ Type mismatch warning passed\n');
        
        % Test with extreme value ranges
        extremeImg = rand(20, 20) * 1000 - 500; % Range [-500, 500]
        try
            PreprocessingValidator.validateImageData(extremeImg);
            fprintf('  ✓ Extreme value range handled\n');
        catch ME
            fprintf('  ! Extreme values caused expected validation issue: %s\n', ME.message);
        end
        
    catch ME
        fprintf('  ✗ Complex data scenario test failed: %s\n', ME.message);
    end
    
    fprintf('\n');
end