# Main Execution Script Guide

## Overview

The `executar_classificacao.m` script is the main entry point for the complete classification system workflow. It orchestrates all phases from label generation to final results export.

## Requirements Addressed

- **8.1**: Complete workflow execution from label generation to evaluation
- **8.2**: Automatic path detection and validation
- **8.3**: Progress reporting with timing information
- **8.4**: Comprehensive error handling with graceful degradation
- **8.5**: Execution logging with timestamped log files

## Usage

### Basic Usage

```matlab
% Use default configuration
executar_classificacao()
```

### Custom Configuration

```matlab
% Use custom configuration file
executar_classificacao('my_config.mat')
```

## Execution Phases

The script executes 7 sequential phases:

### Phase 1: Load Configuration
- Loads configuration from `ClassificationConfig`
- Validates all configuration parameters
- Detects and validates dataset paths automatically
- Creates output directories if missing

**Key Features:**
- Automatic path detection with fallback locations
- Configuration validation
- Directory structure creation

### Phase 2: Generate Labels from Masks
- Converts segmentation masks to severity labels
- Uses configurable thresholds (default: [10, 30])
- Saves labels to CSV file
- Provides class distribution statistics

**Key Features:**
- Checks for existing labels file
- Prompts user before regenerating
- Logs conversion statistics

### Phase 3: Prepare Dataset Splits
- Loads images and labels
- Creates stratified train/val/test splits (default: 70/15/15)
- Applies data augmentation to training set
- Validates dataset integrity

**Key Features:**
- Stratified splitting maintains class balance
- Configurable augmentation pipeline
- Dataset statistics reporting

### Phase 4: Train All Models
- Trains each configured model architecture
- Supports: ResNet50, EfficientNet-B0, CustomCNN
- Implements early stopping and checkpointing
- Continues with remaining models if one fails

**Key Features:**
- Sequential training with progress reporting
- Graceful degradation on failures
- Training history visualization
- Best model checkpointing

### Phase 5: Evaluate All Models
- Computes comprehensive metrics for each model
- Generates confusion matrices
- Calculates ROC curves and AUC scores
- Measures inference speed

**Key Features:**
- Per-class and overall metrics
- Inference time benchmarking
- Detailed evaluation reports

### Phase 6: Generate Visualizations
- Creates confusion matrix heatmaps
- Generates training curves comparison
- Plots ROC curves for each model
- Creates inference time comparison chart
- Exports LaTeX tables

**Key Features:**
- Publication-quality figures (PNG 300 DPI + PDF)
- LaTeX table generation
- Comparative visualizations

### Phase 7: Generate Final Summary
- Creates comprehensive execution summary
- Identifies best models for each metric
- Documents all configuration parameters
- Lists all output files

**Key Features:**
- Timestamped summary report
- Best model identification
- Complete execution log

## Automatic Path Detection

The script automatically detects dataset locations:

### Image Directory Detection
Searches in order:
1. Configured path (`config.paths.imageDir`)
2. `img/original`
3. `data/images`
4. `images`

### Mask Directory Detection
Searches in order:
1. Configured path (`config.paths.maskDir`)
2. `img/masks`
3. `data/masks`
4. `masks`

If paths are not found, the script raises an error with clear instructions.

## Progress Reporting

The script provides detailed progress information:

### Phase-Level Reporting
```
[Phase 1/7] Loading Configuration...
----------------------------------------
✓ Configuration loaded successfully (0.15 seconds)
```

### Model-Level Reporting
```
--- Training Model 1/3: ResNet50 ---
✓ ResNet50 training completed
  - Best validation accuracy: 0.9234
  - Training epochs: 45
```

### Timing Information
- Phase execution time
- Total execution time
- Estimated time remaining (for long operations)

## Error Handling

### Graceful Degradation
If a model fails to train or evaluate:
- Error is logged with full stack trace
- Execution continues with remaining models
- Failed models are excluded from visualizations
- Summary report documents all failures

### Error Categories
1. **Configuration Errors**: Invalid paths, parameters
2. **Data Errors**: Missing images, corrupted files
3. **Training Errors**: Out of memory, convergence issues
4. **Evaluation Errors**: Invalid predictions, metric computation failures

### Error Recovery
```matlab
try
    [net, history] = trainModel(modelName, trainDS, valDS, config, errorHandler);
    trainedModels{end+1} = net;
catch ME
    errorHandler.logError('Main', sprintf('Training failed for %s: %s', modelName, ME.message));
    fprintf('✗ %s training failed: %s\n', modelName, ME.message);
    fprintf('  Continuing with remaining models...\n');
    trainedModels{end+1} = [];
    trainingErrors{end+1} = ME;
end
```

## Execution Logging

### Log File Location
```
output/classification/logs/classification_execution_YYYYMMDD_HHMMSS.txt
```

### Log Levels
- **INFO**: Normal execution progress
- **WARNING**: Non-critical issues (e.g., class imbalance)
- **ERROR**: Failures with stack traces
- **DEBUG**: Detailed diagnostic information

### Log Content
- Configuration parameters
- Phase execution times
- Model training progress
- Evaluation metrics
- Error messages and stack traces

## Output Structure

```
output/classification/
├── labels.csv                          # Generated labels
├── checkpoints/                        # Model checkpoints
│   ├── ResNet50_best.mat
│   ├── EfficientNetB0_best.mat
│   └── CustomCNN_best.mat
├── results/                            # Evaluation reports
│   ├── ResNet50_evaluation_report.mat
│   ├── execution_summary_YYYYMMDD_HHMMSS.txt
│   └── ...
├── figures/                            # Visualizations
│   ├── confusion_matrix_ResNet50.png
│   ├── confusion_matrix_ResNet50.pdf
│   ├── training_curves_comparison.png
│   ├── roc_curves_ResNet50.png
│   └── inference_time_comparison.png
├── latex/                              # LaTeX tables
│   ├── metrics_comparison_table.tex
│   ├── confusion_matrix_ResNet50.tex
│   └── results_summary.tex
└── logs/                               # Execution logs
    └── classification_execution_YYYYMMDD_HHMMSS.txt
```

## Configuration Options

### Minimal Configuration
```matlab
config = ClassificationConfig();
executar_classificacao();
```

### Custom Configuration
```matlab
config = ClassificationConfig();

% Modify paths
config.paths.imageDir = 'custom/images';
config.paths.maskDir = 'custom/masks';

% Modify training parameters
config.training.maxEpochs = 100;
config.training.miniBatchSize = 64;

% Modify model selection
config.models.architectures = {'ResNet50', 'CustomCNN'};

% Save and use
config.saveToFile('custom_config.mat');
executar_classificacao('custom_config.mat');
```

## Performance Considerations

### Memory Usage
- Training: ~8GB GPU memory (ResNet50)
- Inference: ~2GB GPU memory
- Disk space: ~500MB per model checkpoint

### Execution Time
Typical execution times (with GPU):
- Label generation: 1-2 minutes (800 images)
- Dataset preparation: 30 seconds
- Training per model: 20-40 minutes (50 epochs)
- Evaluation per model: 2-3 minutes
- Visualization: 1-2 minutes

**Total: ~1.5-2.5 hours for 3 models**

### Optimization Tips
1. Reduce `maxEpochs` for faster training
2. Increase `miniBatchSize` if GPU memory allows
3. Use `CustomCNN` for faster prototyping
4. Enable early stopping to avoid unnecessary epochs

## Troubleshooting

### Common Issues

#### Issue: "Image directory not found"
**Solution**: Check that images exist in one of the searched locations or update `config.paths.imageDir`

#### Issue: "Out of memory during training"
**Solution**: 
- Reduce `miniBatchSize` (e.g., from 32 to 16)
- Use smaller model (CustomCNN instead of ResNet50)
- Close other GPU applications

#### Issue: "All models failed to train"
**Solution**: 
- Check log file for detailed error messages
- Verify dataset integrity
- Ensure Deep Learning Toolbox is installed
- Check GPU availability with `gpuDevice()`

#### Issue: "Class imbalance warning"
**Solution**: 
- This is informational - system handles imbalance
- Consider collecting more data for minority classes
- Use weighted loss functions (future enhancement)

### Debug Mode

To enable detailed logging:
```matlab
errorHandler = ErrorHandler.getInstance();
errorHandler.setLogLevel('DEBUG');
executar_classificacao();
```

## Integration with Existing Infrastructure

The script integrates with:
- **ErrorHandler**: Centralized logging and error management
- **VisualizationHelper**: Data preparation for plots
- **DataTypeConverter**: Type conversions
- **PreprocessingValidator**: Image validation

## Best Practices

1. **Always review configuration** before execution
2. **Monitor log file** during execution for warnings
3. **Check disk space** before starting (need ~2GB free)
4. **Use GPU** for training (CPU training is very slow)
5. **Save custom configurations** for reproducibility
6. **Backup checkpoints** after successful training

## Example Workflow

```matlab
% 1. Create and customize configuration
config = ClassificationConfig();
config.training.maxEpochs = 30;  % Faster training
config.models.architectures = {'ResNet50', 'CustomCNN'};  % Only 2 models
config.saveToFile('quick_test_config.mat');

% 2. Run execution
executar_classificacao('quick_test_config.mat');

% 3. Review results
% Check: output/classification/results/execution_summary_*.txt
% View figures: output/classification/figures/

% 4. Load best model for inference
load('output/classification/checkpoints/ResNet50_best.mat', 'net');
testImage = imread('test_image.jpg');
testImage = imresize(testImage, [224, 224]);
[predictedClass, scores] = classify(net, testImage);
```

## Validation

To validate the implementation:
```matlab
validate_executar_classificacao()
```

This runs 12 comprehensive tests covering:
- Script existence
- Helper functions
- Path detection
- Progress reporting
- Error handling
- Logging
- Phase implementation
- Graceful degradation
- Configuration integration
- Summary generation
- Component integration
- Timing tracking

## Future Enhancements

Planned improvements:
1. Parallel model training
2. Distributed training support
3. Hyperparameter optimization
4. Real-time progress dashboard
5. Email notifications on completion
6. Cloud storage integration
7. Automated model selection

## Support

For issues or questions:
1. Check log file in `output/classification/logs/`
2. Review this guide
3. Run validation script
4. Check component-specific guides in `src/classification/`

## References

- Requirements: `.kiro/specs/corrosion-classification-system/requirements.md`
- Design: `.kiro/specs/corrosion-classification-system/design.md`
- Tasks: `.kiro/specs/corrosion-classification-system/tasks.md`
- Component guides: `src/classification/*_GUIDE.md`
