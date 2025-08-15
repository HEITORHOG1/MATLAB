# Sistema de Visualização Avançada

Este módulo implementa um sistema completo de visualização e comparação avançada para análise de modelos de segmentação, especificamente U-Net vs Attention U-Net.

## Componentes Principais

### 1. ComparisonVisualizer
Classe principal para criação de visualizações comparativas detalhadas.

**Funcionalidades:**
- Comparações lado a lado (4 painéis: original, ground truth, U-Net, Attention U-Net)
- Mapas de diferença com heatmaps destacando divergências entre modelos
- Sobreposição de métricas (IoU, Dice, Accuracy) diretamente nas imagens segmentadas
- Configuração flexível de formato, resolução e estilo

**Uso básico:**
```matlab
% Criar visualizador
visualizer = ComparisonVisualizer('outputDir', 'results/visualizations/');

% Comparação lado a lado
outputPath = visualizer.createSideBySideComparison(...
    originalImage, groundTruth, unetPred, attentionPred, metrics);

% Mapa de diferenças
diffPath = visualizer.createDifferenceMap(unetPred, attentionPred);

% Overlay de métricas
overlayPath = visualizer.createMetricsOverlay(...
    originalImage, segmentation, metrics, 'U-Net');
```

### 2. HTMLGalleryGenerator
Gerador de galerias HTML interativas para navegação e exploração visual.

**Funcionalidades:**
- Galeria HTML responsiva com thumbnails
- Navegação por teclado (setas, ESC)
- Modal para visualização ampliada com zoom
- Organização automática por sessões
- Metadados e métricas integradas

**Uso básico:**
```matlab
% Criar gerador
generator = HTMLGalleryGenerator('outputDir', 'results/gallery/');

% Gerar galeria
galleryPath = generator.generateComparisonGallery(allResults, ...
    'sessionId', 'experiment_001');
```

### 3. StatisticalPlotter
Gerador de gráficos estatísticos comparativos e análises de significância.

**Funcionalidades:**
- Boxplots comparativos entre modelos
- Gráficos de distribuição sobrepostas
- Testes estatísticos automáticos (t-test, Mann-Whitney)
- Cálculo de effect size (Cohen's d)
- Correção para múltiplas comparações
- Gráficos de evolução da performance durante treinamento

**Uso básico:**
```matlab
% Criar plotter
plotter = StatisticalPlotter('outputDir', 'results/statistics/');

% Comparação estatística
statsPath = plotter.plotStatisticalComparison(unetMetrics, attentionMetrics);

% Evolução da performance
evolutionPath = plotter.createPerformanceEvolution(trainingHistory);
```

### 4. TimeLapseGenerator
Gerador de vídeos time-lapse mostrando evolução durante treinamento.

**Funcionalidades:**
- Vídeos de evolução dos gradientes por camada
- Time-lapse da evolução das predições
- Comparação visual entre modelos ao longo do tempo
- Configuração de frame rate e qualidade
- Suporte a múltiplos formatos (MP4, AVI)

**Uso básico:**
```matlab
% Criar gerador
generator = TimeLapseGenerator('outputDir', 'results/videos/', 'frameRate', 2);

% Vídeo de gradientes
videoPath = generator.createTrainingEvolutionVideo(gradientHistory);

% Vídeo de predições
predVideoPath = generator.createPredictionEvolutionVideo(...
    predictionHistory, originalImage, groundTruth);

% Vídeo comparativo
compVideoPath = generator.createComparisonVideo(...
    unetHistory, attentionHistory, originalImage, groundTruth);
```

## Estrutura de Arquivos

```
src/visualization/
├── ComparisonVisualizer.m      # Visualizações comparativas
├── HTMLGalleryGenerator.m      # Galerias HTML interativas
├── StatisticalPlotter.m        # Gráficos estatísticos
├── TimeLapseGenerator.m        # Vídeos time-lapse
├── demo_visualization_system.m # Demonstração completa
├── validate_visualization_system.m # Validação e testes
└── README.md                   # Esta documentação
```

## Configuração e Instalação

### Pré-requisitos
- MATLAB R2018b ou superior
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox (opcional, para testes estatísticos avançados)
- Computer Vision Toolbox (opcional, para funcionalidades de vídeo)

### Instalação
1. Adicione o diretório `src/` ao path do MATLAB:
```matlab
addpath(genpath('src/'));
```

2. Execute a demonstração para verificar funcionamento:
```matlab
demo_visualization_system();
```

3. Execute a validação para testes completos:
```matlab
results = validate_visualization_system();
```

## Exemplos de Uso

### Exemplo Completo: Pipeline de Visualização

```matlab
% 1. Configurar dados
originalImage = imread('image.jpg');
groundTruth = imread('mask.png') > 0;
unetPred = segmentWithUNet(originalImage);
attentionPred = segmentWithAttentionUNet(originalImage);

% Calcular métricas
metrics = calculateMetrics(unetPred, attentionPred, groundTruth);

% 2. Criar visualizações comparativas
visualizer = ComparisonVisualizer('outputDir', 'results/comparisons/');

% Comparação lado a lado
comparisonPath = visualizer.createSideBySideComparison(...
    originalImage, groundTruth, unetPred, attentionPred, metrics, ...
    'title', 'Comparação de Modelos - Imagem 001');

% Mapa de diferenças
diffPath = visualizer.createDifferenceMap(unetPred, attentionPred, ...
    'title', 'Análise de Divergências');

% 3. Análise estatística
plotter = StatisticalPlotter('outputDir', 'results/statistics/');

% Gerar dados de múltiplas execuções
allUnetMetrics = collectMetrics('unet', imageList);
allAttentionMetrics = collectMetrics('attention', imageList);

% Análise comparativa
statsPath = plotter.plotStatisticalComparison(...
    allUnetMetrics, allAttentionMetrics, ...
    'includeTests', true, ...
    'title', 'Análise Estatística Comparativa');

% 4. Galeria HTML
generator = HTMLGalleryGenerator('outputDir', 'results/gallery/');

% Preparar dados da galeria
allResults = {};
for i = 1:length(imageList)
    result = struct();
    result.imagePath = imageList{i};
    result.comparisonPath = comparisonPaths{i};
    result.metrics = allMetrics{i};
    allResults{i} = result;
end

% Gerar galeria
galleryPath = generator.generateComparisonGallery(allResults, ...
    'sessionId', datestr(now, 'yyyymmdd_HHMMSS'));

fprintf('Visualizações geradas:\n');
fprintf('- Comparação: %s\n', comparisonPath);
fprintf('- Estatísticas: %s\n', statsPath);
fprintf('- Galeria: %s\n', galleryPath);
```

### Exemplo: Vídeo Time-lapse

```matlab
% Configurar gerador de vídeo
generator = TimeLapseGenerator('outputDir', 'results/videos/', ...
    'frameRate', 3, 'quality', 85);

% Criar vídeo de evolução dos gradientes
% (assumindo que gradientHistory foi coletado durante treinamento)
videoPath = generator.createTrainingEvolutionVideo(gradientHistory, ...
    'title', 'Evolução dos Gradientes - U-Net', ...
    'modelName', 'U-Net');

% Criar vídeo de evolução das predições
% (assumindo que predictionHistory foi coletado durante treinamento)
predVideoPath = generator.createPredictionEvolutionVideo(...
    predictionHistory, originalImage, groundTruth, ...
    'title', 'Convergência das Predições', ...
    'modelName', 'Attention U-Net');

fprintf('Vídeos gerados:\n');
fprintf('- Gradientes: %s\n', videoPath);
fprintf('- Predições: %s\n', predVideoPath);
```

## Configurações Avançadas

### ComparisonVisualizer

```matlab
visualizer = ComparisonVisualizer(...
    'outputDir', 'custom/path/', ...
    'figureFormat', 'pdf', ...        % png, pdf, eps, svg
    'saveHighRes', true, ...           % Alta resolução
    'showProgress', false);            % Suprimir mensagens
```

### HTMLGalleryGenerator

```matlab
generator = HTMLGalleryGenerator(...
    'outputDir', 'web/gallery/', ...
    'galleryTitle', 'Meus Experimentos', ...
    'imagesPerPage', 50, ...           % Imagens por página
    'thumbnailSize', 150);             % Tamanho dos thumbnails
```

### StatisticalPlotter

```matlab
plotter = StatisticalPlotter(...
    'outputDir', 'analysis/stats/', ...
    'figureFormat', 'svg', ...
    'saveHighRes', true);

% Configurar métricas específicas
statsPath = plotter.plotStatisticalComparison(...
    unetMetrics, attentionMetrics, ...
    'metrics', {'iou', 'dice'}, ...    % Apenas IoU e Dice
    'includeTests', true);             % Incluir testes estatísticos
```

### TimeLapseGenerator

```matlab
generator = TimeLapseGenerator(...
    'outputDir', 'videos/', ...
    'videoFormat', 'mp4', ...          % mp4, avi
    'frameRate', 5, ...                % Frames por segundo
    'quality', 90);                    % Qualidade (0-100)
```

## Integração com Sistema Existente

O sistema de visualização foi projetado para integrar-se perfeitamente com o sistema existente:

```matlab
% No arquivo executar_comparacao.m, adicionar:

% Após treinamento e avaliação
if strcmp(opcao, '5') % Nova opção para visualizações
    fprintf('Gerando visualizações avançadas...\n');
    
    % Criar visualizador
    visualizer = ComparisonVisualizer();
    
    % Gerar comparações para todas as imagens processadas
    for i = 1:length(resultados.imagens)
        comparisonPath = visualizer.createSideBySideComparison(...
            resultados.imagens{i}, ...
            resultados.groundTruth{i}, ...
            resultados.unet{i}, ...
            resultados.attention{i}, ...
            resultados.metricas{i});
    end
    
    % Análise estatística
    plotter = StatisticalPlotter();
    statsPath = plotter.plotStatisticalComparison(...
        resultados.metricas_unet, resultados.metricas_attention);
    
    fprintf('Visualizações salvas em: output/visualizations/\n');
end
```

## Troubleshooting

### Problemas Comuns

1. **Erro de VideoWriter**: Funcionalidade de vídeo não disponível
   - Solução: Instalar Computer Vision Toolbox ou usar versão mais recente do MATLAB

2. **Erro de memória com imagens grandes**: 
   - Solução: Redimensionar imagens antes da visualização ou processar em lotes menores

3. **Galeria HTML não carrega imagens**:
   - Verificar se os caminhos das imagens estão corretos
   - Certificar-se de que as imagens foram copiadas para o diretório da galeria

4. **Testes estatísticos falham**:
   - Verificar se há dados suficientes (mínimo 3 amostras por grupo)
   - Instalar Statistics and Machine Learning Toolbox

### Logs e Debugging

Para ativar logs detalhados:

```matlab
% Ativar modo verbose
visualizer = ComparisonVisualizer('showProgress', true);
plotter = StatisticalPlotter('showProgress', true);
```

Para debugging avançado, verificar arquivos de log em:
- `output/logs/visualization_debug.log`

## Contribuição

Para contribuir com melhorias:

1. Execute os testes de validação
2. Documente novas funcionalidades
3. Mantenha compatibilidade com sistema existente
4. Adicione testes para novas funcionalidades

## Requisitos Atendidos

Este sistema atende aos seguintes requisitos da especificação:

- **5.1**: Comparações lado a lado detalhadas ✓
- **5.2**: Mapas de diferença com heatmaps ✓  
- **5.3**: Sobreposição de métricas nas imagens ✓
- **5.4**: Galeria HTML interativa com navegação ✓
- **5.5**: Vídeos time-lapse de evolução ✓

## Versão

Sistema de Visualização Avançada v1.0
Compatível com MATLAB R2018b+
Última atualização: Agosto 2025