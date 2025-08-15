classdef VisualizationExporter < handle
    % VisualizationExporter - Exportação de visualizações em alta resolução
    % 
    % Esta classe implementa exportação de visualizações e gráficos
    % em alta resolução para publicação científica
    %
    % Uso:
    %   exporter = VisualizationExporter();
    %   exporter.exportFigure(fig, 'figure.png', 'DPI', 300);
    %   exporter.exportComparisonGrid(images, 'comparison.tiff');
    
    properties (Access = private)
        outputDirectory
        defaultDPI
        defaultFormat
        compressionQuality
    end
    
    methods
        function obj = VisualizationExporter(varargin)
            % Constructor - Inicializa o exportador de visualizações
            %
            % Parâmetros:
            %   'OutputDirectory' - Diretório de saída (padrão: 'output/figures')
            %   'DefaultDPI' - DPI padrão (padrão: 300)
            %   'DefaultFormat' - Formato padrão ('png', 'tiff', 'eps', 'pdf')
            %   'CompressionQuality' - Qualidade de compressão (padrão: 95)
            
            p = inputParser;
            addParameter(p, 'OutputDirectory', 'output/figures', @ischar);
            addParameter(p, 'DefaultDPI', 300, @isnumeric);
            addParameter(p, 'DefaultFormat', 'png', @ischar);
            addParameter(p, 'CompressionQuality', 95, @isnumeric);
            parse(p, varargin{:});
            
            obj.outputDirectory = p.Results.OutputDirectory;
            obj.defaultDPI = p.Results.DefaultDPI;
            obj.defaultFormat = p.Results.DefaultFormat;
            obj.compressionQuality = p.Results.CompressionQuality;
            
            % Criar diretório se não existir
            if ~exist(obj.outputDirectory, 'dir')
                mkdir(obj.outputDirectory);
            end
        end
        
        function filepath = exportFigure(obj, figHandle, filename, varargin)
            % Exporta figura MATLAB em alta resolução
            %
            % Parâmetros:
            %   figHandle - Handle da figura
            %   filename - Nome do arquivo
            %   'DPI' - Resolução em DPI (padrão: obj.defaultDPI)
            %   'Format' - Formato do arquivo (padrão: obj.defaultFormat)
            %   'Transparent' - Fundo transparente (padrão: false)
            %   'PaperSize' - Tamanho do papel [width, height] em polegadas
            
            p = inputParser;
            addParameter(p, 'DPI', obj.defaultDPI, @isnumeric);
            addParameter(p, 'Format', obj.defaultFormat, @ischar);
            addParameter(p, 'Transparent', false, @islogical);
            addParameter(p, 'PaperSize', [], @isnumeric);
            parse(p, varargin{:});
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('figure_%s.%s', timestamp, p.Results.Format);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Configurar figura para exportação
                obj.prepareFigureForExport(figHandle, p.Results.PaperSize);
                
                % Configurar opções de exportação
                exportOptions = {'-r', sprintf('%d', p.Results.DPI)};
                
                % Adicionar formato
                switch lower(p.Results.Format)
                    case 'png'
                        exportOptions = [exportOptions, {'-dpng'}];
                    case 'tiff'
                        exportOptions = [exportOptions, {'-dtiff'}];
                    case 'eps'
                        exportOptions = [exportOptions, {'-depsc'}];
                    case 'pdf'
                        exportOptions = [exportOptions, {'-dpdf'}];
                    case 'svg'
                        exportOptions = [exportOptions, {'-dsvg'}];
                    otherwise
                        exportOptions = [exportOptions, {'-dpng'}];
                end
                
                % Adicionar transparência se solicitado
                if p.Results.Transparent && ismember(lower(p.Results.Format), {'png', 'tiff'})
                    exportOptions = [exportOptions, {'-transparent'}];
                end
                
                % Exportar figura
                print(figHandle, filepath, exportOptions{:});
                
                fprintf('Figura exportada: %s\n', filepath);
                
            catch ME
                error('VisualizationExporter:ExportError', ...
                    'Erro ao exportar figura: %s', ME.message);
            end
        end
        
        function filepath = exportComparisonGrid(obj, images, filename, varargin)
            % Exporta grade de comparação de imagens
            %
            % Parâmetros:
            %   images - Cell array com imagens ou estrutura com campos de imagem
            %   filename - Nome do arquivo
            %   'GridSize' - Tamanho da grade [rows, cols] (auto se vazio)
            %   'Labels' - Labels para cada imagem
            %   'Colormap' - Colormap a usar (padrão: 'gray')
            %   'ShowColorbar' - Mostrar colorbar (padrão: false)
            
            p = inputParser;
            addParameter(p, 'GridSize', [], @isnumeric);
            addParameter(p, 'Labels', {}, @iscell);
            addParameter(p, 'Colormap', 'gray', @ischar);
            addParameter(p, 'ShowColorbar', false, @islogical);
            addParameter(p, 'DPI', obj.defaultDPI, @isnumeric);
            parse(p, varargin{:});
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('comparison_grid_%s.png', timestamp);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Preparar imagens
                if isstruct(images)
                    imageList = obj.structToImageList(images);
                elseif iscell(images)
                    imageList = images;
                else
                    error('VisualizationExporter:InvalidInput', 'Imagens devem ser cell array ou struct');
                end
                
                numImages = length(imageList);
                
                % Determinar tamanho da grade
                if isempty(p.Results.GridSize)
                    cols = ceil(sqrt(numImages));
                    rows = ceil(numImages / cols);
                else
                    rows = p.Results.GridSize(1);
                    cols = p.Results.GridSize(2);
                end
                
                % Criar figura
                fig = figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);
                
                % Plotar imagens
                for i = 1:numImages
                    subplot(rows, cols, i);
                    
                    img = imageList{i};
                    if size(img, 3) == 1
                        imshow(img, 'Colormap', colormap(p.Results.Colormap));
                    else
                        imshow(img);
                    end
                    
                    % Adicionar label se fornecido
                    if i <= length(p.Results.Labels)
                        title(p.Results.Labels{i}, 'FontSize', 12, 'FontWeight', 'bold');
                    end
                    
                    axis off;
                end
                
                % Adicionar colorbar se solicitado
                if p.Results.ShowColorbar
                    colorbar('Position', [0.92, 0.1, 0.02, 0.8]);
                end
                
                % Ajustar layout
                sgtitle('Comparação de Segmentações', 'FontSize', 16, 'FontWeight', 'bold');
                
                % Exportar
                obj.exportFigure(fig, filename, 'DPI', p.Results.DPI);
                
                % Fechar figura
                close(fig);
                
                fprintf('Grade de comparação exportada: %s\n', filepath);
                
            catch ME
                error('VisualizationExporter:GridExportError', ...
                    'Erro ao exportar grade: %s', ME.message);
            end
        end
        
        function filepath = exportMetricsPlot(obj, metrics, filename, varargin)
            % Exporta gráfico de métricas
            %
            % Parâmetros:
            %   metrics - Estrutura com métricas (IoU, Dice, etc.)
            %   filename - Nome do arquivo
            %   'PlotType' - Tipo de gráfico ('boxplot', 'histogram', 'scatter')
            %   'CompareModels' - Comparar múltiplos modelos (padrão: false)
            
            p = inputParser;
            addParameter(p, 'PlotType', 'boxplot', @ischar);
            addParameter(p, 'CompareModels', false, @islogical);
            addParameter(p, 'DPI', obj.defaultDPI, @isnumeric);
            parse(p, varargin{:});
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('metrics_plot_%s.png', timestamp);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Criar figura
                fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 600]);
                
                switch lower(p.Results.PlotType)
                    case 'boxplot'
                        obj.createBoxplot(metrics, p.Results.CompareModels);
                    case 'histogram'
                        obj.createHistogram(metrics, p.Results.CompareModels);
                    case 'scatter'
                        obj.createScatterplot(metrics, p.Results.CompareModels);
                    otherwise
                        obj.createBoxplot(metrics, p.Results.CompareModels);
                end
                
                % Exportar
                obj.exportFigure(fig, filename, 'DPI', p.Results.DPI);
                
                % Fechar figura
                close(fig);
                
                fprintf('Gráfico de métricas exportado: %s\n', filepath);
                
            catch ME
                error('VisualizationExporter:MetricsPlotError', ...
                    'Erro ao exportar gráfico de métricas: %s', ME.message);
            end
        end
        
        function filepath = exportTrainingCurves(obj, trainingHistory, filename, varargin)
            % Exporta curvas de treinamento
            %
            % Parâmetros:
            %   trainingHistory - Histórico de treinamento
            %   filename - Nome do arquivo
            %   'ShowValidation' - Mostrar curvas de validação (padrão: true)
            
            p = inputParser;
            addParameter(p, 'ShowValidation', true, @islogical);
            addParameter(p, 'DPI', obj.defaultDPI, @isnumeric);
            parse(p, varargin{:});
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('training_curves_%s.png', timestamp);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Criar figura
                fig = figure('Visible', 'off', 'Position', [100, 100, 1200, 400]);
                
                % Subplot para loss
                subplot(1, 2, 1);
                if isfield(trainingHistory, 'TrainingLoss')
                    plot(trainingHistory.TrainingLoss, 'b-', 'LineWidth', 2);
                    hold on;
                    if p.Results.ShowValidation && isfield(trainingHistory, 'ValidationLoss')
                        plot(trainingHistory.ValidationLoss, 'r--', 'LineWidth', 2);
                        legend('Treinamento', 'Validação', 'Location', 'best');
                    end
                    xlabel('Época');
                    ylabel('Loss');
                    title('Curva de Loss');
                    grid on;
                end
                
                % Subplot para acurácia
                subplot(1, 2, 2);
                if isfield(trainingHistory, 'TrainingAccuracy')
                    plot(trainingHistory.TrainingAccuracy, 'b-', 'LineWidth', 2);
                    hold on;
                    if p.Results.ShowValidation && isfield(trainingHistory, 'ValidationAccuracy')
                        plot(trainingHistory.ValidationAccuracy, 'r--', 'LineWidth', 2);
                        legend('Treinamento', 'Validação', 'Location', 'best');
                    end
                    xlabel('Época');
                    ylabel('Acurácia');
                    title('Curva de Acurácia');
                    grid on;
                end
                
                sgtitle('Histórico de Treinamento', 'FontSize', 16, 'FontWeight', 'bold');
                
                % Exportar
                obj.exportFigure(fig, filename, 'DPI', p.Results.DPI);
                
                % Fechar figura
                close(fig);
                
                fprintf('Curvas de treinamento exportadas: %s\n', filepath);
                
            catch ME
                error('VisualizationExporter:TrainingCurvesError', ...
                    'Erro ao exportar curvas de treinamento: %s', ME.message);
            end
        end
        
        function filepath = exportSegmentationOverlay(obj, originalImage, segmentation, filename, varargin)
            % Exporta sobreposição de segmentação
            %
            % Parâmetros:
            %   originalImage - Imagem original
            %   segmentation - Máscara de segmentação
            %   filename - Nome do arquivo
            %   'Alpha' - Transparência da sobreposição (padrão: 0.5)
            %   'ColorMap' - Colormap para segmentação (padrão: 'jet')
            
            p = inputParser;
            addParameter(p, 'Alpha', 0.5, @isnumeric);
            addParameter(p, 'ColorMap', 'jet', @ischar);
            addParameter(p, 'DPI', obj.defaultDPI, @isnumeric);
            parse(p, varargin{:});
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('segmentation_overlay_%s.png', timestamp);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Criar figura
                fig = figure('Visible', 'off', 'Position', [100, 100, 800, 600]);
                
                % Mostrar imagem original
                imshow(originalImage);
                hold on;
                
                % Criar overlay colorido
                if max(segmentation(:)) > 1
                    segmentation = segmentation / max(segmentation(:));
                end
                
                % Aplicar colormap
                cmap = colormap(p.Results.ColorMap);
                segmentationRGB = ind2rgb(uint8(segmentation * 255), cmap);
                
                % Mostrar overlay com transparência
                h = imshow(segmentationRGB);
                set(h, 'AlphaData', segmentation * p.Results.Alpha);
                
                title('Sobreposição de Segmentação', 'FontSize', 14, 'FontWeight', 'bold');
                axis off;
                
                % Exportar
                obj.exportFigure(fig, filename, 'DPI', p.Results.DPI);
                
                % Fechar figura
                close(fig);
                
                fprintf('Sobreposição exportada: %s\n', filepath);
                
            catch ME
                error('VisualizationExporter:OverlayError', ...
                    'Erro ao exportar sobreposição: %s', ME.message);
            end
        end
        
        function success = exportMultipleFormats(obj, figHandle, baseName, formats)
            % Exporta figura em múltiplos formatos
            %
            % Parâmetros:
            %   figHandle - Handle da figura
            %   baseName - Nome base do arquivo (sem extensão)
            %   formats - Cell array com formatos desejados
            
            success = true;
            
            try
                for i = 1:length(formats)
                    format = formats{i};
                    filename = sprintf('%s.%s', baseName, format);
                    
                    try
                        obj.exportFigure(figHandle, filename, 'Format', format);
                    catch ME
                        warning('VisualizationExporter:FormatError', ...
                            'Erro ao exportar formato %s: %s', format, ME.message);
                        success = false;
                    end
                end
                
            catch ME
                error('VisualizationExporter:MultipleFormatsError', ...
                    'Erro na exportação múltipla: %s', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function prepareFigureForExport(obj, figHandle, paperSize)
            % Prepara figura para exportação em alta qualidade
            
            % Configurar propriedades da figura
            set(figHandle, 'Color', 'white');
            set(figHandle, 'InvertHardcopy', 'off');
            
            % Configurar tamanho do papel se especificado
            if ~isempty(paperSize)
                set(figHandle, 'PaperUnits', 'inches');
                set(figHandle, 'PaperSize', paperSize);
                set(figHandle, 'PaperPosition', [0, 0, paperSize]);
            else
                set(figHandle, 'PaperPositionMode', 'auto');
            end
            
            % Configurar renderer para melhor qualidade
            set(figHandle, 'Renderer', 'painters');
        end
        
        function imageList = structToImageList(obj, imageStruct)
            % Converte estrutura de imagens para cell array
            
            imageList = {};
            fields = fieldnames(imageStruct);
            
            for i = 1:length(fields)
                field = fields{i};
                value = imageStruct.(field);
                
                if isnumeric(value) && ndims(value) >= 2
                    imageList{end+1} = value;
                end
            end
        end
        
        function createBoxplot(obj, metrics, compareModels)
            % Cria boxplot das métricas
            
            if compareModels && isstruct(metrics) && isfield(metrics, 'unet') && isfield(metrics, 'attention')
                % Comparação entre modelos
                unetMetrics = metrics.unet;
                attentionMetrics = metrics.attention;
                
                if isfield(unetMetrics, 'iou') && isfield(attentionMetrics, 'iou')
                    data = [unetMetrics.iou(:); attentionMetrics.iou(:)];
                    groups = [repmat({'U-Net'}, length(unetMetrics.iou), 1); ...
                             repmat({'Attention U-Net'}, length(attentionMetrics.iou), 1)];
                    
                    boxplot(data, groups);
                    ylabel('IoU');
                    title('Comparação de IoU entre Modelos');
                end
            else
                % Métricas de um modelo
                if isfield(metrics, 'iou')
                    boxplot(metrics.iou);
                    ylabel('IoU');
                    title('Distribuição de IoU');
                end
            end
            
            grid on;
        end
        
        function createHistogram(obj, metrics, compareModels)
            % Cria histograma das métricas
            
            if compareModels && isstruct(metrics) && isfield(metrics, 'unet') && isfield(metrics, 'attention')
                % Comparação entre modelos
                unetMetrics = metrics.unet;
                attentionMetrics = metrics.attention;
                
                if isfield(unetMetrics, 'iou') && isfield(attentionMetrics, 'iou')
                    histogram(unetMetrics.iou, 'FaceAlpha', 0.7, 'DisplayName', 'U-Net');
                    hold on;
                    histogram(attentionMetrics.iou, 'FaceAlpha', 0.7, 'DisplayName', 'Attention U-Net');
                    legend('show');
                    xlabel('IoU');
                    ylabel('Frequência');
                    title('Distribuição de IoU');
                end
            else
                % Métricas de um modelo
                if isfield(metrics, 'iou')
                    histogram(metrics.iou);
                    xlabel('IoU');
                    ylabel('Frequência');
                    title('Distribuição de IoU');
                end
            end
            
            grid on;
        end
        
        function createScatterplot(obj, metrics, compareModels)
            % Cria scatter plot das métricas
            
            if isfield(metrics, 'iou') && isfield(metrics, 'dice')
                if compareModels && isstruct(metrics) && isfield(metrics, 'unet') && isfield(metrics, 'attention')
                    % Comparação entre modelos
                    unetMetrics = metrics.unet;
                    attentionMetrics = metrics.attention;
                    
                    scatter(unetMetrics.iou, unetMetrics.dice, 'b', 'filled', 'DisplayName', 'U-Net');
                    hold on;
                    scatter(attentionMetrics.iou, attentionMetrics.dice, 'r', 'filled', 'DisplayName', 'Attention U-Net');
                    legend('show');
                else
                    % Métricas de um modelo
                    scatter(metrics.iou, metrics.dice, 'filled');
                end
                
                xlabel('IoU');
                ylabel('Dice');
                title('Correlação IoU vs Dice');
                grid on;
            end
        end
    end
end