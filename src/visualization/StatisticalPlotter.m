classdef StatisticalPlotter < handle
    % StatisticalPlotter - Gerador de gráficos estatísticos comparativos
    % 
    % Esta classe implementa funcionalidades para:
    % - Gráficos estatísticos comparativos com boxplots e distribuições
    % - Testes de significância estatística
    % - Visualizações de performance por métrica
    % - Análise de distribuições e outliers
    
    properties (Constant)
        % Configurações padrão
        DEFAULT_FIGURE_SIZE = [1000, 600];
        DEFAULT_DPI = 300;
        COLORS = {'#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd'};
        FONT_SIZE_TITLE = 14;
        FONT_SIZE_LABEL = 12;
        FONT_SIZE_TICK = 10;
    end
    
    properties
        outputDirectory
        figureFormat
        saveHighRes
        showProgress
    end
    
    methods
        function obj = StatisticalPlotter(varargin)
            % Constructor - Inicializa o gerador de gráficos estatísticos
            
            % Parse input arguments
            p = inputParser;
            addParameter(p, 'outputDir', 'output/statistics/', @ischar);
            addParameter(p, 'figureFormat', 'png', @ischar);
            addParameter(p, 'saveHighRes', true, @islogical);
            addParameter(p, 'showProgress', true, @islogical);
            parse(p, varargin{:});
            
            obj.outputDirectory = p.Results.outputDir;
            obj.figureFormat = p.Results.figureFormat;
            obj.saveHighRes = p.Results.saveHighRes;
            obj.showProgress = p.Results.showProgress;
            
            % Criar diretório de saída se não existir
            if ~exist(obj.outputDirectory, 'dir')
                mkdir(obj.outputDirectory);
            end
        end
        
        function outputPath = plotStatisticalComparison(obj, unetMetrics, attentionMetrics, varargin)
            % Cria gráficos estatísticos comparativos completos
            %
            % Inputs:
            %   unetMetrics - Struct com métricas do U-Net
            %   attentionMetrics - Struct com métricas do Attention U-Net
            %
            % Output:
            %   outputPath - Caminho do arquivo salvo
            
            % Parse optional arguments
            p = inputParser;
            addParameter(p, 'metrics', {'iou', 'dice', 'accuracy'}, @iscell);
            addParameter(p, 'title', 'Comparação Estatística de Modelos', @ischar);
            addParameter(p, 'filename', '', @ischar);
            addParameter(p, 'includeTests', true, @islogical);
            parse(p, varargin{:});
            
            try
                % Criar figura com múltiplos subplots
                fig = figure('Position', [100, 100, obj.DEFAULT_FIGURE_SIZE]);
                set(fig, 'Color', 'white');
                
                numMetrics = length(p.Results.metrics);
                
                % Configurar layout dos subplots
                if numMetrics <= 3
                    rows = 2;
                    cols = numMetrics;
                else
                    rows = 3;
                    cols = ceil(numMetrics / 2);
                end
                
                % Criar boxplots para cada métrica
                for i = 1:numMetrics
                    metric = p.Results.metrics{i};
                    
                    % Subplot para boxplot
                    subplot(rows, cols, i);
                    obj.createBoxplot(unetMetrics.(metric), attentionMetrics.(metric), metric);
                    
                    % Subplot para distribuições (se houver espaço)
                    if rows >= 2
                        subplot(rows, cols, i + numMetrics);
                        obj.createDistributionPlot(unetMetrics.(metric), attentionMetrics.(metric), metric);
                    end
                end
                
                % Título geral
                sgtitle(p.Results.title, 'FontSize', obj.FONT_SIZE_TITLE + 2);
                
                % Adicionar testes estatísticos se solicitado
                if p.Results.includeTests
                    obj.addStatisticalTests(fig, unetMetrics, attentionMetrics, p.Results.metrics);
                end
                
                % Salvar figura
                if isempty(p.Results.filename)
                    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                    filename = sprintf('statistical_comparison_%s.%s', timestamp, obj.figureFormat);
                else
                    filename = p.Results.filename;
                end
                
                outputPath = fullfile(obj.outputDirectory, filename);
                
                if obj.saveHighRes
                    print(fig, outputPath, ['-d' obj.figureFormat], ['-r' num2str(obj.DEFAULT_DPI)]);
                else
                    saveas(fig, outputPath);
                end
                
                close(fig);
                
                if obj.showProgress
                    fprintf('Gráfico estatístico salvo em: %s\n', outputPath);
                end
                
            catch ME
                if exist('fig', 'var') && ishandle(fig)
                    close(fig);
                end
                error('Erro ao criar gráfico estatístico: %s', ME.message);
            end
        end
        
        function createBoxplot(obj, unetData, attentionData, metricName)
            % Cria boxplot comparativo para uma métrica
            
            % Preparar dados
            allData = [unetData(:); attentionData(:)];
            groups = [repmat({'U-Net'}, length(unetData), 1); ...
                     repmat({'Attention U-Net'}, length(attentionData), 1)];
            
            % Criar boxplot
            boxplot(allData, groups, 'Colors', obj.COLORS{1:2});
            
            % Configurar aparência
            title(sprintf('Boxplot - %s', upper(metricName)), 'FontSize', obj.FONT_SIZE_TITLE);
            ylabel(upper(metricName), 'FontSize', obj.FONT_SIZE_LABEL);
            grid on;
            
            % Adicionar estatísticas básicas
            unetMean = mean(unetData);
            attentionMean = mean(attentionData);
            
            % Adicionar texto com médias
            ylims = ylim;
            text(1, ylims(2) * 0.95, sprintf('Média: %.3f', unetMean), ...
                'HorizontalAlignment', 'center', 'FontSize', obj.FONT_SIZE_TICK);
            text(2, ylims(2) * 0.95, sprintf('Média: %.3f', attentionMean), ...
                'HorizontalAlignment', 'center', 'FontSize', obj.FONT_SIZE_TICK);
        end
        
        function createDistributionPlot(obj, unetData, attentionData, metricName)
            % Cria gráfico de distribuições sobrepostas
            
            % Criar histogramas
            hold on;
            
            % Definir bins
            minVal = min([unetData(:); attentionData(:)]);
            maxVal = max([unetData(:); attentionData(:)]);
            bins = linspace(minVal, maxVal, 20);
            
            % Histograma U-Net
            [counts1, ~] = histcounts(unetData, bins);
            binCenters = (bins(1:end-1) + bins(2:end)) / 2;
            bar(binCenters, counts1, 'FaceColor', obj.COLORS{1}, 'FaceAlpha', 0.6, ...
                'EdgeColor', 'none', 'BarWidth', 0.8);
            
            % Histograma Attention U-Net
            [counts2, ~] = histcounts(attentionData, bins);
            bar(binCenters, counts2, 'FaceColor', obj.COLORS{2}, 'FaceAlpha', 0.6, ...
                'EdgeColor', 'none', 'BarWidth', 0.8);
            
            % Configurar aparência
            title(sprintf('Distribuições - %s', upper(metricName)), 'FontSize', obj.FONT_SIZE_TITLE);
            xlabel(upper(metricName), 'FontSize', obj.FONT_SIZE_LABEL);
            ylabel('Frequência', 'FontSize', obj.FONT_SIZE_LABEL);
            legend({'U-Net', 'Attention U-Net'}, 'Location', 'best');
            grid on;
            
            hold off;
        end
        
        function addStatisticalTests(obj, fig, unetMetrics, attentionMetrics, metrics)
            % Adiciona resultados de testes estatísticos à figura
            
            % Calcular testes para cada métrica
            testResults = {};
            
            for i = 1:length(metrics)
                metric = metrics{i};
                unetData = unetMetrics.(metric);
                attentionData = attentionMetrics.(metric);
                
                % Teste de normalidade (Shapiro-Wilk simplificado)
                isNormal1 = obj.testNormality(unetData);
                isNormal2 = obj.testNormality(attentionData);
                
                % Escolher teste apropriado
                if isNormal1 && isNormal2
                    % Teste t
                    [~, pValue] = ttest2(unetData, attentionData);
                    testType = 't-test';
                else
                    % Teste de Mann-Whitney (Wilcoxon rank-sum)
                    pValue = obj.mannWhitneyTest(unetData, attentionData);
                    testType = 'Mann-Whitney';
                end
                
                % Calcular effect size (Cohen's d)
                effectSize = obj.calculateCohenD(unetData, attentionData);
                
                testResults{i} = sprintf('%s: %s p=%.4f, d=%.3f', ...
                    upper(metric), testType, pValue, effectSize);
            end
            
            % Adicionar texto com resultados dos testes
            annotation(fig, 'textbox', [0.02, 0.02, 0.96, 0.15], ...
                'String', ['Testes Estatísticos:' sprintf('\n%s', testResults{:})], ...
                'FontSize', obj.FONT_SIZE_TICK, ...
                'BackgroundColor', 'white', ...
                'EdgeColor', 'black', ...
                'FitBoxToText', 'on');
        end
        
        function isNormal = testNormality(obj, data)
            % Teste simples de normalidade baseado em skewness e kurtosis
            
            if length(data) < 3
                isNormal = true;
                return;
            end
            
            % Calcular skewness e kurtosis
            skew = skewness(data);
            kurt = kurtosis(data);
            
            % Critérios simples para normalidade
            isNormal = abs(skew) < 2 && abs(kurt - 3) < 2;
        end
        
        function pValue = mannWhitneyTest(obj, x, y)
            % Implementação simplificada do teste de Mann-Whitney
            
            n1 = length(x);
            n2 = length(y);
            
            % Combinar e ranquear
            combined = [x(:); y(:)];
            [~, ranks] = sort(combined);
            rankSum1 = sum(ranks(1:n1));
            
            % Calcular estatística U
            U1 = rankSum1 - n1 * (n1 + 1) / 2;
            U2 = n1 * n2 - U1;
            U = min(U1, U2);
            
            % Aproximação normal para p-value (simplificada)
            meanU = n1 * n2 / 2;
            stdU = sqrt(n1 * n2 * (n1 + n2 + 1) / 12);
            
            if stdU > 0
                z = (U - meanU) / stdU;
                pValue = 2 * (1 - normcdf(abs(z)));
            else
                pValue = 1;
            end
        end
        
        function d = calculateCohenD(obj, x, y)
            % Calcula Cohen's d (effect size)
            
            mean1 = mean(x);
            mean2 = mean(y);
            
            n1 = length(x);
            n2 = length(y);
            
            % Pooled standard deviation
            pooledStd = sqrt(((n1-1)*var(x) + (n2-1)*var(y)) / (n1+n2-2));
            
            if pooledStd > 0
                d = (mean1 - mean2) / pooledStd;
            else
                d = 0;
            end
        end
        
        function outputPath = createPerformanceEvolution(obj, trainingHistory, varargin)
            % Cria gráfico de evolução da performance durante treinamento
            %
            % Inputs:
            %   trainingHistory - Struct com histórico de treinamento
            %
            % Output:
            %   outputPath - Caminho do arquivo salvo
            
            % Parse optional arguments
            p = inputParser;
            addParameter(p, 'filename', '', @ischar);
            addParameter(p, 'title', 'Evolução da Performance', @ischar);
            parse(p, varargin{:});
            
            try
                % Criar figura
                fig = figure('Position', [100, 100, obj.DEFAULT_FIGURE_SIZE]);
                set(fig, 'Color', 'white');
                
                % Subplot para loss
                subplot(2, 2, 1);
                if isfield(trainingHistory, 'unet') && isfield(trainingHistory.unet, 'loss')
                    plot(trainingHistory.unet.loss, 'Color', obj.COLORS{1}, 'LineWidth', 2);
                    hold on;
                end
                if isfield(trainingHistory, 'attention') && isfield(trainingHistory.attention, 'loss')
                    plot(trainingHistory.attention.loss, 'Color', obj.COLORS{2}, 'LineWidth', 2);
                end
                title('Loss durante Treinamento', 'FontSize', obj.FONT_SIZE_TITLE);
                xlabel('Época', 'FontSize', obj.FONT_SIZE_LABEL);
                ylabel('Loss', 'FontSize', obj.FONT_SIZE_LABEL);
                legend({'U-Net', 'Attention U-Net'}, 'Location', 'best');
                grid on;
                
                % Subplot para IoU
                subplot(2, 2, 2);
                if isfield(trainingHistory, 'unet') && isfield(trainingHistory.unet, 'iou')
                    plot(trainingHistory.unet.iou, 'Color', obj.COLORS{1}, 'LineWidth', 2);
                    hold on;
                end
                if isfield(trainingHistory, 'attention') && isfield(trainingHistory.attention, 'iou')
                    plot(trainingHistory.attention.iou, 'Color', obj.COLORS{2}, 'LineWidth', 2);
                end
                title('IoU durante Treinamento', 'FontSize', obj.FONT_SIZE_TITLE);
                xlabel('Época', 'FontSize', obj.FONT_SIZE_LABEL);
                ylabel('IoU', 'FontSize', obj.FONT_SIZE_LABEL);
                legend({'U-Net', 'Attention U-Net'}, 'Location', 'best');
                grid on;
                
                % Subplot para Dice
                subplot(2, 2, 3);
                if isfield(trainingHistory, 'unet') && isfield(trainingHistory.unet, 'dice')
                    plot(trainingHistory.unet.dice, 'Color', obj.COLORS{1}, 'LineWidth', 2);
                    hold on;
                end
                if isfield(trainingHistory, 'attention') && isfield(trainingHistory.attention, 'dice')
                    plot(trainingHistory.attention.dice, 'Color', obj.COLORS{2}, 'LineWidth', 2);
                end
                title('Dice durante Treinamento', 'FontSize', obj.FONT_SIZE_TITLE);
                xlabel('Época', 'FontSize', obj.FONT_SIZE_LABEL);
                ylabel('Dice', 'FontSize', obj.FONT_SIZE_LABEL);
                legend({'U-Net', 'Attention U-Net'}, 'Location', 'best');
                grid on;
                
                % Subplot para Accuracy
                subplot(2, 2, 4);
                if isfield(trainingHistory, 'unet') && isfield(trainingHistory.unet, 'accuracy')
                    plot(trainingHistory.unet.accuracy, 'Color', obj.COLORS{1}, 'LineWidth', 2);
                    hold on;
                end
                if isfield(trainingHistory, 'attention') && isfield(trainingHistory.attention, 'accuracy')
                    plot(trainingHistory.attention.accuracy, 'Color', obj.COLORS{2}, 'LineWidth', 2);
                end
                title('Accuracy durante Treinamento', 'FontSize', obj.FONT_SIZE_TITLE);
                xlabel('Época', 'FontSize', obj.FONT_SIZE_LABEL);
                ylabel('Accuracy', 'FontSize', obj.FONT_SIZE_LABEL);
                legend({'U-Net', 'Attention U-Net'}, 'Location', 'best');
                grid on;
                
                % Título geral
                sgtitle(p.Results.title, 'FontSize', obj.FONT_SIZE_TITLE + 2);
                
                % Salvar figura
                if isempty(p.Results.filename)
                    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                    filename = sprintf('performance_evolution_%s.%s', timestamp, obj.figureFormat);
                else
                    filename = p.Results.filename;
                end
                
                outputPath = fullfile(obj.outputDirectory, filename);
                
                if obj.saveHighRes
                    print(fig, outputPath, ['-d' obj.figureFormat], ['-r' num2str(obj.DEFAULT_DPI)]);
                else
                    saveas(fig, outputPath);
                end
                
                close(fig);
                
                if obj.showProgress
                    fprintf('Gráfico de evolução salvo em: %s\n', outputPath);
                end
                
            catch ME
                if exist('fig', 'var') && ishandle(fig)
                    close(fig);
                end
                error('Erro ao criar gráfico de evolução: %s', ME.message);
            end
        end
    end
end