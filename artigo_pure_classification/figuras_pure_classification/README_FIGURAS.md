# Figuras para o Artigo Pure Classification

Este diretório contém as figuras necessárias para o artigo de classificação pura de corrosão.

## Figuras Necessárias

### 1. figura_fluxograma_metodologia.pdf
**Descrição:** Fluxograma completo da metodologia de classificação
**Conteúdo:**
- Pipeline completo: imagem → preprocessamento → modelo → classificação
- Processo de preparação do dataset
- Divisão train/val/test
- Treinamento com data augmentation
- Avaliação e métricas

**Como gerar:** Use ferramentas de diagramação (draw.io, PowerPoint, Visio) ou código Python com matplotlib/graphviz

### 2. figura_exemplos_classes.pdf
**Descrição:** Grid com exemplos de imagens de cada classe de severidade
**Conteúdo:**
- 4-6 exemplos por classe (Class 0, Class 1, Class 2)
- Layout em grid organizado
- Legendas indicando a classe e percentual de corrosão

**Como gerar:** Use MATLAB ou Python para criar um grid de imagens do dataset

### 3. figura_arquiteturas.pdf
**Descrição:** Comparação visual das três arquiteturas
**Conteúdo:**
- Diagrama de ResNet50 (blocos residuais, skip connections)
- Diagrama de EfficientNet-B0 (MBConv blocks, compound scaling)
- Diagrama de Custom CNN (4 conv blocks + FC layers)
- Anotações com contagem de parâmetros

**Como gerar:** Use ferramentas de diagramação ou bibliotecas como netron, visualkeras

### 4. figura_matrizes_confusao.pdf
**Descrição:** Matrizes de confusão normalizadas para os três modelos
**Conteúdo:**
- 3 subplots (um por modelo)
- Heatmaps 3x3 com anotações de percentual
- Escala de cores consistente
- Eixos: true labels (linhas) vs predicted labels (colunas)

**Como gerar:** Use os resultados do teste com MATLAB ou Python (seaborn.heatmap)

```python
import seaborn as sns
import matplotlib.pyplot as plt

# Exemplo para um modelo
cm_normalized = confusion_matrix / confusion_matrix.sum(axis=1, keepdims=True)
sns.heatmap(cm_normalized, annot=True, fmt='.2%', cmap='Blues')
```

### 5. figura_curvas_treinamento.pdf
**Descrição:** Curvas de loss e accuracy durante o treinamento
**Conteúdo:**
- 2 subplots: (a) loss, (b) accuracy
- Curvas de treino e validação para os 3 modelos
- Legenda identificando cada modelo
- Marcação do ponto de early stopping

**Como gerar:** Use os logs de treinamento com MATLAB ou Python (matplotlib)

```python
plt.subplot(1, 2, 1)
plt.plot(epochs, train_loss_resnet, label='ResNet50 Train')
plt.plot(epochs, val_loss_resnet, label='ResNet50 Val')
# ... adicionar outros modelos
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.legend()
```

### 6. figura_comparacao_performance.pdf
**Descrição:** Gráfico de barras comparando accuracy dos modelos
**Conteúdo:**
- Barras para cada modelo (ResNet50, EfficientNet-B0, Custom CNN)
- Barras de erro (confidence intervals)
- Valores de accuracy anotados no topo das barras
- Linha horizontal de referência (opcional)

**Como gerar:** Use MATLAB ou Python (matplotlib.bar)

```python
models = ['ResNet50', 'EfficientNet-B0', 'Custom CNN']
accuracies = [94.2, 91.9, 85.5]
errors = [2.1, 2.4, 3.1]
plt.bar(models, accuracies, yerr=errors, capsize=5)
plt.ylabel('Accuracy (%)')
```

### 7. figura_tempo_inferencia.pdf
**Descrição:** Gráfico de barras comparando tempo de inferência
**Conteúdo:**
- Barras para cada modelo
- Tempo em ms por imagem
- Anotação com throughput (images/sec)
- Escala apropriada

**Como gerar:** Use MATLAB ou Python (matplotlib.bar)

```python
models = ['ResNet50', 'EfficientNet-B0', 'Custom CNN']
times = [45.3, 32.7, 18.5]
plt.bar(models, times)
plt.ylabel('Inference Time (ms)')
```

## Especificações Técnicas

- **Formato:** PDF
- **Resolução:** 300 DPI mínimo
- **Tamanho:** Adequado para publicação (geralmente 3-6 polegadas de largura)
- **Fontes:** Times New Roman ou similar (compatível com ASCE)
- **Cores:** Usar escala de cinza ou cores que funcionem em impressão P&B

## Notas

- As figuras devem ser geradas a partir dos resultados reais do sistema de classificação
- Certifique-se de que todos os valores correspondem aos reportados no texto do artigo
- Use os mesmos dados do teste set (62 imagens) para todas as análises
- Mantenha consistência visual entre todas as figuras (fontes, cores, estilo)

## Comandos para Compilação

Após gerar todas as figuras em PDF, compile o artigo com:

```bash
compile_pure_classification.bat
```

Ou manualmente:
```bash
pdflatex artigo_pure_classification.tex
bibtex artigo_pure_classification
pdflatex artigo_pure_classification.tex
pdflatex artigo_pure_classification.tex
```
