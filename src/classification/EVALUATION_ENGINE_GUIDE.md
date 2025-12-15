# EvaluationEngine Guide

## Overview

The `EvaluationEngine` class provides comprehensive evaluation capabilities for classification models, including metrics computation, confusion matrix generation, ROC curve analysis, and inference speed benchmarking.

## Features

- **Comprehensive Metrics**: Accuracy, precision, recall, F1-score (per-class, macro, and weighted)
- **Confusion Matrix**: Generation and normalization with visualization support
- **ROC Analysis**: One-vs-rest ROC curves with AUC scores for multi-class classification
- **Performance Benchmarking**: Inference time and throughput measurement with GPU memory tracking
- **Automated Reporting**: Complete evaluation reports in both MAT and text formats

## Requirements Addressed

- **5.1**: Overall and per-class metrics computation
- **5.2**: Confusion matrix generation
- **5.3**: ROC curves and AUC scores
- **5.4**: Inference speed measurement
- **5.5**: Comprehensive evaluation reports

## Quick Start

### Basic Usage

```matlab
% Load trained model
checkpoint = load('output/classification/checkpoints/resnet50_best.mat');
net = checkpoint.net;

% Create test datastore
testDS = imageDatastore('path/to/test/images');
testDS.Labels = categorical(testLabels);

% Define class names
classNames = {'Class 0 - None/Light', 'Class 1 - Moderate', 'Class 2 - Severe'};

% Create EvaluationEngine
errorHandler = ErrorHandler.getInstance();
evaluator = EvaluationEngine(net, testDS, classNames, errorHandler);

% Generate comprehensive report
report = evaluator.generateEvaluationReport('ResNet50', 'output/classification/results');
```

### Step-by-Step Evaluation

```matlab
% 1. Compute metrics
metrics = evaluator.computeMetrics();
fprintf('Accuracy: %.4f\n', metrics.accuracy);
fprintf('Macro F1: %.4f\n', metrics.macroF1);

% 2. Generate confusion matrix
confMat = evaluator.generateConfusionMatrix();
normalizedConfMat = evaluator.getNormalizedConfusionMatrix();

% 3. Compute ROC curves
[fpr, tpr, auc] = evaluator.computeROC();
fprintf('Mean AUC: %.4f\n', mean(auc));

% 4. Measure inference speed
[avgTime, throughput, memoryUsage] = evaluator.measureInferenceSpeed(100);
fprintf('Average time: %.2f ms/image\n', avgTime);
fprintf('Throughput: %.2f images/sec\n', throughput);
```

## Class Reference

### Constructor

```matlab
evaluator = EvaluationEngine(net, testDatastore, classNames, errorHandler)
```

**Parameters:**
- `net`: Trained network (SeriesNetwork, DAGNetwork, or dlnetwork)
- `testDatastore`: Test datastore (imageDatastore or augmentedImageDatastore)
- `classNames`: Cell array of class names (e.g., `{'Class 0', 'Class 1', 'Class 2'}`)
- `errorHandler`: ErrorHandler instance (optional, uses singleton if not provided)

### Methods

#### computeMetrics()

Computes overall and per-class evaluation metrics.

```matlab
metrics = evaluator.computeMetrics();
```

**Returns:**
- `metrics.accuracy`: Overall accuracy (TP + TN) / Total
- `metrics.macroF1`: Macro-averaged F1 score
- `metrics.weightedF1`: Weighted F1 score
- `metrics.perClass`: Struct with per-class precision, recall, F1, and support

**Example:**
```matlab
metrics = evaluator.computeMetrics();

% Access overall metrics
fprintf('Accuracy: %.4f (%.2f%%)\n', metrics.accuracy, metrics.accuracy * 100);
fprintf('Macro F1: %.4f\n', metrics.macroF1);

% Access per-class metrics
perClassFields = fieldnames(metrics.perClass);
for i = 1:length(perClassFields)
    classMetrics = metrics.perClass.(perClassFields{i});
    fprintf('%s:\n', classNames{i});
    fprintf('  Precision: %.4f\n', classMetrics.precision);
    fprintf('  Recall: %.4f\n', classMetrics.recall);
    fprintf('  F1-Score: %.4f\n', classMetrics.f1);
    fprintf('  Support: %d\n', classMetrics.support);
end
```

#### generateConfusionMatrix()

Generates confusion matrix with rows as true labels and columns as predicted labels.

```matlab
confMat = evaluator.generateConfusionMatrix();
```

**Returns:**
- `confMat`: Confusion matrix (numClasses × numClasses)

**Example:**
```matlab
confMat = evaluator.generateConfusionMatrix();

fprintf('Confusion Matrix:\n');
fprintf('Rows: True labels, Columns: Predicted labels\n');
for i = 1:size(confMat, 1)
    fprintf('%s: ', classNames{i});
    for j = 1:size(confMat, 2)
        fprintf('%6d ', confMat(i, j));
    end
    fprintf('\n');
end
```

#### getNormalizedConfusionMatrix()

Returns confusion matrix normalized by row (percentages).

```matlab
normalizedConfMat = evaluator.getNormalizedConfusionMatrix();
```

**Returns:**
- `normalizedConfMat`: Normalized confusion matrix (values in [0, 1])

**Example:**
```matlab
normalizedConfMat = evaluator.getNormalizedConfusionMatrix();

fprintf('Normalized Confusion Matrix (Percentages):\n');
for i = 1:size(normalizedConfMat, 1)
    fprintf('%s: ', classNames{i});
    for j = 1:size(normalizedConfMat, 2)
        fprintf('%6.2f%% ', normalizedConfMat(i, j) * 100);
    end
    fprintf('\n');
end
```

#### computeROC()

Computes ROC curves and AUC scores using one-vs-rest strategy for multi-class classification.

```matlab
[fpr, tpr, auc] = evaluator.computeROC();
```

**Returns:**
- `fpr`: Cell array of false positive rates for each class
- `tpr`: Cell array of true positive rates for each class
- `auc`: Array of AUC scores for each class

**Example:**
```matlab
[fpr, tpr, auc] = evaluator.computeROC();

fprintf('AUC Scores:\n');
for i = 1:length(classNames)
    fprintf('%s: %.4f\n', classNames{i}, auc(i));
end
fprintf('Mean AUC: %.4f\n', mean(auc));

% Plot ROC curves
figure;
hold on;
for i = 1:length(classNames)
    plot(fpr{i}, tpr{i}, 'LineWidth', 2, 'DisplayName', ...
        sprintf('%s (AUC=%.3f)', classNames{i}, auc(i)));
end
plot([0 1], [0 1], 'k--', 'DisplayName', 'Random Classifier');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title('ROC Curves');
legend('Location', 'southeast');
grid on;
hold off;
```

#### measureInferenceSpeed()

Measures inference speed and memory usage.

```matlab
[avgTime, throughput, memoryUsage] = evaluator.measureInferenceSpeed(numSamples);
```

**Parameters:**
- `numSamples`: Number of samples to use for measurement (default: 100)

**Returns:**
- `avgTime`: Average inference time per image in milliseconds
- `throughput`: Throughput in images per second
- `memoryUsage`: GPU memory usage in MB (NaN if GPU not available)

**Example:**
```matlab
[avgTime, throughput, memoryUsage] = evaluator.measureInferenceSpeed(100);

fprintf('Inference Speed:\n');
fprintf('  Average time: %.2f ms/image\n', avgTime);
fprintf('  Throughput: %.2f images/second\n', throughput);

if ~isnan(memoryUsage)
    fprintf('  GPU memory: %.2f MB\n', memoryUsage);
end

% Check real-time performance (30 fps = 33.33 ms)
if avgTime < 33.33
    fprintf('  ✓ Meets real-time requirement\n');
else
    fprintf('  ✗ Does not meet real-time requirement\n');
end
```

#### generateEvaluationReport()

Generates comprehensive evaluation report with all metrics, confusion matrix, ROC curves, and inference speed.

```matlab
report = evaluator.generateEvaluationReport(modelName, outputDir);
```

**Parameters:**
- `modelName`: Name of the model being evaluated
- `outputDir`: Directory to save report files (optional)

**Returns:**
- `report`: Struct containing all evaluation results

**Report Structure:**
```matlab
report = struct(
    'modelName', 'ResNet50',
    'timestamp', datetime('now'),
    'numClasses', 3,
    'classNames', {'Class 0', 'Class 1', 'Class 2'},
    'metrics', metrics,
    'confusionMatrix', confMat,
    'normalizedConfusionMatrix', normalizedConfMat,
    'roc', struct('fpr', fpr, 'tpr', tpr, 'auc', auc),
    'inferenceTime', avgTime,
    'throughput', throughput,
    'memoryUsage', memoryUsage,
    'totalSamples', numSamples,
    'correctPredictions', numCorrect,
    'incorrectPredictions', numIncorrect
);
```

**Example:**
```matlab
outputDir = 'output/classification/results';
report = evaluator.generateEvaluationReport('ResNet50', outputDir);

% Report files saved:
% - ResNet50_evaluation_report.mat (MATLAB format)
% - ResNet50_evaluation_report.txt (human-readable text)

% Access report data
fprintf('Model: %s\n', report.modelName);
fprintf('Accuracy: %.4f\n', report.metrics.accuracy);
fprintf('Mean AUC: %.4f\n', mean(report.roc.auc));
fprintf('Inference time: %.2f ms\n', report.inferenceTime);
```

## Metrics Explained

### Overall Metrics

- **Accuracy**: Proportion of correct predictions
  - Formula: (TP + TN) / Total
  - Range: [0, 1], higher is better

- **Macro F1**: Unweighted mean of per-class F1 scores
  - Treats all classes equally
  - Good for imbalanced datasets

- **Weighted F1**: Weighted mean of per-class F1 scores by support
  - Accounts for class imbalance
  - More representative of overall performance

### Per-Class Metrics

- **Precision**: Proportion of positive predictions that are correct
  - Formula: TP / (TP + FP)
  - "Of all predicted positives, how many are actually positive?"

- **Recall**: Proportion of actual positives that are correctly predicted
  - Formula: TP / (TP + FN)
  - "Of all actual positives, how many did we find?"

- **F1-Score**: Harmonic mean of precision and recall
  - Formula: 2 × (Precision × Recall) / (Precision + Recall)
  - Balances precision and recall

- **Support**: Number of actual samples for this class

### ROC and AUC

- **ROC Curve**: Plot of True Positive Rate vs False Positive Rate
  - Shows trade-off between sensitivity and specificity
  - Diagonal line represents random classifier

- **AUC**: Area Under the ROC Curve
  - Range: [0, 1], higher is better
  - 0.5 = random classifier
  - 1.0 = perfect classifier

## Performance Benchmarking

### Inference Speed

The `measureInferenceSpeed()` method performs:

1. **Warm-up**: 10 inference passes to initialize GPU/cache
2. **Measurement**: Times N inference passes (default: 100)
3. **Calculation**: Computes average time and throughput

### Real-Time Performance

For real-time video processing at 30 fps:
- Target: < 33.33 ms per frame
- The method automatically checks and reports this

### GPU Memory

If GPU is available, the method measures:
- Memory usage during inference
- Helps identify memory bottlenecks

## Integration with Existing Infrastructure

The EvaluationEngine integrates seamlessly with:

- **ErrorHandler**: All operations are logged
- **TrainingEngine**: Evaluate models after training
- **ModelFactory**: Evaluate different architectures
- **VisualizationEngine**: Generate publication-quality figures

## Example Workflow

### Complete Evaluation Pipeline

```matlab
% 1. Setup
addpath(genpath('src/classification'));
addpath('src/utils');

errorHandler = ErrorHandler.getInstance();
errorHandler.setLogFile('evaluation_log.txt');

% 2. Load model
checkpoint = load('output/classification/checkpoints/resnet50_best.mat');
net = checkpoint.net;

% 3. Prepare test data
labels = readtable('output/classification/labels.csv');
testIndices = ...; % Your test indices
testLabels = categorical(labels.severity_class(testIndices));

imds = imageDatastore('img/original');
testDS = subset(imds, testIndices);
testDS.Labels = testLabels;

% 4. Create evaluator
classNames = {'Class 0 - None/Light', 'Class 1 - Moderate', 'Class 2 - Severe'};
evaluator = EvaluationEngine(net, testDS, classNames, errorHandler);

% 5. Generate comprehensive report
outputDir = 'output/classification/results';
report = evaluator.generateEvaluationReport('ResNet50', outputDir);

% 6. Display summary
fprintf('=== Evaluation Summary ===\n');
fprintf('Model: %s\n', report.modelName);
fprintf('Accuracy: %.4f (%.2f%%)\n', report.metrics.accuracy, report.metrics.accuracy * 100);
fprintf('Macro F1: %.4f\n', report.metrics.macroF1);
fprintf('Mean AUC: %.4f\n', mean(report.roc.auc));
fprintf('Inference time: %.2f ms/image\n', report.inferenceTime);
fprintf('Throughput: %.2f images/sec\n', report.throughput);
```

## Testing

### Unit Tests

Run unit tests with:
```matlab
run('tests/unit/test_EvaluationEngine.m');
```

Tests cover:
- Metric computation with known predictions
- Confusion matrix generation
- ROC curve computation
- Inference time measurement
- Report generation

### Validation Script

Run validation with real model:
```matlab
run('validate_evaluation_engine.m');
```

This script:
1. Loads a trained model
2. Creates test dataset
3. Runs comprehensive evaluation
4. Validates all outputs

## Troubleshooting

### Common Issues

**Issue**: "No predictions available"
- **Solution**: Ensure test datastore has data and network is loaded correctly

**Issue**: "Confusion matrix dimensions mismatch"
- **Solution**: Verify class names match the number of output classes in the network

**Issue**: "GPU memory error during inference speed measurement"
- **Solution**: Reduce `numSamples` parameter or use CPU

**Issue**: "ROC computation fails"
- **Solution**: Ensure test set has samples from all classes

### Performance Tips

1. **Large Test Sets**: Process in batches to avoid memory issues
2. **GPU Acceleration**: Ensure GPU is available for faster inference
3. **Caching**: Predictions are cached after first computation
4. **Logging**: Disable console output for faster execution

## Next Steps

After evaluation:

1. **Visualization**: Use VisualizationEngine to create publication figures
2. **Comparison**: Compare multiple models using the reports
3. **Error Analysis**: Identify misclassified samples for improvement
4. **Optimization**: Use inference speed results to guide optimization

## References

- Requirements: See `requirements.md` sections 5.1-5.5
- Design: See `design.md` EvaluationEngine section
- Related Classes: TrainingEngine, ModelFactory, VisualizationEngine
