# Classification Article - README

## Overview

This document provides information about the scientific article on automated corrosion severity classification in ASTM A572 Grade 50 steel structures using deep learning.

## Article Information

**Title:** Automated Corrosion Severity Classification in ASTM A572 Grade 50 Steel Using Deep Learning: A Hierarchical Approach for Structural Health Monitoring

**Authors:**
- Heitor Oliveira Gonçalves (Corresponding author)
- Darlan Porto
- Renato Amaral
- Giovane Quadrelli

**Affiliation:** Catholic University of Petrópolis (UCP), Petrópolis, Rio de Janeiro, Brazil

**Target Journal:** ASCE Journal (same as segmentation article)

## Article Structure

The article follows ASCE journal format and includes:

1. **Abstract** - Structured abstract (250-300 words)
2. **Introduction** - Context, research gap, objectives, contributions
3. **Methodology** - Dataset, architectures, training, evaluation
4. **Results** - Performance comparison, confusion matrices, training curves, inference time
5. **Discussion** - Interpretation, applications, guidelines, limitations, future work
6. **Conclusions** - Summary, impact, recommendations
7. **References** - Comprehensive bibliography

## Key Features

### Hierarchical 4-Class Classification System

The article presents a hierarchical classification approach with four severity classes:

- **Class 0:** No corrosion (0% corroded area)
- **Class 1:** Light corrosion (< 10% corroded area)
- **Class 2:** Moderate corrosion (10-30% corroded area)
- **Class 3:** Severe corrosion (> 30% corroded area)

### Model Architectures Evaluated

1. **ResNet50** - Transfer learning with ~25M parameters
2. **EfficientNet-B0** - Efficient architecture with ~5M parameters
3. **Custom CNN** - Lightweight design with ~2M parameters

### Complementary Approach

The article emphasizes that classification is a **complementary approach** to segmentation, not a replacement:
- **Classification:** Rapid severity assessment for large-scale monitoring
- **Segmentation:** Detailed pixel-level analysis for critical structures

## File Organization

```
.
├── artigo_classificacao_corrosao.tex       # Main LaTeX file
├── referencias_classificacao.bib           # Bibliography (BibTeX)
├── figuras_classificacao/                  # Figures directory
│   ├── README.md                           # Figure documentation
│   ├── figura_fluxograma_metodologia.pdf   # Methodology flowchart
│   ├── figura_exemplos_classes.pdf         # Sample images
│   ├── figura_arquiteturas.pdf             # Architecture comparison
│   ├── figura_matrizes_confusao.pdf        # Confusion matrices (4x4)
│   ├── figura_curvas_treinamento.pdf       # Training curves
│   └── figura_comparacao_tempo.pdf         # Inference time comparison
├── tabelas_classificacao/                  # Tables directory
│   ├── README.md                           # Table documentation
│   ├── tabela_dataset_estatisticas.tex     # Dataset statistics
│   ├── tabela_arquiteturas_modelos.tex     # Model architectures
│   ├── tabela_configuracao_treinamento.tex # Training configuration
│   ├── tabela_metricas_performance.tex     # Performance metrics
│   ├── tabela_tempo_inferencia.tex         # Inference time
│   └── tabela_comparacao_abordagens.tex    # Classification vs segmentation
└── README_ARTIGO_CLASSIFICACAO.md          # This file
```

## Compilation Instructions

### Prerequisites

- LaTeX distribution (TeX Live, MiKTeX, or MacTeX)
- ASCE document class (`ascelike-new.cls`)
- BibTeX for bibliography management

### Compilation Steps

1. **Compile LaTeX:**
   ```bash
   pdflatex artigo_classificacao_corrosao.tex
   ```

2. **Generate Bibliography:**
   ```bash
   bibtex artigo_classificacao_corrosao
   ```

3. **Recompile LaTeX (twice for cross-references):**
   ```bash
   pdflatex artigo_classificacao_corrosao.tex
   pdflatex artigo_classificacao_corrosao.tex
   ```

### Using Makefile (if available)

```bash
make classification-article
```

## Content Development Workflow

The article development follows the spec workflow defined in `.kiro/specs/classification-article/`:

1. **Requirements** - Defined in `requirements.md`
2. **Design** - Outlined in `design.md`
3. **Tasks** - Implementation plan in `tasks.md`

### Current Status

- [x] Task 1: Setup article structure and LaTeX template
- [ ] Task 2: Write abstract and keywords
- [ ] Task 3: Write introduction section
- [ ] Task 4: Write methodology section
- [ ] Task 5: Write results section
- [ ] Task 6: Write discussion section
- [ ] Task 7: Write conclusions section
- [ ] Task 8: Create all figures
- [ ] Task 9: Create all tables
- [ ] Task 10: Compile bibliography and format references
- [ ] Task 11: Final formatting and review
- [ ] Task 12: Prepare supplementary materials

## Data Sources

The article uses data from the classification system implemented in `src/classification/`:

- **Label Generation:** `src/classification/core/LabelGenerator.m`
- **Dataset Management:** `src/classification/core/DatasetManager.m`
- **Model Training:** `src/classification/core/TrainingEngine.m`
- **Evaluation:** `src/classification/core/EvaluationEngine.m`
- **Visualization:** `src/classification/core/VisualizationEngine.m`
- **Comparison:** `src/classification/core/ModelComparator.m`

## Quality Assurance

### Review Checklist

- [ ] All sections complete
- [ ] Results match actual system performance
- [ ] Figures at 300 DPI resolution
- [ ] Tables properly formatted
- [ ] Citations complete and accurate
- [ ] ASCE style guidelines followed
- [ ] Grammar and spelling checked
- [ ] Technical terms used correctly
- [ ] Consistent terminology throughout

### Validation Scripts

Run validation scripts to ensure data accuracy:

```matlab
% Validate classification results
validate_executar_classificacao

% Validate model comparison
validate_model_comparison

% Validate visualization outputs
validate_visualization_engine
```

## References

The article references:
- Previous segmentation article (foundational work)
- Original architecture papers (ResNet, EfficientNet)
- Corrosion engineering literature
- Deep learning fundamentals
- Transfer learning surveys

## Contact

**Corresponding Author:** Heitor Oliveira Gonçalves  
**Email:** heitorhog@gmail.com  
**Institution:** Catholic University of Petrópolis (UCP)

## License

This article and associated materials are part of the corrosion detection research project at UCP.

## Acknowledgments

The authors acknowledge the Catholic University of Petrópolis (UCP) for providing the computational resources and infrastructure necessary for this research.
