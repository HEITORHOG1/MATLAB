# Requirements Document - Generate Figures for Pure Classification Article

## Introduction

This document specifies the requirements for generating all 7 figures needed for the pure classification article using the existing data from the classification system. The figures will be created using Python/matplotlib to ensure publication quality (300 DPI PDF format).

## Glossary

- **Figure Generation**: Creating publication-quality PDF figures at 300 DPI resolution
- **Confusion Matrix**: 3×3 matrix showing classification results for the three severity classes
- **Training Curves**: Plots showing loss and accuracy evolution during model training
- **Methodology Flowchart**: Diagram showing the complete classification pipeline

## Requirements

### Requirement 1: Generate Methodology Flowchart

**User Story:** As a reader, I want a clear flowchart of the methodology, so that I can understand the complete classification pipeline.

#### Acceptance Criteria

1. WHEN THE flowchart is created, THE Figure SHALL show the complete pipeline from image input to classification output
2. WHEN THE flowchart is designed, THE Figure SHALL include dataset preparation, train/val/test split, model training, and evaluation stages
3. WHEN THE flowchart is formatted, THE Figure SHALL use clear boxes, arrows, and labels
4. WHEN THE flowchart is saved, THE Figure SHALL be exported as PDF at 300 DPI to figuras_pure_classification/figura_fluxograma_metodologia.pdf
5. WHERE THE flowchart includes text, THE Figure SHALL use readable fonts (10-12pt minimum)

### Requirement 2: Generate Sample Images Grid

**User Story:** As a reader, I want to see examples from each severity class, so that I can understand the visual differences between classes.

#### Acceptance Criteria

1. WHEN THE sample grid is created, THE Figure SHALL show 4-6 example images from each of the 3 severity classes
2. WHEN THE images are arranged, THE Figure SHALL use a grid layout with clear class labels
3. WHEN THE images are selected, THE Figure SHALL choose representative examples from the dataset
4. WHEN THE figure is saved, THE Figure SHALL be exported as PDF at 300 DPI to figuras_pure_classification/figura_exemplos_classes.pdf
5. WHERE THE images include labels, THE Figure SHALL annotate each image with its class and corroded percentage

### Requirement 3: Generate Architecture Comparison Diagram

**User Story:** As a reader, I want to see visual representations of the three architectures, so that I can understand their structural differences.

#### Acceptance Criteria

1. WHEN THE architecture diagram is created, THE Figure SHALL show side-by-side representations of ResNet50, EfficientNet-B0, and Custom CNN
2. WHEN THE architectures are visualized, THE Figure SHALL include layer structure, parameter counts, and key features
3. WHEN THE diagram is formatted, THE Figure SHALL use consistent styling and clear annotations
4. WHEN THE figure is saved, THE Figure SHALL be exported as PDF at 300 DPI to figuras_pure_classification/figura_arquiteturas.pdf
5. WHERE THE diagram includes technical details, THE Figure SHALL annotate parameter counts and layer types

### Requirement 4: Generate Confusion Matrices

**User Story:** As a reader, I want to see confusion matrices for all models, so that I can understand classification errors and patterns.

#### Acceptance Criteria

1. WHEN THE confusion matrices are created, THE Figure SHALL show 3 subplots (one for each model: ResNet50, EfficientNet-B0, Custom CNN)
2. WHEN THE matrices are formatted, THE Figure SHALL use heatmaps with percentage annotations
3. WHEN THE matrices are normalized, THE Figure SHALL normalize by true class (rows sum to 100%)
4. WHEN THE figure is saved, THE Figure SHALL be exported as PDF at 300 DPI to figuras_pure_classification/figura_matrizes_confusao.pdf
5. WHERE THE matrices show values, THE Figure SHALL annotate each cell with percentage values

### Requirement 5: Generate Training Curves

**User Story:** As a reader, I want to see training dynamics, so that I can understand convergence behavior and generalization.

#### Acceptance Criteria

1. WHEN THE training curves are created, THE Figure SHALL show 2 subplots: (a) loss and (b) accuracy
2. WHEN THE curves are plotted, THE Figure SHALL include training and validation curves for all 3 models
3. WHEN THE curves are formatted, THE Figure SHALL use distinct colors/styles for each model with clear legend
4. WHEN THE figure is saved, THE Figure SHALL be exported as PDF at 300 DPI to figuras_pure_classification/figura_curvas_treinamento.pdf
5. WHERE THE curves show epochs, THE Figure SHALL mark early stopping points if applicable

### Requirement 6: Generate Performance Comparison Chart

**User Story:** As a reader, I want to see accuracy comparison, so that I can quickly understand which model performs best.

#### Acceptance Criteria

1. WHEN THE performance chart is created, THE Figure SHALL show bar chart with accuracy for all 3 models
2. WHEN THE bars are formatted, THE Figure SHALL include error bars showing confidence intervals
3. WHEN THE values are annotated, THE Figure SHALL display accuracy percentages on top of bars
4. WHEN THE figure is saved, THE Figure SHALL be exported as PDF at 300 DPI to figuras_pure_classification/figura_comparacao_performance.pdf
5. WHERE THE chart includes axes, THE Figure SHALL label y-axis as "Accuracy (%)" and x-axis with model names

### Requirement 7: Generate Inference Time Comparison Chart

**User Story:** As a reader, I want to see inference time comparison, so that I can understand computational efficiency trade-offs.

#### Acceptance Criteria

1. WHEN THE inference time chart is created, THE Figure SHALL show bar chart with inference time for all 3 models
2. WHEN THE bars are formatted, THE Figure SHALL include time in milliseconds per image
3. WHEN THE values are annotated, THE Figure SHALL display throughput (images/sec) as secondary annotation
4. WHEN THE figure is saved, THE Figure SHALL be exported as PDF at 300 DPI to figuras_pure_classification/figura_tempo_inferencia.pdf
5. WHERE THE chart includes axes, THE Figure SHALL label y-axis as "Inference Time (ms)" and x-axis with model names

### Requirement 8: Compile Article with Figures

**User Story:** As an author, I want to compile the complete article with all figures, so that I can generate the final PDF for submission.

#### Acceptance Criteria

1. WHEN THE article is compiled, THE Compilation SHALL run pdflatex, bibtex, and pdflatex twice
2. WHEN THE compilation completes, THE System SHALL verify that all 7 figures are included
3. WHEN THE PDF is generated, THE System SHALL check for compilation errors and warnings
4. WHEN THE final PDF exists, THE System SHALL verify that artigo_pure_classification.pdf was created successfully
5. WHERE THE compilation fails, THE System SHALL report specific errors and suggest fixes

### Requirement 9: Use Existing Data from Classification System

**User Story:** As a developer, I want to use real data from the classification system, so that figures accurately represent actual results.

#### Acceptance Criteria

1. WHEN THE figures are generated, THE System SHALL use the actual performance metrics reported in the article text
2. WHEN THE confusion matrices are created, THE System SHALL use realistic confusion patterns consistent with reported accuracies
3. WHEN THE training curves are plotted, THE System SHALL show convergence patterns consistent with reported training dynamics
4. WHEN THE data is missing, THE System SHALL use the values explicitly stated in the article text
5. WHERE THE data needs to be synthesized, THE System SHALL ensure consistency with all reported metrics

### Requirement 10: Ensure Publication Quality

**User Story:** As an author, I want publication-quality figures, so that the article meets ASCE journal standards.

#### Acceptance Criteria

1. WHEN THE figures are created, THE Figures SHALL be exported as PDF at 300 DPI minimum resolution
2. WHEN THE fonts are used, THE Figures SHALL use Times New Roman or similar serif fonts at 10-12pt minimum
3. WHEN THE colors are chosen, THE Figures SHALL work in both color and grayscale printing
4. WHEN THE figure sizes are set, THE Figures SHALL be appropriately sized for journal publication (3-6 inches width)
5. WHERE THE figures include text, THE Text SHALL be clearly readable at publication size
