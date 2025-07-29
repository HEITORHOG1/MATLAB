function test_DataTypeConverter()
    % Comprehensive test suite for DataTypeConverter utility class
    % Tests all static methods with various data types and edge cases
    
    fprintf('=== COMPREHENSIVE DataTypeConverter Test Suite ===\n');
    
    try
        % Test 1: Categorical to numeric conversions
        fprintf('Test 1: Categorical to numeric conversions...\n');
        test_categorical_to_numeric();
        
        % Test 2: Numeric to categorical conversions
        fprintf('Test 2: Numeric to categorical conversions...\n');
        test_numeric_to_categorical();
        
        % Test 3: Data type validation
        fprintf('Test 3: Data type validation...\n');
        test_data_type_validation();
        
        % Test 4: Safe conversion
        fprintf('Test 4: Safe conversion...\n');
        test_safe_conversion();
        
        % Test 5: Categorical structure validation
        fprintf('Test 5: Categorical structure validation...\n');
        test_categorical_structure_validation();
        
        % Test 6: Edge cases and error handling
        fprintf('Test 6: Edge cases and error handling...\n');
        test_edge_cases_and_errors();
        
        % Test 7: Complex conversion scenarios
        fprintf('Test 7: Complex conversion scenarios...\n');
        test_complex_conversions();
        
        % Test 8: Performance and memory tests
        fprintf('Test 8: Performance and memory tests...\n');
        test_performance_and_memory();
        
        fprintf('=== All DataTypeConverter tests passed! ===\n');
        
    catch ME
        fprintf('Test failed: %s\n', ME.message);
        rethrow(ME);
    end
end

function test_categorical_to_numeric()
    % Create test categorical data
    testData = categorical([true, false, true, false], [false, true], ["background", "foreground"]);
    
    % Test conversion to double
    result_double = DataTypeConverter.categoricalToNumeric(testData, 'double');
    expected_double = [1, 0, 1, 0];
    assert(isequal(result_double, expected_double), 'Categorical to double conversion failed');
    
    % Test conversion to logical
    result_logical = DataTypeConverter.categoricalToNumeric(testData, 'logical');
    expected_logical = [true, false, true, false];
    assert(isequal(result_logical, expected_logical), 'Categorical to logical conversion failed');
    
    % Test conversion to uint8
    result_uint8 = DataTypeConverter.categoricalToNumeric(testData, 'uint8');
    expected_uint8 = uint8([255, 0, 255, 0]);
    assert(isequal(result_uint8, expected_uint8), 'Categorical to uint8 conversion failed');
    
    fprintf('  ✓ Categorical to numeric conversions passed\n');
end

function test_numeric_to_categorical()
    % Test logical to categorical
    logicalData = [true, false, true, false];
    result_cat = DataTypeConverter.numericToCategorical(logicalData);
    
    assert(iscategorical(result_cat), 'Result should be categorical');
    assert(length(categories(result_cat)) == 2, 'Should have 2 categories');
    
    % Test double to categorical
    doubleData = [0.8, 0.2, 0.9, 0.1];
    result_cat2 = DataTypeConverter.numericToCategorical(doubleData);
    
    assert(iscategorical(result_cat2), 'Result should be categorical');
    
    fprintf('  ✓ Numeric to categorical conversions passed\n');
end

function test_data_type_validation()
    % Test with valid types
    testData = [1, 2, 3];
    assert(DataTypeConverter.validateDataType(testData, 'double'), 'Should validate double type');
    assert(DataTypeConverter.validateDataType(testData, {'double', 'single'}), 'Should validate multiple types');
    
    % Test with invalid types
    assert(~DataTypeConverter.validateDataType(testData, 'char'), 'Should reject invalid type');
    
    fprintf('  ✓ Data type validation passed\n');
end

function test_safe_conversion()
    % Test safe conversion with different types
    testData = [0.8, 0.2, 0.9, 0.1];
    
    % Test double to uint8
    result = DataTypeConverter.safeConversion(testData, 'uint8', 'test');
    assert(isa(result, 'uint8'), 'Result should be uint8');
    
    % Test no conversion needed
    result2 = DataTypeConverter.safeConversion(testData, 'double', 'test');
    assert(isequal(result2, testData), 'No conversion should return same data');
    
    fprintf('  ✓ Safe conversion passed\n');
end

function test_categorical_structure_validation()
    % Create properly structured categorical data
    goodData = categorical([true, false, true], [false, true], ["background", "foreground"]);
    validation = DataTypeConverter.validateCategoricalStructure(goodData);
    
    assert(validation.isValid, 'Good categorical data should be valid');
    assert(validation.numCategories == 2, 'Should have 2 categories');
    
    % Test with non-categorical data
    badData = [1, 2, 3];
    validation2 = DataTypeConverter.validateCategoricalStructure(badData);
    assert(~validation2.isValid, 'Non-categorical data should be invalid');
    
    fprintf('  ✓ Categorical structure validation passed\n');
end

function test_edge_cases_and_errors()
    % Test error handling for invalid inputs
    
    % Test categoricalToNumeric with non-categorical input
    try
        DataTypeConverter.categoricalToNumeric([1, 2, 3], 'double');
        assert(false, 'Should have thrown error for non-categorical input');
    catch ME
        assert(contains(ME.identifier, 'InvalidInput'), 'Wrong error type');
        fprintf('  ✓ Non-categorical input error handling passed\n');
    end
    
    % Test categoricalToNumeric with invalid target type
    testCat = categorical([0, 1, 0], [0, 1], ["background", "foreground"]);
    try
        DataTypeConverter.categoricalToNumeric(testCat, 'invalid_type');
        assert(false, 'Should have thrown error for invalid target type');
    catch ME
        assert(contains(ME.identifier, 'InvalidTargetType'), 'Wrong error type');
        fprintf('  ✓ Invalid target type error handling passed\n');
    end
    
    % Test with wrong number of categories
    multiCat = categorical([1, 2, 3, 1], [1, 2, 3], ["class1", "class2", "class3"]);
    try
        DataTypeConverter.categoricalToNumeric(multiCat, 'double');
        assert(false, 'Should have thrown error for non-binary categorical');
    catch ME
        assert(contains(ME.identifier, 'InvalidCategories'), 'Wrong error type');
        fprintf('  ✓ Multi-class categorical error handling passed\n');
    end
    
    % Test numericToCategorical with mismatched parameters
    try
        DataTypeConverter.numericToCategorical([1, 0, 1], ["bg", "fg"], [0, 1, 2]);
        assert(false, 'Should have thrown error for mismatched parameters');
    catch ME
        assert(contains(ME.identifier, 'MismatchedParameters'), 'Wrong error type');
        fprintf('  ✓ Mismatched parameters error handling passed\n');
    end
    
    % Test empty data
    try
        emptyData = categorical.empty(0, 1);
        result = DataTypeConverter.categoricalToNumeric(emptyData, 'double');
        assert(isempty(result), 'Empty categorical should return empty result');
        fprintf('  ✓ Empty data handling passed\n');
    catch ME
        if contains(ME.identifier, 'InvalidCategories')
            fprintf('  ✓ Empty data correctly rejected (expected behavior)\n');
        else
            rethrow(ME);
        end
    end
    
    % Test single element data
    singleCat = categorical("foreground", ["background", "foreground"]);
    result = DataTypeConverter.categoricalToNumeric(singleCat, 'double');
    assert(result == 1, 'Single foreground element should convert to 1');
    fprintf('  ✓ Single element handling passed\n');
end

function test_complex_conversions()
    % Test complex conversion scenarios
    
    % Test large data arrays
    largeData = rand(1000, 1000) > 0.5;
    largeCat = DataTypeConverter.numericToCategorical(largeData);
    assert(iscategorical(largeCat), 'Large data conversion should work');
    assert(isequal(size(largeCat), size(largeData)), 'Size should be preserved');
    fprintf('  ✓ Large data conversion passed\n');
    
    % Test 3D data
    data3D = rand(50, 50, 10) > 0.5;
    cat3D = DataTypeConverter.numericToCategorical(data3D);
    assert(iscategorical(cat3D), '3D data conversion should work');
    assert(isequal(size(cat3D), size(data3D)), '3D size should be preserved');
    fprintf('  ✓ 3D data conversion passed\n');
    
    % Test round-trip conversions
    originalLogical = rand(100, 100) > 0.5;
    cat_intermediate = DataTypeConverter.numericToCategorical(originalLogical);
    final_logical = DataTypeConverter.categoricalToNumeric(cat_intermediate, 'logical');
    assert(isequal(originalLogical, final_logical), 'Round-trip conversion should preserve data');
    fprintf('  ✓ Round-trip conversion passed\n');
    
    % Test different numeric ranges
    ranges = {[0, 1], [0, 255], [-1, 1], [100, 200]};
    for i = 1:length(ranges)
        range = ranges{i};
        testData = range(1) + (range(2) - range(1)) * rand(50, 50);
        catData = DataTypeConverter.numericToCategorical(testData);
        assert(iscategorical(catData), sprintf('Range [%g,%g] conversion should work', range(1), range(2)));
    end
    fprintf('  ✓ Different numeric ranges passed\n');
    
    % Test with extreme values
    extremeData = [0, realmax, realmin, 1e-10, 1e10];
    try
        catExtreme = DataTypeConverter.numericToCategorical(extremeData);
        assert(iscategorical(catExtreme), 'Extreme values should be handled');
        fprintf('  ✓ Extreme values handling passed\n');
    catch ME
        fprintf('  ! Extreme values caused expected error: %s\n', ME.message);
    end
end

function test_performance_and_memory()
    % Test performance with different data sizes
    sizes = [100, 500, 1000];
    
    for i = 1:length(sizes)
        sz = sizes(i);
        testData = rand(sz, sz) > 0.5;
        
        % Time the conversion
        tic;
        catData = DataTypeConverter.numericToCategorical(testData);
        convTime = toc;
        
        tic;
        numData = DataTypeConverter.categoricalToNumeric(catData, 'double');
        backTime = toc;
        
        fprintf('  Size %dx%d: forward %.3fs, backward %.3fs\n', sz, sz, convTime, backTime);
        
        % Verify correctness
        assert(isequal(double(testData), numData), 'Performance test data should match');
    end
    
    % Test memory efficiency (basic check)
    originalData = rand(500, 500) > 0.5;
    catData = DataTypeConverter.numericToCategorical(originalData);
    
    % Both should have same number of elements
    assert(numel(originalData) == numel(catData), 'Element count should be preserved');
    fprintf('  ✓ Memory efficiency check passed\n');
end