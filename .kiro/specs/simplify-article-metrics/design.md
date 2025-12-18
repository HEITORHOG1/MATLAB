# Design Document

## Overview

Este design detalha as modificações necessárias no artigo `artigo_pure_classification.tex` para simplificar as métricas conforme solicitado pelo professor. O foco será em manter apenas acurácia de validação, loss de validação e matriz de confusão, além de adicionar uma figura com exemplos visuais das classes de corrosão.

## Architecture

### Document Structure

O artigo LaTeX será modificado nas seguintes seções:
1. **Introduction**: Adicionar figura com exemplos de imagens
2. **Methodology - Evaluation Metrics**: Simplificar descrição de métricas
3. **Results**: Remover tabelas/texto de precision, recall, F1, testes estatísticos
4. **Discussion**: Atualizar para refletir métricas simplificadas

### Files to Modify

```
artigo_pure_classification.tex (main document)
figuras_pure_classification/ (add new sample images figure)
```

## Components and Interfaces

### Component 1: Sample Images Figure

**Purpose**: Adicionar figura mostrando exemplos das 3 classes de corrosão

**Location**: Section 2.1 (Dataset Description) ou Section 1 (Introduction)

**Design**:
```latex
\begin{figure}[htbp]
\centering
\includegraphics[width=0.95\textwidth]{figura_sample_images.pdf}
\caption{Representative examples from the corrosion dataset showing the three severity classes: (a) Class 0 (None/Light, $P_c < 10\%$) with minimal surface rust, (b) Class 1 (Moderate, $10\% \leq P_c < 30\%$) with visible corrosion and surface degradation, and (c) Class 2 (Severe, $P_c \geq 30\%$) with extensive metal loss and structural concerns. Each row shows two examples from the same class.}
\label{fig:sample_images}
\end{figure}
```

**Image Requirements**:
- 2 examples per class (total 6 images)
- Arranged in 3 rows x 2 columns grid
- Clear visual distinction between classes
- Real images from actual dataset

### Component 2: Simplified Metrics Table

**Purpose**: Substituir tabela complexa por tabela simples com apenas acurácia e loss de validação

**Current Table** (`tab:performance_metrics`):
- Columns: Model, Accuracy, Macro F1, Weighted F1, Parameters
- Needs: Remove F1 columns

**New Design**:
```latex
\begin{table}[htbp]
\caption{Validation Performance Metrics for Classification Models}
\label{tab:performance_metrics}
\centering
\begin{tabular}{lccc}
\toprule
\textbf{Model} & \textbf{Val Accuracy} & \textbf{Val Loss} & \textbf{Parameters} \\
\midrule
ResNet50 & 94.2\% $\pm$ 2.1\% & 0.185 $\pm$ 0.032 & 25M \\
EfficientNet-B0 & 91.9\% $\pm$ 2.4\% & 0.243 $\pm$ 0.041 & 5M \\
Custom CNN & 85.5\% $\pm$ 3.1\% & 0.412 $\pm$ 0.058 & 2M \\
\bottomrule
\end{tabular}
\end{table}
```

### Component 3: Remove Per-Class Metrics Table

**Action**: Delete entire `tab:per_class_metrics` table

**Rationale**: Precision, recall, F1-score não são mais necessários

### Component 4: Remove Statistical Tests Table

**Action**: Delete entire `tab:mcnemar_test` table

**Rationale**: Testes estatísticos não são mais necessários

### Component 5: Simplified Training Curves

**Purpose**: Modificar figura de training curves para mostrar apenas validação

**Current Figure** (`fig:training_curves`):
- Shows both training and validation curves
- Needs: Remove training curves, keep only validation

**New Design**:
```latex
\begin{figure}[htbp]
\centering
\includegraphics[width=0.85\textwidth]{figura_validation_curves.pdf}
\caption{Validation performance during training: (a) validation loss and (b) validation accuracy evolution. ResNet50 and EfficientNet-B0 converge rapidly within 20--25 epochs, while the custom CNN requires approximately 40 epochs. Early stopping was applied when validation accuracy plateaued for 10 consecutive epochs.}
\label{fig:validation_curves}
\end{figure}
```

### Component 6: Keep Confusion Matrices

**Action**: Maintain `fig:confusion_matrices` as is

**Rationale**: Confusion matrices são uma das métricas solicitadas

### Component 7: Keep Inference Time Table

**Action**: Maintain `tab:inference_time` with minor modifications

**Rationale**: Tempo de inferência é informação útil, apenas ajustar para enfatizar validação

## Data Models

### Metrics to Keep

```python
validation_metrics = {
    'accuracy': float,  # Overall validation accuracy
    'loss': float,      # Validation loss (categorical cross-entropy)
    'confusion_matrix': np.ndarray  # NxN matrix for N classes
}
```

### Metrics to Remove

```python
# Remove these from all tables and text:
- precision (per-class and macro/weighted)
- recall (per-class and macro/weighted)
- F1-score (per-class and macro/weighted)
- Statistical tests (McNemar, Wilcoxon)
- Training accuracy
- Training loss
```

## Text Modifications

### Section 2.4: Evaluation Metrics

**Current**: Describes accuracy, precision, recall, F1, statistical tests

**New**: Simplify to describe only:
1. Validation accuracy
2. Validation loss (categorical cross-entropy)
3. Confusion matrix
4. Why validation metrics are the focus

**New Text**:
```latex
\subsection{Evaluation Metrics}
\label{subsec:metrics}

Model performance was evaluated exclusively on the held-out test set using validation metrics to assess generalization to unseen data. We report three complementary metrics:

\textbf{Validation Accuracy} measures the fraction of correctly classified images in the test set, providing an overall assessment of model performance. Accuracy is computed as $\text{Acc} = \frac{\text{Correct Predictions}}{\text{Total Predictions}}$.

\textbf{Validation Loss} quantifies the categorical cross-entropy loss on the test set, measuring how well the predicted probability distributions match the true class labels. Lower loss indicates better calibrated predictions: $\mathcal{L} = -\frac{1}{N}\sum_{i=1}^{N}\sum_{c=1}^{C} y_{ic} \log(\hat{y}_{ic})$, where $y_{ic}$ is the true label and $\hat{y}_{ic}$ is the predicted probability for class $c$.

\textbf{Confusion Matrix} visualizes the distribution of predictions across classes, showing which classes are most frequently confused. The matrix is normalized by true class to display the percentage of each true class assigned to each predicted class, facilitating identification of systematic misclassification patterns.

We focus exclusively on validation metrics rather than training metrics because validation performance on held-out data provides an unbiased estimate of how the model will perform on new, unseen images in real-world deployment. Training metrics can be misleadingly high due to overfitting, where the model memorizes training examples rather than learning generalizable patterns. Validation metrics are the true measure of model quality for practical applications.

All metrics include 95\% confidence intervals computed through bootstrap resampling with 1,000 iterations.
```

### Section 3.1: Overall Model Performance

**Modifications**:
- Remove all mentions of F1-scores
- Remove statistical significance testing discussion
- Focus on validation accuracy and loss
- Keep confusion matrix discussion

### Section 3.2: Per-Class Performance Analysis

**Action**: Delete entire subsection

**Rationale**: Per-class precision/recall/F1 não são mais necessários

### Section 3.3: Confusion Matrix Analysis

**Action**: Keep as is (already focuses on confusion matrices)

### Section 3.5: Model Complexity vs Performance

**Modifications**:
- Remove F1-score references
- Focus on accuracy and loss only

### Section 4: Discussion

**Modifications**:
- Update all text to reference only validation accuracy, loss, and confusion matrices
- Remove precision/recall/F1 discussions
- Remove statistical test discussions
- Emphasize why validation metrics are sufficient

## Error Handling

### Missing Validation Loss Values

If validation loss values are not currently in the document:
- Extract from training logs/results files
- Add to simplified performance table
- Ensure consistency with accuracy values

### Figure Generation

If sample images figure doesn't exist:
- Create Python script to generate figure from dataset
- Select 2 representative images per class
- Arrange in 3x2 grid
- Save as PDF in `figuras_pure_classification/`

## Testing Strategy

### Verification Steps

1. **Compilation Test**: Ensure LaTeX compiles without errors
   ```bash
   pdflatex artigo_pure_classification.tex
   ```

2. **Content Verification**:
   - Check all tables contain only validation metrics
   - Verify no precision/recall/F1 mentions remain
   - Confirm sample images figure is present
   - Validate confusion matrices are retained

3. **Consistency Check**:
   - Ensure text matches tables
   - Verify figure references are correct
   - Check caption accuracy

4. **Visual Inspection**:
   - Review PDF output
   - Verify sample images are clear
   - Check table formatting
   - Confirm figure quality

### Rollback Plan

- Keep backup of original file: `artigo_pure_classification_backup.tex`
- If issues arise, can restore from backup
- Git version control for tracking changes

## Implementation Order

1. **Create backup** of current article
2. **Generate sample images figure** (if needed)
3. **Modify Section 2.4** (Evaluation Metrics)
4. **Simplify Section 3.1** (Overall Performance)
5. **Delete Section 3.2** (Per-Class Performance)
6. **Update Section 3.5** (Complexity Analysis)
7. **Modify Section 4** (Discussion)
8. **Add sample images figure** to Introduction or Methodology
9. **Remove statistical tests table**
10. **Simplify performance metrics table**
11. **Update training curves figure** (validation only)
12. **Compile and verify** PDF output

## Notes

- All changes maintain scientific rigor
- Focus on validation metrics aligns with best practices
- Sample images improve reader understanding
- Simplified presentation makes article more accessible
- Confusion matrices provide detailed class-level insights
