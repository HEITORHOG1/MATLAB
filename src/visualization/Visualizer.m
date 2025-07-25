classdef Visualizer < handle
    % ========================================================================
    % VISUALIZER - SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe para criação de visualizações comparativas entre modelos
    %   U-Net e Attention U-Net, incluindo gráficos de métricas, comparações
    %   de predições e visualizações estatísticas.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Data Visualization
    %   - Statistical Plots
    %   - Image Processing and Computer Vision
    %
    % USO:
    %   >> visualizer = Visualizer();
    %   >> visualizer.createComparisonPlot(results);
    %   >> visualizer.createPredictionComparison(images, pred1, pred2, gt);
    %
    % REQUISITOS: 4.1, 4.2
    % ========================================================================
    
    properties (Access = private)
        logger
        outputDir = 'output/visualizations'
        
        % Configurações de visualização
        figureSize = [800, 600]
        figureResolution = 300
        colorScheme = 'default'
        fontSize = 12
        lineWidth = 2
        
        % Cores para modelos
        unetColor = [0.2, 0.4, 0.8]      % Azul
        attentionColor = [0.8, 0.2, 0.4] % Vermelho
        
        % Configurações de salvamento
        saveFormats = {'png', 'fig'}
        autoSave = true
    end
    
    properties (Constant)
        SUPPORTED_FORMATS = {'png', 'jpg', 'pdf', 'eps', 'fig'}
        COLOR_SCHEMES = {'default', 'colorblind', 'grayscale', 'high_contrast'}
        METRICS_NAMES = {'IoU', 'Dice', 'Accuracy'}
    end
    
    methods
        function obj = Visualizer(varargin)
            % Construtor da classe Visualizer
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'OutputDir' - diretório de saída (padrão: 'output/visualizations')
            %     'ColorScheme' - esquema de cores (padrão: 'default')
            %     'FigureSize' - tamanho das figuras (padrão: [800, 600])
            %     'AutoSave' - salvar automaticamente (padrão: true)
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'OutputDir', 'output/visualizations', @ischar);
            addParameter(p, 'ColorScheme', 'default', @(x) ismember(x, obj.COLOR_SCHEMES));
            addParameter(p, 'FigureSize', [800, 600], @(x) isnumeric(x) && length(x) == 2);
            addParameter(p, 'AutoSave', true, @islogical);
            parse(p, varargin{:});
            
            obj.outputDir = p.Results.OutputDir;
            obj.colorScheme = p.Results.ColorScheme;
            obj.figureSize = p.Results.FigureSize;
            obj.autoSave = p.Results.AutoSave;
            
            % Inicializar componentes
            obj.initializeLogger();
            obj.initializeOutputDirectory();
            obj.setupColorScheme();
            
            obj.logger('info', 'Visualizer inicializado');
            obj.logger('info', sprintf('Esquema: %s, Saída: %s', obj.colorScheme, obj.outputDir));
        end
        
        function figHandle = createComparisonPlot(obj, results, varargin)
            % Cria gráfico comparativo de métricas entre modelos
            %
            % ENTRADA:
            %   results - estrutura com resultados da comparação
            %   varargin - parâmetros opcionais:
            %     'Title' - título do gráfico (padrão: auto)
            %     'ShowErrorBars' - mostrar barras de erro (padrão: true)
            %     'ShowStatistics' - mostrar significância estatística (padrão: true)
            %
            % SAÍDA:
            %   figHandle - handle da figura criada
            %
            % REQUISITOS: 4.1 (comparações visuais lado a lado das predições)
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Title', '', @ischar);
            addParameter(p, 'ShowErrorBars', true, @islogical);
            addParameter(p, 'ShowStatistics', true, @islogical);
            parse(p, varargin{:});
            
            title_str = p.Results.Title;
            showErrorBars = p.Results.ShowErrorBars;
            showStatistics = p.Results.ShowStatistics;
            
            if isempty(title_str)
                title_str = 'Comparação de Performance: U-Net vs Attention U-Net';
            end
            
            obj.logger('info', '📊 Criando gráfico de comparação...');
            
            try
                % Validar dados
                if ~obj.validateResultsForComparison(results)
                    error('Dados insuficientes para criar gráfico de comparação');
                end
                
                % Extrair métricas
                [unetMetrics, attentionMetrics] = obj.extractMetricsForComparison(results);
                
                % Criar figura
                figHandle = figure('Position', [100, 100, obj.figureSize]);
                
                % Configurar subplot para múltiplas métricas
                metrics = fieldnames(unetMetrics);
                numMetrics = length(metrics);
                
                if numMetrics <= 3
                    subplot_rows = 1;
                    subplot_cols = numMetrics;
                else
                    subplot_rows = ceil(numMetrics / 3);
                    subplot_cols = 3;
                end
                
                % Criar subplots para cada métrica
                for i = 1:numMetrics
                    metric = metrics{i};
                    subplot(subplot_rows, subplot_cols, i);
                    
                    obj.createSingleMetricComparison(unetMetrics.(metric), ...
                        attentionMetrics.(metric), metric, showErrorBars, showStatistics, results);
                end
                
                % Configurar título geral
                sgtitle(title_str, 'FontSize', obj.fontSize + 2, 'FontWeight', 'bold');
                
                % Ajustar layout
                obj.adjustFigureLayout(figHandle);
                
                % Salvar se habilitado
                if obj.autoSave
                    filename = obj.generateFilename('comparison_plot');
                    obj.saveFigure(figHandle, filename);
                end
                
                obj.logger('success', 'Gráfico de comparação criado');
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar gráfico: %s', ME.message));
                figHandle = [];
                rethrow(ME);
            end
        end
        
        function figHandle = createPredictionComparison(obj, images, pred1, pred2, groundTruth, varargin)
            % Cria comparação visual de predições dos modelos
            %
            % ENTRADA:
            %   images - imagens originais
            %   pred1 - predições do primeiro modelo (U-Net)
            %   pred2 - predições do segundo modelo (Attention U-Net)
            %   groundTruth - máscaras verdadeiras
            %   varargin - parâmetros opcionais:
            %     'NumSamples' - número de amostras a mostrar (padrão: 6)
            %     'Title' - título do gráfico (padrão: auto)
            %
            % SAÍDA:
            %   figHandle - handle da figura criada
            %
            % REQUISITOS: 4.2 (gráficos de barras e boxplots comparativos)
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'NumSamples', 6, @(x) isnumeric(x) && x > 0);
            addParameter(p, 'Title', '', @ischar);
            parse(p, varargin{:});
            
            numSamples = min(p.Results.NumSamples, size(images, 4));
            title_str = p.Results.Title;
            
            if isempty(title_str)
                title_str = 'Comparação de Predições: U-Net vs Attention U-Net';
            end
            
            obj.logger('info', '🖼️ Criando comparação de predições...');
            
            try
                % Validar dimensões
                if size(images, 4) ~= size(pred1, 4) || size(pred1, 4) ~= size(pred2, 4) || ...
                   size(pred2, 4) ~= size(groundTruth, 4)
                    error('Dimensões inconsistentes entre imagens, predições e ground truth');
                end
                
                % Selecionar amostras aleatórias
                totalSamples = size(images, 4);
                if totalSamples > numSamples
                    indices = randperm(totalSamples, numSamples);
                else
                    indices = 1:totalSamples;
                    numSamples = totalSamples;
                end
                
                % Criar figura
                figHandle = figure('Position', [50, 50, obj.figureSize(1) * 2, obj.figureSize(2) * 1.5]);
                
                % Layout: 5 colunas (Original, Ground Truth, U-Net, Attention U-Net, Diferença)
                cols = 5;
                
                for i = 1:numSamples
                    idx = indices(i);
                    
                    % Imagem original
                    subplot(numSamples, cols, (i-1)*cols + 1);
                    obj.displayImage(images(:,:,:,idx), 'Original');
                    
                    % Ground truth
                    subplot(numSamples, cols, (i-1)*cols + 2);
                    obj.displayMask(groundTruth(:,:,idx), 'Ground Truth');
                    
                    % Predição U-Net
                    subplot(numSamples, cols, (i-1)*cols + 3);
                    obj.displayMask(pred1(:,:,idx), 'U-Net', obj.unetColor);
                    
                    % Predição Attention U-Net
                    subplot(numSamples, cols, (i-1)*cols + 4);
                    obj.displayMask(pred2(:,:,idx), 'Attention U-Net', obj.attentionColor);
                    
                    % Diferença entre predições
                    subplot(numSamples, cols, (i-1)*cols + 5);
                    obj.displayDifference(pred1(:,:,idx), pred2(:,:,idx), 'Diferença');
                end
                
                % Configurar título geral
                sgtitle(title_str, 'FontSize', obj.fontSize + 2, 'FontWeight', 'bold');
                
                % Ajustar layout
                obj.adjustFigureLayout(figHandle);
                
                % Salvar se habilitado
                if obj.autoSave
                    filename = obj.generateFilename('prediction_comparison');
                    obj.saveFigure(figHandle, filename);
                end
                
                obj.logger('success', 'Comparação de predições criada');
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar comparação: %s', ME.message));
                figHandle = [];
                rethrow(ME);
            end
        end
        
        function figHandle = createMetricsBoxplot(obj, results, varargin)
            % Cria boxplot das métricas para comparação estatística
            %
            % ENTRADA:
            %   results - estrutura com resultados
            %   varargin - parâmetros opcionais:
            %     'Title' - título do gráfico (padrão: auto)
            %
            % SAÍDA:
            %   figHandle - handle da figura criada
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Title', 'Distribuição de Métricas por Modelo', @ischar);
            parse(p, varargin{:});
            
            title_str = p.Results.Title;
            
            obj.logger('info', '📦 Criando boxplot de métricas...');
            
            try
                % Extrair dados para boxplot
                [data, labels, groups] = obj.prepareDataForBoxplot(results);
                
                if isempty(data)
                    error('Dados insuficientes para criar boxplot');
                end
                
                % Criar figura
                figHandle = figure('Position', [150, 150, obj.figureSize]);
                
                % Criar boxplot
                boxplot(data, {groups, labels}, 'ColorGroup', groups, ...
                    'Colors', [obj.unetColor; obj.attentionColor]);
                
                % Configurar aparência
                title(title_str, 'FontSize', obj.fontSize + 2, 'FontWeight', 'bold');
                ylabel('Valor da Métrica', 'FontSize', obj.fontSize);
                xlabel('Métricas', 'FontSize', obj.fontSize);
                
                % Adicionar grid
                grid on;
                grid minor;
                
                % Configurar legenda
                legend({'U-Net', 'Attention U-Net'}, 'Location', 'best');
                
                % Ajustar layout
                obj.adjustFigureLayout(figHandle);
                
                % Salvar se habilitado
                if obj.autoSave
                    filename = obj.generateFilename('metrics_boxplot');
                    obj.saveFigure(figHandle, filename);
                end
                
                obj.logger('success', 'Boxplot de métricas criado');
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar boxplot: %s', ME.message));
                figHandle = [];
                rethrow(ME);
            end
        end
        
        function figHandle = createTrainingCurvesComparison(obj, trainingHistory1, trainingHistory2, varargin)
            % Cria comparação de curvas de treinamento
            %
            % ENTRADA:
            %   trainingHistory1 - histórico de treinamento do primeiro modelo
            %   trainingHistory2 - histórico de treinamento do segundo modelo
            %   varargin - parâmetros opcionais:
            %     'Title' - título do gráfico (padrão: auto)
            %
            % SAÍDA:
            %   figHandle - handle da figura criada
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Title', 'Comparação de Curvas de Treinamento', @ischar);
            parse(p, varargin{:});
            
            title_str = p.Results.Title;
            
            obj.logger('info', '📈 Criando comparação de curvas de treinamento...');
            
            try
                % Criar figura
                figHandle = figure('Position', [200, 200, obj.figureSize(1) * 1.5, obj.figureSize(2)]);
                
                % Subplot para loss
                subplot(1, 2, 1);
                obj.plotTrainingCurve(trainingHistory1.TrainingLoss, trainingHistory1.ValidationLoss, ...
                    'U-Net', obj.unetColor);
                hold on;
                obj.plotTrainingCurve(trainingHistory2.TrainingLoss, trainingHistory2.ValidationLoss, ...
                    'Attention U-Net', obj.attentionColor);
                
                title('Curvas de Loss', 'FontSize', obj.fontSize + 1);
                xlabel('Época', 'FontSize', obj.fontSize);
                ylabel('Loss', 'FontSize', obj.fontSize);
                legend('show', 'Location', 'best');
                grid on;
                
                % Subplot para accuracy (se disponível)
                subplot(1, 2, 2);
                if isfield(trainingHistory1, 'TrainingAccuracy') && isfield(trainingHistory2, 'TrainingAccuracy')
                    obj.plotTrainingCurve(trainingHistory1.TrainingAccuracy, trainingHistory1.ValidationAccuracy, ...
                        'U-Net', obj.unetColor);
                    hold on;
                    obj.plotTrainingCurve(trainingHistory2.TrainingAccuracy, trainingHistory2.ValidationAccuracy, ...
                        'Attention U-Net', obj.attentionColor);
                    
                    title('Curvas de Accuracy', 'FontSize', obj.fontSize + 1);
                    xlabel('Época', 'FontSize', obj.fontSize);
                    ylabel('Accuracy', 'FontSize', obj.fontSize);
                    legend('show', 'Location', 'best');
                    grid on;
                else
                    % Placeholder se não houver dados de accuracy
                    text(0.5, 0.5, 'Dados de Accuracy\nnão disponíveis', ...
                        'HorizontalAlignment', 'center', 'FontSize', obj.fontSize);
                    axis off;
                end
                
                % Configurar título geral
                sgtitle(title_str, 'FontSize', obj.fontSize + 2, 'FontWeight', 'bold');
                
                % Ajustar layout
                obj.adjustFigureLayout(figHandle);
                
                % Salvar se habilitado
                if obj.autoSave
                    filename = obj.generateFilename('training_curves');
                    obj.saveFigure(figHandle, filename);
                end
                
                obj.logger('success', 'Comparação de curvas de treinamento criada');
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar curvas: %s', ME.message));
                figHandle = [];
                rethrow(ME);
            end
        end
        
        function savedPaths = saveFigure(obj, figHandle, filename, varargin)
            % Salva figura em múltiplos formatos
            %
            % ENTRADA:
            %   figHandle - handle da figura
            %   filename - nome base do arquivo (sem extensão)
            %   varargin - formatos adicionais
            %
            % SAÍDA:
            %   savedPaths - cell array com caminhos dos arquivos salvos
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Formats', obj.saveFormats, @iscell);
            parse(p, varargin{:});
            
            formats = p.Results.Formats;
            savedPaths = {};
            
            try
                for i = 1:length(formats)
                    format = formats{i};
                    filepath = fullfile(obj.outputDir, [filename '.' format]);
                    
                    switch lower(format)
                        case 'png'
                            print(figHandle, filepath, '-dpng', sprintf('-r%d', obj.figureResolution));
                        case 'jpg'
                            print(figHandle, filepath, '-djpeg', sprintf('-r%d', obj.figureResolution));
                        case 'pdf'
                            print(figHandle, filepath, '-dpdf', '-bestfit');
                        case 'eps'
                            print(figHandle, filepath, '-depsc');
                        case 'fig'
                            savefig(figHandle, filepath);
                        otherwise
                            obj.logger('warning', sprintf('Formato não suportado: %s', format));
                            continue;
                    end
                    
                    savedPaths{end+1} = filepath;
                end
                
                obj.logger('info', sprintf('Figura salva em %d formato(s)', length(savedPaths)));
                
            catch ME
                obj.logger('error', sprintf('Erro ao salvar figura: %s', ME.message));
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
                    prefix = '📊';
                case 'success'
                    prefix = '✅';
                case 'warning'
                    prefix = '⚠️';
                case 'error'
                    prefix = '❌';
                otherwise
                    prefix = '📝';
            end
            
            fprintf('[%s] %s [Visualizer] %s\n', timestamp, prefix, message);
        end
        
        function initializeOutputDirectory(obj)
            % Inicializa diretório de saída
            if ~exist(obj.outputDir, 'dir')
                mkdir(obj.outputDir);
                obj.logger('info', sprintf('Diretório criado: %s', obj.outputDir));
            end
        end
        
        function setupColorScheme(obj)
            % Configura esquema de cores
            switch obj.colorScheme
                case 'colorblind'
                    obj.unetColor = [0.0, 0.4, 0.7];      % Azul colorblind-friendly
                    obj.attentionColor = [0.9, 0.6, 0.0]; % Laranja colorblind-friendly
                case 'grayscale'
                    obj.unetColor = [0.3, 0.3, 0.3];      % Cinza escuro
                    obj.attentionColor = [0.7, 0.7, 0.7]; % Cinza claro
                case 'high_contrast'
                    obj.unetColor = [0.0, 0.0, 1.0];      % Azul puro
                    obj.attentionColor = [1.0, 0.0, 0.0]; % Vermelho puro
                otherwise % 'default'
                    % Manter cores padrão já definidas
            end
        end
        
        function isValid = validateResultsForComparison(obj, results)
            % Valida se os resultados são adequados para comparação
            isValid = false;
            
            try
                if ~isstruct(results) || ~isfield(results, 'models')
                    return;
                end
                
                if isfield(results.models, 'unet') && isfield(results.models, 'attentionUnet')
                    if isfield(results.models.unet, 'metrics') && ...
                       isfield(results.models.attentionUnet, 'metrics')
                        isValid = true;
                    end
                end
                
            catch
                % Manter isValid = false
            end
        end
        
        function [unetMetrics, attentionMetrics] = extractMetricsForComparison(obj, results)
            % Extrai métricas para comparação
            unetMetrics = results.models.unet.metrics;
            attentionMetrics = results.models.attentionUnet.metrics;
        end
        
        function createSingleMetricComparison(obj, unetData, attentionData, metricName, showErrorBars, showStatistics, results)
            % Cria comparação para uma única métrica
            
            % Dados para o gráfico
            models = {'U-Net', 'Attention U-Net'};
            means = [unetData.mean, attentionData.mean];
            
            % Criar barras
            bar_handles = bar(1:2, means, 'FaceColor', 'flat');
            bar_handles.CData(1,:) = obj.unetColor;
            bar_handles.CData(2,:) = obj.attentionColor;
            
            % Adicionar barras de erro se solicitado
            if showErrorBars && isfield(unetData, 'std') && isfield(attentionData, 'std')
                hold on;
                stds = [unetData.std, attentionData.std];
                errorbar(1:2, means, stds, 'k.', 'LineWidth', obj.lineWidth);
            end
            
            % Configurar aparência
            set(gca, 'XTickLabel', models);
            ylabel(sprintf('%s Score', metricName));
            title(metricName, 'FontWeight', 'bold');
            ylim([0, 1]);
            grid on;
            
            % Adicionar significância estatística se disponível
            if showStatistics && isfield(results, 'statistical') && ...
               isfield(results.statistical, lower(metricName))
                stat = results.statistical.(lower(metricName));
                if isfield(stat, 'significant') && stat.significant
                    % Adicionar asterisco indicando significância
                    y_pos = max(means) + 0.05;
                    text(1.5, y_pos, '*', 'HorizontalAlignment', 'center', ...
                        'FontSize', obj.fontSize + 4, 'FontWeight', 'bold');
                    text(1.5, y_pos - 0.03, sprintf('p=%.3f', stat.pValue), ...
                        'HorizontalAlignment', 'center', 'FontSize', obj.fontSize - 2);
                end
            end
        end
        
        function displayImage(obj, image, titleStr)
            % Exibe imagem original
            if size(image, 3) == 3
                imshow(image);
            else
                imshow(image, []);
            end
            title(titleStr, 'FontSize', obj.fontSize);
            axis off;
        end
        
        function displayMask(obj, mask, titleStr, color)
            % Exibe máscara com cor opcional
            if nargin < 4
                imshow(mask, []);
            else
                % Aplicar colormap personalizado
                imshow(mask, []);
                colormap(gca, [0 0 0; color]);
            end
            title(titleStr, 'FontSize', obj.fontSize);
            axis off;
        end
        
        function displayDifference(obj, mask1, mask2, titleStr)
            % Exibe diferença entre máscaras
            diff = abs(double(mask1) - double(mask2));
            imshow(diff, []);
            colormap(gca, 'hot');
            title(titleStr, 'FontSize', obj.fontSize);
            axis off;
        end
        
        function [data, labels, groups] = prepareDataForBoxplot(obj, results)
            % Prepara dados para boxplot
            data = [];
            labels = {};
            groups = {};
            
            try
                metrics = {'iou', 'dice', 'accuracy'};
                
                for i = 1:length(metrics)
                    metric = metrics{i};
                    
                    % Dados U-Net
                    if isfield(results.models.unet.metrics, metric) && ...
                       isfield(results.models.unet.metrics.(metric), 'values')
                        unet_values = results.models.unet.metrics.(metric).values;
                        data = [data; unet_values(:)];
                        labels = [labels; repmat({upper(metric)}, length(unet_values), 1)];
                        groups = [groups; repmat({'U-Net'}, length(unet_values), 1)];
                    end
                    
                    % Dados Attention U-Net
                    if isfield(results.models.attentionUnet.metrics, metric) && ...
                       isfield(results.models.attentionUnet.metrics.(metric), 'values')
                        attention_values = results.models.attentionUnet.metrics.(metric).values;
                        data = [data; attention_values(:)];
                        labels = [labels; repmat({upper(metric)}, length(attention_values), 1)];
                        groups = [groups; repmat({'Attention U-Net'}, length(attention_values), 1)];
                    end
                end
                
            catch ME
                obj.logger('warning', sprintf('Erro ao preparar dados para boxplot: %s', ME.message));
            end
        end
        
        function plotTrainingCurve(obj, trainData, valData, modelName, color)
            % Plota curva de treinamento individual
            epochs = 1:length(trainData);
            
            plot(epochs, trainData, '-', 'Color', color, 'LineWidth', obj.lineWidth, ...
                'DisplayName', [modelName ' (Treino)']);
            plot(epochs, valData, '--', 'Color', color, 'LineWidth', obj.lineWidth, ...
                'DisplayName', [modelName ' (Validação)']);
        end
        
        function adjustFigureLayout(obj, figHandle)
            % Ajusta layout da figura
            set(figHandle, 'Color', 'white');
            
            % Ajustar espaçamento entre subplots
            children = get(figHandle, 'Children');
            for i = 1:length(children)
                if strcmp(get(children(i), 'Type'), 'axes')
                    set(children(i), 'FontSize', obj.fontSize);
                end
            end
        end
        
        function figHandle = createDifferenceHeatmap(obj, pred1, pred2, groundTruth, varargin)
            % Cria heatmap de diferenças entre modelos
            %
            % ENTRADA:
            %   pred1 - predições do primeiro modelo
            %   pred2 - predições do segundo modelo
            %   groundTruth - máscaras verdadeiras
            %   varargin - parâmetros opcionais:
            %     'Title' - título do gráfico (padrão: auto)
            %     'NumSamples' - número de amostras (padrão: 4)
            %
            % SAÍDA:
            %   figHandle - handle da figura criada
            %
            % REQUISITOS: 4.4 (heatmaps de diferenças entre modelos)
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Title', 'Heatmap de Diferenças entre Modelos', @ischar);
            addParameter(p, 'NumSamples', 4, @(x) isnumeric(x) && x > 0);
            parse(p, varargin{:});
            
            title_str = p.Results.Title;
            numSamples = min(p.Results.NumSamples, size(pred1, 4));
            
            obj.logger('info', '🔥 Criando heatmap de diferenças...');
            
            try
                % Selecionar amostras
                totalSamples = size(pred1, 4);
                if totalSamples > numSamples
                    indices = randperm(totalSamples, numSamples);
                else
                    indices = 1:totalSamples;
                    numSamples = totalSamples;
                end
                
                % Criar figura
                figHandle = figure('Position', [100, 100, obj.figureSize(1) * 1.5, obj.figureSize(2)]);
                
                % Layout: 4 colunas (GT, U-Net Error, Attention Error, Difference)
                cols = 4;
                
                for i = 1:numSamples
                    idx = indices(i);
                    
                    % Ground Truth
                    subplot(numSamples, cols, (i-1)*cols + 1);
                    imshow(groundTruth(:,:,idx), []);
                    title('Ground Truth', 'FontSize', obj.fontSize);
                    axis off;
                    
                    % Erro U-Net (diferença com GT)
                    subplot(numSamples, cols, (i-1)*cols + 2);
                    unetError = abs(double(pred1(:,:,idx)) - double(groundTruth(:,:,idx)));
                    obj.displayHeatmap(unetError, 'Erro U-Net', 'hot');
                    
                    % Erro Attention U-Net
                    subplot(numSamples, cols, (i-1)*cols + 3);
                    attentionError = abs(double(pred2(:,:,idx)) - double(groundTruth(:,:,idx)));
                    obj.displayHeatmap(attentionError, 'Erro Attention U-Net', 'hot');
                    
                    % Diferença entre modelos
                    subplot(numSamples, cols, (i-1)*cols + 4);
                    modelDiff = abs(double(pred1(:,:,idx)) - double(pred2(:,:,idx)));
                    obj.displayHeatmap(modelDiff, 'Diferença entre Modelos', 'jet');
                end
                
                % Configurar título geral
                sgtitle(title_str, 'FontSize', obj.fontSize + 2, 'FontWeight', 'bold');
                
                % Ajustar layout
                obj.adjustFigureLayout(figHandle);
                
                % Salvar se habilitado
                if obj.autoSave
                    filename = obj.generateFilename('difference_heatmap');
                    obj.saveFigure(figHandle, filename);
                end
                
                obj.logger('success', 'Heatmap de diferenças criado');
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar heatmap: %s', ME.message));
                figHandle = [];
                rethrow(ME);
            end
        end
        
        function figHandle = createAdvancedTrainingComparison(obj, history1, history2, varargin)
            % Cria gráficos avançados de convergência de treinamento
            %
            % ENTRADA:
            %   history1 - histórico de treinamento do primeiro modelo
            %   history2 - histórico de treinamento do segundo modelo
            %   varargin - parâmetros opcionais:
            %     'Title' - título do gráfico (padrão: auto)
            %     'ShowSmoothing' - aplicar suavização (padrão: true)
            %
            % SAÍDA:
            %   figHandle - handle da figura criada
            %
            % REQUISITOS: 4.5 (gráficos de convergência de treinamento comparativos)
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Title', 'Análise Avançada de Convergência', @ischar);
            addParameter(p, 'ShowSmoothing', true, @islogical);
            parse(p, varargin{:});
            
            title_str = p.Results.Title;
            showSmoothing = p.Results.ShowSmoothing;
            
            obj.logger('info', '📈 Criando análise avançada de convergência...');
            
            try
                % Criar figura com layout 2x2
                figHandle = figure('Position', [50, 50, obj.figureSize(1) * 1.8, obj.figureSize(2) * 1.5]);
                
                % Subplot 1: Loss Comparison
                subplot(2, 2, 1);
                obj.plotAdvancedTrainingCurve(history1.TrainingLoss, history1.ValidationLoss, ...
                    'U-Net', obj.unetColor, showSmoothing);
                hold on;
                obj.plotAdvancedTrainingCurve(history2.TrainingLoss, history2.ValidationLoss, ...
                    'Attention U-Net', obj.attentionColor, showSmoothing);
                
                title('Convergência de Loss', 'FontSize', obj.fontSize + 1);
                xlabel('Época', 'FontSize', obj.fontSize);
                ylabel('Loss', 'FontSize', obj.fontSize);
                legend('show', 'Location', 'best');
                grid on;
                
                % Subplot 2: Learning Rate Effect (se disponível)
                subplot(2, 2, 2);
                if isfield(history1, 'LearningRate') && isfield(history2, 'LearningRate')
                    obj.plotLearningRateEffect(history1, history2);
                else
                    obj.plotLossDerivative(history1, history2);
                end
                
                % Subplot 3: Validation Gap Analysis
                subplot(2, 2, 3);
                obj.plotValidationGap(history1, history2);
                
                % Subplot 4: Convergence Speed Analysis
                subplot(2, 2, 4);
                obj.plotConvergenceSpeed(history1, history2);
                
                % Configurar título geral
                sgtitle(title_str, 'FontSize', obj.fontSize + 2, 'FontWeight', 'bold');
                
                % Ajustar layout
                obj.adjustFigureLayout(figHandle);
                
                % Salvar se habilitado
                if obj.autoSave
                    filename = obj.generateFilename('advanced_training_analysis');
                    obj.saveFigure(figHandle, filename);
                end
                
                obj.logger('success', 'Análise avançada de convergência criada');
                
            catch ME
                obj.logger('error', sprintf('Erro na análise de convergência: %s', ME.message));
                figHandle = [];
                rethrow(ME);
            end
        end
        
        function figHandle = createAdvancedMetricsDistribution(obj, results, varargin)
            % Cria visualizações avançadas de distribuição de métricas
            %
            % ENTRADA:
            %   results - estrutura com resultados
            %   varargin - parâmetros opcionais:
            %     'Title' - título do gráfico (padrão: auto)
            %     'ShowOutliers' - mostrar outliers (padrão: true)
            %
            % SAÍDA:
            %   figHandle - handle da figura criada
            %
            % REQUISITOS: 4.5 (visualizações de distribuição de métricas com boxplots)
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Title', 'Distribuição Avançada de Métricas', @ischar);
            addParameter(p, 'ShowOutliers', true, @islogical);
            parse(p, varargin{:});
            
            title_str = p.Results.Title;
            showOutliers = p.Results.ShowOutliers;
            
            obj.logger('info', '📊 Criando distribuição avançada de métricas...');
            
            try
                % Criar figura com layout 2x2
                figHandle = figure('Position', [150, 150, obj.figureSize(1) * 1.6, obj.figureSize(2) * 1.4]);
                
                % Subplot 1: Boxplots comparativos
                subplot(2, 2, 1);
                obj.createAdvancedBoxplot(results, showOutliers);
                
                % Subplot 2: Violin plots (se dados suficientes)
                subplot(2, 2, 2);
                obj.createViolinPlot(results);
                
                % Subplot 3: Histogramas sobrepostos
                subplot(2, 2, 3);
                obj.createOverlappedHistograms(results);
                
                % Subplot 4: Q-Q plots para normalidade
                subplot(2, 2, 4);
                obj.createQQPlots(results);
                
                % Configurar título geral
                sgtitle(title_str, 'FontSize', obj.fontSize + 2, 'FontWeight', 'bold');
                
                % Ajustar layout
                obj.adjustFigureLayout(figHandle);
                
                % Salvar se habilitado
                if obj.autoSave
                    filename = obj.generateFilename('advanced_metrics_distribution');
                    obj.saveFigure(figHandle, filename);
                end
                
                obj.logger('success', 'Distribuição avançada de métricas criada');
                
            catch ME
                obj.logger('error', sprintf('Erro na distribuição avançada: %s', ME.message));
                figHandle = [];
                rethrow(ME);
            end
        end
        
        function figHandle = createPerformanceRadarChart(obj, results, varargin)
            % Cria gráfico radar para comparação multidimensional
            %
            % ENTRADA:
            %   results - estrutura com resultados
            %   varargin - parâmetros opcionais:
            %     'Title' - título do gráfico (padrão: auto)
            %
            % SAÍDA:
            %   figHandle - handle da figura criada
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Title', 'Comparação Multidimensional de Performance', @ischar);
            parse(p, varargin{:});
            
            title_str = p.Results.Title;
            
            obj.logger('info', '🎯 Criando gráfico radar...');
            
            try
                % Extrair métricas
                metrics = {'iou', 'dice', 'accuracy'};
                unetValues = zeros(length(metrics), 1);
                attentionValues = zeros(length(metrics), 1);
                
                for i = 1:length(metrics)
                    metric = metrics{i};
                    if isfield(results.models.unet.metrics, metric)
                        unetValues(i) = results.models.unet.metrics.(metric).mean;
                    end
                    if isfield(results.models.attentionUnet.metrics, metric)
                        attentionValues(i) = results.models.attentionUnet.metrics.(metric).mean;
                    end
                end
                
                % Criar figura
                figHandle = figure('Position', [200, 200, obj.figureSize]);
                
                % Criar gráfico radar
                obj.plotRadarChart(unetValues, attentionValues, upper(metrics), title_str);
                
                % Salvar se habilitado
                if obj.autoSave
                    filename = obj.generateFilename('performance_radar');
                    obj.saveFigure(figHandle, filename);
                end
                
                obj.logger('success', 'Gráfico radar criado');
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar radar: %s', ME.message));
                figHandle = [];
                rethrow(ME);
            end
        end
        
        function filename = generateFilename(obj, prefix)
            % Gera nome de arquivo único
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            filename = sprintf('%s_%s', prefix, timestamp);
        end
        
        % Métodos auxiliares para visualizações avançadas
        function displayHeatmap(obj, data, titleStr, colormap_name)
            % Exibe heatmap com configurações personalizadas
            imagesc(data);
            colorbar;
            colormap(colormap_name);
            title(titleStr, 'FontSize', obj.fontSize);
            axis off;
        end
        
        function plotAdvancedTrainingCurve(obj, trainData, valData, modelName, color, showSmoothing)
            % Plota curva de treinamento com suavização opcional
            epochs = 1:length(trainData);
            
            if showSmoothing && length(trainData) > 5
                % Aplicar suavização com média móvel
                windowSize = max(3, floor(length(trainData) / 10));
                trainSmooth = movmean(trainData, windowSize);
                valSmooth = movmean(valData, windowSize);
                
                % Plotar dados originais (transparentes)
                plot(epochs, trainData, '-', 'Color', [color, 0.3], 'LineWidth', 1, ...
                    'HandleVisibility', 'off');
                plot(epochs, valData, '--', 'Color', [color, 0.3], 'LineWidth', 1, ...
                    'HandleVisibility', 'off');
                
                % Plotar dados suavizados
                plot(epochs, trainSmooth, '-', 'Color', color, 'LineWidth', obj.lineWidth, ...
                    'DisplayName', [modelName ' (Treino)']);
                plot(epochs, valSmooth, '--', 'Color', color, 'LineWidth', obj.lineWidth, ...
                    'DisplayName', [modelName ' (Validação)']);
            else
                % Plotar dados originais
                plot(epochs, trainData, '-', 'Color', color, 'LineWidth', obj.lineWidth, ...
                    'DisplayName', [modelName ' (Treino)']);
                plot(epochs, valData, '--', 'Color', color, 'LineWidth', obj.lineWidth, ...
                    'DisplayName', [modelName ' (Validação)']);
            end
        end
        
        function plotLearningRateEffect(obj, history1, history2)
            % Plota efeito da taxa de aprendizado
            epochs1 = 1:length(history1.LearningRate);
            epochs2 = 1:length(history2.LearningRate);
            
            yyaxis left;
            plot(epochs1, history1.LearningRate, '-', 'Color', obj.unetColor, 'LineWidth', obj.lineWidth);
            plot(epochs2, history2.LearningRate, '-', 'Color', obj.attentionColor, 'LineWidth', obj.lineWidth);
            ylabel('Learning Rate');
            
            yyaxis right;
            plot(epochs1, history1.ValidationLoss, '--', 'Color', obj.unetColor, 'LineWidth', obj.lineWidth);
            plot(epochs2, history2.ValidationLoss, '--', 'Color', obj.attentionColor, 'LineWidth', obj.lineWidth);
            ylabel('Validation Loss');
            
            title('Efeito da Taxa de Aprendizado');
            xlabel('Época');
            legend('U-Net LR', 'Attention LR', 'U-Net Val Loss', 'Attention Val Loss', 'Location', 'best');
            grid on;
        end
        
        function plotLossDerivative(obj, history1, history2)
            % Plota derivada do loss (velocidade de convergência)
            if length(history1.TrainingLoss) > 1
                epochs = 2:length(history1.TrainingLoss);
                
                unetDerivative = diff(history1.TrainingLoss);
                attentionDerivative = diff(history2.TrainingLoss);
                
                plot(epochs, unetDerivative, '-', 'Color', obj.unetColor, 'LineWidth', obj.lineWidth, ...
                    'DisplayName', 'U-Net');
                hold on;
                plot(epochs, attentionDerivative, '-', 'Color', obj.attentionColor, 'LineWidth', obj.lineWidth, ...
                    'DisplayName', 'Attention U-Net');
                
                title('Velocidade de Convergência (dLoss/dEpoch)');
                xlabel('Época');
                ylabel('Derivada do Loss');
                legend('show', 'Location', 'best');
                grid on;
            else
                text(0.5, 0.5, 'Dados insuficientes\npara derivada', 'HorizontalAlignment', 'center');
                axis off;
            end
        end
        
        function plotValidationGap(obj, history1, history2)
            % Plota gap entre treino e validação
            epochs1 = 1:length(history1.TrainingLoss);
            epochs2 = 1:length(history2.TrainingLoss);
            
            unetGap = history1.ValidationLoss - history1.TrainingLoss;
            attentionGap = history2.ValidationLoss - history2.TrainingLoss;
            
            plot(epochs1, unetGap, '-', 'Color', obj.unetColor, 'LineWidth', obj.lineWidth, ...
                'DisplayName', 'U-Net');
            hold on;
            plot(epochs2, attentionGap, '-', 'Color', obj.attentionColor, 'LineWidth', obj.lineWidth, ...
                'DisplayName', 'Attention U-Net');
            
            title('Gap Treino-Validação');
            xlabel('Época');
            ylabel('Validation Loss - Training Loss');
            legend('show', 'Location', 'best');
            grid on;
            
            % Linha de referência
            plot([1, max(length(epochs1), length(epochs2))], [0, 0], 'k--', 'Alpha', 0.5);
        end
        
        function plotConvergenceSpeed(obj, history1, history2)
            % Analisa velocidade de convergência
            % Calcular tempo para atingir 95% da performance final
            
            finalLoss1 = min(history1.ValidationLoss);
            finalLoss2 = min(history2.ValidationLoss);
            
            threshold1 = finalLoss1 * 1.05; % 5% acima do mínimo
            threshold2 = finalLoss2 * 1.05;
            
            convergenceEpoch1 = find(history1.ValidationLoss <= threshold1, 1);
            convergenceEpoch2 = find(history2.ValidationLoss <= threshold2, 1);
            
            if isempty(convergenceEpoch1), convergenceEpoch1 = length(history1.ValidationLoss); end
            if isempty(convergenceEpoch2), convergenceEpoch2 = length(history2.ValidationLoss); end
            
            % Criar gráfico de barras
            models = {'U-Net', 'Attention U-Net'};
            convergenceEpochs = [convergenceEpoch1, convergenceEpoch2];
            
            bar(1:2, convergenceEpochs, 'FaceColor', 'flat');
            colormap([obj.unetColor; obj.attentionColor]);
            
            set(gca, 'XTickLabel', models);
            title('Velocidade de Convergência');
            ylabel('Épocas para Convergência');
            
            % Adicionar valores nas barras
            for i = 1:2
                text(i, convergenceEpochs(i) + max(convergenceEpochs) * 0.02, ...
                    sprintf('%d', convergenceEpochs(i)), 'HorizontalAlignment', 'center');
            end
            
            grid on;
        end
        
        function createAdvancedBoxplot(obj, results, showOutliers)
            % Cria boxplot avançado com configurações personalizadas
            [data, labels, groups] = obj.prepareDataForBoxplot(results);
            
            if ~isempty(data)
                if showOutliers
                    boxplot(data, {groups, labels}, 'ColorGroup', groups, ...
                        'Colors', [obj.unetColor; obj.attentionColor], ...
                        'OutlierSize', 4, 'Symbol', 'ro');
                else
                    boxplot(data, {groups, labels}, 'ColorGroup', groups, ...
                        'Colors', [obj.unetColor; obj.attentionColor], ...
                        'Symbol', '');
                end
                
                title('Boxplot Avançado de Métricas');
                ylabel('Valor da Métrica');
                grid on;
            else
                text(0.5, 0.5, 'Dados insuficientes\npara boxplot', 'HorizontalAlignment', 'center');
                axis off;
            end
        end
        
        function createViolinPlot(obj, results)
            % Cria violin plot (aproximação usando histogramas)
            try
                metrics = {'iou', 'dice', 'accuracy'};
                
                for i = 1:length(metrics)
                    metric = metrics{i};
                    
                    % Dados U-Net
                    if isfield(results.models.unet.metrics, metric) && ...
                       isfield(results.models.unet.metrics.(metric), 'values')
                        unetData = results.models.unet.metrics.(metric).values;
                        
                        % Criar "violin" usando densidade
                        [counts, centers] = hist(unetData, 20);
                        counts = counts / max(counts) * 0.4; % Normalizar
                        
                        % Plotar lado esquerdo do violin
                        fill([i - counts, i + counts(end:-1:1)], [centers, centers(end:-1:1)], ...
                            obj.unetColor, 'FaceAlpha', 0.6, 'EdgeColor', 'none');
                        hold on;
                    end
                    
                    % Dados Attention U-Net
                    if isfield(results.models.attentionUnet.metrics, metric) && ...
                       isfield(results.models.attentionUnet.metrics.(metric), 'values')
                        attentionData = results.models.attentionUnet.metrics.(metric).values;
                        
                        [counts, centers] = hist(attentionData, 20);
                        counts = counts / max(counts) * 0.4;
                        
                        fill([i + 0.5 - counts, i + 0.5 + counts(end:-1:1)], [centers, centers(end:-1:1)], ...
                            obj.attentionColor, 'FaceAlpha', 0.6, 'EdgeColor', 'none');
                    end
                end
                
                set(gca, 'XTick', 1:length(metrics), 'XTickLabel', upper(metrics));
                title('Violin Plot de Distribuições');
                ylabel('Valor da Métrica');
                
            catch
                text(0.5, 0.5, 'Violin Plot\n(Implementação Simplificada)', 'HorizontalAlignment', 'center');
                axis off;
            end
        end
        
        function createOverlappedHistograms(obj, results)
            % Cria histogramas sobrepostos
            try
                % Usar apenas uma métrica para simplicidade (IoU)
                if isfield(results.models.unet.metrics, 'iou') && ...
                   isfield(results.models.unet.metrics.iou, 'values') && ...
                   isfield(results.models.attentionUnet.metrics, 'iou') && ...
                   isfield(results.models.attentionUnet.metrics.iou, 'values')
                    
                    unetData = results.models.unet.metrics.iou.values;
                    attentionData = results.models.attentionUnet.metrics.iou.values;
                    
                    % Criar histogramas
                    histogram(unetData, 15, 'FaceColor', obj.unetColor, 'FaceAlpha', 0.6, ...
                        'DisplayName', 'U-Net');
                    hold on;
                    histogram(attentionData, 15, 'FaceColor', obj.attentionColor, 'FaceAlpha', 0.6, ...
                        'DisplayName', 'Attention U-Net');
                    
                    title('Distribuição de IoU');
                    xlabel('Valor IoU');
                    ylabel('Frequência');
                    legend('show', 'Location', 'best');
                    grid on;
                else
                    text(0.5, 0.5, 'Dados insuficientes\npara histograma', 'HorizontalAlignment', 'center');
                    axis off;
                end
                
            catch
                text(0.5, 0.5, 'Erro no histograma', 'HorizontalAlignment', 'center');
                axis off;
            end
        end
        
        function createQQPlots(obj, results)
            % Cria Q-Q plots para testar normalidade
            try
                % Usar IoU como exemplo
                if isfield(results.models.unet.metrics, 'iou') && ...
                   isfield(results.models.unet.metrics.iou, 'values')
                    
                    unetData = results.models.unet.metrics.iou.values;
                    
                    % Q-Q plot simples
                    sortedData = sort(unetData);
                    n = length(sortedData);
                    theoreticalQuantiles = norminv((1:n) / (n+1));
                    
                    plot(theoreticalQuantiles, sortedData, 'o', 'Color', obj.unetColor, ...
                        'MarkerSize', 4, 'DisplayName', 'U-Net');
                    hold on;
                    
                    % Linha de referência
                    plot(theoreticalQuantiles, theoreticalQuantiles * std(sortedData) + mean(sortedData), ...
                        'r--', 'LineWidth', 2, 'DisplayName', 'Normal Teórica');
                    
                    title('Q-Q Plot (Teste de Normalidade)');
                    xlabel('Quantis Teóricos');
                    ylabel('Quantis Observados');
                    legend('show', 'Location', 'best');
                    grid on;
                else
                    text(0.5, 0.5, 'Dados insuficientes\npara Q-Q plot', 'HorizontalAlignment', 'center');
                    axis off;
                end
                
            catch
                text(0.5, 0.5, 'Q-Q Plot\n(Simplificado)', 'HorizontalAlignment', 'center');
                axis off;
            end
        end
        
        function plotRadarChart(obj, values1, values2, labels, titleStr)
            % Cria gráfico radar
            try
                % Número de variáveis
                numVars = length(values1);
                
                % Ângulos para cada variável
                angles = linspace(0, 2*pi, numVars + 1);
                
                % Fechar o polígono
                values1 = [values1; values1(1)];
                values2 = [values2; values2(1)];
                
                % Converter para coordenadas polares
                [x1, y1] = pol2cart(angles, values1);
                [x2, y2] = pol2cart(angles, values2);
                
                % Plotar
                plot(x1, y1, '-o', 'Color', obj.unetColor, 'LineWidth', obj.lineWidth, ...
                    'MarkerSize', 6, 'MarkerFaceColor', obj.unetColor, 'DisplayName', 'U-Net');
                hold on;
                plot(x2, y2, '-s', 'Color', obj.attentionColor, 'LineWidth', obj.lineWidth, ...
                    'MarkerSize', 6, 'MarkerFaceColor', obj.attentionColor, 'DisplayName', 'Attention U-Net');
                
                % Adicionar grid circular
                for r = 0.2:0.2:1.0
                    [xc, yc] = pol2cart(angles(1:end-1), repmat(r, 1, numVars));
                    plot([xc, xc(1)], [yc, yc(1)], 'k:', 'Alpha', 0.3);
                end
                
                % Adicionar linhas radiais
                for i = 1:numVars
                    [xr, yr] = pol2cart(angles(i), 1);
                    plot([0, xr], [0, yr], 'k:', 'Alpha', 0.3);
                    
                    % Adicionar labels
                    [xl, yl] = pol2cart(angles(i), 1.1);
                    text(xl, yl, labels{i}, 'HorizontalAlignment', 'center', ...
                        'FontSize', obj.fontSize);
                end
                
                axis equal;
                axis off;
                title(titleStr, 'FontSize', obj.fontSize + 1);
                legend('show', 'Location', 'best');
                
            catch ME
                text(0, 0, sprintf('Erro no radar chart:\n%s', ME.message), ...
                    'HorizontalAlignment', 'center');
                axis off;
            end
        end
    end
end