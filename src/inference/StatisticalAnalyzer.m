classdef StatisticalAnalyzer < handle
    % StatisticalAnalyzer - Análises estatísticas avançadas para comparação de modelos
    % 
    % Esta classe implementa análises estatísticas completas incluindo testes
    % paramétricos e não-paramétricos, cálculo de effect size, correção para
    % múltiplas comparações e interpretação automática dos resultados.
    %
    % Requisitos atendidos: 6.1, 6.2, 6.3, 6.4, 6.5
    
    properties
        alpha              % Nível de significância
        multipleComparisonsMethod % Método de correção para múltiplas comparações
        effectSizeMethod   % Método para cálculo de effect size
        verbose           % Flag para output detalhado
        confidenceLevel   % Nível de confiança para intervalos
    end
    
    methods (Static)
        function results = performComprehensiveAnalysis(unetMetrics, attentionMetrics, config)
            % Realiza análise estatística completa comparando dois modelos
            %
            % Inputs:
            %   unetMetrics - struct com métricas do U-Net
            %   attentionMetrics - struct com métricas do Attention U-Net
            %   config - struct com configurações (opcional)
            %
            % Outputs:
            %   results - struct com resultados da análise estatística
            
            if nargin < 3
                config = struct();
            end
            
            % Criar instância do analisador
            analyzer = StatisticalAnalyzer(config);
            
            if analyzer.verbose
                fprintf('Iniciando análise estatística completa...\n');
            end
            
            results = struct();
            results.timestamp = datetime('now');
            results.config = config;
            
            % Extrair métricas para análise
            metrics = analyzer.extractMetrics(unetMetrics, attentionMetrics);
            results.metrics = metrics;
            
            % Testes de normalidade
            results.normalityTests = analyzer.performNormalityTests(metrics);
            
            % Comparações estatísticas
            results.comparisons = analyzer.performComparisons(metrics, results.normalityTests);
            
            % Correção para múltiplas comparações
            results.correctedResults = analyzer.applyMultipleComparisonsCorrection(results.comparisons);
            
            % Cálculo de effect sizes
            results.effectSizes = analyzer.calculateEffectSizes(metrics);
            
            % Intervalos de confiança
            results.confidenceIntervals = analyzer.calculateConfidenceIntervals(metrics);
            
            % Interpretação automática
            results.interpretation = analyzer.interpretResults(results);
            
            % Resumo executivo
            results.summary = analyzer.generateSummary(results);
            
            if analyzer.verbose
                fprintf('Análise estatística concluída.\n');
                analyzer.printResults(results);
            end
        end
        
        function [pValue, effectSize, testUsed] = compareModels(metrics1, metrics2, config)
            % Compara dois conjuntos de métricas
            %
            % Inputs:
            %   metrics1, metrics2 - arrays com métricas dos modelos
            %   config - configurações (opcional)
            %
            % Outputs:
            %   pValue - valor p do teste
            %   effectSize - tamanho do efeito
            %   testUsed - nome do teste utilizado
            
            if nargin < 3
                config = struct();
            end
            
            analyzer = StatisticalAnalyzer(config);
            
            % Remover NaN
            valid1 = metrics1(~isnan(metrics1));
            valid2 = metrics2(~isnan(metrics2));
            
            if length(valid1) < 3 || length(valid2) < 3
                pValue = NaN;
                effectSize = NaN;
                testUsed = 'insufficient_data';
                return;
            end
            
            % Teste de normalidade
            isNormal1 = analyzer.testNormality(valid1);
            isNormal2 = analyzer.testNormality(valid2);
            
            % Escolher teste apropriado
            if isNormal1 && isNormal2
                % Teste t
                [~, pValue] = ttest2(valid1, valid2);
                testUsed = 'ttest2';
            else
                % Teste de Mann-Whitney U
                pValue = ranksum(valid1, valid2);
                testUsed = 'ranksum';
            end
            
            % Calcular effect size
            effectSize = analyzer.calculateCohenD(valid1, valid2);
        end
        
        function report = generateScientificReport(analysisResults, outputPath)
            % Gera relatório científico completo
            %
            % Inputs:
            %   analysisResults - resultados da análise estatística
            %   outputPath - caminho para salvar o relatório (opcional)
            %
            % Outputs:
            %   report - struct com o relatório formatado
            
            report = struct();
            report.title = 'Análise Estatística Comparativa: U-Net vs Attention U-Net';
            report.timestamp = datetime('now');
            
            % Seção de métodos
            report.methods = StatisticalAnalyzer.generateMethodsSection(analysisResults);
            
            % Seção de resultados
            report.results = StatisticalAnalyzer.generateResultsSection(analysisResults);
            
            % Seção de discussão
            report.discussion = StatisticalAnalyzer.generateDiscussionSection(analysisResults);
            
            % Tabelas e figuras
            report.tables = StatisticalAnalyzer.generateTables(analysisResults);
            
            % Salvar se caminho fornecido
            if nargin > 1 && ~isempty(outputPath)
                StatisticalAnalyzer.saveReport(report, outputPath);
            end
        end
    end
    
    methods
        function obj = StatisticalAnalyzer(config)
            % Construtor do StatisticalAnalyzer
            
            if nargin < 1
                config = struct();
            end
            
            % Configurações padrão
            obj.alpha = getfield_default(config, 'alpha', 0.05);
            obj.multipleComparisonsMethod = getfield_default(config, 'multipleComparisonsMethod', 'bonferroni');
            obj.effectSizeMethod = getfield_default(config, 'effectSizeMethod', 'cohen_d');
            obj.verbose = getfield_default(config, 'verbose', true);
            obj.confidenceLevel = getfield_default(config, 'confidenceLevel', 0.95);
            
            if obj.verbose
                fprintf('StatisticalAnalyzer inicializado.\n');
                fprintf('Nível de significância: %.3f\n', obj.alpha);
                fprintf('Método de correção: %s\n', obj.multipleComparisonsMethod);
            end
        end
        
        function isNormal = testNormality(obj, data)
            % Testa normalidade dos dados
            
            if length(data) < 3
                isNormal = false;
                return;
            end
            
            if length(data) <= 50
                % Shapiro-Wilk para amostras pequenas
                try
                    [~, pValue] = swtest(data);
                    isNormal = pValue > obj.alpha;
                catch
                    % Fallback para teste de Kolmogorov-Smirnov
                    [~, pValue] = kstest(zscore(data));
                    isNormal = pValue > obj.alpha;
                end
            else
                % Kolmogorov-Smirnov para amostras grandes
                [~, pValue] = kstest(zscore(data));
                isNormal = pValue > obj.alpha;
            end
        end
        
        function correctedPValues = applyMultipleComparisonsCorrection(obj, comparisons)
            % Aplica correção para múltiplas comparações
            
            % Extrair p-values
            pValues = [];
            testNames = {};
            
            fields = fieldnames(comparisons);
            for i = 1:length(fields)
                if isfield(comparisons.(fields{i}), 'pValue')
                    pValues(end+1) = comparisons.(fields{i}).pValue;
                    testNames{end+1} = fields{i};
                end
            end
            
            if isempty(pValues)
                correctedPValues = struct();
                return;
            end
            
            % Aplicar correção
            switch obj.multipleComparisonsMethod
                case 'bonferroni'
                    correctedP = pValues * length(pValues);
                    correctedP = min(correctedP, 1); % Limitar a 1
                    
                case 'fdr' % False Discovery Rate (Benjamini-Hochberg)
                    [~, sortIdx] = sort(pValues);
                    n = length(pValues);
                    correctedP = zeros(size(pValues));
                    
                    for i = 1:n
                        correctedP(sortIdx(i)) = pValues(sortIdx(i)) * n / i;
                    end
                    
                case 'holm'
                    [sortedP, sortIdx] = sort(pValues);
                    n = length(pValues);
                    correctedP = zeros(size(pValues));
                    
                    for i = 1:n
                        correctedP(sortIdx(i)) = sortedP(i) * (n - i + 1);
                    end
                    correctedP = min(correctedP, 1);
                    
                otherwise
                    correctedP = pValues; % Sem correção
            end
            
            % Organizar resultados
            correctedPValues = struct();
            correctedPValues.method = obj.multipleComparisonsMethod;
            correctedPValues.originalPValues = pValues;
            correctedPValues.correctedPValues = correctedP;
            correctedPValues.testNames = testNames;
            
            % Adicionar significância corrigida
            for i = 1:length(testNames)
                correctedPValues.(testNames{i}) = struct();
                correctedPValues.(testNames{i}).originalP = pValues(i);
                correctedPValues.(testNames{i}).correctedP = correctedP(i);
                correctedPValues.(testNames{i}).significant = correctedP(i) < obj.alpha;
            end
        end
        
        function interpretation = interpretResults(obj, statisticalResults)
            % Gera interpretação automática dos resultados
            
            interpretation = struct();
            interpretation.timestamp = datetime('now');
            
            % Interpretar comparações principais
            if isfield(statisticalResults, 'correctedResults')
                interpretation.mainFindings = obj.interpretMainFindings(statisticalResults.correctedResults);
            end
            
            % Interpretar effect sizes
            if isfield(statisticalResults, 'effectSizes')
                interpretation.effectSizeInterpretation = obj.interpretEffectSizes(statisticalResults.effectSizes);
            end
            
            % Recomendações
            interpretation.recommendations = obj.generateRecommendations(statisticalResults);
            
            % Limitações
            interpretation.limitations = obj.identifyLimitations(statisticalResults);
        end 
       
        function metrics = extractMetrics(obj, unetMetrics, attentionMetrics)
            % Extrai e organiza métricas para análise
            
            metrics = struct();
            
            % Extrair métricas do U-Net
            if isfield(unetMetrics, 'iou')
                if isfield(unetMetrics.iou, 'values')
                    metrics.unet_iou = unetMetrics.iou.values;
                else
                    metrics.unet_iou = unetMetrics.iou;
                end
            end
            
            if isfield(unetMetrics, 'dice')
                if isfield(unetMetrics.dice, 'values')
                    metrics.unet_dice = unetMetrics.dice.values;
                else
                    metrics.unet_dice = unetMetrics.dice;
                end
            end
            
            if isfield(unetMetrics, 'accuracy')
                if isfield(unetMetrics.accuracy, 'values')
                    metrics.unet_accuracy = unetMetrics.accuracy.values;
                else
                    metrics.unet_accuracy = unetMetrics.accuracy;
                end
            end
            
            % Extrair métricas do Attention U-Net
            if isfield(attentionMetrics, 'iou')
                if isfield(attentionMetrics.iou, 'values')
                    metrics.attention_iou = attentionMetrics.iou.values;
                else
                    metrics.attention_iou = attentionMetrics.iou;
                end
            end
            
            if isfield(attentionMetrics, 'dice')
                if isfield(attentionMetrics.dice, 'values')
                    metrics.attention_dice = attentionMetrics.dice.values;
                else
                    metrics.attention_dice = attentionMetrics.dice;
                end
            end
            
            if isfield(attentionMetrics, 'accuracy')
                if isfield(attentionMetrics.accuracy, 'values')
                    metrics.attention_accuracy = attentionMetrics.accuracy.values;
                else
                    metrics.attention_accuracy = attentionMetrics.accuracy;
                end
            end
        end
        
        function normalityResults = performNormalityTests(obj, metrics)
            % Realiza testes de normalidade para todas as métricas
            
            normalityResults = struct();
            
            metricNames = fieldnames(metrics);
            for i = 1:length(metricNames)
                metricName = metricNames{i};
                data = metrics.(metricName);
                
                if ~isempty(data) && sum(~isnan(data)) > 2
                    validData = data(~isnan(data));
                    
                    result = struct();
                    result.isNormal = obj.testNormality(validData);
                    result.sampleSize = length(validData);
                    result.mean = mean(validData);
                    result.std = std(validData);
                    result.skewness = skewness(validData);
                    result.kurtosis = kurtosis(validData);
                    
                    normalityResults.(metricName) = result;
                end
            end
        end
        
        function comparisons = performComparisons(obj, metrics, normalityTests)
            % Realiza comparações estatísticas entre modelos
            
            comparisons = struct();
            
            % Comparar IoU
            if isfield(metrics, 'unet_iou') && isfield(metrics, 'attention_iou')
                comparisons.iou = obj.compareMetrics(metrics.unet_iou, metrics.attention_iou, ...
                    normalityTests.unet_iou.isNormal && normalityTests.attention_iou.isNormal);
            end
            
            % Comparar Dice
            if isfield(metrics, 'unet_dice') && isfield(metrics, 'attention_dice')
                comparisons.dice = obj.compareMetrics(metrics.unet_dice, metrics.attention_dice, ...
                    normalityTests.unet_dice.isNormal && normalityTests.attention_dice.isNormal);
            end
            
            % Comparar Accuracy
            if isfield(metrics, 'unet_accuracy') && isfield(metrics, 'attention_accuracy')
                comparisons.accuracy = obj.compareMetrics(metrics.unet_accuracy, metrics.attention_accuracy, ...
                    normalityTests.unet_accuracy.isNormal && normalityTests.attention_accuracy.isNormal);
            end
        end
        
        function result = compareMetrics(obj, data1, data2, bothNormal)
            % Compara duas métricas usando teste apropriado
            
            % Remover NaN
            valid1 = data1(~isnan(data1));
            valid2 = data2(~isnan(data2));
            
            result = struct();
            result.n1 = length(valid1);
            result.n2 = length(valid2);
            result.mean1 = mean(valid1);
            result.mean2 = mean(valid2);
            result.std1 = std(valid1);
            result.std2 = std(valid2);
            
            if length(valid1) < 3 || length(valid2) < 3
                result.pValue = NaN;
                result.testUsed = 'insufficient_data';
                result.significant = false;
                return;
            end
            
            % Escolher e executar teste
            if bothNormal
                % Teste t de Student
                [~, result.pValue] = ttest2(valid1, valid2);
                result.testUsed = 'ttest2';
                
                % Teste de Levene para igualdade de variâncias
                result.equalVariances = obj.testEqualVariances(valid1, valid2);
            else
                % Teste de Mann-Whitney U (Wilcoxon rank-sum)
                result.pValue = ranksum(valid1, valid2);
                result.testUsed = 'ranksum';
                result.equalVariances = NaN;
            end
            
            result.significant = result.pValue < obj.alpha;
        end
        
        function effectSizes = calculateEffectSizes(obj, metrics)
            % Calcula tamanhos de efeito para todas as comparações
            
            effectSizes = struct();
            
            % Effect size para IoU
            if isfield(metrics, 'unet_iou') && isfield(metrics, 'attention_iou')
                effectSizes.iou = obj.calculateCohenD(metrics.unet_iou, metrics.attention_iou);
            end
            
            % Effect size para Dice
            if isfield(metrics, 'unet_dice') && isfield(metrics, 'attention_dice')
                effectSizes.dice = obj.calculateCohenD(metrics.unet_dice, metrics.attention_dice);
            end
            
            % Effect size para Accuracy
            if isfield(metrics, 'unet_accuracy') && isfield(metrics, 'attention_accuracy')
                effectSizes.accuracy = obj.calculateCohenD(metrics.unet_accuracy, metrics.attention_accuracy);
            end
        end
        
        function cohenD = calculateCohenD(obj, group1, group2)
            % Calcula Cohen's d como medida de effect size
            
            % Remover NaN
            valid1 = group1(~isnan(group1));
            valid2 = group2(~isnan(group2));
            
            if length(valid1) < 2 || length(valid2) < 2
                cohenD = NaN;
                return;
            end
            
            % Calcular médias
            mean1 = mean(valid1);
            mean2 = mean(valid2);
            
            % Calcular desvio padrão pooled
            n1 = length(valid1);
            n2 = length(valid2);
            
            pooledStd = sqrt(((n1-1)*var(valid1) + (n2-1)*var(valid2)) / (n1+n2-2));
            
            % Cohen's d
            cohenD = (mean1 - mean2) / pooledStd;
        end
        
        function intervals = calculateConfidenceIntervals(obj, metrics)
            % Calcula intervalos de confiança para as métricas
            
            intervals = struct();
            alpha = 1 - obj.confidenceLevel;
            
            metricNames = fieldnames(metrics);
            for i = 1:length(metricNames)
                metricName = metricNames{i};
                data = metrics.(metricName);
                
                if ~isempty(data) && sum(~isnan(data)) > 1
                    validData = data(~isnan(data));
                    n = length(validData);
                    
                    meanVal = mean(validData);
                    stdVal = std(validData);
                    
                    % Intervalo de confiança para a média
                    tCrit = tinv(1 - alpha/2, n-1);
                    margin = tCrit * stdVal / sqrt(n);
                    
                    intervals.(metricName) = struct();
                    intervals.(metricName).mean = meanVal;
                    intervals.(metricName).lower = meanVal - margin;
                    intervals.(metricName).upper = meanVal + margin;
                    intervals.(metricName).margin = margin;
                end
            end
        end
        
        function equalVar = testEqualVariances(obj, data1, data2)
            % Testa igualdade de variâncias (teste de Levene simplificado)
            
            % Usar teste F simples
            var1 = var(data1);
            var2 = var(data2);
            
            if var1 == 0 && var2 == 0
                equalVar = true;
                return;
            end
            
            fStat = max(var1, var2) / min(var1, var2);
            
            % Graus de liberdade
            df1 = length(data1) - 1;
            df2 = length(data2) - 1;
            
            % Valor crítico F
            fCrit = finv(1 - obj.alpha/2, df1, df2);
            
            equalVar = fStat < fCrit;
        end
        
        function findings = interpretMainFindings(obj, correctedResults)
            % Interpreta os principais achados
            
            findings = {};
            
            metrics = {'iou', 'dice', 'accuracy'};
            metricNames = {'IoU', 'Dice Coefficient', 'Accuracy'};
            
            for i = 1:length(metrics)
                metric = metrics{i};
                metricName = metricNames{i};
                
                if isfield(correctedResults, metric)
                    result = correctedResults.(metric);
                    
                    if result.significant
                        findings{end+1} = sprintf('Diferença significativa encontrada para %s (p = %.4f)', ...
                            metricName, result.correctedP);
                    else
                        findings{end+1} = sprintf('Não há diferença significativa para %s (p = %.4f)', ...
                            metricName, result.correctedP);
                    end
                end
            end
        end
        
        function interpretation = interpretEffectSizes(obj, effectSizes)
            % Interpreta os tamanhos de efeito
            
            interpretation = {};
            
            metrics = fieldnames(effectSizes);
            for i = 1:length(metrics)
                metric = metrics{i};
                cohenD = effectSizes.(metric);
                
                if ~isnan(cohenD)
                    absD = abs(cohenD);
                    
                    if absD < 0.2
                        magnitude = 'desprezível';
                    elseif absD < 0.5
                        magnitude = 'pequeno';
                    elseif absD < 0.8
                        magnitude = 'médio';
                    else
                        magnitude = 'grande';
                    end
                    
                    direction = '';
                    if cohenD > 0
                        direction = ' (favorável ao U-Net)';
                    elseif cohenD < 0
                        direction = ' (favorável ao Attention U-Net)';
                    end
                    
                    interpretation{end+1} = sprintf('%s: Effect size %s (d = %.3f)%s', ...
                        upper(metric), magnitude, cohenD, direction);
                end
            end
        end
        
        function recommendations = generateRecommendations(obj, results)
            % Gera recomendações baseadas nos resultados
            
            recommendations = {};
            
            % Analisar significância geral
            significantTests = 0;
            totalTests = 0;
            
            if isfield(results, 'correctedResults')
                fields = fieldnames(results.correctedResults);
                for i = 1:length(fields)
                    if isfield(results.correctedResults.(fields{i}), 'significant')
                        totalTests = totalTests + 1;
                        if results.correctedResults.(fields{i}).significant
                            significantTests = significantTests + 1;
                        end
                    end
                end
            end
            
            if significantTests == 0
                recommendations{end+1} = 'Não foram encontradas diferenças significativas entre os modelos.';
                recommendations{end+1} = 'Considere aumentar o tamanho da amostra ou usar métricas mais sensíveis.';
            elseif significantTests == totalTests
                recommendations{end+1} = 'Diferenças significativas foram encontradas em todas as métricas.';
                recommendations{end+1} = 'Recomenda-se escolher o modelo com melhor performance geral.';
            else
                recommendations{end+1} = sprintf('Diferenças significativas em %d de %d métricas.', ...
                    significantTests, totalTests);
                recommendations{end+1} = 'Considere o contexto específico da aplicação para escolha do modelo.';
            end
        end
        
        function limitations = identifyLimitations(obj, results)
            % Identifica limitações da análise
            
            limitations = {};
            
            % Verificar tamanho da amostra
            if isfield(results, 'metrics')
                minSampleSize = inf;
                fields = fieldnames(results.metrics);
                
                for i = 1:length(fields)
                    data = results.metrics.(fields{i});
                    validData = data(~isnan(data));
                    minSampleSize = min(minSampleSize, length(validData));
                end
                
                if minSampleSize < 30
                    limitations{end+1} = sprintf('Tamanho de amostra pequeno (n = %d). Resultados devem ser interpretados com cautela.', minSampleSize);
                end
            end
            
            % Verificar normalidade
            if isfield(results, 'normalityTests')
                nonNormalCount = 0;
                totalTests = 0;
                
                fields = fieldnames(results.normalityTests);
                for i = 1:length(fields)
                    totalTests = totalTests + 1;
                    if ~results.normalityTests.(fields{i}).isNormal
                        nonNormalCount = nonNormalCount + 1;
                    end
                end
                
                if nonNormalCount > 0
                    limitations{end+1} = sprintf('%d de %d distribuições não são normais. Testes não-paramétricos foram utilizados quando apropriado.', ...
                        nonNormalCount, totalTests);
                end
            end
        end
        
        function printResults(obj, results)
            % Imprime resumo dos resultados
            
            fprintf('\n=== Resultados da Análise Estatística ===\n');
            
            if isfield(results, 'summary')
                fprintf('%s\n', results.summary);
            end
            
            if isfield(results, 'interpretation') && isfield(results.interpretation, 'mainFindings')
                fprintf('\nPrincipais Achados:\n');
                for i = 1:length(results.interpretation.mainFindings)
                    fprintf('  • %s\n', results.interpretation.mainFindings{i});
                end
            end
            
            if isfield(results, 'interpretation') && isfield(results.interpretation, 'recommendations')
                fprintf('\nRecomendações:\n');
                for i = 1:length(results.interpretation.recommendations)
                    fprintf('  • %s\n', results.interpretation.recommendations{i});
                end
            end
            
            fprintf('========================================\n\n');
        end
        
        function summary = generateSummary(obj, results)
            % Gera resumo executivo
            
            summary = 'Análise estatística comparativa entre U-Net e Attention U-Net concluída. ';
            
            if isfield(results, 'correctedResults')
                significantCount = 0;
                totalCount = 0;
                
                fields = fieldnames(results.correctedResults);
                for i = 1:length(fields)
                    if isfield(results.correctedResults.(fields{i}), 'significant')
                        totalCount = totalCount + 1;
                        if results.correctedResults.(fields{i}).significant
                            significantCount = significantCount + 1;
                        end
                    end
                end
                
                summary = [summary sprintf('Foram encontradas diferenças significativas em %d de %d métricas analisadas.', ...
                    significantCount, totalCount)];
            end
        end
    end
    
    methods (Static)
        function methodsSection = generateMethodsSection(results)
            methodsSection = 'Análise estatística realizada utilizando testes paramétricos e não-paramétricos conforme apropriado, com correção para múltiplas comparações.';
        end
        
        function resultsSection = generateResultsSection(results)
            resultsSection = 'Resultados detalhados disponíveis na estrutura de dados retornada.';
        end
        
        function discussionSection = generateDiscussionSection(results)
            discussionSection = 'Discussão baseada nos achados estatísticos e tamanhos de efeito observados.';
        end
        
        function tables = generateTables(results)
            tables = struct();
            tables.summary = 'Tabelas de resumo podem ser geradas a partir dos resultados.';
        end
        
        function saveReport(report, outputPath)
            save(outputPath, 'report');
            fprintf('Relatório salvo em: %s\n', outputPath);
        end
    end

end

function value = getfield_default(s, field, default)
    % Função auxiliar para obter campo com valor padrão
    if isfield(s, field)
        value = s.(field);
    else
        value = default;
    end
end