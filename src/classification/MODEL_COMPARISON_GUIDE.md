# Model Comparison and Benchmarking Guide

## Overview

This guide covers the model comparison and benchmarking utilities implemented in Task 8. These tools enable comprehensive comparison of classification models, comparison with segmentation approaches, and detailed error analysis.

## Components

### 1. ModelComparator

**Purpose**: Aggregate and compare results from multiple classification models.

**Location**: `src/classification/core/ModelComparator.m`

**Key Features**:
- Load evaluation results from multiple models
- Create comparative metrics tables
- Identify best model per metric
- Generate ranking tables
- Export results in multiple formats (MAT, CSV, TXT)

**Usage Example**:

```matlab
% Initialize
errorHandler = ErrorHandler.getInstance();
comparator = ModelComparator(errorHandler);

% Load results from directory
resultsDir = 'output/classification/results';
comparator.loadResults(resultsDir);

% Or add results manually
comparator.addResult('ResNet50', resnet50_report);
comparator.addResult('EfficientNetB0', efficientnet_report);

% Create comparison table
compTable = comparator.createComparisonTable();

% Identify best models
bestModels = comparator.identifyBestModels();

% Generate ranking table
rankingTable = comparator.generateRankingTable();

% Save comparison
outputDir = 'output/classification/results';
comparator.saveComparison(outputDir, 'model_comparison');
```

**Output Files**:
- `model_comparison.mat` - MATLAB data file with all results
- `model_comparison_metrics.csv` - Metrics table in CSV format
- `model_comparison_rankings.csv` - Rankings table in CSV format
- `model_comparison.txt` - Human-readable text report

### 2. SegmentationComparator

**Purpose**: Compare classification models with segmentation approaches.

**Location**: `src/classification/core/SegmentationComparator.m`

**Key Features**:
- Load classification and segmentation results
- Calculate speedup factors
- Generate comparison visualizations
- Export comparison tables

**Usage Example**:

```matlab
% Initialize
errorHandler = ErrorHandler.getInstance();
segComparator = SegmentationComparator(errorHandler);

% Load classification results
classificationDir = 'output/classification/results';
segComparator.loadClassificationResults(classificationDir);

% Load segmentation results (or use estimated times)
segmentationDir = 'resultados_segmentacao';
segComparator.loadSegmentationResults(segmentationDir);

% If no segmentation timing data available, use estimates
segComparator.useEstimatedSegmentationTimes();

% Create comparison table
compTable = segComparator.createComparisonTable();

% Calculate speedup factors
speedupFactors = segComparator.calculateSpeedupFactors();

% Generate visualization
figuresDir = 'output/classification/figures';
segComparator.generateComparisonVisualization(figuresDir, 'classification_vs_segmentation');

% Save all results
segComparator.saveComparison(figuresDir, 'segmentation_comparison');
```

**Output Files**:
- `segmentation_comparison.mat` - MATLAB data file
- `segmentation_comparison.csv` - Comparison table in CSV
- `segmentation_comparison.txt` - Text report
- `classification_vs_segmentation.png` - Visualization (PNG)
- `classification_vs_segmentation.pdf` - Visualization (PDF)

### 3. ErrorAnalyzer

**Purpose**: Analyze classification errors and provide insights for model improvement.

**Location**: `src/classification/core/ErrorAnalyzer.m`

**Key Features**:
- Identify top-K misclassified images with highest confidence
- Calculate correlation between predictions and corroded percentages
- Analyze confusion patterns
- Generate insights for model improvement
- Save sample images of errors

**Usage Example**:

```matlab
% Initialize
errorHandler = ErrorHandler.getInstance();
labelCSV = 'output/classification/labels.csv';
analyzer = ErrorAnalyzer(net, testDatastore, classNames, labelCSV, errorHandler);

% Identify top 10 misclassifications
topErrors = analyzer.identifyTopMisclassifications(10);

% Calculate correlation
correlation = analyzer.calculateCorrelation();

% Generate comprehensive report
outputDir = 'output/classification/results';
report = analyzer.generateErrorAnalysisReport('ResNet50', outputDir, 10);
```

**Output Files**:
- `{model}_error_analysis.mat` - MATLAB data file with analysis
- `{model}_error_analysis.txt` - Human-readable text report
- `{model}_error_samples/` - Directory with sample images of errors
- `{model}_top_errors.png` - Visualization of top errors

## Metrics Explained

### Comparison Metrics

1. **Accuracy**: Overall classification accuracy (0-1)
2. **Macro F1**: Unweighted average of per-class F1 scores
3. **Weighted F1**: Class-weighted average of F1 scores
4. **Mean AUC**: Average of per-class AUC scores
5. **Inference Time**: Average time per image in milliseconds
6. **Throughput**: Images processed per second

### Ranking System

Models are ranked (1 = best) for each metric:
- Accuracy, F1, AUC: Higher is better
- Inference Time: Lower is better
- Average Rank: Overall performance indicator

### Speedup Factors

Speedup is calculated as:
```
Speedup = Segmentation Time / Classification Time
```

Example: If segmentation takes 150ms and classification takes 25ms:
```
Speedup = 150 / 25 = 6.0x faster
```

### Correlation Analysis

1. **True Class vs Corroded %**: How well class labels align with actual corrosion
2. **Predicted Class vs Corroded %**: How well predictions align with actual corrosion
3. **True vs Predicted**: Agreement between true and predicted labels

Strong correlation (r > 0.9) indicates the model is learning the right features.

## Error Analysis Insights

The ErrorAnalyzer generates actionable insights:

1. **Overall Performance**: Assessment of accuracy level
2. **Feature Learning**: Correlation analysis interpretation
3. **Common Errors**: Most frequent confusion patterns
4. **High-Confidence Errors**: Potential labeling issues
5. **Class Variance**: Suggestions for class refinement

## Integration Example

Complete workflow for model comparison:

```matlab
% 1. Load all model results
comparator = ModelComparator();
comparator.loadResults('output/classification/results');

% 2. Compare with segmentation
segComparator = SegmentationComparator();
segComparator.loadClassificationResults('output/classification/results');
segComparator.useEstimatedSegmentationTimes();

% 3. Analyze errors for best model
bestModels = comparator.identifyBestModels();
bestModelName = bestModels.accuracy.model;

% Load best model
load(sprintf('output/classification/checkpoints/%s_best.mat', bestModelName));

% Analyze errors
analyzer = ErrorAnalyzer(net, testDatastore, classNames, ...
    'output/classification/labels.csv');
report = analyzer.generateErrorAnalysisReport(bestModelName, ...
    'output/classification/results', 10);

% 4. Save all comparisons
comparator.saveComparison('output/classification/results', 'model_comparison');
segComparator.saveComparison('output/classification/figures', 'segmentation_comparison');
```

## Validation

Run the validation script to verify implementation:

```matlab
validate_model_comparison
```

This will test:
- ModelComparator functionality
- SegmentationComparator functionality
- Result loading and processing
- Table generation
- Ranking calculations

## Requirements Addressed

- **Requirement 5.5**: Comprehensive model evaluation and comparison
- **Requirement 10.3**: Performance benchmarking and comparison
- **Requirement 10.4**: Top-K misclassification identification
- **Requirement 10.5**: Correlation analysis and insights

## Troubleshooting

### Issue: No segmentation timing data found

**Solution**: Use estimated times:
```matlab
segComparator.useEstimatedSegmentationTimes();
```

### Issue: Label CSV not found for error analysis

**Solution**: Ensure label CSV path is correct:
```matlab
labelCSV = 'output/classification/labels.csv';
assert(isfile(labelCSV), 'Label CSV not found');
```

### Issue: Cannot load evaluation reports

**Solution**: Verify report files exist:
```matlab
resultsDir = 'output/classification/results';
files = dir(fullfile(resultsDir, '*_evaluation_report.mat'));
assert(~isempty(files), 'No evaluation reports found');
```

## Best Practices

1. **Always compare multiple models** to identify the best architecture
2. **Use speedup analysis** to justify classification vs segmentation trade-offs
3. **Review error analysis** to identify model weaknesses
4. **Check correlation metrics** to ensure model is learning correct features
5. **Save all comparisons** for documentation and reproducibility

## Next Steps

After completing model comparison:
1. Review insights from error analysis
2. Identify best model for deployment
3. Document performance trade-offs
4. Prepare results for publication
5. Consider ensemble methods if multiple models perform well
