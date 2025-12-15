# System Architecture Documentation

**Corrosion Analysis System - Complete Architecture**

## Overview

This document provides a comprehensive overview of the complete corrosion analysis system architecture, including both segmentation and classification components.

## System Components

### 1. Segmentation System

**Purpose:** Pixel-level corrosion detection and localization

**Architecture:**
- U-Net: Classic encoder-decoder with skip connections
- Attention U-Net: Enhanced with attention gates for improved focus

**Key Components:**
- `src/models/`: Model architectures
- `src/treinamento/`: Training pipelines
- `src/segmentacao/`: Inference engines
- `src/evaluation/`: Metrics computation

**Outputs:**
- Binary segmentation masks
- Pixel-level accuracy metrics (IoU, Dice)
- Attention maps (for Attention U-Net)

### 2. Classification System

**Purpose:** Image-level severity assessment for rapid triage

**Architecture:**
- ResNet50: Deep residual network with transfer learning
- EfficientNet-B0: Efficient architecture with compound scaling
- Custom CNN: Lightweight network optimized for task

**Key Components:**
- `src/classification/core/LabelGenerator.m`: Label generation
- `src/classification/core/DatasetManager.m`: Dataset management
- `src/classification/core/ModelFactory.m`: Model creation
- `src/classification/core/TrainingEngine.m`: Training pipeline
- `src/classification/core/EvaluationEngine.m`: Evaluation
- `src/classification/core/VisualizationEngine.m`: Visualization

**Outputs:**
- Severity classifications (None/Light, Moderate, Severe)
- Classification metrics (Accuracy, F1, AUC)
- Confusion matrices and ROC curves

### 3. Shared Infrastructure

**Purpose:** Common utilities and services used by both systems

**Components:**

#### Error Handling
- `src/utils/ErrorHandler.m`: Centralized error logging
- Timestamped logs
- Severity categorization (INFO, WARNING, ERROR)
- Automatic log file management

#### Visualization
- `src/utils/VisualizationHelper.m`: Data preparation for plotting
- Consistent plotting styles
- Automatic figure export
- Publication-quality outputs

#### Data Management
- `src/data/`: Data loading and preprocessing
- `src/utils/DataTypeConverter.m`: Type conversions
- `src/validation/`: Data validation utilities

#### Configuration
- `src/classification/utils/ClassificationConfig.m`: Classification config
- Centralized parameter management
- Easy configuration switching

## Data Flow

### Segmentation Pipeline

```
Input Images → Preprocessing → U-Net/Attention U-Net → Binary Masks → Evaluation
                                                              ↓
                                                        Visualization
```

### Classification Pipeline

```
Binary Masks → Label Generation → Dataset Preparation → Model Training → Evaluation
                                                              ↓
                                                        Visualization
```

### Integrated Workflow

```
Input Images → Segmentation → Binary Masks → Classification → Severity Labels
                    ↓                              ↓
              Detailed Analysis            Rapid Triage
```

## Directory Structure

```
project_root/
├── src/
│   ├── classification/          # Classification system
│   │   ├── core/               # Core components
│   │   └── utils/              # Classification utilities
│   ├── models/                 # Segmentation models
│   ├── treinamento/            # Training pipelines
│   ├── segmentacao/            # Segmentation inference
│   ├── evaluation/             # Metrics and analysis
│   ├── visualization/          # Visualization tools
│   ├── data/                   # Data management
│   ├── utils/                  # Shared utilities
│   └── validation/             # Validation tools
├── tests/
│   ├── unit/                   # Unit tests
│   └── integration/            # Integration tests
├── output/
│   ├── classification/         # Classification outputs
│   └── segmentation/           # Segmentation outputs
├── img/
│   ├── original/               # Input images
│   └── masks/                  # Ground truth masks
├── docs/                       # Documentation
├── .kiro/
│   └── specs/                  # Specification documents
└── scripts/                    # Utility scripts
```

## Module Dependencies

### Classification System Dependencies

```
ClassificationConfig
        ↓
LabelGenerator → ErrorHandler
        ↓
DatasetManager → DatasetValidator
        ↓
ModelFactory
        ↓
TrainingEngine → ErrorHandler
        ↓
EvaluationEngine → ErrorHandler
        ↓
VisualizationEngine → VisualizationHelper
        ↓
ModelComparator
```

### Segmentation System Dependencies

```
ConfigurationManager
        ↓
DataLoader → PreprocessingValidator
        ↓
ModelArchitecture
        ↓
TrainingPipeline → ErrorHandler
        ↓
SegmentationEngine
        ↓
EvaluationMetrics
        ↓
VisualizationHelper
```

## Design Patterns

### 1. Factory Pattern
- **ModelFactory:** Creates different model architectures
- **Purpose:** Encapsulate model creation logic
- **Benefit:** Easy to add new architectures

### 2. Singleton Pattern
- **ErrorHandler:** Single instance for logging
- **Purpose:** Centralized error management
- **Benefit:** Consistent logging across system

### 3. Strategy Pattern
- **EvaluationEngine:** Different evaluation strategies
- **Purpose:** Flexible metric computation
- **Benefit:** Easy to add new metrics

### 4. Template Method Pattern
- **TrainingEngine:** Common training workflow
- **Purpose:** Standardize training process
- **Benefit:** Consistent training across models

## Configuration Management

### Classification Configuration

```matlab
config = ClassificationConfig();

% Paths
config.paths.imageDir = 'img/original';
config.paths.maskDir = 'img/masks';
config.paths.outputDir = 'output/classification';

% Label generation
config.labelGeneration.thresholds = [10, 30];
config.labelGeneration.numClasses = 3;

% Dataset
config.dataset.splitRatios = [0.7, 0.15, 0.15];
config.dataset.inputSize = [224, 224];
config.dataset.augmentation = true;

% Training
config.training.maxEpochs = 50;
config.training.miniBatchSize = 32;
config.training.initialLearnRate = 1e-4;

% Models
config.models.architectures = {'ResNet50', 'EfficientNetB0', 'CustomCNN'};
```

### Segmentation Configuration

```matlab
% Similar structure for segmentation
config.model = 'AttentionUNet';
config.inputSize = [256, 256];
config.batchSize = 8;
config.epochs = 100;
```

## Error Handling Strategy

### Levels

1. **INFO:** Normal operation logging
2. **WARNING:** Non-critical issues
3. **ERROR:** Critical failures

### Handling

```matlab
try
    % Operation
    result = performOperation();
    errorHandler.logInfo('Module', 'Operation successful');
catch ME
    errorHandler.logError('Module', ME.message);
    % Fallback or rethrow
end
```

### Logging

- Timestamped entries
- Module identification
- Stack trace for errors
- Automatic log file creation

## Performance Considerations

### Memory Management

- Mini-batch processing
- Gradient checkpointing
- Clear intermediate variables
- Single precision (float32)

### Speed Optimization

- GPU acceleration
- Parallel data loading
- Cached preprocessing
- Compiled MEX functions

### Scalability

- Configurable batch sizes
- Distributed training support (future)
- Efficient data pipelines
- Modular architecture

## Testing Strategy

### Unit Tests

- Individual component testing
- Mock data for isolation
- Edge case coverage
- Automated test execution

### Integration Tests

- End-to-end pipeline testing
- Component interaction verification
- Real data testing
- Performance benchmarking

### Validation Tests

- Requirements verification
- Output format validation
- Scientific soundness checks
- Regression testing

## Deployment Considerations

### Segmentation System

- **Environment:** Workstation with GPU
- **Memory:** 8GB GPU minimum
- **Inference Time:** 200-500ms per image
- **Use Case:** Detailed analysis

### Classification System

- **Environment:** Workstation or edge device
- **Memory:** 2GB GPU minimum
- **Inference Time:** 20-50ms per image
- **Use Case:** Rapid triage

### Integration

- Both systems can run independently
- Classification can use segmentation outputs
- Shared infrastructure reduces overhead
- Consistent API for both systems

## Future Enhancements

### Planned Features

1. **Ensemble Methods:** Combine multiple models
2. **Active Learning:** Identify uncertain samples
3. **Explainability:** Grad-CAM visualizations
4. **Real-time Processing:** Optimized inference
5. **Multi-label Classification:** Type + severity
6. **Web Interface:** Browser-based deployment

### Architecture Evolution

1. **Microservices:** Separate services for each component
2. **REST API:** HTTP interface for integration
3. **Cloud Deployment:** Scalable cloud infrastructure
4. **Mobile Support:** On-device inference

## Maintenance Guide

### Code Organization

- Keep modules independent
- Document all public interfaces
- Use consistent naming conventions
- Maintain test coverage

### Version Control

- Semantic versioning (MAJOR.MINOR.PATCH)
- Tag releases
- Document breaking changes
- Maintain changelog

### Documentation

- Update README for new features
- Document API changes
- Provide usage examples
- Include troubleshooting guides

### Testing

- Run tests before commits
- Maintain test coverage >80%
- Add tests for new features
- Update tests for bug fixes

## System Integration Patterns

### Workflow 1: Segmentation-Only

```
Input Images → Segmentation Model → Binary Masks → Metrics → Visualization
```

**Use Case:** Detailed analysis requiring pixel-level precision

### Workflow 2: Classification-Only

```
Input Images → Classification Model → Severity Labels → Metrics → Visualization
```

**Use Case:** Rapid triage of large image sets

### Workflow 3: Integrated Pipeline

```
Input Images → Classification (Triage) → High-Risk Images → Segmentation (Detail) → Complete Report
```

**Use Case:** Efficient inspection workflow with detailed analysis of critical cases

### Workflow 4: Label Generation

```
Segmentation Masks → Label Generator → Severity Labels → Classification Training
```

**Use Case:** Leveraging existing segmentation data for classification

## API Reference

### Classification System API

#### LabelGenerator

```matlab
% Generate labels from masks
labels = LabelGenerator.generateLabelsFromMasks(maskDir, outputCSV, thresholds);

% Compute corroded percentage
percentage = LabelGenerator.computeCorrodedPercentage(mask);

% Assign severity class
class = LabelGenerator.assignSeverityClass(percentage, thresholds);
```

#### DatasetManager

```matlab
% Create dataset manager
manager = DatasetManager(imageDir, labelCSV, config, errorHandler);

% Prepare datasets
[trainDS, valDS, testDS] = manager.prepareDatasets();

% Get statistics
stats = manager.getDatasetStatistics();

% Apply augmentation
augDS = manager.applyAugmentation(datastore);
```

#### ModelFactory

```matlab
% Create models
net = ModelFactory.createResNet50(numClasses, inputSize);
net = ModelFactory.createEfficientNetB0(numClasses, inputSize);
net = ModelFactory.createCustomCNN(numClasses, inputSize);
```

#### TrainingEngine

```matlab
% Create training engine
trainer = TrainingEngine(model, config, errorHandler);

% Train model
[trainedNet, history] = trainer.train(trainDS, valDS);

% Plot training history
trainer.plotTrainingHistory(history, outputPath);
```

#### EvaluationEngine

```matlab
% Create evaluation engine
evaluator = EvaluationEngine(model, testDS, classNames, errorHandler);

% Compute metrics
metrics = evaluator.computeMetrics();

% Generate confusion matrix
confMat = evaluator.generateConfusionMatrix();

% Compute ROC curves
[fpr, tpr, auc] = evaluator.computeROC();

% Measure inference speed
inferenceTime = evaluator.measureInferenceSpeed(numSamples);

% Generate complete report
report = evaluator.generateEvaluationReport(modelName, outputDir);
```

#### VisualizationEngine

```matlab
% Plot confusion matrix
VisualizationEngine.plotConfusionMatrix(confMat, classNames, filename);

% Plot training curves
VisualizationEngine.plotTrainingCurves(histories, modelNames, filename);

% Plot ROC curves
VisualizationEngine.plotROCCurves(rocData, classNames, filename);

% Plot inference comparison
VisualizationEngine.plotInferenceComparison(times, modelNames, filename);

% Generate LaTeX table
VisualizationEngine.generateLatexTable(metrics, filename);
```

## Security Considerations

### Data Privacy

- No data is transmitted externally
- All processing is local
- Sensitive images remain on-premises
- Access control through file system permissions

### Model Security

- Models trained on proprietary data
- Checkpoints stored securely
- No external model downloads during inference
- Version control for model tracking

### Input Validation

- Image format validation
- Size and dimension checks
- Mask binary value verification
- Label format validation

## Scalability Considerations

### Current Limitations

- Single GPU training
- Local file system storage
- Sequential model training
- Limited to available RAM

### Scaling Strategies

**Horizontal Scaling:**
- Distribute inference across multiple GPUs
- Parallel model training
- Batch processing of large datasets

**Vertical Scaling:**
- Larger GPU memory
- More CPU cores for data loading
- Faster storage (SSD/NVMe)

**Cloud Scaling:**
- AWS/Azure/GCP deployment
- Auto-scaling based on load
- Distributed training
- Object storage for datasets

## Monitoring and Observability

### Current Monitoring

- ErrorHandler logging
- Training progress plots
- Execution time tracking
- Memory usage monitoring

### Enhanced Monitoring (Future)

- Real-time dashboards
- Performance metrics tracking
- Model drift detection
- Automated alerting

## Compliance and Standards

### Code Quality

- MATLAB best practices
- Consistent naming conventions
- Comprehensive documentation
- Test coverage >80%

### Scientific Standards

- Reproducible results
- Documented methodology
- Peer-reviewed algorithms
- Open science principles

### Industry Standards

- ASTM corrosion standards
- Image quality standards
- Safety inspection protocols

## Contact and Support

### Documentation Resources

- **Main README:** `README.md`
- **User Guides:** `src/classification/USER_GUIDE.md`, `docs/user_guide.md`
- **API Reference:** This document
- **Maintenance:** `MAINTENANCE_GUIDE.md`
- **Future Plans:** `FUTURE_ENHANCEMENTS.md`

### Getting Help

1. **Check Documentation:** Start with relevant user guide
2. **Search Issues:** Look for similar problems
3. **Run Diagnostics:** Use validation scripts
4. **Contact Support:** Create issue with details

### Contributing

- Follow code style guidelines
- Write tests for new features
- Update documentation
- Submit pull requests

### Author

**Heitor Oliveira Gonçalves**
- LinkedIn: [linkedin.com/in/heitorhog](https://www.linkedin.com/in/heitorhog/)

---

*This document was created as part of Task 12.4: Write final project documentation*
*Date: 2025-10-23*
*Version: 1.1*
*Last Updated: 2025-10-23*
