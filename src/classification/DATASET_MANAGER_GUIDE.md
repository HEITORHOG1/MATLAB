# DatasetManager Implementation Guide

## Overview

The `DatasetManager` class is responsible for loading images with their corresponding labels, performing stratified train/val/test splits, computing dataset statistics, and configuring data augmentation pipelines for the corrosion classification system.

## Requirements Addressed

- **2.1**: Load all images from the existing segmentation dataset directory structure
- **2.2**: Split the dataset into 70% training, 15% validation, and 15% test sets with stratified sampling
- **2.3**: Ensure each severity class is proportionally represented in all splits
- **2.4**: Validate that each image has a corresponding label before including it in the dataset
- **7.3**: Reuse existing infrastructure and maintain code consistency

## Class Structure

### Properties

#### Private Properties
- `imageDir`: Directory containing RGB images
- `labelCSV`: Path to CSV file with labels
- `splitRatios`: Array [train, val, test] ratios (default: [0.7, 0.15, 0.15])
- `augmentationConfig`: Configuration struct for data augmentation
- `errorHandler`: ErrorHandler instance for logging
- `allImages`: Cell array of image filenames
- `allLabels`: Array of severity class labels
- `allPercentages`: Array of corroded percentages

#### Constants
- `DEFAULT_SPLIT_RATIOS`: [0.7, 0.15, 0.15]
- `DEFAULT_INPUT_SIZE`: [224, 224]
- `DEFAULT_AUGMENTATION`: Default augmentation configuration

### Public Methods

#### Constructor
```matlab
manager = DatasetManager(imageDir, labelCSV, config)
```

**Parameters:**
- `imageDir` (string): Directory containing RGB images
- `labelCSV` (string): Path to CSV file with labels
- `config` (struct, optional): Configuration with fields:
  - `splitRatios`: [train, val, test] ratios
  - `augmentation`: Augmentation configuration
  - `errorHandler`: ErrorHandler instance

**Example:**
```matlab
config = struct();
config.splitRatios = [0.7, 0.15, 0.15];
config.augmentation = struct(...
    'enabled', true, ...
    'horizontalFlip', true, ...
    'verticalFlip', true, ...
    'rotationRange', [-15, 15]);

manager = DatasetManager('img/original', 'output/classification/labels.csv', config);
```

#### prepareDatasets
```matlab
[trainDS, valDS, testDS] = manager.prepareDatasets(inputSize)
```

Creates stratified train/val/test splits with proper class distribution.

**Parameters:**
- `inputSize` ([height, width], optional): Image size for resizing (default: [224, 224])

**Returns:**
- `trainDS`: Training imageDatastore with labels
- `valDS`: Validation imageDatastore with labels
- `testDS`: Test imageDatastore with labels

**Example:**
```matlab
[trainDS, valDS, testDS] = manager.prepareDatasets([224, 224]);
fprintf('Train: %d, Val: %d, Test: %d\n', ...
    trainDS.numpartitions, valDS.numpartitions, testDS.numpartitions);
```

#### getDatasetStatistics
```matlab
stats = manager.getDatasetStatistics()
```

Computes comprehensive dataset statistics including class distribution and balance analysis.

**Returns:**
- `stats` (struct): Statistics with fields:
  - `totalSamples`: Total number of samples
  - `uniqueClasses`: Array of unique class labels
  - `numClasses`: Number of classes
  - `classDistribution`: Count per class
  - `classPercentages`: Percentage per class
  - `classNames`: Cell array of class names
  - `percentageRange`: [min, max] corroded percentages
  - `percentageMean`: Mean corroded percentage
  - `percentageStd`: Standard deviation
  - `percentageMedian`: Median corroded percentage
  - `imbalanceRatio`: Ratio of largest to smallest class
  - `isImbalanced`: Boolean indicating if ratio > 3.0

**Example:**
```matlab
stats = manager.getDatasetStatistics();
fprintf('Total samples: %d\n', stats.totalSamples);
fprintf('Imbalance ratio: %.2f:1\n', stats.imbalanceRatio);
if stats.isImbalanced
    fprintf('WARNING: Dataset is imbalanced!\n');
end
```

#### applyAugmentation
```matlab
augDS = manager.applyAugmentation(datastore)
```

Configures data augmentation for training datastore.

**Parameters:**
- `datastore`: imageDatastore to augment

**Returns:**
- `augDS`: augmentedImageDatastore with configured augmentation

**Example:**
```matlab
[trainDS, ~, ~] = manager.prepareDatasets([224, 224]);
augTrainDS = manager.applyAugmentation(trainDS);
```

## Usage Examples

### Basic Usage

```matlab
% Initialize DatasetManager
manager = DatasetManager('img/original', 'output/classification/labels.csv');

% Get dataset statistics
stats = manager.getDatasetStatistics();

% Prepare datasets
[trainDS, valDS, testDS] = manager.prepareDatasets([224, 224]);

% Apply augmentation to training set
augTrainDS = manager.applyAugmentation(trainDS);
```

### Custom Configuration

```matlab
% Create custom configuration
config = struct();
config.splitRatios = [0.8, 0.1, 0.1];  % 80/10/10 split
config.augmentation = struct(...
    'enabled', true, ...
    'horizontalFlip', true, ...
    'verticalFlip', false, ...
    'rotationRange', [-10, 10], ...
    'brightnessRange', [0.9, 1.1], ...
    'contrastRange', [0.9, 1.1]);

% Initialize with custom config
manager = DatasetManager('img/original', 'output/classification/labels.csv', config);

% Prepare datasets
[trainDS, valDS, testDS] = manager.prepareDatasets([256, 256]);
```

### Disable Augmentation

```matlab
% Create config with augmentation disabled
config = struct();
config.augmentation = struct('enabled', false);

manager = DatasetManager('img/original', 'output/classification/labels.csv', config);

[trainDS, ~, ~] = manager.prepareDatasets([224, 224]);

% This will return the original datastore
augTrainDS = manager.applyAugmentation(trainDS);
```

## Data Validation

The DatasetManager performs several validation checks:

1. **Directory Validation**: Ensures image directory exists
2. **CSV Validation**: Ensures label CSV file exists and has required columns
3. **Image Validation**: Checks that all images referenced in CSV exist
4. **Label Validation**: Ensures all images have corresponding labels
5. **Split Ratio Validation**: Ensures split ratios sum to 1.0
6. **Stratification Verification**: Verifies class proportions are maintained

## Stratified Splitting

The stratified split ensures that each class is proportionally represented in all splits:

1. For each class, samples are randomly shuffled
2. Samples are divided according to split ratios
3. Class proportions are verified to be within 5% tolerance
4. Warnings are logged if deviation exceeds tolerance

## Class Imbalance Detection

The system automatically detects class imbalance:

- **Imbalance Ratio**: Calculated as max_count / min_count
- **Threshold**: Ratio > 3.0 is considered imbalanced
- **Warning**: Logged if imbalance detected
- **Recommendation**: Use class weights or resampling

## Error Handling

All operations are logged using the ErrorHandler:

- **Info**: Normal operations and progress
- **Warning**: Missing files, imbalance, stratification issues
- **Error**: Critical failures (invalid paths, CSV errors)

## Testing

Run the validation script to test the implementation:

```matlab
validate_dataset_manager
```

Or run unit tests directly:

```matlab
addpath('src/utils');
addpath('src/classification/core');
addpath('tests/unit');
test_DatasetManager();
```

## Integration with Training Pipeline

The DatasetManager integrates seamlessly with the training pipeline:

```matlab
% 1. Initialize manager
manager = DatasetManager('img/original', 'output/classification/labels.csv');

% 2. Prepare datasets
[trainDS, valDS, testDS] = manager.prepareDatasets([224, 224]);

% 3. Apply augmentation to training
augTrainDS = manager.applyAugmentation(trainDS);

% 4. Train model (next task)
% trainingEngine = TrainingEngine(model, config);
% trainedNet = trainingEngine.train(augTrainDS, valDS);

% 5. Evaluate on test set (future task)
% evaluationEngine = EvaluationEngine(trainedNet, testDS);
% metrics = evaluationEngine.computeMetrics();
```

## File Locations

- **Class**: `src/classification/core/DatasetManager.m`
- **Tests**: `tests/unit/test_DatasetManager.m`
- **Validation**: `validate_dataset_manager.m`
- **Documentation**: `src/classification/DATASET_MANAGER_GUIDE.md`

## Dependencies

- MATLAB Deep Learning Toolbox
- MATLAB Image Processing Toolbox
- `ErrorHandler` class (src/utils/ErrorHandler.m)
- Label CSV file (generated by LabelGenerator)

## Next Steps

After validating the DatasetManager:

1. Implement ModelFactory (Task 4.1)
2. Implement TrainingEngine (Task 5.1)
3. Integrate all components in main execution script

## Troubleshooting

### Issue: "Image directory not found"
**Solution**: Ensure the image directory path is correct and exists

### Issue: "Label CSV file not found"
**Solution**: Run the label generation script first to create the CSV

### Issue: "CSV must contain columns: filename, corroded_percentage, severity_class"
**Solution**: Ensure the CSV was generated by LabelGenerator with correct format

### Issue: "Split ratios must sum to 1.0"
**Solution**: Ensure split ratios are valid, e.g., [0.7, 0.15, 0.15]

### Issue: "No valid image-label pairs found"
**Solution**: Check that images exist in the specified directory and match CSV filenames

## Performance Considerations

- **Memory**: Datastores use lazy loading, so memory usage is minimal
- **Speed**: Stratified splitting is O(n log n) due to shuffling
- **Augmentation**: Applied on-the-fly during training, no preprocessing needed

## Future Enhancements

- Support for custom augmentation pipelines
- Advanced resampling strategies for imbalanced datasets
- Cross-validation support
- Multi-fold splitting
- Data caching for faster loading
