classdef HyperparameterOptimizer < handle
    % ========================================================================
    % HYPERPARAMETEROPTIMIZER - OTIMIZADOR DE HIPERPARÂMETROS
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe para otimização automática de hiperparâmetros usando grid search
    %   básico, ajuste automático de batch size baseado na memória disponível
    %   e sistema de recomendação de parâmetros baseado no dataset.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Optimization Toolbox
    %   - Hyperparameter Optimization
    %   - Memory Management
    %
    % USO:
    %   >> optimizer = HyperparameterOptimizer();
    %   >> bestParams = optimizer.optimizeHyperparameters(trainData, valData, config);
    %   >> optimalBatchSize = optimizer.findOptimalBatchSize(config);
    %
    % REQUISITOS: 7.3, 7.4
    % ========================================================================
    
    properties (Access = private)
        logger
        gpuAvailable = false
        availableMemoryGB = 0
        optimizationHistory = []
        bestResults = []
    end
    
    properties (Constant)
        % Ranges padrão para grid search
        LEARNING_RATE_RANGE = [1e-4, 5e-4, 1e-3, 5e-3, 1e-2]
        BATCH_SIZE_RANGE = [2, 4, 8, 16, 32]
        ENCODER_DEPTH_RANGE = [2, 3, 4, 5]
        L2_REGULARIZATION_RANGE = [0, 1e-4, 1e-3, 1e-2]
        
        % Limites de memória
        MIN_MEMORY_PER_SAMPLE_MB = 50  % MB por amostra
        SAFETY_MEMORY_FACTOR = 0.8     % Usar apenas 80% da memória disponível
        
        % Configurações de otimização
        MAX_OPTIMIZATION_TIME_MINUTES = 60
        MIN_VALIDATION_SAMPLES = 10
    end
    
    methods
        function obj = HyperparameterOptimizer()
            % Construtor da classe HyperparameterOptimizer
            % Inicializa o otimizador e detecta recursos disponíveis
            
            obj.initializeLogger();
            obj.detectSystemResources();
            obj.optimizationHistory = [];
            
            obj.logger('info', 'HyperparameterOptimizer inicializado');
        end
        
        function bestParams = optimizeHyperparameters(obj, trainData, valData, config, options)
            % Otimiza hiperparâmetros usando grid search básico
            %
            % ENTRADA:
            %   trainData - datastore de treinamento
            %   valData - datastore de validação
            %   config - configuração base
            %   options (opcional) - opções de otimização
            %
            % SAÍDA:
            %   bestParams - melhores hiperparâmetros encontrados
            %
            % REQUISITOS: 7.3
            
            if nargin < 5
                options = struct();
            end
            
            obj.logger('info', '=== INICIANDO OTIMIZAÇÃO DE HIPERPARÂMETROS ===');
            
            try
                % Validar entradas
                if ~obj.validateOptimizationInputs(trainData, valData, config)
                    error('Entradas de otimização inválidas');
                end
                
                % Configurar parâmetros de busca
                searchSpace = obj.createSearchSpace(config, options);
                obj.logger('info', sprintf('Espaço de busca: %d combinações', obj.countCombinations(searchSpace)));
                
                % Executar grid search
                bestParams = obj.executeGridSearch(trainData, valData, config, searchSpace, options);
                
                % Salvar resultados
                obj.saveOptimizationResults(bestParams);
                
                obj.logger('success', 'Otimização de hiperparâmetros concluída');
                
            catch ME
                obj.logger('error', sprintf('Erro na otimização: %s', ME.message));
                bestParams = obj.getDefaultParameters(config);
                obj.logger('info', 'Usando parâmetros padrão como fallback');
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
            
            obj.logger('info', 'Calculando batch size ótimo...');
            
            try
                % Estimar uso de memória por amostra
                memoryPerSampleMB = obj.estimateMemoryPerSample(config);
                
                % Calcular batch size máximo baseado na memória
                availableMemoryMB = obj.availableMemoryGB * 1024 * obj.SAFETY_MEMORY_FACTOR;
                maxBatchSize = floor(availableMemoryMB / memoryPerSampleMB);
                
                % Limitar aos valores válidos
                validBatchSizes = obj.BATCH_SIZE_RANGE(obj.BATCH_SIZE_RANGE <= maxBatchSize);
                
                if isempty(validBatchSizes)
                    optimalBatchSize = 1;  % Fallback mínimo
                    obj.logger('warning', 'Memória muito limitada, usando batch size 1');
                else
                    optimalBatchSize = max(validBatchSizes);
                    obj.logger('success', sprintf('Batch size ótimo: %d (memória: %.1f MB por amostra)', ...
                        optimalBatchSize, memoryPerSampleMB));
                end
                
                % Ajustar baseado no tipo de hardware
                if obj.gpuAvailable
                    % GPU pode lidar com batch sizes maiores
                    optimalBatchSize = min(optimalBatchSize * 2, 32);
                else
                    % CPU prefere batch sizes menores
                    optimalBatchSize = min(optimalBatchSize, 8);
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao calcular batch size: %s', ME.message));
                optimalBatchSize = 4;  % Valor seguro padrão
            end
        end
        
        function recommendations = recommendParameters(obj, config, datasetInfo)
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
            
            obj.logger('info', 'Gerando recomendações de parâmetros...');
            
            try
                recommendations = struct();
                
                % Recomendações baseadas no tamanho do dataset
                if isfield(datasetInfo, 'numSamples')
                    recommendations = obj.recommendBasedOnDatasetSize(recommendations, datasetInfo.numSamples);
                end
                
                % Recomendações baseadas na complexidade da tarefa
                if isfield(datasetInfo, 'taskComplexity')
                    recommendations = obj.recommendBasedOnComplexity(recommendations, datasetInfo.taskComplexity);
                end
                
                % Recomendações baseadas no hardware
                recommendations = obj.recommendBasedOnHardware(recommendations, config);
                
                % Recomendações baseadas no tamanho da imagem
                recommendations = obj.recommendBasedOnImageSize(recommendations, config.inputSize);
                
                obj.logger('success', 'Recomendações geradas');
                obj.logRecommendations(recommendations);
                
            catch ME
                obj.logger('error', sprintf('Erro ao gerar recomendações: %s', ME.message));
                recommendations = obj.getDefaultParameters(config);
            end
        end
        
        function results = getOptimizationHistory(obj)
            % Retorna histórico de otimizações
            %
            % SAÍDA:
            %   results - histórico de otimizações realizadas
            
            results = obj.optimizationHistory;
        end
        
        function bestConfig = getBestConfiguration(obj)
            % Retorna a melhor configuração encontrada
            %
            % SAÍDA:
            %   bestConfig - melhor configuração de hiperparâmetros
            
            if isempty(obj.bestResults)
                bestConfig = [];
                obj.logger('warning', 'Nenhuma otimização foi executada ainda');
            else
                bestConfig = obj.bestResults;
                obj.logger('info', 'Retornando melhor configuração encontrada');
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
                    prefix = '🔧';
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
        
        function detectSystemResources(obj)
            % Detecta recursos do sistema disponíveis
            
            try
                % Detectar GPU
                try
                    if license('test', 'Distrib_Computing_Toolbox') || license('test', 'Parallel_Computing_Toolbox')
                        gpuDevice();
                        obj.gpuAvailable = true;
                        obj.logger('info', 'GPU detectada');
                    end
                catch
                    obj.gpuAvailable = false;
                    obj.logger('info', 'GPU não disponível');
                end
                
                % Estimar memória disponível
                if ispc
                    [~, memInfo] = memory;
                    obj.availableMemoryGB = memInfo.PhysicalMemory.Available / (1024^3);
                else
                    % Para Linux/Mac, usar estimativa conservadora
                    obj.availableMemoryGB = 4;
                end
                
                obj.logger('info', sprintf('Memória disponível: %.1f GB', obj.availableMemoryGB));
                
            catch ME
                obj.logger('warning', sprintf('Erro ao detectar recursos: %s', ME.message));
                obj.availableMemoryGB = 2;  % Valor conservador
            end
        end
        
        function isValid = validateOptimizationInputs(obj, trainData, valData, config)
            % Valida entradas para otimização
            
            isValid = false;
            
            try
                if isempty(trainData) || isempty(valData)
                    obj.logger('error', 'Datastores não podem estar vazios');
                    return;
                end
                
                if ~isfield(config, 'inputSize') || ~isfield(config, 'numClasses')
                    obj.logger('error', 'Configuração deve conter inputSize e numClasses');
                    return;
                end
                
                % Verificar se há amostras suficientes para validação
                try
                    reset(valData);
                    sampleCount = 0;
                    while hasdata(valData) && sampleCount < obj.MIN_VALIDATION_SAMPLES
                        read(valData);
                        sampleCount = sampleCount + 1;
                    end
                    
                    if sampleCount < obj.MIN_VALIDATION_SAMPLES
                        obj.logger('warning', sprintf('Poucas amostras de validação (%d < %d)', ...
                            sampleCount, obj.MIN_VALIDATION_SAMPLES));
                    end
                    
                    reset(valData);
                catch
                    obj.logger('warning', 'Não foi possível contar amostras de validação');
                end
                
                isValid = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na validação: %s', ME.message));
            end
        end
        
        function searchSpace = createSearchSpace(obj, config, options)
            % Cria espaço de busca para grid search
            
            searchSpace = struct();
            
            % Learning rates
            if isfield(options, 'learningRates')
                searchSpace.learningRates = options.learningRates;
            else
                searchSpace.learningRates = obj.LEARNING_RATE_RANGE;
            end
            
            % Batch sizes (limitado pela memória)
            maxBatchSize = obj.findOptimalBatchSize(config);
            validBatchSizes = obj.BATCH_SIZE_RANGE(obj.BATCH_SIZE_RANGE <= maxBatchSize);
            searchSpace.batchSizes = validBatchSizes;
            
            % Encoder depths
            if isfield(options, 'encoderDepths')
                searchSpace.encoderDepths = options.encoderDepths;
            else
                maxDepth = floor(log2(min(config.inputSize(1:2)))) - 2;
                validDepths = obj.ENCODER_DEPTH_RANGE(obj.ENCODER_DEPTH_RANGE <= maxDepth);
                searchSpace.encoderDepths = validDepths;
            end
            
            % L2 regularization
            if isfield(options, 'l2Factors')
                searchSpace.l2Factors = options.l2Factors;
            else
                searchSpace.l2Factors = obj.L2_REGULARIZATION_RANGE;
            end
            
            obj.logger('info', sprintf('Espaço de busca criado: LR=%d, BS=%d, ED=%d, L2=%d', ...
                length(searchSpace.learningRates), length(searchSpace.batchSizes), ...
                length(searchSpace.encoderDepths), length(searchSpace.l2Factors)));
        end
        
        function numCombinations = countCombinations(obj, searchSpace)
            % Conta número total de combinações no espaço de busca
            
            numCombinations = length(searchSpace.learningRates) * ...
                            length(searchSpace.batchSizes) * ...
                            length(searchSpace.encoderDepths) * ...
                            length(searchSpace.l2Factors);
        end
        
        function bestParams = executeGridSearch(obj, trainData, valData, config, searchSpace, options)
            % Executa grid search para encontrar melhores hiperparâmetros
            
            obj.logger('info', 'Executando grid search...');
            
            bestParams = struct();
            bestScore = -Inf;
            totalCombinations = obj.countCombinations(searchSpace);
            currentCombination = 0;
            
            startTime = tic;
            
            % Iterar sobre todas as combinações
            for lr = searchSpace.learningRates
                for bs = searchSpace.batchSizes
                    for ed = searchSpace.encoderDepths
                        for l2 = searchSpace.l2Factors
                            currentCombination = currentCombination + 1;
                            
                            % Verificar limite de tempo
                            elapsedMinutes = toc(startTime) / 60;
                            if elapsedMinutes > obj.MAX_OPTIMIZATION_TIME_MINUTES
                                obj.logger('warning', 'Limite de tempo atingido, parando otimização');
                                break;
                            end
                            
                            % Criar configuração de teste
                            testConfig = config;
                            testConfig.learningRate = lr;
                            testConfig.miniBatchSize = bs;
                            testConfig.encoderDepth = ed;
                            testConfig.l2Factor = l2;
                            testConfig.maxEpochs = 5;  % Épocas reduzidas para otimização rápida
                            
                            obj.logger('info', sprintf('Testando combinação %d/%d: LR=%.2e, BS=%d, ED=%d, L2=%.2e', ...
                                currentCombination, totalCombinations, lr, bs, ed, l2));
                            
                            % Avaliar configuração
                            score = obj.evaluateConfiguration(trainData, valData, testConfig);
                            
                            % Salvar no histórico
                            result = struct();
                            result.learningRate = lr;
                            result.batchSize = bs;
                            result.encoderDepth = ed;
                            result.l2Factor = l2;
                            result.score = score;
                            result.timestamp = datetime('now');
                            
                            obj.optimizationHistory = [obj.optimizationHistory; result];
                            
                            % Atualizar melhor resultado
                            if score > bestScore
                                bestScore = score;
                                bestParams = result;
                                obj.logger('success', sprintf('Nova melhor configuração: score=%.4f', score));
                            end
                        end
                    end
                end
            end
            
            obj.bestResults = bestParams;
            obj.logger('success', sprintf('Grid search concluído. Melhor score: %.4f', bestScore));
        end
        
        function score = evaluateConfiguration(obj, trainData, valData, config)
            % Avalia uma configuração específica de hiperparâmetros
            
            score = 0;
            
            try
                % Criar modelo simples para teste rápido
                lgraph = unetLayers(config.inputSize, config.numClasses, 'EncoderDepth', config.encoderDepth);
                
                % Configurar opções de treinamento rápido
                options = trainingOptions('adam', ...
                    'InitialLearnRate', config.learningRate, ...
                    'MaxEpochs', config.maxEpochs, ...
                    'MiniBatchSize', config.miniBatchSize, ...
                    'ValidationData', valData, ...
                    'ValidationFrequency', 2, ...
                    'Verbose', false, ...
                    'Plots', 'none', ...
                    'ExecutionEnvironment', 'auto');
                
                % Treinar modelo
                net = trainNetwork(trainData, lgraph, options);
                
                % Avaliar performance na validação
                reset(valData);
                totalAccuracy = 0;
                numSamples = 0;
                
                while hasdata(valData) && numSamples < 10  % Avaliar apenas algumas amostras
                    data = read(valData);
                    img = data{1};
                    gt = data{2};
                    
                    pred = semanticseg(img, net);
                    accuracy = obj.calculateAccuracy(pred, gt);
                    
                    totalAccuracy = totalAccuracy + accuracy;
                    numSamples = numSamples + 1;
                end
                
                if numSamples > 0
                    score = totalAccuracy / numSamples;
                end
                
            catch ME
                obj.logger('warning', sprintf('Erro na avaliação: %s', ME.message));
                score = 0;  % Penalizar configurações que falham
            end
        end
        
        function accuracy = calculateAccuracy(obj, pred, gt)
            % Calcula acurácia simples entre predição e ground truth
            
            try
                if iscategorical(pred)
                    predVals = double(pred);
                else
                    predVals = pred;
                end
                
                if iscategorical(gt)
                    gtVals = double(gt);
                else
                    gtVals = gt;
                end
                
                correct = sum(predVals(:) == gtVals(:));
                total = numel(gtVals);
                accuracy = correct / total;
            catch
                accuracy = 0;
            end
        end
        
        function memoryMB = estimateMemoryPerSample(obj, config)
            % Estima uso de memória por amostra
            
            % Cálculo baseado no tamanho da imagem e profundidade da rede
            imageSize = prod(config.inputSize);
            
            % Estimativa conservadora: 4 bytes por pixel * fator de overhead
            overheadFactor = 10;  % Considera gradientes, ativações, etc.
            memoryMB = (imageSize * 4 * overheadFactor) / (1024^2);
            
            % Ajustar baseado na profundidade da rede
            if isfield(config, 'encoderDepth')
                memoryMB = memoryMB * config.encoderDepth;
            else
                memoryMB = memoryMB * 4;  % Profundidade padrão
            end
            
            memoryMB = max(memoryMB, obj.MIN_MEMORY_PER_SAMPLE_MB);
        end
        
        function recommendations = recommendBasedOnDatasetSize(obj, recommendations, numSamples)
            % Recomendações baseadas no tamanho do dataset
            
            if numSamples < 100
                % Dataset pequeno - mais regularização, learning rate menor
                recommendations.learningRate = 1e-4;
                recommendations.l2Factor = 1e-2;
                recommendations.batchSize = min(4, numSamples);
                obj.logger('info', 'Dataset pequeno detectado - aumentando regularização');
            elseif numSamples < 1000
                % Dataset médio
                recommendations.learningRate = 5e-4;
                recommendations.l2Factor = 1e-3;
                recommendations.batchSize = 8;
            else
                % Dataset grande - menos regularização, learning rate maior
                recommendations.learningRate = 1e-3;
                recommendations.l2Factor = 1e-4;
                recommendations.batchSize = 16;
                obj.logger('info', 'Dataset grande detectado - reduzindo regularização');
            end
        end
        
        function recommendations = recommendBasedOnComplexity(obj, recommendations, complexity)
            % Recomendações baseadas na complexidade da tarefa
            
            switch lower(complexity)
                case 'low'
                    recommendations.encoderDepth = 3;
                    recommendations.maxEpochs = 20;
                case 'medium'
                    recommendations.encoderDepth = 4;
                    recommendations.maxEpochs = 30;
                case 'high'
                    recommendations.encoderDepth = 5;
                    recommendations.maxEpochs = 50;
                otherwise
                    recommendations.encoderDepth = 4;
                    recommendations.maxEpochs = 30;
            end
        end
        
        function recommendations = recommendBasedOnHardware(obj, recommendations, config)
            % Recomendações baseadas no hardware disponível
            
            if obj.gpuAvailable
                % GPU disponível - pode usar batch sizes maiores
                if ~isfield(recommendations, 'batchSize')
                    recommendations.batchSize = 16;
                end
                recommendations.executionEnvironment = 'gpu';
                obj.logger('info', 'GPU detectada - usando configurações otimizadas para GPU');
            else
                % Apenas CPU - batch sizes menores
                if ~isfield(recommendations, 'batchSize')
                    recommendations.batchSize = 4;
                end
                recommendations.executionEnvironment = 'cpu';
                obj.logger('info', 'Apenas CPU disponível - usando configurações otimizadas para CPU');
            end
            
            % Ajustar baseado na memória disponível
            if obj.availableMemoryGB < 4
                recommendations.batchSize = min(recommendations.batchSize, 4);
                obj.logger('info', 'Pouca memória disponível - reduzindo batch size');
            end
        end
        
        function recommendations = recommendBasedOnImageSize(obj, recommendations, inputSize)
            % Recomendações baseadas no tamanho da imagem
            
            imageArea = inputSize(1) * inputSize(2);
            
            if imageArea >= 512 * 512
                % Imagens grandes
                recommendations.encoderDepth = 5;
                if ~isfield(recommendations, 'batchSize')
                    recommendations.batchSize = 4;  % Batch size menor para imagens grandes
                end
            elseif imageArea >= 256 * 256
                % Imagens médias
                recommendations.encoderDepth = 4;
                if ~isfield(recommendations, 'batchSize')
                    recommendations.batchSize = 8;
                end
            else
                % Imagens pequenas
                recommendations.encoderDepth = 3;
                if ~isfield(recommendations, 'batchSize')
                    recommendations.batchSize = 16;
                end
            end
        end
        
        function defaultParams = getDefaultParameters(obj, config)
            % Retorna parâmetros padrão seguros
            
            defaultParams = struct();
            defaultParams.learningRate = 1e-3;
            defaultParams.batchSize = obj.findOptimalBatchSize(config);
            defaultParams.encoderDepth = 4;
            defaultParams.l2Factor = 1e-3;
            defaultParams.maxEpochs = 30;
            defaultParams.executionEnvironment = obj.gpuAvailable ? 'gpu' : 'cpu';
        end
        
        function logRecommendations(obj, recommendations)
            % Exibe recomendações de forma organizada
            
            obj.logger('info', '--- RECOMENDAÇÕES DE HIPERPARÂMETROS ---');
            
            fields = fieldnames(recommendations);
            for i = 1:length(fields)
                field = fields{i};
                value = recommendations.(field);
                
                if isnumeric(value)
                    if value < 1e-2
                        obj.logger('info', sprintf('  %s: %.2e', field, value));
                    else
                        obj.logger('info', sprintf('  %s: %.4g', field, value));
                    end
                else
                    obj.logger('info', sprintf('  %s: %s', field, string(value)));
                end
            end
            
            obj.logger('info', '----------------------------------------');
        end
        
        function saveOptimizationResults(obj, bestParams)
            % Salva resultados da otimização
            
            try
                resultsDir = fullfile('output', 'optimization');
                if ~exist(resultsDir, 'dir')
                    mkdir(resultsDir);
                end
                
                timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
                filename = sprintf('hyperparameter_optimization_%s.mat', timestamp);
                filepath = fullfile(resultsDir, filename);
                
                optimizationResults = struct();
                optimizationResults.bestParams = bestParams;
                optimizationResults.history = obj.optimizationHistory;
                optimizationResults.timestamp = timestamp;
                
                save(filepath, 'optimizationResults');
                obj.logger('success', sprintf('Resultados salvos: %s', filepath));
                
            catch ME
                obj.logger('warning', sprintf('Erro ao salvar resultados: %s', ME.message));
            end
        end
    end
end