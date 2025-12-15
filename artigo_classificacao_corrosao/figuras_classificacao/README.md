# Classification Article Figures Directory

This directory contains all figures for the classification article in high-resolution PDF format (300 DPI).

## Expected Figures

### Figure 1: Methodology Flowchart
**File:** `figura_fluxograma_metodologia.pdf`
- Complete pipeline from image to 4-class classification
- Label generation process visualization
- Model training and evaluation workflow

### Figure 2: Sample Images with Classifications
**File:** `figura_exemplos_classes.pdf`
- Grid showing examples from each of 4 severity classes
- Model predictions vs ground truth
- Confidence scores

### Figure 3: Model Architecture Comparison
**File:** `figura_arquiteturas.pdf`
- Visual representation of ResNet50, EfficientNet-B0, Custom CNN
- Parameter counts and key layer structures

### Figure 4: Confusion Matrices (4x4)
**File:** `figura_matrizes_confusao.pdf`
- Heatmaps for all three models
- Percentage annotations for 4 classes
- Color-coding for clarity

### Figure 5: Training Curves
**File:** `figura_curvas_treinamento.pdf`
- Loss and accuracy evolution for all models
- Validation curves included
- Consistent styling

### Figure 6: Inference Time Comparison
**File:** `figura_comparacao_tempo.pdf`
- Bar chart comparing classification models vs segmentation
- Speedup factors annotated
- Appropriate scale

### Figure 7: ROC Curves (Optional)
**File:** `figura_curvas_roc.pdf`
- One-vs-rest ROC curves for multi-class
- AUC scores for each class
- Model comparison

## Figure Requirements

- **Format:** PDF (vector graphics preferred)
- **Resolution:** 300 DPI minimum
- **Color:** RGB color space
- **Fonts:** Embedded fonts
- **Size:** Appropriate for journal column width (typically 3.5" or 7" wide)

## Generation Notes

Figures should be generated using MATLAB scripts in the `src/classification/` directory. Each figure generation script should:
1. Load results from the classification system
2. Create publication-quality visualizations
3. Export to PDF format with proper settings
4. Save to this directory with the correct filename
