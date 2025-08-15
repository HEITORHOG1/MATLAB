function demo_model_management()
    % ========================================================================
    % DEMO DO SISTEMA DE GERENCIAMENTO DE MODELOS
    % ========================================================================
    % 
    % AUTOR: Sistema de Melhorias de Segmentação
    % Data: Agosto 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Demonstração completa do sistema de gerenciamento de modelos
    %   incluindo salvamento, carregamento, versionamento e CLI
    % ========================================================================
    
    fprintf('\n=== DEMO DO SISTEMA DE GERENCIAMENTO DE MODELOS ===\n');
    
    % Configuração de demonstração
    config = struct();
    config.saveDirectory = 'saved_models_demo';
    config.maxVersionsPerModel = 3;
    config.compressionEnabled = true;
    config.autoSaveEnabled = true;
    config.autoVersionEnabled = true;
    
    % Limpar diretório de demo se existir
    if exist(config.saveDirectory, 'dir')
        rmdir(config.saveDirectory, 's');
    end
    
    try
        % 1. Demonstrar ModelSaver
        fprintf('\n--- 1. DEMONSTRAÇÃO DO MODELSAVER ---\n');
        demo_model_saver(config);
        
        % 2. Demonstrar ModelLoader
        fprintf('\n--- 2. DEMONSTRAÇÃO DO MODELLOADER ---\n');
        demo_model_loader(config);
        
        % 3. Demonstrar ModelVersioning
        fprintf('\n--- 3. DEMONSTRAÇÃO DO VERSIONAMENTO ---\n');
        demo_versioning(config);
        
        % 4. Demonstrar TrainingIntegration
        fprintf('\n--- 4. DEMONSTRAÇÃO DA INTEGRAÇÃO ---\n');
        demo_training_integration(config);
        
        % 5. Demonstrar CLI
        fprintf('\n--- 5. DEMONSTRAÇÃO DA CLI ---\n');
        demo_cli(config);
        
        % 6. Demonstrar Scripts Aprimorados
        fprintf('\n--- 6. DEMONSTRAÇÃO DOS SCRIPTS APRIMORADOS ---\n');
        demo_enhanced_scripts(config);
        
        fprintf('\n✓ DEMONSTRAÇÃO COMPLETA CONCLUÍDA!\n');
        fprintf('Todos os componentes do sistema de gerenciamento foram testados.\n');
        
    catch ME
        fprintf('❌ Erro na demonstração: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function demo_model_saver(config)
    % Demonstrar funcionalidades do ModelSaver
    
    fprintf('Inicializando ModelSaver...\n');
    modelSaver = ModelSaver(config);
    
    % Criar modelo de exemplo
    fprintf('Criando modelo de exemplo...\n');
    inputSize = [256, 256, 3];
    numClasses = 2;
    
    % Criar uma U-Net simples para demonstração
    lgraph = unetLayers(inputSize, numClasses, 'EncoderDepth', 2);
    
    % Simular treinamento rápido (apenas para demo)
    fprintf('Simulando treinamento...\n');
    
    % Criar dados sintéticos mínimos
    X_demo = rand(256, 256, 3, 2);  % 2 imagens de exemplo
    Y_demo = categorical(randi([0, 1], 256, 256, 1, 2), [0, 1], {'background', 'foreground'});
    
    % Opções de treinamento mínimas
    options = trainingOptions('adam', ...
        'MaxEpochs', 1, ...
        'MiniBatchSize', 1, ...
        'Verbose', false, ...
        'Plots', 'none');
    
    try
        % Treinar modelo de demonstração
        net = trainNetwork(X_demo, Y_demo, lgraph, options);
        
        % Criar métricas de exemplo
        metricas = struct();
        metricas.iou_mean = 0.75 + rand() * 0.2;  % IoU entre 0.75-0.95
        metricas.iou_std = 0.05 + rand() * 0.05;
        metricas.dice_mean = 0.80 + rand() * 0.15;
        metricas.dice_std = 0.03 + rand() * 0.03;
        metricas.acc_mean = 0.85 + rand() * 0.1;
        metricas.acc_std = 0.02 + rand() * 0.02;
        
        % Configuração de treinamento de exemplo
        trainingConfig = struct();
        trainingConfig.maxEpochs = 1;
        trainingConfig.miniBatchSize = 1;
        trainingConfig.inputSize = inputSize;
        trainingConfig.numClasses = numClasses;
        
        % Salvar modelo
        fprintf('Salvando modelo com ModelSaver...\n');
        savedPath = modelSaver.saveModel(net, 'unet_demo', metricas, trainingConfig);
        
        if ~isempty(savedPath)
            fprintf('✓ Modelo salvo com sucesso: %s\n', savedPath);
        end
        
        % Demonstrar salvamento com gradientes (simulado)
        fprintf('Demonstrando salvamento com gradientes...\n');
        gradientHistory = cell(3, 1);
        for i = 1:3
            gradientHistory{i} = struct('layer1', randn(10, 1), 'layer2', randn(5, 1));
        end
        
        success = modelSaver.saveModelWithGradients(net, 'unet_demo_gradients', metricas, trainingConfig, gradientHistory);
        
        if success
            fprintf('✓ Modelo com gradientes salvo com sucesso\n');
        end
        
    catch ME
        fprintf('⚠ Erro no treinamento de demonstração: %s\n', ME.message);
        fprintf('Continuando com modelo vazio...\n');
        
        % Criar modelo vazio para demonstração
        net = [];
        metricas = struct('iou_mean', 0.5, 'dice_mean', 0.6);
        trainingConfig = struct();
        
        % Tentar salvar mesmo assim
        try
            savedPath = modelSaver.saveModel(net, 'unet_demo_empty', metricas, trainingConfig);
            fprintf('✓ Modelo vazio salvo para demonstração\n');
        catch
            fprintf('⚠ Não foi possível salvar modelo de demonstração\n');
        end
    end
end

function demo_model_loader(config)
    % Demonstrar funcionalidades do ModelLoader
    
    fprintf('Demonstrando ModelLoader...\n');
    
    % Listar modelos disponíveis
    fprintf('Listando modelos disponíveis...\n');
    models = ModelLoader.listAvailableModels(config.saveDirectory);
    
    if ~isempty(models)
        % Tentar carregar o primeiro modelo
        fprintf('Carregando primeiro modelo encontrado...\n');
        try
            [model, metadata] = ModelLoader.loadModel(models(1).filepath);
            
            if ~isempty(model)
                fprintf('✓ Modelo carregado com sucesso!\n');
            else
                fprintf('⚠ Modelo carregado está vazio\n');
            end
            
            if ~isempty(metadata)
                fprintf('✓ Metadados carregados\n');
            end
            
        catch ME
            fprintf('⚠ Erro ao carregar modelo: %s\n', ME.message);
        end
        
        % Demonstrar carregamento do melhor modelo
        fprintf('Tentando carregar melhor modelo...\n');
        try
            [bestModel, bestMetadata] = ModelLoader.loadBestModel(config.saveDirectory, 'iou_mean');
            
            if ~isempty(bestModel)
                fprintf('✓ Melhor modelo carregado!\n');
            end
            
        catch ME
            fprintf('⚠ Erro ao carregar melhor modelo: %s\n', ME.message);
        end
        
        % Demonstrar validação de compatibilidade
        fprintf('Testando validação de compatibilidade...\n');
        currentConfig = struct();
        currentConfig.inputSize = [256, 256, 3];
        currentConfig.numClasses = 2;
        
        isValid = ModelLoader.validateModelCompatibility(models(1).filepath, currentConfig);
        fprintf('Compatibilidade: %s\n', iif(isValid, 'Válido', 'Inválido'));
        
    else
        fprintf('⚠ Nenhum modelo encontrado para demonstração\n');
    end
end

function demo_versioning(config)
    % Demonstrar sistema de versionamento
    
    fprintf('Demonstrando sistema de versionamento...\n');
    
    versioningSystem = ModelVersioning(config);
    
    % Verificar se há modelos para versionar
    models = ModelLoader.listAvailableModels(config.saveDirectory);
    
    if ~isempty(models)
        % Criar versões de exemplo
        fprintf('Criando versões de exemplo...\n');
        
        for i = 1:min(2, length(models))
            model = models(i);
            
            try
                versionPath = versioningSystem.createNewVersion(model.filepath, model.type);
                fprintf('✓ Versão criada: %s\n', versionPath);
            catch ME
                fprintf('⚠ Erro ao criar versão: %s\n', ME.message);
            end
        end
        
        % Listar versões
        fprintf('Listando versões disponíveis...\n');
        versions = versioningSystem.listVersions();
        
        % Demonstrar limpeza
        fprintf('Demonstrando limpeza de versões antigas...\n');
        if ~isempty(models)
            versioningSystem.cleanupOldVersions(models(1).type);
        end
        
        % Gerar relatório de versionamento
        fprintf('Gerando relatório de versionamento...\n');
        versioningSystem.generateVersionReport();
        
    else
        fprintf('⚠ Nenhum modelo disponível para versionamento\n');
    end
end

function demo_training_integration(config)
    % Demonstrar integração com treinamento
    
    fprintf('Demonstrando integração com treinamento...\n');
    
    trainingIntegration = TrainingIntegration(config);
    
    % Criar configuração de treinamento de exemplo
    originalConfig = struct();
    originalConfig.maxEpochs = 5;
    originalConfig.miniBatchSize = 4;
    originalConfig.inputSize = [256, 256, 3];
    originalConfig.numClasses = 2;
    
    % Aprimorar configuração
    fprintf('Aprimorando configuração de treinamento...\n');
    enhancedConfig = trainingIntegration.enhanceTrainingConfig(originalConfig);
    
    fprintf('✓ Configuração aprimorada criada\n');
    
    % Demonstrar modificação de script (simulada)
    fprintf('Demonstrando modificação de script...\n');
    
    % Criar script de exemplo
    exampleScript = sprintf([...
        'function net = exemplo_treinamento(config)\n' ...
        '    %% Script de exemplo\n' ...
        '    lgraph = unetLayers([256, 256, 3], 2);\n' ...
        '    options = trainingOptions(''adam'', ''MaxEpochs'', 5);\n' ...
        '    net = trainNetwork(data, lgraph, options);\n' ...
        'end\n'
    ]);
    
    % Salvar script de exemplo
    scriptPath = fullfile(config.saveDirectory, 'exemplo_original.m');
    fid = fopen(scriptPath, 'w');
    if fid ~= -1
        fprintf(fid, '%s', exampleScript);
        fclose(fid);
        
        % Modificar script
        modifiedPath = fullfile(config.saveDirectory, 'exemplo_modificado.m');
        modifiedScript = trainingIntegration.modifyTrainingScript(scriptPath, modifiedPath);
        
        if ~isempty(modifiedScript)
            fprintf('✓ Script modificado criado\n');
        end
    end
end

function demo_cli(config)
    % Demonstrar interface CLI
    
    fprintf('Demonstrando interface CLI...\n');
    
    cli = ModelManagerCLI(config);
    
    % Demonstrar comandos básicos
    fprintf('Executando comandos CLI de demonstração...\n');
    
    % Listar modelos
    fprintf('\n> Comando: list\n');
    cli.executeCommand('list', config.saveDirectory);
    
    % Gerar relatório
    fprintf('\n> Comando: report\n');
    cli.executeCommand('report');
    
    % Buscar modelos
    fprintf('\n> Comando: search\n');
    cli.executeCommand('search', 'unet');
    
    % Listar versões
    fprintf('\n> Comando: versions\n');
    cli.executeCommand('versions');
    
    fprintf('✓ Comandos CLI demonstrados\n');
    
    % Nota sobre modo interativo
    fprintf('\nPara usar o modo interativo, execute:\n');
    fprintf('  cli = ModelManagerCLI();\n');
    fprintf('  cli.runInteractiveMode();\n');
end

function demo_enhanced_scripts(config)
    % Demonstrar scripts aprimorados
    
    fprintf('Demonstrando scripts aprimorados...\n');
    
    % Verificar se scripts aprimorados existem
    enhancedUNetScript = 'utils/treinar_unet_simples_enhanced.m';
    enhancedComparisonScript = 'legacy/comparacao_unet_attention_enhanced.m';
    
    if exist(enhancedUNetScript, 'file')
        fprintf('✓ Script U-Net aprimorado disponível: %s\n', enhancedUNetScript);
    else
        fprintf('⚠ Script U-Net aprimorado não encontrado\n');
    end
    
    if exist(enhancedComparisonScript, 'file')
        fprintf('✓ Script de comparação aprimorado disponível: %s\n', enhancedComparisonScript);
    else
        fprintf('⚠ Script de comparação aprimorado não encontrado\n');
    end
    
    % Mostrar como usar os scripts aprimorados
    fprintf('\nPara usar os scripts aprimorados:\n');
    fprintf('1. U-Net Simples Aprimorada:\n');
    fprintf('   config.loadPretrainedModel = true;  %% Para carregar modelo pré-treinado\n');
    fprintf('   result = treinar_unet_simples_enhanced(config);\n\n');
    
    fprintf('2. Comparação Aprimorada:\n');
    fprintf('   config.usePretrainedModels = true;  %% Para usar modelos pré-treinados\n');
    fprintf('   result = comparacao_unet_attention_enhanced(config);\n\n');
    
    % Demonstrar configuração para scripts aprimorados
    fprintf('Configuração recomendada para scripts aprimorados:\n');
    
    recommendedConfig = struct();
    recommendedConfig.imageDir = 'img/original';
    recommendedConfig.maskDir = 'img/masks';
    recommendedConfig.inputSize = [256, 256, 3];
    recommendedConfig.numClasses = 2;
    recommendedConfig.maxEpochs = 10;
    recommendedConfig.miniBatchSize = 8;
    recommendedConfig.loadPretrainedModel = true;
    recommendedConfig.usePretrainedModels = true;
    recommendedConfig.autoSaveEnabled = true;
    recommendedConfig.autoVersionEnabled = true;
    
    fprintf('Exemplo de configuração:\n');
    disp(recommendedConfig);
end

function showSystemOverview()
    % Mostrar visão geral do sistema
    
    fprintf('\n=== VISÃO GERAL DO SISTEMA DE GERENCIAMENTO ===\n');
    
    fprintf('\nComponentes implementados:\n');
    fprintf('✓ ModelSaver - Salvamento automático com metadados\n');
    fprintf('✓ ModelLoader - Carregamento seguro e validação\n');
    fprintf('✓ ModelVersioning - Versionamento automático\n');
    fprintf('✓ TrainingIntegration - Integração com pipeline existente\n');
    fprintf('✓ ModelManagerCLI - Interface de linha de comando\n');
    
    fprintf('\nScripts aprimorados:\n');
    fprintf('✓ treinar_unet_simples_enhanced.m\n');
    fprintf('✓ comparacao_unet_attention_enhanced.m\n');
    
    fprintf('\nFuncionalidades principais:\n');
    fprintf('• Salvamento automático de modelos com timestamp e métricas\n');
    fprintf('• Carregamento de modelos pré-treinados com validação\n');
    fprintf('• Sistema de versionamento com limpeza inteligente\n');
    fprintf('• Interface CLI para gerenciamento de modelos\n');
    fprintf('• Integração transparente com código existente\n');
    fprintf('• Análise estatística avançada de resultados\n');
    fprintf('• Visualizações aprimoradas de comparação\n');
    
    fprintf('\nPróximos passos:\n');
    fprintf('1. Execute demo_model_management() para ver demonstração completa\n');
    fprintf('2. Use os scripts aprimorados para treinamento com gerenciamento automático\n');
    fprintf('3. Explore a CLI para gerenciar modelos existentes\n');
    fprintf('4. Integre o sistema com seu workflow de pesquisa\n');
    
    fprintf('\n===============================================\n');
end

function result = iif(condition, trueValue, falseValue)
    % Função auxiliar para operador ternário
    if condition
        result = trueValue;
    else
        result = falseValue;
    end
end

% Executar visão geral quando script é chamado diretamente
if nargout == 0
    showSystemOverview();
end