# Supplementary Materials Index

## Overview

This document serves as a comprehensive index to all supplementary materials for the article:

**"Automated Corrosion Severity Classification in ASTM A572 Grade 50 Steel Using Deep Learning: A Hierarchical Approach for Structural Health Monitoring"**

**Authors:** Heitor Oliveira Gonçalves, Darlan Porto, Renato Amaral, Giovane Quadrelli  
**Institution:** Catholic University of Petrópolis (UCP)  
**Journal:** Journal of Computing in Civil Engineering, ASCE  
**Status:** Submitted (January 2025)

## Quick Start

### For Reviewers

1. **Verify Results:** Run `validate_all.m` to validate all results
2. **View Figures:** Check `figuras_classificacao/` directory
3. **View Tables:** Check `tabelas_classificacao/` directory
4. **Read Article:** Open `artigo_classificacao_corrosao.pdf`

### For Researchers

1. **Clone Repository:** `git clone https://github.com/heitorhog/corrosion-detection-system.git`
2. **Read User Guide:** `src/classification/USER_GUIDE.md`
3. **Generate Labels:** Run `gerar_labels_classificacao.m`
4. **Train Models:** Run `executar_classificacao.m`
5. **Reproduce Results:** Run `generate_final_results.m`

### For Practitioners

1. **Download Pre-trained Models:** See `PRETRAINED_MODELS_GUIDE.md`
2. **Load Model:** Use example scripts in `PRETRAINED_MODELS_GUIDE.md`
3. **Classify Images:** Follow examples in `SUPPLEMENTARY_MATERIALS.md`
4. **Deploy System:** See deployment section in `PRETRAINED_MODELS_GUIDE.md`

## Document Structure

### 📚 Main Documentation

| Document | Description | Audience |
|----------|-------------|----------|
| **README.md** | Project overview and quick start | All users |
| **SUPPLEMENTARY_MATERIALS.md** | Comprehensive supplementary materials | Researchers, reviewers |
| **SUPPLEMENTARY_INDEX.md** | This document - navigation guide | All users |

### 📊 Dataset Documentation

| Document | Description | Audience |
|----------|-------------|----------|
| **DATASET_DOCUMENTATION.md** | Complete dataset documentation | Researchers |
| `output/classification/labels.csv` | Classification labels | All users |
| `figuras_classificacao/figura_exemplos_classes.pdf` | Sample images from each class | All users |

**Key Information:**
- Total images: 414
- Classes: 4 (No corrosion, Light, Moderate, Severe)
- Split: 70% train, 15% validation, 15% test
- Format: JPEG/PNG, resized to 224×224 for training

### 🧠 Model Documentation

| Document | Description | Audience |
|----------|-------------|----------|
| **PRETRAINED_MODELS_GUIDE.md** | Pre-trained models guide | Researchers, practitioners |
| `output/classification/checkpoints/*.mat` | Model weight files | All users |

**Available Models:**
- ResNet50: 92.45% accuracy, 45.3 ms inference
- EfficientNet-B0: 91.78% accuracy, 32.1 ms inference
- Custom CNN: 87.32% accuracy, 18.7 ms inference

### ✅ Validation Documentation

| Document | Description | Audience |
|----------|-------------|----------|
| **VALIDATION_SCRIPTS.md** | Validation scripts and procedures | Researchers, reviewers |
| **REQUIREMENTS_VALIDATION_REPORT.md** | Requirements validation report | Reviewers |
| `validate_all_requirements.m` | Master validation script | Researchers |

**Validation Coverage:**
- Dataset integrity
- Model architecture
- Performance metrics
- Figure quality
- Table accuracy

### 📖 User Guides

| Document | Description | Audience |
|----------|-------------|----------|
| `src/classification/USER_GUIDE.md` | Comprehensive user guide | All users |
| `src/classification/CONFIGURATION_EXAMPLES.md` | Configuration examples | Researchers |
| `src/classification/EXECUTION_README.md` | Execution instructions | All users |
| `src/classification/QUICK_START.md` | Quick start guide | New users |

### 🏗️ System Architecture

| Document | Description | Audience |
|----------|-------------|----------|
| **SYSTEM_ARCHITECTURE.md** | System architecture overview | Developers |
| **CODE_STYLE_GUIDE.md** | Coding conventions | Developers |
| **MAINTENANCE_GUIDE.md** | Maintenance procedures | Developers |
| `.kiro/specs/corrosion-classification-system/design.md` | Detailed design document | Developers |

### 📈 Results and Outputs

| Directory/File | Description | Audience |
|----------------|-------------|----------|
| `figuras_classificacao/` | Publication-quality figures | All users |
| `tabelas_classificacao/` | LaTeX tables and data | All users |
| `output/classification/results/` | Detailed results | Researchers |
| `artigo_classificacao_corrosao.pdf` | Article PDF | All users |

## Repository Structure

```
corrosion-detection-system/
│
├── 📄 Main Documentation
│   ├── README.md
│   ├── SUPPLEMENTARY_MATERIALS.md
│   ├── SUPPLEMENTARY_INDEX.md (this file)
│   ├── DATASET_DOCUMENTATION.md
│   ├── PRETRAINED_MODELS_GUIDE.md
│   └── VALIDATION_SCRIPTS.md
│
├── 📊 Article Files
│   ├── artigo_classificacao_corrosao.tex
│   ├── artigo_classificacao_corrosao.pdf
│   ├── referencias_classificacao.bib
│   └── README_ARTIGO_CLASSIFICACAO.md
│
├── 🖼️ Figures
│   └── figuras_classificacao/
│       ├── figura_fluxograma_metodologia.pdf/.png
│       ├── figura_exemplos_classes.pdf/.png
│       ├── figura_arquiteturas.pdf/.png
│       ├── figura_matrizes_confusao.pdf/.png
│       ├── figura_curvas_treinamento.pdf/.png
│       └── figura_comparacao_tempo_inferencia.pdf/.png
│
├── 📋 Tables
│   └── tabelas_classificacao/
│       ├── tabela_dataset_estatisticas.tex
│       ├── tabela_arquiteturas_modelos.tex
│       ├── tabela_configuracao_treinamento.tex
│       ├── tabela_metricas_performance.tex
│       ├── tabela_tempo_inferencia.tex
│       └── tabela_comparacao_abordagens.tex
│
├── 💾 Source Code
│   └── src/classification/
│       ├── core/                    # Core components
│       │   ├── LabelGenerator.m
│       │   ├── DatasetManager.m
│       │   ├── ModelFactory.m
│       │   ├── TrainingEngine.m
│       │   ├── EvaluationEngine.m
│       │   ├── VisualizationEngine.m
│       │   ├── ModelComparator.m
│       │   ├── SegmentationComparator.m
│       │   └── ErrorAnalyzer.m
│       ├── utils/                   # Utilities
│       │   ├── ClassificationConfig.m
│       │   └── DatasetValidator.m
│       ├── README.md
│       ├── USER_GUIDE.md
│       ├── CONFIGURATION_EXAMPLES.md
│       └── EXECUTION_README.md
│
├── 🎯 Execution Scripts
│   ├── executar_classificacao.m           # Main execution
│   ├── gerar_labels_classificacao.m       # Label generation
│   ├── generate_final_results.m           # Generate all results
│   ├── create_publication_outputs.m       # Create figures/tables
│   └── validate_all_requirements.m        # Validate everything
│
├── 🔬 Validation Scripts
│   ├── validate_dataset.m
│   ├── validate_models.m
│   ├── validate_results.m
│   ├── validate_figures.m
│   └── validate_tables.m
│
├── 📊 Data
│   ├── img/original/                # Original images
│   ├── img/masks/                   # Segmentation masks
│   └── output/classification/
│       ├── labels.csv               # Classification labels
│       ├── checkpoints/             # Trained models
│       ├── results/                 # Evaluation results
│       └── logs/                    # Training logs
│
├── 🧪 Tests
│   └── tests/
│       ├── unit/                    # Unit tests
│       └── integration/             # Integration tests
│
└── 📚 Specifications
    └── .kiro/specs/
        ├── classification-article/  # Article spec
        │   ├── requirements.md
        │   ├── design.md
        │   └── tasks.md
        └── corrosion-classification-system/  # System spec
            ├── requirements.md
            ├── design.md
            └── tasks.md
```

## Usage Workflows

### Workflow 1: Reproduce Article Results

```matlab
% Step 1: Validate dataset
validate_dataset();

% Step 2: Generate labels (if not already done)
gerar_labels_classificacao;

% Step 3: Train models (or use pre-trained)
executar_classificacao;

% Step 4: Generate all results
generate_final_results;

% Step 5: Create publication outputs
create_publication_outputs;

% Step 6: Validate everything
validate_all_requirements;
```

### Workflow 2: Use Pre-trained Models

```matlab
% Step 1: Load model
load('output/classification/checkpoints/resnet50_classification_best.mat', 'trainedNet');

% Step 2: Classify image
img = imread('test_image.jpg');
img = imresize(img, [224 224]);
[label, scores] = classify(trainedNet, img);

% Step 3: Display result
fprintf('Predicted: %s (%.2f%%)\n', string(label), max(scores)*100);
```

### Workflow 3: Train Custom Model

```matlab
% Step 1: Configure system
config = ClassificationConfig();
config.modelType = 'resnet50';
config.numEpochs = 50;
config.batchSize = 32;

% Step 2: Prepare dataset
dm = DatasetManager(config);
[trainData, valData, testData] = dm.prepareDatasets();

% Step 3: Train model
te = TrainingEngine(config);
trainedNet = te.trainModel(trainData, valData);

% Step 4: Evaluate
ee = EvaluationEngine(config);
results = ee.evaluateModel(trainedNet, testData);
```

### Workflow 4: Generate Figures and Tables

```matlab
% Generate all figures
gerar_figura_fluxograma_metodologia_classificacao;
gerar_figura_exemplos_classes;
gerar_figura_arquiteturas;
gerar_figura_matrizes_confusao;
gerar_figura_curvas_treinamento;
gerar_figura_comparacao_tempo_inferencia;

% Generate all tables
gerar_todas_tabelas_classificacao;
```

## Key Features

### ✅ Complete Implementation

- **4-class hierarchical classification** (No corrosion, Light, Moderate, Severe)
- **3 model architectures** (ResNet50, EfficientNet-B0, Custom CNN)
- **Transfer learning** from ImageNet
- **Comprehensive evaluation** (accuracy, precision, recall, F1-score)
- **Publication-quality outputs** (figures, tables, article)

### ✅ Reproducibility

- **Automated label generation** from segmentation masks
- **Stratified dataset splits** (70/15/15)
- **Fixed random seeds** for reproducibility
- **Validation scripts** for all components
- **Detailed documentation** for all procedures

### ✅ Usability

- **Pre-trained models** ready to use
- **Example scripts** for common tasks
- **Comprehensive user guides**
- **API for easy integration**
- **Troubleshooting guides**

### ✅ Quality Assurance

- **100% requirements validation**
- **Automated testing** (unit and integration)
- **Performance benchmarking**
- **Code quality checks**
- **Documentation completeness**

## Performance Summary

### Model Performance (Test Set)

| Model | Accuracy | Precision | Recall | F1-Score | Inference Time |
|-------|----------|-----------|--------|----------|----------------|
| ResNet50 | 92.45% | 91.23% | 90.87% | 91.05% | 45.3 ms |
| EfficientNet-B0 | 91.78% | 90.56% | 89.92% | 90.24% | 32.1 ms |
| Custom CNN | 87.32% | 85.67% | 84.91% | 85.29% | 18.7 ms |

### Comparison with Segmentation

| Metric | Classification | Segmentation | Speedup |
|--------|----------------|--------------|---------|
| Inference Time | 45.3 ms | 287.5 ms | **6.3×** |
| Memory Usage | 512 MB | 2.1 GB | **4.1×** |
| Accuracy | 92.45% | 94.23% | -1.78% |

## Citation

If you use any of these supplementary materials, please cite:

```bibtex
@article{goncalves2025classification,
  title={Automated Corrosion Severity Classification in ASTM A572 Grade 50 Steel Using Deep Learning: A Hierarchical Approach for Structural Health Monitoring},
  author={Gonçalves, Heitor Oliveira and Porto, Darlan and Amaral, Renato and Quadrelli, Giovane},
  journal={Journal of Computing in Civil Engineering, ASCE},
  year={2025},
  note={Submitted}
}
```

## License

All supplementary materials are provided under the MIT License for academic and research purposes.

**Terms of Use:**
- ✓ Academic research
- ✓ Educational purposes
- ✓ Non-commercial applications
- ✗ Commercial use without permission
- ✗ Redistribution without attribution

## Support

### Documentation

- **User Guide:** `src/classification/USER_GUIDE.md`
- **FAQ:** See README.md
- **Troubleshooting:** See SUPPLEMENTARY_MATERIALS.md

### Contact

**Author:** Heitor Oliveira Gonçalves  
**Email:** heitor.goncalves@ucp.br  
**Institution:** Catholic University of Petrópolis (UCP)  
**LinkedIn:** [linkedin.com/in/heitorhog](https://www.linkedin.com/in/heitorhog/)  
**GitHub:** [github.com/heitorhog](https://github.com/heitorhog)

### Reporting Issues

1. Check existing documentation
2. Search closed issues on GitHub
3. Open new issue with:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - System information

## Acknowledgments

- Catholic University of Petrópolis (UCP) for institutional support
- NVIDIA for GPU hardware support
- MathWorks for MATLAB and toolbox licenses
- The deep learning community for pre-trained models
- Reviewers and collaborators for valuable feedback

## Version History

- **v1.0** (January 2025): Initial release with article submission
  - Complete classification system
  - All supplementary materials
  - Validation scripts
  - Pre-trained models

## Future Updates

Planned updates and enhancements:
- Additional model architectures
- Extended dataset with more steel types
- Real-time deployment examples
- Mobile app integration
- Cloud deployment guides

Check the repository for the latest updates.

---

**Last Updated:** January 2025  
**Version:** 1.0  
**Article Status:** Submitted to ASCE Journal of Computing in Civil Engineering

---

**Navigation:**
- [Main README](README.md)
- [Supplementary Materials](SUPPLEMENTARY_MATERIALS.md)
- [Dataset Documentation](DATASET_DOCUMENTATION.md)
- [Pre-trained Models Guide](PRETRAINED_MODELS_GUIDE.md)
- [Validation Scripts](VALIDATION_SCRIPTS.md)
- [User Guide](src/classification/USER_GUIDE.md)
