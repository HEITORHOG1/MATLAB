function test_preprocessDataCorrigido()
    % Unit tests for preprocessDataCorrigido function
    % Tests the type validation, safe conversions, and error handling
    
    fprintf('=== Testing preprocessDataCorrigido function ===\n');
    
    % Add paths
    addpath('src/utils');
    addpath('utils');
    
    % Test configuration
    config.inputSize = [64, 64, 3];
    
    % Test 1: Normal uint8 image and mask
    fprintf('\nTest 1: Normal uint8 image and mask\n');
    try
        test_img = uint8(rand(100,100,3)*255);
        test_mask = uint8(rand(100,100)>0.5)*255;
        result = preprocessDataCorrigido({test_img, test_mask}, config);
        
        assert(isa(result{1}, 'single'), 'Image should be single type');
        assert(iscategorical(result{2}), 'Mask should be categorical');
        assert(isequal(size(result{1}), [64, 64, 3]), 'Image should have correct size');
        assert(isequal(size(result{2}), [64, 64]), 'Mask should have correct size');
        
        fprintf('✓ Test 1 passed\n');
    catch ME
        fprintf('✗ Test 1 failed: %s\n', ME.message);
    end
    
    % Test 2: Categorical mask input
    fprintf('\nTest 2: Categorical mask input\n');
    try
        test_img = uint8(rand(100,100,3)*255);
        test_mask_numeric = uint8(rand(100,100)>0.5);
        test_mask = categorical(test_mask_numeric, [0,1], ["background","foreground"]);
        result = preprocessDataCorrigido({test_img, test_mask}, config);
        
        assert(isa(result{1}, 'single'), 'Image should be single type');
        assert(iscategorical(result{2}), 'Mask should be categorical');
        
        fprintf('✓ Test 2 passed\n');
    catch ME
        fprintf('✗ Test 2 failed: %s\n', ME.message);
    end
    
    % Test 3: Grayscale image input
    fprintf('\nTest 3: Grayscale image input\n');
    try
        test_img = uint8(rand(100,100)*255);  % Grayscale
        test_mask = uint8(rand(100,100)>0.5)*255;
        result = preprocessDataCorrigido({test_img, test_mask}, config);
        
        assert(isa(result{1}, 'single'), 'Image should be single type');
        assert(size(result{1}, 3) == 3, 'Image should have 3 channels after processing');
        assert(iscategorical(result{2}), 'Mask should be categorical');
        
        fprintf('✓ Test 3 passed\n');
    catch ME
        fprintf('✗ Test 3 failed: %s\n', ME.message);
    end
    
    % Test 4: Double precision inputs
    fprintf('\nTest 4: Double precision inputs\n');
    try
        test_img = rand(100,100,3);  % Double [0,1]
        test_mask = double(rand(100,100)>0.5);  % Double binary
        result = preprocessDataCorrigido({test_img, test_mask}, config);
        
        assert(isa(result{1}, 'single'), 'Image should be single type');
        assert(iscategorical(result{2}), 'Mask should be categorical');
        
        fprintf('✓ Test 4 passed\n');
    catch ME
        fprintf('✗ Test 4 failed: %s\n', ME.message);
    end
    
    % Test 5: RGB mask input (should be converted to grayscale)
    fprintf('\nTest 5: RGB mask input\n');
    try
        test_img = uint8(rand(100,100,3)*255);
        test_mask = uint8(rand(100,100,3)*255);  % RGB mask
        result = preprocessDataCorrigido({test_img, test_mask}, config);
        
        assert(isa(result{1}, 'single'), 'Image should be single type');
        assert(iscategorical(result{2}), 'Mask should be categorical');
        assert(ndims(result{2}) == 2, 'Mask should be 2D after processing');
        
        fprintf('✓ Test 5 passed\n');
    catch ME
        fprintf('✗ Test 5 failed: %s\n', ME.message);
    end
    
    % Test 6: Data augmentation
    fprintf('\nTest 6: Data augmentation\n');
    try
        test_img = uint8(rand(100,100,3)*255);
        test_mask = uint8(rand(100,100)>0.5)*255;
        result = preprocessDataCorrigido({test_img, test_mask}, config, [], true);
        
        assert(isa(result{1}, 'single'), 'Image should be single type');
        assert(iscategorical(result{2}), 'Mask should be categorical');
        
        fprintf('✓ Test 6 passed\n');
    catch ME
        fprintf('✗ Test 6 failed: %s\n', ME.message);
    end
    
    % Test 7: Error handling with invalid input
    fprintf('\nTest 7: Error handling with invalid input\n');
    try
        % This should trigger fallback processing
        test_img = [];  % Invalid input
        test_mask = uint8(rand(100,100)>0.5)*255;
        
        try
            result = preprocessDataCorrigido({test_img, test_mask}, config);
            fprintf('✗ Test 7 failed: Should have thrown an error\n');
        catch ME
            % Expected to fail - this is good
            fprintf('✓ Test 7 passed: Correctly handled invalid input\n');
        end
    catch ME
        fprintf('✗ Test 7 setup failed: %s\n', ME.message);
    end
    
    fprintf('\n=== preprocessDataCorrigido tests completed ===\n');
end