# Requirements Document

## Introduction

This document specifies the requirements for developing an automated corrosion severity classification system for ASTM A572 Grade 50 steel structures using deep learning. The system will complement the existing segmentation-based approach by providing rapid triage capabilities for corrosion inspection workflows. The classification system will leverage the existing segmentation dataset and infrastructure, converting pixel-level annotations into image-level severity labels based on corroded area percentage.

## Glossary

- **Classification System**: The deep learning-based software component that assigns severity labels to corrosion images
- **Segmentation Dataset**: The existing collection of RGB images and binary masks used for pixel-level corrosion detection
- **Severity Label**: A categorical classification indicating corrosion level (None, Light, Moderate, Severe)
- **Label Converter**: The software module that transforms segmentation masks into classification labels
- **Training Pipeline**: The automated workflow for model training, validation, and evaluation
- **Inference Engine**: The component that performs real-time classification on new images
- **Evaluation Module**: The system that computes classification metrics and generates reports
- **Visualization System**: The component that creates confusion matrices, ROC curves, and comparative plots

## Requirements

### Requirement 1: Label Generation from Segmentation Masks

**User Story:** As a researcher, I want to automatically generate severity classification labels from existing segmentation masks, so that I can reuse the dataset without manual relabeling

#### Acceptance Criteria

1. WHEN the Label Converter receives a binary segmentation mask, THE Classification System SHALL compute the percentage of corroded pixels relative to total image pixels
2. WHEN the corroded area percentage is less than 10%, THE Classification System SHALL assign the label "Class 0 - None/Light"
3. WHEN the corroded area percentage is between 10% and 30%, THE Classification System SHALL assign the label "Class 1 - Moderate"
4. WHEN the corroded area percentage is greater than 30%, THE Classification System SHALL assign the label "Class 2 - Severe"
5. THE Classification System SHALL save the generated labels in a CSV file with columns: image_filename, corroded_percentage, severity_class

### Requirement 2: Dataset Preparation and Validation

**User Story:** As a researcher, I want to prepare and validate the classification dataset with proper train/validation/test splits, so that I can ensure reproducible and unbiased model evaluation

#### Acceptance Criteria

1. THE Classification System SHALL load all images from the existing segmentation dataset directory structure
2. THE Classification System SHALL split the dataset into 70% training, 15% validation, and 15% test sets with stratified sampling
3. WHEN the dataset split is created, THE Classification System SHALL ensure each severity class is proportionally represented in all splits
4. THE Classification System SHALL validate that each image has a corresponding label before including it in the dataset
5. THE Classification System SHALL generate a dataset statistics report showing class distribution across all splits

### Requirement 3: Deep Learning Model Implementation

**User Story:** As a researcher, I want to implement and compare multiple state-of-the-art classification architectures, so that I can identify the most effective model for corrosion severity classification

#### Acceptance Criteria

1. THE Classification System SHALL implement a ResNet50-based classification model with transfer learning from ImageNet weights
2. THE Classification System SHALL implement an EfficientNet-B0 classification model with transfer learning from ImageNet weights
3. THE Classification System SHALL implement a custom CNN architecture optimized for the corrosion classification task
4. WHEN a model is initialized, THE Classification System SHALL replace the final classification layer to output the correct number of severity classes
5. THE Classification System SHALL support configurable input image sizes (224x224, 256x256, 299x299) for different architectures

### Requirement 4: Training Pipeline with Monitoring

**User Story:** As a researcher, I want an automated training pipeline with real-time monitoring, so that I can track model performance and detect training issues early

#### Acceptance Criteria

1. THE Training Pipeline SHALL train each model architecture for a configurable number of epochs with early stopping based on validation loss
2. WHEN training begins, THE Training Pipeline SHALL apply data augmentation including random rotation, flipping, brightness adjustment, and contrast adjustment
3. THE Training Pipeline SHALL compute and log training loss, validation loss, and validation accuracy after each epoch
4. WHEN validation accuracy does not improve for 10 consecutive epochs, THE Training Pipeline SHALL stop training and restore the best model weights
5. THE Training Pipeline SHALL save training history plots showing loss and accuracy curves for both training and validation sets

### Requirement 5: Comprehensive Model Evaluation

**User Story:** As a researcher, I want comprehensive evaluation metrics and visualizations, so that I can thoroughly assess model performance and identify weaknesses

#### Acceptance Criteria

1. THE Evaluation Module SHALL compute overall accuracy, per-class precision, per-class recall, and per-class F1-score on the test set
2. THE Evaluation Module SHALL generate a confusion matrix showing predicted vs actual classifications for all severity classes
3. THE Evaluation Module SHALL compute and plot ROC curves with AUC scores for each severity class using one-vs-rest strategy
4. THE Evaluation Module SHALL calculate and report the inference time per image for each model architecture
5. THE Evaluation Module SHALL generate a comparative table showing all metrics across different model architectures

### Requirement 6: Visualization and Reporting System

**User Story:** As a researcher, I want automated generation of publication-quality figures and tables, so that I can efficiently prepare results for the research article

#### Acceptance Criteria

1. THE Visualization System SHALL generate confusion matrix heatmaps with percentage annotations for each model
2. THE Visualization System SHALL create side-by-side comparison plots of training curves for all model architectures
3. THE Visualization System SHALL generate ROC curve plots with AUC values for multi-class classification
4. THE Visualization System SHALL create bar charts comparing inference times across different architectures
5. THE Visualization System SHALL export all figures in high-resolution formats (PNG 300dpi, PDF vector) suitable for publication

### Requirement 7: Integration with Existing Infrastructure

**User Story:** As a researcher, I want the classification system to integrate seamlessly with existing project infrastructure, so that I can leverage proven utilities and maintain code consistency

#### Acceptance Criteria

1. THE Classification System SHALL reuse the existing ErrorHandler module for logging and error management
2. THE Classification System SHALL reuse the existing VisualizationHelper module for data preparation and plotting
3. THE Classification System SHALL reuse the existing DataTypeConverter module for type conversions
4. THE Classification System SHALL follow the existing project directory structure under src/classification/
5. THE Classification System SHALL use the existing configuration management system for hyperparameters and paths

### Requirement 8: Automated Execution Pipeline

**User Story:** As a researcher, I want a single-command execution script that runs the entire classification workflow, so that I can reproduce results easily and minimize manual intervention

#### Acceptance Criteria

1. THE Classification System SHALL provide an executar_classificacao.m script that runs the complete workflow from label generation to final evaluation
2. WHEN the execution script is run, THE Classification System SHALL automatically detect the segmentation dataset location
3. THE Classification System SHALL train all configured model architectures sequentially with progress reporting
4. THE Classification System SHALL generate all evaluation metrics and visualizations automatically after training completes
5. THE Classification System SHALL save a comprehensive execution log with timestamps and all computed metrics

### Requirement 9: Research Article Generation Support

**User Story:** As a researcher, I want automated generation of LaTeX tables and figure references, so that I can quickly integrate results into the research article

#### Acceptance Criteria

1. THE Classification System SHALL generate LaTeX-formatted tables for model comparison metrics
2. THE Classification System SHALL generate LaTeX-formatted confusion matrix tables
3. THE Classification System SHALL create a results summary document with figure captions and descriptions
4. THE Classification System SHALL organize all output figures in a publication-ready directory structure
5. THE Classification System SHALL generate a bibliography entry template for citing the classification system

### Requirement 10: Performance Benchmarking and Comparison

**User Story:** As a researcher, I want to compare classification performance against the segmentation approach, so that I can demonstrate the trade-offs between speed and precision

#### Acceptance Criteria

1. THE Evaluation Module SHALL measure and report average inference time per image for each classification model
2. THE Evaluation Module SHALL compute memory usage during inference for each model architecture
3. THE Evaluation Module SHALL generate a comparison table showing classification vs segmentation inference times
4. THE Evaluation Module SHALL calculate the correlation between classification predictions and actual corroded area percentages
5. THE Evaluation Module SHALL identify and report misclassified images with the highest confidence errors for error analysis
