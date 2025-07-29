function demo_VisualizationHelper()
    % Demo script for VisualizationHelper utility class
    % Shows how to use the class for safe image and mask visualization
    
    fprintf('=== VisualizationHelper Demo ===\n\n');
    
    % Demo 1: Prepare different image types for display
    demo_image_preparation();
    
    % Demo 2: Prepare different mask types for display
    demo_mask_preparation();
    
    % Demo 3: Prepare comparison data
    demo_comparison_preparation();
    
    % Demo 4: Safe imshow with error handling
    demo_safe_imshow();
    
    fprintf('Demo completed successfully!\n');
end

function demo_image_preparation()
    fprintf('1. Image Preparation Demo\n');
    fprintf('-------------------------\n');
    
    % Create sample images of different types
    img_uint8 = uint8(rand(50, 50) * 255);
    img_double = rand(50, 50);
    img_logical = rand(50, 50) > 0.5;
    img_categorical = categorical(rand(50, 50) > 0.5, [false, true], ["background", "foreground"]);
    
    % Prepare each for display
    prepared_uint8 = VisualizationHelper.prepareImageForDisplay(img_uint8);
    prepared_double = VisualizationHelper.prepareImageForDisplay(img_double);
    prepared_logical = VisualizationHelper.prepareImageForDisplay(img_logical);
    prepared_categorical = VisualizationHelper.prepareImageForDisplay(img_categorical);
    
    fprintf('  Original uint8 image: %s, range [%d, %d]\n', ...
        class(img_uint8), min(img_uint8(:)), max(img_uint8(:)));
    fprintf('  Prepared uint8 image: %s, range [%d, %d]\n', ...
        class(prepared_uint8), min(prepared_uint8(:)), max(prepared_uint8(:)));
    
    fprintf('  Original double image: %s, range [%.3f, %.3f]\n', ...
        class(img_double), min(img_double(:)), max(img_double(:)));
    fprintf('  Prepared double image: %s, range [%.3f, %.3f]\n', ...
        class(prepared_double), min(prepared_double(:)), max(prepared_double(:)));
    
    fprintf('  Original logical image: %s\n', class(img_logical));
    fprintf('  Prepared logical image: %s, range [%d, %d]\n', ...
        class(prepared_logical), min(prepared_logical(:)), max(prepared_logical(:)));
    
    fprintf('  Original categorical image: %s with categories: %s\n', ...
        class(img_categorical), strjoin(categories(img_categorical), ', '));
    fprintf('  Prepared categorical image: %s, range [%d, %d]\n', ...
        class(prepared_categorical), min(prepared_categorical(:)), max(prepared_categorical(:)));
    
    fprintf('\n');
end

function demo_mask_preparation()
    fprintf('2. Mask Preparation Demo\n');
    fprintf('------------------------\n');
    
    % Create sample masks of different types
    mask_categorical = categorical(rand(30, 30) > 0.6, [false, true], ["background", "foreground"]);
    mask_logical = rand(30, 30) > 0.6;
    mask_uint8 = uint8(rand(30, 30) > 0.6) * 255;
    mask_double = double(rand(30, 30) > 0.6);
    
    % Prepare each for display
    prepared_cat = VisualizationHelper.prepareMaskForDisplay(mask_categorical);
    prepared_log = VisualizationHelper.prepareMaskForDisplay(mask_logical);
    prepared_u8 = VisualizationHelper.prepareMaskForDisplay(mask_uint8);
    prepared_dbl = VisualizationHelper.prepareMaskForDisplay(mask_double);
    
    fprintf('  Categorical mask: %s -> %s, unique values: [%s]\n', ...
        class(mask_categorical), class(prepared_cat), ...
        num2str(unique(prepared_cat)'));
    
    fprintf('  Logical mask: %s -> %s, unique values: [%s]\n', ...
        class(mask_logical), class(prepared_log), ...
        num2str(unique(prepared_log)'));
    
    fprintf('  Uint8 mask: %s -> %s, unique values: [%s]\n', ...
        class(mask_uint8), class(prepared_u8), ...
        num2str(unique(prepared_u8)'));
    
    fprintf('  Double mask: %s -> %s, unique values: [%s]\n', ...
        class(mask_double), class(prepared_dbl), ...
        num2str(unique(prepared_dbl)'));
    
    fprintf('\n');
end

function demo_comparison_preparation()
    fprintf('3. Comparison Data Preparation Demo\n');
    fprintf('-----------------------------------\n');
    
    % Create sample comparison data
    img = uint8(rand(40, 40, 3) * 255);  % RGB image
    mask = categorical(rand(40, 40) > 0.5, [false, true], ["background", "foreground"]);
    pred = categorical(rand(40, 40) > 0.4, [false, true], ["background", "foreground"]);
    
    fprintf('  Original data types:\n');
    fprintf('    Image: %s, size: [%s]\n', class(img), num2str(size(img)));
    fprintf('    Mask: %s, size: [%s]\n', class(mask), num2str(size(mask)));
    fprintf('    Prediction: %s, size: [%s]\n', class(pred), num2str(size(pred)));
    
    % Prepare for comparison
    [imgOut, maskOut, predOut] = VisualizationHelper.prepareComparisonData(img, mask, pred);
    
    fprintf('  Prepared data types:\n');
    fprintf('    Image: %s, size: [%s]\n', class(imgOut), num2str(size(imgOut)));
    fprintf('    Mask: %s, size: [%s], range: [%d, %d]\n', ...
        class(maskOut), num2str(size(maskOut)), min(maskOut(:)), max(maskOut(:)));
    fprintf('    Prediction: %s, size: [%s], range: [%d, %d]\n', ...
        class(predOut), num2str(size(predOut)), min(predOut(:)), max(predOut(:)));
    
    fprintf('\n');
end

function demo_safe_imshow()
    fprintf('4. Safe Imshow Demo\n');
    fprintf('-------------------\n');
    
    % Test with different data types
    test_data = {
        uint8(rand(20, 20) * 255), 'uint8 image';
        rand(20, 20), 'double [0,1] image';
        rand(20, 20) > 0.5, 'logical image';
        categorical(rand(20, 20) > 0.5, [false, true], ["background", "foreground"]), 'categorical mask';
        [], 'empty data'
    };
    
    for i = 1:size(test_data, 1)
        data = test_data{i, 1};
        description = test_data{i, 2};
        
        fprintf('  Testing %s: ', description);
        
        % Create figure for testing
        fig = figure('Visible', 'off');
        success = VisualizationHelper.safeImshow(data);
        close(fig);
        
        if success
            fprintf('SUCCESS\n');
        else
            fprintf('FAILED (handled gracefully)\n');
        end
    end
    
    fprintf('\n');
end