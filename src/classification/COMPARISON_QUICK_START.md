# Model Comparison Quick Start Guide

## Quick Start: Compare All Models

```matlab
% Initialize error handler
errorHandler = ErrorHandler.getInstance();
errorHandler.setLogFile('model_comparison.log');

% 1. Compare classification models
fprintf('=== Comparing Classification Models ===\n');
comparator = ModelComparator(errorHandler);
comparator.loadResults('output/classification/results');

% View comparison table
compTable = comparator.createComparisonTable();
disp(compTable);

% Identify best models
bestModels = comparator.identifyBestModels();
fprintf('\nBest Accuracy: %s (%.4f)\n', bestModels.accuracy.model, bestModels.accuracy.value);
fprintf('Fastest Model: %s (%.2f ms)\n', bestModels.inferenceTime.model, bestModels.inferenceTime.value);

% Generate rankings
rankingTable = comparator.generateRankingTable();
disp(rankingTable);

% Save results
comparator.saveComparison('output/classification/results', 'model_comparison');
fprintf('✓ Comparison saved\n\n');
```

## Quick Start: Compare with Segmentation

```matlab
% 2. Compare with segmentation
fprintf('=== Comparing with Segmentation ===\n');
segComparator = SegmentationComparator(errorHandler);

% Load classification results
segComparator.loadClassificationResults('output/classification/results');

% Use estimated segmentation times
segComparator.useEstimatedSegmentationTimes();

% Calculate speedup
speedupFactors = segComparator.calculateSpeedupFactors();

% Display speedup for each model
classModels = fieldnames(speedupFactors);
for i = 1:length(classModels)
    modelName = classModels{i};
    speedup = speedupFactors.(modelName).vsAverage;
    fprintf('%s: %.2fx faster than segmentation\n', modelName, speedup);
end

% Save comparison
segComparator.saveComparison('output/classification/figures', 'segmentation_comparison');
fprintf('✓ Segmentation comparison saved\n\n');
```

## Quick Start: Analyze Errors

```matlab
% 3. Analyze errors for best model
fprintf('=== Analyzing Errors ===\n');

% Load best model
bestModelName = bestModels.accuracy.model;
checkpointPath = sprintf('output/classification/checkpoints/%s_best.mat', bestModelName);
load(checkpointPath, 'net');

% Load test data
config = ClassificationConfig();
labelCSV = config.labelGeneration.outputCSV;

% Create test datastore (you need to have this from training)
% This is a placeholder - replace with actual test datastore
% testDatastore = ...;

% Initialize analyzer
analyzer = ErrorAnalyzer(net, testDatastore, config.labelGeneration.classNames, ...
    labelCSV, errorHandler);

% Generate error analysis report
report = analyzer.generateErrorAnalysisReport(bestModelName, ...
    'output/classification/results', 10);

% Display insights
fprintf('\n=== Insights ===\n');
for i = 1:length(report.insights)
    fprintf('%d. %s\n', i, report.insights{i});
end

fprintf('✓ Error analysis complete\n\n');
```

## One-Line Commands

### Compare all models
```matlab
comparator = ModelComparator(); comparator.loadResults('output/classification/results'); comparator.saveComparison('output/classification/results', 'model_comparison');
```

### Compare with segmentation
```matlab
segComp = SegmentationComparator(); segComp.loadClassificationResults('output/classification/results'); segComp.useEstimatedSegmentationTimes(); segComp.saveComparison('output/classification/figures', 'seg_comparison');
```

### Analyze errors
```matlab
analyzer = ErrorAnalyzer(net, testDS, classNames, 'output/classification/labels.csv'); analyzer.generateErrorAnalysisReport('ModelName', 'output/classification/results', 10);
```

## Expected Output

### Comparison Table
```
Model              Accuracy    MacroF1    WeightedF1    MeanAUC    InferenceTime_ms    Throughput_imgs_per_sec
ResNet50           0.9200      0.9100     0.9200        0.9400     25.50               39.22
EfficientNetB0     0.9100      0.9000     0.9100        0.9300     18.20               54.95
CustomCNN          0.8800      0.8700     0.8800        0.9000     12.50               80.00
```

### Best Models
```
Best Accuracy: ResNet50 (0.9200)
Best Macro F1: ResNet50 (0.9100)
Best Weighted F1: ResNet50 (0.9200)
Best Mean AUC: ResNet50 (0.9400)
Fastest Inference: CustomCNN (12.50 ms)
```

### Speedup Factors
```
ResNet50: 5.88x faster than segmentation
EfficientNetB0: 8.24x faster than segmentation
CustomCNN: 12.00x faster than segmentation
```

### Top Errors
```
#1: img042.jpg - True: Moderate, Pred: Severe (95.23% conf, 28.5% corroded)
#2: img087.jpg - True: Light, Pred: Moderate (92.15% conf, 9.8% corroded)
#3: img123.jpg - True: Severe, Pred: Moderate (89.67% conf, 31.2% corroded)
```

## Output Files Location

All results are saved to:
- `output/classification/results/` - Comparison tables and reports
- `output/classification/figures/` - Visualizations
- `output/classification/results/{model}_error_samples/` - Error sample images

## Troubleshooting

### Error: "No evaluation report files found"
**Solution**: Ensure models have been evaluated first
```matlab
% Run evaluation for each model first
evaluator = EvaluationEngine(net, testDS, classNames);
report = evaluator.generateEvaluationReport('ModelName', 'output/classification/results');
```

### Error: "Label CSV not found"
**Solution**: Generate labels first
```matlab
% Run label generation
gerar_labels_classificacao
```

### Error: "Test datastore not available"
**Solution**: Recreate test datastore
```matlab
config = ClassificationConfig();
datasetManager = DatasetManager(config.paths.imageDir, config.labelGeneration.outputCSV, config);
[~, ~, testDS] = datasetManager.prepareDatasets();
```

## Tips

1. **Always run evaluation first** before comparison
2. **Save test datastore** for error analysis
3. **Use estimated segmentation times** if actual data unavailable
4. **Review insights** to improve model
5. **Check correlation metrics** to validate learning

## Next Steps

After running comparisons:
1. Review best model for each metric
2. Check speedup factors for deployment decisions
3. Analyze top errors to identify weaknesses
4. Review insights for model improvements
5. Prepare results for publication

## Complete Workflow

```matlab
% Complete comparison workflow
errorHandler = ErrorHandler.getInstance();

% 1. Model comparison
comp = ModelComparator(errorHandler);
comp.loadResults('output/classification/results');
comp.saveComparison('output/classification/results', 'model_comparison');

% 2. Segmentation comparison
segComp = SegmentationComparator(errorHandler);
segComp.loadClassificationResults('output/classification/results');
segComp.useEstimatedSegmentationTimes();
segComp.saveComparison('output/classification/figures', 'segmentation_comparison');

% 3. Error analysis (for best model)
bestModels = comp.identifyBestModels();
load(sprintf('output/classification/checkpoints/%s_best.mat', bestModels.accuracy.model));
analyzer = ErrorAnalyzer(net, testDS, classNames, 'output/classification/labels.csv', errorHandler);
analyzer.generateErrorAnalysisReport(bestModels.accuracy.model, 'output/classification/results', 10);

fprintf('✓ All comparisons complete!\n');
```

## Validation

Test the implementation:
```matlab
validate_model_comparison
```

This will verify all components are working correctly.
