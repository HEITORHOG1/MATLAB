# Implementation Plan

- [ ] 1. Create backup and prepare workspace
  - Create backup of `artigo_pure_classification.tex` as `artigo_pure_classification_backup_before_simplification.tex`
  - Verify current article compiles successfully
  - _Requirements: All requirements_

- [x] 2. Generate sample images figure



  - [x] 2.1 Create Python script to generate sample images figure

    - Write script `generate_sample_images_figure.py` to select 2 representative images per class
    - Arrange images in 3x2 grid (3 rows for classes, 2 columns for examples)
    - Add class labels and annotations
    - Save as PDF: `figuras_pure_classification/figura_sample_images.pdf`
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [x] 2.2 Execute script to generate figure

    - Run `generate_sample_images_figure.py`
    - Verify output PDF is created and looks good
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 3. Add sample images figure to article


  - Insert figure in Section 2.1 (Dataset Description) after Table 1
  - Add LaTeX code for figure with proper caption
  - Reference figure in text explaining the three classes
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 4. Simplify Section 2.4 (Evaluation Metrics)


  - Rewrite subsection to describe only validation accuracy, validation loss, and confusion matrix
  - Remove all text about precision, recall, F1-score, statistical tests
  - Add explanation of why validation metrics are the focus
  - Update mathematical formulas to show only accuracy and loss
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 5.1, 5.5_

- [x] 5. Simplify Section 3.1 (Overall Model Performance)


  - [x] 5.1 Modify Table 3 (performance_metrics)

    - Remove columns: Macro F1, Weighted F1
    - Add column: Val Loss
    - Update caption to emphasize validation metrics
    - Add validation loss values for each model
    - _Requirements: 1.1, 1.2, 4.1, 4.2, 4.4, 4.5_

  - [x] 5.2 Update text in Section 3.1

    - Remove all mentions of F1-scores
    - Add discussion of validation loss values
    - Remove statistical significance testing paragraph
    - Focus on validation accuracy and loss comparison
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 5.1, 5.2, 5.3, 5.4_

  - [x] 5.3 Delete Table 4 (mcnemar_test)

    - Remove entire statistical significance testing table
    - Remove table reference from text
    - _Requirements: 1.2, 4.2, 4.4_

- [x] 6. Delete Section 3.2 (Per-Class Performance Analysis)


  - Remove entire subsection including Table 5 (per_class_metrics)
  - Remove subsection heading and all text
  - Update section numbering for subsequent sections
  - _Requirements: 1.2, 4.2, 4.4_

- [x] 7. Keep Section 3.3 (Confusion Matrix Analysis) unchanged

  - Verify confusion matrix figure and text are intact
  - This section already focuses on confusion matrices (required metric)
  - _Requirements: 1.1, 1.3_

- [x] 8. Update Section 3.4 (Training Dynamics)


  - [x] 8.1 Modify Figure 4 caption (training_curves)

    - Update caption to emphasize validation metrics only
    - Change title to "Validation Performance During Training"
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [x] 8.2 Update text in Section 3.4

    - Remove all mentions of training accuracy and training loss
    - Focus discussion on validation curves only
    - Remove train-validation gap discussions
    - Emphasize validation convergence patterns
    - _Requirements: 1.3, 1.4, 3.1, 3.2, 3.3, 3.4, 3.5, 5.4_

- [x] 9. Update Section 3.6 (Model Complexity vs Performance)


  - Modify Table 7 to remove F1-related columns if present
  - Update text to focus on accuracy and loss only
  - Remove any precision/recall/F1 mentions
  - _Requirements: 1.1, 1.2, 4.1, 4.2, 4.4_

- [x] 10. Update Section 4 (Discussion)

  - [x] 10.1 Update Section 4.1 (Transfer Learning Effectiveness)

    - Remove F1-score mentions
    - Focus on validation accuracy and loss
    - Remove statistical test references
    - _Requirements: 1.1, 1.2, 1.4, 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 10.2 Update Section 4.2 (Architecture Comparison)

    - Remove precision/recall/F1 discussions
    - Focus on validation accuracy and loss comparisons
    - Update per-class performance discussion to reference confusion matrices only
    - _Requirements: 1.1, 1.2, 1.4, 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 10.3 Update Section 4.4 (Deployment Considerations)

    - Remove F1-score references in model selection guidance
    - Focus on validation accuracy and confusion matrix patterns
    - _Requirements: 1.1, 1.2, 5.1, 5.2, 5.3, 5.4_

  - [x] 10.4 Update Section 4.5 (Limitations)

    - Remove any precision/recall/F1 mentions
    - Focus on validation accuracy and loss limitations
    - _Requirements: 1.1, 1.2, 5.1, 5.2, 5.3, 5.4_

- [x] 11. Global search and replace


  - Search entire document for remaining instances of "precision", "recall", "F1", "McNemar", "Wilcoxon"
  - Remove or rephrase any remaining references to removed metrics
  - Verify all metric references are validation-only
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 5.1, 5.2, 5.3, 5.4_

- [x] 12. Compile and verify article


  - Run `compile_pure_classification.bat` to compile LaTeX
  - Check for compilation errors
  - Verify PDF output looks correct
  - Review all tables, figures, and text
  - _Requirements: All requirements_

- [x] 13. Final quality check


  - Verify sample images figure is present and clear
  - Confirm all tables show only validation metrics
  - Check confusion matrices are retained
  - Ensure no precision/recall/F1 mentions remain
  - Validate text consistency with tables/figures
  - _Requirements: All requirements_
