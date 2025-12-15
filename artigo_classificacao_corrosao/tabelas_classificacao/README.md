# Classification Article Tables Directory

This directory contains all tables for the classification article in LaTeX format.

## Expected Tables

### Table 1: Dataset Statistics
**File:** `tabela_dataset_estatisticas.tex`
- Total images and distribution across 4 classes
- Train/val/test split sizes
- Class balance metrics

### Table 2: Model Architecture Details
**File:** `tabela_arquiteturas_modelos.tex`
- Parameters, layers, input size for each model
- Pre-training dataset information
- Modifications for 4-class classification

### Table 3: Training Configuration
**File:** `tabela_configuracao_treinamento.tex`
- Hyperparameters for all models
- Data augmentation settings
- Hardware specifications

### Table 4: Performance Metrics
**File:** `tabela_metricas_performance.tex`
- Accuracy, precision, recall, F1-score for 4 classes
- Per-class and overall metrics
- Confidence intervals

### Table 5: Inference Time Comparison
**File:** `tabela_tempo_inferencia.tex`
- Classification models (ms per image)
- Segmentation model (ms per image)
- Speedup factors
- Hardware specifications

### Table 6: Classification vs Segmentation Trade-offs
**File:** `tabela_comparacao_abordagens.tex`
- Accuracy, speed, memory, use cases
- Qualitative comparison

## Table Format Requirements

All tables should follow ASCE formatting guidelines:
- Use `booktabs` package for professional appearance
- Include proper captions with `\caption{}`
- Use `\label{}` for cross-referencing
- Align numerical data appropriately
- Include units where applicable
- Use consistent decimal places

## Generation Notes

Tables should be generated using MATLAB scripts that:
1. Extract metrics from classification results
2. Format data according to ASCE guidelines
3. Generate LaTeX table code
4. Save to this directory with the correct filename

Example table structure:
```latex
\begin{table}
\caption{Table Caption Here}
\label{tab:label_here}
\centering
\small
\renewcommand{\arraystretch}{1.25}
\begin{tabular}{l c c c}
\hline\hline
\textbf{Column 1} & \textbf{Column 2} & \textbf{Column 3} & \textbf{Column 4} \\
\hline
Data row 1 & Value & Value & Value \\
Data row 2 & Value & Value & Value \\
\hline\hline
\end{tabular}
\normalsize
\end{table}
```
