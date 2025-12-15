# Dataset Validation Guide

## Overview

The DatasetValidator class provides comprehensive validation utilities for the classification dataset. It ensures data integrity before training by checking file existence, image properties, and class balance.

## Quick Start

```matlab
% Initialize validator
errorHandler = ErrorHandler.getInstance();
validator = DatasetValidator(errorHandler);

% Validate dataset
imageDir = 'img/original';
labelCSV = 'output/classification/labels.csv';
[isValid, report] = validator.validateDataset(imageDir, labelCSV);

% Generate detailed report
reportFile = 'output/classification/validation/report.txt';
validator.generateReport(report, reportFile);

% Check if dataset is ready
if isValid
    fprintf('Dataset is valid and ready for training\n');
else
    fprintf('Dataset has issues. Review report for details.\n');
end
```

## Validation Checks

### 1. File Existence
- Verifies image directory exists
- Verifies label CSV file exists
- Checks each image file is present

### 2. File Readability
- Attempts to read each image
- Reports corrupted or unreadable files
- Logs specific error messages

### 3. Image Dimensions
- Validates minimum size (50x50 pixels)
- Reports images that are too small
- Ensures compatibility with model input

### 4. Image Channels
- Validates RGB format (3 channels)
- Reports grayscale or other formats
- Ensures model compatibility

### 5. Class Balance
- Computes class distribution
- Calculates imbalance ratio
- Warns if ratio > 3:1
- Suggests remediation strategies

## Validation Report Structure

```matlab
report = struct(
    'timestamp',          % When validation was performed
    'imageDir',           % Image directory path
    'labelCSV',           % Label CSV path
    'totalLabels',        % Total number of labels
    'validImages',        % Number of valid images
    'missingFiles',       % Cell array of missing filenames
    'unreadableFiles',    % Cell array of unreadable files
    'invalidDimensions',  % Cell array of small images
    'invalidChannels',    % Cell array of non-RGB images
    'classDistribution',  % Array of counts per class
    'uniqueClasses',      % Array of class labels
    'imbalanceRatio',     % Max/min class ratio
    'errors',             % Cell array of error messages
    'warnings'            % Cell array of warning messages
);
```

## Usage Examples

### Example 1: Basic Validation

```matlab
validator = DatasetValidator();
[isValid, report] = validator.validateDataset('img/original', 'labels.csv');

if isValid
    fprintf('All checks passed!\n');
else
    fprintf('Found %d errors\n', length(report.errors));
end
```

### Example 2: Detailed Report

```matlab
validator = DatasetValidator();
[isValid, report] = validator.validateDataset('img/original', 'labels.csv');

% Generate report to console and file
validator.generateReport(report, 'validation_report.txt');

% Access specific information
fprintf('Valid images: %d/%d\n', report.validImages, report.totalLabels);
fprintf('Imbalance ratio: %.2f:1\n', report.imbalanceRatio);
```

### Example 3: Check Specific Issues

```matlab
validator = DatasetValidator();
[isValid, report] = validator.validateDataset('img/original', 'labels.csv');

% Check for missing files
if ~isempty(report.missingFiles)
    fprintf('Missing files:\n');
    for i = 1:length(report.missingFiles)
        fprintf('  - %s\n', report.missingFiles{i});
    end
end

% Check for class imbalance
if report.imbalanceRatio > 3.0
    fprintf('Dataset is imbalanced: %.2f:1\n', report.imbalanceRatio);
    fprintf('Consider using class weights or resampling\n');
end
```

### Example 4: Integration with DatasetManager

```matlab
% Validate before creating DatasetManager
validator = DatasetValidator();
[isValid, report] = validator.validateDataset('img/original', 'labels.csv');

if ~isValid
    error('Dataset validation failed. Fix issues before proceeding.');
end

% Create DatasetManager if validation passed
config = struct();
manager = DatasetManager('img/original', 'labels.csv', config);
[trainDS, valDS, testDS] = manager.prepareDatasets([224, 224]);
```

## Validation Thresholds

### Configurable Constants
```matlab
EXPECTED_CHANNELS = 3;      % RGB images
MIN_IMAGE_SIZE = 50;        % Minimum dimension in pixels
IMBALANCE_THRESHOLD = 3.0;  % Ratio threshold for warning
```

These can be modified in the DatasetValidator class if needed.

## Common Issues and Solutions

### Issue 1: Missing Files
**Problem**: Some images in CSV are not in directory
**Solution**: 
- Check file paths in CSV
- Verify image directory is correct
- Re-run label generation if needed

### Issue 2: Unreadable Files
**Problem**: Some images cannot be read
**Solution**:
- Check file corruption
- Verify file format (jpg, png)
- Re-download or regenerate images

### Issue 3: Invalid Dimensions
**Problem**: Images smaller than 50x50
**Solution**:
- Remove small images from dataset
- Resize images if appropriate
- Update minimum size threshold if needed

### Issue 4: Invalid Channels
**Problem**: Grayscale or other non-RGB images
**Solution**:
- Convert to RGB format
- Remove non-RGB images
- Update preprocessing pipeline

### Issue 5: Class Imbalance
**Problem**: Imbalance ratio > 3:1
**Solution**:
- Use class weights in training
- Apply oversampling to minority class
- Apply undersampling to majority class
- Use data augmentation strategically

## Integration Points

### With ErrorHandler
```matlab
errorHandler = ErrorHandler.getInstance();
validator = DatasetValidator(errorHandler);
% All validation messages logged through ErrorHandler
```

### With DatasetManager
```matlab
% Validate before dataset preparation
validator = DatasetValidator();
[isValid, ~] = validator.validateDataset(imageDir, labelCSV);

if isValid
    manager = DatasetManager(imageDir, labelCSV, config);
end
```

### With Training Pipeline
```matlab
% Validate at start of training script
validator = DatasetValidator();
[isValid, report] = validator.validateDataset(imageDir, labelCSV);

if ~isValid
    validator.generateReport(report, 'validation_errors.txt');
    error('Dataset validation failed. See validation_errors.txt');
end

% Proceed with training
% ...
```

## Best Practices

1. **Always validate before training**
   - Run validation at the start of training scripts
   - Save validation reports for documentation
   - Fix all errors before proceeding

2. **Review warnings carefully**
   - Class imbalance can affect model performance
   - Small images may lose quality when resized
   - Missing files indicate data pipeline issues

3. **Keep validation reports**
   - Document dataset state at training time
   - Track changes across experiments
   - Include in research documentation

4. **Automate validation**
   - Include in automated pipelines
   - Run after data collection
   - Run before each training session

5. **Monitor class balance**
   - Track imbalance ratio over time
   - Adjust data collection if needed
   - Use appropriate training strategies

## Output Files

### Validation Report
- **Location**: `output/classification/validation/`
- **Format**: Plain text
- **Contents**: 
  - Configuration details
  - Validation results
  - Class distribution
  - Error and warning lists
  - Overall status

### Example Report Structure
```
=== Dataset Validation Report ===
Generated: 23-Oct-2025 14:30:00

--- Configuration ---
Image Directory: img/original
Label CSV: output/classification/labels.csv

--- Validation Results ---
Total Labels: 150
Valid Images: 148
Missing Files: 2
Unreadable Files: 0
Invalid Dimensions: 0
Invalid Channels: 0

--- Class Distribution ---
Class 0 (None/Light): 50 samples (33.3%)
Class 1 (Moderate): 48 samples (32.0%)
Class 2 (Severe): 52 samples (34.7%)
Imbalance Ratio: 1.08:1

--- Overall Status ---
Status: PASSED
Dataset is valid and ready for training
```

## Performance

- **Speed**: Fast validation (~1-2 seconds for 150 images)
- **Memory**: Low memory footprint (processes one image at a time)
- **Scalability**: Handles thousands of images efficiently

## Requirements Addressed

- **Requirement 2.5**: Dataset validation and statistics
  - ✓ Image file existence validation
  - ✓ Image readability validation
  - ✓ Image dimension validation
  - ✓ Image channel validation
  - ✓ Class imbalance detection
  - ✓ Statistics report generation

## Related Documentation

- [Dataset Manager Guide](DATASET_MANAGER_GUIDE.md)
- [Label Generation Guide](LABEL_GENERATION_GUIDE.md)
- [Classification System README](README.md)

## Support

For issues or questions:
1. Check validation report for specific errors
2. Review this guide for solutions
3. Check ErrorHandler logs for detailed messages
4. Refer to requirements document for specifications
