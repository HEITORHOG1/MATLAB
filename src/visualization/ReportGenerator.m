classdef ReportGenerator < handle
    % ========================================================================
    % REPORTGENERATOR - SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe para geração automática de relatórios comparativos com
    %   interpretação automática de resultados e recomendações baseadas
    %   nos dados obtidos.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Report Generation
    %   - Data Visualization
    %   - Statistical Analysis
    %
    % USO:
    %   >> generator = ReportGenerator();
    %   >> generator.generateComparisonReport(results);
    %   >> generator.generateAutomaticInterpretation(results);
    %
    % REQUISITOS: 1.4, 1.5
    % ========================================================================
    
    properties (Access = private)
        logger
        outputDir = 'output/reports'
        templateDir = 'templates'
        
        % Configurações de relatório
        includeVisualizations = true
        includeStatisticalAnalysis = true
        includeRecommendations = true
        includeExecutionDetails = true
        
        % Formatação
        reportFormat = 'text' % 'text', 'html', 'pdf'
        figureFormat = 'png'
        figureResolution = 300
        
        % Templates de interpretação
        interpretationTemplates = struct()
        recommendationRules = struct()
    end
    
    properties (Constant)
        SUPPORTED_FORMATS = {'text', 'html', 'pdf'}
        CONFIDENCE_LEVELS = {'muito_alta', 'alta', 'media', 'baixa', 'muito_baixa'}
        PERFORMANCE_CATEGORIES = {'excelente', 'boa', 'regular', 'ruim', 'muito_ruim'}
    end 
   
    methods
        function obj = ReportGenerator(varargin)
            % Construtor da classe ReportGenerator
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'OutputDir' - diretório de saída (padrão: 'output/reports')
            %     'ReportFormat' - formato do relatório (padrão: 'text')
            %     'IncludeVisualizations' - incluir visualizações (padrão: true)
            %     'IncludeRecommendations' - incluir recomendações (padrão: true)
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'OutputDir', 'output/reports', @ischar);
            addParameter(p, 'ReportFormat', 'text', @(x) ismember(x, obj.SUPPORTED_FORMATS));
            addParameter(p, 'IncludeVisualizations', true, @islogical);
            addParameter(p, 'IncludeRecommendations', true, @islogical);
            parse(p, varargin{:});
            
            obj.outputDir = p.Results.OutputDir;
            obj.reportFormat = p.Results.ReportFormat;
            obj.includeVisualizations = p.Results.IncludeVisualizations;
            obj.includeRecommendations = p.Results.IncludeRecommendations;
            
            % Inicializar componentes
            obj.initializeLogger();
            obj.initializeOutputDirectory();
            obj.initializeInterpretationTemplates();
            obj.initializeRecommendationRules();
            
            obj.logger('info', 'ReportGenerator inicializado');
            obj.logger('info', sprintf('Formato: %s, Saída: %s', obj.reportFormat, obj.outputDir));
        end
        
        function reportPath = generateComparisonReport(obj, results, varargin)
            % Gera relatório completo de comparação
            %
            % ENTRADA:
            %   results - estrutura com resultados da comparação
            %   varargin - parâmetros opcionais:
            %     'Title' - título do relatório (padrão: auto)
            %     'IncludeRawData' - incluir dados brutos (padrão: false)
            %
            % SAÍDA:
            %   reportPath - caminho para o relatório gerado
            %
            % REQUISITOS: 1.4 (geração automática de relatórios comparativos)
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Title', '', @ischar);
            addParameter(p, 'IncludeRawData', false, @islogical);
            parse(p, varargin{:});
            
            title = p.Results.Title;
            includeRawData = p.Results.IncludeRawData;
            
            if isempty(title)
                title = sprintf('Relatório de Comparação U-Net vs Attention U-Net - %s', ...
                    datestr(now, 'dd/mm/yyyy HH:MM'));
            end
            
            obj.logger('info', '📄 Gerando relatório de comparação...');
            
            try
                % Validar resultados
                if ~obj.validateResults(results)
                    error('Resultados inválidos para geração de relatório');
                end
                
                % Gerar interpretação automática
                interpretation = obj.generateAutomaticInterpretation(results);
                
                % Gerar recomendações
                recommendations = obj.generateRecommendations(results, interpretation);
                
                % Criar estrutura do relatório
                report = obj.createReportStructure(results, interpretation, recommendations, title);
                
                % Gerar visualizações se habilitado
                if obj.includeVisualizations
                    report.visualizations = obj.generateVisualizations(results);
                end
                
                % Incluir dados brutos se solicitado
                if includeRawData
                    report.rawData = results;
                end
                
                % Gerar arquivo de relatório
                reportPath = obj.writeReport(report);
                
                obj.logger('success', sprintf('Relatório gerado: %s', reportPath));
                
            catch ME
                obj.logger('error', sprintf('Erro ao gerar relatório: %s', ME.message));
                reportPath = '';
                rethrow(ME);
            end
        end
        
        function interpretation = generateAutomaticInterpretation(obj, results)
            % Gera interpretação automática dos resultados
            %
            % ENTRADA:
            %   results - estrutura com resultados da comparação
            %
            % SAÍDA:
            %   interpretation - estrutura com interpretação automática
            %
            % REQUISITOS: 1.5 (interpretação automática de resultados)
            
            obj.logger('info', '🤖 Gerando interpretação automática...');
            
            try
                interpretation = struct();
                
                % Análise de performance geral
                interpretation.performance = obj.analyzeOverallPerformance(results);
                
                % Análise estatística
                if isfield(results, 'statistical')
                    interpretation.statistical = obj.interpretStatisticalResults(results.statistical);
                end
                
                % Análise de significância
                interpretation.significance = obj.analyzeSignificance(results);
                
                % Análise de confiabilidade
                interpretation.reliability = obj.analyzeReliability(results);
                
                % Determinar modelo vencedor com confiança
                interpretation.winner = obj.determineWinnerWithConfidence(results);
                
                % Gerar resumo executivo
                interpretation.executiveSummary = obj.generateExecutiveSummary(interpretation);
                
                % Identificar pontos fortes e fracos
                interpretation.strengths = obj.identifyStrengths(results);
                interpretation.weaknesses = obj.identifyWeaknesses(results);
                
                obj.logger('success', 'Interpretação automática gerada');
                
            catch ME
                obj.logger('error', sprintf('Erro na interpretação: %s', ME.message));
                interpretation = struct('error', ME.message);
            end
        end
        
        function recommendations = generateRecommendations(obj, results, interpretation)
            % Gera recomendações baseadas nos resultados
            %
            % ENTRADA:
            %   results - estrutura com resultados
            %   interpretation - interpretação automática
            %
            % SAÍDA:
            %   recommendations - estrutura com recomendações
            %
            % REQUISITOS: 1.5 (recomendações baseadas nos resultados)
            
            obj.logger('info', '💡 Gerando recomendações...');
            
            try
                recommendations = struct();
                
                % Recomendações de modelo
                recommendations.modelChoice = obj.recommendModelChoice(results, interpretation);
                
                % Recomendações técnicas
                recommendations.technical = obj.generateTechnicalRecommendations(results);
                
                % Recomendações de melhoria
                recommendations.improvements = obj.generateImprovementRecommendations(results, interpretation);
                
                % Recomendações de uso
                recommendations.usage = obj.generateUsageRecommendations(results, interpretation);
                
                % Próximos passos
                recommendations.nextSteps = obj.generateNextSteps(results, interpretation);
                
                % Priorizar recomendações
                recommendations.prioritized = obj.prioritizeRecommendations(recommendations);
                
                obj.logger('success', 'Recomendações geradas');
                
            catch ME
                obj.logger('error', sprintf('Erro ao gerar recomendações: %s', ME.message));
                recommendations = struct('error', ME.message);
            end
        end    
    
        function visualizations = generateVisualizations(obj, results)
            % Gera visualizações para o relatório
            %
            % ENTRADA:
            %   results - estrutura com resultados
            %
            % SAÍDA:
            %   visualizations - estrutura com caminhos das visualizações
            
            obj.logger('info', '📊 Gerando visualizações...');
            
            visualizations = struct();
            
            try
                % Criar diretório de visualizações
                vizDir = fullfile(obj.outputDir, 'visualizations');
                if ~exist(vizDir, 'dir')
                    mkdir(vizDir);
                end
                
                % Gráfico de comparação de métricas
                visualizations.metricsComparison = obj.createMetricsComparisonChart(results, vizDir);
                
                % Gráfico de distribuição de métricas
                visualizations.metricsDistribution = obj.createMetricsDistributionChart(results, vizDir);
                
                % Gráfico de significância estatística
                if isfield(results, 'statistical')
                    visualizations.statisticalSignificance = obj.createStatisticalChart(results, vizDir);
                end
                
                % Gráfico de barras de erro
                visualizations.errorBars = obj.createErrorBarsChart(results, vizDir);
                
                % Heatmap de correlação (se dados suficientes)
                if obj.hasEnoughDataForCorrelation(results)
                    visualizations.correlationHeatmap = obj.createCorrelationHeatmap(results, vizDir);
                end
                
                obj.logger('success', 'Visualizações geradas');
                
            catch ME
                obj.logger('warning', sprintf('Erro ao gerar visualizações: %s', ME.message));
                visualizations.error = ME.message;
            end
        end
        
        function summary = generateExecutiveSummary(obj, interpretation)
            % Gera resumo executivo da interpretação
            %
            % ENTRADA:
            %   interpretation - estrutura com interpretação
            %
            % SAÍDA:
            %   summary - string com resumo executivo
            
            try
                summary = '';
                
                % Resultado principal
                if isfield(interpretation, 'winner')
                    summary = [summary sprintf('RESULTADO PRINCIPAL: %s demonstrou melhor performance ', ...
                        interpretation.winner.model)];
                    
                    switch interpretation.winner.confidence
                        case 'muito_alta'
                            summary = [summary 'com confiança muito alta.\n\n'];
                        case 'alta'
                            summary = [summary 'com alta confiança.\n\n'];
                        case 'media'
                            summary = [summary 'com confiança moderada.\n\n'];
                        case 'baixa'
                            summary = [summary 'com baixa confiança.\n\n'];
                        otherwise
                            summary = [summary 'mas com confiança limitada.\n\n'];
                    end
                end
                
                % Performance geral
                if isfield(interpretation, 'performance')
                    summary = [summary sprintf('PERFORMANCE GERAL: %s\n\n', ...
                        interpretation.performance.overall)];
                end
                
                % Significância estatística
                if isfield(interpretation, 'significance')
                    if interpretation.significance.hasSignificantDifferences
                        summary = [summary sprintf('SIGNIFICÂNCIA: Diferenças estatisticamente significativas ' ...
                            'detectadas em %d de %d métricas.\n\n', ...
                            interpretation.significance.significantMetrics, ...
                            interpretation.significance.totalMetrics)];
                    else
                        summary = [summary 'SIGNIFICÂNCIA: Não foram detectadas diferenças ' ...
                            'estatisticamente significativas.\n\n'];
                    end
                end
                
                % Recomendação principal
                summary = [summary 'RECOMENDAÇÃO: '];
                if isfield(interpretation, 'winner')
                    if strcmp(interpretation.winner.confidence, 'alta') || ...
                       strcmp(interpretation.winner.confidence, 'muito_alta')
                        summary = [summary sprintf('Use %s para este tipo de aplicação.\n', ...
                            interpretation.winner.model)];
                    else
                        summary = [summary 'Considere testes adicionais antes da decisão final.\n'];
                    end
                end
                
            catch ME
                summary = sprintf('Erro ao gerar resumo: %s', ME.message);
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
            
            fprintf('[%s] %s [ReportGenerator] %s\n', timestamp, prefix, message);
        end
        
        function initializeOutputDirectory(obj)
            % Inicializa diretório de saída
            if ~exist(obj.outputDir, 'dir')
                mkdir(obj.outputDir);
                obj.logger('info', sprintf('Diretório criado: %s', obj.outputDir));
            end
        end  
      
        function initializeInterpretationTemplates(obj)
            % Inicializa templates de interpretação
            
            obj.interpretationTemplates = struct();
            
            % Templates para performance
            obj.interpretationTemplates.performance = containers.Map();
            obj.interpretationTemplates.performance('excelente') = 'Performance excelente (>0.90)';
            obj.interpretationTemplates.performance('boa') = 'Boa performance (0.80-0.90)';
            obj.interpretationTemplates.performance('regular') = 'Performance regular (0.70-0.80)';
            obj.interpretationTemplates.performance('ruim') = 'Performance ruim (0.60-0.70)';
            obj.interpretationTemplates.performance('muito_ruim') = 'Performance muito ruim (<0.60)';
            
            % Templates para confiança
            obj.interpretationTemplates.confidence = containers.Map();
            obj.interpretationTemplates.confidence('muito_alta') = 'Confiança muito alta (p<0.001)';
            obj.interpretationTemplates.confidence('alta') = 'Alta confiança (p<0.01)';
            obj.interpretationTemplates.confidence('media') = 'Confiança moderada (p<0.05)';
            obj.interpretationTemplates.confidence('baixa') = 'Baixa confiança (p<0.10)';
            obj.interpretationTemplates.confidence('muito_baixa') = 'Confiança muito baixa (p≥0.10)';
        end
        
        function initializeRecommendationRules(obj)
            % Inicializa regras para recomendações
            
            obj.recommendationRules = struct();
            
            % Regras para escolha de modelo
            obj.recommendationRules.modelChoice = {
                struct('condition', @(r) obj.hasHighConfidenceWinner(r), ...
                       'recommendation', 'Use o modelo vencedor com confiança');
                struct('condition', @(r) obj.hasLowConfidenceWinner(r), ...
                       'recommendation', 'Considere testes adicionais');
                struct('condition', @(r) obj.hasNoSignificantDifference(r), ...
                       'recommendation', 'Escolha baseada em outros critérios (velocidade, simplicidade)')
            };
            
            % Regras técnicas
            obj.recommendationRules.technical = {
                struct('condition', @(r) obj.hasMemoryIssues(r), ...
                       'recommendation', 'Considere otimizações de memória');
                struct('condition', @(r) obj.hasGPUAvailable(r), ...
                       'recommendation', 'Aproveite aceleração GPU');
                struct('condition', @(r) obj.hasLargeDataset(r), ...
                       'recommendation', 'Implemente data augmentation')
            };
        end
        
        function isValid = validateResults(obj, results)
            % Valida estrutura de resultados
            
            isValid = false;
            
            try
                % Verificar campos obrigatórios
                if ~isstruct(results)
                    obj.logger('error', 'Resultados devem ser uma estrutura');
                    return;
                end
                
                % Verificar se há dados de modelos
                if ~isfield(results, 'models')
                    obj.logger('error', 'Resultados devem conter campo "models"');
                    return;
                end
                
                % Verificar se há métricas
                if isfield(results.models, 'unet') && isfield(results.models, 'attentionUnet')
                    if isfield(results.models.unet, 'metrics') && ...
                       isfield(results.models.attentionUnet, 'metrics')
                        isValid = true;
                    end
                end
                
                if ~isValid
                    obj.logger('error', 'Estrutura de resultados inválida');
                end
                
            catch ME
                obj.logger('error', sprintf('Erro na validação: %s', ME.message));
            end
        end
        
        function performance = analyzeOverallPerformance(obj, results)
            % Analisa performance geral dos modelos
            
            performance = struct();
            
            try
                if isfield(results.models, 'unet') && isfield(results.models.unet, 'metrics')
                    unetMetrics = results.models.unet.metrics;
                    unetAvg = mean([unetMetrics.iou.mean, unetMetrics.dice.mean, unetMetrics.accuracy.mean]);
                    performance.unet = obj.categorizePerformance(unetAvg);
                end
                
                if isfield(results.models, 'attentionUnet') && isfield(results.models.attentionUnet, 'metrics')
                    attentionMetrics = results.models.attentionUnet.metrics;
                    attentionAvg = mean([attentionMetrics.iou.mean, attentionMetrics.dice.mean, attentionMetrics.accuracy.mean]);
                    performance.attentionUnet = obj.categorizePerformance(attentionAvg);
                end
                
                % Performance geral
                if isfield(performance, 'unet') && isfield(performance, 'attentionUnet')
                    if strcmp(performance.unet.category, performance.attentionUnet.category)
                        performance.overall = sprintf('Ambos os modelos apresentaram %s', performance.unet.category);
                    else
                        performance.overall = sprintf('Performance variada: U-Net %s, Attention U-Net %s', ...
                            performance.unet.category, performance.attentionUnet.category);
                    end
                end
                
            catch ME
                performance.error = ME.message;
            end
        end
        
        function category = categorizePerformance(obj, avgScore)
            % Categoriza performance baseada na pontuação média
            
            category = struct();
            category.score = avgScore;
            
            if avgScore >= 0.90
                category.category = 'excelente';
                category.description = obj.interpretationTemplates.performance('excelente');
            elseif avgScore >= 0.80
                category.category = 'boa';
                category.description = obj.interpretationTemplates.performance('boa');
            elseif avgScore >= 0.70
                category.category = 'regular';
                category.description = obj.interpretationTemplates.performance('regular');
            elseif avgScore >= 0.60
                category.category = 'ruim';
                category.description = obj.interpretationTemplates.performance('ruim');
            else
                category.category = 'muito_ruim';
                category.description = obj.interpretationTemplates.performance('muito_ruim');
            end
        end
        
        function statistical = interpretStatisticalResults(obj, statisticalResults)
            % Interpreta resultados estatísticos
            
            statistical = struct();
            
            try
                metrics = {'iou', 'dice', 'accuracy'};
                statistical.interpretations = struct();
                
                for i = 1:length(metrics)
                    metric = metrics{i};
                    if isfield(statisticalResults, metric)
                        result = statisticalResults.(metric);
                        statistical.interpretations.(metric) = obj.interpretSingleStatistic(result, metric);
                    end
                end
                
                % Resumo geral
                significantCount = 0;
                totalCount = length(metrics);
                
                for i = 1:length(metrics)
                    metric = metrics{i};
                    if isfield(statistical.interpretations, metric) && ...
                       statistical.interpretations.(metric).significant
                        significantCount = significantCount + 1;
                    end
                end
                
                statistical.summary = sprintf('%d de %d métricas mostram diferenças significativas', ...
                    significantCount, totalCount);
                
            catch ME
                statistical.error = ME.message;
            end
        end
        
        function interpretation = interpretSingleStatistic(obj, result, metricName)
            % Interpreta resultado estatístico individual
            
            interpretation = struct();
            interpretation.metric = metricName;
            interpretation.significant = result.significant;
            interpretation.pValue = result.pValue;
            interpretation.effectSize = result.effectSize;
            
            % Interpretar p-value
            if result.pValue < 0.001
                interpretation.confidenceLevel = 'muito_alta';
            elseif result.pValue < 0.01
                interpretation.confidenceLevel = 'alta';
            elseif result.pValue < 0.05
                interpretation.confidenceLevel = 'media';
            elseif result.pValue < 0.10
                interpretation.confidenceLevel = 'baixa';
            else
                interpretation.confidenceLevel = 'muito_baixa';
            end
            
            % Interpretar effect size
            if result.effectSize < 0.2
                interpretation.effectMagnitude = 'pequeno';
            elseif result.effectSize < 0.5
                interpretation.effectMagnitude = 'medio';
            elseif result.effectSize < 0.8
                interpretation.effectMagnitude = 'grande';
            else
                interpretation.effectMagnitude = 'muito_grande';
            end
            
            % Gerar interpretação textual
            if result.significant
                interpretation.text = sprintf('Diferença significativa em %s (p=%.4f, efeito %s)', ...
                    metricName, result.pValue, interpretation.effectMagnitude);
            else
                interpretation.text = sprintf('Sem diferença significativa em %s (p=%.4f)', ...
                    metricName, result.pValue);
            end
        end        
 
       function significance = analyzeSignificance(obj, results)
            % Analisa significância estatística geral
            
            significance = struct();
            
            try
                significance.hasSignificantDifferences = false;
                significance.significantMetrics = 0;
                significance.totalMetrics = 0;
                
                if isfield(results, 'statistical')
                    metrics = fieldnames(results.statistical);
                    significance.totalMetrics = length(metrics);
                    
                    for i = 1:length(metrics)
                        metric = metrics{i};
                        if isfield(results.statistical.(metric), 'significant') && ...
                           results.statistical.(metric).significant
                            significance.significantMetrics = significance.significantMetrics + 1;
                        end
                    end
                    
                    significance.hasSignificantDifferences = significance.significantMetrics > 0;
                    significance.significanceRatio = significance.significantMetrics / significance.totalMetrics;
                end
                
            catch ME
                significance.error = ME.message;
            end
        end
        
        function reliability = analyzeReliability(obj, results)
            % Analisa confiabilidade dos resultados
            
            reliability = struct();
            
            try
                % Verificar tamanho da amostra
                if isfield(results.models, 'unet') && isfield(results.models.unet.metrics, 'numSamples')
                    sampleSize = results.models.unet.metrics.numSamples;
                    
                    if sampleSize >= 100
                        reliability.sampleSize = 'adequado';
                    elseif sampleSize >= 50
                        reliability.sampleSize = 'moderado';
                    else
                        reliability.sampleSize = 'pequeno';
                    end
                    
                    reliability.numSamples = sampleSize;
                end
                
                % Verificar consistência das métricas
                reliability.consistency = obj.analyzeMetricsConsistency(results);
                
                % Verificar se foi teste rápido
                if isfield(results, 'execution') && isfield(results.execution, 'quickTest')
                    reliability.quickTest = results.execution.quickTest.enabled;
                    if reliability.quickTest
                        reliability.warning = 'Resultados baseados em teste rápido - validação completa recomendada';
                    end
                end
                
                % Calcular score de confiabilidade geral
                reliability.overallScore = obj.calculateReliabilityScore(reliability);
                
            catch ME
                reliability.error = ME.message;
            end
        end
        
        function winner = determineWinnerWithConfidence(obj, results)
            % Determina vencedor com nível de confiança
            
            winner = struct();
            
            try
                if isfield(results, 'comparison') && isfield(results.comparison, 'winner')
                    winner.model = results.comparison.winner;
                    
                    % Determinar confiança baseada em múltiplos fatores
                    confidenceFactors = [];
                    
                    % Fator 1: Significância estatística
                    if isfield(results, 'statistical')
                        significance = obj.analyzeSignificance(results);
                        if significance.significanceRatio >= 0.67  % 2/3 das métricas
                            confidenceFactors(end+1) = 0.9;
                        elseif significance.significanceRatio >= 0.33  % 1/3 das métricas
                            confidenceFactors(end+1) = 0.6;
                        else
                            confidenceFactors(end+1) = 0.3;
                        end
                    end
                    
                    % Fator 2: Magnitude da diferença
                    if isfield(results.models, 'unet') && isfield(results.models, 'attentionUnet')
                        unetAvg = obj.calculateAverageMetrics(results.models.unet.metrics);
                        attentionAvg = obj.calculateAverageMetrics(results.models.attentionUnet.metrics);
                        
                        difference = abs(unetAvg - attentionAvg);
                        if difference >= 0.1
                            confidenceFactors(end+1) = 0.9;
                        elseif difference >= 0.05
                            confidenceFactors(end+1) = 0.7;
                        else
                            confidenceFactors(end+1) = 0.4;
                        end
                    end
                    
                    % Fator 3: Consistência entre métricas
                    consistency = obj.analyzeWinnerConsistency(results);
                    confidenceFactors(end+1) = consistency;
                    
                    % Calcular confiança final
                    if ~isempty(confidenceFactors)
                        avgConfidence = mean(confidenceFactors);
                        winner.confidenceScore = avgConfidence;
                        winner.confidence = obj.categorizeConfidence(avgConfidence);
                    else
                        winner.confidence = 'baixa';
                        winner.confidenceScore = 0.3;
                    end
                    
                    % Gerar explicação
                    winner.explanation = obj.generateWinnerExplanation(winner, results);
                    
                else
                    winner.model = 'Indeterminado';
                    winner.confidence = 'muito_baixa';
                    winner.explanation = 'Não foi possível determinar um vencedor claro';
                end
                
            catch ME
                winner.error = ME.message;
            end
        end
        
        function avgMetrics = calculateAverageMetrics(obj, metrics)
            % Calcula média das métricas
            
            try
                values = [];
                if isfield(metrics, 'iou') && isfield(metrics.iou, 'mean')
                    values(end+1) = metrics.iou.mean;
                end
                if isfield(metrics, 'dice') && isfield(metrics.dice, 'mean')
                    values(end+1) = metrics.dice.mean;
                end
                if isfield(metrics, 'accuracy') && isfield(metrics.accuracy, 'mean')
                    values(end+1) = metrics.accuracy.mean;
                end
                
                if ~isempty(values)
                    avgMetrics = mean(values);
                else
                    avgMetrics = 0;
                end
                
            catch
                avgMetrics = 0;
            end
        end
        
        function confidence = categorizeConfidence(obj, score)
            % Categoriza nível de confiança
            
            if score >= 0.9
                confidence = 'muito_alta';
            elseif score >= 0.7
                confidence = 'alta';
            elseif score >= 0.5
                confidence = 'media';
            elseif score >= 0.3
                confidence = 'baixa';
            else
                confidence = 'muito_baixa';
            end
        end
        
        function report = createReportStructure(obj, results, interpretation, recommendations, title)
            % Cria estrutura do relatório
            
            report = struct();
            report.title = title;
            report.timestamp = datestr(now);
            report.results = results;
            report.interpretation = interpretation;
            report.recommendations = recommendations;
            
            % Metadados
            report.metadata = struct();
            report.metadata.generator = 'ReportGenerator v2.0';
            report.metadata.format = obj.reportFormat;
            report.metadata.includeVisualizations = obj.includeVisualizations;
        end
        
        function reportPath = writeReport(obj, report)
            % Escreve relatório no formato especificado
            
            timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
            
            switch obj.reportFormat
                case 'text'
                    reportPath = obj.writeTextReport(report, timestamp);
                case 'html'
                    reportPath = obj.writeHTMLReport(report, timestamp);
                case 'pdf'
                    reportPath = obj.writePDFReport(report, timestamp);
                otherwise
                    error('Formato de relatório não suportado: %s', obj.reportFormat);
            end
        end
        
        function reportPath = writeTextReport(obj, report, timestamp)
            % Escreve relatório em formato texto
            
            filename = sprintf('comparison_report_%s.txt', timestamp);
            reportPath = fullfile(obj.outputDir, filename);
            
            try
                fid = fopen(reportPath, 'w');
                if fid == -1
                    error('Não foi possível criar arquivo de relatório');
                end
                
                % Cabeçalho
                fprintf(fid, '=== %s ===\n', report.title);
                fprintf(fid, 'Gerado em: %s\n', report.timestamp);
                fprintf(fid, 'Gerador: %s\n\n', report.metadata.generator);
                
                % Resumo executivo
                if isfield(report.interpretation, 'executiveSummary')
                    fprintf(fid, '=== RESUMO EXECUTIVO ===\n');
                    fprintf(fid, '%s\n\n', report.interpretation.executiveSummary);
                end
                
                % Resultados dos modelos
                obj.writeModelResults(fid, report.results);
                
                % Interpretação
                obj.writeInterpretation(fid, report.interpretation);
                
                % Recomendações
                if obj.includeRecommendations
                    obj.writeRecommendations(fid, report.recommendations);
                end
                
                % Visualizações
                if obj.includeVisualizations && isfield(report, 'visualizations')
                    obj.writeVisualizationReferences(fid, report.visualizations);
                end
                
                fclose(fid);
                
            catch ME
                if fid ~= -1
                    fclose(fid);
                end
                rethrow(ME);
            end
        end
        
        % Métodos auxiliares para escrita do relatório
        function writeModelResults(obj, fid, results)
            % Escreve resultados dos modelos
            
            fprintf(fid, '=== RESULTADOS DOS MODELOS ===\n');
            
            if isfield(results.models, 'unet') && isfield(results.models.unet, 'metrics')
                fprintf(fid, 'U-Net:\n');
                obj.writeMetrics(fid, results.models.unet.metrics, '  ');
            end
            
            if isfield(results.models, 'attentionUnet') && isfield(results.models.attentionUnet, 'metrics')
                fprintf(fid, '\nAttention U-Net:\n');
                obj.writeMetrics(fid, results.models.attentionUnet.metrics, '  ');
            end
            
            fprintf(fid, '\n');
        end
        
        function writeMetrics(obj, fid, metrics, indent)
            % Escreve métricas formatadas
            
            if isfield(metrics, 'iou')
                fprintf(fid, '%sIoU: %.4f ± %.4f\n', indent, metrics.iou.mean, metrics.iou.std);
            end
            if isfield(metrics, 'dice')
                fprintf(fid, '%sDice: %.4f ± %.4f\n', indent, metrics.dice.mean, metrics.dice.std);
            end
            if isfield(metrics, 'accuracy')
                fprintf(fid, '%sAccuracy: %.4f ± %.4f\n', indent, metrics.accuracy.mean, metrics.accuracy.std);
            end
            if isfield(metrics, 'numSamples')
                fprintf(fid, '%sAmostras: %d\n', indent, metrics.numSamples);
            end
        end
        
        function writeInterpretation(obj, fid, interpretation)
            % Escreve interpretação
            
            fprintf(fid, '=== INTERPRETAÇÃO AUTOMÁTICA ===\n');
            
            if isfield(interpretation, 'winner')
                fprintf(fid, 'Modelo vencedor: %s\n', interpretation.winner.model);
                fprintf(fid, 'Confiança: %s\n', interpretation.winner.confidence);
                if isfield(interpretation.winner, 'explanation')
                    fprintf(fid, 'Explicação: %s\n', interpretation.winner.explanation);
                end
            end
            
            if isfield(interpretation, 'statistical')
                fprintf(fid, '\nAnálise Estatística:\n');
                if isfield(interpretation.statistical, 'summary')
                    fprintf(fid, '  %s\n', interpretation.statistical.summary);
                end
            end
            
            fprintf(fid, '\n');
        end
        
        function writeRecommendations(obj, fid, recommendations)
            % Escreve recomendações
            
            fprintf(fid, '=== RECOMENDAÇÕES ===\n');
            
            if isfield(recommendations, 'modelChoice')
                fprintf(fid, 'Escolha de Modelo:\n');
                fprintf(fid, '  %s\n', recommendations.modelChoice);
            end
            
            if isfield(recommendations, 'nextSteps')
                fprintf(fid, '\nPróximos Passos:\n');
                for i = 1:length(recommendations.nextSteps)
                    fprintf(fid, '  %d. %s\n', i, recommendations.nextSteps{i});
                end
            end
            
            fprintf(fid, '\n');
        end
        
        function writeVisualizationReferences(obj, fid, visualizations)
            % Escreve referências às visualizações
            
            fprintf(fid, '=== VISUALIZAÇÕES GERADAS ===\n');
            
            fields = fieldnames(visualizations);
            for i = 1:length(fields)
                field = fields{i};
                if ischar(visualizations.(field))
                    fprintf(fid, '%s: %s\n', field, visualizations.(field));
                end
            end
            
            fprintf(fid, '\n');
        end
        
        % Métodos auxiliares para análise
        function hasHighConfidence = hasHighConfidenceWinner(obj, results)
            hasHighConfidence = false;
            % Implementar lógica
        end
        
        function hasLowConfidence = hasLowConfidenceWinner(obj, results)
            hasLowConfidence = false;
            % Implementar lógica
        end
        
        function hasNoSignificant = hasNoSignificantDifference(obj, results)
            hasNoSignificant = false;
            % Implementar lógica
        end
        
        function hasMemory = hasMemoryIssues(obj, results)
            hasMemory = false;
            % Implementar lógica
        end
        
        function hasGPU = hasGPUAvailable(obj, results)
            hasGPU = false;
            % Implementar lógica
        end
        
        function hasLarge = hasLargeDataset(obj, results)
            hasLarge = false;
            try
                if isfield(results.models, 'unet') && isfield(results.models.unet.metrics, 'numSamples')
                    hasLarge = results.models.unet.metrics.numSamples > 1000;
                end
            catch
                % Manter hasLarge = false
            end
        end
        
        function reportPath = generateHTMLReport(obj, results, varargin)
            % Gera relatório em formato HTML
            %
            % ENTRADA:
            %   results - estrutura com resultados
            %   varargin - parâmetros opcionais
            %
            % SAÍDA:
            %   reportPath - caminho para o relatório HTML
            %
            % REQUISITOS: 4.3 (relatórios em HTML)
            
            p = inputParser;
            addParameter(p, 'Title', 'Relatório de Comparação U-Net vs Attention U-Net', @ischar);
            addParameter(p, 'Template', 'default', @ischar);
            parse(p, varargin{:});
            
            title = p.Results.Title;
            template = p.Results.Template;
            
            obj.logger('info', '🌐 Gerando relatório HTML...');
            
            try
                % Gerar interpretação e recomendações
                interpretation = obj.generateAutomaticInterpretation(results);
                recommendations = obj.generateRecommendations(results, interpretation);
                
                % Criar estrutura HTML
                html = obj.createHTMLStructure(results, interpretation, recommendations, title);
                
                % Salvar arquivo HTML
                timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                filename = sprintf('relatorio_comparacao_%s.html', timestamp);
                reportPath = fullfile(obj.outputDir, filename);
                
                fid = fopen(reportPath, 'w', 'n', 'UTF-8');
                if fid == -1
                    error('Não foi possível criar arquivo HTML');
                end
                
                fprintf(fid, '%s', html);
                fclose(fid);
                
                obj.logger('success', sprintf('Relatório HTML gerado: %s', reportPath));
                
            catch ME
                obj.logger('error', sprintf('Erro ao gerar HTML: %s', ME.message));
                reportPath = '';
                rethrow(ME);
            end
        end
        
        function reportPath = generatePDFReport(obj, results, varargin)
            % Gera relatório em formato PDF
            %
            % ENTRADA:
            %   results - estrutura com resultados
            %   varargin - parâmetros opcionais
            %
            % SAÍDA:
            %   reportPath - caminho para o relatório PDF
            %
            % REQUISITOS: 4.3 (relatórios em PDF)
            
            p = inputParser;
            addParameter(p, 'Title', 'Relatório de Comparação U-Net vs Attention U-Net', @ischar);
            parse(p, varargin{:});
            
            title = p.Results.Title;
            
            obj.logger('info', '📄 Gerando relatório PDF...');
            
            try
                % Primeiro gerar HTML
                htmlPath = obj.generateHTMLReport(results, 'Title', title);
                
                % Converter HTML para PDF (requer wkhtmltopdf ou similar)
                timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                filename = sprintf('relatorio_comparacao_%s.pdf', timestamp);
                reportPath = fullfile(obj.outputDir, filename);
                
                % Tentar conversão usando diferentes métodos
                success = obj.convertHTMLToPDF(htmlPath, reportPath);
                
                if ~success
                    % Fallback: gerar PDF usando MATLAB Report Generator (se disponível)
                    reportPath = obj.generateMATLABPDF(results, title);
                end
                
                obj.logger('success', sprintf('Relatório PDF gerado: %s', reportPath));
                
            catch ME
                obj.logger('error', sprintf('Erro ao gerar PDF: %s', ME.message));
                reportPath = '';
                rethrow(ME);
            end
        end
        
        function exportPath = exportToScientificFormat(obj, results, format, varargin)
            % Exporta resultados em formatos científicos
            %
            % ENTRADA:
            %   results - estrutura com resultados
            %   format - formato de exportação ('csv', 'json', 'mat', 'excel')
            %   varargin - parâmetros opcionais
            %
            % SAÍDA:
            %   exportPath - caminho para o arquivo exportado
            %
            % REQUISITOS: 4.3 (exportação em formatos científicos)
            
            p = inputParser;
            addParameter(p, 'IncludeRawData', true, @islogical);
            addParameter(p, 'IncludeStatistics', true, @islogical);
            parse(p, varargin{:});
            
            includeRawData = p.Results.IncludeRawData;
            includeStatistics = p.Results.IncludeStatistics;
            
            obj.logger('info', sprintf('📊 Exportando para formato %s...', upper(format)));
            
            try
                % Preparar dados para exportação
                exportData = obj.prepareDataForExport(results, includeRawData, includeStatistics);
                
                % Gerar nome do arquivo
                timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                filename = sprintf('dados_comparacao_%s.%s', timestamp, format);
                exportPath = fullfile(obj.outputDir, filename);
                
                % Exportar baseado no formato
                switch lower(format)
                    case 'csv'
                        obj.exportToCSV(exportData, exportPath);
                    case 'json'
                        obj.exportToJSON(exportData, exportPath);
                    case 'mat'
                        obj.exportToMAT(exportData, exportPath);
                    case 'excel'
                        obj.exportToExcel(exportData, exportPath);
                    otherwise
                        error('Formato não suportado: %s', format);
                end
                
                obj.logger('success', sprintf('Dados exportados: %s', exportPath));
                
            catch ME
                obj.logger('error', sprintf('Erro na exportação: %s', ME.message));
                exportPath = '';
                rethrow(ME);
            end
        end
        
        % Métodos de visualização (implementação completa)
        function chartPath = createMetricsComparisonChart(obj, results, vizDir)
            chartPath = fullfile(vizDir, 'metrics_comparison.png');
            
            try
                % Usar Visualizer para criar gráfico
                if exist('Visualizer', 'class')
                    visualizer = Visualizer('OutputDir', vizDir, 'AutoSave', false);
                    figHandle = visualizer.createComparisonPlot(results);
                    
                    if ~isempty(figHandle)
                        print(figHandle, chartPath, '-dpng', '-r300');
                        close(figHandle);
                    end
                else
                    % Implementação básica sem Visualizer
                    obj.createBasicComparisonChart(results, chartPath);
                end
                
            catch ME
                obj.logger('warning', sprintf('Erro ao criar gráfico de comparação: %s', ME.message));
                chartPath = '';
            end
        end
        
        function chartPath = createMetricsDistributionChart(obj, results, vizDir)
            chartPath = fullfile(vizDir, 'metrics_distribution.png');
            
            try
                % Usar Visualizer para criar boxplot
                if exist('Visualizer', 'class')
                    visualizer = Visualizer('OutputDir', vizDir, 'AutoSave', false);
                    figHandle = visualizer.createMetricsBoxplot(results);
                    
                    if ~isempty(figHandle)
                        print(figHandle, chartPath, '-dpng', '-r300');
                        close(figHandle);
                    end
                else
                    % Implementação básica sem Visualizer
                    obj.createBasicDistributionChart(results, chartPath);
                end
                
            catch ME
                obj.logger('warning', sprintf('Erro ao criar gráfico de distribuição: %s', ME.message));
                chartPath = '';
            end
        end
        
        function chartPath = createStatisticalChart(obj, results, vizDir)
            chartPath = fullfile(vizDir, 'statistical_significance.png');
            
            try
                if ~isfield(results, 'statistical')
                    chartPath = '';
                    return;
                end
                
                fig = figure('Visible', 'off');
                
                % Extrair p-values
                metrics = fieldnames(results.statistical);
                pValues = zeros(length(metrics), 1);
                
                for i = 1:length(metrics)
                    if isfield(results.statistical.(metrics{i}), 'pValue')
                        pValues(i) = results.statistical.(metrics{i}).pValue;
                    end
                end
                
                % Criar gráfico de significância
                bar(1:length(metrics), -log10(pValues));
                hold on;
                plot([0, length(metrics)+1], [-log10(0.05), -log10(0.05)], 'r--', 'LineWidth', 2);
                
                set(gca, 'XTickLabel', upper(metrics));
                ylabel('-log10(p-value)');
                title('Significância Estatística por Métrica');
                legend('p-values', 'Limiar α=0.05', 'Location', 'best');
                grid on;
                
                print(fig, chartPath, '-dpng', '-r300');
                close(fig);
                
            catch ME
                obj.logger('warning', sprintf('Erro ao criar gráfico estatístico: %s', ME.message));
                chartPath = '';
            end
        end
        
        function chartPath = createErrorBarsChart(obj, results, vizDir)
            chartPath = fullfile(vizDir, 'error_bars.png');
            
            try
                fig = figure('Visible', 'off');
                
                % Extrair dados
                metrics = {'iou', 'dice', 'accuracy'};
                unetMeans = zeros(length(metrics), 1);
                unetStds = zeros(length(metrics), 1);
                attentionMeans = zeros(length(metrics), 1);
                attentionStds = zeros(length(metrics), 1);
                
                for i = 1:length(metrics)
                    metric = metrics{i};
                    if isfield(results.models.unet.metrics, metric)
                        unetMeans(i) = results.models.unet.metrics.(metric).mean;
                        unetStds(i) = results.models.unet.metrics.(metric).std;
                    end
                    if isfield(results.models.attentionUnet.metrics, metric)
                        attentionMeans(i) = results.models.attentionUnet.metrics.(metric).mean;
                        attentionStds(i) = results.models.attentionUnet.metrics.(metric).std;
                    end
                end
                
                % Criar gráfico com barras de erro
                x = 1:length(metrics);
                width = 0.35;
                
                bar(x - width/2, unetMeans, width, 'FaceColor', [0.2, 0.4, 0.8]);
                hold on;
                bar(x + width/2, attentionMeans, width, 'FaceColor', [0.8, 0.2, 0.4]);
                
                errorbar(x - width/2, unetMeans, unetStds, 'k.', 'LineWidth', 1.5);
                errorbar(x + width/2, attentionMeans, attentionStds, 'k.', 'LineWidth', 1.5);
                
                set(gca, 'XTickLabel', upper(metrics));
                ylabel('Score');
                title('Comparação de Métricas com Barras de Erro');
                legend('U-Net', 'Attention U-Net', 'Location', 'best');
                grid on;
                
                print(fig, chartPath, '-dpng', '-r300');
                close(fig);
                
            catch ME
                obj.logger('warning', sprintf('Erro ao criar gráfico de barras de erro: %s', ME.message));
                chartPath = '';
            end
        end
        
        function chartPath = createCorrelationHeatmap(obj, results, vizDir)
            chartPath = fullfile(vizDir, 'correlation_heatmap.png');
            
            try
                if ~obj.hasEnoughDataForCorrelation(results)
                    chartPath = '';
                    return;
                end
                
                % Implementação básica de heatmap de correlação
                fig = figure('Visible', 'off');
                
                % Extrair dados para correlação
                data = obj.extractDataForCorrelation(results);
                
                if ~isempty(data)
                    corrMatrix = corr(data);
                    imagesc(corrMatrix);
                    colorbar;
                    colormap('jet');
                    
                    title('Matriz de Correlação entre Métricas');
                    
                    print(fig, chartPath, '-dpng', '-r300');
                end
                
                close(fig);
                
            catch ME
                obj.logger('warning', sprintf('Erro ao criar heatmap: %s', ME.message));
                chartPath = '';
            end
        end
        
        function hasEnough = hasEnoughDataForCorrelation(obj, results)
            hasEnough = false;
            try
                if isfield(results.models, 'unet') && isfield(results.models.unet.metrics, 'numSamples')
                    hasEnough = results.models.unet.metrics.numSamples >= 10;
                end
            catch
                % Manter hasEnough = false
            end
        end
        
        % Métodos auxiliares para exportação
        function exportData = prepareDataForExport(obj, results, includeRawData, includeStatistics)
            exportData = struct();
            
            % Informações básicas
            exportData.metadata = struct();
            exportData.metadata.timestamp = datestr(now);
            exportData.metadata.version = '2.0';
            exportData.metadata.description = 'Resultados de comparação U-Net vs Attention U-Net';
            
            % Métricas resumidas
            exportData.summary = struct();
            if isfield(results.models, 'unet')
                exportData.summary.unet = results.models.unet.metrics;
            end
            if isfield(results.models, 'attentionUnet')
                exportData.summary.attentionUnet = results.models.attentionUnet.metrics;
            end
            
            % Dados estatísticos
            if includeStatistics && isfield(results, 'statistical')
                exportData.statistics = results.statistical;
            end
            
            % Dados brutos (se solicitado)
            if includeRawData
                exportData.rawData = results;
            end
        end
        
        function exportToCSV(obj, data, filepath)
            % Exporta dados para CSV
            try
                % Criar tabela com métricas principais
                if isfield(data, 'summary')
                    metrics = {'iou', 'dice', 'accuracy'};
                    models = fieldnames(data.summary);
                    
                    % Preparar dados tabulares
                    tableData = [];
                    rowNames = {};
                    colNames = {'Modelo', 'Métrica', 'Média', 'Desvio', 'Min', 'Max'};
                    
                    for i = 1:length(models)
                        model = models{i};
                        for j = 1:length(metrics)
                            metric = metrics{j};
                            if isfield(data.summary.(model), metric)
                                metricData = data.summary.(model).(metric);
                                row = {model, metric, metricData.mean, metricData.std, ...
                                      metricData.min, metricData.max};
                                tableData = [tableData; row];
                            end
                        end
                    end
                    
                    % Criar tabela
                    T = cell2table(tableData, 'VariableNames', colNames);
                    writetable(T, filepath);
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao exportar CSV: %s', ME.message));
            end
        end
        
        function exportToJSON(obj, data, filepath)
            % Exporta dados para JSON
            try
                jsonStr = jsonencode(data);
                
                fid = fopen(filepath, 'w');
                if fid ~= -1
                    fprintf(fid, '%s', jsonStr);
                    fclose(fid);
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao exportar JSON: %s', ME.message));
            end
        end
        
        function exportToMAT(obj, data, filepath)
            % Exporta dados para arquivo .mat
            try
                save(filepath, 'data', '-v7.3');
            catch ME
                obj.logger('error', sprintf('Erro ao exportar MAT: %s', ME.message));
            end
        end
        
        function exportToExcel(obj, data, filepath)
            % Exporta dados para Excel
            try
                if isfield(data, 'summary')
                    % Similar ao CSV mas usando xlswrite
                    metrics = {'iou', 'dice', 'accuracy'};
                    models = fieldnames(data.summary);
                    
                    % Preparar dados
                    tableData = {};
                    tableData{1, 1} = 'Modelo';
                    tableData{1, 2} = 'Métrica';
                    tableData{1, 3} = 'Média';
                    tableData{1, 4} = 'Desvio';
                    tableData{1, 5} = 'Min';
                    tableData{1, 6} = 'Max';
                    
                    row = 2;
                    for i = 1:length(models)
                        model = models{i};
                        for j = 1:length(metrics)
                            metric = metrics{j};
                            if isfield(data.summary.(model), metric)
                                metricData = data.summary.(model).(metric);
                                tableData{row, 1} = model;
                                tableData{row, 2} = metric;
                                tableData{row, 3} = metricData.mean;
                                tableData{row, 4} = metricData.std;
                                tableData{row, 5} = metricData.min;
                                tableData{row, 6} = metricData.max;
                                row = row + 1;
                            end
                        end
                    end
                    
                    xlswrite(filepath, tableData);
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao exportar Excel: %s', ME.message));
            end
        end
        
        function html = createHTMLStructure(obj, results, interpretation, recommendations, title)
            % Cria estrutura HTML completa
            html = sprintf(['<!DOCTYPE html>\n' ...
                           '<html lang="pt-BR">\n' ...
                           '<head>\n' ...
                           '    <meta charset="UTF-8">\n' ...
                           '    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n' ...
                           '    <title>%s</title>\n' ...
                           '    <style>\n' ...
                           '        %s\n' ...
                           '    </style>\n' ...
                           '</head>\n' ...
                           '<body>\n' ...
                           '    <div class="container">\n' ...
                           '        %s\n' ...
                           '    </div>\n' ...
                           '</body>\n' ...
                           '</html>'], title, obj.getHTMLStyles(), obj.getHTMLContent(results, interpretation, recommendations, title));
        end
        
        function styles = getHTMLStyles(obj)
            % Retorna estilos CSS para o relatório HTML
            styles = ['body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }' ...
                     '.container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }' ...
                     'h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }' ...
                     'h2 { color: #34495e; margin-top: 30px; }' ...
                     'h3 { color: #7f8c8d; }' ...
                     '.metric-table { width: 100%; border-collapse: collapse; margin: 20px 0; }' ...
                     '.metric-table th, .metric-table td { border: 1px solid #ddd; padding: 12px; text-align: left; }' ...
                     '.metric-table th { background-color: #3498db; color: white; }' ...
                     '.metric-table tr:nth-child(even) { background-color: #f2f2f2; }' ...
                     '.winner { background-color: #d4edda; border: 1px solid #c3e6cb; padding: 15px; border-radius: 5px; margin: 20px 0; }' ...
                     '.recommendation { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }' ...
                     '.statistics { background-color: #e2e3e5; border: 1px solid #d6d8db; padding: 15px; border-radius: 5px; margin: 20px 0; }'];
        end
        
        function content = getHTMLContent(obj, results, interpretation, recommendations, title)
            % Gera conteúdo HTML do relatório
            content = sprintf('<h1>%s</h1>\n', title);
            
            % Resumo executivo
            if isfield(interpretation, 'executiveSummary')
                content = [content sprintf('<h2>Resumo Executivo</h2>\n<p>%s</p>\n', ...
                    strrep(interpretation.executiveSummary, sprintf('\n'), '<br>'))];
            end
            
            % Tabela de métricas
            content = [content '<h2>Resultados das Métricas</h2>\n'];
            content = [content obj.createMetricsTable(results)];
            
            % Interpretação
            if isfield(interpretation, 'winner')
                content = [content sprintf('<div class="winner"><h3>Modelo Vencedor</h3><p>%s com confiança %s</p></div>\n', ...
                    interpretation.winner.model, interpretation.winner.confidence)];
            end
            
            % Recomendações
            if isfield(recommendations, 'modelChoice')
                content = [content sprintf('<div class="recommendation"><h3>Recomendação</h3><p>%s</p></div>\n', ...
                    recommendations.modelChoice)];
            end
            
            % Estatísticas
            if isfield(results, 'statistical')
                content = [content '<div class="statistics"><h3>Análise Estatística</h3>'];
                content = [content obj.createStatisticsSection(results.statistical)];
                content = [content '</div>'];
            end
        end
        
        function tableHTML = createMetricsTable(obj, results)
            % Cria tabela HTML com métricas
            tableHTML = '<table class="metric-table">\n';
            tableHTML = [tableHTML '<tr><th>Modelo</th><th>IoU</th><th>Dice</th><th>Accuracy</th></tr>\n'];
            
            % Linha U-Net
            if isfield(results.models, 'unet')
                unet = results.models.unet.metrics;
                tableHTML = [tableHTML sprintf('<tr><td>U-Net</td><td>%.4f ± %.4f</td><td>%.4f ± %.4f</td><td>%.4f ± %.4f</td></tr>\n', ...
                    unet.iou.mean, unet.iou.std, unet.dice.mean, unet.dice.std, unet.accuracy.mean, unet.accuracy.std)];
            end
            
            % Linha Attention U-Net
            if isfield(results.models, 'attentionUnet')
                attention = results.models.attentionUnet.metrics;
                tableHTML = [tableHTML sprintf('<tr><td>Attention U-Net</td><td>%.4f ± %.4f</td><td>%.4f ± %.4f</td><td>%.4f ± %.4f</td></tr>\n', ...
                    attention.iou.mean, attention.iou.std, attention.dice.mean, attention.dice.std, attention.accuracy.mean, attention.accuracy.std)];
            end
            
            tableHTML = [tableHTML '</table>\n'];
        end
        
        function statsHTML = createStatisticsSection(obj, statistical)
            % Cria seção de estatísticas em HTML
            statsHTML = '<ul>\n';
            
            metrics = fieldnames(statistical);
            for i = 1:length(metrics)
                metric = metrics{i};
                if isfield(statistical.(metric), 'pValue')
                    significance = '';
                    if statistical.(metric).significant
                        significance = ' (significativo)';
                    end
                    statsHTML = [statsHTML sprintf('<li>%s: p-value = %.4f%s</li>\n', ...
                        upper(metric), statistical.(metric).pValue, significance)];
                end
            end
            
            statsHTML = [statsHTML '</ul>\n'];
        end
        
        function success = convertHTMLToPDF(obj, htmlPath, pdfPath)
            % Tenta converter HTML para PDF
            success = false;
            
            try
                % Tentar usar wkhtmltopdf se disponível
                [status, ~] = system(sprintf('wkhtmltopdf "%s" "%s"', htmlPath, pdfPath));
                if status == 0
                    success = true;
                    return;
                end
                
                % Outros métodos de conversão podem ser adicionados aqui
                
            catch
                % Falha na conversão
            end
        end
        
        function pdfPath = generateMATLABPDF(obj, results, title)
            % Gera PDF usando recursos nativos do MATLAB
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            filename = sprintf('relatorio_matlab_%s.pdf', timestamp);
            pdfPath = fullfile(obj.outputDir, filename);
            
            try
                % Criar figura para PDF
                fig = figure('Visible', 'off', 'PaperType', 'A4', 'PaperOrientation', 'portrait');
                
                % Adicionar texto do relatório
                text(0.1, 0.9, title, 'FontSize', 16, 'FontWeight', 'bold');
                
                % Adicionar métricas básicas
                y_pos = 0.8;
                if isfield(results.models, 'unet')
                    unet = results.models.unet.metrics;
                    text(0.1, y_pos, sprintf('U-Net - IoU: %.4f, Dice: %.4f, Acc: %.4f', ...
                        unet.iou.mean, unet.dice.mean, unet.accuracy.mean), 'FontSize', 12);
                    y_pos = y_pos - 0.05;
                end
                
                if isfield(results.models, 'attentionUnet')
                    attention = results.models.attentionUnet.metrics;
                    text(0.1, y_pos, sprintf('Attention U-Net - IoU: %.4f, Dice: %.4f, Acc: %.4f', ...
                        attention.iou.mean, attention.dice.mean, attention.accuracy.mean), 'FontSize', 12);
                end
                
                axis off;
                
                % Salvar como PDF
                print(fig, pdfPath, '-dpdf');
                close(fig);
                
            catch ME
                obj.logger('error', sprintf('Erro ao gerar PDF MATLAB: %s', ME.message));
                pdfPath = '';
            end
        end
        
        function data = extractDataForCorrelation(obj, results)
            % Extrai dados para análise de correlação
            data = [];
            
            try
                metrics = {'iou', 'dice', 'accuracy'};
                
                % Coletar dados de ambos os modelos
                allData = [];
                
                for i = 1:length(metrics)
                    metric = metrics{i};
                    
                    % U-Net
                    if isfield(results.models.unet.metrics, metric) && ...
                       isfield(results.models.unet.metrics.(metric), 'values')
                        unetValues = results.models.unet.metrics.(metric).values;
                        allData = [allData, unetValues(:)];
                    end
                    
                    % Attention U-Net
                    if isfield(results.models.attentionUnet.metrics, metric) && ...
                       isfield(results.models.attentionUnet.metrics.(metric), 'values')
                        attentionValues = results.models.attentionUnet.metrics.(metric).values;
                        allData = [allData, attentionValues(:)];
                    end
                end
                
                if size(allData, 2) >= 2
                    data = allData;
                end
                
            catch
                % Retornar dados vazios em caso de erro
            end
        end
        
        function createBasicComparisonChart(obj, results, chartPath)
            % Implementação básica de gráfico de comparação
            try
                fig = figure('Visible', 'off');
                
                metrics = {'iou', 'dice', 'accuracy'};
                unetMeans = zeros(length(metrics), 1);
                attentionMeans = zeros(length(metrics), 1);
                
                for i = 1:length(metrics)
                    metric = metrics{i};
                    if isfield(results.models.unet.metrics, metric)
                        unetMeans(i) = results.models.unet.metrics.(metric).mean;
                    end
                    if isfield(results.models.attentionUnet.metrics, metric)
                        attentionMeans(i) = results.models.attentionUnet.metrics.(metric).mean;
                    end
                end
                
                x = 1:length(metrics);
                width = 0.35;
                
                bar(x - width/2, unetMeans, width, 'FaceColor', [0.2, 0.4, 0.8]);
                hold on;
                bar(x + width/2, attentionMeans, width, 'FaceColor', [0.8, 0.2, 0.4]);
                
                set(gca, 'XTickLabel', upper(metrics));
                ylabel('Score');
                title('Comparação de Métricas');
                legend('U-Net', 'Attention U-Net', 'Location', 'best');
                grid on;
                
                print(fig, chartPath, '-dpng', '-r300');
                close(fig);
                
            catch ME
                obj.logger('warning', sprintf('Erro no gráfico básico: %s', ME.message));
            end
        end
        
        function createBasicDistributionChart(obj, results, chartPath)
            % Implementação básica de gráfico de distribuição
            try
                fig = figure('Visible', 'off');
                
                % Placeholder para distribuição básica
                text(0.5, 0.5, 'Gráfico de Distribuição\n(Implementação Básica)', ...
                    'HorizontalAlignment', 'center', 'FontSize', 14);
                axis off;
                
                print(fig, chartPath, '-dpng', '-r300');
                close(fig);
                
            catch ME
                obj.logger('warning', sprintf('Erro no gráfico de distribuição: %s', ME.message));
            end
        end
    end
end