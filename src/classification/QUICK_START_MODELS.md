# Quick Start: Model Architectures

## Creating Models

### ResNet50 (Best Accuracy)
```matlab
addpath('src/classification/core');
lgraph = ModelFactory.createResNet50(3, [224, 224, 3]);
```

### EfficientNet-B0 (Balanced)
```matlab
lgraph = ModelFactory.createEfficientNetB0(3, [224, 224, 3]);
```

### Custom CNN (Fastest)
```matlab
lgraph = ModelFactory.createCustomCNN(3, [224, 224, 3]);
```

## Transfer Learning

```matlab
% Create model
lgraph = ModelFactory.createResNet50(3, [224, 224, 3]);

% Configure transfer learning (freeze early layers, fine-tune last 10)
lgraph = ModelFactory.configureTransferLearning(lgraph, 10);
```

## Validation

```matlab
% Quick validation
validate_model_factory

% Full unit tests
run('tests/unit/test_ModelFactory.m')
```

## Model Selection Guide

| Scenario | Recommended Model | Reason |
|----------|------------------|---------|
| Best accuracy needed | ResNet50 | Proven performance, 25M parameters |
| Balanced performance | EfficientNet-B0 | Good accuracy, 5M parameters |
| Real-time inference | Custom CNN | Fastest, 2M parameters |
| Limited GPU memory | Custom CNN | Smallest memory footprint |
| Embedded deployment | Custom CNN | Lightweight, no pre-training |

## Next Steps

After creating models, proceed to:
1. Task 5: Implement training pipeline
2. Train models on corrosion dataset
3. Evaluate and compare performance

See `MODEL_FACTORY_GUIDE.md` for detailed documentation.
