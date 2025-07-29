function demo_preprocessDataMelhorado()
    % Demo script for the corrected preprocessDataMelhorado function
    
    fprintf('=== Demo: preprocessDataMelhorado Function ===\n\n');
    
    % Add paths
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'utils'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'utils'));
    
    % Configuration
    config.inputSize = [128, 128, 3];
    labelIDs = [0, 1];
    
    fprintf('Configuration:\n');
    fprintf('  Input size: [%d, %d, %d]\n', config.inputSize);
    fprintf('  Label IDs: [%d, %d]\n\n', labelIDs);
    
    % Demo 1: Basic preprocessing with numeric mask
    fprintf('Demo 1: Basic preprocessing with numeric mask\n');
    fprintf('----------------------------------------\n');
    
    % Create sample data
    img = uint8(rand(64, 64, 3) * 255);
    mask = uint8(rand(64, 64) > 0.5);
    data = {img, mask};
    
    fprintf('Input data:\n');
    fprintf('  Image: %s, size [%s]\n', class(img), num2str(size(img)));
    fprintf('  Mask: %s, size [%s]\n', class(mask), num2str(size(mask)));
    
    % Process data
    result = preprocessDataMelhorado(data, config, labelIDs, false);
    
    fprintf('Output data:\n');
    fprintf('  Image: %s, size [%s], range [%.3f, %.3f]\n', ...
        class(result{1}), num2str(size(result{1})), ...
        min(result{1}(:)), max(result{1}(:)));
    fprintf('  Mask: %s, size [%s], categories: %s\n', ...
        class(result{2}), num2str(size(result{2})), ...
        strjoin(string(categories(result{2})), ', '));
    fprintf('\n');
    
    % Demo 2: Preprocessing with categorical mask
    fprintf('Demo 2: Preprocessing with categorical mask\n');
    fprintf('------------------------------------------\n');
    
    % Create sample data with categorical mask
    img = uint8(rand(64, 64, 3) * 255);
    mask_numeric = uint8(rand(64, 64) > 0.5);
    mask = categorical(mask_numeric, [0, 1], ["background", "foreground"]);
    data = {img, mask};
    
    fprintf('Input data:\n');
    fprintf('  Image: %s, size [%s]\n', class(img), num2str(size(img)));
    fprintf('  Mask: %s, size [%s], categories: %s\n', ...
        class(mask), num2str(size(mask)), ...
        strjoin(string(categories(mask)), ', '));
    
    % Process data
    result = preprocessDataMelhorado(data, config, labelIDs, false);
    
    fprintf('Output data:\n');
    fprintf('  Image: %s, size [%s], range [%.3f, %.3f]\n', ...
        class(result{1}), num2str(size(result{1})), ...
        min(result{1}(:)), max(result{1}(:)));
    fprintf('  Mask: %s, size [%s], categories: %s\n', ...
        class(result{2}), num2str(size(result{2})), ...
        strjoin(string(categories(result{2})), ', '));
    fprintf('\n');
    
    % Demo 3: Preprocessing with data augmentation
    fprintf('Demo 3: Preprocessing with data augmentation\n');
    fprintf('-------------------------------------------\n');
    
    % Create sample data
    img = uint8(rand(64, 64, 3) * 255);
    mask = uint8(rand(64, 64) > 0.5);
    data = {img, mask};
    
    fprintf('Processing with augmentation enabled...\n');
    
    % Process multiple times to show augmentation effects
    for i = 1:3
        result = preprocessDataMelhorado(data, config, labelIDs, true);
        fprintf('  Run %d: Image range [%.3f, %.3f], Mask categories: %s\n', ...
            i, min(result{1}(:)), max(result{1}(:)), ...
            strjoin(string(categories(result{2})), ', '));
    end
    fprintf('\n');
    
    % Demo 4: Error recovery demonstration
    fprintf('Demo 4: Error recovery demonstration\n');
    fprintf('-----------------------------------\n');
    
    % Create invalid data to trigger error recovery
    img = []; % Empty image
    mask = uint8(rand(64, 64) > 0.5);
    data = {img, mask};
    
    fprintf('Input data (invalid):\n');
    fprintf('  Image: empty\n');
    fprintf('  Mask: %s, size [%s]\n', class(mask), num2str(size(mask)));
    
    try
        result = preprocessDataMelhorado(data, config, labelIDs, false);
        fprintf('Error recovery successful!\n');
        fprintf('Output data:\n');
        fprintf('  Image: %s, size [%s], range [%.3f, %.3f]\n', ...
            class(result{1}), num2str(size(result{1})), ...
            min(result{1}(:)), max(result{1}(:)));
        fprintf('  Mask: %s, size [%s], categories: %s\n', ...
            class(result{2}), num2str(size(result{2})), ...
            strjoin(string(categories(result{2})), ', '));
    catch ME
        fprintf('Error recovery failed: %s\n', ME.message);
    end
    fprintf('\n');
    
    % Demo 5: RGB mask conversion
    fprintf('Demo 5: RGB mask conversion\n');
    fprintf('--------------------------\n');
    
    % Create sample data with RGB mask
    img = uint8(rand(64, 64, 3) * 255);
    mask = uint8(rand(64, 64, 3) * 255); % RGB mask
    data = {img, mask};
    
    fprintf('Input data:\n');
    fprintf('  Image: %s, size [%s]\n', class(img), num2str(size(img)));
    fprintf('  Mask: %s, size [%s] (RGB)\n', class(mask), num2str(size(mask)));
    
    % Process data
    result = preprocessDataMelhorado(data, config, labelIDs, false);
    
    fprintf('Output data:\n');
    fprintf('  Image: %s, size [%s], range [%.3f, %.3f]\n', ...
        class(result{1}), num2str(size(result{1})), ...
        min(result{1}(:)), max(result{1}(:)));
    fprintf('  Mask: %s, size [%s], categories: %s\n', ...
        class(result{2}), num2str(size(result{2})), ...
        strjoin(string(categories(result{2})), ', '));
    fprintf('\n');
    
    fprintf('=== Demo completed successfully! ===\n');
end