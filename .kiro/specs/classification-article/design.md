# Design Document - Classification Article

## Overview

This document outlines the design for creating a scientific article about the corrosion severity classification system. The article will be structured as a companion paper to the previous segmentation article, presenting classification as a complementary and more efficient approach for rapid corrosion assessment in large-scale infrastructure monitoring.

## Article Structure

### 1. Title and Metadata

**Title:** "AUTOMATED CORROSION SEVERITY CLASSIFICATION IN ASTM A572 GRADE 50 STEEL USING DEEP LEARNING: A HIERARCHICAL APPROACH FOR STRUCTURAL HEALTH MONITORING"

**Authors:**
- Heitor Oliveira Gonçalves (Corresponding author)
- Darlan Porto
- Renato Amaral
- Giovane Quadrelli
- Catholic University of Petrópolis (UCP)

**Keywords:** Deep Learning, Image Classification, Transfer Learning, Corrosion Assessment, ASTM A572 Grade 50, ResNet, EfficientNet, Structural Inspection, Computer Vision

### 2. Abstract Structure (250-300 words)

**Components:**
1. **Problem Statement:** Need for rapid corrosion assessment in large-scale infrastructure
2. **Methodology:** Three-class classification using transfer learning (ResNet50, EfficientNet-B0, Custom CNN)
3. **Dataset:** 414 images with severity labels derived from segmentation masks
4. **Key Results:** Best model accuracy, inference time comparison with segmentation
5. **Practical Impact:** Speedup factor and applicability for rapid screening

### 3. Introduction Structure

**Section Flow:**
1. **Context:** Corrosion problem and economic impact (reference segmentation article)
2. **Current Approaches:** Segmentation provides detailed masks but is computationally expensive
3. **Research Gap:** Need for rapid severity assessment for large-scale monitoring
4. **Proposed Solution:** Classification as complementary approach to segmentation
5. **Objectives:** Compare transfer learning architectures and evaluate practical applicability
6. **Contributions:** Demonstrate classification efficiency and establish guidelines for method selection

### 4. Methodology Structure

**Subsections:**

#### 4.1 Dataset Preparation
- Label generation from segmentation masks
- Threshold-based hierarchical severity classification (10%, 30%)
- **Four classes:**
  - **Class 0:** No corrosion (0% corroded area)
  - **Class 1:** Light corrosion (< 10% corroded area)
  - **Class 2:** Moderate corrosion (10-30% corroded area)
  - **Class 3:** Severe corrosion (> 30% corroded area)
- Dataset statistics and class distribution

#### 4.2 Model Architectures
- **ResNet50:** Pre-trained on ImageNet, ~25M parameters, transfer learning configuration
- **EfficientNet-B0:** Pre-trained on ImageNet, ~5M parameters, efficient architecture
- **Custom CNN:** Lightweight design, ~2M parameters, 4 conv blocks + 2 FC layers

#### 4.3 Training Configuration
- Stratified train/val/test split (70/15/15)
- Data augmentation (flips, rotation, brightness, contrast)
- Hyperparameters (learning rate, batch size, epochs)
- Early stopping with validation patience
- Optimizer (Adam) and loss function (cross-entropy)

#### 4.4 Evaluation Metrics
- Overall accuracy
- Per-class precision, recall, F1-score
- Confusion matrix analysis
- Inference time benchmarking
- Statistical significance testing

#### 4.5 Comparison with Segmentation
- Inference time comparison
- Accuracy vs speed trade-off
- Use case analysis

### 5. Results Structure

**Subsections:**

#### 5.1 Model Performance Comparison
- Table with accuracy, precision, recall, F1-score for all models
- Best performing model identification
- Statistical significance of differences

#### 5.2 Confusion Matrix Analysis
- Normalized confusion matrices for each model
- Error pattern analysis
- Class-specific performance discussion

#### 5.3 Training Dynamics
- Loss and accuracy curves during training
- Convergence behavior comparison
- Overfitting analysis

#### 5.4 Inference Time Analysis
- Classification inference time per image
- Comparison with segmentation approach
- Speedup factor calculation
- Scalability implications

#### 5.5 Classification vs Segmentation Trade-offs
- Accuracy comparison
- Computational efficiency comparison
- Memory usage comparison
- Practical applicability analysis

### 6. Discussion Structure

**Topics:**

#### 6.1 Performance Interpretation
- Why transfer learning outperforms custom CNN
- Role of pre-trained features
- Impact of model capacity

#### 6.2 Practical Applications
- Rapid screening for large infrastructure
- Integration with inspection workflows
- Cost-benefit analysis
- Deployment scenarios

#### 6.3 Classification vs Segmentation Selection
- When to use classification (rapid assessment, large-scale monitoring)
- When to use segmentation (detailed analysis, critical structures)
- Hybrid approaches (classification for screening, segmentation for detailed analysis)

#### 6.4 Limitations
- Loss of spatial information compared to segmentation
- Threshold sensitivity
- Class imbalance challenges
- Generalization to other steel types

#### 6.5 Future Work
- Ensemble methods combining multiple models
- Explainability techniques (Grad-CAM, attention visualization)
- Multi-task learning (classification + localization)
- Real-time mobile deployment

### 7. Conclusions Structure

**Components:**
1. **Summary of Findings:** Best model performance and key results
2. **Practical Impact:** Speedup and efficiency gains
3. **Complementary Nature:** Classification and segmentation as complementary tools
4. **Recommendations:** Guidelines for method selection
5. **Future Directions:** Specific improvements and research paths

## Figures and Tables Design

### Figures

**Figure 1: Methodology Flowchart**
- Complete pipeline from image to classification
- Label generation process
- Model training and evaluation workflow

**Figure 2: Sample Images with Classifications**
- Grid showing examples from each severity class
- Model predictions vs ground truth
- Confidence scores

**Figure 3: Model Architecture Comparison**
- Visual representation of ResNet50, EfficientNet-B0, Custom CNN
- Parameter counts and layer structures

**Figure 4: Confusion Matrices**
- 3x3 heatmaps for each model
- Percentage annotations
- Color-coded for clarity

**Figure 5: Training Curves**
- Loss and accuracy evolution
- All models on same plot for comparison
- Validation curves included

**Figure 6: Inference Time Comparison**
- Bar chart: Classification models vs Segmentation
- Speedup factors annotated
- Log scale if needed

**Figure 7: ROC Curves (Optional)**
- One-vs-rest ROC curves for multi-class
- AUC scores for each class
- Model comparison

### Tables

**Table 1: Dataset Statistics**
- Total images, class distribution
- Train/val/test split sizes
- Class balance metrics

**Table 2: Model Architecture Details**
- Parameters, layers, input size
- Pre-training dataset
- Modifications for classification

**Table 3: Training Configuration**
- Hyperparameters for all models
- Augmentation settings
- Hardware specifications

**Table 4: Performance Metrics**
- Accuracy, precision, recall, F1-score
- Per-class and overall metrics
- Confidence intervals

**Table 5: Inference Time Comparison**
- Classification models (ms per image)
- Segmentation model (ms per image)
- Speedup factors
- Hardware specifications

**Table 6: Classification vs Segmentation Trade-offs**
- Accuracy, speed, memory, use cases
- Qualitative comparison

## LaTeX Document Structure

### Document Class and Packages

```latex
\documentclass[Journal,letterpaper,InsideFigs]{ascelike-new}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[english]{babel}
\usepackage{graphicx}
\usepackage{caption}
\usepackage{subcaption}
\usepackage{amsmath}
\usepackage{siunitx}
\usepackage{booktabs}
\usepackage{array}
\usepackage{multirow}
\usepackage{hyperref}
```

### File Organization

```
article/
├── artigo_classificacao_corrosao.tex (main file)
├── artigo_classificacao_corrosao.bib (bibliography)
├── figuras/ (figures directory)
│   ├── figura_fluxograma_metodologia.pdf
│   ├── figura_exemplos_classes.pdf
│   ├── figura_arquiteturas.pdf
│   ├── figura_matrizes_confusao.pdf
│   ├── figura_curvas_treinamento.pdf
│   ├── figura_comparacao_tempo.pdf
│   └── figura_curvas_roc.pdf
└── tabelas/ (tables as separate files if needed)
```

## Bibliography Design

### Key References Categories

1. **Corrosion and Structural Engineering:**
   - Fontana & Greene (corrosion fundamentals)
   - Koch et al. (economic impact)
   - ASTM A572 standard
   - Previous segmentation article

2. **Deep Learning Fundamentals:**
   - LeCun et al. (deep learning review)
   - Goodfellow et al. (deep learning book)

3. **Classification Architectures:**
   - He et al. (ResNet original paper)
   - Tan & Le (EfficientNet original paper)
   - Transfer learning surveys

4. **Corrosion Detection with AI:**
   - Recent papers on corrosion classification
   - Computer vision for structural inspection
   - Automated damage detection

5. **Comparative Studies:**
   - Classification vs segmentation papers
   - Multi-task learning approaches

## Writing Style Guidelines

### Technical Writing Principles

1. **Clarity:** Use clear, concise language
2. **Precision:** Specify exact values with units and confidence intervals
3. **Objectivity:** Present results objectively, acknowledge limitations
4. **Reproducibility:** Provide sufficient detail for reproduction
5. **Consistency:** Use consistent terminology throughout

### Terminology Consistency

- "Classification" (not "categorization")
- "Severity classes" (not "severity levels")
- "Transfer learning" (not "fine-tuning" unless specifically discussing)
- "Inference time" (not "prediction time")
- "Ground truth" (not "true labels")

### Numerical Reporting

- Report accuracy as percentage with 2 decimal places (e.g., 92.45%)
- Report inference time in milliseconds with 1 decimal place (e.g., 45.3 ms)
- Include confidence intervals (e.g., 92.45% ± 1.23%)
- Use scientific notation for very small/large numbers

## Quality Assurance

### Review Checklist

1. **Content:**
   - [ ] All sections complete
   - [ ] Results match actual system performance
   - [ ] Figures and tables properly referenced
   - [ ] Citations complete and accurate

2. **Format:**
   - [ ] ASCE style guidelines followed
   - [ ] Figures at 300 DPI
   - [ ] Tables properly formatted
   - [ ] References in correct format

3. **Language:**
   - [ ] Grammar and spelling checked
   - [ ] Technical terms used correctly
   - [ ] Consistent terminology
   - [ ] Clear and concise writing

4. **Reproducibility:**
   - [ ] Methodology sufficiently detailed
   - [ ] Hyperparameters specified
   - [ ] Code and data availability mentioned
   - [ ] Hardware specifications provided

## Timeline and Milestones

### Phase 1: Content Creation (Tasks 1-5)
- Write abstract and introduction
- Develop methodology section
- Create results section
- Write discussion and conclusions

### Phase 2: Figures and Tables (Tasks 6-8)
- Generate all figures
- Create all tables
- Format for publication quality

### Phase 3: Bibliography and Formatting (Tasks 9-10)
- Compile bibliography
- Format document according to ASCE guidelines
- Final review and corrections

### Phase 4: Supplementary Materials (Task 11)
- Prepare code repository
- Create documentation
- Organize supplementary files
