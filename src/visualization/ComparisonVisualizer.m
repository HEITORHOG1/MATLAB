classdef ComparisonVisualizer < handle
    % ComparisonVisualizer - Sistema avançado de visualização e comparação
    % 
    % Esta classe implementa funcionalidades para:
    % - Comparações lado a lado detalhadas (original, ground truth, U-Net, Attention U-Net)
    % - Geração automática de mapas de diferença com heatmaps
    % - Sobreposição de métricas (IoU, Dice) nas imagens segmentadas
    % - Galeria HTML interativa com navegação e zoom
    % - Gráficos estatísticos comparativos
    
    properties (Constant)
        % Configurações padrão de visualização
        DEFAULT_FIGURE_SIZE = [1200, 800];
        DEFAULT_DPI = 300;
        COLORMAP_DIFFERENCE = 'jet';
        FONT_SIZE_TITLE = 14;
        FONT_SIZE_METRICS = 12;
    end
    
    properties
        outputDirectory
        figureFormat
        saveHighRes
        showProgress
    end
    
    methods
        function obj = ComparisonVisualizer(varargin)
            % Constructor - Inicializa o visualizador de comparações
            %
            % Uso:
            %   visualizer = ComparisonVisualizer()
            %   visualizer = ComparisonVisualizer('outputDir', 'results/')
            
            % Parse input arguments
            p = inputParser;
            addParameter(p, 'outputDir', 'output/visualizations/', @ischar);
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
        
        function outputPath = createSideBySideComparison(obj, original, groundTruth, unetPred, attentionPred, metrics, varargin)
            % Cria comparação lado a lado detalhada com 4 painéis
            %
            % Inputs:
            %   original - Imagem original
            %   groundTruth - Ground truth (máscara verdadeira)
            %   unetPred - Predição do U-Net
            %   attentionPred - Predição do Attention U-Net
            %   metrics - Struct com métricas para cada modelo
            %
            % Output:
            %   outputPath - Caminho do arquivo salvo
            
            % Parse optional arguments
            p = inputParser;
            addParameter(p, 'title', '', @ischar);
            addParameter(p, 'filename', '', @ischar);
            parse(p, varargin{:});
            
            try
                % Criar figura com 4 subplots
                fig = figure('Position', [100, 100, obj.DEFAULT_FIGURE_SIZE]);
                set(fig, 'Color', 'white');
                
                % Subplot 1: Imagem original
                subplot(2, 2, 1);
                imshow(original);
                title('Imagem Original', 'FontSize', obj.FONT_SIZE_TITLE);
                
                % Subplot 2: Ground Truth
                subplot(2, 2, 2);
                imshow(groundTruth);
                title('Ground Truth', 'FontSize', obj.FONT_SIZE_TITLE);
                
                % Subplot 3: U-Net com métricas
                subplot(2, 2, 3);
                imshow(unetPred);
                unetTitle = sprintf('U-Net\nIoU: %.3f | Dice: %.3f', ...
                    metrics.unet.iou, metrics.unet.dice);
                title(unetTitle, 'FontSize', obj.FONT_SIZE_TITLE);
                
                % Subplot 4: Attention U-Net com métricas
                subplot(2, 2, 4);
                imshow(attentionPred);
                attentionTitle = sprintf('Attention U-Net\nIoU: %.3f | Dice: %.3f', ...
                    metrics.attention.iou, metrics.attention.dice);
                title(attentionTitle, 'FontSize', obj.FONT_SIZE_TITLE);
                
                % Título geral da figura
                if ~isempty(p.Results.title)
                    sgtitle(p.Results.title, 'FontSize', obj.FONT_SIZE_TITLE + 2);
                end
                
                % Salvar figura
                if isempty(p.Results.filename)
                    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                    filename = sprintf('comparison_sidebyside_%s.%s', timestamp, obj.figureFormat);
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
                    fprintf('Comparação lado a lado salva em: %s\n', outputPath);
                end
                
            catch ME
                if exist('fig', 'var') && ishandle(fig)
                    close(fig);
                end
                error('Erro ao criar comparação lado a lado: %s', ME.message);
            end
        end
        
        function outputPath = createDifferenceMap(obj, unetPred, attentionPred, varargin)
            % Cria mapa de diferença com heatmap destacando divergências
            %
            % Inputs:
            %   unetPred - Predição do U-Net
            %   attentionPred - Predição do Attention U-Net
            %
            % Output:
            %   outputPath - Caminho do arquivo salvo
            
            % Parse optional arguments
            p = inputParser;
            addParameter(p, 'title', 'Mapa de Diferenças', @ischar);
            addParameter(p, 'filename', '', @ischar);
            addParameter(p, 'colormap', obj.COLORMAP_DIFFERENCE, @ischar);
            parse(p, varargin{:});
            
            try
                % Converter para double se necessário
                if isa(unetPred, 'logical')
                    unetPred = double(unetPred);
                end
                if isa(attentionPred, 'logical')
                    attentionPred = double(attentionPred);
                end
                
                % Calcular diferença absoluta
                difference = abs(unetPred - attentionPred);
                
                % Criar figura
                fig = figure('Position', [100, 100, obj.DEFAULT_FIGURE_SIZE]);
                set(fig, 'Color', 'white');
                
                % Criar subplot com 3 painéis
                subplot(1, 3, 1);
                imshow(unetPred);
                title('U-Net', 'FontSize', obj.FONT_SIZE_TITLE);
                
                subplot(1, 3, 2);
                imshow(attentionPred);
                title('Attention U-Net', 'FontSize', obj.FONT_SIZE_TITLE);
                
                subplot(1, 3, 3);
                imagesc(difference);
                colormap(p.Results.colormap);
                colorbar;
                title('Mapa de Diferenças', 'FontSize', obj.FONT_SIZE_TITLE);
                axis image;
                axis off;
                
                % Título geral
                sgtitle(p.Results.title, 'FontSize', obj.FONT_SIZE_TITLE + 2);
                
                % Salvar figura
                if isempty(p.Results.filename)
                    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                    filename = sprintf('difference_map_%s.%s', timestamp, obj.figureFormat);
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
                    fprintf('Mapa de diferenças salvo em: %s\n', outputPath);
                end
                
            catch ME
                if exist('fig', 'var') && ishandle(fig)
                    close(fig);
                end
                error('Erro ao criar mapa de diferenças: %s', ME.message);
            end
        end
        
        function outputPath = createMetricsOverlay(obj, image, segmentation, metrics, modelName, varargin)
            % Cria sobreposição de métricas diretamente na imagem segmentada
            %
            % Inputs:
            %   image - Imagem original
            %   segmentation - Segmentação do modelo
            %   metrics - Struct com métricas (iou, dice, accuracy)
            %   modelName - Nome do modelo
            %
            % Output:
            %   outputPath - Caminho do arquivo salvo
            
            % Parse optional arguments
            p = inputParser;
            addParameter(p, 'filename', '', @ischar);
            addParameter(p, 'overlayAlpha', 0.3, @isnumeric);
            parse(p, varargin{:});
            
            try
                % Criar figura
                fig = figure('Position', [100, 100, obj.DEFAULT_FIGURE_SIZE]);
                set(fig, 'Color', 'white');
                
                % Mostrar imagem original
                imshow(image);
                hold on;
                
                % Criar overlay da segmentação
                if isa(segmentation, 'logical')
                    segmentation = double(segmentation);
                end
                
                % Criar máscara colorida
                overlay = cat(3, segmentation, zeros(size(segmentation)), zeros(size(segmentation)));
                h = imshow(overlay);
                set(h, 'AlphaData', segmentation * p.Results.overlayAlpha);
                
                % Adicionar texto com métricas
                textStr = sprintf('%s\nIoU: %.3f\nDice: %.3f\nAcc: %.3f', ...
                    modelName, metrics.iou, metrics.dice, metrics.accuracy);
                
                % Posicionar texto no canto superior esquerdo
                text(10, 30, textStr, 'FontSize', obj.FONT_SIZE_METRICS, ...
                    'Color', 'white', 'BackgroundColor', 'black', ...
                    'VerticalAlignment', 'top');
                
                title(sprintf('Segmentação com Métricas - %s', modelName), ...
                    'FontSize', obj.FONT_SIZE_TITLE);
                
                % Salvar figura
                if isempty(p.Results.filename)
                    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                    filename = sprintf('metrics_overlay_%s_%s.%s', ...
                        strrep(lower(modelName), ' ', '_'), timestamp, obj.figureFormat);
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
                    fprintf('Overlay de métricas salvo em: %s\n', outputPath);
                end
                
            catch ME
                if exist('fig', 'var') && ishandle(fig)
                    close(fig);
                end
                error('Erro ao criar overlay de métricas: %s', ME.message);
            end
        end
    end
end