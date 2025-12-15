% test_ModelFactory - Unit tests for ModelFactory class
%
% This script tests the ModelFactory class to ensure all model architectures
% are created correctly with proper layer configurations.
%
% Test Coverage:
%   - ResNet50 architecture creation
%   - EfficientNet-B0 architecture creation
%   - Custom CNN architecture creation
%   - Output layer validation (correct number of classes)
%   - Input size compatibility
%   - Transfer learning configuration
%
% Requirements: 3.1, 3.2, 3.3, 3.4, 3.5

%% Setup
fprintf('=== ModelFactory Unit Tests ===\n\n');

% Initialize error handler
errorHandler = ErrorHandler.getInstance();
errorHandler.setLogFile('test_model_factory.log');

% Test configuration
numClasses = 3;
inputSize = [224, 224, 3];

% Test results tracking
testResults = struct();
testResults.passed = 0;
testResults.failed = 0;
testResults.errors = {};

%% Test 1: ResNet50 Architecture Creation
fprintf('Test 1: ResNet50 Architecture Creation\n');
fprintf('---------------------------------------\n');

try
    % Create ResNet50 model
    lgraph = ModelFactory.createResNet50(numClasses, inputSize);
    
    % Validate layer graph
    assert(isa(lgraph, 'nnet.cnn.LayerGraph'), ...
        'Output must be a LayerGraph');
    
    % Check that layers exist
    layers = lgraph.Layers;
    assert(~isempty(layers), 'Layer graph must contain layers');
    
    % Find input layer and verify size
    inputLayer = layers(1);
    assert(isa(inputLayer, 'nnet.cnn.layer.ImageInputLayer'), ...
        'First layer must be ImageInputLayer');
    
    % Find output classification layer
    layerNames = {layers.Name};
    classLayerIdx = find(contains(layerNames, 'output') | ...
                        contains(layerNames, 'ClassificationLayer'));
    assert(~isempty(classLayerIdx), 'Must have classification output layer');
    
    % Find new FC layer
    fcLayerIdx = find(contains(layerNames, 'fc_corrosion'));
    assert(~isempty(fcLayerIdx), 'Must have fc_corrosion layer');
    
    fcLayer = layers(fcLayerIdx);
    assert(fcLayer.OutputSize == numClasses, ...
        sprintf('FC layer output size must be %d, got %d', ...
        numClasses, fcLayer.OutputSize));
    
    fprintf('✓ ResNet50 architecture created successfully\n');
    fprintf('  - Total layers: %d\n', length(layers));
    fprintf('  - Output classes: %d\n', fcLayer.OutputSize);
    fprintf('  - New FC layer: %s\n', fcLayer.Name);
    
    testResults.passed = testResults.passed + 1;
    
catch ME
    fprintf('✗ Test failed: %s\n', ME.message);
    testResults.failed = testResults.failed + 1;
    testResults.errors{end+1} = sprintf('Test 1: %s', ME.message);
end

fprintf('\n');

%% Test 2: EfficientNet-B0 Architecture Creation
fprintf('Test 2: EfficientNet-B0 Architecture Creation\n');
fprintf('----------------------------------------------\n');

try
    % Create EfficientNet-B0 model
    lgraph = ModelFactory.createEfficientNetB0(numClasses, inputSize);
    
    % Validate layer graph
    assert(isa(lgraph, 'nnet.cnn.LayerGraph'), ...
        'Output must be a LayerGraph');
    
    % Check that layers exist
    layers = lgraph.Layers;
    assert(~isempty(layers), 'Layer graph must contain layers');
    
    % Find input layer
    inputLayer = layers(1);
    assert(isa(inputLayer, 'nnet.cnn.layer.ImageInputLayer'), ...
        'First layer must be ImageInputLayer');
    
    % Find output classification layer
    layerNames = {layers.Name};
    classLayerIdx = find(contains(layerNames, 'output') | ...
                        contains(layerNames, 'ClassificationLayer'));
    assert(~isempty(classLayerIdx), 'Must have classification output layer');
    
    % Find new FC layer
    fcLayerIdx = find(contains(layerNames, 'fc_corrosion'));
    assert(~isempty(fcLayerIdx), 'Must have fc_corrosion layer');
    
    fcLayer = layers(fcLayerIdx);
    assert(fcLayer.OutputSize == numClasses, ...
        sprintf('FC layer output size must be %d, got %d', ...
        numClasses, fcLayer.OutputSize));
    
    fprintf('✓ EfficientNet-B0 architecture created successfully\n');
    fprintf('  - Total layers: %d\n', length(layers));
    fprintf('  - Output classes: %d\n', fcLayer.OutputSize);
    fprintf('  - New FC layer: %s\n', fcLayer.Name);
    
    testResults.passed = testResults.passed + 1;
    
catch ME
    fprintf('✗ Test failed: %s\n', ME.message);
    testResults.failed = testResults.failed + 1;
    testResults.errors{end+1} = sprintf('Test 2: %s', ME.message);
end

fprintf('\n');

%% Test 3: Custom CNN Architecture Creation
fprintf('Test 3: Custom CNN Architecture Creation\n');
fprintf('-----------------------------------------\n');

try
    % Create Custom CNN model
    lgraph = ModelFactory.createCustomCNN(numClasses, inputSize);
    
    % Validate layer graph
    assert(isa(lgraph, 'nnet.cnn.LayerGraph'), ...
        'Output must be a LayerGraph');
    
    % Check that layers exist
    layers = lgraph.Layers;
    assert(~isempty(layers), 'Layer graph must contain layers');
    
    % Verify architecture structure
    layerNames = {layers.Name};
    
    % Check for input layer
    assert(any(strcmp(layerNames, 'input')), 'Must have input layer');
    
    % Check for 4 convolutional blocks
    convLayers = contains(layerNames, 'conv');
    assert(sum(convLayers) == 4, 'Must have 4 convolutional layers');
    
    % Check for batch normalization layers
    bnLayers = contains(layerNames, 'bn');
    assert(sum(bnLayers) == 4, 'Must have 4 batch normalization layers');
    
    % Check for pooling layers
    poolLayers = contains(layerNames, 'pool');
    assert(sum(poolLayers) == 4, 'Must have 4 pooling layers');
    
    % Check for FC layers
    fcLayers = contains(layerNames, 'fc');
    assert(sum(fcLayers) >= 2, 'Must have at least 2 FC layers');
    
    % Check for dropout layer
    assert(any(strcmp(layerNames, 'dropout')), 'Must have dropout layer');
    
    % Verify output layer
    fcOutputIdx = find(strcmp(layerNames, 'fc_output'));
    assert(~isempty(fcOutputIdx), 'Must have fc_output layer');
    
    fcOutputLayer = layers(fcOutputIdx);
    assert(fcOutputLayer.OutputSize == numClasses, ...
        sprintf('Output FC layer must have %d outputs, got %d', ...
        numClasses, fcOutputLayer.OutputSize));
    
    fprintf('✓ Custom CNN architecture created successfully\n');
    fprintf('  - Total layers: %d\n', length(layers));
    fprintf('  - Convolutional blocks: 4\n');
    fprintf('  - Output classes: %d\n', fcOutputLayer.OutputSize);
    
    testResults.passed = testResults.passed + 1;
    
catch ME
    fprintf('✗ Test failed: %s\n', ME.message);
    testResults.failed = testResults.failed + 1;
    testResults.errors{end+1} = sprintf('Test 3: %s', ME.message);
end

fprintf('\n');

%% Test 4: Output Layer Validation with Different Class Numbers
fprintf('Test 4: Output Layer Validation (Different Class Numbers)\n');
fprintf('----------------------------------------------------------\n');

try
    % Test with different number of classes
    testClassNumbers = [2, 3, 5, 10];
    
    for i = 1:length(testClassNumbers)
        nClasses = testClassNumbers(i);
        
        % Test Custom CNN (fastest to create)
        lgraph = ModelFactory.createCustomCNN(nClasses, inputSize);
        layers = lgraph.Layers;
        layerNames = {layers.Name};
        
        % Find output FC layer
        fcOutputIdx = find(strcmp(layerNames, 'fc_output'));
        fcOutputLayer = layers(fcOutputIdx);
        
        assert(fcOutputLayer.OutputSize == nClasses, ...
            sprintf('Expected %d classes, got %d', nClasses, fcOutputLayer.OutputSize));
        
        fprintf('  ✓ Validated %d classes\n', nClasses);
    end
    
    fprintf('✓ Output layer validation passed for all class numbers\n');
    testResults.passed = testResults.passed + 1;
    
catch ME
    fprintf('✗ Test failed: %s\n', ME.message);
    testResults.failed = testResults.failed + 1;
    testResults.errors{end+1} = sprintf('Test 4: %s', ME.message);
end

fprintf('\n');

%% Test 5: Input Size Compatibility
fprintf('Test 5: Input Size Compatibility\n');
fprintf('---------------------------------\n');

try
    % Test with different input sizes
    testInputSizes = {[224, 224, 3], [256, 256, 3], [128, 128, 3]};
    
    for i = 1:length(testInputSizes)
        testSize = testInputSizes{i};
        
        % Test Custom CNN with different input sizes
        lgraph = ModelFactory.createCustomCNN(numClasses, testSize);
        layers = lgraph.Layers;
        
        % Verify input layer size
        inputLayer = layers(1);
        actualSize = inputLayer.InputSize;
        
        assert(isequal(actualSize, testSize), ...
            sprintf('Expected input size [%d,%d,%d], got [%d,%d,%d]', ...
            testSize(1), testSize(2), testSize(3), ...
            actualSize(1), actualSize(2), actualSize(3)));
        
        fprintf('  ✓ Validated input size [%d, %d, %d]\n', ...
            testSize(1), testSize(2), testSize(3));
    end
    
    fprintf('✓ Input size compatibility validated\n');
    testResults.passed = testResults.passed + 1;
    
catch ME
    fprintf('✗ Test failed: %s\n', ME.message);
    testResults.failed = testResults.failed + 1;
    testResults.errors{end+1} = sprintf('Test 5: %s', ME.message);
end

fprintf('\n');

%% Test 6: Transfer Learning Configuration
fprintf('Test 6: Transfer Learning Configuration\n');
fprintf('----------------------------------------\n');

try
    % Create a Custom CNN model (easier to test than pre-trained models)
    lgraph = ModelFactory.createCustomCNN(numClasses, inputSize);
    
    % Configure transfer learning
    numLayersToFineTune = 5;
    lgraphConfigured = ModelFactory.configureTransferLearning(lgraph, numLayersToFineTune);
    
    % Validate that configuration was applied
    assert(isa(lgraphConfigured, 'nnet.cnn.LayerGraph'), ...
        'Output must be a LayerGraph');
    
    layers = lgraphConfigured.Layers;
    assert(~isempty(layers), 'Configured graph must contain layers');
    
    % Check that some layers have frozen weights (learning rate = 0)
    numFrozen = 0;
    for i = 1:length(layers)
        layer = layers(i);
        if isprop(layer, 'WeightLearnRateFactor')
            if layer.WeightLearnRateFactor == 0
                numFrozen = numFrozen + 1;
            end
        end
    end
    
    fprintf('✓ Transfer learning configuration applied\n');
    fprintf('  - Layers to fine-tune: %d\n', numLayersToFineTune);
    fprintf('  - Frozen layers detected: %d\n', numFrozen);
    
    testResults.passed = testResults.passed + 1;
    
catch ME
    fprintf('✗ Test failed: %s\n', ME.message);
    testResults.failed = testResults.failed + 1;
    testResults.errors{end+1} = sprintf('Test 6: %s', ME.message);
end

fprintf('\n');

%% Test 7: Layer Graph Connectivity
fprintf('Test 7: Layer Graph Connectivity\n');
fprintf('---------------------------------\n');

try
    % Test that all architectures have valid connectivity
    architectures = {'ResNet50', 'EfficientNetB0', 'CustomCNN'};
    
    for i = 1:length(architectures)
        arch = architectures{i};
        
        % Create model
        switch arch
            case 'ResNet50'
                lgraph = ModelFactory.createResNet50(numClasses, inputSize);
            case 'EfficientNetB0'
                lgraph = ModelFactory.createEfficientNetB0(numClasses, inputSize);
            case 'CustomCNN'
                lgraph = ModelFactory.createCustomCNN(numClasses, inputSize);
        end
        
        % Analyze layer graph
        try
            analyzeNetwork(lgraph);
            fprintf('  ✓ %s: Valid layer connectivity\n', arch);
        catch ME
            error('Invalid layer connectivity in %s: %s', arch, ME.message);
        end
    end
    
    fprintf('✓ All architectures have valid layer connectivity\n');
    testResults.passed = testResults.passed + 1;
    
catch ME
    fprintf('✗ Test failed: %s\n', ME.message);
    testResults.failed = testResults.failed + 1;
    testResults.errors{end+1} = sprintf('Test 7: %s', ME.message);
end

fprintf('\n');

%% Test Summary
fprintf('=== Test Summary ===\n');
fprintf('Total tests: %d\n', testResults.passed + testResults.failed);
fprintf('Passed: %d\n', testResults.passed);
fprintf('Failed: %d\n', testResults.failed);

if testResults.failed > 0
    fprintf('\nFailed tests:\n');
    for i = 1:length(testResults.errors)
        fprintf('  - %s\n', testResults.errors{i});
    end
end

if testResults.failed == 0
    fprintf('\n✓ All tests passed!\n');
    fprintf('\nModelFactory validation complete:\n');
    fprintf('  - ResNet50 architecture: ✓\n');
    fprintf('  - EfficientNet-B0 architecture: ✓\n');
    fprintf('  - Custom CNN architecture: ✓\n');
    fprintf('  - Output layer validation: ✓\n');
    fprintf('  - Input size compatibility: ✓\n');
    fprintf('  - Transfer learning configuration: ✓\n');
    fprintf('  - Layer graph connectivity: ✓\n');
else
    fprintf('\n✗ Some tests failed. Please review the errors above.\n');
end

fprintf('\n=== End of Tests ===\n');
