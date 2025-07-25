classdef ModelTrainer < handle
    % ========================================================================
    % MODELTRAINER - TREINADOR DE MODELOS UNIFICADO
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe handle unificada para treinamento de modelos U-Net e Attention U-Net.
    %   Implementa detecção automática de GPU, early stopping, checkpoints automáticos
    %   e configuração otimizada de treinamento.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Deep Learning Toolbox
    %   - Training Deep Neural Networks
    %   - GPU Computing
    %
    % USO:
    %   >> trainer = ModelTrainer();
    %   >> net = trainer.trainUNet(trainData, valData, config);
    %   >> net = trainer.trainAttentionUNet(trainData, valData, config);
    %
    % REQUISITOS: 1.1, 7.1
    % ========================================================================
    
    properties (Access = private)
        logger
        gpuAvailable = false
        gpuDevice = []
        checkpointDir = 'checkpoints'
        trainingOptions = []
        currentModel = ''
        hyperparameterOptimizer = []
    end
    
    properties (Constant)
        SUPPORTED_MODELS = {'unet', 'attention_unet'}
        DEFAULT_CHECKPOINT_FREQUENCY = 5
        DEFAULT_VALIDATION_FREQUENCY = 2
        MIN_EPOCHS_FOR_EARLY_STOPPING = 10
    end
    
    methods
        function obj = ModelTrainer()
            % Construtor da classe ModelTrainer
            % Inicializa o treinador e detecta recursos disponíveis
            
            obj.initializeLogger();
            obj.detectGPU();
            obj.ensureCheckpointDirectory();
            obj.hyperparameterOptimizer = HyperparameterOptimizer();
            
            obj.logger('info', 'ModelTrainer inicializado');
        end
        
        function net = trainUNet(obj, trainData, valData, config)
            % Treina modelo U-Net clássico
            %
            % ENTRADA:
            %   trainData - datastore de treinamento
            %   valData - datastore de validação
            %   config - estrutura de configuração
            %
            % SAÍDA:
            %   net - rede neural treinada
            %
            % REFERÊNCIA MATLAB:
            %   https://www.mathworks.com/help/vision/ref/unetlayers.html
            %   https://www.mathworks.com/help/deeplearning/ref/trainnetwork.html
            %
            % REQUISITOS: 1.1
            
            obj.logger('info', '=== INICIANDO TREINAMENTO U-NET ===');
            obj.currentModel = 'unet';
            
            try
                % Validar entradas
                if ~obj.validateTrainingInputs(trainData, valData, config)
                    error('Entradas de treinamento inválidas');
                end
                
                % Criar arquitetura U-Net
                obj.logger('info', 'Criando arquitetura U-Net...');
                lgraph = unetLayers(config.inputSize, config.numClasses, ...
                    'EncoderDepth', obj.getEncoderDepth(config));
                
                obj.logger('success', 'Arquitetura U-Net criada');
                
                % Configurar opções de treinamento
                options = obj.createTrainingOptions(config, valData);
                
                % Configurar checkpoints
                checkpointPath = obj.setupCheckpoints('unet', config);
                
                % Treinar rede
                obj.logger('info', 'Iniciando treinamento...');
                startTime = tic;
                
                net = trainNetwork(trainData, lgraph, options);
                
                trainingTime = toc(startTime);
                obj.logger('success', sprintf('Treinamento U-Net concluído em %.2f segundos', trainingTime));
                
                % Salvar modelo final
                obj.saveModel(net, 'unet_final', config, trainingTime);
                
                % Limpar checkpoints temporários se treinamento foi bem-sucedido
                obj.cleanupCheckpoints(checkpointPath);
                
            catch ME
                obj.logger('error', sprintf('Erro no treinamento U-Net: %s', ME.message));
                obj.handleTrainingError(ME, 'unet');
                rethrow(ME);
            end
        end
        
        function net = trainAttentionUNet(obj, trainData, valData, config)
            % Treina modelo Attention U-Net
            %
            % ENTRADA:
            %   trainData - datastore de treinamento
            %   valData - datastore de validação
            %   config - estrutura de configuração
            %
            % SAÍDA:
            %   net - rede neural treinada
            %
            % REQUISITOS: 1.1
            
            obj.logger('info', '=== INICIANDO TREINAMENTO ATTENTION U-NET ===');
            obj.currentModel = 'attention_unet';
            
            try
                % Validar entradas
                if ~obj.validateTrainingInputs(trainData, valData, config)
                    error('Entradas de treinamento inválidas');
                end
                
                % Criar arquitetura Attention U-Net
                obj.logger('info', 'Criando arquitetura Attention U-Net...');
                lgraph = obj.createAttentionUNet(config.inputSize, config.numClasses);
                
                obj.logger('success', 'Arquitetura Attention U-Net criada');
                
                % Configurar opções de treinamento (pode ser diferente da U-Net)
                options = obj.createTrainingOptions(config, valData, 'attention');
                
                % Configurar checkpoints
                checkpointPath = obj.setupCheckpoints('attention_unet', config);
                
                % Treinar rede
                obj.logger('info', 'Iniciando treinamento...');
                startTime = tic;
                
                net = trainNetwork(trainData, lgraph, options);
                
                trainingTime = toc(startTime);
                obj.logger('success', sprintf('Treinamento Attention U-Net concluído em %.2f segundos', trainingTime));
                
                % Salvar modelo final
                obj.saveModel(net, 'attention_unet_final', config, trainingTime);
                
                % Limpar checkpoints temporários se treinamento foi bem-sucedido
                obj.cleanupCheckpoints(checkpointPath);
                
            catch ME
                obj.logger('error', sprintf('Erro no treinamento Attention U-Net: %s', ME.message));
                obj.handleTrainingError(ME, 'attention_unet');
                rethrow(ME);
            end
        end
        
        function success = saveModel(obj, net, modelName, config, trainingTime)
            % Salva modelo treinado com metadados
            %
            % ENTRADA:
            %   net - rede neural treinada
            %   modelName - nome do modelo
            %   config - configuração usada
            %   trainingTime - tempo de treinamento em segundos
            %
            % SAÍDA:
            %   success - true se salvou com sucesso
            
            success = false;
            
            try
                % Criar diretório de modelos se não existir
                modelDir = fullfile('output', 'models');
                if ~exist(modelDir, 'dir')
                    mkdir(modelDir);
                end
                
                % Criar nome do arquivo com timestamp
                timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
                filename = sprintf('%s_%s.mat', modelName, timestamp);
                filepath = fullfile(modelDir, filename);
                
                % Preparar metadados
                metadata = struct();
                metadata.modelName = modelName;
                metadata.trainingTime = trainingTime;
                metadata.timestamp = timestamp;
                metadata.config = config;
                metadata.gpuUsed = obj.gpuAvailable;
                if obj.gpuAvailable && ~isempty(obj.gpuDevice)
                    metadata.gpuInfo = struct();
                    metadata.gpuInfo.name = obj.gpuDevice.Name;
                    metadata.gpuInfo.memory = obj.gpuDevice.TotalMemory;
                end
                
                % Salvar modelo e metadados
                save(filepath, 'net', 'metadata', 'config');
                
                obj.logger('success', sprintf('Modelo salvo: %s', filepath));
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro ao salvar modelo: %s', ME.message));
            end
        end
        
        function net = loadModel(obj, modelPath)
            % Carrega modelo salvo
            %
            % ENTRADA:
            %   modelPath - caminho para arquivo do modelo
            %
            % SAÍDA:
            %   net - rede neural carregada
            
            net = [];
            
            try
                if ~exist(modelPath, 'file')
                    obj.logger('error', sprintf('Arquivo de modelo não encontrado: %s', modelPath));
                    return;
                end
                
                obj.logger('info', sprintf('Carregando modelo: %s', modelPath));
                
                loadedData = load(modelPath);
                
                if isfield(loadedData, 'net')
                    net = loadedData.net;
                    obj.logger('success', 'Modelo carregado com sucesso');
                    
                    % Mostrar metadados se disponíveis
                    if isfield(loadedData, 'metadata')
                        metadata = loadedData.metadata;
                        obj.logger('info', sprintf('Modelo: %s', metadata.modelName));
                        obj.logger('info', sprintf('Treinado em: %s', metadata.timestamp));
                        if isfield(metadata, 'trainingTime')
                            obj.logger('info', sprintf('Tempo de treinamento: %.2f segundos', metadata.trainingTime));
                        end
                    end
                else
                    obj.logger('error', 'Arquivo não contém modelo válido');
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao carregar modelo: %s', ME.message));
            end
        end
        
        function optimizedConfig = optimizeHyperparameters(obj, trainData, valData, config, options)
            % Otimiza hiperparâmetros para treinamento
            %
            % ENTRADA:
            %   trainData - datastore de treinamento
            %   valData - datastore de validação
            %   config - configuração base
            %   options (opcional) - opções de otimização
            %
            % SAÍDA:
            %   optimizedConfig - configuração com hiperparâmetros otimizados
            %
            % REQUISITOS: 7.3
            
            if nargin < 5
                options = struct();
            end
            
            obj.logger('info', '=== OTIMIZANDO HIPERPARÂMETROS ===');
            
            try
                % Usar o otimizador de hiperparâmetros
                bestParams = obj.hyperparameterOptimizer.optimizeHyperparameters(trainData, valData, config, options);
                
                % Aplicar melhores parâmetros à configuração
                optimizedConfig = config;
                if ~isempty(bestParams)
                    if isfield(bestParams, 'learningRate')
                        optimizedConfig.learningRate = bestParams.learningRate;
                    end
                    if isfield(bestParams, 'batchSize')
                        optimizedConfig.miniBatchSize = bestParams.batchSize;
                    end
                    if isfield(bestParams, 'encoderDepth')
                        optimizedConfig.encoderDepth = bestParams.encoderDepth;
                    end
                    if isfield(bestParams, 'l2Factor')
                        optimizedConfig.l2Factor = bestParams.l2Factor;
                    end
                    
                    obj.logger('success', 'Configuração otimizada aplicada');
                else
                    obj.logger('warning', 'Otimização falhou, usando configuração original');
                end
                
            catch ME
                obj.logger('error', sprintf('Erro na otimização: %s', ME.message));
                optimizedConfig = config;
            end
        end
        
        function optimalBatchSize = findOptimalBatchSize(obj, config)
            % Encontra batch size ótimo baseado na memória disponível
            %
            % ENTRADA:
            %   config - configuração do sistema
            %
            % SAÍDA:
            %   optimalBatchSize - batch size recomendado
            %
            % REQUISITOS: 7.4
            
            try
                optimalBatchSize = obj.hyperparameterOptimizer.findOptimalBatchSize(config);
                obj.logger('info', sprintf('Batch size ótimo calculado: %d', optimalBatchSize));
            catch ME
                obj.logger('error', sprintf('Erro ao calcular batch size: %s', ME.message));
                optimalBatchSize = 4;  % Valor seguro padrão
            end
        end
        
        function recommendations = getParameterRecommendations(obj, config, datasetInfo)
            % Gera recomendações de parâmetros baseadas no dataset
            %
            % ENTRADA:
            %   config - configuração base
            %   datasetInfo - informações sobre o dataset
            %
            % SAÍDA:
            %   recommendations - estrutura com parâmetros recomendados
            %
            % REQUISITOS: 7.3, 7.4
            
            try
                recommendations = obj.hyperparameterOptimizer.recommendParameters(config, datasetInfo);
                obj.logger('success', 'Recomendações de parâmetros geradas');
            catch ME
                obj.logger('error', sprintf('Erro ao gerar recomendações: %s', ME.message));
                recommendations = struct();
            end
        end
    end
    
    methods (Access = private)
        function initializeLogger(obj)
            % Inicializa sistema de logging
            obj.logger = @(level, msg) obj.logMessage(level, msg);
        end
        
        function logMessage(obj, level, message)
            % Sistema de logging simples
            timestamp = datestr(now, 'HH:MM:SS');
            
            switch lower(level)
                case 'info'
                    prefix = '📋';
                case 'success'
                    prefix = '✅';
                case 'warning'
                    prefix = '⚠️';
                case 'error'
                    prefix = '❌';
                otherwise
                    prefix = '📝';
            end
            
            fprintf('[%s] %s %s\n', timestamp, prefix, message);
        end
        
        function detectGPU(obj)
            % Detecta e configura GPU se disponível
            %
            % REQUISITOS: 7.1
            
            try
                obj.logger('info', 'Detectando GPU...');
                
                % Verificar se Parallel Computing Toolbox está disponível
                if ~license('test', 'Distrib_Computing_Toolbox') && ~license('test', 'Parallel_Computing_Toolbox')
                    obj.logger('info', 'Parallel Computing Toolbox não disponível');
                    return;
                end
                
                % Tentar acessar GPU
                obj.gpuDevice = gpuDevice();
                obj.gpuAvailable = true;
                
                obj.logger('success', sprintf('GPU detectada: %s', obj.gpuDevice.Name));
                obj.logger('info', sprintf('Memória GPU: %.1f GB total, %.1f GB disponível', ...
                    obj.gpuDevice.TotalMemory / (1024^3), ...
                    obj.gpuDevice.AvailableMemory / (1024^3)));
                
                % Verificar se há memória suficiente
                if obj.gpuDevice.AvailableMemory < 1e9  % Menos de 1GB
                    obj.logger('warning', 'GPU com pouca memória disponível');
                end
                
            catch ME
                obj.logger('info', sprintf('GPU não disponível: %s', ME.message));
                obj.gpuAvailable = false;
                obj.gpuDevice = [];
            end
        end
        
        function ensureCheckpointDirectory(obj)
            % Garante que diretório de checkpoints existe
            if ~exist(obj.checkpointDir, 'dir')
                mkdir(obj.checkpointDir);
                obj.logger('info', sprintf('Diretório de checkpoints criado: %s', obj.checkpointDir));
            end
        end
        
        function isValid = validateTrainingInputs(obj, trainData, valData, config)
            % Valida entradas de treinamento
            %
            % ENTRADA:
            %   trainData - datastore de treinamento
            %   valData - datastore de validação  
            %   config - configuração
            %
            % SAÍDA:
            %   isValid - true se entradas são válidas
            
            isValid = false;
            
            try
                % Verificar datastores
                if isempty(trainData)
                    obj.logger('error', 'Datastore de treinamento vazio');
                    return;
                end
                
                if isempty(valData)
                    obj.logger('error', 'Datastore de validação vazio');
                    return;
                end
                
                % Verificar configuração
                requiredFields = {'inputSize', 'numClasses', 'maxEpochs', 'miniBatchSize'};
                for i = 1:length(requiredFields)
                    if ~isfield(config, requiredFields{i})
                        obj.logger('error', sprintf('Campo obrigatório ausente: %s', requiredFields{i}));
                        return;
                    end
                end
                
                % Validar valores
                if config.numClasses < 2
                    obj.logger('error', 'numClasses deve ser >= 2');
                    return;
                end
                
                if config.maxEpochs < 1
                    obj.logger('error', 'maxEpochs deve ser >= 1');
                    return;
                end
                
                if config.miniBatchSize < 1
                    obj.logger('error', 'miniBatchSize deve ser >= 1');
                    return;
                end
                
                obj.logger('success', 'Entradas de treinamento validadas');
                isValid = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na validação: %s', ME.message));
            end
        end
        
        function options = createTrainingOptions(obj, config, valData, modelType)
            % Cria opções de treinamento otimizadas
            %
            % ENTRADA:
            %   config - configuração
            %   valData - dados de validação
            %   modelType - tipo do modelo ('standard' ou 'attention')
            %
            % SAÍDA:
            %   options - opções de treinamento
            
            if nargin < 4
                modelType = 'standard';
            end
            
            try
                obj.logger('info', 'Configurando opções de treinamento...');
                
                % Determinar execution environment
                if obj.gpuAvailable
                    executionEnv = 'gpu';
                    obj.logger('info', 'Usando GPU para treinamento');
                else
                    executionEnv = 'cpu';
                    obj.logger('info', 'Usando CPU para treinamento');
                end
                
                % Learning rate baseado no tipo de modelo
                if strcmp(modelType, 'attention')
                    initialLR = 5e-4;  % Learning rate menor para Attention U-Net
                else
                    initialLR = 1e-3;  % Learning rate padrão para U-Net
                end
                
                % Ajustar learning rate baseado no batch size
                if isfield(config, 'miniBatchSize')
                    lrScale = sqrt(config.miniBatchSize / 8);  % Escalar baseado no batch size
                    initialLR = initialLR * lrScale;
                end
                
                % Configurar early stopping se épocas suficientes
                if config.maxEpochs >= obj.MIN_EPOCHS_FOR_EARLY_STOPPING
                    validationPatience = max(5, round(config.maxEpochs * 0.2));
                else
                    validationPatience = Inf;  % Desabilitar early stopping
                end
                
                % Criar opções de treinamento
                options = trainingOptions('adam', ...
                    'InitialLearnRate', initialLR, ...
                    'MaxEpochs', config.maxEpochs, ...
                    'MiniBatchSize', config.miniBatchSize, ...
                    'ValidationData', valData, ...
                    'ValidationFrequency', obj.DEFAULT_VALIDATION_FREQUENCY, ...
                    'ValidationPatience', validationPatience, ...
                    'Shuffle', 'every-epoch', ...
                    'Verbose', true, ...
                    'Plots', 'training-progress', ...
                    'ExecutionEnvironment', executionEnv, ...
                    'LearnRateSchedule', 'piecewise', ...
                    'LearnRateDropFactor', 0.5, ...
                    'LearnRateDropPeriod', max(5, round(config.maxEpochs * 0.3)));
                
                obj.trainingOptions = options;
                
                obj.logger('success', sprintf('Opções configuradas - LR: %.2e, Env: %s', initialLR, executionEnv));
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar opções de treinamento: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function lgraph = createAttentionUNet(obj, inputSize, numClasses)
            % Cria arquitetura Attention U-Net
            % Usa implementação do arquivo existente
            %
            % ENTRADA:
            %   inputSize - tamanho da entrada [H, W, C]
            %   numClasses - número de classes
            %
            % SAÍDA:
            %   lgraph - layer graph da Attention U-Net
            
            try
                obj.logger('info', 'Criando Attention U-Net usando implementação existente...');
                
                % Usar função existente
                lgraph = create_working_attention_unet(inputSize, numClasses);
                
                obj.logger('success', 'Attention U-Net criada com sucesso');
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar Attention U-Net: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function encoderDepth = getEncoderDepth(obj, config)
            % Determina profundidade do encoder baseado na configuração
            %
            % ENTRADA:
            %   config - configuração
            %
            % SAÍDA:
            %   encoderDepth - profundidade do encoder
            
            if isfield(config, 'encoderDepth')
                encoderDepth = config.encoderDepth;
            else
                % Determinar baseado no tamanho da entrada
                minSize = min(config.inputSize(1:2));
                if minSize >= 512
                    encoderDepth = 5;
                elseif minSize >= 256
                    encoderDepth = 4;
                else
                    encoderDepth = 3;
                end
            end
            
            obj.logger('info', sprintf('Encoder depth: %d', encoderDepth));
        end
        
        function checkpointPath = setupCheckpoints(obj, modelName, config)
            % Configura sistema de checkpoints
            %
            % ENTRADA:
            %   modelName - nome do modelo
            %   config - configuração
            %
            % SAÍDA:
            %   checkpointPath - caminho para checkpoints
            
            try
                timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
                checkpointPath = fullfile(obj.checkpointDir, sprintf('%s_%s', modelName, timestamp));
                
                if ~exist(checkpointPath, 'dir')
                    mkdir(checkpointPath);
                end
                
                obj.logger('info', sprintf('Checkpoints configurados em: %s', checkpointPath));
                
            catch ME
                obj.logger('warning', sprintf('Erro ao configurar checkpoints: %s', ME.message));
                checkpointPath = '';
            end
        end
        
        function cleanupCheckpoints(obj, checkpointPath)
            % Remove checkpoints temporários após treinamento bem-sucedido
            %
            % ENTRADA:
            %   checkpointPath - caminho dos checkpoints
            
            try
                if ~isempty(checkpointPath) && exist(checkpointPath, 'dir')
                    rmdir(checkpointPath, 's');
                    obj.logger('info', 'Checkpoints temporários removidos');
                end
            catch ME
                obj.logger('warning', sprintf('Erro ao limpar checkpoints: %s', ME.message));
            end
        end
        
        function handleTrainingError(obj, ME, modelType)
            % Trata erros durante o treinamento
            %
            % ENTRADA:
            %   ME - MException
            %   modelType - tipo do modelo
            
            obj.logger('error', sprintf('Erro no treinamento %s:', modelType));
            obj.logger('error', sprintf('  Mensagem: %s', ME.message));
            
            if ~isempty(ME.stack)
                obj.logger('error', '  Stack trace:');
                for i = 1:min(3, length(ME.stack))  % Mostrar apenas os 3 primeiros
                    obj.logger('error', sprintf('    %s (linha %d)', ME.stack(i).name, ME.stack(i).line));
                end
            end
            
            % Sugestões baseadas no tipo de erro
            if contains(ME.message, 'Out of memory') || contains(ME.message, 'memory')
                obj.logger('info', 'Sugestão: Reduza o batch size ou use CPU');
            elseif contains(ME.message, 'GPU')
                obj.logger('info', 'Sugestão: Tente usar CPU ou verifique drivers da GPU');
            elseif contains(ME.message, 'layer') || contains(ME.message, 'network')
                obj.logger('info', 'Sugestão: Verifique a arquitetura da rede');
            end
        end
    end
end