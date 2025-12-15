# Label Generation Guide

## Overview

The `gerar_labels_classificacao.m` script converts binary segmentation masks into categorical severity labels for the corrosion classification system.

## Quick Start

### Basic Usage

```matlab
% Run with default configuration
gerar_labels_classificacao();
```

This will:
1. Load masks from `img/masks/`
2. Generate labels using thresholds [10%, 30%]
3. Save CSV to `output/classification/labels.csv`
4. Create statistics and reports

### Custom Configuration

```matlab
% Create custom configuration
config = ClassificationConfig();
config.paths.maskDir = 'path/to/masks';
config.labelGeneration.thresholds = [15, 35];  % Custom thresholds
config.saveToFile('my_config.mat');

% Run with custom config
gerar_labels_classificacao('my_config.mat');
```

## Output Files

### 1. Labels CSV
**Location**: `output/classification/labels.csv`

**Format**:
```csv
filename,corroded_percentage,severity_class
img001.jpg,5.23,0
img002.jpg,18.47,1
img003.jpg,42.91,2
```

**Columns**:
- `filename`: Image filename (string)
- `corroded_percentage`: Percentage of corroded pixels (0-100)
- `severity_class`: Integer class (0=None/Light, 1=Moderate, 2=Severe)

### 2. Statistics MAT File
**Location**: `output/classification/results/label_generation_stats.mat`

**Contents**:
- `stats`: Statistics struct with processing summary
- `labels`: Table with all generated labels
- `config`: Configuration object used

**Usage**:
```matlab
load('output/classification/results/label_generation_stats.mat');
disp(stats.classDistribution);
```

### 3. Text Report
**Location**: `output/classification/results/label_generation_report.txt`

Human-readable report with:
- Configuration summary
- Processing statistics
- Class distribution
- Sample data

### 4. Log File
**Location**: `output/classification/logs/label_generation_YYYYMMDD_HHMMSS.txt`

Detailed execution log with timestamps.

## Configuration Options

### Thresholds

The thresholds define class boundaries:

```matlab
config.labelGeneration.thresholds = [10, 30];
```

- `< 10%` → Class 0 (None/Light)
- `10% - 30%` → Class 1 (Moderate)
- `> 30%` → Class 2 (Severe)

### Paths

```matlab
config.paths.maskDir = 'img/masks';              % Input masks
config.paths.outputDir = 'output/classification'; % Output directory
config.labelGeneration.outputCSV = 'output/classification/labels.csv';
```

## Class Distribution

The script automatically analyzes class distribution and warns about imbalance:

```
--- Class Distribution ---
Class 0 (None/Light): 45 samples (33.3%)
Class 1 (Moderate): 38 samples (28.1%)
Class 2 (Severe): 52 samples (38.5%)

*** WARNING: Class imbalance detected! ***
Imbalance ratio: 1.4:1
```

If imbalance ratio > 3:1, consider:
- Stratified sampling during dataset split
- Class weights during training
- Data augmentation for minority classes

## Error Handling

### Common Issues

**1. Mask directory not found**
```
Error: Mask directory not found: img/masks
```
**Solution**: Check that the mask directory exists and path is correct.

**2. No mask files found**
```
Error: No mask files found in directory: img/masks
```
**Solution**: Ensure directory contains .png, .jpg, or .bmp files.

**3. Failed to process specific files**
```
Failed files:
  - corrupted_mask.jpg
```
**Solution**: Check log file for details. Files may be corrupted or invalid format.

## Statistics Explained

### Processing Summary
- **Total files**: Number of mask files found
- **Successfully processed**: Files converted to labels
- **Failed**: Files that couldn't be processed
- **Success rate**: Percentage of successful conversions

### Corroded Percentage Statistics
- **Range**: [min%, max%] - Spread of corroded percentages
- **Mean**: Average corroded percentage
- **Standard Deviation**: Variability in corroded percentages

High standard deviation indicates diverse corrosion levels (good for training).

## Integration with Pipeline

The generated CSV is used by subsequent pipeline stages:

```matlab
% 1. Generate labels
gerar_labels_classificacao();

% 2. Prepare dataset (next task)
datasetManager = DatasetManager('img/original', 'output/classification/labels.csv');
[trainDS, valDS, testDS] = datasetManager.prepareDatasets();

% 3. Train models
% ... (future tasks)
```

## Troubleshooting

### Check Output Files

```matlab
% Verify CSV was created
if exist('output/classification/labels.csv', 'file')
    labels = readtable('output/classification/labels.csv');
    fprintf('Generated %d labels\n', height(labels));
    disp(labels(1:5, :));  % Show first 5
else
    error('CSV file not created');
end
```

### Validate Label Distribution

```matlab
% Load and analyze labels
labels = readtable('output/classification/labels.csv');

% Count per class
class0 = sum(labels.severity_class == 0);
class1 = sum(labels.severity_class == 1);
class2 = sum(labels.severity_class == 2);

fprintf('Class 0: %d (%.1f%%)\n', class0, 100*class0/height(labels));
fprintf('Class 1: %d (%.1f%%)\n', class1, 100*class1/height(labels));
fprintf('Class 2: %d (%.1f%%)\n', class2, 100*class2/height(labels));
```

### Check for Invalid Values

```matlab
labels = readtable('output/classification/labels.csv');

% Check for NaN or invalid percentages
assert(all(~isnan(labels.corroded_percentage)), 'NaN values found');
assert(all(labels.corroded_percentage >= 0 & labels.corroded_percentage <= 100), ...
    'Invalid percentages');

% Check for invalid classes
assert(all(ismember(labels.severity_class, [0, 1, 2])), 'Invalid class values');

fprintf('All labels are valid!\n');
```

## Performance

Typical performance on standard hardware:
- **Processing speed**: ~50-100 masks/second
- **Memory usage**: < 500 MB
- **Disk space**: CSV ~10 KB per 1000 images

For large datasets (>10,000 images):
- Processing time: ~2-5 minutes
- Consider batch processing if memory limited

## Best Practices

1. **Always review the summary report** after generation
2. **Check for class imbalance** before training
3. **Verify a sample of labels** manually for correctness
4. **Keep log files** for reproducibility
5. **Use version control** for configuration files

## Example Workflow

```matlab
% 1. Setup
addpath('src/classification/core');
addpath('src/classification/utils');
addpath('src/utils');

% 2. Generate labels
fprintf('Generating labels...\n');
gerar_labels_classificacao();

% 3. Review results
labels = readtable('output/classification/labels.csv');
fprintf('\nGenerated %d labels\n', height(labels));

% 4. Load statistics
load('output/classification/results/label_generation_stats.mat');
fprintf('Class distribution: [%d, %d, %d]\n', stats.classDistribution);

% 5. Check for issues
if max(stats.classDistribution) / min(stats.classDistribution) > 3
    warning('Significant class imbalance detected!');
end

fprintf('\nLabel generation complete!\n');
```

## Support

For issues or questions:
1. Check the log file in `output/classification/logs/`
2. Review the text report in `output/classification/results/`
3. Verify configuration with `config.displayConfig()`
4. Consult the main README in `src/classification/`
