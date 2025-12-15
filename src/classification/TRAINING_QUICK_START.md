# TrainingEngine Quick Start Guide

## Minimal Example

```matlab
% 1. Add paths
addpath(genpath('src'));

% 2. Create model
lgraph = ModelFactory.createCustomCNN(3, [224, 224, 3]);

% 3. Prepare data
imageDir = 'img/original';
labelCSV = 'output/classification/labels.csv';
dataManager = DatasetManager(imageDir, labelCSV, struct());
[trainDS, valDS, testDS] = dataManager.prepareDatasets([224, 224]);

% 4. Apply augmentation
trainDS = dataManager.applyAugmentation(trainDS, [224, 224]);

% 5. Configure training
config = struct();
config.trainingOptions = struct(...
    'maxEpochs', 50, ...
    'miniBatchSize', 32, ...
    'initialLearnRate', 1e-4, ...
    'validationPatience', 10);
config.checkpointDir = 'output/classification/checkpoints';

% 6. Create engine and train
engine = TrainingEngine(lgraph, config);
[trainedNet, history] = engine.train(trainDS, valDS, 'CustomCNN');

% 7. Plot results
engine.plotTrainingHistory(history, 'output/classification/figures/training_curves.png');

% 8. Save model
save('output/classification/models/CustomCNN_final.mat', 'trainedNet', 'history');
```

## Train All Three Models

```matlab
% Configuration
imageDir = 'img/original';
labelCSV = 'output/classification/labels.csv';
inputSize = [224, 224];

% Prepare data once
dataManager = DatasetManager(imageDir, labelCSV, struct());
[trainDS, valDS, testDS] = dataManager.prepareDatasets(inputSize);
trainDS = dataManager.applyAugmentation(trainDS, inputSize);

% Training configuration
config = struct();
config.trainingOptions = struct(...
    'maxEpochs', 50, ...
    'miniBatchSize', 32, ...
    'initialLearnRate', 1e-4, ...
    'validationPatience', 10);
config.checkpointDir = 'output/classification/checkpoints';

% Train ResNet50
fprintf('Training ResNet50...\n');
lgraph1 = ModelFactory.createResNet50(3, [inputSize, 3]);
engine1 = TrainingEngine(lgraph1, config);
[net1, hist1] = engine1.train(trainDS, valDS, 'ResNet50');
engine1.plotTrainingHistory(hist1, 'output/classification/figures/training_ResNet50.png');

% Train EfficientNetB0
fprintf('Training EfficientNetB0...\n');
lgraph2 = ModelFactory.createEfficientNetB0(3, [inputSize, 3]);
engine2 = TrainingEngine(lgraph2, config);
[net2, hist2] = engine2.train(trainDS, valDS, 'EfficientNetB0');
engine2.plotTrainingHistory(hist2, 'output/classification/figures/training_EfficientNetB0.png');

% Train CustomCNN
fprintf('Training CustomCNN...\n');
lgraph3 = ModelFactory.createCustomCNN(3, [inputSize, 3]);
engine3 = TrainingEngine(lgraph3, config);
[net3, hist3] = engine3.train(trainDS, valDS, 'CustomCNN');
engine3.plotTrainingHistory(hist3, 'output/classification/figures/training_CustomCNN.png');

fprintf('All models trained successfully!\n');
```

## Custom Configuration

```matlab
% Advanced configuration
config = struct();
config.trainingOptions = struct(...
    'maxEpochs', 100, ...              % More epochs
    'miniBatchSize', 16, ...           % Smaller batches (less memory)
    'initialLearnRate', 5e-5, ...      % Lower learning rate
    'learnRateSchedule', 'piecewise', ...
    'learnRateDropFactor', 0.1, ...
    'learnRateDropPeriod', 15, ...     % Drop LR every 15 epochs
    'validationFrequency', 100, ...    % Validate less frequently
    'validationPatience', 15, ...      % More patience
    'shuffle', 'every-epoch', ...
    'verbose', true, ...
    'plots', 'none');
config.checkpointDir = 'my_checkpoints';
config.errorHandler = ErrorHandler.getInstance();

engine = TrainingEngine(lgraph, config);
[trainedNet, history] = engine.train(trainDS, valDS, 'MyModel');
```

## Load and Resume

```matlab
% Load best checkpoint
engine = TrainingEngine(lgraph, config);
bestNet = engine.loadCheckpoint('ResNet50', 'best');

% Load last checkpoint
lastNet = engine.loadCheckpoint('ResNet50', 'last');

% Use loaded model for inference
predictions = classify(bestNet, testDS);
```

## Troubleshooting

### Out of Memory
```matlab
% Reduce batch size
config.trainingOptions.miniBatchSize = 8;

% Or use smaller input size
[trainDS, valDS, testDS] = dataManager.prepareDatasets([128, 128]);
```

### Training Too Slow
```matlab
% Increase batch size (if memory allows)
config.trainingOptions.miniBatchSize = 64;

% Reduce validation frequency
config.trainingOptions.validationFrequency = 200;

% Use CustomCNN instead of ResNet50
lgraph = ModelFactory.createCustomCNN(3, [224, 224, 3]);
```

### Early Stopping Too Soon
```matlab
% Increase patience
config.trainingOptions.validationPatience = 20;

% Or reduce learning rate for more stable training
config.trainingOptions.initialLearnRate = 1e-5;
```

## Next Steps

After training:
1. Evaluate models with EvaluationEngine (Task 6)
2. Generate visualizations (Task 7)
3. Compare model performance (Task 8)
4. Export results for publication (Task 9)

## See Also

- Full documentation: `TRAINING_ENGINE_GUIDE.md`
- Integration tests: `tests/integration/test_TrainingEngine.m`
- Validation script: `validate_training_engine.m`
