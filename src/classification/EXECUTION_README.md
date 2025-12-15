# Classification System Execution

## Quick Links

- **Quick Start**: [QUICK_START.md](QUICK_START.md) - Get started in 5 minutes
- **Main Execution Guide**: [MAIN_EXECUTION_GUIDE.md](MAIN_EXECUTION_GUIDE.md) - Complete reference
- **Component Guides**: See individual `*_GUIDE.md` files for each component

## What is executar_classificacao.m?

The main execution script that runs the complete classification workflow:

1. **Load Configuration** - Set up paths and parameters
2. **Generate Labels** - Convert masks to severity labels
3. **Prepare Datasets** - Create train/val/test splits
4. **Train Models** - Train all configured architectures
5. **Evaluate Models** - Compute comprehensive metrics
6. **Generate Visualizations** - Create figures and LaTeX tables
7. **Create Summary** - Generate final report

## One-Command Execution

```matlab
executar_classificacao()
```

That's it! Everything else is automatic.

## What You Get

After execution completes (~2 hours with GPU):

### Results Summary
```
output/classification/results/execution_summary_YYYYMMDD_HHMMSS.txt
```

### Trained Models
```
output/classification/checkpoints/
├── ResNet50_best.mat
├── EfficientNetB0_best.mat
└── CustomCNN_best.mat
```

### Visualizations
```
output/classification/figures/
├── confusion_matrix_*.png/pdf
├── training_curves_comparison.png/pdf
├── roc_curves_*.png/pdf
└── inference_time_comparison.png/pdf
```

### LaTeX Tables
```
output/classification/latex/
├── metrics_comparison_table.tex
├── confusion_matrix_*.tex
└── results_summary.tex
```

### Execution Log
```
output/classification/logs/classification_execution_YYYYMMDD_HHMMSS.txt
```

## Customization

### Fast Prototyping (15 minutes)
```matlab
config = ClassificationConfig();
config.training.maxEpochs = 10;
config.models.architectures = {'CustomCNN'};
executar_classificacao();
```

### Production Run (2 hours)
```matlab
config = ClassificationConfig();
config.training.maxEpochs = 100;
config.models.architectures = {'ResNet50', 'EfficientNetB0', 'CustomCNN'};
executar_classificacao();
```

### Custom Configuration
```matlab
config = ClassificationConfig();
config.paths.imageDir = 'custom/path/images';
config.labelGeneration.thresholds = [15, 35];
config.dataset.splitRatios = [0.8, 0.1, 0.1];
config.training.miniBatchSize = 64;
config.saveToFile('my_config.mat');
executar_classificacao('my_config.mat');
```

## Features

### ✅ Automatic Path Detection
Searches multiple locations for images and masks:
- `img/original`, `img/masks`
- `data/images`, `data/masks`
- `images`, `masks`

### ✅ Progress Reporting
Real-time progress with timing:
```
[Phase 4/7] Training Models...
----------------------------------------
--- Training Model 1/3: ResNet50 ---
✓ ResNet50 training completed (2456.78 seconds)
```

### ✅ Error Handling
Graceful degradation - continues with remaining models if one fails:
```
✗ EfficientNetB0 training failed: Out of memory
  Continuing with remaining models...
```

### ✅ Comprehensive Logging
Timestamped log files with all details:
- Configuration parameters
- Training progress
- Evaluation metrics
- Error messages with stack traces

### ✅ Final Results Summary
Console table with best models highlighted:
```
Model                Accuracy   Macro F1   Mean AUC  Inf. Time
ResNet50              92.34%     0.9156     0.9523      12.45 ms
EfficientNetB0        91.87%     0.9089     0.9487      10.23 ms
CustomCNN             89.45%     0.8834     0.9201       8.67 ms

Best Accuracy:      ResNet50 (92.34%)
Best F1 Score:      ResNet50 (0.9156)
Fastest Inference:  CustomCNN (8.67 ms)
```

## Validation

Verify the implementation:
```matlab
validate_executar_classificacao()
```

Runs 12 comprehensive tests:
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

## Troubleshooting

### Common Issues

**"Image directory not found"**
- Check that images exist in `img/original` or configure custom path

**"Out of memory during training"**
- Reduce `miniBatchSize` (e.g., from 32 to 16)
- Use smaller model (`CustomCNN`)
- Close other GPU applications

**"All models failed to train"**
- Check log file for detailed errors
- Verify GPU availability: `gpuDevice()`
- Ensure Deep Learning Toolbox is installed

### Debug Mode
```matlab
errorHandler = ErrorHandler.getInstance();
errorHandler.setLogLevel('DEBUG');
executar_classificacao();
```

## Performance

### Typical Execution Time (with GPU)
- Label generation: 1-2 minutes
- Dataset preparation: 30 seconds
- Training (3 models): 1.5-2 hours
- Evaluation: 5-10 minutes
- Visualization: 1-2 minutes
- **Total: ~2-2.5 hours**

### Resource Requirements
- **GPU**: NVIDIA GPU with 8GB+ memory (recommended)
- **Disk**: 2GB free space
- **RAM**: 16GB+ recommended

## Using Trained Models

### Single Image Classification
```matlab
% Load best model
load('output/classification/checkpoints/ResNet50_best.mat', 'net');

% Classify image
img = imread('test_image.jpg');
img = imresize(img, [224, 224]);
[pred, scores] = classify(net, img);

% Display result
classNames = {'None/Light', 'Moderate', 'Severe'};
fprintf('Prediction: %s (%.1f%% confidence)\n', ...
    classNames{double(pred)+1}, max(scores)*100);
```

### Batch Classification
```matlab
% Load model
load('output/classification/checkpoints/ResNet50_best.mat', 'net');

% Create datastore
imds = imageDatastore('path/to/images');
imds.ReadFcn = @(f) imresize(imread(f), [224, 224]);

% Classify all
predictions = classify(net, imds);
```

## Integration with Research Article

### LaTeX Tables
Copy from `output/classification/latex/`:
- `metrics_comparison_table.tex` - Model comparison
- `confusion_matrix_*.tex` - Confusion matrices
- `results_summary.tex` - Complete results section

### Figures
Copy from `output/classification/figures/`:
- All figures available in PNG (300 DPI) and PDF (vector)
- Ready for publication

### Results Text
Use summary report:
- `execution_summary_*.txt` - Complete results description
- Best model identification
- Performance metrics

## Documentation Structure

```
src/classification/
├── EXECUTION_README.md          # This file - execution overview
├── QUICK_START.md               # 5-minute quick start guide
├── MAIN_EXECUTION_GUIDE.md      # Complete execution reference
├── LABEL_GENERATION_GUIDE.md    # Label generation details
├── DATASET_MANAGER_GUIDE.md     # Dataset preparation details
├── MODEL_FACTORY_GUIDE.md       # Model architecture details
├── TRAINING_ENGINE_GUIDE.md     # Training process details
├── EVALUATION_ENGINE_GUIDE.md   # Evaluation metrics details
├── VISUALIZATION_ENGINE_GUIDE.md # Visualization details
└── MODEL_COMPARISON_GUIDE.md    # Model comparison details
```

## Support

1. **Check Documentation**: Start with [QUICK_START.md](QUICK_START.md)
2. **Review Log File**: `output/classification/logs/classification_execution_*.txt`
3. **Run Validation**: `validate_executar_classificacao()`
4. **Check Component Guides**: See individual `*_GUIDE.md` files

## Requirements Addressed

This implementation addresses all requirements from the specification:

- **8.1**: Complete workflow execution ✅
- **8.2**: Automatic path detection ✅
- **8.3**: Progress reporting ✅
- **8.4**: Error handling ✅
- **8.5**: Execution logging ✅

Plus integration with all components:
- **7.1**: ErrorHandler integration ✅
- **7.2**: VisualizationHelper integration ✅
- **7.3**: DataTypeConverter integration ✅
- **7.4**: Configuration management ✅

## Example Workflow

```matlab
%% Complete workflow example

% 1. Validate setup
validate_setup

% 2. Run classification system
executar_classificacao()

% 3. Review results
edit output/classification/results/execution_summary_*.txt

% 4. View visualizations
imshow('output/classification/figures/confusion_matrix_ResNet50.png')

% 5. Load best model
load('output/classification/checkpoints/ResNet50_best.mat', 'net');

% 6. Test on new image
testImg = imread('new_image.jpg');
testImg = imresize(testImg, [224, 224]);
[pred, scores] = classify(net, testImg);
fprintf('Prediction: %s\n', char(pred));
```

## Ready to Start?

```matlab
% Just run this:
executar_classificacao()

% Then wait ~2 hours for results
% Everything is automatic!
```

## What's Next?

After successful execution:
1. Review accuracy and metrics
2. Analyze confusion matrices
3. Compare model performance
4. Select best model
5. Integrate into research article
6. Deploy for production use

---

**Need help?** Check [QUICK_START.md](QUICK_START.md) or [MAIN_EXECUTION_GUIDE.md](MAIN_EXECUTION_GUIDE.md)

**Ready to go?** Just run `executar_classificacao()` 🚀
