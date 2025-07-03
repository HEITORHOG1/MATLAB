function data = preprocessDataMelhorado(data, config, labelIDs, useAugmentation)
    % Preprocessamento melhorado com data augmentation opcional
    % VERSÃO FINAL - Correção crítica para categorical
    
    img = data{1};
    mask = data{2};
    
    % Redimensionar
    img = imresize(img, config.inputSize(1:2));
    mask = imresize(mask, config.inputSize(1:2), 'nearest');
    
    % Garantir que a imagem tenha 3 canais
    if size(img, 3) == 1
        img = repmat(img, [1, 1, 3]);
    elseif size(img, 3) > 3
        img = img(:,:,1:3);
    end
    
    % Normalizar imagem
    img = im2double(img);
    
    % Data augmentation (apenas para treinamento)
    if useAugmentation && rand > 0.5
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
    
    % Processar máscara - CORREÇÃO CRÍTICA
    if ~isa(mask, 'categorical')
        if size(mask, 3) > 1
            mask = rgb2gray(mask);
        end
        
        % Binarizar se necessário
        if length(labelIDs) == 2 && ~all(ismember(unique(mask(:)), labelIDs))
            threshold = mean(double(labelIDs));
            mask = uint8(mask > threshold);
            if labelIDs(1) == 0 && labelIDs(2) == 1
                % Já está correto
            elseif labelIDs(1) == 0 && labelIDs(2) == 255
                mask = mask * 255;
            end
        end
        
        % Converter para categorical - CORREÇÃO CRÍTICA
        classNames = ["background", "foreground"];
        % Garantir que os valores da máscara correspondem aos labelIDs
        if length(labelIDs) == 2 && all(ismember(labelIDs, [0, 255]))
            % Converter 255 para 1 para compatibilidade com categorical
            mask(mask == 255) = 1;
            labelIDs_cat = [0, 1];
        else
            labelIDs_cat = labelIDs;
        end
        
        % Garantir que mask só tenha valores válidos
        mask = uint8(mask);
        uniqueVals = unique(mask(:));
        
        if length(uniqueVals) > length(labelIDs_cat)
            % Binarizar se ainda há valores extras
            threshold = mean(double(labelIDs_cat));
            mask = uint8(mask > threshold);
        end
        
        % Converter para categorical com classes corretas
        classNames = ["background", "foreground"];
        mask = categorical(mask, labelIDs_cat, classNames);
    end
    
    data = {img, mask};
end
