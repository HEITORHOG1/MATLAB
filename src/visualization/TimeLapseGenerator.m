classdef TimeLapseGenerator < handle
    % TimeLapseGenerator - Gerador de vídeos time-lapse
    % 
    % Esta classe implementa funcionalidades para:
    % - Geração de vídeos time-lapse mostrando evolução das predições
    % - Animações de convergência durante treinamento
    % - Comparação visual da evolução de diferentes modelos
    % - Exportação em diferentes formatos de vídeo
    
    properties
        outputDirectory
        videoFormat
        frameRate
        quality
        showProgress
    end
    
    methods
        function obj = TimeLapseGenerator(varargin)
            % Constructor - Inicializa o gerador de time-lapse
            
            % Parse input arguments
            p = inputParser;
            addParameter(p, 'outputDir', 'output/videos/', @ischar);
            addParameter(p, 'videoFormat', 'mp4', @ischar);
            addParameter(p, 'frameRate', 2, @isnumeric);
            addParameter(p, 'quality', 75, @isnumeric);
            addParameter(p, 'showProgress', true, @islogical);
            parse(p, varargin{:});
            
            obj.outputDirectory = p.Results.outputDir;
            obj.videoFormat = p.Results.videoFormat;
            obj.frameRate = p.Results.frameRate;
            obj.quality = p.Results.quality;
            obj.showProgress = p.Results.showProgress;
            
            % Criar diretório de saída se não existir
            if ~exist(obj.outputDirectory, 'dir')
                mkdir(obj.outputDirectory);
            end
        end
        
        function videoPath = createTrainingEvolutionVideo(obj, gradientHistory, varargin)
            % Cria vídeo time-lapse da evolução dos gradientes durante treinamento
            %
            % Inputs:
            %   gradientHistory - Struct com histórico de gradientes por época
            %
            % Output:
            %   videoPath - Caminho do vídeo gerado
            
            % Parse optional arguments
            p = inputParser;
            addParameter(p, 'filename', '', @ischar);
            addParameter(p, 'title', 'Evolução dos Gradientes', @ischar);
            addParameter(p, 'modelName', 'Modelo', @ischar);
            parse(p, varargin{:});
            
            try
                % Preparar dados
                epochs = fieldnames(gradientHistory);
                numEpochs = length(epochs);
                
                if numEpochs < 2
                    error('Histórico insuficiente para criar vídeo (mínimo 2 épocas)');
                end
                
                % Configurar vídeo
                if isempty(p.Results.filename)
                    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                    filename = sprintf('gradient_evolution_%s_%s.%s', ...
                        strrep(lower(p.Results.modelName), ' ', '_'), timestamp, obj.videoFormat);
                else
                    filename = p.Results.filename;
                end
                
                videoPath = fullfile(obj.outputDirectory, filename);
                
                % Criar objeto de vídeo
                if strcmp(obj.videoFormat, 'mp4')
                    profile = 'MPEG-4';
                elseif strcmp(obj.videoFormat, 'avi')
                    profile = 'Motion JPEG AVI';
                else
                    profile = 'MPEG-4';
                end
                
                writerObj = VideoWriter(videoPath, profile);
                writerObj.FrameRate = obj.frameRate;
                if strcmp(profile, 'MPEG-4')
                    writerObj.Quality = obj.quality;
                end
                open(writerObj);
                
                % Criar frames
                for i = 1:numEpochs
                    epochName = epochs{i};
                    epochData = gradientHistory.(epochName);
                    
                    % Criar frame
                    frame = obj.createGradientFrame(epochData, i, numEpochs, p.Results.title, p.Results.modelName);
                    
                    % Adicionar frame ao vídeo
                    writeVideo(writerObj, frame);
                    
                    if obj.showProgress && mod(i, 10) == 0
                        fprintf('Processando época %d/%d...\n', i, numEpochs);
                    end
                end
                
                % Fechar vídeo
                close(writerObj);
                
                if obj.showProgress
                    fprintf('Vídeo time-lapse salvo em: %s\n', videoPath);
                end
                
            catch ME
                if exist('writerObj', 'var')
                    try
                        close(writerObj);
                    catch
                        % Ignorar erro ao fechar
                    end
                end
                error('Erro ao criar vídeo time-lapse: %s', ME.message);
            end
        end
        
        function frame = createGradientFrame(obj, epochData, epochNum, totalEpochs, titleStr, modelName)
            % Cria frame individual para o vídeo de gradientes
            
            % Criar figura temporária
            fig = figure('Position', [100, 100, 800, 600], 'Visible', 'off');
            set(fig, 'Color', 'white');
            
            try
                % Extrair dados dos gradientes
                layerNames = fieldnames(epochData);
                numLayers = length(layerNames);
                
                if numLayers == 0
                    error('Nenhum dado de gradiente encontrado para época %d', epochNum);
                end
                
                % Subplot para magnitude dos gradientes
                subplot(2, 2, 1);
                gradMagnitudes = [];
                layerLabels = {};
                
                for i = 1:numLayers
                    layerName = layerNames{i};
                    gradData = epochData.(layerName);
                    
                    if isnumeric(gradData) && ~isempty(gradData)
                        magnitude = mean(abs(gradData(:)));
                        gradMagnitudes(end+1) = magnitude;
                        layerLabels{end+1} = layerName;
                    end
                end
                
                if ~isempty(gradMagnitudes)
                    bar(gradMagnitudes);
                    set(gca, 'XTickLabel', layerLabels);
                    title('Magnitude dos Gradientes por Camada');
                    ylabel('Magnitude Média');
                    xtickangle(45);
                end
                
                % Subplot para distribuição dos gradientes
                subplot(2, 2, 2);
                if ~isempty(gradMagnitudes)
                    histogram(gradMagnitudes, 10);
                    title('Distribuição das Magnitudes');
                    xlabel('Magnitude');
                    ylabel('Frequência');
                end
                
                % Subplot para evolução temporal (placeholder)
                subplot(2, 2, 3);
                plot(1:epochNum, ones(1, epochNum) * mean(gradMagnitudes), 'b-', 'LineWidth', 2);
                xlim([1, totalEpochs]);
                title('Evolução da Magnitude Média');
                xlabel('Época');
                ylabel('Magnitude Média');
                grid on;
                
                % Subplot para informações da época
                subplot(2, 2, 4);
                axis off;
                infoText = sprintf(['Modelo: %s\nÉpoca: %d/%d\nProgress: %.1f%%\n\n' ...
                    'Camadas monitoradas: %d\nMagnitude média: %.6f'], ...
                    modelName, epochNum, totalEpochs, (epochNum/totalEpochs)*100, ...
                    numLayers, mean(gradMagnitudes));
                
                text(0.1, 0.8, infoText, 'FontSize', 12, 'VerticalAlignment', 'top');
                
                % Título geral
                sgtitle(sprintf('%s - Época %d', titleStr, epochNum), 'FontSize', 14);
                
                % Capturar frame
                frame = getframe(fig);
                
                close(fig);
                
            catch ME
                close(fig);
                error('Erro ao criar frame: %s', ME.message);
            end
        end
        
        function videoPath = createPredictionEvolutionVideo(obj, predictionHistory, originalImage, groundTruth, varargin)
            % Cria vídeo time-lapse da evolução das predições
            %
            % Inputs:
            %   predictionHistory - Cell array com predições por época
            %   originalImage - Imagem original
            %   groundTruth - Ground truth
            %
            % Output:
            %   videoPath - Caminho do vídeo gerado
            
            % Parse optional arguments
            p = inputParser;
            addParameter(p, 'filename', '', @ischar);
            addParameter(p, 'title', 'Evolução das Predições', @ischar);
            addParameter(p, 'modelName', 'Modelo', @ischar);
            parse(p, varargin{:});
            
            try
                numEpochs = length(predictionHistory);
                
                if numEpochs < 2
                    error('Histórico insuficiente para criar vídeo (mínimo 2 épocas)');
                end
                
                % Configurar vídeo
                if isempty(p.Results.filename)
                    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                    filename = sprintf('prediction_evolution_%s_%s.%s', ...
                        strrep(lower(p.Results.modelName), ' ', '_'), timestamp, obj.videoFormat);
                else
                    filename = p.Results.filename;
                end
                
                videoPath = fullfile(obj.outputDirectory, filename);
                
                % Criar objeto de vídeo
                if strcmp(obj.videoFormat, 'mp4')
                    profile = 'MPEG-4';
                elseif strcmp(obj.videoFormat, 'avi')
                    profile = 'Motion JPEG AVI';
                else
                    profile = 'MPEG-4';
                end
                
                writerObj = VideoWriter(videoPath, profile);
                writerObj.FrameRate = obj.frameRate;
                if strcmp(profile, 'MPEG-4')
                    writerObj.Quality = obj.quality;
                end
                open(writerObj);
                
                % Criar frames
                for i = 1:numEpochs
                    prediction = predictionHistory{i};
                    
                    % Criar frame
                    frame = obj.createPredictionFrame(originalImage, groundTruth, prediction, ...
                        i, numEpochs, p.Results.title, p.Results.modelName);
                    
                    % Adicionar frame ao vídeo
                    writeVideo(writerObj, frame);
                    
                    if obj.showProgress && mod(i, 10) == 0
                        fprintf('Processando predição %d/%d...\n', i, numEpochs);
                    end
                end
                
                % Fechar vídeo
                close(writerObj);
                
                if obj.showProgress
                    fprintf('Vídeo de evolução das predições salvo em: %s\n', videoPath);
                end
                
            catch ME
                if exist('writerObj', 'var')
                    try
                        close(writerObj);
                    catch
                        % Ignorar erro ao fechar
                    end
                end
                error('Erro ao criar vídeo de predições: %s', ME.message);
            end
        end
        
        function frame = createPredictionFrame(obj, originalImage, groundTruth, prediction, epochNum, totalEpochs, titleStr, modelName)
            % Cria frame individual para o vídeo de predições
            
            % Criar figura temporária
            fig = figure('Position', [100, 100, 1000, 600], 'Visible', 'off');
            set(fig, 'Color', 'white');
            
            try
                % Subplot 1: Imagem original
                subplot(2, 3, 1);
                imshow(originalImage);
                title('Imagem Original');
                
                % Subplot 2: Ground truth
                subplot(2, 3, 2);
                imshow(groundTruth);
                title('Ground Truth');
                
                % Subplot 3: Predição atual
                subplot(2, 3, 3);
                imshow(prediction);
                title(sprintf('Predição - Época %d', epochNum));
                
                % Subplot 4: Diferença com ground truth
                subplot(2, 3, 4);
                if isa(prediction, 'logical')
                    prediction = double(prediction);
                end
                if isa(groundTruth, 'logical')
                    groundTruth = double(groundTruth);
                end
                
                difference = abs(prediction - groundTruth);
                imagesc(difference);
                colormap('hot');
                colorbar;
                title('Diferença com GT');
                axis image;
                axis off;
                
                % Subplot 5: Sobreposição
                subplot(2, 3, 5);
                imshow(originalImage);
                hold on;
                overlay = cat(3, prediction, zeros(size(prediction)), zeros(size(prediction)));
                h = imshow(overlay);
                set(h, 'AlphaData', prediction * 0.3);
                title('Sobreposição');
                
                % Subplot 6: Informações
                subplot(2, 3, 6);
                axis off;
                
                % Calcular métricas simples
                intersection = sum(sum(prediction & groundTruth));
                union = sum(sum(prediction | groundTruth));
                iou = intersection / union;
                
                dice = 2 * intersection / (sum(sum(prediction)) + sum(sum(groundTruth)));
                
                infoText = sprintf(['Modelo: %s\nÉpoca: %d/%d\nProgress: %.1f%%\n\n' ...
                    'IoU: %.3f\nDice: %.3f\n\nConvergência em andamento...'], ...
                    modelName, epochNum, totalEpochs, (epochNum/totalEpochs)*100, iou, dice);
                
                text(0.1, 0.8, infoText, 'FontSize', 12, 'VerticalAlignment', 'top');
                
                % Título geral
                sgtitle(sprintf('%s - %s - Época %d', titleStr, modelName, epochNum), 'FontSize', 14);
                
                % Capturar frame
                frame = getframe(fig);
                
                close(fig);
                
            catch ME
                close(fig);
                error('Erro ao criar frame de predição: %s', ME.message);
            end
        end
        
        function videoPath = createComparisonVideo(obj, unetHistory, attentionHistory, originalImage, groundTruth, varargin)
            % Cria vídeo comparativo entre U-Net e Attention U-Net
            %
            % Inputs:
            %   unetHistory - Histórico de predições do U-Net
            %   attentionHistory - Histórico de predições do Attention U-Net
            %   originalImage - Imagem original
            %   groundTruth - Ground truth
            %
            % Output:
            %   videoPath - Caminho do vídeo gerado
            
            % Parse optional arguments
            p = inputParser;
            addParameter(p, 'filename', '', @ischar);
            addParameter(p, 'title', 'Comparação U-Net vs Attention U-Net', @ischar);
            parse(p, varargin{:});
            
            try
                numEpochs = min(length(unetHistory), length(attentionHistory));
                
                if numEpochs < 2
                    error('Histórico insuficiente para criar vídeo (mínimo 2 épocas)');
                end
                
                % Configurar vídeo
                if isempty(p.Results.filename)
                    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                    filename = sprintf('comparison_evolution_%s.%s', timestamp, obj.videoFormat);
                else
                    filename = p.Results.filename;
                end
                
                videoPath = fullfile(obj.outputDirectory, filename);
                
                % Criar objeto de vídeo
                if strcmp(obj.videoFormat, 'mp4')
                    profile = 'MPEG-4';
                elseif strcmp(obj.videoFormat, 'avi')
                    profile = 'Motion JPEG AVI';
                else
                    profile = 'MPEG-4';
                end
                
                writerObj = VideoWriter(videoPath, profile);
                writerObj.FrameRate = obj.frameRate;
                if strcmp(profile, 'MPEG-4')
                    writerObj.Quality = obj.quality;
                end
                open(writerObj);
                
                % Criar frames
                for i = 1:numEpochs
                    unetPred = unetHistory{i};
                    attentionPred = attentionHistory{i};
                    
                    % Criar frame comparativo
                    frame = obj.createComparisonFrame(originalImage, groundTruth, unetPred, attentionPred, ...
                        i, numEpochs, p.Results.title);
                    
                    % Adicionar frame ao vídeo
                    writeVideo(writerObj, frame);
                    
                    if obj.showProgress && mod(i, 10) == 0
                        fprintf('Processando comparação %d/%d...\n', i, numEpochs);
                    end
                end
                
                % Fechar vídeo
                close(writerObj);
                
                if obj.showProgress
                    fprintf('Vídeo de comparação salvo em: %s\n', videoPath);
                end
                
            catch ME
                if exist('writerObj', 'var')
                    try
                        close(writerObj);
                    catch
                        % Ignorar erro ao fechar
                    end
                end
                error('Erro ao criar vídeo de comparação: %s', ME.message);
            end
        end
        
        function frame = createComparisonFrame(obj, originalImage, groundTruth, unetPred, attentionPred, epochNum, totalEpochs, titleStr)
            % Cria frame individual para o vídeo de comparação
            
            % Criar figura temporária
            fig = figure('Position', [100, 100, 1200, 800], 'Visible', 'off');
            set(fig, 'Color', 'white');
            
            try
                % Layout 2x3
                subplot(2, 3, 1);
                imshow(originalImage);
                title('Imagem Original');
                
                subplot(2, 3, 2);
                imshow(groundTruth);
                title('Ground Truth');
                
                subplot(2, 3, 3);
                imshow(unetPred);
                title(sprintf('U-Net - Época %d', epochNum));
                
                subplot(2, 3, 4);
                imshow(attentionPred);
                title(sprintf('Attention U-Net - Época %d', epochNum));
                
                % Diferença entre modelos
                subplot(2, 3, 5);
                if isa(unetPred, 'logical')
                    unetPred = double(unetPred);
                end
                if isa(attentionPred, 'logical')
                    attentionPred = double(attentionPred);
                end
                
                difference = abs(unetPred - attentionPred);
                imagesc(difference);
                colormap('jet');
                colorbar;
                title('Diferença entre Modelos');
                axis image;
                axis off;
                
                % Métricas comparativas
                subplot(2, 3, 6);
                axis off;
                
                % Calcular métricas
                if isa(groundTruth, 'logical')
                    groundTruth = double(groundTruth);
                end
                
                % U-Net metrics
                unet_intersection = sum(sum(unetPred & groundTruth));
                unet_union = sum(sum(unetPred | groundTruth));
                unet_iou = unet_intersection / unet_union;
                unet_dice = 2 * unet_intersection / (sum(sum(unetPred)) + sum(sum(groundTruth)));
                
                % Attention U-Net metrics
                att_intersection = sum(sum(attentionPred & groundTruth));
                att_union = sum(sum(attentionPred | groundTruth));
                att_iou = att_intersection / att_union;
                att_dice = 2 * att_intersection / (sum(sum(attentionPred)) + sum(sum(groundTruth)));
                
                metricsText = sprintf(['Época: %d/%d (%.1f%%)\n\n' ...
                    'U-Net:\n  IoU: %.3f\n  Dice: %.3f\n\n' ...
                    'Attention U-Net:\n  IoU: %.3f\n  Dice: %.3f\n\n' ...
                    'Diferença IoU: %.3f\nDiferença Dice: %.3f'], ...
                    epochNum, totalEpochs, (epochNum/totalEpochs)*100, ...
                    unet_iou, unet_dice, att_iou, att_dice, ...
                    att_iou - unet_iou, att_dice - unet_dice);
                
                text(0.1, 0.9, metricsText, 'FontSize', 11, 'VerticalAlignment', 'top');
                
                % Título geral
                sgtitle(sprintf('%s - Época %d', titleStr, epochNum), 'FontSize', 16);
                
                % Capturar frame
                frame = getframe(fig);
                
                close(fig);
                
            catch ME
                close(fig);
                error('Erro ao criar frame de comparação: %s', ME.message);
            end
        end
    end
end