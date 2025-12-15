# Classification System Configuration Examples

## Overview

This document provides comprehensive examples of configuration options for the Corrosion Classification System. All configurations are managed through the `ClassificationConfig` class.

## Table of Contents

1. [Default Configuration](#default-configuration)
2. [Quick Testing Configuration](#quick-testing-configuration)
3. [High-Accuracy Configuration](#high-accuracy-configuration)
4. [Fast Inference Configuration](#fast-inference-configuration)
5. [Custom Dataset Configuration](#custom-dataset-configuration)
6. [Single Model Configuration](#single-model-configuration)
7. [Advanced Training Configuration](#advanced-training-configuration)
8. [Custom Label Thresholds](#custom-label-thresholds)
9. [GPU/CPU Configuration](#gpucpu-configuration)
10. [Production Deployment Configuration](#production-deployment-configuration)

---

## Default Configuration

The default configuration provides balanced settings suitable for most use cases.

```matlab
% Create default configuration
config = ClassificationConfig();

% Display all settings
config.displayConfig();

% Use default configuration
executar_classificacao();
```

### Default Parameters

**Paths:**
- `imageDir`: `'img/original'`
- `maskDir`: `'img/masks'`
- `outputDir`: `'output/classification'`

**Label Generation:**
- `thresholds`: `[10, 30]` (Class 0: <10%, Class 1: 10-30%, Class 2: >30%)
- `classNames`: `{'None/Light', 'Moderate', 'Severe'}`

**Dataset:**
- `splitRatios`: `[0.7, 0.15, 0.15]` (70% train, 15% val, 15% test)
- `inputSize`: `[224, 224]`
- `augmentation`: `true`
- `seed`: `42`

**Training:**
- `maxEpochs`: `50`
- `miniBatchSize`: `32`
- `initialLearnRate`: `1e-4`
- `validationPatience`: `10`
- `executionEnvironment`: `'auto'` (GPU if available)

**Models:**
- `architectures`: `{'ResNet50', 'EfficientNetB0', 'CustomCNN'}`
- `transferLearning`: `true`

---

## Quick Testing Configuration

For rapid prototyping and testing (completes in ~15 minutes).

```matlab
% Create quick testing configuration
config = ClassificationConfig();

% Reduce training time
config.training.maxEpochs = 10;              % Reduce from 50 to 10
config.training.validationPatience = 5;      % Reduce from 10 to 5

% Use only lightweight model
config.models.architectures = {'CustomCNN'};

% Smaller batch size for faster iteration
config.training.miniBatchSize = 16;

% Save configuration
config.saveToFile('quick_test_config.mat');

% Run with quick configuration
executar_classificacao('quick_test_config.mat');
```

**Expected time**: ~15 minutes with GPU

---

## High-Accuracy Configuration

For maximum accuracy when training time is not a constraint.

```matlab
% Create high-accuracy configuration
config = ClassificationConfig();

% Extended training
config.training.maxEpochs = 100;             % Increase from 50 to 100
config.training.validationPatience = 15;     % More patience for convergence

% Larger input size for more detail
config.dataset.inputSize = [256, 256];       % Increase from [224, 224]

% Smaller learning rate for fine-tuning
config.training.initialLearnRate = 5e-5;     % Reduce from 1e-4

% Larger batch size for stable gradients
config.training.miniBatchSize = 64;          % Increase from 32

% Use best models
config.models.architectures = {'ResNet50', 'EfficientNetB0'};

% Enable all evaluation metrics
config.evaluation.generateROC = true;
config.evaluation.generateConfusionMatrix = true;
config.evaluation.measureInferenceTime = true;

% Save configuration
config.saveToFile('high_accuracy_config.mat');

% Run with high-accuracy configuration
executar_classificacao('high_accuracy_config.mat');
```

**Expected time**: ~4-5 hours with GPU

---

## Fast Inference Configuration

Optimized for deployment scenarios requiring real-time inference.

```matlab
% Create fast inference configuration
config = ClassificationConfig();

% Use only lightweight model
config.models.architectures = {'CustomCNN'};

% Smaller input size for faster processing
config.dataset.inputSize = [224, 224];

% Standard training (model is already fast)
config.training.maxEpochs = 50;
config.training.miniBatchSize = 32;

% Measure inference time carefully
config.evaluation.measureInferenceTime = true;
config.evaluation.numInferenceSamples = 200;  % More samples for accurate timing

% Save configuration
config.saveToFile('fast_inference_config.mat');

% Run with fast inference configuration
executar_classificacao('fast_inference_config.mat');
```

**Target inference time**: <10 ms per image

---

## Custom Dataset Configuration

For using custom dataset locations and paths.

```matlab
% Create custom dataset configuration
config = ClassificationConfig();

% Set custom paths
config.paths.imageDir = 'data/custom_images';
config.paths.maskDir = 'data/custom_masks';
config.paths.outputDir = 'results/classification';

% Custom output subdirectories
config.paths.checkpointDir = fullfile(config.paths.outputDir, 'models');
config.paths.resultsDir = fullfile(config.paths.outputDir, 'metrics');
config.paths.figuresDir = fullfile(config.paths.outputDir, 'plots');
config.paths.latexDir = fullfile(config.paths.outputDir, 'tables');
config.paths.logsDir = fullfile(config.paths.outputDir, 'logs');

% Custom label output
config.labelGeneration.outputCSV = fullfile(config.paths.outputDir, 'custom_labels.csv');

% Save configuration
config.saveToFile('custom_dataset_config.mat');

% Run with custom dataset configuration
executar_classificacao('custom_dataset_config.mat');
```

---

## Single Model Configuration

For training and evaluating only one specific model.

### ResNet50 Only

```matlab
% Create ResNet50-only configuration
config = ClassificationConfig();

% Train only ResNet50
config.models.architectures = {'ResNet50'};

% Optimize for ResNet50
config.dataset.inputSize = [224, 224];
config.training.miniBatchSize = 32;
config.training.initialLearnRate = 1e-4;

% Save configuration
config.saveToFile('resnet50_only_config.mat');

% Run
executar_classificacao('resnet50_only_config.mat');
```

### EfficientNet-B0 Only

```matlab
% Create EfficientNet-B0-only configuration
config = ClassificationConfig();

% Train only EfficientNet-B0
config.models.architectures = {'EfficientNetB0'};

% Optimize for EfficientNet-B0
config.dataset.inputSize = [224, 224];
config.training.miniBatchSize = 32;
config.training.initialLearnRate = 1e-4;

% Save configuration
config.saveToFile('efficientnet_only_config.mat');

% Run
executar_classificacao('efficientnet_only_config.mat');
```

### Custom CNN Only

```matlab
% Create CustomCNN-only configuration
config = ClassificationConfig();

% Train only CustomCNN
config.models.architectures = {'CustomCNN'};

% Optimize for CustomCNN (no transfer learning)
config.dataset.inputSize = [224, 224];
config.training.miniBatchSize = 32;
config.training.initialLearnRate = 1e-3;  % Higher LR for training from scratch
config.training.maxEpochs = 75;           % More epochs needed

% Save configuration
config.saveToFile('customcnn_only_config.mat');

% Run
executar_classificacao('customcnn_only_config.mat');
```

---

## Advanced Training Configuration

Fine-tuned training parameters for experienced users.

```matlab
% Create advanced training configuration
config = ClassificationConfig();

% Advanced training parameters
config.training.maxEpochs = 80;
config.training.miniBatchSize = 48;
config.training.initialLearnRate = 2e-4;
config.training.validationPatience = 12;

% Learning rate schedule
config.training.learnRateSchedule = 'piecewise';
config.training.learnRateDropFactor = 0.1;
config.training.learnRateDropPeriod = 20;  % Drop every 20 epochs

% Validation frequency
config.training.validationFrequency = 50;  % Validate every 50 iterations

% Execution environment
config.training.executionEnvironment = 'gpu';  % Force GPU usage

% Advanced model settings
config.models.transferLearning = true;
config.models.freezeEarlyLayers = true;

% All models
config.models.architectures = {'ResNet50', 'EfficientNetB0', 'CustomCNN'};

% Save configuration
config.saveToFile('advanced_training_config.mat');

% Run
executar_classificacao('advanced_training_config.mat');
```

---

## Custom Label Thresholds

Adjust severity class boundaries based on domain expertise.

### Conservative Thresholds (More Severe Classifications)

```matlab
% Create conservative threshold configuration
config = ClassificationConfig();

% Lower thresholds = more images classified as severe
config.labelGeneration.thresholds = [5, 20];  % Default: [10, 30]
% Class 0: <5%, Class 1: 5-20%, Class 2: >20%

% Save configuration
config.saveToFile('conservative_thresholds_config.mat');

% Run
executar_classificacao('conservative_thresholds_config.mat');
```

### Liberal Thresholds (Fewer Severe Classifications)

```matlab
% Create liberal threshold configuration
config = ClassificationConfig();

% Higher thresholds = fewer images classified as severe
config.labelGeneration.thresholds = [15, 40];  % Default: [10, 30]
% Class 0: <15%, Class 1: 15-40%, Class 2: >40%

% Save configuration
config.saveToFile('liberal_thresholds_config.mat');

% Run
executar_classificacao('liberal_thresholds_config.mat');
```

### Three-Way Split (Equal Ranges)

```matlab
% Create equal-range threshold configuration
config = ClassificationConfig();

% Equal 33% ranges
config.labelGeneration.thresholds = [33, 66];
% Class 0: <33%, Class 1: 33-66%, Class 2: >66%

% Save configuration
config.saveToFile('equal_range_thresholds_config.mat');

% Run
executar_classificacao('equal_range_thresholds_config.mat');
```

---

## GPU/CPU Configuration

Control execution environment for training and inference.

### Force GPU Usage

```matlab
% Create GPU-only configuration
config = ClassificationConfig();

% Force GPU usage (will error if GPU not available)
config.training.executionEnvironment = 'gpu';

% Optimize for GPU
config.training.miniBatchSize = 64;  % Larger batch for GPU

% Save configuration
config.saveToFile('gpu_config.mat');

% Verify GPU before running
gpuDevice()

% Run
executar_classificacao('gpu_config.mat');
```

### Force CPU Usage

```matlab
% Create CPU-only configuration
config = ClassificationConfig();

% Force CPU usage
config.training.executionEnvironment = 'cpu';

% Optimize for CPU (smaller batch, fewer epochs)
config.training.miniBatchSize = 8;   % Smaller batch for CPU
config.training.maxEpochs = 20;      % Fewer epochs (CPU is slow)
config.models.architectures = {'CustomCNN'};  % Lightweight model only

% Save configuration
config.saveToFile('cpu_config.mat');

% Run
executar_classificacao('cpu_config.mat');
```

**Warning**: CPU training is 10-50x slower than GPU training.

### Auto-Detect (Recommended)

```matlab
% Create auto-detect configuration
config = ClassificationConfig();

% Auto-detect (use GPU if available, otherwise CPU)
config.training.executionEnvironment = 'auto';

% Save configuration
config.saveToFile('auto_config.mat');

% Run
executar_classificacao('auto_config.mat');
```

---

## Production Deployment Configuration

Optimized for deployment in production environments.

```matlab
% Create production deployment configuration
config = ClassificationConfig();

% Use best-performing model only
config.models.architectures = {'ResNet50'};  % Or whichever performed best

% Standard input size
config.dataset.inputSize = [224, 224];

% Train with full dataset
config.dataset.splitRatios = [0.85, 0.10, 0.05];  % More training data

% Extended training for best performance
config.training.maxEpochs = 100;
config.training.validationPatience = 15;

% Disable augmentation for final model (optional)
% config.dataset.augmentation = false;

% Measure inference time accurately
config.evaluation.measureInferenceTime = true;
config.evaluation.numInferenceSamples = 500;

% Generate all outputs for documentation
config.evaluation.generateROC = true;
config.evaluation.generateConfusionMatrix = true;

% Save configuration
config.saveToFile('production_config.mat');

% Run
executar_classificacao('production_config.mat');

% After training, deploy the best checkpoint:
% output/classification/checkpoints/ResNet50_best.mat
```

---

## Configuration Parameter Reference

### Complete Parameter List

```matlab
config = ClassificationConfig();

% ===== PATHS =====
config.paths.imageDir = 'img/original';
config.paths.maskDir = 'img/masks';
config.paths.outputDir = 'output/classification';
config.paths.checkpointDir = 'output/classification/checkpoints';
config.paths.resultsDir = 'output/classification/results';
config.paths.figuresDir = 'output/classification/figures';
config.paths.latexDir = 'output/classification/latex';
config.paths.logsDir = 'output/classification/logs';

% ===== LABEL GENERATION =====
config.labelGeneration.thresholds = [10, 30];
config.labelGeneration.classNames = {'None/Light', 'Moderate', 'Severe'};
config.labelGeneration.numClasses = 3;
config.labelGeneration.outputCSV = 'output/classification/labels.csv';

% ===== DATASET =====
config.dataset.splitRatios = [0.7, 0.15, 0.15];
config.dataset.inputSize = [224, 224];
config.dataset.augmentation = true;
config.dataset.seed = 42;

% ===== AUGMENTATION =====
config.augmentation.horizontalFlip = true;
config.augmentation.verticalFlip = true;
config.augmentation.rotation = [-15, 15];
config.augmentation.brightness = [-0.2, 0.2];
config.augmentation.contrast = [-0.2, 0.2];

% ===== TRAINING =====
config.training.maxEpochs = 50;
config.training.miniBatchSize = 32;
config.training.initialLearnRate = 1e-4;
config.training.learnRateSchedule = 'piecewise';
config.training.learnRateDropFactor = 0.1;
config.training.learnRateDropPeriod = 10;
config.training.validationFrequency = 50;
config.training.validationPatience = 10;
config.training.shuffle = 'every-epoch';
config.training.executionEnvironment = 'auto';
config.training.verbose = true;
config.training.plots = 'training-progress';

% ===== MODELS =====
config.models.architectures = {'ResNet50', 'EfficientNetB0', 'CustomCNN'};
config.models.transferLearning = true;
config.models.freezeEarlyLayers = true;

% ===== EVALUATION =====
config.evaluation.generateROC = true;
config.evaluation.generateConfusionMatrix = true;
config.evaluation.measureInferenceTime = true;
config.evaluation.numInferenceSamples = 100;
```

### Parameter Descriptions

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `paths.imageDir` | string | `'img/original'` | Directory containing RGB images |
| `paths.maskDir` | string | `'img/masks'` | Directory containing binary masks |
| `paths.outputDir` | string | `'output/classification'` | Base output directory |
| `labelGeneration.thresholds` | array | `[10, 30]` | Percentage thresholds for class boundaries |
| `dataset.splitRatios` | array | `[0.7, 0.15, 0.15]` | Train/validation/test split ratios |
| `dataset.inputSize` | array | `[224, 224]` | Input image dimensions [height, width] |
| `dataset.augmentation` | boolean | `true` | Enable data augmentation |
| `dataset.seed` | integer | `42` | Random seed for reproducibility |
| `training.maxEpochs` | integer | `50` | Maximum training epochs |
| `training.miniBatchSize` | integer | `32` | Batch size for training |
| `training.initialLearnRate` | float | `1e-4` | Initial learning rate |
| `training.validationPatience` | integer | `10` | Early stopping patience (epochs) |
| `training.executionEnvironment` | string | `'auto'` | `'auto'`, `'gpu'`, or `'cpu'` |
| `models.architectures` | cell array | `{'ResNet50', ...}` | Models to train |
| `models.transferLearning` | boolean | `true` | Use pre-trained weights |
| `evaluation.generateROC` | boolean | `true` | Generate ROC curves |
| `evaluation.measureInferenceTime` | boolean | `true` | Measure inference speed |

---

## Saving and Loading Configurations

### Save Configuration

```matlab
% Create configuration
config = ClassificationConfig();

% Customize
config.training.maxEpochs = 75;

% Save to file
config.saveToFile('my_config.mat');
```

### Load Configuration

```matlab
% Load from file
config = ClassificationConfig.loadFromFile('my_config.mat');

% Display loaded configuration
config.displayConfig();

% Use loaded configuration
executar_classificacao('my_config.mat');
```

### Export Configuration to JSON (for documentation)

```matlab
% Create configuration
config = ClassificationConfig();

% Get configuration as struct
configStruct = config.toStruct();

% Save as JSON (requires MATLAB R2016b+)
jsonStr = jsonencode(configStruct);
fid = fopen('config.json', 'w');
fprintf(fid, '%s', jsonStr);
fclose(fid);
```

---

## Tips for Configuration

1. **Start with defaults**: The default configuration works well for most cases
2. **Test quickly first**: Use quick testing configuration to verify setup
3. **Save configurations**: Always save custom configurations for reproducibility
4. **Document changes**: Add comments explaining why you changed parameters
5. **Use descriptive names**: Name configuration files clearly (e.g., `high_accuracy_config.mat`)
6. **Version control**: Keep configuration files in version control
7. **Validate before running**: Use `config.displayConfig()` to review settings
8. **Monitor training**: Watch training curves to adjust learning rate and epochs
9. **Compare configurations**: Run multiple configurations to find optimal settings
10. **Document results**: Note which configuration produced best results

---

## Common Configuration Patterns

### Pattern 1: Iterative Refinement

```matlab
% Start with quick test
config = ClassificationConfig();
config.training.maxEpochs = 10;
config.models.architectures = {'CustomCNN'};
executar_classificacao();

% If results look good, train longer
config.training.maxEpochs = 50;
executar_classificacao();

% If still good, try better model
config.models.architectures = {'ResNet50'};
executar_classificacao();
```

### Pattern 2: Model Comparison

```matlab
% Train all models with same settings
config = ClassificationConfig();
config.training.maxEpochs = 50;
config.models.architectures = {'ResNet50', 'EfficientNetB0', 'CustomCNN'};
executar_classificacao();

% Review results and select best model
% Then retrain best model with more epochs
```

### Pattern 3: Hyperparameter Search

```matlab
% Try different learning rates
for lr = [1e-5, 5e-5, 1e-4, 5e-4]
    config = ClassificationConfig();
    config.training.initialLearnRate = lr;
    config.saveToFile(sprintf('config_lr_%.0e.mat', lr));
    executar_classificacao(sprintf('config_lr_%.0e.mat', lr));
end

% Compare results and select best learning rate
```

---

## Troubleshooting Configuration Issues

### Issue: Configuration file not found

```matlab
% Check if file exists
if exist('my_config.mat', 'file')
    executar_classificacao('my_config.mat');
else
    error('Configuration file not found');
end
```

### Issue: Invalid parameter values

```matlab
% Validate configuration before use
config = ClassificationConfig();
config.training.maxEpochs = -10;  % Invalid!

% ClassificationConfig validates on creation
% Will show warning or error for invalid values
```

### Issue: Path not found

```matlab
% Check if paths exist before running
config = ClassificationConfig();
if ~exist(config.paths.imageDir, 'dir')
    error('Image directory not found: %s', config.paths.imageDir);
end
```

---

## See Also

- **Main README**: `src/classification/README.md`
- **Quick Start Guide**: `src/classification/QUICK_START.md`
- **Main Execution Guide**: `src/classification/MAIN_EXECUTION_GUIDE.md`
- **ClassificationConfig Documentation**: `src/classification/utils/ClassificationConfig.m`

---

## Questions?

For more information:
1. Review the requirements: `.kiro/specs/corrosion-classification-system/requirements.md`
2. Check the design document: `.kiro/specs/corrosion-classification-system/design.md`
3. Run validation: `validate_executar_classificacao()`
4. Check logs: `output/classification/logs/`
