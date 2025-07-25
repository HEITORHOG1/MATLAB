classdef ComparisonController < handle
    % ========================================================================
    % COMPARISONCONTROLLER - SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe principal que orquestra todo o processo de comparação entre
    %   U-Net e Attention U-Net. Coordena treinamento, avaliação e geração
    %   de relatórios automáticos com interpretação.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Deep Learning Toolbox
    %   - Object-Oriented Programming
    %   - Parallel Computing Toolbox
    %
    % USO:
    %   >> controller = ComparisonController(config);
    %   >> results = controller.runFullComparison();
    %
    % REQUISITOS: 1.1, 1.2, 1.3, 1.4, 1.5
    % ========================================================================
    
    properties (Access = private)
        config
        configManager
        dataLoader
        dataPreprocessor
        modelTrainer
        metricsCalculator
        statisticalAnalyzer
        crossValidator
        logger
        
        % Estado interno
        currentStep = 'initialized'
        startTime
        results = struct()
        
        % Componentes de dados
        trainData = []
        valData = []
        testData = []
        
        % Modelos treinados
        unetModel = []
        attentionUnetModel = []
        
        % Métricas
        unetMetrics = []
        attentionMetrics = []
        
        % Gerenciador de execução otimizada
        executionManager = []
        
        % Configurações de execução
        enableParallelTraining = false
        enableDetailedLogging = true
        enableQuickTest = false
        quickTestSampleSize = 50
    end
    
    properties (Constant)
        SUPPORTED_MODES = {'full', 'quick', 'models_only', 'evaluation_only'}
        LOG_LEVELS = {'info', 'success', 'warning', 'error', 'debug'}
        PIPELINE_STEPS = {'initialization', 'data_loading', 'data_preprocessing', ...
                         'model_training', 'model_evaluation', 'statistical_analysis', ...
                         'report_generation', 'completed'}
    end
    
    methods
        function obj = ComparisonController(config, varargin)
            % Construtor da classe ComparisonController
            %
            % ENTRADA:
            %   config - estrutura de configuração do sistema
            %   varargin - parâmetros opcionais:
            %     'EnableParallelTraining' - true/false (padrão: false)
            %     'EnableDetailedLogging' - true/false (padrão: true)
            %     'EnableQuickTest' - true/false (padrão: false)
            %     'QuickTestSampleSize' - número de amostras para teste rápido (padrão: 50)
            
            if nargin < 1
                error('ComparisonController:InvalidInput', 'Configuração é obrigatória');
            end
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'EnableParallelTraining', false, @islogical);
            addParameter(p, 'EnableDetailedLogging', true, @islogical);
            addParameter(p, 'EnableQuickTest', false, @islogical);
            addParameter(p, 'QuickTestSampleSize', 50, @isnumeric);
            parse(p, varargin{:});
            
            obj.config = config;
            obj.enableParallelTraining = p.Results.EnableParallelTraining;
            obj.enableDetailedLogging = p.Results.EnableDetailedLogging;
            obj.enableQuickTest = p.Results.EnableQuickTest;
            obj.quickTestSampleSize = p.Results.QuickTestSampleSize;
            
            % Inicializar sistema de logging
            obj.initializeLogger();
            
            % Inicializar componentes
            obj.initializeComponents();
            
            obj.logger('info', '=== COMPARISON CONTROLLER INICIALIZADO ===');
            obj.logger('info', sprintf('Modo paralelo: %s', obj.boolToString(obj.enableParallelTraining)));
            obj.logger('info', sprintf('Teste rápido: %s', obj.boolToString(obj.enableQuickTest)));
            
            obj.currentStep = 'initialized';
        end
        
        function results = runFullComparison(obj, varargin)
            % Executa pipeline completo de comparação
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'Mode' - 'full', 'quick', 'models_only', 'evaluation_only' (padrão: 'full')
            %     'SaveModels' - true/false (padrão: true)
            %     'GenerateReports' - true/false (padrão: true)
            %     'RunCrossValidation' - true/false (padrão: false)
            %
            % SAÍDA:
            %   results - estrutura completa com todos os resultados
            %
            % REQUISITOS: 1.1, 1.2
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Mode', 'full', @(x) ismember(x, obj.SUPPORTED_MODES));
            addParameter(p, 'SaveModels', true, @islogical);
            addParameter(p, 'GenerateReports', true, @islogical);
            addParameter(p, 'RunCrossValidation', false, @islogical);
            parse(p, varargin{:});
            
            mode = p.Results.Mode;
            saveModels = p.Results.SaveModels;
            generateReports = p.Results.GenerateReports;
            runCrossValidation = p.Results.RunCrossValidation;
            
            obj.startTime = tic;
            
            try
                obj.logger('info', '🚀 INICIANDO COMPARAÇÃO COMPLETA U-NET vs ATTENTION U-NET');
                obj.logger('info', sprintf('Modo de execução: %s', upper(mode)));
                
                % Executar pipeline baseado no modo
                switch mode
                    case 'full'
                        results = obj.executeFullPipeline(saveModels, generateReports, runCrossValidation);
                    case 'quick'
                        obj.enableQuickTest = true;
                        results = obj.executeFullPipeline(saveModels, generateReports, false);
                    case 'models_only'
                        results = obj.executeModelTrainingOnly(saveModels);
                    case 'evaluation_only'
                        results = obj.executeEvaluationOnly(generateReports);
                end
                
                % Finalizar execução
                obj.finalizeExecution(results);
                
            catch ME
                obj.handleExecutionError(ME);
                rethrow(ME);
            end
        end
        
        function results = executeModelTrainingOnly(obj, saveModels)
            % Executa apenas o treinamento dos modelos
            %
            % ENTRADA:
            %   saveModels - true/false para salvar modelos
            %
            % SAÍDA:
            %   results - estrutura com modelos treinados
            
            obj.logger('info', '🔧 MODO: Treinamento de Modelos Apenas');
            
            % Carregar e preparar dados
            obj.loadAndPrepareData();
            
            % Treinar modelos
            obj.trainModels(saveModels);
            
            % Preparar resultados básicos
            results = obj.prepareBasicResults();
            
            obj.logger('success', 'Treinamento de modelos concluído');
            return results;
        end
        
        function results = executeEvaluationOnly(obj, generateReports)
            % Executa apenas avaliação de modelos já treinados
            %
            % ENTRADA:
            %   generateReports - true/false para gerar relatórios
            %
            % SAÍDA:
            %   results - estrutura com avaliação completa
            
            obj.logger('info', '📊 MODO: Avaliação Apenas');
            
            % Carregar modelos existentes
            obj.loadExistingModels();
            
            % Carregar e preparar dados
            obj.loadAndPrepareData();
            
            % Avaliar modelos
            obj.evaluateModels();
            
            % Análise estatística
            obj.performStatisticalAnalysis();
            
            % Gerar relatórios se solicitado
            if generateReports
                obj.generateReports();
            end
            
            % Preparar resultados completos
            results = obj.prepareCompleteResults();
            
            obj.logger('success', 'Avaliação concluída');
            return results;
        end
        
        function status = getExecutionStatus(obj)
            % Retorna status atual da execução
            %
            % SAÍDA:
            %   status - estrutura com informações de status
            
            status = struct();
            status.currentStep = obj.currentStep;
            status.stepsCompleted = obj.getCompletedSteps();
            status.totalSteps = length(obj.PIPELINE_STEPS);
            status.progressPercent = (status.stepsCompleted / status.totalSteps) * 100;
            
            if ~isempty(obj.startTime)
                status.elapsedTime = toc(obj.startTime);
                status.estimatedTimeRemaining = obj.estimateRemainingTime(status.progressPercent);
            else
                status.elapsedTime = 0;
                status.estimatedTimeRemaining = 0;
            end
            
            status.hasErrors = obj.hasErrors();
            status.lastError = obj.getLastError();
        end
        
        function summary = generateExecutionSummary(obj)
            % Gera resumo da execução
            %
            % SAÍDA:
            %   summary - string com resumo da execução
            
            status = obj.getExecutionStatus();
            
            summary = sprintf(['=== RESUMO DA EXECUÇÃO ===\n' ...
                              'Status: %s\n' ...
                              'Progresso: %.1f%% (%d/%d etapas)\n' ...
                              'Tempo decorrido: %.2f segundos\n'], ...
                              obj.currentStep, status.progressPercent, ...
                              status.stepsCompleted, status.totalSteps, ...
                              status.elapsedTime);
            
            if ~isempty(obj.results)
                if isfield(obj.results, 'comparison') && isfield(obj.results.comparison, 'winner')
                    summary = [summary sprintf('Modelo vencedor: %s\n', obj.results.comparison.winner)];
                end
                
                if isfield(obj.results, 'models')
                    if isfield(obj.results.models, 'unet') && isfield(obj.results.models.unet, 'metrics')
                        unetMean = mean([obj.results.models.unet.metrics.iou, ...
                                       obj.results.models.unet.metrics.dice, ...
                                       obj.results.models.unet.metrics.accuracy]);
                        summary = [summary sprintf('U-Net performance média: %.4f\n', unetMean)];
                    end
                    
                    if isfield(obj.results.models, 'attentionUnet') && isfield(obj.results.models.attentionUnet, 'metrics')
                        attentionMean = mean([obj.results.models.attentionUnet.metrics.iou, ...
                                            obj.results.models.attentionUnet.metrics.dice, ...
                                            obj.results.models.attentionUnet.metrics.accuracy]);
                        summary = [summary sprintf('Attention U-Net performance média: %.4f\n', attentionMean)];
                    end
                end
            end
        end
    end
    
    methods (Access = private)
        function initializeLogger(obj)
            % Inicializa sistema de logging detalhado
            obj.logger = @(level, msg) obj.logMessage(level, msg);
        end
        
        function logMessage(obj, level, message)
            % Sistema de logging com diferentes níveis
            %
            % REQUISITOS: 1.2 (sistema de logging detalhado)
            
            if ~obj.enableDetailedLogging && strcmp(level, 'debug')
                return;
            end
            
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
                case 'debug'
                    prefix = '🔍';
                otherwise
                    prefix = '📝';
            end
            
            fprintf('[%s] %s %s\n', timestamp, prefix, message);
            
            % Salvar em arquivo de log se configurado
            if isfield(obj.config, 'logFile') && ~isempty(obj.config.logFile)
                try
                    fid = fopen(obj.config.logFile, 'a');
                    if fid ~= -1
                        fprintf(fid, '[%s] [%s] %s\n', timestamp, upper(level), message);
                        fclose(fid);
                    end
                catch
                    % Ignorar erros de logging para não interromper execução
                end
            end
        end
        
        function initializeComponents(obj)
            % Inicializa todos os componentes necessários
            
            try
                obj.logger('info', 'Inicializando componentes...');
                
                % Inicializar gerenciador de configuração
                obj.configManager = ConfigManager();
                
                % Inicializar carregador de dados
                obj.dataLoader = DataLoader(obj.config);
                
                % Inicializar preprocessador
                obj.dataPreprocessor = DataPreprocessor(obj.config);
                
                % Inicializar treinador de modelos
                obj.modelTrainer = ModelTrainer();
                
                % Inicializar calculador de métricas
                obj.metricsCalculator = MetricsCalculator('verbose', obj.enableDetailedLogging);
                
                % Inicializar analisador estatístico
                obj.statisticalAnalyzer = StatisticalAnalyzer('verbose', obj.enableDetailedLogging);
                
                % Inicializar validador cruzado
                obj.crossValidator = CrossValidator();
                
                % Inicializar gerenciador de execução otimizada
                obj.executionManager = ExecutionManager('MaxConcurrentJobs', 2, ...
                    'EnableMemoryOptimization', true, 'EnableGPUOptimization', true, ...
                    'QuickTestRatio', 0.1);
                
                obj.logger('success', 'Todos os componentes inicializados');
                
            catch ME
                obj.logger('error', sprintf('Erro na inicialização: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function results = executeFullPipeline(obj, saveModels, generateReports, runCrossValidation)
            % Executa pipeline completo de comparação
            
            obj.logger('info', '🔄 EXECUTANDO PIPELINE COMPLETO');
            
            % 1. Carregar e preparar dados
            obj.updateStep('data_loading');
            obj.loadAndPrepareData();
            
            % 2. Treinar modelos
            obj.updateStep('model_training');
            obj.trainModels(saveModels);
            
            % 3. Avaliar modelos
            obj.updateStep('model_evaluation');
            obj.evaluateModels();
            
            % 4. Análise estatística
            obj.updateStep('statistical_analysis');
            obj.performStatisticalAnalysis();
            
            % 5. Validação cruzada (opcional)
            if runCrossValidation
                obj.performCrossValidation();
            end
            
            % 6. Gerar relatórios
            if generateReports
                obj.updateStep('report_generation');
                obj.generateReports();
            end
            
            % 7. Preparar resultados finais
            results = obj.prepareCompleteResults();
            
            obj.updateStep('completed');
            return results;
        end
        
        function loadAndPrepareData(obj)
            % Carrega e prepara dados para treinamento e avaliação
            
            obj.logger('info', '📂 Carregando e preparando dados...');
            
            try
                % Carregar dados brutos
                [images, masks] = obj.dataLoader.loadData('Verbose', obj.enableDetailedLogging);
                
                % Aplicar modo de teste rápido se habilitado usando ExecutionManager
                if obj.enableQuickTest && length(images) > obj.quickTestSampleSize
                    obj.logger('info', sprintf('🚀 Aplicando modo teste rápido...'));
                    
                    % Usar ExecutionManager para otimizar dados
                    optimizedData = obj.executionManager.enableQuickTestMode({images, masks}, ...
                        'MaxSamples', obj.quickTestSampleSize, 'Strategy', 'random');
                    
                    images = optimizedData{1};
                    masks = optimizedData{2};
                end
                
                % Dividir dados
                [obj.trainData, obj.valData, obj.testData] = obj.dataLoader.splitData(images, masks, ...
                    'TrainRatio', 0.7, 'ValRatio', 0.2, 'TestRatio', 0.1, 'Shuffle', true);
                
                obj.logger('success', sprintf('Dados preparados: %d treino, %d validação, %d teste', ...
                    obj.trainData.size, obj.valData.size, obj.testData.size));
                
            catch ME
                obj.logger('error', sprintf('Erro no carregamento de dados: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function trainModels(obj, saveModels)
            % Treina ambos os modelos (U-Net e Attention U-Net)
            
            obj.logger('info', '🏋️ Iniciando treinamento dos modelos...');
            
            try
                % Criar datastores para treinamento
                trainDS = obj.createDatastore(obj.trainData, true);
                valDS = obj.createDatastore(obj.valData, false);
                
                if obj.enableParallelTraining && obj.canRunParallel()
                    % Treinamento paralelo (se recursos permitirem)
                    obj.trainModelsParallel(trainDS, valDS, saveModels);
                else
                    % Treinamento sequencial
                    obj.trainModelsSequential(trainDS, valDS, saveModels);
                end
                
                obj.logger('success', 'Treinamento de ambos os modelos concluído');
                
            catch ME
                obj.logger('error', sprintf('Erro no treinamento: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function trainModelsSequential(obj, trainDS, valDS, saveModels)
            % Treina modelos sequencialmente
            
            obj.logger('info', '⏭️ Treinamento sequencial iniciado');
            
            % Treinar U-Net
            obj.logger('info', '1️⃣ Treinando U-Net...');
            obj.unetModel = obj.modelTrainer.trainUNet(trainDS, valDS, obj.config);
            
            if saveModels
                obj.modelTrainer.saveModel(obj.unetModel, 'unet_comparison', obj.config, 0);
            end
            
            % Treinar Attention U-Net
            obj.logger('info', '2️⃣ Treinando Attention U-Net...');
            obj.attentionUnetModel = obj.modelTrainer.trainAttentionUNet(trainDS, valDS, obj.config);
            
            if saveModels
                obj.modelTrainer.saveModel(obj.attentionUnetModel, 'attention_unet_comparison', obj.config, 0);
            end
        end
        
        function trainModelsParallel(obj, trainDS, valDS, saveModels)
            % Treina modelos em paralelo quando recursos permitirem
            %
            % REQUISITOS: 7.4 (execução paralela quando recursos permitirem)
            
            obj.logger('info', '⚡ Treinamento paralelo iniciado');
            
            try
                % Habilitar execução paralela no ExecutionManager
                if obj.executionManager.enableParallelExecution()
                    obj.logger('success', 'Execução paralela habilitada');
                    
                    % Otimizar configuração para recursos disponíveis
                    optimizedConfig = obj.executionManager.optimizeResourceUsage(obj.config);
                    
                    % Criar tarefas de treinamento
                    unetTask = @() obj.modelTrainer.trainUNet(trainDS, valDS, optimizedConfig);
                    attentionTask = @() obj.modelTrainer.trainAttentionUNet(trainDS, valDS, optimizedConfig);
                    
                    % Executar tarefas em paralelo usando queue
                    tasks = {unetTask, attentionTask};
                    results = obj.executionManager.executeWithQueue(tasks, 'Priority', 'high');
                    
                    if length(results) == 2
                        obj.unetModel = results{1};
                        obj.attentionUnetModel = results{2};
                        
                        % Salvar modelos se solicitado
                        if saveModels
                            obj.modelTrainer.saveModel(obj.unetModel, 'unet_parallel', optimizedConfig, 0);
                            obj.modelTrainer.saveModel(obj.attentionUnetModel, 'attention_unet_parallel', optimizedConfig, 0);
                        end
                        
                        obj.logger('success', 'Treinamento paralelo concluído com sucesso');
                    else
                        obj.logger('warning', 'Treinamento paralelo falhou, usando sequencial');
                        obj.trainModelsSequential(trainDS, valDS, saveModels);
                    end
                else
                    obj.logger('warning', 'Recursos insuficientes para execução paralela, usando sequencial');
                    obj.trainModelsSequential(trainDS, valDS, saveModels);
                end
                
            catch ME
                obj.logger('error', sprintf('Erro no treinamento paralelo: %s', ME.message));
                obj.logger('info', 'Fallback para treinamento sequencial');
                obj.trainModelsSequential(trainDS, valDS, saveModels);
            end
        end
        
        function evaluateModels(obj)
            % Avalia ambos os modelos nos dados de teste
            
            obj.logger('info', '📊 Avaliando modelos...');
            
            try
                % Criar datastore de teste
                testDS = obj.createDatastore(obj.testData, false);
                
                % Avaliar U-Net
                obj.logger('info', '📈 Avaliando U-Net...');
                obj.unetMetrics = obj.evaluateModel(obj.unetModel, testDS, 'U-Net');
                
                % Avaliar Attention U-Net
                obj.logger('info', '📈 Avaliando Attention U-Net...');
                obj.attentionMetrics = obj.evaluateModel(obj.attentionUnetModel, testDS, 'Attention U-Net');
                
                obj.logger('success', 'Avaliação de ambos os modelos concluída');
                
            catch ME
                obj.logger('error', sprintf('Erro na avaliação: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function metrics = evaluateModel(obj, model, testDS, modelName)
            % Avalia um modelo específico
            %
            % ENTRADA:
            %   model - modelo treinado
            %   testDS - datastore de teste
            %   modelName - nome do modelo para logging
            %
            % SAÍDA:
            %   metrics - estrutura com métricas calculadas
            
            obj.logger('debug', sprintf('Iniciando avaliação do %s', modelName));
            
            allMetrics = [];
            numBatches = 0;
            
            % Resetar datastore
            reset(testDS);
            
            % Processar todos os batches
            while hasdata(testDS)
                try
                    % Ler batch
                    batch = read(testDS);
                    
                    % Fazer predições
                    predictions = predict(model, batch{:,1});
                    groundTruth = batch{:,2};
                    
                    % Calcular métricas para cada amostra no batch
                    batchSize = size(predictions, 4);
                    for i = 1:batchSize
                        pred = predictions(:,:,:,i);
                        gt = groundTruth(:,:,i);
                        
                        % Converter predição para formato adequado
                        [~, pred] = max(pred, [], 3);
                        pred = pred - 1; % Converter para 0-based
                        
                        % Calcular métricas
                        sampleMetrics = obj.metricsCalculator.calculateAllMetrics(pred, gt);
                        
                        if isempty(allMetrics)
                            allMetrics = sampleMetrics;
                            allMetrics.iou = [allMetrics.iou];
                            allMetrics.dice = [allMetrics.dice];
                            allMetrics.accuracy = [allMetrics.accuracy];
                        else
                            allMetrics.iou(end+1) = sampleMetrics.iou;
                            allMetrics.dice(end+1) = sampleMetrics.dice;
                            allMetrics.accuracy(end+1) = sampleMetrics.accuracy;
                        end
                    end
                    
                    numBatches = numBatches + 1;
                    
                catch ME
                    obj.logger('warning', sprintf('Erro no batch %d: %s', numBatches+1, ME.message));
                    continue;
                end
            end
            
            % Calcular estatísticas finais
            metrics = struct();
            metrics.iou = struct('values', allMetrics.iou, 'mean', mean(allMetrics.iou), 'std', std(allMetrics.iou));
            metrics.dice = struct('values', allMetrics.dice, 'mean', mean(allMetrics.dice), 'std', std(allMetrics.dice));
            metrics.accuracy = struct('values', allMetrics.accuracy, 'mean', mean(allMetrics.accuracy), 'std', std(allMetrics.accuracy));
            metrics.numSamples = length(allMetrics.iou);
            
            obj.logger('info', sprintf('%s - IoU: %.4f±%.4f, Dice: %.4f±%.4f, Acc: %.4f±%.4f', ...
                modelName, metrics.iou.mean, metrics.iou.std, ...
                metrics.dice.mean, metrics.dice.std, ...
                metrics.accuracy.mean, metrics.accuracy.std));
        end
        
        function performStatisticalAnalysis(obj)
            % Realiza análise estatística comparativa
            %
            % REQUISITOS: 3.1, 3.2, 3.3 (análise estatística avançada)
            
            obj.logger('info', '🔬 Realizando análise estatística...');
            
            try
                % Comparar IoU
                iouComparison = obj.statisticalAnalyzer.performTTest(...
                    obj.unetMetrics.iou.values, obj.attentionMetrics.iou.values);
                
                % Comparar Dice
                diceComparison = obj.statisticalAnalyzer.performTTest(...
                    obj.unetMetrics.dice.values, obj.attentionMetrics.dice.values);
                
                % Comparar Accuracy
                accuracyComparison = obj.statisticalAnalyzer.performTTest(...
                    obj.unetMetrics.accuracy.values, obj.attentionMetrics.accuracy.values);
                
                % Armazenar resultados
                obj.results.statistical = struct();
                obj.results.statistical.iou = iouComparison;
                obj.results.statistical.dice = diceComparison;
                obj.results.statistical.accuracy = accuracyComparison;
                
                % Determinar vencedor geral
                obj.results.comparison = obj.determineOverallWinner();
                
                obj.logger('success', 'Análise estatística concluída');
                obj.logger('info', sprintf('Resultado: %s', obj.results.comparison.summary));
                
            catch ME
                obj.logger('error', sprintf('Erro na análise estatística: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function performCrossValidation(obj)
            % Realiza validação cruzada k-fold
            %
            % REQUISITOS: 3.4 (validação cruzada k-fold automatizada)
            
            obj.logger('info', '🔄 Realizando validação cruzada...');
            
            try
                % Combinar dados de treino e validação para cross-validation
                allImages = [obj.trainData.images; obj.valData.images];
                allMasks = [obj.trainData.masks; obj.valData.masks];
                
                % Executar validação cruzada
                cvResults = obj.crossValidator.performKFoldValidation(...
                    allImages, allMasks, obj.config, 'NumFolds', 5);
                
                obj.results.crossValidation = cvResults;
                
                obj.logger('success', 'Validação cruzada concluída');
                
            catch ME
                obj.logger('warning', sprintf('Erro na validação cruzada: %s', ME.message));
                obj.results.crossValidation = struct('error', ME.message);
            end
        end
        
        function generateReports(obj)
            % Gera relatórios automáticos com interpretação usando ReportGenerator
            %
            % REQUISITOS: 1.4, 1.5 (relatórios automáticos com interpretação)
            
            obj.logger('info', '📄 Gerando relatórios automáticos...');
            
            try
                % Inicializar ReportGenerator
                reportGenerator = ReportGenerator('OutputDir', fullfile('output', 'reports'), ...
                    'ReportFormat', 'text', 'IncludeVisualizations', true, ...
                    'IncludeRecommendations', true);
                
                % Preparar dados completos para o relatório
                reportData = obj.prepareCompleteResults();
                
                % Gerar relatório completo com interpretação automática
                reportPath = reportGenerator.generateComparisonReport(reportData, ...
                    'Title', 'Comparação Automática U-Net vs Attention U-Net', ...
                    'IncludeRawData', false);
                
                if ~isempty(reportPath)
                    obj.logger('success', sprintf('Relatório automático gerado: %s', reportPath));
                    
                    % Armazenar caminho do relatório nos resultados
                    obj.results.reportPath = reportPath;
                else
                    obj.logger('warning', 'Falha na geração do relatório automático');
                end
                
                % Gerar interpretação adicional se necessário
                interpretation = reportGenerator.generateAutomaticInterpretation(reportData);
                if ~isempty(interpretation) && ~isfield(interpretation, 'error')
                    obj.results.automaticInterpretation = interpretation;
                    obj.logger('success', 'Interpretação automática gerada');
                    
                    % Mostrar resumo executivo no console
                    if isfield(interpretation, 'executiveSummary')
                        obj.logger('info', '=== RESUMO EXECUTIVO ===');
                        fprintf('%s\n', interpretation.executiveSummary);
                    end
                end
                
            catch ME
                obj.logger('error', sprintf('Erro na geração de relatórios: %s', ME.message));
                
                % Fallback para método simples
                obj.logger('info', 'Tentando geração de relatório simplificado...');
                obj.generateSimpleTextReport();
            end
        end
        
        function generateTextReport(obj, reportDir)
            % Gera relatório de texto detalhado
            
            reportFile = fullfile(reportDir, sprintf('comparison_report_%s.txt', datestr(now, 'yyyy-mm-dd_HH-MM-SS')));
            
            try
                fid = fopen(reportFile, 'w');
                if fid == -1
                    error('Não foi possível criar arquivo de relatório');
                end
                
                % Cabeçalho
                fprintf(fid, '=== RELATÓRIO DE COMPARAÇÃO U-NET vs ATTENTION U-NET ===\n');
                fprintf(fid, 'Data: %s\n', datestr(now));
                fprintf(fid, 'Configuração: %s\n\n', obj.config.name);
                
                % Resultados dos modelos
                fprintf(fid, '--- RESULTADOS DOS MODELOS ---\n');
                fprintf(fid, 'U-Net:\n');
                fprintf(fid, '  IoU: %.4f ± %.4f\n', obj.unetMetrics.iou.mean, obj.unetMetrics.iou.std);
                fprintf(fid, '  Dice: %.4f ± %.4f\n', obj.unetMetrics.dice.mean, obj.unetMetrics.dice.std);
                fprintf(fid, '  Accuracy: %.4f ± %.4f\n', obj.unetMetrics.accuracy.mean, obj.unetMetrics.accuracy.std);
                
                fprintf(fid, '\nAttention U-Net:\n');
                fprintf(fid, '  IoU: %.4f ± %.4f\n', obj.attentionMetrics.iou.mean, obj.attentionMetrics.iou.std);
                fprintf(fid, '  Dice: %.4f ± %.4f\n', obj.attentionMetrics.dice.mean, obj.attentionMetrics.dice.std);
                fprintf(fid, '  Accuracy: %.4f ± %.4f\n', obj.attentionMetrics.accuracy.mean, obj.attentionMetrics.accuracy.std);
                
                % Análise estatística
                if isfield(obj.results, 'statistical')
                    fprintf(fid, '\n--- ANÁLISE ESTATÍSTICA ---\n');
                    fprintf(fid, 'IoU: %s\n', obj.results.statistical.iou.interpretation);
                    fprintf(fid, 'Dice: %s\n', obj.results.statistical.dice.interpretation);
                    fprintf(fid, 'Accuracy: %s\n', obj.results.statistical.accuracy.interpretation);
                end
                
                % Conclusão
                if isfield(obj.results, 'comparison')
                    fprintf(fid, '\n--- CONCLUSÃO ---\n');
                    fprintf(fid, 'Modelo vencedor: %s\n', obj.results.comparison.winner);
                    fprintf(fid, 'Resumo: %s\n', obj.results.comparison.summary);
                    
                    if isfield(obj.results.comparison, 'recommendations')
                        fprintf(fid, '\nRecomendações:\n');
                        for i = 1:length(obj.results.comparison.recommendations)
                            fprintf(fid, '- %s\n', obj.results.comparison.recommendations{i});
                        end
                    end
                end
                
                fclose(fid);
                obj.logger('success', sprintf('Relatório salvo: %s', reportFile));
                
            catch ME
                if fid ~= -1
                    fclose(fid);
                end
                obj.logger('error', sprintf('Erro ao gerar relatório: %s', ME.message));
            end
        end
        
        function generateVisualizations(obj, reportDir)
            % Gera visualizações dos resultados
            
            try
                % Gráfico de comparação de métricas
                figure('Visible', 'off');
                
                metrics = {'IoU', 'Dice', 'Accuracy'};
                unetValues = [obj.unetMetrics.iou.mean, obj.unetMetrics.dice.mean, obj.unetMetrics.accuracy.mean];
                attentionValues = [obj.attentionMetrics.iou.mean, obj.attentionMetrics.dice.mean, obj.attentionMetrics.accuracy.mean];
                
                x = 1:length(metrics);
                width = 0.35;
                
                bar(x - width/2, unetValues, width, 'DisplayName', 'U-Net');
                hold on;
                bar(x + width/2, attentionValues, width, 'DisplayName', 'Attention U-Net');
                
                xlabel('Métricas');
                ylabel('Valor');
                title('Comparação de Performance: U-Net vs Attention U-Net');
                set(gca, 'XTickLabel', metrics);
                legend('Location', 'best');
                grid on;
                
                % Salvar gráfico
                saveas(gcf, fullfile(reportDir, 'metrics_comparison.png'));
                close(gcf);
                
                obj.logger('success', 'Visualizações geradas');
                
            catch ME
                obj.logger('warning', sprintf('Erro ao gerar visualizações: %s', ME.message));
            end
        end
        
        function ds = createDatastore(obj, data, isTraining)
            % Cria datastore para treinamento ou avaliação
            
            % Criar cell arrays com caminhos
            imagePaths = data.images;
            maskPaths = data.masks;
            
            % Criar image datastore
            imds = imageDatastore(imagePaths);
            
            % Criar pixel label datastore
            classNames = ["background", "foreground"];
            labelIDs = [0, 1];
            pxds = pixelLabelDatastore(maskPaths, classNames, labelIDs);
            
            % Combinar datastores
            ds = combine(imds, pxds);
            
            % Aplicar transformações se necessário
            if isTraining
                ds = transform(ds, @(data) obj.dataPreprocessor.preprocess(data, ...
                    'IsTraining', true, 'UseAugmentation', true));
            else
                ds = transform(ds, @(data) obj.dataPreprocessor.preprocess(data, ...
                    'IsTraining', false, 'UseAugmentation', false));
            end
        end
        
        function winner = determineOverallWinner(obj)
            % Determina o vencedor geral baseado em todas as métricas
            
            winner = struct();
            
            % Contar vitórias por métrica
            unetWins = 0;
            attentionWins = 0;
            ties = 0;
            
            metrics = {'iou', 'dice', 'accuracy'};
            
            for i = 1:length(metrics)
                metric = metrics{i};
                if isfield(obj.results.statistical, metric) && obj.results.statistical.(metric).significant
                    if obj.results.statistical.(metric).meanDifference > 0
                        unetWins = unetWins + 1;
                    else
                        attentionWins = attentionWins + 1;
                    end
                else
                    ties = ties + 1;
                end
            end
            
            % Determinar vencedor
            if unetWins > attentionWins
                winner.winner = 'U-Net';
                winner.confidence = 'alta';
            elseif attentionWins > unetWins
                winner.winner = 'Attention U-Net';
                winner.confidence = 'alta';
            else
                % Usar performance média como desempate
                unetMean = mean([obj.unetMetrics.iou.mean, obj.unetMetrics.dice.mean, obj.unetMetrics.accuracy.mean]);
                attentionMean = mean([obj.attentionMetrics.iou.mean, obj.attentionMetrics.dice.mean, obj.attentionMetrics.accuracy.mean]);
                
                if unetMean > attentionMean
                    winner.winner = 'U-Net';
                    winner.confidence = 'baixa';
                else
                    winner.winner = 'Attention U-Net';
                    winner.confidence = 'baixa';
                end
            end
            
            % Gerar resumo
            winner.summary = sprintf('%s venceu com %d vitórias de %d métricas (confiança: %s)', ...
                winner.winner, max(unetWins, attentionWins), length(metrics), winner.confidence);
            
            % Gerar recomendações
            winner.recommendations = obj.generateRecommendations(winner);
        end
        
        function recommendations = generateRecommendations(obj, winner)
            % Gera recomendações baseadas nos resultados
            
            recommendations = {};
            
            % Recomendação baseada no vencedor
            if strcmp(winner.winner, 'U-Net')
                recommendations{end+1} = 'U-Net clássica mostrou melhor performance para este dataset';
                recommendations{end+1} = 'Considere usar U-Net para aplicações que requerem simplicidade e eficiência';
            else
                recommendations{end+1} = 'Attention U-Net mostrou melhor performance, justificando a complexidade adicional';
                recommendations{end+1} = 'Recomendado para aplicações que requerem alta precisão de segmentação';
            end
            
            % Recomendações baseadas na confiança
            if strcmp(winner.confidence, 'baixa')
                recommendations{end+1} = 'Diferenças pequenas entre modelos - considere validação cruzada adicional';
                recommendations{end+1} = 'Teste com datasets maiores para resultados mais conclusivos';
            end
            
            % Recomendações técnicas
            if obj.enableQuickTest
                recommendations{end+1} = 'Resultados baseados em teste rápido - execute comparação completa para validação';
            end
        end
        
        function results = prepareBasicResults(obj)
            % Prepara estrutura básica de resultados
            
            results = struct();
            results.timestamp = datestr(now);
            results.mode = 'basic';
            results.config = obj.config;
            
            if ~isempty(obj.unetModel)
                results.models.unet.trained = true;
                results.models.unet.model = obj.unetModel;
            end
            
            if ~isempty(obj.attentionUnetModel)
                results.models.attentionUnet.trained = true;
                results.models.attentionUnet.model = obj.attentionUnetModel;
            end
        end
        
        function results = prepareCompleteResults(obj)
            % Prepara estrutura completa de resultados
            
            results = obj.results;
            results.timestamp = datestr(now);
            results.mode = 'complete';
            results.config = obj.config;
            results.executionTime = toc(obj.startTime);
            
            % Adicionar modelos
            results.models.unet.model = obj.unetModel;
            results.models.unet.metrics = obj.unetMetrics;
            
            results.models.attentionUnet.model = obj.attentionUnetModel;
            results.models.attentionUnet.metrics = obj.attentionMetrics;
            
            % Adicionar dados de execução
            results.execution = obj.getExecutionStatus();
        end
        
        function loadExistingModels(obj)
            % Carrega modelos já treinados
            
            obj.logger('info', '📁 Carregando modelos existentes...');
            
            try
                % Procurar modelos na pasta de output
                modelDir = fullfile('output', 'models');
                
                if exist(modelDir, 'dir')
                    % Procurar U-Net
                    unetFiles = dir(fullfile(modelDir, 'unet*.mat'));
                    if ~isempty(unetFiles)
                        [~, idx] = max([unetFiles.datenum]); % Pegar o mais recente
                        unetPath = fullfile(modelDir, unetFiles(idx).name);
                        obj.unetModel = obj.modelTrainer.loadModel(unetPath);
                        obj.logger('success', sprintf('U-Net carregada: %s', unetFiles(idx).name));
                    end
                    
                    % Procurar Attention U-Net
                    attentionFiles = dir(fullfile(modelDir, 'attention*.mat'));
                    if ~isempty(attentionFiles)
                        [~, idx] = max([attentionFiles.datenum]); % Pegar o mais recente
                        attentionPath = fullfile(modelDir, attentionFiles(idx).name);
                        obj.attentionUnetModel = obj.modelTrainer.loadModel(attentionPath);
                        obj.logger('success', sprintf('Attention U-Net carregada: %s', attentionFiles(idx).name));
                    end
                end
                
                if isempty(obj.unetModel) || isempty(obj.attentionUnetModel)
                    error('Modelos não encontrados. Execute treinamento primeiro.');
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao carregar modelos: %s', ME.message));
                rethrow(ME);
            end
        end
        
        function canRun = canRunParallel(obj)
            % Verifica se pode executar treinamento paralelo
            
            canRun = false;
            
            try
                % Verificar se Parallel Computing Toolbox está disponível
                if license('test', 'Distrib_Computing_Toolbox') || license('test', 'Parallel_Computing_Toolbox')
                    % Verificar se há pool paralelo
                    pool = gcp('nocreate');
                    if ~isempty(pool)
                        canRun = true;
                    end
                end
            catch
                % Ignorar erros
            end
        end
        
        function updateStep(obj, step)
            % Atualiza etapa atual da execução
            obj.currentStep = step;
            obj.logger('debug', sprintf('Etapa atual: %s', step));
        end
        
        function completed = getCompletedSteps(obj)
            % Retorna número de etapas completadas
            currentIdx = find(strcmp(obj.PIPELINE_STEPS, obj.currentStep));
            if isempty(currentIdx)
                completed = 0;
            else
                completed = currentIdx - 1;
            end
        end
        
        function timeRemaining = estimateRemainingTime(obj, progressPercent)
            % Estima tempo restante baseado no progresso
            if progressPercent > 0 && ~isempty(obj.startTime)
                elapsedTime = toc(obj.startTime);
                totalEstimated = elapsedTime / (progressPercent / 100);
                timeRemaining = totalEstimated - elapsedTime;
            else
                timeRemaining = 0;
            end
        end
        
        function hasErr = hasErrors(obj)
            % Verifica se houve erros durante a execução
            hasErr = isfield(obj.results, 'errors') && ~isempty(obj.results.errors);
        end
        
        function lastError = getLastError(obj)
            % Retorna último erro registrado
            if obj.hasErrors()
                errors = obj.results.errors;
                lastError = errors{end};
            else
                lastError = '';
            end
        end
        
        function finalizeExecution(obj, results)
            % Finaliza execução e salva resultados
            
            totalTime = toc(obj.startTime);
            
            obj.logger('success', '🎉 COMPARAÇÃO CONCLUÍDA COM SUCESSO!');
            obj.logger('info', sprintf('Tempo total de execução: %.2f segundos', totalTime));
            
            % Salvar resultados
            try
                resultsDir = fullfile('output', 'results');
                if ~exist(resultsDir, 'dir')
                    mkdir(resultsDir);
                end
                
                resultsFile = fullfile(resultsDir, sprintf('comparison_results_%s.mat', ...
                    datestr(now, 'yyyy-mm-dd_HH-MM-SS')));
                save(resultsFile, 'results');
                
                obj.logger('success', sprintf('Resultados salvos: %s', resultsFile));
                
            catch ME
                obj.logger('warning', sprintf('Erro ao salvar resultados: %s', ME.message));
            end
            
            % Mostrar resumo final
            summary = obj.generateExecutionSummary();
            fprintf('\n%s\n', summary);
        end
        
        function handleExecutionError(obj, ME)
            % Trata erros durante a execução
            
            obj.logger('error', '💥 ERRO DURANTE A EXECUÇÃO');
            obj.logger('error', sprintf('Mensagem: %s', ME.message));
            
            if ~isempty(ME.stack)
                obj.logger('error', 'Stack trace:');
                for i = 1:min(3, length(ME.stack))
                    obj.logger('error', sprintf('  %s (linha %d)', ME.stack(i).name, ME.stack(i).line));
                end
            end
            
            % Salvar erro nos resultados
            if ~isfield(obj.results, 'errors')
                obj.results.errors = {};
            end
            obj.results.errors{end+1} = struct('message', ME.message, 'timestamp', datestr(now));
            
            % Sugestões de solução
            obj.suggestSolutions(ME);
        end
        
        function suggestSolutions(obj, ME)
            % Sugere soluções baseadas no tipo de erro
            
            message = ME.message;
            
            if contains(message, 'memory') || contains(message, 'Memory')
                obj.logger('info', '💡 Sugestão: Reduza o batch size ou use modo de teste rápido');
            elseif contains(message, 'GPU')
                obj.logger('info', '💡 Sugestão: Verifique drivers da GPU ou use CPU');
            elseif contains(message, 'file') || contains(message, 'File')
                obj.logger('info', '💡 Sugestão: Verifique se os caminhos de dados estão corretos');
            elseif contains(message, 'network') || contains(message, 'layer')
                obj.logger('info', '💡 Sugestão: Verifique a configuração da rede neural');
            else
                obj.logger('info', '💡 Sugestão: Verifique a configuração e tente novamente');
            end
        end
        
        function str = boolToString(obj, value)
            % Converte booleano para string
            if value
                str = 'Habilitado';
            else
                str = 'Desabilitado';
            end
        end
        
        function generateSimpleTextReport(obj)
            % Gera relatório de texto simples como fallback
            
            try
                reportDir = fullfile('output', 'reports');
                if ~exist(reportDir, 'dir')
                    mkdir(reportDir);
                end
                
                reportFile = fullfile(reportDir, sprintf('simple_report_%s.txt', datestr(now, 'yyyy-mm-dd_HH-MM-SS')));
                
                fid = fopen(reportFile, 'w');
                if fid == -1
                    error('Não foi possível criar arquivo de relatório simples');
                end
                
                % Cabeçalho
                fprintf(fid, '=== RELATÓRIO SIMPLES DE COMPARAÇÃO ===\n');
                fprintf(fid, 'Data: %s\n\n', datestr(now));
                
                % Resultados básicos
                if ~isempty(obj.unetMetrics) && ~isempty(obj.attentionMetrics)
                    fprintf(fid, '--- RESULTADOS ---\n');
                    fprintf(fid, 'U-Net:\n');
                    fprintf(fid, '  IoU: %.4f ± %.4f\n', obj.unetMetrics.iou.mean, obj.unetMetrics.iou.std);
                    fprintf(fid, '  Dice: %.4f ± %.4f\n', obj.unetMetrics.dice.mean, obj.unetMetrics.dice.std);
                    fprintf(fid, '  Accuracy: %.4f ± %.4f\n', obj.unetMetrics.accuracy.mean, obj.unetMetrics.accuracy.std);
                    
                    fprintf(fid, '\nAttention U-Net:\n');
                    fprintf(fid, '  IoU: %.4f ± %.4f\n', obj.attentionMetrics.iou.mean, obj.attentionMetrics.iou.std);
                    fprintf(fid, '  Dice: %.4f ± %.4f\n', obj.attentionMetrics.dice.mean, obj.attentionMetrics.dice.std);
                    fprintf(fid, '  Accuracy: %.4f ± %.4f\n', obj.attentionMetrics.accuracy.mean, obj.attentionMetrics.accuracy.std);
                end
                
                % Conclusão simples
                if isfield(obj.results, 'comparison') && isfield(obj.results.comparison, 'winner')
                    fprintf(fid, '\n--- CONCLUSÃO ---\n');
                    fprintf(fid, 'Modelo vencedor: %s\n', obj.results.comparison.winner);
                    fprintf(fid, 'Resumo: %s\n', obj.results.comparison.summary);
                end
                
                fclose(fid);
                
                obj.logger('success', sprintf('Relatório simples gerado: %s', reportFile));
                obj.results.simpleReportPath = reportFile;
                
            catch ME
                if exist('fid', 'var') && fid ~= -1
                    fclose(fid);
                end
                obj.logger('error', sprintf('Erro ao gerar relatório simples: %s', ME.message));
            end
        end
        
        function cleanup(obj)
            % Limpa recursos e finaliza execução
            
            obj.logger('info', 'Limpando recursos do ComparisonController...');
            
            try
                % Limpar ExecutionManager se existir
                if ~isempty(obj.executionManager)
                    obj.executionManager.cleanup();
                end
                
                % Limpar cache do preprocessador se existir
                if ~isempty(obj.dataPreprocessor)
                    obj.dataPreprocessor.clearCache();
                end
                
                % Limpar dados temporários
                obj.trainData = [];
                obj.valData = [];
                obj.testData = [];
                
                obj.logger('success', 'Recursos do ComparisonController limpos');
                
            catch ME
                obj.logger('warning', sprintf('Erro na limpeza: %s', ME.message));
            end
        end
    end
end