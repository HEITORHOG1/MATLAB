classdef StatisticalAnalyzer < handle
    % ========================================================================
    % STATISTICAL ANALYZER - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe para análises estatísticas avançadas de métricas de segmentação
    %   Implementa testes estatísticos, intervalos de confiança e interpretação
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Statistics and Machine Learning Toolbox
    %   - Hypothesis Testing
    % ========================================================================
    
    properties (Access = private)
        verbose = false;
        alpha = 0.05; % Nível de significância padrão
    end
    
    methods
        function obj = StatisticalAnalyzer(varargin)
            % Construtor da classe StatisticalAnalyzer
            %
            % Uso:
            %   analyzer = StatisticalAnalyzer()
            %   analyzer = StatisticalAnalyzer('verbose', true, 'alpha', 0.01)
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'verbose', false, @islogical);
            addParameter(p, 'alpha', 0.05, @(x) isnumeric(x) && x > 0 && x < 1);
            parse(p, varargin{:});
            
            obj.verbose = p.Results.verbose;
            obj.alpha = p.Results.alpha;
            
            if obj.verbose
                fprintf('StatisticalAnalyzer inicializado (α = %.3f).\n', obj.alpha);
            end
        end
        
        function results = performTTest(obj, sample1, sample2, varargin)
            % Realizar teste t para comparar duas amostras
            %
            % Entrada:
            %   sample1 - Primeira amostra (vetor)
            %   sample2 - Segunda amostra (vetor)
            %   varargin - Parâmetros opcionais:
            %              'type': 'paired' ou 'unpaired' (padrão: 'unpaired')
            %              'tail': 'both', 'left', 'right' (padrão: 'both')
            %
            % Saída:
            %   results - Struct com resultados do teste
            
            try
                % Parse de argumentos opcionais
                p = inputParser;
                addParameter(p, 'type', 'unpaired', @(x) ismember(x, {'paired', 'unpaired'}));
                addParameter(p, 'tail', 'both', @(x) ismember(x, {'both', 'left', 'right'}));
                parse(p, varargin{:});
                
                testType = p.Results.type;
                tail = p.Results.tail;
                
                % Validar entrada
                sample1 = sample1(:); % Converter para vetor coluna
                sample2 = sample2(:);
                
                if strcmp(testType, 'paired') && length(sample1) ~= length(sample2)
                    error('StatisticalAnalyzer:PairedSampleSizeMismatch', ...
                          'Amostras pareadas devem ter o mesmo tamanho');
                end
                
                % Inicializar estrutura de resultados
                results = struct();
                results.testType = testType;
                results.tail = tail;
                results.alpha = obj.alpha;
                results.n1 = length(sample1);
                results.n2 = length(sample2);
                
                % Estatísticas descritivas
                results.sample1.mean = mean(sample1);
                results.sample1.std = std(sample1);
                results.sample1.median = median(sample1);
                
                results.sample2.mean = mean(sample2);
                results.sample2.std = std(sample2);
                results.sample2.median = median(sample2);
                
                % Realizar teste t
                if strcmp(testType, 'paired')
                    % Teste t pareado
                    diff = sample1 - sample2;
                    results.meanDifference = mean(diff);
                    results.stdDifference = std(diff);
                    
                    % Calcular estatística t
                    results.tStat = results.meanDifference / (results.stdDifference / sqrt(length(diff)));
                    results.df = length(diff) - 1;
                    
                else
                    % Teste t não pareado (assumindo variâncias iguais)
                    pooledStd = sqrt(((results.n1-1)*results.sample1.std^2 + (results.n2-1)*results.sample2.std^2) / ...
                                   (results.n1 + results.n2 - 2));
                    
                    results.pooledStd = pooledStd;
                    results.meanDifference = results.sample1.mean - results.sample2.mean;
                    
                    % Calcular estatística t
                    results.tStat = results.meanDifference / (pooledStd * sqrt(1/results.n1 + 1/results.n2));
                    results.df = results.n1 + results.n2 - 2;
                end
                
                % Calcular p-value usando aproximação própria
                if isnan(results.tStat) || isinf(results.tStat)
                    % Caso especial: amostras idênticas ou erro numérico
                    results.pValue = 1.0; % Não há diferença
                else
                    results.pValue = obj.approximateTDistribution(results.tStat, results.df, tail);
                end
                
                % Decisão do teste
                results.significant = results.pValue < obj.alpha;
                results.effectSize = obj.calculateEffectSize(sample1, sample2, testType);
                
                % Interpretação
                results.interpretation = obj.interpretTTestResults(results);
                
                if obj.verbose
                    fprintf('Teste t realizado:\n');
                    fprintf('  Tipo: %s\n', testType);
                    fprintf('  t = %.4f, df = %d, p = %.4f\n', results.tStat, results.df, results.pValue);
                    fprintf('  Significativo: %s\n', obj.boolToString(results.significant));
                    fprintf('  Effect size: %.4f\n', results.effectSize);
                end
                
            catch ME
                if obj.verbose
                    fprintf('Erro no teste t: %s\n', ME.message);
                end
                results = struct('error', ME.message);
            end
        end
        
        function ci = calculateConfidenceIntervals(obj, data, varargin)
            % Calcular intervalos de confiança para métricas
            %
            % Entrada:
            %   data - Dados (vetor ou struct com campos de métricas)
            %   varargin - Parâmetros opcionais:
            %              'confidence': nível de confiança (padrão: 0.95)
            %              'method': 'normal' ou 'bootstrap' (padrão: 'normal')
            %
            % Saída:
            %   ci - Struct com intervalos de confiança
            
            try
                % Parse de argumentos opcionais
                p = inputParser;
                addParameter(p, 'confidence', 0.95, @(x) isnumeric(x) && x > 0 && x < 1);
                addParameter(p, 'method', 'normal', @(x) ismember(x, {'normal', 'bootstrap'}));
                parse(p, varargin{:});
                
                confidence = p.Results.confidence;
                method = p.Results.method;
                
                % Inicializar estrutura de resultados
                ci = struct();
                ci.confidence = confidence;
                ci.method = method;
                ci.alpha = 1 - confidence;
                
                if isstruct(data)
                    % Dados estruturados (múltiplas métricas)
                    fields = fieldnames(data);
                    for i = 1:length(fields)
                        fieldName = fields{i};
                        if isnumeric(data.(fieldName)) && length(data.(fieldName)) > 1
                            ci.(fieldName) = obj.calculateSingleCI(data.(fieldName), confidence, method);
                        end
                    end
                else
                    % Dados simples (vetor)
                    ci.data = obj.calculateSingleCI(data, confidence, method);
                end
                
                if obj.verbose
                    fprintf('Intervalos de confiança calculados (%.1f%%, método: %s)\n', ...
                            confidence*100, method);
                end
                
            catch ME
                if obj.verbose
                    fprintf('Erro no cálculo de intervalos de confiança: %s\n', ME.message);
                end
                ci = struct('error', ME.message);
            end
        end  
      
        function comparison = compareModels(obj, metrics1, metrics2, modelNames)
            % Comparar dois modelos usando múltiplas métricas
            %
            % Entrada:
            %   metrics1   - Métricas do primeiro modelo (struct ou array)
            %   metrics2   - Métricas do segundo modelo (struct ou array)
            %   modelNames - Cell array com nomes dos modelos (opcional)
            %
            % Saída:
            %   comparison - Struct com comparação completa
            
            try
                if nargin < 4
                    modelNames = {'Model 1', 'Model 2'};
                end
                
                % Inicializar estrutura de resultados
                comparison = struct();
                comparison.modelNames = modelNames;
                comparison.timestamp = datestr(now);
                
                if isstruct(metrics1) && isstruct(metrics2)
                    % Comparação estruturada (múltiplas métricas)
                    fields = intersect(fieldnames(metrics1), fieldnames(metrics2));
                    
                    for i = 1:length(fields)
                        fieldName = fields{i};
                        if isnumeric(metrics1.(fieldName)) && isnumeric(metrics2.(fieldName))
                            % Realizar teste t para esta métrica
                            testResults = obj.performTTest(metrics1.(fieldName), metrics2.(fieldName));
                            
                            % Calcular intervalos de confiança
                            ci1 = obj.calculateConfidenceIntervals(metrics1.(fieldName));
                            ci2 = obj.calculateConfidenceIntervals(metrics2.(fieldName));
                            
                            % Armazenar resultados
                            comparison.metrics.(fieldName) = struct();
                            comparison.metrics.(fieldName).tTest = testResults;
                            comparison.metrics.(fieldName).ci1 = ci1.data;
                            comparison.metrics.(fieldName).ci2 = ci2.data;
                            comparison.metrics.(fieldName).winner = obj.determineWinner(testResults, modelNames);
                        end
                    end
                    
                else
                    % Comparação simples (arrays)
                    testResults = obj.performTTest(metrics1, metrics2);
                    ci1 = obj.calculateConfidenceIntervals(metrics1);
                    ci2 = obj.calculateConfidenceIntervals(metrics2);
                    
                    comparison.tTest = testResults;
                    comparison.ci1 = ci1.data;
                    comparison.ci2 = ci2.data;
                    comparison.winner = obj.determineWinner(testResults, modelNames);
                end
                
                % Resumo geral
                comparison.summary = obj.generateComparisonSummary(comparison);
                
                if obj.verbose
                    fprintf('Comparação de modelos realizada:\n');
                    fprintf('  %s vs %s\n', modelNames{1}, modelNames{2});
                    fprintf('  Resumo: %s\n', comparison.summary);
                end
                
            catch ME
                if obj.verbose
                    fprintf('Erro na comparação de modelos: %s\n', ME.message);
                end
                comparison = struct('error', ME.message);
            end
        end
        
        function interpretation = interpretResults(obj, results)
            % Interpretar automaticamente resultados estatísticos
            %
            % Entrada:
            %   results - Struct com resultados de testes estatísticos
            %
            % Saída:
            %   interpretation - String com interpretação em linguagem natural
            
            try
                if isfield(results, 'error')
                    interpretation = sprintf('Erro na análise: %s', results.error);
                    return;
                end
                
                if isfield(results, 'tTest')
                    % Interpretação de teste t
                    interpretation = obj.interpretTTestResults(results.tTest);
                    
                elseif isfield(results, 'pValue')
                    % Interpretação direta de teste estatístico
                    interpretation = obj.interpretTTestResults(results);
                    
                else
                    interpretation = 'Tipo de resultado não reconhecido para interpretação.';
                end
                
            catch ME
                interpretation = sprintf('Erro na interpretação: %s', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function singleCI = calculateSingleCI(obj, data, confidence, method)
            % Calcular intervalo de confiança para um único conjunto de dados
            
            data = data(:); % Converter para vetor coluna
            n = length(data);
            
            % Verificar se dados estão vazios
            if n == 0
                error('StatisticalAnalyzer:EmptyData', 'Dados não podem estar vazios');
            end
            
            meanVal = mean(data);
            stdVal = std(data);
            
            singleCI = struct();
            singleCI.mean = meanVal;
            singleCI.std = stdVal;
            singleCI.n = n;
            
            if strcmp(method, 'normal')
                % Método normal (assumindo distribuição normal)
                alpha = 1 - confidence;
                
                if n > 30
                    % Usar distribuição normal para amostras grandes
                    z = obj.approximateNormInv(1 - alpha/2);
                    margin = z * stdVal / sqrt(n);
                else
                    % Usar aproximação t para amostras pequenas
                    t = obj.approximateTValue(n-1, alpha/2);
                    margin = t * stdVal / sqrt(n);
                end
                
                singleCI.lower = meanVal - margin;
                singleCI.upper = meanVal + margin;
                singleCI.margin = margin;
                
            else
                % Método bootstrap (implementação simples)
                singleCI = obj.bootstrapCI(data, confidence);
            end
        end
        
        function ci = bootstrapCI(obj, data, confidence)
            % Implementação simples de bootstrap para intervalo de confiança
            
            nBootstrap = 1000;
            n = length(data);
            bootstrapMeans = zeros(nBootstrap, 1);
            
            % Gerar amostras bootstrap
            for i = 1:nBootstrap
                % Amostragem com reposição
                indices = randi(n, n, 1);
                bootstrapSample = data(indices);
                bootstrapMeans(i) = mean(bootstrapSample);
            end
            
            % Calcular percentis
            alpha = 1 - confidence;
            lowerPercentile = alpha/2 * 100;
            upperPercentile = (1 - alpha/2) * 100;
            
            ci = struct();
            ci.mean = mean(data);
            ci.std = std(data);
            ci.n = length(data);
            ci.lower = prctile(bootstrapMeans, lowerPercentile);
            ci.upper = prctile(bootstrapMeans, upperPercentile);
            ci.margin = (ci.upper - ci.lower) / 2;
            ci.bootstrapMeans = bootstrapMeans;
        end
        
        function pValue = approximateTDistribution(obj, tStat, df, tail)
            % Aproximação simples da distribuição t usando distribuição normal
            % Para uso quando não há acesso à função tcdf
            
            if df > 30
                % Usar distribuição normal para df grandes
                switch tail
                    case 'both'
                        pValue = 2 * (1 - obj.approximateNormCDF(abs(tStat)));
                    case 'right'
                        pValue = 1 - obj.approximateNormCDF(tStat);
                    case 'left'
                        pValue = obj.approximateNormCDF(tStat);
                end
            else
                % Aproximação conservadora para df pequenos
                % Usar distribuição normal com correção
                correction = 1 + 1/(4*df);
                adjustedT = tStat / correction;
                
                switch tail
                    case 'both'
                        pValue = 2 * (1 - obj.approximateNormCDF(abs(adjustedT)));
                    case 'right'
                        pValue = 1 - obj.approximateNormCDF(adjustedT);
                    case 'left'
                        pValue = obj.approximateNormCDF(adjustedT);
                end
            end
        end
        
        function t = approximateTValue(obj, df, alpha)
            % Aproximação simples do valor crítico t
            
            if df > 30
                % Usar valor z para df grandes
                t = obj.approximateNormInv(1 - alpha);
            else
                % Aproximação para df pequenos
                z = obj.approximateNormInv(1 - alpha);
                correction = 1 + (z^2 + 1)/(4*df);
                t = z * correction;
            end
        end
        
        function effectSize = calculateEffectSize(obj, sample1, sample2, testType)
            % Calcular tamanho do efeito (Cohen's d)
            
            if strcmp(testType, 'paired')
                % Para teste pareado
                diff = sample1 - sample2;
                effectSize = mean(diff) / std(diff);
            else
                % Para teste não pareado
                pooledStd = sqrt((var(sample1) + var(sample2)) / 2);
                effectSize = (mean(sample1) - mean(sample2)) / pooledStd;
            end
            
            effectSize = abs(effectSize); % Magnitude do efeito
        end
        
        function interpretation = interpretTTestResults(obj, results)
            % Interpretar resultados do teste t
            
            if results.significant
                if results.effectSize < 0.2
                    effectDesc = 'pequeno';
                elseif results.effectSize < 0.5
                    effectDesc = 'médio';
                elseif results.effectSize < 0.8
                    effectDesc = 'grande';
                else
                    effectDesc = 'muito grande';
                end
                
                interpretation = sprintf(['Diferença estatisticamente significativa ' ...
                                        '(p = %.4f < %.3f) com efeito %s (d = %.3f)'], ...
                                        results.pValue, obj.alpha, effectDesc, results.effectSize);
            else
                interpretation = sprintf(['Não há diferença estatisticamente significativa ' ...
                                        '(p = %.4f ≥ %.3f)'], ...
                                        results.pValue, obj.alpha);
            end
        end
        
        function winner = determineWinner(obj, testResults, modelNames)
            % Determinar qual modelo é melhor baseado nos resultados
            
            if ~testResults.significant
                winner = 'Empate (diferença não significativa)';
            else
                if testResults.meanDifference > 0
                    winner = modelNames{1};
                else
                    winner = modelNames{2};
                end
            end
        end
        
        function summary = generateComparisonSummary(obj, comparison)
            % Gerar resumo da comparação
            
            if isfield(comparison, 'metrics')
                % Múltiplas métricas
                fields = fieldnames(comparison.metrics);
                significantCount = 0;
                totalCount = length(fields);
                
                for i = 1:length(fields)
                    if comparison.metrics.(fields{i}).tTest.significant
                        significantCount = significantCount + 1;
                    end
                end
                
                summary = sprintf('%d de %d métricas mostram diferenças significativas', ...
                                significantCount, totalCount);
            else
                % Métrica única
                if comparison.tTest.significant
                    summary = sprintf('Diferença significativa detectada (p = %.4f)', ...
                                    comparison.tTest.pValue);
                else
                    summary = sprintf('Nenhuma diferença significativa (p = %.4f)', ...
                                    comparison.tTest.pValue);
                end
            end
        end
        
        function str = boolToString(obj, value)
            % Converter booleano para string
            if value
                str = 'Sim';
            else
                str = 'Não';
            end
        end
        
        function p = approximateNormCDF(obj, x)
            % Aproximação da função de distribuição cumulativa normal padrão
            % Usando aproximação de Abramowitz e Stegun (1964)
            
            if x < 0
                p = 1 - obj.approximateNormCDF(-x);
                return;
            end
            
            % Constantes para aproximação
            a1 =  0.254829592;
            a2 = -0.284496736;
            a3 =  1.421413741;
            a4 = -1.453152027;
            a5 =  1.061405429;
            p_const = 0.3275911;
            
            % Calcular aproximação
            t = 1.0 / (1.0 + p_const * x);
            y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-x * x);
            
            p = y;
        end
        
        function x = approximateNormInv(obj, p)
            % Aproximação da função inversa da distribuição normal padrão
            % Usando aproximação de Beasley-Springer-Moro
            
            if p <= 0 || p >= 1
                error('StatisticalAnalyzer:InvalidProbability', 'p deve estar entre 0 e 1');
            end
            
            if p < 0.5
                % Usar simetria
                x = -obj.approximateNormInv(1 - p);
                return;
            end
            
            % Constantes para aproximação
            a0 = -3.969683028665376e+01;
            a1 =  2.209460984245205e+02;
            a2 = -2.759285104469687e+02;
            a3 =  1.383577518672690e+02;
            a4 = -3.066479806614716e+01;
            a5 =  2.506628277459239e+00;
            
            b1 = -5.447609879822406e+01;
            b2 =  1.615858368580409e+02;
            b3 = -1.556989798598866e+02;
            b4 =  6.680131188771972e+01;
            b5 = -1.328068155288572e+01;
            
            % Transformar para trabalhar com cauda superior
            if p > 0.5
                q = 1 - p;
                sign = 1;
            else
                q = p;
                sign = -1;
            end
            
            % Calcular aproximação
            t = sqrt(-2 * log(q));
            
            x = sign * (((((a5*t + a4)*t + a3)*t + a2)*t + a1)*t + a0) / ...
                      (((((t + b5)*t + b4)*t + b3)*t + b2)*t + b1);
        end
    end
end