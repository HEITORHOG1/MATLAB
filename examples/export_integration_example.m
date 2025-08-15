function export_integration_example()
    % export_integration_example - Exemplo de integração do sistema de exportação
    %
    % Este exemplo demonstra como integrar o sistema de exportação
    % com o sistema existente de comparação U-Net vs Attention U-Net
    
    fprintf('=== EXEMPLO DE INTEGRAÇÃO DO SISTEMA DE EXPORTAÇÃO ===\n\n');
    
    try
        % 1. Simular resultados de segmentação (normalmente viriam do sistema principal)
        fprintf('1. Preparando dados de exemplo...\n');
        segmentationResults = prepareExampleData();
        
        % 2. Configurar sistema de exportação
        fprintf('2. Configurando sistema de exportação...\n');
        exportManager = setupExportSystem();
        
        % 3. Exportar resultados completos
        fprintf('3. Executando exportação completa...\n');
        exportResults = performCompleteExport(exportManager, segmentationResults);
        
        % 4. Demonstrar funcionalidades específicas
        fprintf('4. Demonstrando funcionalidades específicas...\n');
        demonstrateSpecificFeatures(exportManager, segmentationResults);
        
        % 5. Validar exportações
        fprintf('5. Validando exportações...\n');
        validateExportResults(exportManager, exportResults);
        
        % 6. Mostrar como integrar com sistema existente
        fprintf('6. Exemplo de integração com sistema existente...\n');
        showSystemIntegration();
        
        fprintf('\n=== EXEMPLO CONCLUÍDO COM SUCESSO ===\n');
        fprintf('Verifique os arquivos gerados em: output/example_session/\n');
        
    catch ME
        fprintf('\nERRO NO EXEMPLO: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function segmentationResults = prepareExampleData()
    % Prepara dados de exemplo simulando resultados reais
    
    % Simular métricas de U-Net
    numImages = 20;
    unetMetrics = struct();
    unetMetrics.iou = 0.75 + 0.15 * randn(numImages, 1); % IoU médio ~0.75
    unetMetrics.dice = 0.80 + 0.12 * randn(numImages, 1); % Dice médio ~0.80
    unetMetrics.accuracy = 0.85 + 0.10 * randn(numImages, 1); % Accuracy média ~0.85
    
    % Garantir valores válidos (0-1)
    unetMetrics.iou = max(0, min(1, unetMetrics.iou));
    unetMetrics.dice = max(0, min(1, unetMetrics.dice));
    unetMetrics.accuracy = max(0, min(1, unetMetrics.accuracy));
    
    % Simular métricas de Attention U-Net (ligeiramente melhores)
    attentionMetrics = struct();
    attentionMetrics.iou = unetMetrics.iou + 0.03 + 0.02 * randn(numImages, 1);
    attentionMetrics.dice = unetMetrics.dice + 0.025 + 0.015 * randn(numImages, 1);
    attentionMetrics.accuracy = unetMetrics.accuracy + 0.02 + 0.01 * randn(numImages, 1);
    
    % Garantir valores válidos
    attentionMetrics.iou = max(0, min(1, attentionMetrics.iou));
    attentionMetrics.dice = max(0, min(1, attentionMetrics.dice));
    attentionMetrics.accuracy = max(0, min(1, attentionMetrics.accuracy));
    
    % Simular imagens de exemplo
    sampleImages = struct();
    sampleImages.original = rand(256, 256); % Imagem original
    sampleImages.ground_truth = rand(256, 256) > 0.7; % Ground truth
    sampleImages.unet_segmentation = rand(256, 256) > 0.65; % Segmentação U-Net
    sampleImages.attention_segmentation = rand(256, 256) > 0.6; % Segmentação Attention U-Net
    
    % Simular histórico de treinamento
    epochs = 50;
    trainingHistory = struct();
    trainingHistory.TrainingLoss = 2 * exp(-0.1 * (1:epochs)) + 0.1 * randn(1, epochs);
    trainingHistory.ValidationLoss = 2.2 * exp(-0.08 * (1:epochs)) + 0.15 * randn(1, epochs);
    trainingHistory.TrainingAccuracy = 1 - exp(-0.08 * (1:epochs)) + 0.05 * randn(1, epochs);
    trainingHistory.ValidationAccuracy = 1 - 1.1 * exp(-0.07 * (1:epochs)) + 0.08 * randn(1, epochs);
    
    % Simular configuração experimental
    config = struct();
    config.learning_rate = 0.001;
    config.batch_size = 16;
    config.epochs = epochs;
    config.optimizer = 'adam';
    config.loss_function = 'dice_loss';
    config.data_augmentation = true;
    config.input_size = [256, 256, 1];
    config.model_architecture = 'attention_unet';
    
    % Simular modelos treinados (estruturas simplificadas)
    models = struct();
    models.unet = createSimpleModelStructure('U-Net');
    models.attention_unet = createSimpleModelStructure('Attention U-Net');
    
    % Consolidar resultados
    segmentationResults = struct();
    segmentationResults.unet_metrics = unetMetrics;
    segmentationResults.attention_metrics = attentionMetrics;
    segmentationResults.sample_images = sampleImages;
    segmentationResults.training_history = trainingHistory;
    segmentationResults.config = config;
    segmentationResults.models = models;
    segmentationResults.session_id = sprintf('example_session_%s', datestr(now, 'yyyyMMdd_HHmmss'));
    segmentationResults.processing_date = datestr(now);
    
    fprintf('  ✓ Dados de exemplo preparados (%d imagens simuladas)\n', numImages);
end

function model = createSimpleModelStructure(modelType)
    % Cria estrutura de modelo simplificada para exemplo
    
    model = struct();
    model.type = modelType;
    model.architecture = sprintf('%s_architecture', lower(strrep(modelType, ' ', '_')));
    model.parameters = randi([1000000, 5000000]); % Número simulado de parâmetros
    model.training_time = randi([300, 1800]); % Tempo de treinamento em segundos
    model.final_loss = 0.1 + 0.05 * rand(); % Loss final
    model.final_accuracy = 0.85 + 0.1 * rand(); % Accuracy final
    model.creation_date = datestr(now);
end

function exportManager = setupExportSystem()
    % Configura o sistema de exportação
    
    % Criar diretório de saída se não existir
    outputDir = 'output';
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Inicializar ExportManager com configurações apropriadas
    exportManager = ExportManager(...
        'OutputDirectory', outputDir, ...
        'SessionId', sprintf('example_%s', datestr(now, 'yyyyMMdd_HHmmss')), ...
        'EnableGitLFS', false, ... % Desabilitado para exemplo
        'EnableDICOM', false ... % Desabilitado para exemplo
    );
    
    fprintf('  ✓ Sistema de exportação configurado\n');
end

function exportResults = performCompleteExport(exportManager, segmentationResults)
    % Executa exportação completa dos resultados
    
    sessionName = 'example_session';
    
    % Exportar todos os resultados
    exportResults = exportManager.exportCompleteResults(segmentationResults, sessionName, ...
        'IncludeModels', true, ...
        'IncludeVisualizations', true, ...
        'IncludeReports', true, ...
        'CreateBackup', true);
    
    fprintf('  ✓ Exportação completa realizada\n');
    fprintf('    - %d arquivos gerados\n', length(exportResults.exported_files));
    
    % Mostrar alguns arquivos gerados
    fprintf('  Arquivos principais gerados:\n');
    if isfield(exportResults, 'data_files') && isstruct(exportResults.data_files)
        if isfield(exportResults.data_files, 'metrics_comparison')
            fprintf('    - Comparação de métricas: %s\n', exportResults.data_files.metrics_comparison.csv);
        end
    end
    
    if isfield(exportResults, 'report_files') && isstruct(exportResults.report_files)
        if isfield(exportResults.report_files, 'html_report')
            fprintf('    - Relatório HTML: %s\n', exportResults.report_files.html_report);
        end
    end
end

function demonstrateSpecificFeatures(exportManager, segmentationResults)
    % Demonstra funcionalidades específicas do sistema
    
    % 1. Exportação de modelos para formatos padrão
    if isfield(segmentationResults, 'models')
        fprintf('  Exportando modelos para formatos padrão...\n');
        try
            modelFiles = exportManager.exportModelsToStandardFormats(...
                segmentationResults.models, 'demo_models');
            fprintf('    ✓ Modelos exportados\n');
        catch ME
            fprintf('    ! Erro na exportação de modelos: %s\n', ME.message);
        end
    end
    
    % 2. Geração de relatórios científicos
    fprintf('  Gerando relatórios científicos...\n');
    try
        reportFiles = exportManager.generateComprehensiveReports(...
            segmentationResults, 'demo_reports');
        fprintf('    ✓ Relatórios científicos gerados\n');
    catch ME
        fprintf('    ! Erro na geração de relatórios: %s\n', ME.message);
    end
    
    % 3. Exportação de dados científicos
    fprintf('  Exportando dados em formatos científicos...\n');
    try
        % Usar DataExporter diretamente
        dataExporter = DataExporter('OutputDirectory', 'output/demo_data');
        
        % Exportar comparação de métricas
        comparisonFiles = dataExporter.exportMetricsComparison(...
            segmentationResults.unet_metrics, ...
            segmentationResults.attention_metrics, ...
            'demo_comparison');
        
        fprintf('    ✓ Dados científicos exportados\n');
        fprintf('      - CSV: %s\n', comparisonFiles.csv);
        fprintf('      - Excel: %s\n', comparisonFiles.excel);
        fprintf('      - LaTeX: %s\n', comparisonFiles.latex);
        
    catch ME
        fprintf('    ! Erro na exportação de dados: %s\n', ME.message);
    end
    
    % 4. Geração de visualizações
    fprintf('  Gerando visualizações avançadas...\n');
    try
        visualExporter = VisualizationExporter('OutputDirectory', 'output/demo_figures');
        
        % Gráfico de comparação de métricas
        metricsPlot = visualExporter.exportMetricsPlot(segmentationResults, ...
            'demo_metrics_comparison.png', 'CompareModels', true, 'PlotType', 'boxplot');
        
        % Grade de comparação de imagens
        if isfield(segmentationResults, 'sample_images')
            comparisonGrid = visualExporter.exportComparisonGrid(...
                segmentationResults.sample_images, 'demo_image_comparison.png', ...
                'Labels', {'Original', 'Ground Truth', 'U-Net', 'Attention U-Net'});
        end
        
        fprintf('    ✓ Visualizações geradas\n');
        
    catch ME
        fprintf('    ! Erro na geração de visualizações: %s\n', ME.message);
    end
end

function validateExportResults(exportManager, exportResults)
    % Valida os resultados da exportação
    
    try
        validationResults = exportManager.validateExports(exportResults);
        
        fprintf('  ✓ Validação concluída\n');
        fprintf('    - Arquivos válidos: %d/%d\n', ...
            validationResults.valid_files, validationResults.total_files);
        
        if ~isempty(validationResults.invalid_files)
            fprintf('    - Arquivos inválidos:\n');
            for i = 1:length(validationResults.invalid_files)
                fprintf('      * %s\n', validationResults.invalid_files{i});
            end
        end
        
    catch ME
        fprintf('    ! Erro na validação: %s\n', ME.message);
    end
end

function showSystemIntegration()
    % Mostra como integrar com o sistema existente
    
    fprintf('  Exemplo de integração com sistema existente:\n\n');
    
    % Mostrar código de exemplo
    fprintf('  %% No arquivo executar_comparacao.m, adicionar:\n');
    fprintf('  \n');
    fprintf('  %% Após executar comparação de modelos\n');
    fprintf('  if strcmp(opcao, ''5'') %% Nova opção para exportação\n');
    fprintf('      fprintf(''\\n=== EXPORTAÇÃO DE RESULTADOS ===\\n'');\n');
    fprintf('      \n');
    fprintf('      %% Configurar exportação\n');
    fprintf('      exportManager = ExportManager(''OutputDirectory'', ''output'');\n');
    fprintf('      \n');
    fprintf('      %% Preparar resultados\n');
    fprintf('      results = struct();\n');
    fprintf('      results.unet_metrics = unet_results;\n');
    fprintf('      results.attention_metrics = attention_results;\n');
    fprintf('      results.config = training_config;\n');
    fprintf('      \n');
    fprintf('      %% Exportar\n');
    fprintf('      sessionName = sprintf(''session_%%s'', datestr(now, ''yyyyMMdd_HHmmss''));\n');
    fprintf('      exportResults = exportManager.exportCompleteResults(results, sessionName);\n');
    fprintf('      \n');
    fprintf('      fprintf(''Resultados exportados: %%d arquivos\\n'', length(exportResults.exported_files));\n');
    fprintf('  end\n');
    fprintf('  \n');
    
    fprintf('  %% Para integração automática após cada treinamento:\n');
    fprintf('  \n');
    fprintf('  %% No final do treinar_unet_simples.m, adicionar:\n');
    fprintf('  if auto_export_enabled\n');
    fprintf('      exportManager = ExportManager();\n');
    fprintf('      results = struct(''metrics'', final_metrics, ''model'', trained_model);\n');
    fprintf('      exportManager.exportCompleteResults(results, model_name);\n');
    fprintf('  end\n');
    fprintf('  \n');
    
    fprintf('  ✓ Exemplos de integração mostrados\n');
end