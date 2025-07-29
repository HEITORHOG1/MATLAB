function test_preprocessDataMelhorado()
    % Unit tests for preprocessDataMelhorado function
    
    fprintf('Testing preprocessDataMelhorado function...\n');
    
    % Add paths
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'utils'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'src', 'utils'));
    
    % Test configuration
    config.inputSize = [128, 128, 3];
    labelIDs = [0, 1];
    
    % Test 1: Basic functionality with numeric mask
    fprintf('Test 1: Basic functionality with numeric mask...\n');
    try
        img = uint8(rand(64, 64, 3) * 255);
        mask = uint8(rand(64, 64) > 0.5);
        data = {img, mask};
        
        result = preprocessDataMelhorado(data, config, labelIDs, false);
        
        assert(isa(result{1}, 'double'), 'Image should be double');
        assert(isa(result{2}, 'categorical'), 'Mask should be categorical');
        assert(all(size(result{1}) == [128, 128, 3]), 'Image size should match config');
        assert(all(size(result{2}) == [128, 128]), 'Mask size should match config');
        
        fprintf('✓ Test 1 passed\n');
    catch ME
        fprintf('✗ Test 1 failed: %s\n', ME.message);
    end
    
    % Test 2: Categorical mask input
    fprintf('Test 2: Categorical mask input...\n');
    try
        img = uint8(rand(64, 64, 3) * 255);
        mask_numeric = uint8(rand(64, 64) > 0.5);
        mask = categorical(mask_numeric, [0, 1], ["background", "foreground"]);
        data = {img, mask};
        
        result = preprocessDataMelhorado(data, config, labelIDs, false);
        
        assert(isa(result{1}, 'double'), 'Image should be double');
        assert(isa(result{2}, 'categorical'), 'Mask should remain categorical');
        assert(all(categories(result{2}) == ["background"; "foreground"]), 'Categories should be correct');
        
        fprintf('✓ Test 2 passed\n');
    catch ME
        fprintf('✗ Test 2 failed: %s\n', ME.message);
    end
    
    % Test 3: RGB mask input (should be converted to grayscale then categorical)
    fprintf('Test 3: RGB mask input...\n');
    try
        img = uint8(rand(64, 64, 3) * 255);
        mask = uint8(rand(64, 64, 3) * 255); % RGB mask
        data = {img, mask};
        
        result = preprocessDataMelhorado(data, config, labelIDs, false);
        
        assert(isa(result{1}, 'double'), 'Image should be double');
        assert(isa(result{2}, 'categorical'), 'Mask should be categorical');
        assert(size(result{2}, 3) == 1, 'Mask should be 2D');
        
        fprintf('✓ Test 3 passed\n');
    catch ME
        fprintf('✗ Test 3 failed: %s\n', ME.message);
    end
    
    % Test 4: Data augmentation
    fprintf('Test 4: Data augmentation...\n');
    try
        img = uint8(rand(64, 64, 3) * 255);
        mask = uint8(rand(64, 64) > 0.5);
        data = {img, mask};
        
        % Run multiple times to test augmentation
        for i = 1:5
            result = preprocessDataMelhorado(data, config, labelIDs, true);
            assert(isa(result{1}, 'double'), 'Image should be double');
            assert(isa(result{2}, 'categorical'), 'Mask should be categorical');
        end
        
        fprintf('✓ Test 4 passed\n');
    catch ME
        fprintf('✗ Test 4 failed: %s\n', ME.message);
    end
    
    % Test 5: Error recovery with invalid data
    fprintf('Test 5: Error recovery...\n');
    try
        img = []; % Invalid image
        mask = uint8(rand(64, 64) > 0.5);
        data = {img, mask};
        
        % This should trigger error recovery
        result = preprocessDataMelhorado(data, config, labelIDs, false);
        
        % If we get here, error recovery worked
        fprintf('✓ Test 5 passed (error recovery worked)\n');
    catch ME
        fprintf('✗ Test 5 failed: %s\n', ME.message);
    end
    
    % Test 6: Grayscale image input
    fprintf('Test 6: Grayscale image input...\n');
    try
        img = uint8(rand(64, 64) * 255); % Grayscale
        mask = uint8(rand(64, 64) > 0.5);
        data = {img, mask};
        
        result = preprocessDataMelhorado(data, config, labelIDs, false);
        
        assert(isa(result{1}, 'double'), 'Image should be double');
        assert(size(result{1}, 3) == 3, 'Image should have 3 channels');
        assert(isa(result{2}, 'categorical'), 'Mask should be categorical');
        
        fprintf('✓ Test 6 passed\n');
    catch ME
        fprintf('✗ Test 6 failed: %s\n', ME.message);
    end
    
    fprintf('preprocessDataMelhorado tests completed.\n\n');
end