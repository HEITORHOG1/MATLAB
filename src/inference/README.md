# Sistema de Inferência e Análise Estatística

Este módulo implementa um sistema completo de inferência e análise estatística para modelos de segmentação U-Net e Attention U-Net.

## Componentes

### 1. InferenceEngine
Sistema principal para aplicação de modelos treinados em novas imagens.

**Funcionalidades:**
- Carregamento e gerenciamento de modelos
- Segmentação em lote de imagens
- Cálculo de métricas de performance
- Detecção de casos atípicos
- Geração de estatísticas descritivas

**Uso básico:**
```matlab
% Configurar engine
config = struct('batchSize', 8, 'outputDir', 'output/inference');
engine = InferenceEngine(config);

% Carregar modelo
engine.loadModel('path/to/model.mat', 'unet');

% Segmentar imagens
imagePaths = {'img1.jpg', 'img2.jpg', 'img3.jpg'};
results = engine.segmentImages('unet', imagePaths);
```

### 2. ResultsAnalyzer
Análise avançada de confiança e incerteza das predições.

**Funcionalidades:**
- Cálculo de confiança baseado em entropia, variância ou coerência de bordas
- Análise de incerteza usando múltiplos métodos
- Detecção automática de resultados anômalos
- Análise de distribuições estatísticas
- Correlações entre métricas

**Uso básico:**
```matlab
% Configurar analisador
config = struct('confidenceMethod', 'entropy', 'uncertaintyMethod', 'variance');
analyzer = ResultsAnalyzer(config);

% Analisar resultados
analysis = analyzer.analyzeResults(results, groundTruthPaths);
```

### 3. StatisticalAnalyzer
Análises estatísticas completas para comparação de modelos.

**Funcionalidades:**
- Testes de normalidade (Shapiro-Wilk, Kolmogorov-Smirnov)
- Testes paramétricos e não-paramétricos
- Cálculo de effect size (Cohen's d)
- Correção para múltiplas comparações (Bonferroni, FDR, Holm)
- Intervalos de confiança
- Interpretação automática dos resultados
- Geração de relatórios científicos

**Uso básico:**
```matlab
% Análise completa
results = StatisticalAnalyzer.performComprehensiveAnalysis(unetMetrics, attentionMetrics);

% Comparação simples
[pValue, effectSize, testUsed] = StatisticalAnalyzer.compareModels(data1, data2);

% Gerar relatório
report = StatisticalAnalyzer.generateScientificReport(results);
```

## Requisitos Atendidos

- **3.1**: Sistema de inferência para aplicação de modelos em novas imagens
- **3.2**: Cálculo automático de métricas e estatísticas descritivas
- **3.3**: Análise de confiança e incerteza das predições
- **3.4**: Detecção automática de casos atípicos
- **6.1**: Testes estatísticos apropriados (paramétricos/não-paramétricos)
- **6.2**: Cálculo de effect size
- **6.3**: Correção para múltiplas comparações
- **6.4**: Interpretação automática dos resultados
- **6.5**: Exportação em formatos científicos

## Estrutura de Arquivos

```
src/inference/
├── InferenceEngine.m          # Sistema principal de inferência
├── ResultsAnalyzer.m          # Análise de confiança e incerteza
├── StatisticalAnalyzer.m      # Análises estatísticas avançadas
├── demo_inference_system.m    # Demonstração do sistema
└── README.md                  # Esta documentação
```

## Exemplo Completo

```matlab
% 1. Configurar sistema
config = struct();
config.batchSize = 8;
config.outputDir = 'output/inference';
config.verbose = true;

% 2. Criar engine de inferência
engine = InferenceEngine(config);

% 3. Carregar modelos
engine.loadModel('models/unet_trained.mat', 'unet');
engine.loadModel('models/attention_unet_trained.mat', 'attention_unet');

% 4. Segmentar imagens
imagePaths = {'test1.jpg', 'test2.jpg', 'test3.jpg'};
unetResults = engine.segmentImages('unet', imagePaths);
attentionResults = engine.segmentImages('attention_unet', imagePaths);

% 5. Calcular métricas
groundTruthPaths = {'gt1.png', 'gt2.png', 'gt3.png'};
unetMetrics = engine.calculateBatchMetrics(unetResults, groundTruthPaths);
attentionMetrics = engine.calculateBatchMetrics(attentionResults, groundTruthPaths);

% 6. Análise estatística completa
statisticalResults = StatisticalAnalyzer.performComprehensiveAnalysis(...
    unetMetrics, attentionMetrics);

% 7. Análise de confiança
analyzer = ResultsAnalyzer();
confidenceAnalysis = analyzer.analyzeResults(unetResults, groundTruthPaths);

% 8. Gerar relatório
report = StatisticalAnalyzer.generateScientificReport(statisticalResults);
```

## Configurações Disponíveis

### InferenceEngine
- `batchSize`: Tamanho do lote para processamento (default: 8)
- `confidenceThreshold`: Limiar de confiança (default: 0.5)
- `outputDir`: Diretório de saída (default: 'output/inference')
- `verbose`: Output detalhado (default: true)

### ResultsAnalyzer
- `confidenceMethod`: 'entropy', 'variance', 'edge_coherence' (default: 'entropy')
- `uncertaintyMethod`: 'variance', 'entropy', 'gradient' (default: 'variance')
- `outlierThreshold`: Limiar para detecção de outliers (default: 2.0)
- `verbose`: Output detalhado (default: true)

### StatisticalAnalyzer
- `alpha`: Nível de significância (default: 0.05)
- `multipleComparisonsMethod`: 'bonferroni', 'fdr', 'holm' (default: 'bonferroni')
- `effectSizeMethod`: 'cohen_d' (default: 'cohen_d')
- `confidenceLevel`: Nível de confiança para intervalos (default: 0.95)
- `verbose`: Output detalhado (default: true)

## Demonstração

Execute o script de demonstração para ver o sistema em funcionamento:

```matlab
demo_inference_system();
```

Este script demonstra todas as funcionalidades principais usando dados simulados.

## Integração com Sistema Existente

O sistema de inferência foi projetado para integrar perfeitamente com o sistema existente:

1. **Compatibilidade**: Funciona com modelos salvos pelo ModelSaver
2. **Flexibilidade**: Suporta diferentes formatos de modelo
3. **Extensibilidade**: Fácil adição de novas métricas e métodos
4. **Performance**: Otimizado para processamento em lote

## Notas Técnicas

- Todas as classes implementam tratamento robusto de erros
- Suporte para dados com valores NaN
- Validação automática de entrada
- Documentação completa de todas as funções
- Testes de normalidade automáticos para escolha de testes apropriados
- Múltiplos métodos de detecção de outliers