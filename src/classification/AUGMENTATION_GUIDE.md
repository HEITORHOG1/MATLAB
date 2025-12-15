# Data Augmentation Pipeline Guide

## Quick Start

### Basic Usage

```matlab
% 1. Configure augmentation
config = struct();
config.augmentation = struct(...
    'enabled', true, ...
    'horizontalFlip', true, ...
    'verticalFlip', true, ...
    'rotationRange', [-15, 15], ...
    'brightnessRange', [0.8, 1.2], ...
    'contrastRange', [0.8, 1.2]);

% 2. Create DatasetManager
manager = DatasetManager('img/original', 'labels.csv', config);

% 3. Prepare datasets
[trainDS, valDS, testDS] = manager.prepareDatasets([224, 224]);

% 4. Apply augmentation (typically only to training data)
augTrainDS = manager.applyAugmentation(trainDS, [224, 224]);
```

## Configuration Options

### Enable/Disable Augmentation

```matlab
% Enable augmentation
config.augmentation.enabled = true;

% Disable augmentation (returns original datastore)
config.augmentation.enabled = false;
```

### Geometric Transformations

```matlab
% Horizontal flip (50% probability)
config.augmentation.horizontalFlip = true;

% Vertical flip (50% probability)
config.augmentation.verticalFlip = true;

% Rotation range in degrees
config.augmentation.rotationRange = [-15, 15];  % -15° to +15°
```

### Color Transformations

```matlab
% Brightness adjustment (multiplier range)
config.augmentation.brightnessRange = [0.8, 1.2];  % ±20%

% Contrast adjustment (multiplier range)
config.augmentation.contrastRange = [0.8, 1.2];    % ±20%
```

## Common Scenarios

### Scenario 1: Training with Augmentation

```matlab
% Apply augmentation to training data only
augTrainDS = manager.applyAugmentation(trainDS, [224, 224]);

% No augmentation for validation/test
% (use original datastores)

% Train model
options = trainingOptions('adam', ...
    'MaxEpochs', 50, ...
    'ValidationData', valDS);

net = trainNetwork(augTrainDS, layers, options);
```

### Scenario 2: Light Augmentation

```matlab
% Only geometric transformations, no color changes
config.augmentation = struct(...
    'enabled', true, ...
    'horizontalFlip', true, ...
    'verticalFlip', false, ...
    'rotationRange', [-10, 10], ...
    'brightnessRange', [1.0, 1.0], ...  % No brightness change
    'contrastRange', [1.0, 1.0]);       % No contrast change
```

### Scenario 3: Aggressive Augmentation

```matlab
% More aggressive augmentation for small datasets
config.augmentation = struct(...
    'enabled', true, ...
    'horizontalFlip', true, ...
    'verticalFlip', true, ...
    'rotationRange', [-30, 30], ...     % Wider rotation
    'brightnessRange', [0.6, 1.4], ...  % ±40% brightness
    'contrastRange', [0.6, 1.4]);       % ±40% contrast
```

### Scenario 4: No Augmentation

```matlab
% Disable augmentation for baseline comparison
config.augmentation.enabled = false;

% Or simply don't call applyAugmentation
% trainDS can be used directly
```

## Augmentation Effects

### Horizontal Flip
- Mirrors image left-to-right
- Useful for objects with no preferred orientation
- Applied randomly with 50% probability

### Vertical Flip
- Mirrors image top-to-bottom
- Less common for natural images
- Applied randomly with 50% probability

### Rotation
- Rotates image by random angle within range
- Helps model learn rotation invariance
- Range: typically [-15°, +15°] for corrosion images

### Brightness Adjustment
- Multiplies all pixel values by random factor
- Simulates different lighting conditions
- Range [0.8, 1.2] = ±20% brightness change

### Contrast Adjustment
- Scales pixel deviations from mean
- Simulates different camera settings
- Range [0.8, 1.2] = ±20% contrast change

## Validation

### Visual Inspection

```matlab
% Run validation script to see augmentation effects
validate_augmentation

% Check output figure:
% output/classification/validation/augmentation_comparison.png
```

### Programmatic Validation

```matlab
% Read augmented samples
reset(augTrainDS);
for i = 1:5
    data = read(augTrainDS);
    img = data{1};
    label = data{2};
    
    % Display
    figure;
    imshow(img);
    title(sprintf('Augmented Sample %d - Label: %s', i, char(label)));
end
```

## Best Practices

### 1. Apply to Training Data Only
```matlab
% ✓ Correct
augTrainDS = manager.applyAugmentation(trainDS, [224, 224]);
% Use valDS and testDS without augmentation

% ✗ Incorrect
augValDS = manager.applyAugmentation(valDS, [224, 224]);
```

### 2. Match Input Size
```matlab
% Ensure input size matches model requirements
inputSize = [224, 224];  % For ResNet50, EfficientNet-B0
[trainDS, valDS, testDS] = manager.prepareDatasets(inputSize);
augTrainDS = manager.applyAugmentation(trainDS, inputSize);
```

### 3. Consistent Configuration
```matlab
% Use same config for all experiments in a comparison
config = ClassificationConfig.getDefaultConfig();
% Modify only specific parameters
config.augmentation.rotationRange = [-20, 20];
```

### 4. Document Augmentation Settings
```matlab
% Log augmentation configuration
fprintf('Augmentation settings:\n');
fprintf('  Horizontal flip: %d\n', config.augmentation.horizontalFlip);
fprintf('  Vertical flip: %d\n', config.augmentation.verticalFlip);
fprintf('  Rotation: [%.1f, %.1f]\n', config.augmentation.rotationRange);
fprintf('  Brightness: [%.2f, %.2f]\n', config.augmentation.brightnessRange);
fprintf('  Contrast: [%.2f, %.2f]\n', config.augmentation.contrastRange);
```

## Troubleshooting

### Issue: Out of Memory

**Solution**: Reduce batch size or disable some augmentations
```matlab
% Reduce augmentation complexity
config.augmentation.verticalFlip = false;
config.augmentation.rotationRange = [0, 0];  % Disable rotation
```

### Issue: Training Too Slow

**Solution**: Disable color augmentation (most expensive)
```matlab
config.augmentation.brightnessRange = [1.0, 1.0];
config.augmentation.contrastRange = [1.0, 1.0];
```

### Issue: Model Not Learning

**Solution**: Reduce augmentation aggressiveness
```matlab
% Use milder augmentation
config.augmentation.rotationRange = [-10, 10];
config.augmentation.brightnessRange = [0.9, 1.1];
config.augmentation.contrastRange = [0.9, 1.1];
```

### Issue: Augmented Images Look Wrong

**Solution**: Check configuration values
```matlab
% Verify ranges are valid
assert(config.augmentation.brightnessRange(1) > 0);
assert(config.augmentation.brightnessRange(2) > 0);
assert(config.augmentation.contrastRange(1) > 0);
assert(config.augmentation.contrastRange(2) > 0);
```

## Performance Tips

### 1. Use Parallel Workers
```matlab
options = trainingOptions('adam', ...
    'ExecutionEnvironment', 'gpu', ...
    'WorkerLoad', 0.8);  % Use 80% of available workers
```

### 2. Prefetch Data
```matlab
% MATLAB automatically prefetches data
% Ensure sufficient RAM for prefetching
```

### 3. Profile Augmentation
```matlab
% Time augmentation pipeline
tic;
for i = 1:100
    data = read(augTrainDS);
end
avgTime = toc / 100;
fprintf('Average augmentation time: %.2f ms\n', avgTime * 1000);
```

## Advanced Usage

### Custom Augmentation Function

```matlab
% Add custom augmentation
customAugment = @(data) myCustomAugmentation(data);
augTrainDS = transform(augTrainDS, customAugment);
```

### Conditional Augmentation

```matlab
% Apply different augmentation based on class
function data = classSpecificAugmentation(data)
    img = data{1};
    label = data{2};
    
    if label == categorical(0)
        % Light augmentation for class 0
        img = augmentLight(img);
    else
        % Aggressive augmentation for other classes
        img = augmentAggressive(img);
    end
    
    data = {img, label};
end
```

## References

- MATLAB Documentation: [Image Data Augmentation](https://www.mathworks.com/help/deeplearning/ug/preprocess-images-for-deep-learning.html)
- Design Document: `.kiro/specs/corrosion-classification-system/design.md`
- Requirements: `.kiro/specs/corrosion-classification-system/requirements.md` (Requirement 4.2)
- Implementation: `src/classification/TASK_3_2_IMPLEMENTATION.md`

## Summary

The data augmentation pipeline provides flexible, configurable augmentation for training corrosion classification models. Key features:

- ✅ Geometric transformations (flip, rotation)
- ✅ Color transformations (brightness, contrast)
- ✅ Easy enable/disable
- ✅ Compatible with MATLAB training pipeline
- ✅ Efficient on-the-fly augmentation
- ✅ Preserves labels automatically

For questions or issues, refer to the implementation documentation or run the validation script.
