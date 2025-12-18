# Implementation Plan

- [x] 1. Setup project structure and configuration system





  - Create directory structure under `src/classification/`
  - Create subdirectories: `core/`, `models/`, `utils/`
  - Create output directory structure: `output/classification/` with subdirs `checkpoints/`, `results/`, `figures/`, `latex/`, `logs/`
  - Implement `ClassificationConfig.m` for centralized configuration management
  - _Requirements: 7.4, 8.1_

- [x] 2. Implement label generation system





  - [x] 2.1 Create LabelGenerator class


    - Implement `computeCorrodedPercentage()` method to calculate percentage from binary masks
    - Implement `assignSeverityClass()` method with configurable thresholds [10, 30]
    - Implement `generateLabelsFromMasks()` batch processing method
    - Add ErrorHandler integration for logging conversion statistics
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 7.1_



  - [x] 2.2 Create label generation script





    - Write `gerar_labels_classificacao.m` script
    - Load configuration for mask directory and thresholds
    - Call LabelGenerator to process all masks
    - Save results to CSV with columns: filename, corroded_percentage, severity_class
    - Generate summary statistics report


    - _Requirements: 1.5_

  - [x] 2.3 Write unit tests for LabelGenerator





    - Test corroded percentage calculation with synthetic masks (0%, 50%, 100%)
    - Test class assignment with boundary values (9.9%, 10.0%, 29.9%, 30.0%)
    - Test CSV format validation
    - Test error handling for invalid masks
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 3. Implement dataset management system



  - [x] 3.1 Create DatasetManager class





    - Implement constructor to load images and labels from CSV
    - Implement `prepareDatasets()` method with stratified splitting (70/15/15)
    - Implement `getDatasetStatistics()` to compute class distribution
    - Implement `applyAugmentation()` for data augmentation configuration
    - Add validation to ensure all images have corresponding labels
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 7.3_

  - [x] 3.2 Implement data augmentation pipeline






    - Configure random horizontal/vertical flips
    - Configure random rotation (-15° to +15°)
    - Configure random brightness adjustment (±20%)
    - Configure random contrast adjustment (±20%)
    - Return augmentedImageDatastore for training
    - _Requirements: 4.2_

  - [x] 3.3 Create dataset validation utilities


    - Validate image file existence and readability
    - Validate image dimensions and channels (RGB)
    - Check for class imbalance and log warnings
    - Generate dataset statistics report
    - _Requirements: 2.5_

  - [x] 3.4 Write unit tests for DatasetManager


    - Test stratified split maintains class proportions
    - Test augmentation pipeline produces valid images
    - Test dataset statistics computation
    - Test handling of missing files
    - _Requirements: 2.1, 2.2, 2.3, 2.4_


- [x] 4. Implement model architectures





  - [x] 4.1 Create ModelFactory class


    - Implement static method `createResNet50(numClasses, inputSize)`
    - Implement static method `createEfficientNetB0(numClasses, inputSize)`
    - Implement static method `createCustomCNN(numClasses, inputSize)`
    - Implement `configureTransferLearning()` helper method
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [x] 4.2 Implement ResNet50 classifier

    - Load pre-trained ResNet50 from ImageNet
    - Replace final fully connected layer with new FC(numClasses)
    - Configure layer learning rates (freeze early layers, fine-tune last blocks)
    - Set input size to 224×224×3
    - _Requirements: 3.1, 3.4_

  - [x] 4.3 Implement EfficientNet-B0 classifier

    - Load pre-trained EfficientNet-B0 from ImageNet
    - Replace classification head with new layers
    - Configure layer learning rates for transfer learning
    - Set input size to 224×224×3
    - _Requirements: 3.2, 3.4_

  - [x] 4.4 Implement Custom CNN classifier

    - Create 4 convolutional blocks: Conv → BatchNorm → ReLU → MaxPool
    - Set filter sizes: [32, 64, 128, 256]
    - Add 2 fully connected layers: FC(512) → Dropout(0.5) → FC(numClasses)
    - Configure for input size 224×224×3
    - _Requirements: 3.3_

  - [x] 4.5 Write unit tests for ModelFactory


    - Test each architecture creates valid network
    - Test output layer has correct number of classes
    - Test input size compatibility
    - Test transfer learning configuration
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 5. Implement training pipeline





  - [x] 5.1 Create TrainingEngine class


    - Implement constructor to accept model and configuration
    - Implement `train(trainDS, valDS)` method with training loop
    - Implement `plotTrainingHistory()` for visualization
    - Implement `saveCheckpoint()` for model saving
    - Add ErrorHandler integration for training logs
    - _Requirements: 4.1, 4.3, 7.1_

  - [x] 5.2 Configure training options

    - Set MaxEpochs = 50, MiniBatchSize = 32
    - Set InitialLearnRate = 1e-4 with piecewise schedule
    - Configure LearnRateDropFactor = 0.1, LearnRateDropPeriod = 10
    - Set ValidationFrequency and ValidationPatience = 10 for early stopping
    - Enable shuffle every epoch
    - _Requirements: 4.1_

  - [x] 5.3 Implement checkpointing system

    - Save best model based on validation accuracy
    - Save last epoch model for resuming
    - Store training history with each checkpoint
    - Implement checkpoint loading for resume functionality
    - _Requirements: 4.4_

  - [x] 5.4 Implement training monitoring

    - Log training loss and accuracy after each epoch
    - Log validation loss and accuracy after validation
    - Detect and log early stopping trigger
    - Generate training curves plot automatically
    - _Requirements: 4.3, 4.4_

  - [x] 5.5 Write integration tests for training


    - Test training loop with synthetic data (10 samples)
    - Test early stopping triggers correctly
    - Test checkpoint saving and loading
    - Test training history logging
    - _Requirements: 4.1, 4.3, 4.4_


- [x] 6. Implement evaluation system





  - [x] 6.1 Create EvaluationEngine class


    - Implement constructor to accept model, test datastore, and class names
    - Implement `computeMetrics()` for overall and per-class metrics
    - Implement `generateConfusionMatrix()` for confusion matrix computation
    - Implement `computeROC()` for ROC curves and AUC scores
    - Implement `measureInferenceSpeed()` for performance benchmarking
    - Implement `generateEvaluationReport()` to aggregate all results
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 6.2 Implement metrics calculation

    - Compute overall accuracy: (TP + TN) / Total
    - Compute per-class precision: TP / (TP + FP)
    - Compute per-class recall: TP / (TP + FN)
    - Compute per-class F1-score: 2 × (Precision × Recall) / (Precision + Recall)
    - Compute macro-averaged and weighted F1 scores
    - _Requirements: 5.1_


  - [x] 6.3 Implement confusion matrix generation

    - Predict all test samples
    - Build confusion matrix (rows=true, cols=predicted)
    - Normalize by row to get percentages
    - Format for visualization and LaTeX export
    - _Requirements: 5.2_

  - [x] 6.4 Implement ROC curve computation

    - Use one-vs-rest strategy for multi-class ROC
    - Compute TPR and FPR for each class
    - Calculate AUC score per class
    - Compute micro and macro-averaged ROC curves
    - _Requirements: 5.3_

  - [x] 6.5 Implement inference speed measurement

    - Warm up model with 10 inference passes
    - Measure time for 100 inference passes
    - Calculate average time per image in milliseconds
    - Calculate throughput in images/second
    - Measure GPU memory usage during inference
    - _Requirements: 5.4, 10.1, 10.2_


  - [x] 6.6 Write unit tests for EvaluationEngine

    - Test metric computation with known predictions
    - Test confusion matrix generation
    - Test ROC curve computation
    - Test inference time measurement
    - _Requirements: 5.1, 5.2, 5.3, 5.4_


- [x] 7. Implement visualization and export system



  - [x] 7.1 Create VisualizationEngine class


    - Implement static method `plotConfusionMatrix()`
    - Implement static method `plotTrainingCurves()`
    - Implement static method `plotROCCurves()`
    - Implement static method `plotInferenceComparison()`
    - Implement static method `generateLatexTable()`
    - Implement static method `exportAllFigures()`
    - Integrate with existing VisualizationHelper for data preparation
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 7.2_

  - [x] 7.2 Implement confusion matrix visualization

    - Create heatmap with Blues colormap
    - Add percentage annotations to each cell
    - Set figure size to 8×6 inches
    - Export as PNG (300 DPI) and PDF (vector)
    - _Requirements: 6.1_

  - [x] 7.3 Implement training curves visualization

    - Create subplot with Loss and Accuracy
    - Plot training (solid line) and validation (dashed line)
    - Add legend with model names
    - Enable grid for readability
    - Export in publication format
    - _Requirements: 6.2_


  - [x] 7.4 Implement ROC curves visualization

    - Plot one curve per class with different colors
    - Add diagonal reference line (random classifier)
    - Include AUC values in legend
    - Label axes: False Positive Rate, True Positive Rate
    - Export in publication format
    - _Requirements: 6.3_

  - [x] 7.5 Implement inference time comparison

    - Create bar chart with error bars
    - X-axis: Model names, Y-axis: Time (ms)
    - Add horizontal line for real-time threshold (33ms for 30fps)
    - Export in publication format
    - _Requirements: 6.4_



  - [ ] 7.6 Implement LaTeX table generation
    - Generate metrics comparison table with booktabs formatting
    - Generate confusion matrix table in LaTeX format
    - Create results summary document with figure captions
    - Export all tables to `output/classification/latex/`
    - _Requirements: 9.1, 9.2, 9.3_


  - [x] 7.7 Write integration tests for visualization

    - Test all figure generation functions
    - Test LaTeX export format validation
    - Test figure file creation and format
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_


- [x] 8. Implement model comparison and benchmarking




  - [x] 8.1 Create comparison utilities


    - Implement function to aggregate results from all models
    - Create comparative metrics table (accuracy, F1, inference time)
    - Identify best model per metric
    - Generate ranking table
    - _Requirements: 5.5, 10.3_

  - [x] 8.2 Implement segmentation vs classification comparison


    - Load segmentation model inference times from existing results
    - Compare classification inference times against segmentation
    - Calculate speedup factors
    - Generate comparison table and visualization
    - _Requirements: 10.3_

  - [x] 8.3 Implement error analysis utilities


    - Identify top-K misclassified images with highest confidence
    - Calculate correlation between predicted class and actual corroded percentage
    - Generate error analysis report with sample images
    - Provide insights for model improvement
    - _Requirements: 10.4, 10.5_

- [x] 9. Create main execution script





  - [x] 9.1 Implement executar_classificacao.m


    - Load configuration from ClassificationConfig
    - Execute label generation phase
    - Execute dataset preparation phase
    - Execute training phase for all models sequentially
    - Execute evaluation phase for all models
    - Execute visualization and export phase
    - Generate final summary report
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [x] 9.2 Add automatic path detection

    - Detect segmentation dataset location automatically
    - Validate all required directories exist
    - Create output directories if missing
    - Log all detected paths for verification
    - _Requirements: 8.2_

  - [x] 9.3 Add progress reporting

    - Display current phase and progress percentage
    - Show estimated time remaining
    - Log completion of each major step
    - Display summary statistics after each phase
    - _Requirements: 8.3_

  - [x] 9.4 Add comprehensive error handling

    - Wrap each phase in try-catch blocks
    - Log errors with ErrorHandler
    - Implement graceful degradation (continue with remaining models if one fails)
    - Generate error summary report
    - _Requirements: 8.5, 7.1_

  - [x] 9.5 Create execution log

    - Save timestamped log file for each execution
    - Include all configuration parameters
    - Log all computed metrics
    - Save execution summary with timing information
    - _Requirements: 8.5_
- [x] 10. Create documentation and examples




- [ ] 10. Create documentation and examples

  - [x] 10.1 Write README for classification module


    - Document system overview and features
    - Provide quick start guide
    - Explain configuration options
    - Include usage examples
    - Document output structure
    - _Requirements: 9.4_

  - [x] 10.2 Create configuration examples


    - Provide default configuration template
    - Document all configuration parameters
    - Include examples for different use cases
    - Add comments explaining each option
    - _Requirements: 7.4_

  - [x] 10.3 Generate results summary template


    - Create template for research article results section
    - Include figure caption templates
    - Provide LaTeX code snippets for tables
    - Add bibliography entry template
    - _Requirements: 9.3, 9.5_

  - [x] 10.4 Create user guide


    - Write step-by-step tutorial
    - Include troubleshooting section
    - Document common issues and solutions
    - Provide performance optimization tips
    - _Requirements: 9.4_



- [x] 11. End-to-end integration and testing




  - [x] 11.1 Create synthetic test dataset


    - Generate 30 synthetic images (10 per class)
    - Create corresponding binary masks with controlled corroded percentages
    - Organize in proper directory structure
    - Validate dataset integrity
    - _Requirements: 2.1, 2.4_

  - [x] 11.2 Run complete pipeline test

    - Execute executar_classificacao.m with synthetic data
    - Verify all phases complete successfully
    - Validate all output files are created
    - Check output formats and content
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [x] 11.3 Validate integration with existing infrastructure

    - Test ErrorHandler integration and logging
    - Test VisualizationHelper reuse
    - Test DataTypeConverter compatibility
    - Verify no conflicts with segmentation code
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

  - [x] 11.4 Perform performance benchmarking

    - Measure training time for each model
    - Measure inference time per image
    - Measure memory usage during training and inference
    - Compare against performance targets
    - Generate performance report
    - _Requirements: 10.1, 10.2_

  - [x] 11.5 Run full test suite

    - Execute all unit tests
    - Execute all integration tests
    - Generate test coverage report
    - Fix any failing tests
    - _Requirements: All testing requirements_
-

- [x] 12. Final validation and documentation







  - [x] 12.1 Validate all requirements are met



    - Review each requirement from requirements.md
    - Verify corresponding implementation exists
    - Test each acceptance criterion
    - Document any deviations or limitations
    - _Requirements: All requirements_


  - [x] 12.2 Generate final results with real data



    - Run complete pipeline with actual corrosion dataset
    - Generate all figures and tables for publication
    - Validate results are scientifically sound
    - Create results archive for article submission
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_



  - [x] 12.3 Create publication-ready outputs


    - Organize all figures in publication directory
    - Export all LaTeX tables
    - Generate results summary document
    - Create supplementary materials archive
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_




  - [x] 12.4 Write final project documentation





    - Update main README with classification system
    - Document system architecture
    - Provide maintenance guide
    - Include future enhancement suggestions
    - _Requirements: 9.4_



  - [x] 12.5 Prepare code for release







    - Clean up debug code and comments
    - Ensure consistent code style
    - Add license headers
    - Create release notes
    - _Requirements: 9.4_
