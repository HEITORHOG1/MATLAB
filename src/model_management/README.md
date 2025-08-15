# Sistema de Gerenciamento de Modelos

Este diretório contém o sistema completo de gerenciamento de modelos para o projeto de segmentação U-Net vs Attention U-Net.

## Visão Geral

O sistema de gerenciamento de modelos adiciona funcionalidades essenciais ao pipeline de treinamento existente:

- **Salvamento automático** de redes treinadas com metadados completos
- **Carregamento seguro** de modelos pré-treinados com validação
- **Versionamento automático** e limpeza inteligente de modelos antigos
- **Interface de linha de comando** para gerenciamento de modelos
- **Integração transparente** com o código existente

## Componentes

### 1. ModelSaver.m
Responsável pelo salvamento automático de modelos com metadados completos.

**Funcionalidades:**
- Salvamento com timestamp e métricas de performance
- Geração automática de metadados (arquitetura, configuração, sistema)
- Compressão inteligente para economizar espaço
- Salvamento de histórico de gradientes
- Limpeza automática de modelos antigos

**Exemplo de uso:**
```matlab
% Inicializar
config = struct('saveDirectory', 'saved_models', 'maxModels', 10);
modelSaver = ModelSaver(config);

% Salvar modelo
metricas = struct('iou_mean', 0.85, 'dice_mean', 0.82);
savedPath = modelSaver.saveModel(net, 'unet', metricas, trainingConfig);
```

### 2. ModelLoader.m
Carregamento seguro de modelos pré-treinados com validação de compatibilidade.

**Funcionalidades:**
- Carregamento com validação automática
- Listagem de modelos disponíveis com métricas
- Seleção automática do melhor modelo
- Verificação de compatibilidade com configuração atual
- Carregamento de histórico de gradientes

**Exemplo de uso:**
```matlab
% Listar modelos disponíveis
models = ModelLoader.listAvailableModels('saved_models');

% Carregar melhor modelo
[model, metadata] = ModelLoader.loadBestModel('saved_models', 'iou_mean');

% Validar compatibilidade
isValid = ModelLoader.validateModelCompatibility(modelPath, currentConfig);
```

### 3. ModelVersioning.m
Sistema de versionamento automático com limpeza inteligente.

**Funcionalidades:**
- Criação automática de versões com numeração sequencial
- Limpeza baseada em número máximo de versões e tempo de retenção
- Compressão de versões antigas
- Backup automático antes de restaurar versões
- Relatórios de uso de espaço e versões

**Exemplo de uso:**
```matlab
% Inicializar sistema de versionamento
versioningSystem = ModelVersioning(config);

% Criar nova versão
versionPath = versioningSystem.createNewVersion(modelPath, 'unet');

% Listar versões
versions = versioningSystem.listVersions('unet');

% Restaurar versão específica
[model, metadata] = versioningSystem.restoreVersion('unet', 3);
```

### 4. TrainingIntegration.m
Integração com o pipeline de treinamento existente.

**Funcionalidades:**
- Modificação automática de scripts de treinamento
- Aprimoramento de configurações com funcionalidades de salvamento
- Callbacks para salvamento e versionamento automáticos
- Geração de scripts aprimorados
- Processamento de resultados de treinamento

**Exemplo de uso:**
```matlab
% Inicializar integração
trainingIntegration = TrainingIntegration(config);

% Aprimorar configuração
enhancedConfig = trainingIntegration.enhanceTrainingConfig(originalConfig);

% Salvar modelo treinado
savedPath = trainingIntegration.saveTrainedModel(net, 'unet', metricas, config);
```

### 5. ModelManagerCLI.m
Interface de linha de comando para gerenciamento interativo.

**Funcionalidades:**
- Modo interativo com menu de opções
- Execução de comandos específicos
- Listagem e busca de modelos
- Comparação entre modelos
- Geração de relatórios
- Limpeza do sistema

**Exemplo de uso:**
```matlab
% Inicializar CLI
cli = ModelManagerCLI(config);

% Modo interativo
cli.runInteractiveMode();

% Executar comandos específicos
cli.executeCommand('list');
cli.executeCommand('search', 'unet');
cli.executeCommand('report');
```

## Scripts Aprimorados

### treinar_unet_simples_enhanced.m
Versão aprimorada do script de treinamento U-Net com:
- Carregamento automático de modelos pré-treinados
- Salvamento automático com versionamento
- Métricas aprimoradas (IoU, Dice, F1, Precisão, Recall, FPS)
- Avaliação mais detalhada

### comparacao_unet_attention_enhanced.m
Versão aprimorada da comparação com:
- Uso de modelos pré-treinados quando disponíveis
- Salvamento automático de ambos os modelos
- Análise estatística avançada (testes t, effect size)
- Visualizações aprimoradas com métricas sobrepostas
- Relatórios detalhados em múltiplos formatos

## Instalação e Configuração

### 1. Adicionar ao Path
```matlab
addpath('src/model_management');
```

### 2. Configuração Básica
```matlab
config = struct();
config.saveDirectory = 'saved_models';
config.maxVersionsPerModel = 5;
config.compressionEnabled = true;
config.autoSaveEnabled = true;
config.autoVersionEnabled = true;
config.retentionDays = 30;
```

### 3. Inicialização dos Componentes
```matlab
modelSaver = ModelSaver(config);
versioningSystem = ModelVersioning(config);
trainingIntegration = TrainingIntegration(config);
cli = ModelManagerCLI(config);
```

## Exemplos de Uso

### Treinamento com Salvamento Automático
```matlab
% Configurar para usar sistema aprimorado
config.loadPretrainedModel = true;
config.autoSaveEnabled = true;

% Executar treinamento aprimorado
result = treinar_unet_simples_enhanced(config);
```

### Comparação com Modelos Pré-treinados
```matlab
% Configurar para usar modelos existentes
config.usePretrainedModels = true;
config.autoVersionEnabled = true;

% Executar comparação aprimorada
result = comparacao_unet_attention_enhanced(config);
```

### Gerenciamento via CLI
```matlab
% Inicializar CLI
cli = ModelManagerCLI();

% Listar modelos
cli.executeCommand('list');

% Carregar melhor modelo
cli.executeCommand('load');  % Modo interativo

% Gerar relatório
cli.executeCommand('report');

% Limpeza do sistema
cli.executeCommand('cleanup');
```

### Carregamento Manual de Modelos
```matlab
% Listar modelos disponíveis
models = ModelLoader.listAvailableModels();

% Carregar modelo específico
[model, metadata] = ModelLoader.loadModel(models(1).filepath);

% Carregar melhor modelo por métrica
[bestModel, bestMetadata] = ModelLoader.loadBestModel('saved_models', 'dice_mean');
```

## Estrutura de Diretórios Criada

```
saved_models/
├── unet_20250815_143022.mat              # Modelos salvos
├── attention_unet_20250815_144530.mat
├── versions/                             # Versões dos modelos
│   ├── unet/
│   │   ├── unet_v001_20250815_143022.mat
│   │   └── unet_v002_20250815_150000.mat
│   └── attention_unet/
│       └── attention_unet_v001_20250815_144530.mat
└── backups/                              # Backups automáticos
    └── unet_backup_20250815_160000.mat
```

## Metadados Salvos

Cada modelo salvo inclui metadados completos:

```matlab
metadata = struct(
    'modelType', 'unet',
    'timestamp', datetime('now'),
    'version', '1.0',
    'architecture', struct(...),
    'performance', struct(...),
    'trainingConfig', struct(...),
    'systemInfo', struct(...),
    'datasetInfo', struct(...)
);
```

## Demonstração Completa

Execute a demonstração completa do sistema:

```matlab
demo_model_management();
```

Esta função demonstra todas as funcionalidades do sistema de gerenciamento de modelos.

## Integração com Código Existente

O sistema foi projetado para integração transparente:

1. **Scripts existentes continuam funcionando** sem modificações
2. **Scripts aprimorados** oferecem funcionalidades adicionais
3. **Configuração opcional** - funcionalidades podem ser habilitadas/desabilitadas
4. **Compatibilidade total** com estrutura de dados existente

## Requisitos

- MATLAB R2019b ou superior
- Deep Learning Toolbox
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox (para análise estatística)

## Troubleshooting

### Problema: Erro ao salvar modelo
**Solução:** Verificar permissões de escrita no diretório de destino

### Problema: Modelo não carrega
**Solução:** Verificar compatibilidade com `ModelLoader.validateModelCompatibility()`

### Problema: Versões não são criadas
**Solução:** Verificar se `autoVersionEnabled = true` na configuração

### Problema: CLI não responde
**Solução:** Verificar se todos os componentes estão no path do MATLAB

## Contribuição

Para adicionar novas funcionalidades:

1. Seguir padrão de nomenclatura existente
2. Incluir documentação completa
3. Adicionar testes na função de demonstração
4. Manter compatibilidade com código existente

## Licença

Este sistema faz parte do projeto de comparação U-Net vs Attention U-Net e segue a mesma licença do projeto principal.