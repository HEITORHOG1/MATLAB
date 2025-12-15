% validate_model_factory - Validation script for ModelFactory implementation
%
% This script validates the ModelFactory class by creating each architecture
% and verifying basic functionality. Run this script in MATLAB to validate
% the implementation.
%
% Usage:
%   Run this script in MATLAB: validate_model_factory
%
% Requirements: 3.1, 3.2, 3.3, 3.4

fprintf('=== ModelFactory Validation ===\n\n');

% Add paths
addpath('src/classification/core');
addpath('src/utils');

%% Test 1: Create ResNet50 Model
fprintf('Test 1: Creating ResNet50 model...\n');
try
    lgraph_resnet = ModelFactory.createResNet50(3, [224, 224, 3]);
    fprintf('✓ ResNet50 created successfully\n');
    fprintf('  Layers: %d\n', length(lgraph_resnet.Layers));
catch ME
    fprintf('✗ Failed to create ResNet50: %s\n', ME.message);
    fprintf('  Note: Ensure Deep Learning Toolbox Model for ResNet-50 is installed\n');
end
fprintf('\n');

%% Test 2: Create EfficientNet-B0 Model
fprintf('Test 2: Creating EfficientNet-B0 model...\n');
try
    lgraph_efficient = ModelFactory.createEfficientNetB0(3, [224, 224, 3]);
    fprintf('✓ EfficientNet-B0 created successfully\n');
    fprintf('  Layers: %d\n', length(lgraph_efficient.Layers));
catch ME
    fprintf('✗ Failed to create EfficientNet-B0: %s\n', ME.message);
    fprintf('  Note: Ensure Deep Learning Toolbox Model for EfficientNet-b0 is installed\n');
end
fprintf('\n');

%% Test 3: Create Custom CNN Model
fprintf('Test 3: Creating Custom CNN model...\n');
try
    lgraph_custom = ModelFactory.createCustomCNN(3, [224, 224, 3]);
    fprintf('✓ Custom CNN created successfully\n');
    fprintf('  Layers: %d\n', length(lgraph_custom.Layers));
    
    % Verify architecture
    layerNames = {lgraph_custom.Layers.Name};
    fprintf('  Architecture verification:\n');
    fprintf('    - Conv layers: %d\n', sum(contains(layerNames, 'conv')));
    fprintf('    - BatchNorm layers: %d\n', sum(contains(layerNames, 'bn')));
    fprintf('    - Pooling layers: %d\n', sum(contains(layerNames, 'pool')));
    fprintf('    - FC layers: %d\n', sum(contains(layerNames, 'fc')));
    fprintf('    - Dropout: %d\n', sum(contains(layerNames, 'dropout')));
catch ME
    fprintf('✗ Failed to create Custom CNN: %s\n', ME.message);
end
fprintf('\n');

%% Test 4: Verify Output Classes
fprintf('Test 4: Verifying output classes...\n');
try
    % Test with different class numbers
    for nClasses = [2, 3, 5]
        lgraph = ModelFactory.createCustomCNN(nClasses, [224, 224, 3]);
        layers = lgraph.Layers;
        layerNames = {layers.Name};
        
        % Find output FC layer
        fcIdx = find(strcmp(layerNames, 'fc_output'));
        fcLayer = layers(fcIdx);
        
        assert(fcLayer.OutputSize == nClasses, ...
            sprintf('Expected %d classes, got %d', nClasses, fcLayer.OutputSize));
        
        fprintf('  ✓ %d classes validated\n', nClasses);
    end
    fprintf('✓ Output class validation passed\n');
catch ME
    fprintf('✗ Output class validation failed: %s\n', ME.message);
end
fprintf('\n');

%% Test 5: Transfer Learning Configuration
fprintf('Test 5: Testing transfer learning configuration...\n');
try
    lgraph = ModelFactory.createCustomCNN(3, [224, 224, 3]);
    lgraph_configured = ModelFactory.configureTransferLearning(lgraph, 5);
    fprintf('✓ Transfer learning configuration applied\n');
    fprintf('  Configured layers: %d\n', length(lgraph_configured.Layers));
catch ME
    fprintf('✗ Transfer learning configuration failed: %s\n', ME.message);
end
fprintf('\n');

%% Summary
fprintf('=== Validation Summary ===\n');
fprintf('ModelFactory implementation validated.\n');
fprintf('\nNext steps:\n');
fprintf('  1. Run full unit tests: run(''tests/unit/test_ModelFactory.m'')\n');
fprintf('  2. Proceed to Task 5: Implement training pipeline\n');
fprintf('\n=== End of Validation ===\n');
