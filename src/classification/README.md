# Corrosion Classification System

## Overview

The Corrosion Classification System is a deep learning-based solution for automated severity assessment of corrosion in ASTM A572 Grade 50 steel structures. This system complements the existing segmentation pipeline by providing rapid triage capabilities through image-level severity classification.

### Key Features

- **Automated Label Generation**: Convert segmentation masks to severity labels based on corroded area percentage
- **Multiple CNN Architectures**: ResNet50, EfficientNet-B0, and Custom CNN implementations
- **Transfer Learning**: Leverage pre-trained ImageNet weights for improved performance
- **Comprehensive Evaluation**: Accuracy, precision, recall, F1-score, ROC curves, and confusion matrices
- **Publication-Ready Outputs**: High-resolution figures (PNG 300 DPI + PDF) and LaTeX-formatted tables
- **Integrated Infrastructure**: Reuses existing ErrorHandler, VisualizationHelper, and DataTypeConverter
- **Automated Pipeline**: Single-command execution from data preparation to final results
- **Graceful Error Handling**: Continues execution even if individual models fail

## Implementation Status

✅ **Task 1: Setup project structure and configuration system** - COMPLETE
✅ **Task 2: Implement label generation system** - COMPLETE
✅ **Task 3: Implement dataset management system** - COMPLETE
✅ **Task 4: Implement model architectures** - COMPLETE
✅ **Task 5: Implement training pipeline** - COMPLETE
✅ **Task 6: Implement evaluation system** - COMPLETE
✅ **Task 7: Implement visualization and export system** - COMPLETE
✅ **Task 8: Implement model comparison and benchmarking** - COMPLETE
✅ **Task 9: Create main execution script** - COMPLETE
⏳ **Task 10: Create documentation and examples** - IN PROGRESS
⏳ **Task 11: End-to-end integration and testing** - PENDING
⏳ **Task 12: Final validation and documentation** - PENDING

## Directory Structure

```
src/classification/
├── core/                           # Core classification components
│   ├── LabelGenerator.m            # ✅ Converts masks to severity labels
│   ├── DatasetManager.m            # ✅ Dataset loading and splitting
│   ├── ModelFactory.m              # ✅ Creates CNN architectures
│   ├── TrainingEngine.m            # ✅ Training loop and checkpointing
│   ├── EvaluationEngine.m          # ✅ Metrics computation
│   ├── VisualizationEngine.m       # ✅ Figure generation
│   ├── ModelComparator.m           # ✅ Model comparison utilities
│   ├── SegmentationComparator.m    # ✅ Segmentation vs classification
│   └── ErrorAnalyzer.m             # ✅ Error analysis utilities
├── models/                         # Model architecture implementations
│   └── (Generated dynamically)     # Models created by ModelFactory
├── utils/                          # Utility classes
│   ├── ClassificationConfig.m      # ✅ Configuration management
│   └── DatasetValidator.m          # ✅ Dataset validation
├── README.md                       # This file (main documentation)
├── QUICK_START.md                  # Quick start guide
├── MAIN_EXECUTION_GUIDE.md         # Detailed execution guide
├── *_GUIDE.md                      # Component-specific guides
└── validate_setup.m                # Setup validation script

output/classification/
├── labels.csv                      # Generated severity labels
├── checkpoints/                    # Saved model checkpoints
│   ├── ResNet50_best.mat
│   ├── EfficientNetB0_best.mat
│   └── CustomCNN_best.mat
├── results/                        # Evaluation results
│   ├── *_evaluation_report.mat
│   └── execution_summary_*.txt
├── figures/                        # Generated visualizations
│   ├── confusion_matrix_*.png/pdf
│   ├── training_curves_comparison.png/pdf
│   ├── roc_curves_*.png/pdf
│   └── inference_time_comparison.png/pdf
├── latex/                          # LaTeX tables and documents
│   ├── metrics_comparison_table.tex
│   ├── confusion_matrix_*.tex
│   └── results_summary.tex
└── logs/                           # Execution logs
    └── classification_execution_*.txt

tests/
├── unit/                           # Unit tests
│   ├── test_LabelGenerator.m
│   ├── test_DatasetManager.m
│   ├── test_ModelFactory.m
│   └── test_EvaluationEngine.m
└── integration/                    # Integration tests
    ├── test_TrainingEngine.m
    └── test_VisualizationEngine.m

Root scripts:
├── executar_classificacao.m        # ✅ Main execution script
├── gerar_labels_classificacao.m    # ✅ Label generation script
└── validate_*.m                    # ✅ Validation scripts
```

## Quick Start

### Prerequisites

1. **MATLAB** R2020b or later
2. **Required Toolboxes**:
   - Deep Learning Toolbox
   - Image Processing Toolbox
   - Statistics and Machine Learning Toolbox
   - Computer Vision Toolbox
3. **GPU** (recommended): NVIDIA GPU with CUDA support
4. **Dataset**: Segmentation images and masks in `img/original` and `img/masks`

### 5-Minute Quick Start

```matlab
% 1. Verify setup
cd src/classification
validate_setup

% 2. Run complete pipeline (uses default configuration)
executar_classificacao()

% That's it! Results will be in output/classification/
```

**Expected time**: 1.5-2.5 hours (with GPU)

### Fast Prototyping (15 minutes)

For quick testing with reduced training time:

```matlab
% Create fast configuration
config = ClassificationConfig();
config.training.maxEpochs = 10;  % Reduce from 50 to 10
config.models.architectures = {'CustomCNN'};  % Only lightweight model
config.saveToFile('fast_config.mat');

% Run with fast configuration
executar_classificacao('fast_config.mat');
```

### Detailed Guides

- **Quick Start**: See `QUICK_START.md` for detailed quick start guide
- **Main Execution**: See `MAIN_EXECUTION_GUIDE.md` for complete workflow documentation
- **Component Guides**: See `*_GUIDE.md` files for specific component documentation

## Configuration Options

### Path Configuration
- `imageDir`: Directory containing RGB images
- `maskDir`: Directory containing binary masks
- `outputDir`: Base output directory
- `checkpointDir`: Model checkpoint directory
- `resultsDir`: Evaluation results directory
- `figuresDir`: Generated figures directory
- `latexDir`: LaTeX tables directory
- `logsDir`: Execution logs directory

### Label Generation
- `thresholds`: [10, 30] - Percentage thresholds for class boundaries
- `classNames`: {'None/Light', 'Moderate', 'Severe'}
- `numClasses`: 3

### Dataset Configuration
- `splitRatios`: [0.7, 0.15, 0.15] - Train/validation/test split
- `inputSize`: [224, 224] - Input image dimensions
- `augmentation`: true - Enable data augmentation
- `seed`: 42 - Random seed for reproducibility

### Training Configuration
- `maxEpochs`: 50 - Maximum training epochs
- `miniBatchSize`: 32 - Batch size for training
- `initialLearnRate`: 1e-4 - Initial learning rate
- `validationPatience`: 10 - Early stopping patience
- `executionEnvironment`: 'auto' - Use GPU if available

### Model Configuration
- `architectures`: {'ResNet50', 'EfficientNetB0', 'CustomCNN'}
- `transferLearning`: true - Use pre-trained weights
- `freezeEarlyLayers`: true - Freeze early layers during training

### Evaluation Configuration
- `generateROC`: true - Generate ROC curves
- `generateConfusionMatrix`: true - Generate confusion matrices
- `measureInferenceTime`: true - Measure inference speed
- `numInferenceSamples`: 100 - Samples for speed measurement

## Severity Classes

The system classifies corrosion into three severity levels based on corroded area percentage:

| Class | Label | Corroded Area | Description |
|-------|-------|---------------|-------------|
| 0 | None/Light | < 10% | Minimal or no visible corrosion |
| 1 | Moderate | 10% - 30% | Moderate corrosion requiring attention |
| 2 | Severe | > 30% | Severe corrosion requiring immediate action |

## Output Structure

After execution, the following files are generated:

### Labels
```
output/classification/labels.csv
```
CSV file with columns: `filename`, `corroded_percentage`, `severity_class`

### Model Checkpoints
```
output/classification/checkpoints/
├── ResNet50_best.mat              # Best model based on validation accuracy
├── ResNet50_last.mat              # Model from last training epoch
├── EfficientNetB0_best.mat
├── EfficientNetB0_last.mat
├── CustomCNN_best.mat
└── CustomCNN_last.mat
```

### Evaluation Results
```
output/classification/results/
├── ResNet50_evaluation_report.mat      # Complete metrics and confusion matrix
├── ResNet50_training_history.mat       # Training/validation loss and accuracy
├── EfficientNetB0_evaluation_report.mat
├── EfficientNetB0_training_history.mat
├── CustomCNN_evaluation_report.mat
├── CustomCNN_training_history.mat
└── execution_summary_YYYYMMDD_HHMMSS.txt  # Final summary report
```

### Figures (PNG 300 DPI + PDF vector)
```
output/classification/figures/
├── confusion_matrix_ResNet50.png          # Confusion matrix heatmap
├── confusion_matrix_ResNet50.pdf
├── confusion_matrix_EfficientNetB0.png
├── confusion_matrix_EfficientNetB0.pdf
├── confusion_matrix_CustomCNN.png
├── confusion_matrix_CustomCNN.pdf
├── training_curves_comparison.png         # All models training curves
├── training_curves_comparison.pdf
├── roc_curves_ResNet50.png                # ROC curves with AUC
├── roc_curves_ResNet50.pdf
├── roc_curves_EfficientNetB0.png
├── roc_curves_EfficientNetB0.pdf
├── roc_curves_CustomCNN.png
├── roc_curves_CustomCNN.pdf
├── inference_time_comparison.png          # Speed comparison bar chart
└── inference_time_comparison.pdf
```

### LaTeX Tables
```
output/classification/latex/
├── metrics_comparison_table.tex           # Model comparison table
├── confusion_matrix_ResNet50.tex          # Confusion matrix in LaTeX
├── confusion_matrix_EfficientNetB0.tex
├── confusion_matrix_CustomCNN.tex
└── results_summary.tex                    # Complete results document
```

### Execution Logs
```
output/classification/logs/
└── classification_execution_YYYYMMDD_HHMMSS.txt  # Detailed execution log
```

Each output file is timestamped and includes complete metadata for reproducibility.

## Requirements

### MATLAB Toolboxes
- Deep Learning Toolbox
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox
- Computer Vision Toolbox (for pre-trained models)

### Dependencies
- `src/utils/ErrorHandler.m`
- `src/utils/VisualizationHelper.m`
- `src/utils/DataTypeConverter.m`
- `src/validation/PreprocessingValidator.m`

## Testing

Run the configuration test:

```matlab
run('test_classification_config.m');
```

## Performance Targets

### Inference Speed
- ResNet50: < 50ms per image
- EfficientNet-B0: < 30ms per image
- Custom CNN: < 20ms per image

### Memory Usage
- Training: < 8GB GPU memory
- Inference: < 2GB GPU memory

### Accuracy
- Target: > 90% overall accuracy
- Target: > 0.85 F1-score per class

## Usage Examples

### Example 1: Basic Usage with Default Settings

```matlab
% Run with all defaults
executar_classificacao()
```

### Example 2: Custom Configuration

```matlab
% Create and customize configuration
config = ClassificationConfig();
config.training.maxEpochs = 30;
config.models.architectures = {'ResNet50', 'CustomCNN'};
config.saveToFile('my_config.mat');

% Run with custom configuration
executar_classificacao('my_config.mat');
```

### Example 3: Using Trained Model for Inference

```matlab
% Load best model
load('output/classification/checkpoints/ResNet50_best.mat', 'net');

% Classify new image
testImage = imread('new_corrosion_image.jpg');
testImage = imresize(testImage, [224, 224]);
[predictedClass, scores] = classify(net, testImage);

% Display result
classNames = {'None/Light', 'Moderate', 'Severe'};
fprintf('Predicted: %s (%.1f%% confidence)\n', ...
    classNames{double(predictedClass)+1}, max(scores)*100);
```

### Example 4: Batch Inference

```matlab
% Load model
load('output/classification/checkpoints/ResNet50_best.mat', 'net');

% Create datastore for new images
imds = imageDatastore('path/to/new/images');
imds.ReadFcn = @(filename) imresize(imread(filename), [224, 224]);

% Classify all images
predictions = classify(net, imds);

% Display results
for i = 1:length(predictions)
    fprintf('%s: %s\n', imds.Files{i}, char(predictions(i)));
end
```

### Example 5: Custom Label Thresholds

```matlab
% Change severity thresholds
config = ClassificationConfig();
config.labelGeneration.thresholds = [15, 35];  % Default: [10, 30]
executar_classificacao();
```

## Troubleshooting

### Common Issues

1. **Out of Memory Error**
   - Reduce `miniBatchSize` in training configuration (e.g., from 32 to 16)
   - Use smaller model (CustomCNN instead of ResNet50)
   - Close other GPU applications
   - Use smaller input size (e.g., [224, 224] instead of [299, 299])

2. **Slow Training**
   - Ensure GPU is being used: check with `gpuDevice()`
   - Set `executionEnvironment: 'gpu'` in configuration
   - Reduce number of augmentation operations
   - Use parallel data loading

3. **Poor Performance**
   - Increase training epochs (e.g., from 50 to 100)
   - Adjust learning rate (try 5e-5 or 2e-4)
   - Enable more data augmentation
   - Try different model architectures
   - Check for class imbalance in dataset

4. **Class Imbalance**
   - System uses stratified sampling automatically
   - Check dataset statistics in execution log
   - Consider collecting more data for minority classes
   - Future: Use weighted loss functions

5. **GPU Not Detected**
   - Check GPU availability: `gpuDevice()`
   - Install CUDA drivers if needed
   - Training will use CPU (much slower) if GPU unavailable

6. **Dataset Not Found**
   - Verify images exist: `ls img/original`
   - Verify masks exist: `ls img/masks`
   - Or specify custom paths in configuration

### Getting Help

1. **Check log files**: `output/classification/logs/classification_execution_*.txt`
2. **Run validation scripts**: `validate_executar_classificacao()`, `validate_model_factory()`, etc.
3. **Review component guides**: See `*_GUIDE.md` files in `src/classification/`
4. **Check requirements**: `.kiro/specs/corrosion-classification-system/requirements.md`
5. **Review design**: `.kiro/specs/corrosion-classification-system/design.md`

## References

- Requirements: `.kiro/specs/corrosion-classification-system/requirements.md`
- Design: `.kiro/specs/corrosion-classification-system/design.md`
- Tasks: `.kiro/specs/corrosion-classification-system/tasks.md`

## License

This code is part of the ASTM A572 Grade 50 corrosion detection research project.

## Contact

For questions or issues, please refer to the main project documentation.
