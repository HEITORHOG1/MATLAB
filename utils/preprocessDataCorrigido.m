function data = preprocessDataCorrigido(data, config, labelIDs, useAugmentation)
    % ========================================================================
    % PREPROCESSAMENTO CORRIGIDO - VERSÃO CRÍTICA COM VALIDAÇÃO DE TIPOS
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 3.0 - Correção Crítica com Validação de Tipos
    %
    % CORREÇÕES IMPLEMENTADAS:
    % - Validação de tipos antes de operações RGB
    % - Conversões seguras categorical para numérico
    % - Tratamento de erros com fallbacks graceful
    % - Integração com DataTypeConverter e PreprocessingValidator
    % ========================================================================
    
    try
        img = data{1};
        mask = data{2};
        
        % === VALIDAÇÃO INICIAL DE DADOS ===
        fprintf('=== Iniciando pré-processamento com validação de tipos ===\n');
        
        % Validar dados de entrada
        try
            PreprocessingValidator.validateImageData(img);
            PreprocessingValidator.validateMaskData(mask);
            
            % Validar compatibilidade entre imagem e máscara
            compatibility = PreprocessingValidator.validateDataCompatibility(img, mask);
            if ~compatibility.isCompatible
                warning('preprocessDataCorrigido:CompatibilityIssues', ...
                    'Compatibility issues detected: %s', strjoin(compatibility.errors, '; '));
            end
            
            % Reportar warnings de compatibilidade
            for i = 1:length(compatibility.warnings)
                warning('preprocessDataCorrigido:CompatibilityWarning', compatibility.warnings{i});
            end
            
        catch ME
            warning('preprocessDataCorrigido:ValidationFailed', ...
                'Initial validation failed: %s. Proceeding with caution.', ME.message);
        end
        
        % === PROCESSAMENTO DA IMAGEM ===
        fprintf('Processando imagem: %s, tamanho %s\n', class(img), mat2str(size(img)));
        
        % Preparar imagem para operações RGB (redimensionamento)
        try
            img = PreprocessingValidator.prepareForRGBOperation(img);
        catch ME
            warning('preprocessDataCorrigido:ImageRGBPreparationFailed', ...
                'Failed to prepare image for RGB operations: %s. Using fallback.', ME.message);
            % Fallback: converter categorical para uint8 se necessário
            if iscategorical(img)
                img = DataTypeConverter.safeConversion(img, 'uint8', 'image_rgb_fallback');
            end
        end
        
        % Redimensionar com validação de tipo
        try
            img = imresize(img, config.inputSize(1:2));
        catch ME
            error('preprocessDataCorrigido:ResizeFailed', ...
                'Failed to resize image: %s. Image type: %s', ME.message, class(img));
        end
        
        % Garantir que a imagem tenha 3 canais
        if size(img, 3) == 1
            img = repmat(img, [1, 1, 3]);
        elseif size(img, 3) > 3
            img = img(:,:,1:3);
        end
        
        % Normalizar imagem para [0,1] com conversão segura
        try
            if ~isa(img, 'double')
                img = im2double(img);
            end
        catch ME
            warning('preprocessDataCorrigido:NormalizationFailed', ...
                'Failed to normalize image: %s. Using safe conversion.', ME.message);
            img = DataTypeConverter.safeConversion(img, 'double', 'image_normalization');
        end
        
        % === PROCESSAMENTO DA MÁSCARA ===
        fprintf('Processando máscara: %s, tamanho %s\n', class(mask), mat2str(size(mask)));
        
        % Preparar máscara para operações RGB (redimensionamento)
        maskForResize = mask;
        try
            maskForResize = PreprocessingValidator.prepareForRGBOperation(mask);
        catch ME
            warning('preprocessDataCorrigido:MaskRGBPreparationFailed', ...
                'Failed to prepare mask for RGB operations: %s. Using fallback.', ME.message);
            % Fallback: converter categorical para uint8 se necessário
            if iscategorical(mask)
                maskForResize = DataTypeConverter.safeConversion(mask, 'uint8', 'mask_rgb_fallback');
            end
        end
        
        % Redimensionar máscara com validação de tipo
        try
            mask = imresize(maskForResize, config.inputSize(1:2), 'nearest');
        catch ME
            error('preprocessDataCorrigido:MaskResizeFailed', ...
                'Failed to resize mask: %s. Mask type: %s', ME.message, class(maskForResize));
        end
        
        % Converter para escala de cinza se necessário (com validação de tipo)
        if size(mask, 3) > 1
            try
                % Garantir que não é categorical antes de rgb2gray
                if iscategorical(mask)
                    mask = DataTypeConverter.safeConversion(mask, 'uint8', 'mask_rgb2gray_prep');
                end
                mask = rgb2gray(mask);
            catch ME
                warning('preprocessDataCorrigido:RGB2GrayFailed', ...
                    'Failed to convert mask to grayscale: %s. Using fallback.', ME.message);
                % Fallback: usar apenas o primeiro canal
                mask = mask(:,:,1);
            end
        end
        
        % Converter para double com conversão segura
        try
            if iscategorical(mask)
                mask = DataTypeConverter.safeConversion(mask, 'double', 'mask_to_double');
            else
                mask = double(mask);
            end
        catch ME
            warning('preprocessDataCorrigido:MaskDoubleConversionFailed', ...
                'Failed to convert mask to double: %s. Using fallback.', ME.message);
            mask = DataTypeConverter.safeConversion(mask, 'double', 'mask_double_fallback');
        end
        
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
        
        % CRÍTICO: Converter para categorical para segmentação semântica com validação
        try
            % Use standardized categorical creation with consistent [0,1] labelIDs and ["background","foreground"]
            mask = DataTypeConverter.numericToCategorical(mask, ["background", "foreground"], [0, 1]);
            
            % Validar estrutura categorical criada
            validation = DataTypeConverter.validateCategoricalStructure(mask);
            if ~validation.isValid
                error('preprocessDataCorrigido:InvalidCategoricalMask', ...
                    'Created categorical mask is invalid: %s', strjoin(validation.errors, '; '));
            end
            
            % Reportar warnings se houver
            for i = 1:length(validation.warnings)
                warning('preprocessDataCorrigido:CategoricalWarning', validation.warnings{i});
            end
            
        catch ME
            error('preprocessDataCorrigido:CategoricalConversionFailed', ...
                'Failed to convert mask to categorical: %s', ME.message);
        end
        
        % === DATA AUGMENTATION (apenas para treinamento) ===
        if nargin >= 4 && useAugmentation && rand > 0.5
            fprintf('Aplicando data augmentation...\n');
            
            % Flip horizontal
            if rand > 0.5
                try
                    img = fliplr(img);
                    mask = fliplr(mask);
                catch ME
                    warning('preprocessDataCorrigido:FlipFailed', ...
                        'Failed to flip data: %s', ME.message);
                end
            end
            
            % Rotação pequena (requer conversão de categorical para operações geométricas)
            if rand > 0.7
                try
                    angle = (rand - 0.5) * 20; % ±10 graus
                    img = imrotate(img, angle, 'bilinear', 'crop');
                    
                    % Para máscara categorical, converter temporariamente para numérico
                    if iscategorical(mask)
                        maskNumeric = DataTypeConverter.safeConversion(mask, 'uint8', 'rotation_prep');
                        maskNumeric = imrotate(maskNumeric, angle, 'nearest', 'crop');
                        mask = DataTypeConverter.safeConversion(maskNumeric, 'categorical', 'rotation_restore');
                    else
                        mask = imrotate(mask, angle, 'nearest', 'crop');
                    end
                catch ME
                    warning('preprocessDataCorrigido:RotationFailed', ...
                        'Failed to rotate data: %s', ME.message);
                end
            end
            
            % Ajuste de brilho (apenas para imagem)
            if rand > 0.6
                try
                    brightness_factor = 0.8 + 0.4 * rand; % 0.8 a 1.2
                    img = img * brightness_factor;
                    img = min(max(img, 0), 1);
                catch ME
                    warning('preprocessDataCorrigido:BrightnessAdjustmentFailed', ...
                        'Failed to adjust brightness: %s', ME.message);
                end
            end
        end
        
        % === VALIDAÇÃO FINAL ===
        fprintf('=== Validação final dos dados processados ===\n');
        
        % Garantir tipos corretos com conversão segura
        try
            img = DataTypeConverter.safeConversion(img, 'single', 'final_image_conversion');
        catch ME
            warning('preprocessDataCorrigido:FinalImageConversionFailed', ...
                'Failed final image conversion: %s', ME.message);
            img = single(img); % Fallback direto
        end
        
        % Validar que mask é categorical
        if ~iscategorical(mask)
            warning('preprocessDataCorrigido:MaskNotCategorical', ...
                'Mask is not categorical after processing. Converting...');
            try
                mask = DataTypeConverter.safeConversion(mask, 'categorical', 'final_mask_conversion');
            catch ME
                error('preprocessDataCorrigido:FinalMaskConversionFailed', ...
                    'Failed to ensure mask is categorical: %s', ME.message);
            end
        end
        
        % Garantir dimensões corretas
        if size(img, 3) ~= 3
            error('preprocessDataCorrigido:InvalidImageChannels', ...
                'Imagem deve ter 3 canais, tem %d', size(img, 3));
        end
        
        if ndims(mask) ~= 2
            error('preprocessDataCorrigido:InvalidMaskDimensions', ...
                'Máscara deve ser 2D, tem %d dimensões', ndims(mask));
        end
        
        % Verificar valores da imagem
        if any(img(:) < 0) || any(img(:) > 1)
            fprintf('AVISO: Valores de imagem fora do range [0,1]. Corrigindo...\n');
            img = max(0, min(1, img));
        end
        
        % Validação final dos dados processados
        try
            PreprocessingValidator.validateImageData(img);
            PreprocessingValidator.validateMaskData(mask);
            fprintf('✓ Validação final passou - dados prontos para uso\n');
        catch ME
            warning('preprocessDataCorrigido:FinalValidationFailed', ...
                'Final validation failed: %s', ME.message);
        end
        
        data = {img, mask};
        fprintf('=== Pré-processamento concluído com sucesso ===\n');
        
    catch ME
        fprintf('=== ERRO CRÍTICO NO PRÉ-PROCESSAMENTO ===\n');
        fprintf('Erro: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        % Implementar fallback robusto com validação de tipos
        fprintf('Tentando recuperação com fallback seguro...\n');
        try
            % Recuperar dados originais
            originalImg = data{1};
            originalMask = data{2};
            
            % Processamento básico da imagem com conversões seguras
            try
                % Preparar imagem para redimensionamento
                if iscategorical(originalImg)
                    imgForResize = DataTypeConverter.safeConversion(originalImg, 'uint8', 'fallback_img_prep');
                else
                    imgForResize = originalImg;
                end
                
                img = imresize(imgForResize, config.inputSize(1:2));
                img = DataTypeConverter.safeConversion(img, 'single', 'fallback_img_final');
                
                % Garantir 3 canais
                if size(img, 3) == 1
                    img = repmat(img, [1, 1, 3]);
                elseif size(img, 3) > 3
                    img = img(:,:,1:3);
                end
                
                % Normalizar se necessário
                if max(img(:)) > 1
                    img = img / max(img(:));
                end
                
            catch imgError
                error('preprocessDataCorrigido:FallbackImageFailed', ...
                    'Fallback image processing failed: %s', imgError.message);
            end
            
            % Processamento básico da máscara com conversões seguras
            try
                % Preparar máscara para redimensionamento
                if iscategorical(originalMask)
                    maskForResize = DataTypeConverter.safeConversion(originalMask, 'uint8', 'fallback_mask_prep');
                else
                    maskForResize = originalMask;
                end
                
                mask_temp = imresize(maskForResize, config.inputSize(1:2), 'nearest');
                
                % Converter para escala de cinza se necessário
                if size(mask_temp, 3) > 1
                    if iscategorical(mask_temp)
                        mask_temp = DataTypeConverter.safeConversion(mask_temp, 'uint8', 'fallback_mask_gray_prep');
                    end
                    mask_temp = rgb2gray(mask_temp);
                end
                
                % Converter para double e binarizar
                mask_temp = DataTypeConverter.safeConversion(mask_temp, 'double', 'fallback_mask_double');
                if max(mask_temp(:)) > 1
                    mask_temp = mask_temp / 255;
                end
                mask_temp = double(mask_temp > 0.5);
                
                % Converter para categorical com estrutura padrão
                classNames = ["background", "foreground"];
                labelIDs = [0, 1];
                mask = DataTypeConverter.numericToCategorical(mask_temp, classNames, labelIDs);
                
            catch maskError
                error('preprocessDataCorrigido:FallbackMaskFailed', ...
                    'Fallback mask processing failed: %s', maskError.message);
            end
            
            data = {img, mask};
            fprintf('✓ Recuperação com fallback bem-sucedida\n');
            
        catch fallbackError
            fprintf('=== FALHA CRÍTICA NO FALLBACK ===\n');
            fprintf('Erro no fallback: %s\n', fallbackError.message);
            error('preprocessDataCorrigido:CriticalFailure', ...
                'Falha crítica no pré-processamento - nem o processamento principal nem o fallback funcionaram. Erro original: %s. Erro do fallback: %s', ...
                ME.message, fallbackError.message);
        end
    end
end
