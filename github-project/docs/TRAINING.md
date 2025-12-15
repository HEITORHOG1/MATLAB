# Training Guide

This guide explains how to train the corrosion classification models.

## Prerequisites

- MATLAB R2023b or later
- Deep Learning Toolbox
- NVIDIA GPU with CUDA support (recommended)
- At least 12GB GPU memory
- Prepared dataset in `data/` directory

## Dataset Preparation

### 1. Organize Your Dataset

Place your images in the following structure:

```
data/
├── class_0/  # None/Light corrosion (Pc < 10%)
│   ├── image001.jpg
│   ├── image002.jpg
│   └── ...
├── class_1/  # Moderate corrosion (10% ≤ Pc < 30%)
│   ├── image001.jpg
│   ├── image002.jpg
│   └── ...
└── class_2/  # Severe corrosion (Pc ≥ 30%)
    ├── image001.jpg
    ├── image002.jpg
    └── ...
```

### 2. Run Dataset Preparation

```matlab
cd matlab
prepare_dataset
```

This script will:
- Load all images
- Create stratified train/val/test splits (70%/15%/15%)
- Compute class weights for imbalanced dataset
- Save processed datastores
- Display sample images

## Training Models

### ResNet50 (Highest Accuracy)

```matlab
cd matlab
train_resnet50
```

**Expected Results:**
- Validation Accuracy: ~94.2%
- Validation Loss: ~0.185
- Training Time: 2-4 hours (GPU)
- Parameters: 25M

**When to use:**
- Maximum accuracy is required
- Computational resources available
- Safety-critical applications

### EfficientNet-B0 (Best Balance)

```matlab
cd matlab
train_efficientnet
```

**Expected Results:**
- Validation Accuracy: ~91.9%
- Validation Loss: ~0.243
- Training Time: 1.5-3 hours (GPU)
- Parameters: 5M

**When to use:**
- Balance between accuracy and efficiency
- Mobile or edge deployment
- Most practical applications

### Custom CNN (Lightweight)

```matlab
cd matlab
train_custom_cnn
```

**Expected Results:**
- Validation Accuracy: ~85.5%
- Validation Loss: ~0.412
- Training Time: 1-2 hours (GPU)
- Parameters: 2M

**When to use:**
- Ultra-lightweight deployment
- Resource-constrained devices
- Baseline comparison

## Training Configuration

### Hyperparameters

| Parameter | Transfer Learning | From Scratch |
|-----------|------------------|--------------|
| Learning Rate | 1e-5 | 1e-4 |
| Batch Size | 32 | 32 |
| Max Epochs | 100 | 100 |
| Optimizer | Adam | Adam |
| Early Stopping | 10 epochs | 10 epochs |

### Data Augmentation

All models use the following augmentation techniques:
- Random horizontal flip (50% probability)
- Random vertical flip (50% probability)
- Random rotation (±15 degrees)
- Random scale (0.8-1.2x)
- Brightness adjustment (±20%)
- Contrast adjustment (±20%)

### Class Weighting

To handle class imbalance, we compute class weights:

```
w_c = N / (C × n_c)
```

Where:
- N = total training images (290)
- C = number of classes (3)
- n_c = number of images in class c

**Computed weights:**
- Class 0: 0.56
- Class 1: 1.23
- Class 2: 2.42

## Monitoring Training

### Training Progress Plot

MATLAB will display a real-time training progress plot showing:
- Training loss
- Validation loss
- Training accuracy
- Validation accuracy

### Early Stopping

Training automatically stops if validation accuracy doesn't improve for 10 consecutive epochs.

### Checkpoints

Models are automatically saved at:
- `models/resnet50_best.mat`
- `models/efficientnet_b0_best.mat`
- `models/custom_cnn_best.mat`

The best model (based on validation loss) is saved.

## Troubleshooting

### Out of Memory Error

If you encounter GPU memory errors:

1. Reduce batch size:
```matlab
miniBatchSize = 16;  % Instead of 32
```

2. Use CPU (slower):
```matlab
options = trainingOptions('adam', ...
    'ExecutionEnvironment', 'cpu', ...
    ...
);
```

### Slow Training

If training is very slow:

1. Verify GPU is being used:
```matlab
gpuDevice
```

2. Check GPU utilization:
```matlab
% In Windows PowerShell
nvidia-smi
```

3. Reduce validation frequency:
```matlab
'ValidationFrequency', 20  % Instead of 10
```

### Poor Convergence

If model doesn't converge well:

1. Adjust learning rate:
```matlab
learningRate = 5e-6;  % Lower
% or
learningRate = 5e-5;  % Higher
```

2. Increase max epochs:
```matlab
maxEpochs = 150;
```

3. Try different optimizer:
```matlab
options = trainingOptions('sgdm', ...  % Instead of 'adam'
    'Momentum', 0.9, ...
    ...
);
```

## Advanced Options

### Custom Learning Rate Schedule

```matlab
options = trainingOptions('adam', ...
    'InitialLearnRate', 1e-5, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 30, ...
    ...
);
```

### L2 Regularization

```matlab
options = trainingOptions('adam', ...
    'L2Regularization', 0.0001, ...
    ...
);
```

### Gradient Clipping

```matlab
options = trainingOptions('adam', ...
    'GradientThreshold', 1, ...
    ...
);
```

## Next Steps

After training:

1. **Evaluate on test set:**
```matlab
evaluate_model('resnet50')
```

2. **Measure inference time:**
```matlab
inference_time_analysis
```

3. **Compare models:**
```matlab
compare_models
```

4. **Deploy model:**
See [DEPLOYMENT.md](DEPLOYMENT.md) for deployment instructions.

## References

- [MATLAB Deep Learning Toolbox Documentation](https://www.mathworks.com/help/deeplearning/)
- [Transfer Learning Guide](https://www.mathworks.com/help/deeplearning/ug/transfer-learning.html)
- [Training Options Reference](https://www.mathworks.com/help/deeplearning/ref/trainingoptions.html)
