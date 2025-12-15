# Deep Learning-Based Corrosion Severity Classification for ASTM A572 Grade 50 Steel Structures

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2023b-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![Python](https://img.shields.io/badge/Python-3.12-blue.svg)](https://www.python.org/)

This repository contains the implementation code for the paper "Deep Learning-Based Corrosion Severity Classification for ASTM A572 Grade 50 Steel Structures: A Transfer Learning Approach".

## 📋 Overview

This project implements and compares three deep learning architectures for automated corrosion severity classification in steel structures:
- **ResNet50** (25M parameters) - Highest accuracy: 94.2%
- **EfficientNet-B0** (5M parameters) - Best balance: 91.9% accuracy, 32.7ms inference
- **Custom CNN** (2M parameters) - Lightweight: 85.5% accuracy, 18.5ms inference

## 🎯 Key Results

- **Transfer learning** achieves 94.2% accuracy with only 414 training images
- **Real-time inference**: 18-45ms per image on NVIDIA RTX 3060
- **Adjacent-class errors only**: No critical misclassifications
- **Practical deployment**: Suitable for mobile devices and edge computing

## 📊 Dataset

- **Total images**: 414 high-resolution images of ASTM A572 Grade 50 steel
- **Classes**: 3 severity levels based on corroded area percentage
  - Class 0 (None/Light): Pc < 10% (245 images, 59.2%)
  - Class 1 (Moderate): 10% ≤ Pc < 30% (112 images, 27.1%)
  - Class 2 (Severe): Pc ≥ 30% (57 images, 13.8%)
- **Split**: 70% training / 15% validation / 15% test

## 🚀 Quick Start

### Prerequisites

- MATLAB R2023b or later with Deep Learning Toolbox
- Python 3.12+ (for analysis scripts)
- NVIDIA GPU with CUDA support (recommended)
- At least 12GB GPU memory

### Installation

```bash
# Clone the repository
git clone https://github.com/heitorhog/corrosion-classification-astm-a572.git
cd corrosion-classification-astm-a572

# Install Python dependencies
pip install -r requirements.txt
```

### Dataset Preparation

1. Place your corrosion images in the `data/` directory with the following structure:
```
data/
├── class_0/  # None/Light corrosion (Pc < 10%)
├── class_1/  # Moderate corrosion (10% ≤ Pc < 30%)
└── class_2/  # Severe corrosion (Pc ≥ 30%)
```

2. Run the dataset preparation script:
```matlab
cd matlab
run('prepare_dataset.m')
```

## 📁 Repository Structure

```
corrosion-classification-astm-a572/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── requirements.txt                   # Python dependencies
├── .gitignore                        # Git ignore rules
│
├── data/                             # Dataset directory (not included)
│   ├── class_0/                      # Class 0 images
│   ├── class_1/                      # Class 1 images
│   └── class_2/                      # Class 2 images
│
├── matlab/                           # MATLAB implementation
│   ├── prepare_dataset.m             # Dataset preparation
│   ├── train_resnet50.m              # Train ResNet50 model
│   ├── train_efficientnet.m          # Train EfficientNet-B0 model
│   ├── train_custom_cnn.m            # Train custom CNN model
│   ├── evaluate_model.m              # Model evaluation
│   ├── inference_time_analysis.m     # Inference time benchmarking
│   ├── plot_confusion_matrix.m       # Confusion matrix visualization
│   ├── plot_training_curves.m        # Training curves visualization
│   └── utils/                        # Utility functions
│       ├── augment_data.m            # Data augmentation
│       ├── compute_class_weights.m   # Class weight calculation
│       └── bootstrap_metrics.m       # Bootstrap confidence intervals
│
├── python/                           # Python analysis scripts
│   ├── analyze_results.py            # Results analysis
│   ├── generate_figures.py           # Figure generation
│   └── export_metrics.py             # Export metrics to CSV
│
├── models/                           # Trained model weights (not included)
│   ├── resnet50_best.mat
│   ├── efficientnet_b0_best.mat
│   └── custom_cnn_best.mat
│
├── results/                          # Results and figures
│   ├── confusion_matrices/
│   ├── training_curves/
│   └── metrics/
│
└── docs/                             # Documentation
    ├── TRAINING.md                   # Training guide
    ├── EVALUATION.md                 # Evaluation guide
    └── DEPLOYMENT.md                 # Deployment guide
```

## 🔧 Training Models

### Train ResNet50
```matlab
cd matlab
train_resnet50
```

### Train EfficientNet-B0
```matlab
cd matlab
train_efficientnet
```

### Train Custom CNN
```matlab
cd matlab
train_custom_cnn
```

Training parameters:
- **Optimizer**: Adam
- **Learning rate**: 1e-5 (transfer learning), 1e-4 (from scratch)
- **Batch size**: 32
- **Max epochs**: 100
- **Early stopping**: 10 epochs patience
- **Data augmentation**: 6 techniques (flip, rotate, brightness, contrast, noise)

## 📈 Evaluation

Evaluate a trained model:
```matlab
cd matlab
evaluate_model('resnet50')  % or 'efficientnet', 'custom_cnn'
```

This will generate:
- Confusion matrix
- Classification report
- ROC curves
- Precision-Recall curves

## 🎨 Generating Figures

Generate all paper figures:
```matlab
cd matlab
plot_confusion_matrix
plot_training_curves
```

Or use Python for additional analysis:
```bash
cd python
python generate_figures.py
```

## 📊 Results

### Model Performance

| Model | Val Accuracy | Val Loss | Parameters | Inference Time |
|-------|-------------|----------|------------|----------------|
| ResNet50 | 94.2% ± 2.1% | 0.185 ± 0.032 | 25M | 45.3 ms |
| EfficientNet-B0 | 91.9% ± 2.4% | 0.243 ± 0.041 | 5M | 32.7 ms |
| Custom CNN | 85.5% ± 3.1% | 0.412 ± 0.058 | 2M | 18.5 ms |

### Confusion Matrices

All models exhibit adjacent-class errors only, with no critical misclassifications between Class 0 and Class 2.

## 🚀 Deployment

### Real-time Inference

```matlab
% Load trained model
load('models/resnet50_best.mat', 'net');

% Load and preprocess image
img = imread('test_image.jpg');
img = imresize(img, [224 224]);

% Predict
[label, scores] = classify(net, img);
fprintf('Predicted class: %s (confidence: %.2f%%)\n', label, max(scores)*100);
```

### Batch Processing

```matlab
% Process multiple images
imageFolder = 'path/to/images';
results = batch_inference(net, imageFolder);
```

See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for detailed deployment instructions including:
- Mobile deployment (TensorFlow Lite)
- Edge computing (NVIDIA Jetson)
- Cloud deployment (AWS, Azure)

## 📝 Citation

If you use this code in your research, please cite our paper:

```bibtex
@article{goncalves2025corrosion,
  title={Deep Learning-Based Corrosion Severity Classification for ASTM A572 Grade 50 Steel Structures: A Transfer Learning Approach},
  author={Gon{\c{c}}alves, Heitor Oliveira and Porto, Darlan and Amaral, Renato and Pereira, Celso Santana Santos and Esteves, Cleber Mange and Quadrelli, Giovane},
  journal={Computer-Aided Civil and Infrastructure Engineering},
  year={2025},
  publisher={Elsevier}
}
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Heitor Oliveira Gonçalves** - *Corresponding author* - heitorhog@gmail.com
- Darlan Porto
- Renato Amaral
- Celso Santana Santos Pereira
- Cleber Mange Esteves
- Giovane Quadrelli

**Affiliation**: Catholic University of Petrópolis (UCP), Petrópolis, Rio de Janeiro, Brazil

## 🙏 Acknowledgments

- Catholic University of Petrópolis for computational resources
- NVIDIA for GPU support through academic program
- The deep learning community for open-source tools and pre-trained models

## 📧 Contact

For questions or collaboration opportunities, please contact:
- Email: heitorhog@gmail.com
- Institution: Catholic University of Petrópolis (UCP)

## 🔗 Links

- [Paper (preprint)](https://arxiv.org/abs/XXXXX) - To be added
- [Supplementary Materials](https://github.com/heitorhog/corrosion-classification-astm-a572/tree/main/supplementary)
- [Project Website](https://heitorhog.github.io/corrosion-classification) - To be added

## ⚠️ Dataset Availability

The corrosion image dataset contains proprietary information from infrastructure inspections and cannot be publicly shared. However, the code can be applied to your own corrosion datasets following the structure described above.

For academic collaboration or dataset access requests, please contact the corresponding author.

## 🔄 Updates

- **2025-11-10**: Initial release with training and evaluation code
- **2025-11-10**: Added deployment guides and inference scripts

## 🐛 Issues

If you encounter any issues or have suggestions, please [open an issue](https://github.com/heitorhog/corrosion-classification-astm-a572/issues).

## 🌟 Star History

If you find this project useful, please consider giving it a star ⭐!
