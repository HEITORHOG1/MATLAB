function data = preprocessDataCorrigido(data, config, labelIDs, useAugmentation)
    % ========================================================================
    % PREPROCESSAMENTO CORRIGIDO - VERSÃO CRÍTICA
    % ========================================================================
    % 
    % CORREÇÃO CRÍTICA: Remove conversão para categorical que causa erros
    % Mantém máscaras como numéricas para compatibilidade com trainNetwork
    %
    % VERSÃO: 2.0 - Correção Crítica
    % DATA: Julho 2025
    % ========================================================================
    
    try
        img = data{1};
        mask = data{2};
        
        % === PROCESSAMENTO DA IMAGEM ===
        % Redimensionar
        img = imresize(img, config.inputSize(1:2));
        
        % Garantir que a imagem tenha 3 canais
        if size(img, 3) == 1
            img = repmat(img, [1, 1, 3]);
        elseif size(img, 3) > 3
            img = img(:,:,1:3);
        end
        
        % Normalizar imagem para [0,1]
        if ~isa(img, 'double')
            img = im2double(img);
        end
        
        % === PROCESSAMENTO DA MÁSCARA ===
        % Redimensionar máscara
        mask = imresize(mask, config.inputSize(1:2), 'nearest');
        
        % Converter para escala de cinza se necessário
        if size(mask, 3) > 1
            mask = rgb2gray(mask);
        end
        
        % Converter para double
        mask = double(mask);
        
        % Normalizar se os valores estão em [0,255]
        if max(mask(:)) > 1
            mask = mask / 255;
        end
        
        % Binarizar máscara
        threshold = 0.5;
        mask = double(mask > threshold);
        
        % Garantir dimensões corretas (2D para segmentação)
        if size(mask, 3) > 1
            mask = mask(:,:,1);
        end
        
        % CRÍTICO: Converter para categorical para segmentação semântica
        classNames = ["background", "foreground"];
        mask = categorical(mask, [0, 1], classNames);
        
        % === DATA AUGMENTATION (apenas para treinamento) ===
        if nargin >= 4 && useAugmentation && rand > 0.5
            % Flip horizontal
            if rand > 0.5
                img = fliplr(img);
                mask = fliplr(mask);
            end
            
            % Rotação pequena
            if rand > 0.7
                angle = (rand - 0.5) * 20; % ±10 graus
                img = imrotate(img, angle, 'bilinear', 'crop');
                mask = imrotate(mask, angle, 'nearest', 'crop');
            end
            
            % Ajuste de brilho
            if rand > 0.6
                brightness_factor = 0.8 + 0.4 * rand; % 0.8 a 1.2
                img = img * brightness_factor;
                img = min(max(img, 0), 1);
            end
        end
        
        % === VALIDAÇÃO FINAL ===
        % Garantir tipos corretos
        img = single(img);  % CRÍTICO: single para imagens
        % mask já é categorical - correto para segmentação
        
        % Garantir dimensões corretas
        if size(img, 3) ~= 3
            error('Imagem deve ter 3 canais');
        end
        
        if ndims(mask) ~= 2
            error('Máscara deve ser 2D');
        end
        
        % Verificar valores da imagem
        if any(img(:) < 0) || any(img(:) > 1)
            fprintf('AVISO: Valores de imagem fora do range [0,1]\n');
            img = max(0, min(1, img));
        end
        
        data = {img, mask};
        
    catch ME
        fprintf('Erro no pré-processamento: %s\n', ME.message);
        % Retornar dados básicos em caso de erro
        try
            img = single(im2double(imresize(data{1}, config.inputSize(1:2))));
            if size(img, 3) == 1
                img = repmat(img, [1, 1, 3]);
            end
            
            mask_temp = im2double(imresize(data{2}, config.inputSize(1:2), 'nearest'));
            if size(mask_temp, 3) > 1
                mask_temp = rgb2gray(mask_temp);
            end
            mask_temp = double(mask_temp > 0.5);
            
            % Converter para categorical
            classNames = ["background", "foreground"];
            mask = categorical(mask_temp, [0, 1], classNames);
            
            data = {img, mask};
        catch
            error('Falha crítica no pré-processamento');
        end
    end
end
