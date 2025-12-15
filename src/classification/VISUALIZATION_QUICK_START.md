# VisualizationEngine Quick Start Guide

## Overview

The VisualizationEngine provides publication-quality figure generation and LaTeX export for classification results.

## Quick Examples

### 1. Plot Confusion Matrix

```matlab
% Prepare data
confMat = [45, 3, 2; 4, 38, 3; 2, 1, 42];
classNames = {'Class 0 - None/Light', 'Class 1 - Moderate', 'Class 2 - Severe'};

% Generate figure
figHandle = VisualizationEngine.plotConfusionMatrix(...
    confMat, ...
    classNames, ...
    'output/classification/figures/confusion_matrix_resnet50', ...
    'ResNet50');

% Files created:
% - confusion_matrix_resnet50.png (300 DPI)
% - confusion_matrix_resnet50.pdf (vector)
```

### 2. Plot Training Curves

```matlab
% Prepare training history
history = struct(...
    'epoch', 1:30, ...
    'trainLoss', [...], ...
    'valLoss', [...], ...
    'trainAccuracy', [...], ...
    'valAccuracy', [...]);

% Generate figure
figHandle = VisualizationEngine.plotTrainingCurves(...
    {history}, ...
    {'ResNet50'}, ...
    'output/classification/figures/training_curves');
```

### 3. Plot ROC Curves

```matlab
% Prepare ROC data (from EvaluationEngine)
[fpr, tpr, auc] = evaluationEngine.computeROC();
rocData = struct('fpr', {fpr}, 'tpr', {tpr}, 'auc', auc);

% Generate figure
figHandle = VisualizationEngine.plotROCCurves(...
    rocData, ...
    classNames, ...
    'output/classification/figures/roc_curves_resnet50', ...
    'ResNet50');
```

### 4. Plot Inference Time Comparison

```matlab
% Prepare data
times = [28.5, 19.2, 45.7]; % milliseconds
modelNames = {'ResNet50', 'EfficientNet-B0', 'Custom CNN'};

% Generate figure
figHandle = VisualizationEngine.plotInferenceComparison(...
    times, ...
    modelNames, ...
    'output/classification/figures/inference_comparison');
```

### 5. Generate LaTeX Metrics Table

```matlab
% Prepare evaluation reports
reports = {report1, report2, report3};
modelNames = {'ResNet50', 'EfficientNet-B0', 'Custom CNN'};

% Generate table
VisualizationEngine.generateLatexTable(...
    reports, ...
    'metrics', ...
    'output/classification/latex/metrics_table.tex', ...
    modelNames);
```

### 6. Generate LaTeX Confusion Matrix Table

```matlab
% Generate table
VisualizationEngine.generateLatexTable(...
    confMat, ...
    'confusion', ...
    'output/classification/latex/confusion_table.tex', ...
    classNames, ...
    'ResNet50');
```

### 7. Generate Complete Results Summary

```matlab
% Generate summary document with all figures and captions
VisualizationEngine.generateLatexTable(...
    reports, ...
    'summary', ...
    'output/classification/latex/results_summary.tex', ...
    modelNames, ...
    classNames);
```

### 8. Batch Export Figures

```matlab
% Create multiple figures
fig1 = VisualizationEngine.plotConfusionMatrix(...);
fig2 = VisualizationEngine.plotROCCurves(...);
fig3 = VisualizationEngine.plotTrainingCurves(...);

% Export all at once
figHandles = {fig1, fig2, fig3};
VisualizationEngine.exportAllFigures(...
    figHandles, ...
    'output/classification/figures', ...
    'model_results');

% Creates:
% - model_results_1.png/pdf
% - model_results_2.png/pdf
% - model_results_3.png/pdf
```

## Complete Workflow Example

```matlab
% After training and evaluation
outputDir = 'output/classification';
figuresDir = fullfile(outputDir, 'figures');
latexDir = fullfile(outputDir, 'latex');

% Ensure directories exist
if ~exist(figuresDir, 'dir'), mkdir(figuresDir); end
if ~exist(latexDir, 'dir'), mkdir(latexDir); end

% 1. Generate confusion matrices for each model
models = {'ResNet50', 'EfficientNet-B0', 'Custom CNN'};
for i = 1:length(models)
    VisualizationEngine.plotConfusionMatrix(...
        reports{i}.confusionMatrix, ...
        classNames, ...
        fullfile(figuresDir, sprintf('confusion_%s', models{i})), ...
        models{i});
end

% 2. Generate training curves comparison
VisualizationEngine.plotTrainingCurves(...
    {history1, history2, history3}, ...
    models, ...
    fullfile(figuresDir, 'training_curves_comparison'));

% 3. Generate ROC curves for each model
for i = 1:length(models)
    VisualizationEngine.plotROCCurves(...
        reports{i}.roc, ...
        classNames, ...
        fullfile(figuresDir, sprintf('roc_%s', models{i})), ...
        models{i});
end

% 4. Generate inference time comparison
times = cellfun(@(r) r.inferenceTime, reports);
VisualizationEngine.plotInferenceComparison(...
    times, ...
    models, ...
    fullfile(figuresDir, 'inference_comparison'));

% 5. Generate LaTeX tables
VisualizationEngine.generateLatexTable(...
    reports, 'metrics', fullfile(latexDir, 'metrics_table.tex'), models);

for i = 1:length(models)
    VisualizationEngine.generateLatexTable(...
        reports{i}.confusionMatrix, 'confusion', ...
        fullfile(latexDir, sprintf('confusion_%s.tex', models{i})), ...
        classNames, models{i});
end

% 6. Generate complete summary
VisualizationEngine.generateLatexTable(...
    reports, 'summary', fullfile(latexDir, 'results_summary.tex'), ...
    models, classNames);

fprintf('All visualizations and tables generated successfully!\n');
fprintf('Figures: %s\n', figuresDir);
fprintf('LaTeX: %s\n', latexDir);
```

## Using with EvaluationEngine

```matlab
% Create evaluation engine
evaluationEngine = EvaluationEngine(net, testDatastore, classNames, errorHandler);

% Generate evaluation report
report = evaluationEngine.generateEvaluationReport('ResNet50', outputDir);

% Use report data for visualization
VisualizationEngine.plotConfusionMatrix(...
    report.confusionMatrix, classNames, 'output/confusion', 'ResNet50');

VisualizationEngine.plotROCCurves(...
    report.roc, classNames, 'output/roc', 'ResNet50');
```

## Using with TrainingEngine

```matlab
% Train model
trainingEngine = TrainingEngine(net, config);
[trainedNet, history] = trainingEngine.train(trainDS, valDS);

% Visualize training history
VisualizationEngine.plotTrainingCurves(...
    {history}, {'ResNet50'}, 'output/training_curves');
```

## LaTeX Integration

### In Your LaTeX Document

```latex
\documentclass{article}
\usepackage{booktabs}
\usepackage{graphicx}

\begin{document}

% Include metrics table
\input{output/classification/latex/metrics_table.tex}

% Include figure
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.8\textwidth]{output/classification/figures/confusion_matrix_resnet50.pdf}
  \caption{Confusion matrix for ResNet50 classifier.}
  \label{fig:confusion_resnet50}
\end{figure}

% Include complete summary
\input{output/classification/latex/results_summary.tex}

\end{document}
```

## Tips

1. **Invisible Figures**: Figures are created with 'Visible' off for batch processing. To view:
   ```matlab
   set(figHandle, 'Visible', 'on');
   ```

2. **Custom Colors**: Modify the colormap:
   ```matlab
   % After creating figure
   colormap(figHandle, 'parula'); % or any other colormap
   ```

3. **Figure Size**: Adjust constants in VisualizationEngine if needed:
   ```matlab
   % Default: CONFUSION_MATRIX_SIZE = [8, 6]
   ```

4. **Resolution**: PNG resolution is 300 DPI by default (publication quality)

5. **Error Handling**: All methods log to ErrorHandler. Check logs if issues occur:
   ```matlab
   errorHandler = ErrorHandler.getInstance();
   errorHandler.setLogFile('visualization.log');
   ```

## Common Issues

### Issue: "Cannot open file"
**Solution**: Ensure output directory exists:
```matlab
if ~exist('output/classification/figures', 'dir')
    mkdir('output/classification/figures');
end
```

### Issue: LaTeX compilation errors
**Solution**: Add required packages:
```latex
\usepackage{booktabs}
\usepackage{graphicx}
```

### Issue: Low resolution images
**Solution**: Check PNG info:
```matlab
info = imfinfo('output.png');
fprintf('Width: %d, Height: %d\n', info.Width, info.Height);
% Should be > 1000 for 8-inch width at 300 DPI
```

## Testing

Run tests to verify installation:
```matlab
% Integration tests
test_VisualizationEngine()

% Validation
validate_visualization_engine()
```

## More Information

- Full documentation: `src/classification/VISUALIZATION_ENGINE_GUIDE.md`
- Implementation summary: `TASK_7_IMPLEMENTATION_SUMMARY.md`
- Verification checklist: `src/classification/TASK_7_VERIFICATION.md`
