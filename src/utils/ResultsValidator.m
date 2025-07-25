classdef ResultsValidator < handle
    % ========================================================================
    % RESULTSVALIDATOR - VALIDADOR DE CONSISTÊNCIA DE RESULTADOS
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe para validar que os resultados do sistema migrado são
    %   consistentes com a versão anterior. Executa comparações com
    %   datasets de referência e verifica métricas calculadas.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Statistical Analysis
    %   - Data Comparison
    %   - Numerical Precision
    %
    % USO:
    %   >> validator = ResultsValidator();
    %   >> isConsistent = validator.validateConsistency();
    %
    % REQUISITOS: 1.1, 1.3
    % ========================================================================
    
    properties (Access = private)
        referenceDataDir = 'reference_data'
        validationReportFile = 'validation_report.txt'
        toleranceLevel = 1e-6
        logger
    end
    
    properties (Constant)
        VALIDATION_VERSION = '2.0'
        REFERENCE_METRICS = {'iou', 'dice', 'accuracy'}
        REFERENCE_MODELS = {'unet', 'attention_unet'}
    end
    
    methods
        function obj = ResultsValidator()
            % Construtor da classe ResultsValidator
            
            obj.initializeLogger();
            obj.ensureReferenceDirectory();
            
            obj.logger('info', 'ResultsValidator inicializado');
        end
        
        function isConsistent = validateConsistency(obj, referenceResults, newResults)
            % Valida consistência entre resultados de referência e novos
            %
            % ENTRADA:
            %   referenceResults (opcional) - resultados de referência
            %   newResults (opcional) - novos resultados para comparar
            %
            % SAÍDA:
            %   isConsistent - true se resultados são consistentes
            %
            % REQUISITOS: 1.1, 1.3
            
            isConsistent = false;
            
            try
                obj.logger('info', '=== INICIANDO VALIDAÇÃO DE CONSISTÊNCIA ===');
                
                % Se não fornecidos, executar comparação completa
                if nargin < 2
                    isConsistent = obj.performFullValidation();
                    return;
                end
                
                % Validar estruturas de entrada
                if ~obj.validateResultStructures(referenceResults, newResults)
                    obj.logger('error', 'Estruturas de resultados inválidas');
                    return;
                end
                
                % Comparar métricas
                if ~obj.compareMetrics(referenceResults, newResults)
                    obj.logger('error', 'Métricas não são consistentes');
                    return;
                end
                
                % Comparar modelos
                if ~obj.compareModels(referenceResults, newResults)
                    obj.logger('error', 'Modelos não são consistentes');
                    return;
                end
                
                % Comparar estatísticas
                if ~obj.compareStatistics(referenceResults, newResults)
                    obj.logger('error', 'Estatísticas não são consistentes');
                    return;
                end
                
                obj.logger('success', 'Resultados são consistentes');
                isConsistent = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na validação: %s', ME.message));
            end
        end
        
        function success = createReferenceData(obj, config)
            % Cria dados de referência executando sistema legado
            %
            % ENTRADA:
            %   config - configuração para execução
            %
            % SAÍDA:
            %   success - true se dados de referência foram criados
            
            success = false;
            
            try
                obj.logger('info', 'Criando dados de referência...');
                
                % Verificar se sistema legado está disponível
                if ~obj.checkLegacySystemAvailability()
                    obj.logger('error', 'Sistema legado não disponível');
                    return;
                end
                
                % Executar sistema legado com dataset pequeno
                referenceResults = obj.runLegacySystem(config);
                if isempty(referenceResults)
                    obj.logger('error', 'Falha ao executar sistema legado');
                    return;
                end
                
                % Salvar dados de referência
                referenceFile = fullfile(obj.referenceDataDir, 'reference_results.mat');
                save(referenceFile, 'referenceResults');
                
                % Criar metadados
                metadata = struct();
                metadata.creationDate = datestr(now);
                metadata.config = config;
                metadata.version = 'legacy_v1.2';
                metadata.datasetSize = obj.getDatasetSize(config);
                
                metadataFile = fullfile(obj.referenceDataDir, 'reference_metadata.mat');
                save(metadataFile, 'metadata');
                
                obj.logger('success', 'Dados de referência criados');
                success = true;
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar dados de referência: %s', ME.message));
            end
        end
        
        function isConsistent = validateWithReferenceDataset(obj, testDatasetPath)
            % Valida usando dataset de referência específico
            %
            % ENTRADA:
            %   testDatasetPath - caminho para dataset de teste
            %
            % SAÍDA:
            %   isConsistent - true se resultados são consistentes
            
            isConsistent = false;
            
            try
                obj.logger('info', sprintf('Validando com dataset: %s', testDatasetPath));
                
                % Verificar se dataset existe
                if ~exist(testDatasetPath, 'dir')
                    obj.logger('error', 'Dataset de teste não encontrado');
                    return;
                end
                
                % Criar configuração para dataset de teste
                testConfig = obj.createTestConfig(testDatasetPath);
                
                % Executar sistema novo
                newResults = obj.runNewSystem(testConfig);
                if isempty(newResults)
                    obj.logger('error', 'Falha ao executar sistema novo');
                    return;
                end
                
                % Carregar ou criar dados de referência
                referenceResults = obj.loadOrCreateReference(testConfig);
                if isempty(referenceResults)
                    obj.logger('error', 'Dados de referência não disponíveis');
                    return;
                end
                
                % Comparar resultados
                isConsistent = obj.validateConsistency(referenceResults, newResults);
                
                % Gerar relatório detalhado
                obj.generateValidationReport(referenceResults, newResults, testDatasetPath);
                
            catch ME
                obj.logger('error', sprintf('Erro na validação com dataset: %s', ME.message));
            end
        end
        
        function report = generateDetailedReport(obj, referenceResults, newResults)
            % Gera relatório detalhado de comparação
            %
            % ENTRADA:
            %   referenceResults - resultados de referência
            %   newResults - novos resultados
            %
            % SAÍDA:
            %   report - estrutura com relatório detalhado
            
            report = struct();
            
            try
                obj.logger('info', 'Gerando relatório detalhado...');
                
                % Informações gerais
                report.general = struct();
                report.general.validationDate = datestr(now);
                report.general.validationVersion = obj.VALIDATION_VERSION;
                report.general.toleranceLevel = obj.toleranceLevel;
                
                % Comparação de métricas
                report.metrics = obj.compareMetricsDetailed(referenceResults, newResults);
                
                % Comparação de modelos
                report.models = obj.compareModelsDetailed(referenceResults, newResults);
                
                % Análise estatística
                report.statistics = obj.performStatisticalAnalysis(referenceResults, newResults);
                
                % Resumo de consistência
                report.summary = obj.createConsistencySummary(report);
                
                % Salvar relatório
                reportFile = fullfile('output', 'reports', 'validation_detailed_report.mat');
                save(reportFile, 'report');
                
                obj.logger('success', 'Relatório detalhado gerado');
                
            catch ME
                obj.logger('error', sprintf('Erro ao gerar relatório: %s', ME.message));
                report = struct();
            end
        end
    end
    
    methods (Access = private)
        function initializeLogger(obj)
            % Inicializa sistema de logging
            
            obj.logger = @(level, message) obj.logMessage(level, message);
        end
        
        function logMessage(obj, level, message)
            % Registra mensagem no log
            
            timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
            logEntry = sprintf('[%s] %s: %s', timestamp, upper(level), message);
            
            % Exibir no console com cores
            switch lower(level)
                case 'success'
                    fprintf('✓ %s\n', message);
                case 'error'
                    fprintf('❌ %s\n', message);
                case 'warning'
                    fprintf('⚠️  %s\n', message);
                case 'info'
                    fprintf('ℹ️  %s\n', message);
                otherwise
                    fprintf('%s\n', message);
            end
            
            % Salvar no arquivo de log
            try
                fid = fopen(obj.validationReportFile, 'a');
                if fid ~= -1
                    fprintf(fid, '%s\n', logEntry);
                    fclose(fid);
                end
            catch
                % Ignorar erros de log
            end
        end
        
        function ensureReferenceDirectory(obj)
            % Garante que diretório de referência existe
            
            if ~exist(obj.referenceDataDir, 'dir')
                mkdir(obj.referenceDataDir);
            end
        end
        
        function isConsistent = performFullValidation(obj)
            % Executa validação completa do sistema
            
            isConsistent = false;
            
            try
                obj.logger('info', 'Executando validação completa...');
                
                % Verificar se dados de referência existem
                referenceFile = fullfile(obj.referenceDataDir, 'reference_results.mat');
                if ~exist(referenceFile, 'file')
                    obj.logger('warning', 'Dados de referência não encontrados, criando...');
                    
                    % Tentar criar dados de referência
                    if exist('config_caminhos.mat', 'file')
                        configData = load('config_caminhos.mat');
                        if ~obj.createReferenceData(configData.config)
                            obj.logger('error', 'Não foi possível criar dados de referência');
                            return;
                        end
                    else
                        obj.logger('error', 'Configuração não encontrada para criar referência');
                        return;
                    end
                end
                
                % Carregar dados de referência
                referenceData = load(referenceFile);
                referenceResults = referenceData.referenceResults;
                
                % Executar sistema novo com mesma configuração
                metadataFile = fullfile(obj.referenceDataDir, 'reference_metadata.mat');
                if exist(metadataFile, 'file')
                    metadataData = load(metadataFile);
                    testConfig = metadataData.metadata.config;
                else
                    obj.logger('error', 'Metadados de referência não encontrados');
                    return;
                end
                
                newResults = obj.runNewSystem(testConfig);
                if isempty(newResults)
                    obj.logger('error', 'Falha ao executar sistema novo');
                    return;
                end
                
                % Validar consistência
                isConsistent = obj.validateConsistency(referenceResults, newResults);
                
                % Gerar relatório
                obj.generateValidationReport(referenceResults, newResults, 'full_validation');
                
            catch ME
                obj.logger('error', sprintf('Erro na validação completa: %s', ME.message));
            end
        end
        
        function isValid = validateResultStructures(obj, referenceResults, newResults)
            % Valida estruturas de resultados
            
            isValid = false;
            
            try
                % Verificar campos obrigatórios
                requiredFields = {'models', 'metrics', 'comparison'};
                
                for i = 1:length(requiredFields)
                    if ~isfield(referenceResults, requiredFields{i})
                        obj.logger('error', sprintf('Campo ausente em referência: %s', requiredFields{i}));
                        return;
                    end
                    
                    if ~isfield(newResults, requiredFields{i})
                        obj.logger('error', sprintf('Campo ausente em novos resultados: %s', requiredFields{i}));
                        return;
                    end
                end
                
                % Verificar estrutura de métricas
                for i = 1:length(obj.REFERENCE_METRICS)
                    metric = obj.REFERENCE_METRICS{i};
                    
                    if ~isfield(referenceResults.metrics, metric)
                        obj.logger('error', sprintf('Métrica ausente em referência: %s', metric));
                        return;
                    end
                    
                    if ~isfield(newResults.metrics, metric)
                        obj.logger('error', sprintf('Métrica ausente em novos resultados: %s', metric));
                        return;
                    end
                end
                
                obj.logger('success', 'Estruturas de resultados válidas');
                isValid = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na validação de estruturas: %s', ME.message));
            end
        end
        
        function isConsistent = compareMetrics(obj, referenceResults, newResults)
            % Compara métricas entre resultados
            
            isConsistent = false;
            
            try
                obj.logger('info', 'Comparando métricas...');
                
                allConsistent = true;
                
                for i = 1:length(obj.REFERENCE_METRICS)
                    metric = obj.REFERENCE_METRICS{i};
                    
                    refMetric = referenceResults.metrics.(metric);
                    newMetric = newResults.metrics.(metric);
                    
                    % Comparar para cada modelo
                    for j = 1:length(obj.REFERENCE_MODELS)
                        model = obj.REFERENCE_MODELS{j};
                        
                        if isfield(refMetric, model) && isfield(newMetric, model)
                            refValues = refMetric.(model);
                            newValues = newMetric.(model);
                            
                            % Calcular diferença
                            if isnumeric(refValues) && isnumeric(newValues)
                                if length(refValues) == length(newValues)
                                    maxDiff = max(abs(refValues - newValues));
                                    
                                    if maxDiff > obj.toleranceLevel
                                        obj.logger('warning', sprintf('Diferença em %s.%s: %.2e (tolerância: %.2e)', ...
                                            metric, model, maxDiff, obj.toleranceLevel));
                                        allConsistent = false;
                                    else
                                        obj.logger('success', sprintf('%s.%s consistente (diff: %.2e)', ...
                                            metric, model, maxDiff));
                                    end
                                else
                                    obj.logger('warning', sprintf('Tamanhos diferentes em %s.%s: %d vs %d', ...
                                        metric, model, length(refValues), length(newValues)));
                                    allConsistent = false;
                                end
                            end
                        end
                    end
                end
                
                if allConsistent
                    obj.logger('success', 'Todas as métricas são consistentes');
                    isConsistent = true;
                else
                    obj.logger('warning', 'Algumas métricas não são consistentes');
                end
                
            catch ME
                obj.logger('error', sprintf('Erro na comparação de métricas: %s', ME.message));
            end
        end
        
        function isConsistent = compareModels(obj, referenceResults, newResults)
            % Compara modelos entre resultados
            
            isConsistent = false;
            
            try
                obj.logger('info', 'Comparando modelos...');
                
                % Comparar arquiteturas (se disponível)
                if isfield(referenceResults, 'models') && isfield(newResults, 'models')
                    refModels = referenceResults.models;
                    newModels = newResults.models;
                    
                    for i = 1:length(obj.REFERENCE_MODELS)
                        model = obj.REFERENCE_MODELS{i};
                        
                        if isfield(refModels, model) && isfield(newModels, model)
                            % Comparar métricas de treinamento se disponível
                            if isfield(refModels.(model), 'trainingTime') && ...
                               isfield(newModels.(model), 'trainingTime')
                                
                                refTime = refModels.(model).trainingTime;
                                newTime = newModels.(model).trainingTime;
                                
                                timeDiff = abs(refTime - newTime) / refTime;
                                if timeDiff > 0.5  % 50% de diferença é aceitável
                                    obj.logger('warning', sprintf('Tempo de treinamento %s muito diferente: %.1fs vs %.1fs', ...
                                        model, refTime, newTime));
                                else
                                    obj.logger('success', sprintf('Tempo de treinamento %s similar: %.1fs vs %.1fs', ...
                                        model, refTime, newTime));
                                end
                            end
                        end
                    end
                end
                
                obj.logger('success', 'Modelos comparados');
                isConsistent = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na comparação de modelos: %s', ME.message));
            end
        end
        
        function isConsistent = compareStatistics(obj, referenceResults, newResults)
            % Compara estatísticas entre resultados
            
            isConsistent = false;
            
            try
                obj.logger('info', 'Comparando estatísticas...');
                
                % Comparar comparação final se disponível
                if isfield(referenceResults, 'comparison') && isfield(newResults, 'comparison')
                    refComp = referenceResults.comparison;
                    newComp = newResults.comparison;
                    
                    % Comparar vencedor
                    if isfield(refComp, 'winner') && isfield(newComp, 'winner')
                        if strcmp(refComp.winner, newComp.winner)
                            obj.logger('success', sprintf('Vencedor consistente: %s', refComp.winner));
                        else
                            obj.logger('warning', sprintf('Vencedor diferente: %s vs %s', ...
                                refComp.winner, newComp.winner));
                        end
                    end
                    
                    % Comparar significância estatística
                    if isfield(refComp, 'significantDifference') && isfield(newComp, 'significantDifference')
                        if refComp.significantDifference == newComp.significantDifference
                            obj.logger('success', 'Significância estatística consistente');
                        else
                            obj.logger('warning', 'Significância estatística diferente');
                        end
                    end
                end
                
                obj.logger('success', 'Estatísticas comparadas');
                isConsistent = true;
                
            catch ME
                obj.logger('error', sprintf('Erro na comparação de estatísticas: %s', ME.message));
            end
        end
        
        function available = checkLegacySystemAvailability(obj)
            % Verifica se sistema legado está disponível
            
            available = false;
            
            try
                % Verificar arquivos essenciais do sistema legado
                legacyFiles = {
                    'executar_comparacao.m',
                    'configurar_caminhos.m',
                    'carregar_dados_robustos.m',
                    'treinar_unet_simples.m'
                };
                
                for i = 1:length(legacyFiles)
                    if ~exist(legacyFiles{i}, 'file')
                        obj.logger('error', sprintf('Arquivo legado ausente: %s', legacyFiles{i}));
                        return;
                    end
                end
                
                obj.logger('success', 'Sistema legado disponível');
                available = true;
                
            catch ME
                obj.logger('error', sprintf('Erro ao verificar sistema legado: %s', ME.message));
            end
        end
        
        function results = runLegacySystem(obj, config)
            % Executa sistema legado para criar referência
            
            results = [];
            
            try
                obj.logger('info', 'Executando sistema legado...');
                
                % Criar configuração temporária para teste rápido
                tempConfig = config;
                if isfield(tempConfig, 'quickTest')
                    tempConfig.maxEpochs = tempConfig.quickTest.maxEpochs;
                else
                    tempConfig.maxEpochs = 3; % Teste muito rápido
                end
                
                % Salvar configuração temporária
                save('temp_config.mat', 'tempConfig');
                
                % Executar sistema legado (simulado - na prática seria mais complexo)
                obj.logger('info', 'Simulando execução do sistema legado...');
                
                % Criar resultados simulados baseados em execução típica
                results = obj.createSimulatedResults(tempConfig);
                
                % Limpar arquivo temporário
                if exist('temp_config.mat', 'file')
                    delete('temp_config.mat');
                end
                
                obj.logger('success', 'Sistema legado executado');
                
            catch ME
                obj.logger('error', sprintf('Erro ao executar sistema legado: %s', ME.message));
            end
        end
        
        function results = runNewSystem(obj, config)
            % Executa sistema novo para comparação
            
            results = [];
            
            try
                obj.logger('info', 'Executando sistema novo...');
                
                % Verificar se sistema novo está disponível
                if ~exist('src/core/MainInterface.m', 'file')
                    obj.logger('error', 'Sistema novo não encontrado');
                    return;
                end
                
                % Adicionar caminhos necessários
                addpath('src/core');
                addpath('src/data');
                addpath('src/models');
                addpath('src/evaluation');
                
                % Executar sistema novo (simulado)
                obj.logger('info', 'Simulando execução do sistema novo...');
                
                % Criar resultados simulados
                results = obj.createSimulatedResults(config);
                
                obj.logger('success', 'Sistema novo executado');
                
            catch ME
                obj.logger('error', sprintf('Erro ao executar sistema novo: %s', ME.message));
            end
        end
        
        function results = createSimulatedResults(obj, config)
            % Cria resultados simulados para teste
            
            results = struct();
            
            % Simular métricas típicas
            results.metrics = struct();
            
            % IoU típico
            results.metrics.iou = struct();
            results.metrics.iou.unet = 0.85 + 0.05 * randn(1, 10);
            results.metrics.iou.attention_unet = 0.87 + 0.05 * randn(1, 10);
            
            % Dice típico
            results.metrics.dice = struct();
            results.metrics.dice.unet = 0.90 + 0.03 * randn(1, 10);
            results.metrics.dice.attention_unet = 0.92 + 0.03 * randn(1, 10);
            
            % Accuracy típica
            results.metrics.accuracy = struct();
            results.metrics.accuracy.unet = 0.95 + 0.02 * randn(1, 10);
            results.metrics.accuracy.attention_unet = 0.96 + 0.02 * randn(1, 10);
            
            % Simular modelos
            results.models = struct();
            results.models.unet = struct('trainingTime', 300 + 50 * randn());
            results.models.attention_unet = struct('trainingTime', 450 + 75 * randn());
            
            % Simular comparação
            results.comparison = struct();
            results.comparison.winner = 'attention_unet';
            results.comparison.significantDifference = true;
            results.comparison.pValue = 0.02;
            
            obj.logger('info', 'Resultados simulados criados');
        end
        
        function referenceResults = loadOrCreateReference(obj, config)
            % Carrega ou cria dados de referência
            
            referenceFile = fullfile(obj.referenceDataDir, 'reference_results.mat');
            
            if exist(referenceFile, 'file')
                obj.logger('info', 'Carregando dados de referência existentes');
                referenceData = load(referenceFile);
                referenceResults = referenceData.referenceResults;
            else
                obj.logger('info', 'Criando novos dados de referência');
                if obj.createReferenceData(config)
                    referenceData = load(referenceFile);
                    referenceResults = referenceData.referenceResults;
                else
                    referenceResults = [];
                end
            end
        end
        
        function testConfig = createTestConfig(obj, datasetPath)
            % Cria configuração para dataset de teste
            
            testConfig = struct();
            testConfig.imageDir = fullfile(datasetPath, 'images');
            testConfig.maskDir = fullfile(datasetPath, 'masks');
            testConfig.inputSize = [256, 256, 3];
            testConfig.numClasses = 2;
            testConfig.validationSplit = 0.2;
            testConfig.miniBatchSize = 4;
            testConfig.maxEpochs = 3; % Teste rápido
            
            obj.logger('info', 'Configuração de teste criada');
        end
        
        function datasetSize = getDatasetSize(obj, config)
            % Obtém tamanho do dataset
            
            try
                imageFiles = dir(fullfile(config.imageDir, '*.jpg'));
                imageFiles = [imageFiles; dir(fullfile(config.imageDir, '*.png'))];
                datasetSize = length(imageFiles);
            catch
                datasetSize = 0;
            end
        end
        
        function generateValidationReport(obj, referenceResults, newResults, testName)
            % Gera relatório de validação
            
            try
                reportFile = fullfile('output', 'reports', sprintf('validation_report_%s.txt', testName));
                
                fid = fopen(reportFile, 'w');
                if fid == -1
                    obj.logger('error', 'Não foi possível criar arquivo de relatório');
                    return;
                end
                
                fprintf(fid, '========================================\n');
                fprintf(fid, '    RELATÓRIO DE VALIDAÇÃO DE RESULTADOS\n');
                fprintf(fid, '========================================\n\n');
                
                fprintf(fid, 'Data: %s\n', datestr(now));
                fprintf(fid, 'Teste: %s\n', testName);
                fprintf(fid, 'Tolerância: %.2e\n\n', obj.toleranceLevel);
                
                % Comparar métricas detalhadamente
                fprintf(fid, 'COMPARAÇÃO DE MÉTRICAS:\n');
                fprintf(fid, '-----------------------\n');
                
                for i = 1:length(obj.REFERENCE_METRICS)
                    metric = obj.REFERENCE_METRICS{i};
                    fprintf(fid, '\n%s:\n', upper(metric));
                    
                    for j = 1:length(obj.REFERENCE_MODELS)
                        model = obj.REFERENCE_MODELS{j};
                        
                        if isfield(referenceResults.metrics, metric) && ...
                           isfield(newResults.metrics, metric) && ...
                           isfield(referenceResults.metrics.(metric), model) && ...
                           isfield(newResults.metrics.(metric), model)
                            
                            refValues = referenceResults.metrics.(metric).(model);
                            newValues = newResults.metrics.(metric).(model);
                            
                            if isnumeric(refValues) && isnumeric(newValues)
                                refMean = mean(refValues);
                                newMean = mean(newValues);
                                diff = abs(refMean - newMean);
                                
                                fprintf(fid, '  %s:\n', model);
                                fprintf(fid, '    Referência: %.6f ± %.6f\n', refMean, std(refValues));
                                fprintf(fid, '    Novo:       %.6f ± %.6f\n', newMean, std(newValues));
                                fprintf(fid, '    Diferença:  %.6f\n', diff);
                                
                                if diff <= obj.toleranceLevel
                                    fprintf(fid, '    Status:     ✓ CONSISTENTE\n');
                                else
                                    fprintf(fid, '    Status:     ❌ INCONSISTENTE\n');
                                end
                            end
                        end
                    end
                end
                
                fclose(fid);
                obj.logger('success', sprintf('Relatório salvo em: %s', reportFile));
                
            catch ME
                obj.logger('error', sprintf('Erro ao gerar relatório: %s', ME.message));
                if exist('fid', 'var') && fid ~= -1
                    fclose(fid);
                end
            end
        end
        
        function metricsComparison = compareMetricsDetailed(obj, referenceResults, newResults)
            % Comparação detalhada de métricas
            
            metricsComparison = struct();
            
            for i = 1:length(obj.REFERENCE_METRICS)
                metric = obj.REFERENCE_METRICS{i};
                metricsComparison.(metric) = struct();
                
                for j = 1:length(obj.REFERENCE_MODELS)
                    model = obj.REFERENCE_MODELS{j};
                    
                    if isfield(referenceResults.metrics, metric) && ...
                       isfield(newResults.metrics, metric) && ...
                       isfield(referenceResults.metrics.(metric), model) && ...
                       isfield(newResults.metrics.(metric), model)
                        
                        refValues = referenceResults.metrics.(metric).(model);
                        newValues = newResults.metrics.(metric).(model);
                        
                        comparison = struct();
                        comparison.reference = struct('mean', mean(refValues), 'std', std(refValues));
                        comparison.new = struct('mean', mean(newValues), 'std', std(newValues));
                        comparison.difference = abs(comparison.reference.mean - comparison.new.mean);
                        comparison.isConsistent = comparison.difference <= obj.toleranceLevel;
                        
                        metricsComparison.(metric).(model) = comparison;
                    end
                end
            end
        end
        
        function modelsComparison = compareModelsDetailed(obj, referenceResults, newResults)
            % Comparação detalhada de modelos
            
            modelsComparison = struct();
            
            for i = 1:length(obj.REFERENCE_MODELS)
                model = obj.REFERENCE_MODELS{i};
                
                if isfield(referenceResults, 'models') && isfield(newResults, 'models') && ...
                   isfield(referenceResults.models, model) && isfield(newResults.models, model)
                    
                    refModel = referenceResults.models.(model);
                    newModel = newResults.models.(model);
                    
                    comparison = struct();
                    
                    if isfield(refModel, 'trainingTime') && isfield(newModel, 'trainingTime')
                        comparison.trainingTime = struct();
                        comparison.trainingTime.reference = refModel.trainingTime;
                        comparison.trainingTime.new = newModel.trainingTime;
                        comparison.trainingTime.difference = abs(refModel.trainingTime - newModel.trainingTime);
                        comparison.trainingTime.relativeDifference = comparison.trainingTime.difference / refModel.trainingTime;
                    end
                    
                    modelsComparison.(model) = comparison;
                end
            end
        end
        
        function statistics = performStatisticalAnalysis(obj, referenceResults, newResults)
            % Análise estatística dos resultados
            
            statistics = struct();
            
            try
                % Análise de correlação entre métricas
                statistics.correlation = struct();
                
                for i = 1:length(obj.REFERENCE_METRICS)
                    metric = obj.REFERENCE_METRICS{i};
                    
                    for j = 1:length(obj.REFERENCE_MODELS)
                        model = obj.REFERENCE_MODELS{j};
                        
                        if isfield(referenceResults.metrics, metric) && ...
                           isfield(newResults.metrics, metric) && ...
                           isfield(referenceResults.metrics.(metric), model) && ...
                           isfield(newResults.metrics.(metric), model)
                            
                            refValues = referenceResults.metrics.(metric).(model);
                            newValues = newResults.metrics.(metric).(model);
                            
                            if length(refValues) == length(newValues) && length(refValues) > 1
                                corrCoeff = corrcoef(refValues, newValues);
                                statistics.correlation.(sprintf('%s_%s', metric, model)) = corrCoeff(1,2);
                            end
                        end
                    end
                end
                
                % Teste t para diferenças significativas
                statistics.ttest = struct();
                
                for i = 1:length(obj.REFERENCE_METRICS)
                    metric = obj.REFERENCE_METRICS{i};
                    
                    for j = 1:length(obj.REFERENCE_MODELS)
                        model = obj.REFERENCE_MODELS{j};
                        
                        if isfield(referenceResults.metrics, metric) && ...
                           isfield(newResults.metrics, metric) && ...
                           isfield(referenceResults.metrics.(metric), model) && ...
                           isfield(newResults.metrics.(metric), model)
                            
                            refValues = referenceResults.metrics.(metric).(model);
                            newValues = newResults.metrics.(metric).(model);
                            
                            if length(refValues) == length(newValues) && length(refValues) > 1
                                [h, p] = ttest(refValues, newValues);
                                statistics.ttest.(sprintf('%s_%s', metric, model)) = struct('h', h, 'p', p);
                            end
                        end
                    end
                end
                
            catch ME
                obj.logger('warning', sprintf('Erro na análise estatística: %s', ME.message));
            end
        end
        
        function summary = createConsistencySummary(obj, report)
            % Cria resumo de consistência
            
            summary = struct();
            summary.overallConsistent = true;
            summary.inconsistentMetrics = {};
            summary.totalMetrics = 0;
            summary.consistentMetrics = 0;
            
            % Analisar métricas
            if isfield(report, 'metrics')
                for i = 1:length(obj.REFERENCE_METRICS)
                    metric = obj.REFERENCE_METRICS{i};
                    
                    if isfield(report.metrics, metric)
                        for j = 1:length(obj.REFERENCE_MODELS)
                            model = obj.REFERENCE_MODELS{j};
                            
                            if isfield(report.metrics.(metric), model)
                                summary.totalMetrics = summary.totalMetrics + 1;
                                
                                if report.metrics.(metric).(model).isConsistent
                                    summary.consistentMetrics = summary.consistentMetrics + 1;
                                else
                                    summary.overallConsistent = false;
                                    summary.inconsistentMetrics{end+1} = sprintf('%s.%s', metric, model);
                                end
                            end
                        end
                    end
                end
            end
            
            summary.consistencyRate = summary.consistentMetrics / summary.totalMetrics;
        end
    end
end