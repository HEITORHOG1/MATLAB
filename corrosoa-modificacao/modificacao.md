# Correções Realizadas - CFENG-5422R2

## ORDEM DE ENVIO DOS ARQUIVOS

| # | Arquivo | Descrição |
|---|---------|-----------|
| 001 | `001_Cover_Letter.pdf` | Carta de apresentação |
| 002 | `002_Manuscript.tex` | Manuscrito (arquivo principal) |
| 003 | `003_Referencias.bib` | Referências bibliográficas |
| 004 | `004_Fig1_Methodology_Flowchart.pdf` | Figura 1 - Fluxograma da metodologia |
| 005 | `005_Fig2_Performance_Comparison.pdf` | Figura 2 - Box plots comparação de performance |
| 006 | `006_Fig3_Learning_Curves.pdf` | Figura 3 - Curvas de aprendizado |
| 007 | `007_Fig4_Segmentation_Comparison.pdf` | Figura 4 - Comparação de segmentações |
| 008 | `008_Figure_Captions.txt` | Lista de legendas das figuras |

**Nota:** Os arquivos estão na pasta `submission_package_R1/`

---

## Solicitações do Editor (Mateus Miller)

### 1. Figuras mencionadas em ordem sequencial ✅
**Status:** Verificado e corrigido

As figuras agora são mencionadas na seguinte ordem no texto:
- **Fig. 1** (methodology_flowchart) - Seção Methodology
- **Fig. 2** (performance_comparison) - Seção Results (box plots)
- **Fig. 3** (learning_curves) - Seção Results (curvas de aprendizado)
- **Fig. 4** (segmentation_comparison) - Seção Qualitative Analysis

### 2. Remoção de legendas e solicitações de posicionamento ✅
**Status:** Concluído

Foram removidos todos os placeholders de posicionamento do corpo do artigo:
- `[Table 1 about here]`
- `[Figure 1 about here]`
- `[Table 2 about here]`
- `[Table 3 about here]`
- `[Table 4 about here]`
- `[Figure 2 about here]`
- `[Table 5 about here]`
- `[Table 6 about here]`
- `[Figure 3 about here]`
- `[Figure 4 about here]`

As menções às figuras e tabelas foram integradas naturalmente no fluxo do texto.

### 3. Tabelas em ordem sequencial ✅
**Status:** Verificado

As tabelas são mencionadas na ordem correta:
1. Table 1 - Related Works (Seção Introduction)
2. Table 2 - Dataset Characteristics (Seção Methodology)
3. Table 3 - Training Configurations (Seção Experimental Protocol)
4. Table 4 - Quantitative Results (Seção Results)
5. Table 5 - Computational Analysis (Seção Results)
6. Table 6 - Statistical Summary (Seção Results)

## Arquivos Modificados
- `submission_package_R1/Manuscript.tex`

## Próximos Passos
1. Gerar novo PDF do manuscrito
2. Fazer login no Editorial Manager (https://www.editorialmanager.com/jrncfeng/)
3. Aprovar o envio

## Notas
- O sistema da ASCE redimensiona e posiciona automaticamente tabelas e figuras
- As figuras são enviadas separadamente (Figure_1.pdf a Figure_4.pdf)
- As legendas das figuras estão no arquivo `Figure_Captions.docx.txt`
