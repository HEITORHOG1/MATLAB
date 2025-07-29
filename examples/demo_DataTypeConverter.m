function demo_DataTypeConverter()
    % Demonstration of DataTypeConverter solving categorical RGB errors
    
    fprintf('=== DataTypeConverter Demonstration ===\n\n');
    
    % Add path to the utility
    addpath('src/utils');
    
    % Problem 1: Categorical data causing RGB errors
    fprintf('1. Solving Categorical RGB Conversion Errors:\n');
    fprintf('   Problem: rgb2gray() fails with categorical data\n');
    
    % Create sample categorical mask data (simulating the actual problem)
    sampleMask = categorical([true, false, true, false; false, true, false, true], ...
                           [false, true], ["background", "foreground"]);
    
    fprintf('   Original data type: %s\n', class(sampleMask));
    fprintf('   Categories: [%s]\n', strjoin(categories(sampleMask), ', '));
    
    % Convert for RGB operations
    maskForRGB = DataTypeConverter.categoricalToNumeric(sampleMask, 'double');
    fprintf('   Converted for RGB ops: %s (range: %.1f-%.1f)\n', ...
            class(maskForRGB), min(maskForRGB(:)), max(maskForRGB(:)));
    
    % Problem 2: Incorrect categorical to binary conversion for metrics
    fprintf('\n2. Solving Incorrect Metrics Calculation:\n');
    fprintf('   Problem: double(categorical) > 1 gives wrong results\n');
    
    % Show the WRONG way (current system)
    wrongConversion = double(sampleMask) > 1;
    fprintf('   WRONG: double(categorical) > 1 = [%s]\n', mat2str(wrongConversion(1,:)));
    
    % Show the CORRECT way (our solution)
    correctConversion = DataTypeConverter.categoricalToNumeric(sampleMask, 'logical');
    fprintf('   CORRECT: categorical == "foreground" = [%s]\n', mat2str(correctConversion(1,:)));
    
    % Problem 3: Visualization conversion errors
    fprintf('\n3. Solving Visualization Conversion Errors:\n');
    fprintf('   Problem: imshow() fails with categorical data\n');
    
    % Convert for visualization
    maskForViz = DataTypeConverter.categoricalToNumeric(sampleMask, 'uint8');
    fprintf('   Converted for visualization: %s (range: %d-%d)\n', ...
            class(maskForViz), min(maskForViz(:)), max(maskForViz(:)));
    
    % Problem 4: Data type validation
    fprintf('\n4. Data Type Validation:\n');
    
    % Validate different types
    isValidDouble = DataTypeConverter.validateDataType(maskForRGB, 'double');
    isValidCat = DataTypeConverter.validateDataType(sampleMask, 'categorical');
    isValidWrong = DataTypeConverter.validateDataType(sampleMask, 'uint8');
    
    fprintf('   maskForRGB is double: %s\n', mat2str(isValidDouble));
    fprintf('   sampleMask is categorical: %s\n', mat2str(isValidCat));
    fprintf('   sampleMask is uint8: %s\n', mat2str(isValidWrong));
    
    % Problem 5: Safe conversion with error handling
    fprintf('\n5. Safe Conversion with Error Handling:\n');
    
    try
        % This would normally cause errors in the old system
        safeResult = DataTypeConverter.safeConversion(sampleMask, 'double', 'metrics_calculation');
        fprintf('   Safe conversion successful: %s\n', class(safeResult));
    catch ME
        fprintf('   Safe conversion failed: %s\n', ME.message);
    end
    
    % Problem 6: Categorical structure validation
    fprintf('\n6. Categorical Structure Validation:\n');
    
    validation = DataTypeConverter.validateCategoricalStructure(sampleMask);
    fprintf('   Structure is valid: %s\n', mat2str(validation.isValid));
    fprintf('   Number of categories: %d\n', validation.numCategories);
    fprintf('   Categories: [%s]\n', strjoin(validation.categories, ', '));
    
    if ~isempty(validation.warnings)
        fprintf('   Warnings:\n');
        for i = 1:length(validation.warnings)
            fprintf('     - %s\n', validation.warnings{i});
        end
    end
    
    fprintf('\n=== Summary ===\n');
    fprintf('DataTypeConverter provides:\n');
    fprintf('✓ Safe categorical to numeric conversions\n');
    fprintf('✓ Proper binary conversion logic (fixes metrics)\n');
    fprintf('✓ Visualization-ready data conversion\n');
    fprintf('✓ Data type validation\n');
    fprintf('✓ Error handling with detailed diagnostics\n');
    fprintf('✓ Categorical structure validation\n');
    
    fprintf('\nThis addresses requirements 1.1, 1.2, 3.1, and 3.2 from the spec.\n');
end