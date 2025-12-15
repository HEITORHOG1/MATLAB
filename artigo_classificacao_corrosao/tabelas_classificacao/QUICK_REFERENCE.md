# Quick Reference: Classification Article Tables

## Generated Tables

### Table 1: Dataset Statistics
**File:** `tabela_dataset_estatisticas.tex`
**Label:** `\label{tab:dataset_statistics_classification}`
**Content:** 4-class distribution, train/val/test splits, class balance

### Table 2: Model Architecture Details
**File:** `tabela_arquiteturas_modelos.tex`
**Label:** `\label{tab:model_architectures_classification}`
**Content:** ResNet50, EfficientNet-B0, Custom CNN specifications

### Table 3: Training Configuration
**File:** `tabela_configuracao_treinamento.tex`
**Label:** `\label{tab:training_config_classification}`
**Content:** Hyperparameters, augmentation, hardware specs

### Table 4: Performance Metrics
**File:** `tabela_metricas_performance.tex`
**Label:** `\label{tab:performance_metrics_classification}`
**Content:** Accuracy, precision, recall, F1-scores (4 classes)
**Note:** ⚠️ Uses placeholder metrics - update after running classification

### Table 5: Inference Time Comparison
**File:** `tabela_tempo_inferencia.tex`
**Label:** `\label{tab:inference_time_classification}`
**Content:** Classification vs segmentation speed, speedup factors

### Table 6: Classification vs Segmentation Trade-offs
**File:** `tabela_comparacao_abordagens.tex`
**Label:** `\label{tab:approach_comparison_classification}`
**Content:** Qualitative comparison of both approaches

## Quick Commands

### Generate All Tables
```matlab
gerar_todas_tabelas_classificacao
```

### Generate Individual Table
```matlab
gerar_tabela_dataset_classificacao()
gerar_tabela_arquiteturas_classificacao()
gerar_tabela_configuracao_treinamento_classificacao()
gerar_tabela_metricas_performance_classificacao()
gerar_tabela_tempo_inferencia_classificacao()
gerar_tabela_comparacao_abordagens_classificacao()
```

## LaTeX Integration

### Method 1: Input Files
```latex
\input{tabelas_classificacao/tabela_dataset_estatisticas.tex}
```

### Method 2: Copy Content
Copy the entire table content from the .tex file into your article.

## Cross-References

Reference tables in your article text:
```latex
Table~\ref{tab:dataset_statistics_classification} shows...
As presented in Table~\ref{tab:performance_metrics_classification}...
```

## File Structure

Each table has 3 associated files:
- `.tex` - LaTeX table code
- `_dados.mat` - MATLAB data for reproducibility
- `_relatorio.txt` - Detailed text report

## Important Notes

1. **Table 4 uses placeholder metrics** - Update after running `executar_classificacao()`
2. All tables reflect **4-class hierarchical classification** (Classes 0, 1, 2, 3)
3. Tables follow **ASCE formatting guidelines**
4. Mock dataset created for demonstration (414 images)

## Updating with Actual Results

```matlab
% 1. Run classification system
executar_classificacao()

% 2. Regenerate performance table
gerar_tabela_metricas_performance_classificacao()

% 3. Optionally regenerate all tables
gerar_todas_tabelas_classificacao
```

## Support Files

- `README.md` - Detailed documentation
- `generation_results.mat` - Generation status tracking
- `QUICK_REFERENCE.md` - This file
