# Sistema de Exportação e Integração Externa

Este módulo implementa um sistema completo de exportação e integração externa para o sistema de segmentação de imagens, permitindo exportar resultados, modelos e relatórios em formatos científicos padrão.

## Componentes Principais

### 1. DataExporter
Exporta métricas e dados em formatos científicos.

**Funcionalidades:**
- Exportação para CSV, Excel e LaTeX
- Comparação automática entre modelos
- Formatação científica com precisão configurável
- Geração de metadados automática

**Uso:**
```matlab
exporter = DataExporter();
exporter.exportToCSV(metrics, 'results.csv');
exporter.exportMetricsComparison(unetMetrics, attentionMetrics, 'comparison');
```

### 2. ModelExporter
Exporta modelos treinados para formatos padrão da indústria.

**Funcionalidades:**
- Exportação ONNX (quando disponível)
- Exportação para TensorFlow
- Exportação para PyTorch
- Geração de metadados de modelo
- Validação de modelos exportados

**Uso:**
```matlab
exporter = ModelExporter();
exporter.exportToONNX(model, 'model.onnx', 'InputSize', [256, 256, 1]);
exporter.exportForTensorFlow(model, 'model_tf');
```

### 3. ReportGenerator
Gera relatórios científicos completos automaticamente.

**Funcionalidades:**
- Relatórios HTML interativos
- Relatórios LaTeX para publicação
- Sumários executivos
- Relatórios de metodologia
- Compilação automática de PDF

**Uso:**
```matlab
generator = ReportGenerator();
generator.generateFullReport(results, 'report.html');
generator.generateLaTeXReport(results, 'paper.tex');
```

### 4. BackupManager
Sistema de backup e versionamento com integração Git LFS.

**Funcionalidades:**
- Backup automático com versionamento
- Integração Git LFS para arquivos grandes
- Compressão inteligente
- Validação de integridade
- Limpeza automática de backups antigos

**Uso:**
```matlab
manager = BackupManager('GitLFSEnabled', true);
manager.createBackup('model.mat', 'model_backup_v1');
manager.initializeGitLFS();
```

### 5. VisualizationExporter
Exporta visualizações em alta resolução para publicação.

**Funcionalidades:**
- Exportação em múltiplos formatos (PNG, TIFF, EPS, PDF, SVG)
- Grades de comparação automáticas
- Gráficos de métricas estatísticas
- Sobreposições de segmentação
- Curvas de treinamento
- Configuração de DPI e qualidade

**Uso:**
```matlab
exporter = VisualizationExporter('DefaultDPI', 300);
exporter.exportComparisonGrid(images, 'comparison.png');
exporter.exportMetricsPlot(metrics, 'metrics.png', 'CompareModels', true);
```

### 6. DICOMExporter
Geração de metadados compatíveis com padrões médicos.

**Funcionalidades:**
- Exportação DICOM (quando Image Processing Toolbox disponível)
- Metadados compatíveis com padrões médicos
- Validação de conformidade DICOM
- Exportação de metadados em JSON
- Relatórios de conformidade

**Uso:**
```matlab
exporter = DICOMExporter();
exporter.exportSegmentationAsDICOM(segmentation, 'seg.dcm');
exporter.generateDICOMComplianceReport(dicomFiles);
```

### 7. ExportManager
Gerenciador central que coordena todos os componentes.

**Funcionalidades:**
- Interface unificada para todas as exportações
- Exportação completa em um comando
- Validação automática de resultados
- Geração de índices de sessão
- Limpeza automática de arquivos antigos

**Uso:**
```matlab
manager = ExportManager();
results = manager.exportCompleteResults(segmentationResults, 'session_001');
manager.validateExports(results);
```

## Estrutura de Arquivos Gerada

```
output/
├── data/                    # Dados em formatos científicos
│   ├── *.csv               # Métricas em CSV
│   ├── *.xlsx              # Métricas em Excel
│   └── *.tex               # Tabelas LaTeX
├── models/                  # Modelos exportados
│   ├── *.onnx              # Modelos ONNX
│   ├── *_tensorflow/       # Modelos TensorFlow
│   ├── *_pytorch/          # Modelos PyTorch
│   └── *_metadata.json     # Metadados dos modelos
├── reports/                 # Relatórios científicos
│   ├── *.html              # Relatórios HTML
│   ├── *.tex               # Relatórios LaTeX
│   └── *.pdf               # PDFs compilados
├── figures/                 # Visualizações
│   ├── *.png               # Figuras PNG
│   ├── *.tiff              # Figuras TIFF
│   └── *.eps               # Figuras EPS
├── backups/                 # Backups versionados
│   ├── *.zip               # Backups comprimidos
│   └── *_metadata.json     # Metadados de backup
├── dicom/                   # Arquivos DICOM
│   ├── *.dcm               # Arquivos DICOM
│   └── *_metadata.json     # Metadados DICOM
└── sessions/                # Sessões organizadas
    └── session_YYYYMMDD_HHMMSS/
        ├── models/
        ├── segmentations/
        ├── comparisons/
        └── statistics/
```

## Integração com Sistema Existente

### 1. Integração Manual

Adicionar ao menu principal (`executar_comparacao.m`):

```matlab
case '6'  % Nova opção
    fprintf('\n=== EXPORTAÇÃO DE RESULTADOS ===\n');
    
    % Configurar exportação
    exportManager = ExportManager();
    
    % Preparar resultados (assumindo que já existem)
    results = struct();
    results.unet_metrics = unet_results;
    results.attention_metrics = attention_results;
    results.config = config;
    
    % Exportar
    sessionName = sprintf('session_%s', datestr(now, 'yyyyMMdd_HHmmss'));
    exportResults = exportManager.exportCompleteResults(results, sessionName);
    
    fprintf('Exportação concluída: %d arquivos gerados\n', ...
        length(exportResults.exported_files));
```

### 2. Integração Automática

Adicionar ao final dos scripts de treinamento:

```matlab
% No final de treinar_unet_simples.m
if exist('auto_export', 'var') && auto_export
    try
        exportManager = ExportManager();
        results = struct();
        results.metrics = final_metrics;
        results.model = net;
        results.config = training_options;
        
        modelName = sprintf('%s_%s', model_type, datestr(now, 'yyyyMMdd_HHmmss'));
        exportManager.exportCompleteResults(results, modelName);
        
        fprintf('Resultados exportados automaticamente\n');
    catch ME
        warning('Erro na exportação automática: %s', ME.message);
    end
end
```

### 3. Configuração de Git LFS

Para projetos que usam Git, configurar Git LFS:

```matlab
% Configurar Git LFS uma vez
exportManager = ExportManager('EnableGitLFS', true);
exportManager.setupGitLFS();
```

Isso criará automaticamente `.gitattributes` com:
```
*.mat filter=lfs diff=lfs merge=lfs -text
*.h5 filter=lfs diff=lfs merge=lfs -text
*.onnx filter=lfs diff=lfs merge=lfs -text
*.zip filter=lfs diff=lfs merge=lfs -text
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.tiff filter=lfs diff=lfs merge=lfs -text
```

## Exemplos de Uso

### Exportação Básica de Métricas

```matlab
% Dados de exemplo
unetMetrics = struct('iou', rand(10,1), 'dice', rand(10,1));
attentionMetrics = struct('iou', rand(10,1), 'dice', rand(10,1));

% Exportar
exporter = DataExporter();
files = exporter.exportMetricsComparison(unetMetrics, attentionMetrics, 'comparison');

fprintf('Arquivos gerados:\n');
fprintf('  CSV: %s\n', files.csv);
fprintf('  Excel: %s\n', files.excel);
fprintf('  LaTeX: %s\n', files.latex);
```

### Geração de Relatório Científico

```matlab
% Preparar dados
results = struct();
results.unet_metrics = unetMetrics;
results.attention_metrics = attentionMetrics;
results.config = struct('learning_rate', 0.001, 'epochs', 50);

% Gerar relatório
generator = ReportGenerator();
htmlReport = generator.generateFullReport(results, 'scientific_report.html', ...
    'Title', 'Comparação U-Net vs Attention U-Net', ...
    'Author', 'Pesquisador');

latexReport = generator.generateLaTeXReport(results, 'paper.tex');

% Tentar compilar PDF
if generator.compileLatexReport(latexReport)
    fprintf('PDF gerado com sucesso\n');
end
```

### Exportação de Visualizações

```matlab
% Criar visualizações
visualExporter = VisualizationExporter('DefaultDPI', 300);

% Grade de comparação
images = {original, groundTruth, unetSeg, attentionSeg};
labels = {'Original', 'Ground Truth', 'U-Net', 'Attention U-Net'};
visualExporter.exportComparisonGrid(images, 'comparison.tiff', ...
    'Labels', labels, 'ShowColorbar', true);

% Gráfico de métricas
metrics = struct('unet', unetMetrics, 'attention', attentionMetrics);
visualExporter.exportMetricsPlot(metrics, 'metrics_boxplot.eps', ...
    'PlotType', 'boxplot', 'CompareModels', true);
```

### Backup e Versionamento

```matlab
% Configurar backup com Git LFS
backupManager = BackupManager('GitLFSEnabled', true, 'MaxBackups', 5);

% Criar backup de modelo
backupPath = backupManager.createBackup('trained_model.mat', 'model_v1');

% Listar backups
backups = backupManager.listBackups();
fprintf('Backups disponíveis: %d\n', length(backups));

% Restaurar backup
backupManager.restoreBackup(backupPath, 'restored_model.mat');
```

## Requisitos

### Obrigatórios
- MATLAB R2019b ou superior
- Statistics and Machine Learning Toolbox (para análises estatísticas)

### Opcionais
- Deep Learning Toolbox (para exportação ONNX)
- Image Processing Toolbox (para exportação DICOM)
- Git e Git LFS (para versionamento)
- LaTeX (para compilação de PDFs)

## Configuração

### Configuração Básica

```matlab
% Configuração mínima
exportManager = ExportManager('OutputDirectory', 'meus_resultados');
```

### Configuração Avançada

```matlab
% Configuração completa
exportManager = ExportManager(...
    'OutputDirectory', 'output', ...
    'SessionId', 'experimento_001', ...
    'EnableGitLFS', true, ...
    'EnableDICOM', true);

% Configurar componentes individuais
exportManager.dataExporter.precisionDigits = 6;
exportManager.visualizationExporter.defaultDPI = 600;
exportManager.reportGenerator.reportLanguage = 'en';
```

## Troubleshooting

### Problemas Comuns

1. **Erro "ONNX export not available"**
   - Solução: Instalar Deep Learning Toolbox ou usar exportação alternativa

2. **Erro "DICOM export failed"**
   - Solução: Instalar Image Processing Toolbox ou desabilitar DICOM

3. **Erro "Git LFS not found"**
   - Solução: Instalar Git LFS ou desabilitar versionamento Git

4. **Erro "LaTeX compilation failed"**
   - Solução: Instalar LaTeX ou usar apenas arquivos .tex

### Logs e Debugging

```matlab
% Habilitar logs detalhados
exportManager.enableVerboseLogging = true;

% Validar configuração
exportManager.validateConfiguration();

% Testar componentes
exportManager.runDiagnostics();
```

## Contribuição

Para adicionar novos formatos de exportação:

1. Criar nova classe em `src/export/`
2. Implementar interface padrão com métodos `export*`
3. Adicionar ao `ExportManager.initializeExporters()`
4. Criar testes em `tests/`
5. Atualizar documentação

## Licença

Este sistema é parte do projeto de segmentação de imagens e segue a mesma licença do projeto principal.