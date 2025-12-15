function integration_example()
    % ========================================================================
    % INTEGRATION_EXAMPLE - Exemplo de Integração das Novas Funcionalidades
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Exemplo demonstrando como as novas funcionalidades estão integradas
    %   no sistema existente de comparação U-Net vs Attention U-Net
    %
    % FUNCIONALIDADES DEMONSTRADAS:
    %   1. Salvamento automático de modelos
    %   2. Carregamento de modelos pré-treinados
    %   3. Organização automática de resultados
    %   4. Interface unificada
    %
    % USO:
    %   >> integration_example()
    % ========================================================================
    
    fprintf('\n🚀 EXEMPLO DE INTEGRAÇÃO DAS NOVAS FUNCIONALIDADES\n');
    fprintf('=====================================================\n\n');
    
    try
        % 1. Demonstrar inicialização dos novos componentes
        fprintf('1. Inicializando novos componentes...\n');
        demonstrateComponentInitialization();
        
        % 2. Demonstrar configuração integrada
        fprintf('\n2. Demonstrando configuração integrada...\n');
        demonstrateIntegratedConfiguration();
        
        % 3. Demonstrar salvamento automático
        fprintf('\n3. Demonstrando salvamento automático...\n');
        demonstrateAutoSaving();
        
        % 4. Demonstrar carregamento de modelos
        fprintf('\n4. Demonstrando carregamento de modelos...\n');
        demonstrateModelLoading();
        
        % 5. Demonstrar organização de resultados
        fprintf('\n5. Demonstrando organização de resultados...\n');
        demonstrateResultsOrganization();
        
        % 6. Demonstrar interface unificada
        fprintf('\n6. Demonstrando interface unificada...\n');
        demonstrateUnifiedInterface();
        
        fprintf('\n✅ INTEGRAÇÃO DEMONSTRADA COM SUCESSO!\n');
        fprintf('=====================================================\n');
        
    catch ME
        fprintf('❌ Erro na demonstração: %s\n', ME.message);
        rethrow(ME);
    end
end

function demonstrateComponentInitialization()
    % Demonstra inicialização dos novos componentes
    
    fprintf('   • Inicializando ModelSaver...\n');
    config = struct('saveDirectory', 'saved_models', 'autoSaveEnabled', true);
    modelSaver = ModelSaver(config);
    
    fprintf('   • Inicializando ModelLoader...\n');
    % ModelLoader é uma classe estática, não precisa inicialização
    
    fprintf('   • Inicializando ResultsOrganizer...\n');
    organizerConfig = struct('baseOutputDir', 'output', 'compressionEnabled', true);
    resultsOrganizer = ResultsOrganizer(organizerConfig);
    
    fprintf('   • Inicializando TrainingIntegration...\n');
    trainingIntegration = TrainingIntegration(config);
    
    fprintf('   ✓ Todos os componentes inicializados com sucesso!\n');
end

function demonstrateIntegratedConfiguration()
    % Demonstra configuração integrada
    
    fprintf('   • Criando configuração base...\n');
    config = struct();
    config.imageDir = 'img/original';
    config.maskDir = 'img/masks';
    config.inputSize = [256, 256, 3];
    config.numClasses = 2;
    config.maxEpochs = 20;
    config.miniBatchSize = 8;
    
    fprintf('   • Aprimorando configuração com funcionalidades de salvamento...\n');
    trainingIntegration = TrainingIntegration();
    enhancedConfig = trainingIntegration.enhanceTrainingConfig(config);
    
    fprintf('   • Configurações adicionadas:\n');
    if isfield(enhancedConfig, 'modelManagement')
        fprintf('     - Salvamento automático: %s\n', ...
            mat2str(enhancedConfig.modelManagement.autoSave));
        fprintf('     - Versionamento: %s\n', ...
            mat2str(enhancedConfig.modelManagement.autoVersion));
    end
    
    fprintf('   ✓ Configuração integrada com sucesso!\n');
end

function demonstrateAutoSaving()
    % Demonstra salvamento automático
    
    fprintf('   • Simulando treinamento de modelo...\n');
    
    % Criar modelo simulado (para demonstração)
    try
        % Tentar criar uma rede simples para demonstração
        layers = [
            imageInputLayer([64, 64, 3])
            convolution2dLayer(3, 16, 'Padding', 'same')
            reluLayer
            maxPooling2dLayer(2, 'Stride', 2)
            fullyConnectedLayer(2)
            softmaxLayer
            classificationLayer
        ];
        
        simulatedModel = layerGraph(layers);
        fprintf('     - Modelo simulado criado\n');
        
        % Simular métricas
        metrics = struct();
        metrics.iou_mean = 0.75;
        metrics.dice_mean = 0.80;
        metrics.acc_mean = 0.85;
        
        % Simular configuração
        config = struct();
        config.modelType = 'unet';
        config.maxEpochs = 20;
        
        % Demonstrar salvamento
        fprintf('   • Salvando modelo automaticamente...\n');
        modelSaver = ModelSaver();
        savedPath = modelSaver.saveModel(simulatedModel, 'demo_unet', metrics, config);
        
        if ~isempty(savedPath)
            fprintf('     ✓ Modelo salvo em: %s\n', savedPath);
        end
        
    catch ME
        fprintf('     ⚠ Erro na criação do modelo simulado: %s\n', ME.message);
        fprintf('     (Isso é normal se as toolboxes não estiverem disponíveis)\n');
    end
    
    fprintf('   ✓ Demonstração de salvamento concluída!\n');
end

function demonstrateModelLoading()
    % Demonstra carregamento de modelos
    
    fprintf('   • Listando modelos disponíveis...\n');
    models = ModelLoader.listAvailableModels('saved_models');
    
    if ~isempty(models)
        fprintf('     - Encontrados %d modelos\n', length(models));
        
        % Tentar carregar o primeiro modelo
        fprintf('   • Tentando carregar modelo...\n');
        try
            [model, metadata] = ModelLoader.loadModel(models(1).filepath);
            if ~isempty(model)
                fprintf('     ✓ Modelo carregado com sucesso!\n');
            end
        catch ME
            fprintf('     ⚠ Erro ao carregar modelo: %s\n', ME.message);
        end
    else
        fprintf('     - Nenhum modelo encontrado (execute primeiro o salvamento)\n');
    end
    
    fprintf('   ✓ Demonstração de carregamento concluída!\n');
end

function demonstrateResultsOrganization()
    % Demonstra organização de resultados
    
    fprintf('   • Criando resultados simulados...\n');
    
    % Simular resultados U-Net
    unetResults = [];
    for i = 1:3
        result = struct();
        result.imagePath = sprintf('img_%03d.png', i);
        result.segmentationPath = sprintf('unet_seg_%03d.png', i);
        result.metrics = struct('iou', 0.7 + rand()*0.2, 'dice', 0.75 + rand()*0.2);
        result.processingTime = rand() * 5;
        unetResults = [unetResults, result];
    end
    
    % Simular resultados Attention U-Net
    attentionResults = [];
    for i = 1:3
        result = struct();
        result.imagePath = sprintf('img_%03d.png', i);
        result.segmentationPath = sprintf('attention_seg_%03d.png', i);
        result.metrics = struct('iou', 0.75 + rand()*0.2, 'dice', 0.8 + rand()*0.2);
        result.processingTime = rand() * 6;
        attentionResults = [attentionResults, result];
    end
    
    fprintf('   • Organizando resultados...\n');
    try
        resultsOrganizer = ResultsOrganizer();
        config = struct('imageDir', 'img/original', 'maskDir', 'img/masks');
        
        sessionId = resultsOrganizer.organizeResults(unetResults, attentionResults, config);
        fprintf('     ✓ Resultados organizados na sessão: %s\n', sessionId);
        
        % Gerar índice HTML
        fprintf('   • Gerando índice HTML...\n');
        resultsOrganizer.generateHTMLIndex(sessionId);
        fprintf('     ✓ Índice HTML gerado!\n');
        
    catch ME
        fprintf('     ⚠ Erro na organização: %s\n', ME.message);
    end
    
    fprintf('   ✓ Demonstração de organização concluída!\n');
end

function demonstrateUnifiedInterface()
    % Demonstra interface unificada
    
    fprintf('   • A interface unificada agora inclui:\n');
    fprintf('     - Menu de gerenciamento de modelos (opção 7)\n');
    fprintf('     - Menu de análise de resultados (opção 8)\n');
    fprintf('     - Configuração integrada das novas funcionalidades\n');
    fprintf('     - Salvamento automático durante treinamento\n');
    fprintf('     - Organização automática de resultados\n');
    
    fprintf('   • Para usar a interface completa, execute:\n');
    fprintf('     >> main_sistema_comparacao\n');
    
    fprintf('   ✓ Interface unificada demonstrada!\n');
end