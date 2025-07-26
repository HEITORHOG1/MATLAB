# API Reference - Sistema de Comparação U-Net vs Attention U-Net

## Visão Geral

Esta documentação fornece referência completa da API para todas as classes do sistema de comparação, incluindo as otimizações de performance implementadas na versão 3.0.

## Índice

- [Classes Principais](#classes-principais)
- [Módulo de Dados](#módulo-de-dados)
- [Módulo de Modelos](#módulo-de-modelos)
- [Módulo de Avaliação](#módulo-de-avaliação)
- [Módulo de Visualização](#módulo-de-visualização)
- [Utilitários](#utilitários)
- [Sistema de Monitoramento](#sistema-de-monitoramento)

---

## Classes Principais

### MainInterface

Interface principal do sistema que fornece menu interativo e coordena todas as operações.

#### Construtor
```matlab
interface = MainInterface()
```

#### Métodos Principais

##### `run()`
Inicia a interface principal do sistema.

**Uso:**
```matlab
interface = MainInterface();
interface.run();
```

##### `startSystemMonitoring(sessionName)`
Inicia monitoramento do sistema.

**Parâmetros:**
- `sessionName` (string, opcional): Nome da sessão de monitoramento

**Exemplo:**
```matlab
interface.startSystemMonitoring('minha_sessao');
```

##### `displaySystemStatus()`
Exibe status atual do sistema incluindo uso de memória, CPU e GPU.

##### `generatePerformanceReport()`
Gera relatório completo de performance do sistema.

### ConfigManager

Gerencia todas as configurações do sistema com detecção automática e validação.

#### Construtor
```matlab
configMgr = ConfigManager()
```

#### Métodos Principais

##### `loadConfig()`
Carrega configuração existente ou cria uma nova.

**Retorno:**
- `config` (struct): Estrutura de configuração

##### `saveConfig(config)`
Salva configuração no disco.

**Parâmetros:**
- `config` (struct): Estrutura de configuração

##### `validateConfig(config)`
Valida estrutura de configuração.

**Parâmetros:**
- `config` (struct): Configuração a validar

**Retorno:**
- `isValid` (logical): true se configuração é válida

### ComparisonController

Orquestra todo o processo de comparação entre modelos U-Net e Attention U-Net.

#### Construtor
```matlab
controller = ComparisonController(config)
```

**Parâmetros:**
- `config` (struct): Configuração do sistema

#### Métodos Principais

##### `runFullComparison()`
Executa comparação completa entre os modelos.

**Retorno:**
- `results` (struct): Resultados da comparação

##### `runQuickTest()`
Executa teste rápido com subset de dados.

**Retorno:**
- `results` (struct): Resultados do teste rápido

---

## Módulo de Dados

### DataLoader

Classe unificada para carregamento de dados com lazy loading e cache inteligente.

#### Construtor
```matlab
loader = DataLoader(config)
```

**Parâmetros:**
- `config` (struct): Configuração com `imageDir` e `maskDir`

#### Propriedades

##### Lazy Loading
- `lazyLoadingEnabled` (logical): Habilita lazy loading
- `maxMemoryUsage` (double): Limite de memória em GB

#### Métodos Principais

##### `loadData(varargin)`
Carrega dados de imagens e máscaras.

**Parâmetros Opcionais:**
- `'UseCache'` (logical): Usar cache (padrão: true)
- `'Verbose'` (logical): Saída verbosa (padrão: true)

**Retorno:**
- `images` (cell): Caminhos das imagens
- `masks` (cell): Caminhos das máscaras

**Exemplo:**
```matlab
[images, masks] = loader.loadData('UseCache', true, 'Verbose', false);
```

##### `splitData(images, masks, varargin)`
Divide dados em conjuntos de treino, validação e teste.

**Parâmetros:**
- `images` (cell): Caminhos das imagens
- `masks` (cell): Caminhos das máscaras

**Parâmetros Opcionais:**
- `'TrainRatio'` (double): Proporção para treino (padrão: 0.7)
- `'ValRatio'` (double): Proporção para validação (padrão: 0.2)
- `'TestRatio'` (double): Proporção para teste (padrão: 0.1)
- `'Shuffle'` (logical): Embaralhar dados (padrão: true)
- `'Seed'` (double): Semente para reprodutibilidade (padrão: 42)

**Retorno:**
- `trainData` (struct): Dados de treino
- `valData` (struct): Dados de validação
- `testData` (struct): Dados de teste

##### `lazyLoadSample(index)`
Carrega uma amostra específica usando lazy loading.

**Parâmetros:**
- `index` (double): Índice da amostra

**Retorno:**
- `img` (array): Imagem carregada
- `mask` (array): Máscara carregada

##### `getPerformanceStats()`
Retorna estatísticas de performance do carregamento.

**Retorno:**
- `stats` (struct): Estatísticas detalhadas

### DataPreprocessor

Classe para pré-processamento de dados com cache inteligente e otimizações de memória.

#### Construtor
```matlab
preprocessor = DataPreprocessor(config, varargin)
```

**Parâmetros:**
- `config` (struct): Configuração com `inputSize`

**Parâmetros Opcionais:**
- `'EnableCache'` (logical): Habilitar cache (padrão: true)
- `'CacheMaxSize'` (double): Tamanho máximo do cache (padrão: 1000)
- `'ClassNames'` (string array): Nomes das classes
- `'LabelIDs'` (double array): IDs dos labels

#### Métodos Principais

##### `preprocess(data, varargin)`
Pré-processa dados de imagem e máscara.

**Parâmetros:**
- `data` (cell): {imagem, máscara} ou caminhos para arquivos

**Parâmetros Opcionais:**
- `'IsTraining'` (logical): Modo de treinamento (padrão: false)
- `'UseAugmentation'` (logical): Usar data augmentation (padrão: false)
- `'UseCache'` (logical): Usar cache (padrão: true)

**Retorno:**
- `data` (cell): {imagem_processada, máscara_processada}

##### `preprocessBatch(dataBatch, varargin)`
Pré-processa um lote de dados para otimização de performance.

**Parâmetros:**
- `dataBatch` (cell): Lote de dados

**Parâmetros Opcionais:**
- `'UseParallel'` (logical): Processamento paralelo (padrão: false)

**Retorno:**
- `data` (cell): Dados preprocessados

##### `optimizeMemoryUsage()`
Executa otimização automática de memória.

##### `getCacheStats()`
Retorna estatísticas do cache.

**Retorno:**
- `stats` (struct): Estatísticas do cache

---

## Módulo de Modelos

### ModelTrainer

Classe para treinamento de modelos com detecção automática de GPU e otimizações.

#### Construtor
```matlab
trainer = ModelTrainer(config)
```

#### Métodos Principais

##### `trainUNet(trainData, valData, config)`
Treina modelo U-Net clássico.

**Parâmetros:**
- `trainData` (struct): Dados de treinamento
- `valData` (struct): Dados de validação
- `config` (struct): Configuração de treinamento

**Retorno:**
- `net` (SeriesNetwork): Rede treinada

##### `trainAttentionUNet(trainData, valData, config)`
Treina modelo Attention U-Net.

**Parâmetros:**
- `trainData` (struct): Dados de treinamento
- `valData` (struct): Dados de validação
- `config` (struct): Configuração de treinamento

**Retorno:**
- `net` (SeriesNetwork): Rede treinada

### ModelArchitectures

Classe com métodos estáticos para criação de arquiteturas de rede.

#### Métodos Estáticos

##### `createUNet(inputSize, numClasses)`
Cria arquitetura U-Net clássica.

**Parâmetros:**
- `inputSize` (array): Tamanho da entrada [H, W, C]
- `numClasses` (double): Número de classes

**Retorno:**
- `lgraph` (layerGraph): Grafo da rede

##### `createAttentionUNet(inputSize, numClasses)`
Cria arquitetura Attention U-Net.

**Parâmetros:**
- `inputSize` (array): Tamanho da entrada [H, W, C]
- `numClasses` (double): Número de classes

**Retorno:**
- `lgraph` (layerGraph): Grafo da rede

---

## Módulo de Avaliação

### MetricsCalculator

Classe para cálculo de métricas de avaliação.

#### Métodos Principais

##### `calculateIoU(pred, gt)`
Calcula Intersection over Union.

**Parâmetros:**
- `pred` (array): Predições
- `gt` (array): Ground truth

**Retorno:**
- `iou` (double): Valor IoU

##### `calculateDice(pred, gt)`
Calcula coeficiente Dice.

**Parâmetros:**
- `pred` (array): Predições
- `gt` (array): Ground truth

**Retorno:**
- `dice` (double): Coeficiente Dice

##### `calculateAllMetrics(pred, gt)`
Calcula todas as métricas simultaneamente.

**Parâmetros:**
- `pred` (array): Predições
- `gt` (array): Ground truth

**Retorno:**
- `metrics` (struct): Todas as métricas

### StatisticalAnalyzer

Classe para análises estatísticas avançadas.

#### Métodos Principais

##### `performTTest(metrics1, metrics2)`
Executa teste t para comparar métricas.

**Parâmetros:**
- `metrics1` (array): Métricas do primeiro modelo
- `metrics2` (array): Métricas do segundo modelo

**Retorno:**
- `results` (struct): Resultados do teste

##### `calculateConfidenceIntervals(metrics)`
Calcula intervalos de confiança.

**Parâmetros:**
- `metrics` (array): Valores das métricas

**Retorno:**
- `intervals` (struct): Intervalos de confiança

---

## Sistema de Monitoramento

### SystemMonitor

Classe principal para monitoramento completo do sistema.

#### Construtor
```matlab
monitor = SystemMonitor(varargin)
```

**Parâmetros Opcionais:**
- `'EnableMonitoring'` (logical): Habilitar monitoramento (padrão: true)
- `'EnableAutoReport'` (logical): Relatórios automáticos (padrão: true)
- `'ReportInterval'` (double): Intervalo de relatórios em segundos (padrão: 300)

#### Métodos Principais

##### `startSystemMonitoring(sessionName)`
Inicia sessão completa de monitoramento.

**Parâmetros:**
- `sessionName` (string, opcional): Nome da sessão

##### `stopSystemMonitoring()`
Para sessão de monitoramento e gera relatório final.

##### `checkSystemHealth()`
Verifica saúde do sistema e gera alertas se necessário.

##### `generatePerformanceReport()`
Gera relatório completo de performance.

**Retorno:**
- `report` (string): Relatório formatado

##### `getMonitoringStats()`
Retorna estatísticas de monitoramento.

**Retorno:**
- `stats` (struct): Estatísticas detalhadas

### ResourceMonitor

Classe para monitoramento de recursos do sistema.

#### Construtor
```matlab
monitor = ResourceMonitor(varargin)
```

#### Métodos Principais

##### `getResourceInfo()`
Obtém informações atuais de recursos do sistema.

**Retorno:**
- `resourceInfo` (struct): Informações de recursos

##### `startProfiling(profileName)`
Inicia profiling de performance.

**Parâmetros:**
- `profileName` (string): Nome do perfil

##### `stopProfiling(profileName)`
Para profiling e gera relatório.

**Parâmetros:**
- `profileName` (string): Nome do perfil

##### `generateOptimizationRecommendations()`
Gera recomendações de otimização baseadas no monitoramento.

**Retorno:**
- `recommendations` (cell): Recomendações

### PerformanceProfiler

Classe para profiling automático de performance e identificação de gargalos.

#### Construtor
```matlab
profiler = PerformanceProfiler(varargin)
```

#### Métodos Principais

##### `startFunctionProfiling(functionName)`
Inicia profiling de uma função específica.

**Parâmetros:**
- `functionName` (string): Nome da função

##### `endFunctionProfiling(functionName)`
Finaliza profiling de uma função específica.

**Parâmetros:**
- `functionName` (string): Nome da função

##### `identifyBottlenecks()`
Identifica gargalos de performance baseado nos dados coletados.

**Retorno:**
- `bottlenecks` (cell): Gargalos identificados

##### `generateBottleneckReport()`
Gera relatório detalhado de gargalos.

**Retorno:**
- `report` (string): Relatório formatado

##### `getProfilingStats()`
Retorna estatísticas de profiling.

**Retorno:**
- `stats` (struct): Estatísticas

---

## Utilitários

### Logger

Sistema de logging com níveis e cores.

#### Construtor
```matlab
logger = Logger(component, varargin)
```

### ProgressBar

Barra de progresso visual.

#### Construtor
```matlab
progressBar = ProgressBar(total, varargin)
```

### TimeEstimator

Estimador de tempo para operações longas.

#### Construtor
```matlab
estimator = TimeEstimator()
```

---

## Exemplos de Uso

### Exemplo Básico
```matlab
% Inicializar sistema
interface = MainInterface();
interface.run();
```

### Exemplo com Monitoramento
```matlab
% Criar monitor de sistema
monitor = SystemMonitor('EnableMonitoring', true);

% Iniciar monitoramento
monitor.startSystemMonitoring('minha_sessao');

% Executar comparação
controller = ComparisonController(config);
results = controller.runFullComparison();

% Parar monitoramento e gerar relatório
monitor.stopSystemMonitoring();
```

### Exemplo de Lazy Loading
```matlab
% Configurar DataLoader com lazy loading
config.imageDir = 'img/original';
config.maskDir = 'img/masks';

loader = DataLoader(config);
loader.lazyLoadingEnabled = true;
loader.maxMemoryUsage = 2; % 2GB

% Carregar dados
[images, masks] = loader.loadData();

% Carregar amostra específica
[img, mask] = loader.lazyLoadSample(1);
```

### Exemplo de Cache Inteligente
```matlab
% Configurar preprocessor com cache
preprocessor = DataPreprocessor(config, 'EnableCache', true, 'CacheMaxSize', 1000);

% Preprocessar dados
data = preprocessor.preprocess({img, mask}, 'IsTraining', true);

% Verificar estatísticas do cache
stats = preprocessor.getCacheStats();
fprintf('Taxa de acerto do cache: %.2f%%\n', stats.hitRate * 100);
```

---

## Notas de Versão

### Versão 3.0 - Performance Optimization
- Implementado lazy loading para datasets grandes
- Adicionado cache inteligente de dados preprocessados
- Sistema de monitoramento completo de recursos
- Profiling automático para identificação de gargalos
- Otimização automática de memória
- Relatórios de performance com recomendações

### Compatibilidade
- MATLAB R2019b ou superior
- Deep Learning Toolbox
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox (opcional)
- Parallel Computing Toolbox (opcional)

### Requisitos de Sistema
- Memória: Mínimo 4GB, recomendado 8GB+
- GPU: Opcional, mas recomendado para treinamento
- Espaço em disco: Mínimo 2GB para dados e resultados