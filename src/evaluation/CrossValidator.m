classdef CrossValidator < handle
    % ========================================================================
    % CROSS VALIDATOR - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe para validação cruzada k-fold automatizada
    %   Implementa divisão estratificada e agregação de resultados
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Machine Learning and Cross-Validation
    %   - Statistical Analysis
    % ========================================================================
    
    properties (Access = private)
        verbose = false;
        randomSeed = 42; % Para reprodutibilidade
    end
    
    methods
        function obj = CrossValidator(varargin)
            % Construtor da classe CrossValidator
            %
            % Uso:
            %   cv = CrossValidator()
            %   cv = CrossValidator('verbose', true, 'randomSeed', 123)
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'verbose', false, @islogical);
            addParameter(p, 'randomSeed', 42, @isnumeric);
            parse(p, varargin{:});
            
            obj.verbose = p.Results.verbose;
            obj.randomSeed = p.Results.randomSeed;
            
            % Definir semente aleatória para reprodutibilidade
            try
                rng(obj.randomSeed);
            catch
                % Fallback para Octave
                rand('seed', obj.randomSeed);
                randn('seed', obj.randomSeed);
            end
            
            if obj.verbose
                fprintf('CrossValidator inicializado (seed = %d).\n', obj.randomSeed);
            end
        end
        
        function folds = createKFolds(obj, data, k, varargin)
            % Criar k folds para validação cruzada
            %
            % Entrada:
            %   data - Dados para dividir (cell array ou struct)
            %   k    - Número de folds
            %   varargin - Parâmetros opcionais:
            %              'stratified': true/false (padrão: false)
            %              'labels': labels para estratificação
            %
            % Saída:
            %   folds - Cell array com k folds, cada um contendo índices
            
            try
                % Parse de argumentos opcionais
                p = inputParser;
                addParameter(p, 'stratified', false, @islogical);
                addParameter(p, 'labels', [], @(x) isnumeric(x) || iscell(x));
                parse(p, varargin{:});
                
                stratified = p.Results.stratified;
                labels = p.Results.labels;
                
                % Determinar número de amostras
                if iscell(data)
                    nSamples = length(data);
                elseif isstruct(data)
                    fields = fieldnames(data);
                    if ~isempty(fields)
                        firstField = data.(fields{1});
                        if iscell(firstField)
                            nSamples = length(firstField);
                        else
                            nSamples = size(firstField, 1);
                        end
                    else
                        error('CrossValidator:EmptyStruct', 'Struct de dados está vazio');
                    end
                else
                    nSamples = size(data, 1);
                end
                
                % Validar parâmetros
                if k <= 1 || k > nSamples
                    error('CrossValidator:InvalidK', 'k deve estar entre 2 e %d', nSamples);
                end
                
                if stratified && isempty(labels)
                    error('CrossValidator:MissingLabels', 'Labels são necessários para estratificação');
                end
                
                % Criar folds
                if stratified
                    folds = obj.createStratifiedFolds(nSamples, k, labels);
                else
                    folds = obj.createRandomFolds(nSamples, k);
                end
                
                if obj.verbose
                    fprintf('Criados %d folds para %d amostras\n', k, nSamples);
                    if stratified
                        fprintf('  Estratificação: ativada\n');
                    end
                end
                
            catch ME
                if obj.verbose
                    fprintf('Erro na criação de folds: %s\n', ME.message);
                end
                folds = {};
                rethrow(ME);
            end
        end
        
        function results = performKFoldValidation(obj, data, trainFunction, evaluateFunction, k, varargin)
            % Realizar validação cruzada k-fold
            %
            % Entrada:
            %   data            - Dados para validação
            %   trainFunction   - Handle para função de treinamento
            %   evaluateFunction - Handle para função de avaliação
            %   k               - Número de folds
            %   varargin        - Parâmetros opcionais para createKFolds
            %
            % Saída:
            %   results - Struct com resultados agregados
            
            try
                % Criar folds
                folds = obj.createKFolds(data, k, varargin{:});
                
                % Inicializar estruturas de resultados
                results = struct();
                results.k = k;
                results.foldResults = cell(k, 1);
                results.trainTime = zeros(k, 1);
                results.evalTime = zeros(k, 1);
                
                if obj.verbose
                    fprintf('Iniciando validação cruzada %d-fold...\n', k);
                end
                
                % Executar validação para cada fold
                for foldIdx = 1:k
                    if obj.verbose
                        fprintf('  Processando fold %d/%d...\n', foldIdx, k);
                    end
                    
                    % Dividir dados em treino e validação
                    testIndices = folds{foldIdx};
                    trainIndices = setdiff(1:obj.getTotalSamples(data), testIndices);
                    
                    trainData = obj.extractSubset(data, trainIndices);
                    testData = obj.extractSubset(data, testIndices);
                    
                    % Treinar modelo
                    tic;
                    model = trainFunction(trainData);
                    results.trainTime(foldIdx) = toc;
                    
                    % Avaliar modelo
                    tic;
                    foldResult = evaluateFunction(model, testData);
                    results.evalTime(foldIdx) = toc;
                    
                    % Armazenar resultado do fold
                    results.foldResults{foldIdx} = foldResult;
                    
                    if obj.verbose
                        fprintf('    Fold %d concluído (treino: %.2fs, eval: %.2fs)\n', ...
                                foldIdx, results.trainTime(foldIdx), results.evalTime(foldIdx));
                    end
                end
                
                % Agregar resultados
                results.aggregated = obj.aggregateResults(results.foldResults);
                results.totalTime = sum(results.trainTime) + sum(results.evalTime);
                
                if obj.verbose
                    fprintf('Validação cruzada concluída (tempo total: %.2fs)\n', results.totalTime);
                end
                
            catch ME
                if obj.verbose
                    fprintf('Erro na validação cruzada: %s\n', ME.message);
                end
                results = struct('error', ME.message);
                rethrow(ME);
            end
        end
        
        function comparison = compareModelsKFold(obj, data, trainFunctions, evaluateFunction, k, modelNames, varargin)
            % Comparar múltiplos modelos usando validação cruzada k-fold
            %
            % Entrada:
            %   data            - Dados para validação
            %   trainFunctions  - Cell array de handles para funções de treinamento
            %   evaluateFunction - Handle para função de avaliação
            %   k               - Número de folds
            %   modelNames      - Cell array com nomes dos modelos
            %   varargin        - Parâmetros opcionais
            %
            % Saída:
            %   comparison - Struct com comparação completa
            
            try
                nModels = length(trainFunctions);
                
                if nargin < 6 || isempty(modelNames)
                    modelNames = cell(nModels, 1);
                    for i = 1:nModels
                        modelNames{i} = sprintf('Model %d', i);
                    end
                end
                
                % Inicializar estrutura de comparação
                comparison = struct();
                comparison.modelNames = modelNames;
                comparison.k = k;
                comparison.modelResults = cell(nModels, 1);
                
                if obj.verbose
                    fprintf('Comparando %d modelos com validação cruzada %d-fold...\n', nModels, k);
                end
                
                % Executar validação cruzada para cada modelo
                for modelIdx = 1:nModels
                    if obj.verbose
                        fprintf('  Validando %s...\n', modelNames{modelIdx});
                    end
                    
                    modelResults = obj.performKFoldValidation(data, trainFunctions{modelIdx}, ...
                                                            evaluateFunction, k, varargin{:});
                    comparison.modelResults{modelIdx} = modelResults;
                end
                
                % Realizar comparação estatística
                comparison.statisticalComparison = obj.performStatisticalComparison(comparison.modelResults, modelNames);
                
                % Gerar resumo
                comparison.summary = obj.generateComparisonSummary(comparison);
                
                if obj.verbose
                    fprintf('Comparação de modelos concluída.\n');
                    fprintf('Resumo: %s\n', comparison.summary);
                end
                
            catch ME
                if obj.verbose
                    fprintf('Erro na comparação de modelos: %s\n', ME.message);
                end
                comparison = struct('error', ME.message);
                rethrow(ME);
            end
        end
    end
    
    methods (Access = private)
        function folds = createRandomFolds(obj, nSamples, k)
            % Criar folds aleatórios
            
            % Embaralhar índices
            indices = randperm(nSamples);
            
            % Calcular tamanho dos folds
            foldSize = floor(nSamples / k);
            remainder = mod(nSamples, k);
            
            % Criar folds
            folds = cell(k, 1);
            startIdx = 1;
            
            for i = 1:k
                % Alguns folds podem ter um elemento extra
                currentFoldSize = foldSize;
                if i <= remainder
                    currentFoldSize = currentFoldSize + 1;
                end
                
                endIdx = startIdx + currentFoldSize - 1;
                folds{i} = indices(startIdx:endIdx);
                startIdx = endIdx + 1;
            end
        end
        
        function folds = createStratifiedFolds(obj, nSamples, k, labels)
            % Criar folds estratificados baseados em labels
            
            % Converter labels para formato numérico se necessário
            if iscell(labels)
                [uniqueLabels, ~, labelIndices] = unique(labels);
            else
                labelIndices = labels;
                uniqueLabels = unique(labels);
            end
            
            nClasses = length(uniqueLabels);
            folds = cell(k, 1);
            
            % Inicializar folds vazios
            for i = 1:k
                folds{i} = [];
            end
            
            % Para cada classe, distribuir amostras pelos folds
            for classIdx = 1:nClasses
                classIndices = find(labelIndices == classIdx);
                nClassSamples = length(classIndices);
                
                % Embaralhar índices da classe
                classIndices = classIndices(randperm(nClassSamples));
                
                % Distribuir pelos folds
                for sampleIdx = 1:nClassSamples
                    foldIdx = mod(sampleIdx - 1, k) + 1;
                    folds{foldIdx} = [folds{foldIdx}, classIndices(sampleIdx)];
                end
            end
            
            % Embaralhar índices dentro de cada fold
            for i = 1:k
                folds{i} = folds{i}(randperm(length(folds{i})));
            end
        end
        
        function nSamples = getTotalSamples(obj, data)
            % Obter número total de amostras nos dados
            
            if iscell(data)
                nSamples = length(data);
            elseif isstruct(data)
                fields = fieldnames(data);
                if ~isempty(fields)
                    firstField = data.(fields{1});
                    if iscell(firstField)
                        nSamples = length(firstField);
                    else
                        nSamples = size(firstField, 1);
                    end
                else
                    nSamples = 0;
                end
            else
                nSamples = size(data, 1);
            end
        end
        
        function subset = extractSubset(obj, data, indices)
            % Extrair subconjunto dos dados baseado em índices
            
            if iscell(data)
                subset = data(indices);
            elseif isstruct(data)
                subset = struct();
                fields = fieldnames(data);
                for i = 1:length(fields)
                    fieldName = fields{i};
                    fieldData = data.(fieldName);
                    if iscell(fieldData)
                        subset.(fieldName) = fieldData(indices);
                    else
                        subset.(fieldName) = fieldData(indices, :);
                    end
                end
            else
                subset = data(indices, :);
            end
        end
        
        function aggregated = aggregateResults(obj, foldResults)
            % Agregar resultados de múltiplos folds
            
            if isempty(foldResults)
                aggregated = struct();
                return;
            end
            
            % Verificar se todos os resultados têm a mesma estrutura
            firstResult = foldResults{1};
            
            if isstruct(firstResult)
                % Resultados estruturados
                aggregated = struct();
                fields = fieldnames(firstResult);
                
                for i = 1:length(fields)
                    fieldName = fields{i};
                    values = [];
                    
                    % Coletar valores de todos os folds
                    for foldIdx = 1:length(foldResults)
                        if isfield(foldResults{foldIdx}, fieldName)
                            fieldValue = foldResults{foldIdx}.(fieldName);
                            if isnumeric(fieldValue) && isscalar(fieldValue)
                                values = [values, fieldValue];
                            end
                        end
                    end
                    
                    % Calcular estatísticas agregadas
                    if ~isempty(values)
                        aggregated.(fieldName) = struct();
                        aggregated.(fieldName).mean = mean(values);
                        aggregated.(fieldName).std = std(values);
                        aggregated.(fieldName).min = min(values);
                        aggregated.(fieldName).max = max(values);
                        aggregated.(fieldName).median = median(values);
                        aggregated.(fieldName).values = values;
                    end
                end
                
            else
                % Resultados simples (arrays ou escalares)
                values = [];
                for foldIdx = 1:length(foldResults)
                    if isnumeric(foldResults{foldIdx})
                        values = [values, foldResults{foldIdx}(:)'];
                    end
                end
                
                if ~isempty(values)
                    aggregated = struct();
                    aggregated.mean = mean(values);
                    aggregated.std = std(values);
                    aggregated.min = min(values);
                    aggregated.max = max(values);
                    aggregated.median = median(values);
                    aggregated.values = values;
                end
            end
        end
        
        function comparison = performStatisticalComparison(obj, modelResults, modelNames)
            % Realizar comparação estatística entre modelos
            
            try
                % Usar StatisticalAnalyzer para comparação
                analyzer = StatisticalAnalyzer('verbose', obj.verbose);
                
                nModels = length(modelResults);
                comparison = struct();
                comparison.pairwise = struct();
                
                % Comparações par a par
                for i = 1:nModels
                    for j = i+1:nModels
                        pairName = sprintf('%s_vs_%s', modelNames{i}, modelNames{j});
                        
                        % Extrair métricas dos dois modelos
                        metrics1 = obj.extractMetricsFromResults(modelResults{i});
                        metrics2 = obj.extractMetricsFromResults(modelResults{j});
                        
                        % Realizar comparação
                        pairComparison = analyzer.compareModels(metrics1, metrics2, {modelNames{i}, modelNames{j}});
                        comparison.pairwise.(pairName) = pairComparison;
                    end
                end
                
                % Determinar melhor modelo geral
                comparison.bestModel = obj.determineBestModel(modelResults, modelNames);
                
            catch ME
                if obj.verbose
                    fprintf('Erro na comparação estatística: %s\n', ME.message);
                end
                comparison = struct('error', ME.message);
            end
        end
        
        function metrics = extractMetricsFromResults(obj, results)
            % Extrair métricas dos resultados de validação cruzada
            
            if isfield(results, 'aggregated') && isstruct(results.aggregated)
                % Extrair valores de cada métrica
                metrics = struct();
                fields = fieldnames(results.aggregated);
                
                for i = 1:length(fields)
                    fieldName = fields{i};
                    if isfield(results.aggregated.(fieldName), 'values')
                        metrics.(fieldName) = results.aggregated.(fieldName).values;
                    end
                end
            else
                % Fallback: tentar extrair diretamente dos fold results
                metrics = [];
                if isfield(results, 'foldResults')
                    for foldIdx = 1:length(results.foldResults)
                        if isnumeric(results.foldResults{foldIdx})
                            metrics = [metrics, results.foldResults{foldIdx}];
                        end
                    end
                end
            end
        end
        
        function bestModel = determineBestModel(obj, modelResults, modelNames)
            % Determinar o melhor modelo baseado nos resultados
            
            nModels = length(modelResults);
            scores = zeros(nModels, 1);
            
            % Calcular score para cada modelo (média das métricas principais)
            for i = 1:nModels
                metrics = obj.extractMetricsFromResults(modelResults{i});
                
                if isstruct(metrics)
                    % Múltiplas métricas - calcular média ponderada
                    totalScore = 0;
                    nMetrics = 0;
                    
                    fields = fieldnames(metrics);
                    for j = 1:length(fields)
                        if isnumeric(metrics.(fields{j}))
                            totalScore = totalScore + mean(metrics.(fields{j}));
                            nMetrics = nMetrics + 1;
                        end
                    end
                    
                    if nMetrics > 0
                        scores(i) = totalScore / nMetrics;
                    end
                else
                    % Métrica única
                    if isnumeric(metrics) && ~isempty(metrics)
                        scores(i) = mean(metrics);
                    end
                end
            end
            
            % Encontrar modelo com maior score
            [~, bestIdx] = max(scores);
            bestModel = struct();
            bestModel.name = modelNames{bestIdx};
            bestModel.index = bestIdx;
            bestModel.score = scores(bestIdx);
            bestModel.allScores = scores;
        end
        
        function summary = generateComparisonSummary(obj, comparison)
            % Gerar resumo da comparação
            
            if isfield(comparison, 'error')
                summary = sprintf('Erro na comparação: %s', comparison.error);
                return;
            end
            
            if isfield(comparison, 'bestModel')
                summary = sprintf('Melhor modelo: %s (score: %.4f)', ...
                                comparison.bestModel.name, comparison.bestModel.score);
                
                % Adicionar informação sobre significância estatística
                if isfield(comparison, 'statisticalComparison') && ...
                   isfield(comparison.statisticalComparison, 'pairwise')
                   
                    pairFields = fieldnames(comparison.statisticalComparison.pairwise);
                    significantCount = 0;
                    
                    for i = 1:length(pairFields)
                        pairResult = comparison.statisticalComparison.pairwise.(pairFields{i});
                        if isfield(pairResult, 'tTest') && pairResult.tTest.significant
                            significantCount = significantCount + 1;
                        end
                    end
                    
                    summary = sprintf('%s (%d/%d comparações significativas)', ...
                                    summary, significantCount, length(pairFields));
                end
            else
                summary = 'Comparação incompleta';
            end
        end
    end
end