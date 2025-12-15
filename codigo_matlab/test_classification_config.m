% Test script for ClassificationConfig
% This script validates the configuration system setup

fprintf('Testing ClassificationConfig...\n\n');

try
    % Test 1: Create default configuration
    fprintf('Test 1: Creating default configuration...\n');
    config = ClassificationConfig();
    fprintf('✓ Default configuration created successfully\n\n');
    
    % Test 2: Display configuration
    fprintf('Test 2: Displaying configuration...\n');
    config.displayConfig();
    fprintf('✓ Configuration displayed successfully\n\n');
    
    % Test 3: Validate configuration
    fprintf('Test 3: Validating configuration...\n');
    config.validateConfig();
    fprintf('✓ Configuration validation passed\n\n');
    
    % Test 4: Get configuration as struct
    fprintf('Test 4: Getting configuration as struct...\n');
    configStruct = config.getConfig();
    assert(isstruct(configStruct), 'Configuration should be a struct');
    assert(isfield(configStruct, 'paths'), 'Configuration should have paths field');
    assert(isfield(configStruct, 'training'), 'Configuration should have training field');
    fprintf('✓ Configuration struct retrieved successfully\n\n');
    
    % Test 5: Verify paths
    fprintf('Test 5: Verifying paths...\n');
    assert(isfolder(config.paths.outputDir), 'Output directory should exist');
    assert(isfolder(config.paths.checkpointDir), 'Checkpoint directory should exist');
    assert(isfolder(config.paths.resultsDir), 'Results directory should exist');
    assert(isfolder(config.paths.figuresDir), 'Figures directory should exist');
    assert(isfolder(config.paths.latexDir), 'LaTeX directory should exist');
    assert(isfolder(config.paths.logsDir), 'Logs directory should exist');
    fprintf('✓ All output directories exist\n\n');
    
    % Test 6: Verify label generation config
    fprintf('Test 6: Verifying label generation configuration...\n');
    assert(length(config.labelGeneration.thresholds) == 2, 'Should have 2 thresholds');
    assert(config.labelGeneration.thresholds(1) == 10, 'First threshold should be 10');
    assert(config.labelGeneration.thresholds(2) == 30, 'Second threshold should be 30');
    assert(config.labelGeneration.numClasses == 3, 'Should have 3 classes');
    fprintf('✓ Label generation configuration is correct\n\n');
    
    % Test 7: Verify dataset config
    fprintf('Test 7: Verifying dataset configuration...\n');
    assert(abs(sum(config.dataset.splitRatios) - 1.0) < 1e-6, 'Split ratios should sum to 1.0');
    assert(all(config.dataset.inputSize == [224, 224]), 'Input size should be [224, 224]');
    fprintf('✓ Dataset configuration is correct\n\n');
    
    % Test 8: Verify training config
    fprintf('Test 8: Verifying training configuration...\n');
    assert(config.training.maxEpochs == 50, 'Max epochs should be 50');
    assert(config.training.miniBatchSize == 32, 'Mini batch size should be 32');
    assert(config.training.initialLearnRate == 1e-4, 'Initial learn rate should be 1e-4');
    fprintf('✓ Training configuration is correct\n\n');
    
    % Test 9: Verify model config
    fprintf('Test 9: Verifying model configuration...\n');
    assert(length(config.models.architectures) == 3, 'Should have 3 model architectures');
    assert(ismember('ResNet50', config.models.architectures), 'Should include ResNet50');
    assert(ismember('EfficientNetB0', config.models.architectures), 'Should include EfficientNetB0');
    assert(ismember('CustomCNN', config.models.architectures), 'Should include CustomCNN');
    fprintf('✓ Model configuration is correct\n\n');
    
    % Test 10: Save and load configuration
    fprintf('Test 10: Testing save and load functionality...\n');
    testConfigFile = 'output/classification/test_config.mat';
    config.saveToFile(testConfigFile);
    assert(isfile(testConfigFile), 'Configuration file should be created');
    
    config2 = ClassificationConfig(testConfigFile);
    assert(config2.training.maxEpochs == config.training.maxEpochs, ...
        'Loaded configuration should match saved configuration');
    fprintf('✓ Save and load functionality works correctly\n\n');
    
    % Clean up test file
    delete(testConfigFile);
    
    fprintf('==============================================\n');
    fprintf('All tests passed! ✓\n');
    fprintf('ClassificationConfig is working correctly.\n');
    fprintf('==============================================\n\n');
    
catch ME
    fprintf('\n✗ Test failed with error:\n');
    fprintf('  %s\n', ME.message);
    fprintf('  In %s (line %d)\n', ME.stack(1).name, ME.stack(1).line);
    rethrow(ME);
end
