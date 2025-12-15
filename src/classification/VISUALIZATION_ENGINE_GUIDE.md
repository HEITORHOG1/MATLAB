# VisualizationEngine Implementation Guide

## Overview

The `VisualizationEngine` class provides comprehensive visualization and export functionality for the classification system. It generates publication-quality figures and LaTeX tables for research articles.

## Implementation Status

✅ **COMPLETE** - All visualization and export functionality implemented

## Features Implemented

### 1. Confusion Matrix Visualization (Requirement 6.1)
- Heatmap with Blues colormap
- Percentage annotations in each cell
- Figure size: 8×6 inches
- Export formats: PNG (300 DPI) and PDF (vector)

**Usage:**
```matlab
confMat = [45, 3, 2; 4, 38, 3; 2, 1, 42];
classNames = {'Class 0', 'Class 1', 'Class 2'};
outputPath = 'output/classification/figures/confusion_matrix';

figHandle = VisualizationEngine.plotConfusionMatrix(...
    confMat, classNames, outputPath, 'ResNet50');
```

### 2. Training Curves Visualization (Requirement 6.2)
- Side-by-side subplots for Loss and Accuracy
- Training (solid line) vs Validation (dashed line)
- Multiple models comparison
- Grid enabled for readability

**Usage:**
```matlab
% Create training history struct
history = struct(...
    'epoch', 1:30, ...
    'trainLoss', [...], ...
    'valLoss', [...], ...
    'trainAccuracy', [...], ...
    'valAccuracy', [...]);

histories = {history1, history2};
modelNames = {'ResNet50', 'EfficientNet-B0'};
outputPath = 'output/classification/figures/training_curves';

figHandle = VisualizationEngine.plotTrainingCurves(...
    histories, modelNames, outputPath);
```

### 3. ROC Curves Visualization (Requirement 6.3)
- One curve per class with different colors
- Diagonal reference line (random classifier)
- AUC values in legend
- Axes: False Positive Rate vs True Positive Rate

**Usage:**
```matlab
rocData = struct(...
    'fpr', {fpr_cell_array}, ...
    'tpr', {tpr_cell_array}, ...
    'auc', [0.95, 0.90, 0.93]);

classNames = {'Class 0', 'Class 1', 'Class 2'};
outputPath = 'output/classification/figures/roc_curves';

figHandle = VisualizationEngine.plotROCCurves(...
    rocData, classNames, outputPath, 'ResNet50');
```

### 4. Inference Time Comparison (Requirement 6.4)
- Bar chart with model names
- Horizontal line for real-time threshold (33.33 ms for 30 fps)
- Value labels on top of bars

**Usage:**
```matlab
times = [28.5, 19.2, 45.7]; % milliseconds
modelNames = {'ResNet50', 'EfficientNet-B0', 'Custom CNN'};
outputPath = 'output/classification/figures/inference_comparison';

figHandle = VisualizationEngine.plotInferenceComparison(...
    times, modelNames, outputPath);
```

### 5. LaTeX Table Generation (Requirements 9.1, 9.2, 9.3)

#### Metrics Comparison Table
```matlab
reports = {report1, report2, report3};
modelNames = {'ResNet50', 'EfficientNet-B0', 'Custom CNN'};
outputPath = 'output/classification/latex/metrics_table.tex';

VisualizationEngine.generateLatexTable(...
    reports, 'metrics', outputPath, modelNames);
```

#### Confusion Matrix Table
```matlab
confMat = [45, 3, 2; 4, 38, 3; 2, 1, 42];
classNames = {'Class 0', 'Class 1', 'Class 2'};
outputPath = 'output/classification/latex/confusion_table.tex';

VisualizationEngine.generateLatexTable(...
    confMat, 'confusion', outputPath, classNames, 'ResNet50');
```

#### Summary Document
```matlab
reports = {report1, report2};
modelNames = {'ResNet50', 'EfficientNet-B0'};
classNames = {'Class 0', 'Class 1', 'Class 2'};
outputPath = 'output/classification/latex/results_summary.tex';

VisualizationEngine.generateLatexTable(...
    reports, 'summary', outputPath, modelNames, classNames);
```

### 6. Batch Figure Export (Requirement 6.5)
```matlab
figHandles = {fig1, fig2, fig3};
outputDir = 'output/classification/figures';
baseName = 'model_comparison';

VisualizationEngine.exportAllFigures(figHandles, outputDir, baseName);
% Creates: model_comparison_1.png, model_comparison_1.pdf, etc.
```

## Class Structure

### Public Static Methods

1. **plotConfusionMatrix(confMat, classNames, outputPath, modelName)**
   - Generates confusion matrix heatmap
   - Returns: Figure handle

2. **plotTrainingCurves(histories, modelNames, outputPath)**
   - Generates training/validation curves comparison
   - Returns: Figure handle

3. **plotROCCurves(rocData, classNames, outputPath, modelName)**
   - Generates ROC curves with AUC scores
   - Returns: Figure handle

4. **plotInferenceComparison(times, modelNames, outputPath)**
   - Generates inference time bar chart
   - Returns: Figure handle

5. **generateLatexTable(data, tableType, outputPath, varargin)**
   - Generates LaTeX tables
   - tableType: 'metrics', 'confusion', or 'summary'

6. **exportAllFigures(figHandles, outputDir, baseName)**
   - Batch exports figures in PNG and PDF formats

### Private Static Methods

1. **exportFigure(figHandle, outputPath)**
   - Exports single figure in PNG (300 DPI) and PDF (vector)

2. **generateMetricsTable(reports, outputPath, modelNames)**
   - Generates metrics comparison table

3. **generateConfusionTable(confMat, outputPath, classNames, modelName)**
   - Generates confusion matrix table

4. **generateSummaryDocument(reports, outputPath, modelNames, classNames)**
   - Generates complete results summary with figure captions

### Constants

- **FIGURE_DPI**: 300 (for PNG export)
- **CONFUSION_MATRIX_SIZE**: [8, 6] inches
- **TRAINING_CURVES_SIZE**: [10, 6] inches
- **ROC_CURVES_SIZE**: [8, 6] inches
- **INFERENCE_COMPARISON_SIZE**: [8, 6] inches
- **COLORMAP_CONFUSION**: 'Blues'
- **REALTIME_THRESHOLD**: 33.33 ms (30 fps)

## Integration with Existing Infrastructure

The VisualizationEngine integrates seamlessly with:

1. **ErrorHandler**: All methods use ErrorHandler for logging
2. **EvaluationEngine**: Consumes evaluation report structs
3. **TrainingEngine**: Consumes training history structs

## Testing

### Integration Tests

Run the comprehensive integration tests:
```matlab
test_VisualizationEngine()
```

Tests include:
1. Confusion matrix visualization
2. Training curves visualization
3. ROC curves visualization
4. Inference time comparison
5. LaTeX metrics table generation
6. LaTeX confusion matrix table generation
7. LaTeX summary document generation
8. Batch figure export
9. Figure format validation
10. Error handling

### Validation Script

Run the validation script to test with realistic data:
```matlab
validate_visualization_engine()
```

This validates:
- Class structure
- Realistic scenario testing
- Output quality (resolution, file size, LaTeX syntax)

## Output Structure

```
output/classification/
├── figures/
│   ├── confusion_matrix_resnet50.png
│   ├── confusion_matrix_resnet50.pdf
│   ├── training_curves_comparison.png
│   ├── training_curves_comparison.pdf
│   ├── roc_curves_resnet50.png
│   ├── roc_curves_resnet50.pdf
│   └── inference_time_comparison.png
├── latex/
│   ├── metrics_table.tex
│   ├── confusion_matrix_table.tex
│   └── results_summary.tex
└── logs/
    └── visualization_YYYY-MM-DD_HH-MM-SS.txt
```

## Publication Quality Standards

All figures meet publication standards:
- **Resolution**: 300 DPI for raster images
- **Format**: Vector PDF for scalability
- **Fonts**: Arial, 10-14pt
- **Colors**: Colorblind-friendly palettes
- **Layout**: Professional spacing and alignment

LaTeX tables use:
- **booktabs** package formatting
- Proper table environments with captions and labels
- Consistent number formatting (4 decimal places for metrics)

## Example Workflow

```matlab
% 1. Train models and get evaluation reports
report1 = evaluationEngine1.generateEvaluationReport('ResNet50', outputDir);
report2 = evaluationEngine2.generateEvaluationReport('EfficientNet-B0', outputDir);

% 2. Generate all visualizations
reports = {report1, report2};
modelNames = {'ResNet50', 'EfficientNet-B0'};
classNames = {'Class 0', 'Class 1', 'Class 2'};

% Confusion matrices
for i = 1:length(reports)
    VisualizationEngine.plotConfusionMatrix(...
        reports{i}.confusionMatrix, classNames, ...
        sprintf('output/figures/confusion_%s', modelNames{i}), ...
        modelNames{i});
end

% Training curves
histories = {history1, history2};
VisualizationEngine.plotTrainingCurves(...
    histories, modelNames, 'output/figures/training_curves');

% ROC curves
for i = 1:length(reports)
    VisualizationEngine.plotROCCurves(...
        reports{i}.roc, classNames, ...
        sprintf('output/figures/roc_%s', modelNames{i}), ...
        modelNames{i});
end

% Inference comparison
times = [reports{1}.inferenceTime, reports{2}.inferenceTime];
VisualizationEngine.plotInferenceComparison(...
    times, modelNames, 'output/figures/inference_comparison');

% 3. Generate LaTeX tables
VisualizationEngine.generateLatexTable(...
    reports, 'metrics', 'output/latex/metrics_table.tex', modelNames);

VisualizationEngine.generateLatexTable(...
    reports, 'summary', 'output/latex/results_summary.tex', ...
    modelNames, classNames);
```

## Requirements Coverage

✅ **Requirement 6.1**: Confusion matrix heatmaps with percentage annotations  
✅ **Requirement 6.2**: Training curves comparison plots  
✅ **Requirement 6.3**: ROC curves with AUC values  
✅ **Requirement 6.4**: Inference time comparison bar charts  
✅ **Requirement 6.5**: High-resolution export (PNG 300dpi, PDF vector)  
✅ **Requirement 7.2**: Integration with VisualizationHelper  
✅ **Requirement 9.1**: LaTeX metrics comparison table  
✅ **Requirement 9.2**: LaTeX confusion matrix table  
✅ **Requirement 9.3**: Results summary document with figure captions  

## Next Steps

The VisualizationEngine is complete and ready for use. Next tasks:
1. Task 8: Implement model comparison and benchmarking utilities
2. Task 9: Create main execution script (executar_classificacao.m)
3. Task 10: Create documentation and examples

## Troubleshooting

### Issue: Figures not visible
**Solution**: Figures are created with 'Visible' set to 'off' for batch processing. Use `set(figHandle, 'Visible', 'on')` to view.

### Issue: LaTeX compilation errors
**Solution**: Ensure booktabs package is included in your LaTeX document:
```latex
\usepackage{booktabs}
\usepackage{graphicx}
```

### Issue: Low resolution PNG
**Solution**: The FIGURE_DPI constant is set to 300. Verify with:
```matlab
info = imfinfo('output.png');
disp(info.Width); % Should be > 1000 for 8-inch width
```

## Contact

For issues or questions about the VisualizationEngine implementation, refer to:
- Design document: `.kiro/specs/corrosion-classification-system/design.md`
- Requirements: `.kiro/specs/corrosion-classification-system/requirements.md`
- Integration tests: `tests/integration/test_VisualizationEngine.m`
