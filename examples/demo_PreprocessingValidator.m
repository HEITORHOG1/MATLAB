function demo_PreprocessingValidator()
    % Demo script showing how to use PreprocessingValidator utility class
    
    fprintf('=== PreprocessingValidator Demo ===\n\n');
    
    % Add path to utilities
    addpath('../src/utils');
    
    % Demo 1: Image validation
    fprintf('1. Image Data Validation\n');
    fprintf('------------------------\n');
    
    % Create sample image data
    img_uint8 = uint8(rand(100, 100, 3) * 255);
    img_double = rand(50, 50);
    
    try
        PreprocessingValidator.validateImageData(img_uint8);
        PreprocessingValidator.validateImageData(img_double);
    catch ME
        fprintf('Image validation error: %s\n', ME.message);
    end
    
    fprintf('\n');
    
    % Demo 2: Mask validation
    fprintf('2. Mask Data Validation\n');
    fprintf('-----------------------\n');
    
    % Create sample mask data
    mask_logical = rand(100, 100) > 0.5;
    mask_uint8 = uint8(mask_logical) * 255;
    mask_categorical = categorical(mask_logical, [0, 1], ["background", "foreground"]);
    
    try
        PreprocessingValidator.validateMaskData(mask_logical);
        PreprocessingValidator.validateMaskData(mask_uint8);
        PreprocessingValidator.validateMaskData(mask_categorical);
    catch ME
        fprintf('Mask validation error: %s\n', ME.message);
    end
    
    fprintf('\n');
    
    % Demo 3: RGB operation preparation
    fprintf('3. RGB Operation Preparation\n');
    fprintf('----------------------------\n');
    
    % Prepare different data types for RGB operations
    cat_data = categorical(rand(50, 50) > 0.5, [0, 1], ["background", "foreground"]);
    logical_data = rand(30, 30) > 0.5;
    
    try
        rgb_from_cat = PreprocessingValidator.prepareForRGBOperation(cat_data);
        rgb_from_logical = PreprocessingValidator.prepareForRGBOperation(logical_data);
        
        fprintf('Categorical data converted to: %s\n', class(rgb_from_cat));
        fprintf('Logical data converted to: %s\n', class(rgb_from_logical));
    catch ME
        fprintf('RGB preparation error: %s\n', ME.message);
    end
    
    fprintf('\n');
    
    % Demo 4: Categorical operation preparation
    fprintf('4. Categorical Operation Preparation\n');
    fprintf('------------------------------------\n');
    
    % Prepare different data types for categorical operations
    double_data = double(rand(40, 40) > 0.5);
    uint8_data = uint8(rand(35, 35) > 0.5) * 255;
    
    try
        cat_from_double = PreprocessingValidator.prepareForCategoricalOperation(double_data);
        cat_from_uint8 = PreprocessingValidator.prepareForCategoricalOperation(uint8_data);
        
        fprintf('Double data converted to: %s\n', class(cat_from_double));
        fprintf('uint8 data converted to: %s\n', class(cat_from_uint8));
        
        % Show categories
        fprintf('Categories: [%s]\n', strjoin(categories(cat_from_double), ', '));
    catch ME
        fprintf('Categorical preparation error: %s\n', ME.message);
    end
    
    fprintf('\n');
    
    % Demo 5: Data compatibility validation
    fprintf('5. Data Compatibility Validation\n');
    fprintf('---------------------------------\n');
    
    % Test compatible data
    img_compat = rand(100, 100, 3);
    mask_compat = rand(100, 100) > 0.5;
    
    % Test incompatible data
    img_incompat = rand(100, 100);
    mask_incompat = rand(50, 50) > 0.5;
    
    try
        result1 = PreprocessingValidator.validateDataCompatibility(img_compat, mask_compat);
        result2 = PreprocessingValidator.validateDataCompatibility(img_incompat, mask_incompat);
        
        fprintf('Compatible data result: %s\n', mat2str(result1.isCompatible));
        fprintf('Incompatible data result: %s\n', mat2str(result2.isCompatible));
        
        % Show validation summary
        PreprocessingValidator.reportValidationSummary({result1, result2});
        
    catch ME
        fprintf('Compatibility validation error: %s\n', ME.message);
    end
    
    % Demo 6: Error handling demonstration
    fprintf('6. Error Handling Demonstration\n');
    fprintf('-------------------------------\n');
    
    try
        % Try to validate invalid data
        PreprocessingValidator.validateImageData([]);
    catch ME
        fprintf('Expected error caught: %s\n', ME.identifier);
    end
    
    try
        % Try to validate incompatible mask type
        PreprocessingValidator.validateMaskData("invalid_mask");
    catch ME
        fprintf('Expected error caught: %s\n', ME.identifier);
    end
    
    fprintf('\n=== Demo Complete ===\n');
end