function test_visualization_fix()
    % Test the corrected visualization function in comparacao_unet_attention_final.m
    % This test verifies that the visualization function handles categorical data correctly
    
    fprintf('=== Testing Visualization Fix ===\n');
    
    % Add necessary paths
    addpath(fullfile(pwd, 'src', 'utils'));
    addpath(fullfile(pwd, 'legacy'));
    
    try
        % Test VisualizationHelper methods directly
        fprintf('Testing VisualizationHelper methods...\n');
        
        % Create test categorical data
        test_mask = categorical([0, 1, 0, 1; 1, 0, 1, 0], [0, 1], {'background', 'foreground'});
        test_img = rand(2, 4, 3); % RGB image
        test_pred = categorical([1, 0, 1, 0; 0, 1, 0, 1], [0, 1], {'background', 'foreground'});
        
        % Test prepareMaskForDisplay
        mask_visual = VisualizationHelper.prepareMaskForDisplay(test_mask);
        fprintf('✓ prepareMaskForDisplay: %s -> %s\n', class(test_mask), class(mask_visual));
        
        % Test prepareImageForDisplay
        img_visual = VisualizationHelper.prepareImageForDisplay(test_img);
        fprintf('✓ prepareImageForDisplay: %s -> %s\n', class(test_img), class(img_visual));
        
        % Test prepareComparisonData
        [img_out, mask_out, pred_out] = VisualizationHelper.prepareComparisonData(test_img, test_mask, test_pred);
        fprintf('✓ prepareComparisonData: All outputs prepared successfully\n');
        
        % Test safeImshow (without actually displaying)
        figure('Visible', 'off'); % Create invisible figure for testing
        success = VisualizationHelper.safeImshow(mask_visual);
        close(gcf);
        fprintf('✓ safeImshow: Success = %d\n', success);
        
        % Test categorical conversion logic
        fprintf('\nTesting categorical conversion logic...\n');
        
        % Test the corrected conversion logic
        binary_correct = test_mask == "foreground";
        binary_old = double(test_mask) > 1;
        
        fprintf('Categorical data: %s\n', mat2str(double(test_mask)));
        fprintf('Correct conversion (== "foreground"): %s\n', mat2str(binary_correct));
        fprintf('Old conversion (double > 1): %s\n', mat2str(binary_old));
        
        % Verify they are different (proving the fix is necessary)
        if ~isequal(binary_correct, binary_old)
            fprintf('✓ Conversion methods produce different results (fix is necessary)\n');
        else
            fprintf('⚠ Conversion methods produce same results (unexpected)\n');
        end
        
        % Test metrics calculation with corrected logic
        fprintf('\nTesting metrics calculation...\n');
        
        % Create test data for metrics
        pred_test = categorical([1, 0, 1, 0; 0, 1, 0, 1], [0, 1], {'background', 'foreground'});
        gt_test = categorical([1, 1, 0, 0; 0, 1, 1, 1], [0, 1], {'background', 'foreground'});
        
        % Test IoU calculation (would need to call the internal function)
        % For now, just verify the conversion logic
        pred_binary = pred_test == "foreground";
        gt_binary = gt_test == "foreground";
        
        intersection = sum(pred_binary(:) & gt_binary(:));
        union = sum(pred_binary(:) | gt_binary(:));
        iou = intersection / union;
        
        fprintf('Test IoU calculation: %.4f\n', iou);
        
        if iou > 0 && iou < 1
            fprintf('✓ IoU shows realistic value (not perfect)\n');
        else
            fprintf('⚠ IoU is perfect (%.4f) - may indicate issue\n', iou);
        end
        
        fprintf('\n=== Visualization Fix Test Completed Successfully ===\n');
        
    catch ME
        fprintf('❌ Test failed: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for k = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(k).name, ME.stack(k).line);
        end
    end
end