# TrainingEngine Implementation Guide

## Overview

The `TrainingEngine` class manages the complete training workflow for classification models, including training loop execution, monitoring, checkpointing, and early stopping.

## Requirements Addressed

- **4.1**: Training pipeline with configurable epochs and early stopping
- **4.3**: Training monitoring with loss and accuracy logging
- **4.4**: Checkpointing system for best and last models
- **7.1**: ErrorHandler integration for comprehensive logging

## Class Structure

### Properties

- `lgraph`: Layer graph or network to train
- `trainingOptions`: Training configuration struct
- `errorHandler`: ErrorHandler instance for logging
- `checkpointDir`: Directory for saving checkpoints
- `bestValAccuracy`: Best validation accuracy achieved
- `bestEpoch`: Epoch with best validation accuracy
- `epochsWithoutImprovement`: Counter for early stopping

### Key Methods

#### Constructor

```matlab
engine = TrainingEngine(lgraph, config)
```

**Inputs:**
- `lgraph`: Layer graph from ModelFactory
- `config`: Configuration struct with fields:
  - `trainingOptions`: Training parameters
  - `checkpointDir`: Checkpoint directory path
  - `errorHandler`: ErrorHandler instance (optional)

**Example:**
```matlab
% Create model
lgraph = ModelFactory.createResNet50(3, [224, 224, 3]);

% Configure training
config = struct();
config.trainingOptions = struct(...
    'maxEpochs', 50, ...
    'miniBatchSize', 32, ...
    'initialLearnRate', 1e-4, ...
    'validationPatience', 10);
config.checkpointDir = 'output/classification/checkpoints';

% Create engine
engine = TrainingEngine(lgraph, config);
```

#### train()

```matlab
[trainedNet, history] = engine.train(trainDS, valDS, modelName)
```

**Inputs:**
- `trainDS`: Training datastore (imageDatastore or augmentedImageDatastore)
- `valDS`: Validation datastore
- `modelName`: Name for saving checkpoints (optional)

**Outputs:**
- `trainedNet`: Trained network (best model if early stopping occurred)
- `history`: Training history struct with fields:
  - `epoch`: Array of epoch numbers
  - `trainLoss`: Training loss per epoch
  - `trainAccuracy`: Training accuracy per epoch
  - `valLoss`: Validation loss per epoch
  - `valAccuracy`: Validation accuracy per epoch
  - `learningRate`: Learning rate per epoch
  - `timestamp`: Training start timestamp
  - `modelName`: Model name

**Example:**
```matlab
% Prepare datasets
dataManager = DatasetManager(imageDir, labelCSV, config);
[trainDS, valDS, testDS] = dataManager.prepareDatasets([224, 224]);

% Apply augmentation to training data
trainDS = dataManager.applyAugmentation(trainDS, [224, 224]);

% Train model
[trainedNet, history] = engine.train(trainDS, valDS, 'ResNet50');
```

#### saveCheckpoint()

```matlab
engine.saveCheckpoint(net, epoch, history, modelName, checkpointType)
```

**Inputs:**
- `net`: Network to save
- `epoch`: Current epoch number
- `history`: Training history struct
- `modelName`: Model name for filename
- `checkpointType`: 'best' or 'last'

**Checkpoint Structure:**
- `net`: Trained network
- `epoch`: Epoch number
- `history`: Training history
- `timestamp`: Save timestamp
- `modelName`: Model name
- `checkpointType`: 'best' or 'last'
- `valAccuracy`: Validation accuracy (for 'best' checkpoints)

#### loadCheckpoint()

```matlab
net = engine.loadCheckpoint(modelName, checkpointType)
```

**Inputs:**
- `modelName`: Model name
- `checkpointType`: 'best' or 'last' (default: 'best')

**Output:**
- `net`: Loaded network

**Example:**
```matlab
% Load best model
bestNet = engine.loadCheckpoint('ResNet50', 'best');

% Load last checkpoint for resuming
lastNet = engine.loadCheckpoint('ResNet50', 'last');
```

#### plotTrainingHistory()

```matlab
engine.plotTrainingHistory(history, outputPath)
```

**Inputs:**
- `history`: Training history struct
- `outputPath`: Path to save figure (optional)

**Generates:**
- Two-panel figure with loss and accuracy curves
- Training (solid line) and validation (dashed line)
- Saved as PNG and PDF

**Example:**
```matlab
% Plot and save training history
outputPath = 'output/classification/figures/training_curves_ResNet50.png';
engine.plotTrainingHistory(history, outputPath);
```

## Training Configuration

### Default Configuration

```matlab
DEFAULT_CONFIG = struct(...
    'maxEpochs', 50, ...              % Maximum training epochs
    'miniBatchSize', 32, ...          % Mini-batch size
    'initialLearnRate', 1e-4, ...     % Initial learning rate
    'learnRateSchedule', 'piecewise', ... % LR schedule type
    'learnRateDropFactor', 0.1, ...   % LR reduction factor
    'learnRateDropPeriod', 10, ...    % Epochs between LR drops
    'validationFrequency', 50, ...    % Iterations between validation
    'validationPatience', 10, ...     % Epochs without improvement before stopping
    'shuffle', 'every-epoch', ...     % Data shuffling strategy
    'verbose', true, ...              % Display training progress
    'plots', 'none' ...               % Built-in plots (we use custom)
);
```

### Custom Configuration Example

```matlab
config = struct();
config.trainingOptions = struct(...
    'maxEpochs', 100, ...
    'miniBatchSize', 16, ...
    'initialLearnRate', 5e-5, ...
    'validationPatience', 15);
config.checkpointDir = 'my_checkpoints';

engine = TrainingEngine(lgraph, config);
```

## Training Workflow

### Complete Training Pipeline

```matlab
% 1. Create model
lgraph = ModelFactory.createResNet50(3, [224, 224, 3]);

% 2. Prepare datasets
dataManager = DatasetManager(imageDir, labelCSV, config);
[trainDS, valDS, testDS] = dataManager.prepareDatasets([224, 224]);

% 3. Apply augmentation
trainDS = dataManager.applyAugmentation(trainDS, [224, 224]);

% 4. Configure training
config = struct();
config.trainingOptions = struct(...
    'maxEpochs', 50, ...
    'miniBatchSize', 32, ...
    'initialLearnRate', 1e-4, ...
    'validationPatience', 10);
config.checkpointDir = 'output/classification/checkpoints';

% 5. Create training engine
engine = TrainingEngine(lgraph, config);

% 6. Train model
[trainedNet, history] = engine.train(trainDS, valDS, 'ResNet50');

% 7. Plot training history
engine.plotTrainingHistory(history, 'output/classification/figures/training_ResNet50.png');

% 8. Save final model
save('output/classification/models/ResNet50_final.mat', 'trainedNet', 'history');
```

## Features

### 1. Training Monitoring

The engine logs detailed training progress:

```
[INFO] TrainingEngine: Epoch 1/50 - Train Loss: 1.0234, Train Acc: 0.4567, Val Loss: 0.9876, Val Acc: 0.5123
[INFO] TrainingEngine: *** New best validation accuracy: 0.5123 at epoch 1 ***
[INFO] TrainingEngine: Epoch 2/50 - Train Loss: 0.8765, Train Acc: 0.5678, Val Loss: 0.8543, Val Acc: 0.6234
[INFO] TrainingEngine: *** New best validation accuracy: 0.6234 at epoch 2 ***
```

### 2. Early Stopping

Automatically stops training when validation accuracy plateaus:

```
[INFO] TrainingEngine: No improvement for 8 epochs (patience: 10)
[INFO] TrainingEngine: No improvement for 9 epochs (patience: 10)
[INFO] TrainingEngine: No improvement for 10 epochs (patience: 10)
[WARNING] TrainingEngine: Early stopping triggered at epoch 25
[INFO] TrainingEngine: Best model was at epoch 15 with val accuracy: 0.9234
```

### 3. Checkpointing

Saves two types of checkpoints:
- **Best checkpoint**: Model with highest validation accuracy
- **Last checkpoint**: Most recent model (for resuming)

Checkpoint files:
- `{modelName}_best.mat`: Best model
- `{modelName}_last.mat`: Last epoch model

### 4. Learning Rate Scheduling

Automatically reduces learning rate on plateau:
- Schedule: Piecewise (step decay)
- Drop factor: 0.1 (10x reduction)
- Drop period: Every 10 epochs

### 5. Training History

Complete training history is saved with each checkpoint:

```matlab
history = struct(...
    'epoch', [1, 2, 3, ...], ...
    'trainLoss', [1.02, 0.87, 0.65, ...], ...
    'trainAccuracy', [0.45, 0.56, 0.72, ...], ...
    'valLoss', [0.98, 0.85, 0.68, ...], ...
    'valAccuracy', [0.51, 0.62, 0.75, ...], ...
    'learningRate', [1e-4, 1e-4, 1e-5, ...], ...
    'timestamp', datetime('now'), ...
    'modelName', 'ResNet50' ...
);
```

## Integration with Other Components

### With ModelFactory

```matlab
% Create different architectures
lgraph1 = ModelFactory.createResNet50(3, [224, 224, 3]);
lgraph2 = ModelFactory.createEfficientNetB0(3, [224, 224, 3]);
lgraph3 = ModelFactory.createCustomCNN(3, [224, 224, 3]);

% Train each with same engine configuration
engine = TrainingEngine(lgraph1, config);
[net1, hist1] = engine.train(trainDS, valDS, 'ResNet50');

engine = TrainingEngine(lgraph2, config);
[net2, hist2] = engine.train(trainDS, valDS, 'EfficientNetB0');

engine = TrainingEngine(lgraph3, config);
[net3, hist3] = engine.train(trainDS, valDS, 'CustomCNN');
```

### With DatasetManager

```matlab
% Prepare datasets with augmentation
dataManager = DatasetManager(imageDir, labelCSV, config);
[trainDS, valDS, testDS] = dataManager.prepareDatasets([224, 224]);

% Apply augmentation only to training data
trainDS = dataManager.applyAugmentation(trainDS, [224, 224]);

% Train with augmented data
engine = TrainingEngine(lgraph, config);
[trainedNet, history] = engine.train(trainDS, valDS, 'model');
```

### With ErrorHandler

```matlab
% Initialize error handler
errorHandler = ErrorHandler.getInstance();
errorHandler.setLogFile('training.log');

% Pass to training engine
config.errorHandler = errorHandler;
engine = TrainingEngine(lgraph, config);

% All training events are logged
[trainedNet, history] = engine.train(trainDS, valDS, 'model');
```

## Testing

### Run Integration Tests

```matlab
% Run all tests
test_TrainingEngine();

% Or use validation script
validate_training_engine();
```

### Test Coverage

1. **Training loop execution**: Verifies training completes successfully
2. **Early stopping**: Tests patience mechanism
3. **Checkpointing**: Validates save/load functionality
4. **History logging**: Checks history structure and plotting

## Troubleshooting

### Out of Memory

**Problem**: GPU runs out of memory during training

**Solutions:**
- Reduce mini-batch size: `config.trainingOptions.miniBatchSize = 16;`
- Use smaller input size: `[trainDS, valDS, testDS] = dataManager.prepareDatasets([128, 128]);`
- Use CustomCNN instead of ResNet50

### Training Diverges (NaN Loss)

**Problem**: Loss becomes NaN during training

**Solutions:**
- Reduce learning rate: `config.trainingOptions.initialLearnRate = 1e-5;`
- Check data normalization in DatasetManager
- Verify labels are correct (0, 1, 2 for 3 classes)

### Early Stopping Too Aggressive

**Problem**: Training stops too early

**Solutions:**
- Increase patience: `config.trainingOptions.validationPatience = 20;`
- Reduce validation frequency: `config.trainingOptions.validationFrequency = 100;`
- Use lower learning rate for more stable training

### Checkpoint Not Found

**Problem**: Cannot load checkpoint

**Solutions:**
- Verify checkpoint directory exists
- Check model name matches exactly
- Ensure training completed at least one epoch

## Performance Tips

1. **Use GPU**: Ensure MATLAB can access GPU for faster training
   ```matlab
   gpuDevice(1); % Select GPU
   ```

2. **Optimize batch size**: Larger batches = faster training (if memory allows)
   ```matlab
   config.trainingOptions.miniBatchSize = 64;
   ```

3. **Reduce validation frequency**: Less frequent validation = faster training
   ```matlab
   config.trainingOptions.validationFrequency = 100;
   ```

4. **Use parallel workers**: Enable parallel data loading
   ```matlab
   trainDS.ReadFcn = @(x) imresize(imread(x), [224, 224]);
   ```

## Next Steps

After training models with TrainingEngine:

1. **Evaluate models**: Use EvaluationEngine (Task 6)
2. **Compare models**: Generate comparison visualizations (Task 7)
3. **Export results**: Create LaTeX tables and figures (Task 7)

## References

- Requirements: 4.1, 4.3, 4.4, 7.1
- Design Document: `.kiro/specs/corrosion-classification-system/design.md`
- Related Classes: `ModelFactory`, `DatasetManager`, `ErrorHandler`
