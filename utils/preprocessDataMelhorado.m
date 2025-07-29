function data = preprocessDataMelhorado(data, config, labelIDs, useAugmentation)
    % Preprocessamento melhorado com data augmentation opcional
    % VERSÃO CORRIGIDA - Com validação de tipos e tratamento de erros
    
    try
        % Add path for utility classes
        addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src', 'utils'));
        
        img = data{1};
        mask = data{2};
        
        % STEP 1: Validate input data types
        try
            PreprocessingValidator.validateImageData(img);
            PreprocessingValidator.validateMaskData(mask);
        catch ME
            warning('Data validation failed: %s. Attempting recovery...', ME.message);
        end
        
        % STEP 2: Prepare image data for RGB operations
        img = PreprocessingValidator.prepareForRGBOperation(img);
        
        % Redimensionar com validação de tipo
        img = imresize(img, config.inputSize(1:2));
        
        % Prepare mask for resizing (convert categorical to numeric temporarily if needed)
        if isa(mask, 'categorical')
            mask_for_resize = DataTypeConverter.categoricalToNumeric(mask, 'uint8');
            mask_for_resize = imresize(mask_for_resize, config.inputSize(1:2), 'nearest');
            % Convert back to categorical with consistent structure
            mask = DataTypeConverter.numericToCategorical(mask_for_resize, ...
                ["background", "foreground"], [0, 1]);
        else
            mask = imresize(mask, config.inputSize(1:2), 'nearest');
        end
        
        % Garantir que a imagem tenha 3 canais
        if size(img, 3) == 1
            img = repmat(img, [1, 1, 3]);
        elseif size(img, 3) > 3
            img = img(:,:,1:3);
        end
        
        % Normalizar imagem
        img = im2double(img);
    
        % STEP 3: Data augmentation (apenas para treinamento)
        if useAugmentation && rand > 0.5
            % Flip horizontal
            if rand > 0.5
                img = fliplr(img);
                if isa(mask, 'categorical')
                    % Handle categorical mask flipping safely
                    mask_numeric = DataTypeConverter.categoricalToNumeric(mask, 'uint8');
                    mask_numeric = fliplr(mask_numeric);
                    mask = DataTypeConverter.numericToCategorical(mask_numeric, ...
                        ["background", "foreground"], [0, 1]);
                else
                    mask = fliplr(mask);
                end
            end
            
            % Rotação pequena
            if rand > 0.7
                angle = (rand - 0.5) * 20; % ±10 graus
                img = imrotate(img, angle, 'bilinear', 'crop');
                
                if isa(mask, 'categorical')
                    % Handle categorical mask rotation safely
                    mask_numeric = DataTypeConverter.categoricalToNumeric(mask, 'uint8');
                    mask_numeric = imrotate(mask_numeric, angle, 'nearest', 'crop');
                    mask = DataTypeConverter.numericToCategorical(mask_numeric, ...
                        ["background", "foreground"], [0, 1]);
                else
                    mask = imrotate(mask, angle, 'nearest', 'crop');
                end
            end
            
            % Ajuste de brilho
            if rand > 0.6
                brightness_factor = 0.8 + 0.4 * rand; % 0.8 a 1.2
                img = img * brightness_factor;
                img = min(max(img, 0), 1);
            end
        end
    
        % STEP 4: Process mask with consistent categorical handling
        if ~isa(mask, 'categorical')
            % Prepare mask for categorical conversion
            if size(mask, 3) > 1
                % Validate before rgb2gray operation
                mask = PreprocessingValidator.prepareForRGBOperation(mask);
                mask = rgb2gray(mask);
            end
            
            % Use DataTypeConverter for consistent categorical creation
            mask = DataTypeConverter.numericToCategorical(mask, ...
                ["background", "foreground"], [0, 1]);
        else
            % Validate existing categorical structure
            if ~DataTypeConverter.validateDataType(mask, {'categorical'})
                warning('Invalid categorical mask detected. Attempting correction...');
                % Convert to numeric and back to ensure consistency
                mask_numeric = DataTypeConverter.categoricalToNumeric(mask, 'uint8');
                mask = DataTypeConverter.numericToCategorical(mask_numeric, ...
                    ["background", "foreground"], [0, 1]);
            end
        end
        
        % Final validation
        try
            PreprocessingValidator.validateMaskData(mask);
        catch ME
            warning('Final mask validation failed: %s', ME.message);
            % Last resort: create a simple binary mask
            if ~isa(mask, 'categorical')
                mask = DataTypeConverter.numericToCategorical(uint8(mask > 0), ...
                    ["background", "foreground"], [0, 1]);
            end
        end
        
        data = {img, mask};
        
    catch ME
        % Error recovery mechanism
        fprintf('Error in preprocessDataMelhorado: %s\n', ME.message);
        fprintf('Attempting error recovery...\n');
        
        % Basic fallback preprocessing
        try
            img = data{1};
            mask = data{2};
            
            % Check for empty or invalid data
            if isempty(img) || ~isnumeric(img)
                % Create a default image
                img = zeros(config.inputSize, 'uint8');
                fprintf('Created default image due to invalid input.\n');
            end
            
            if isempty(mask) || (~isnumeric(mask) && ~isa(mask, 'categorical'))
                % Create a default mask
                mask = zeros(config.inputSize(1:2), 'uint8');
                fprintf('Created default mask due to invalid input.\n');
            end
            
            % Basic image processing with size validation
            if numel(size(img)) >= 2 && all(size(img) > 0)
                img = imresize(img, config.inputSize(1:2));
                if size(img, 3) == 1
                    img = repmat(img, [1, 1, 3]);
                elseif size(img, 3) > 3
                    img = img(:,:,1:3);
                end
                img = im2double(img);
            else
                % Create default image
                img = zeros(config.inputSize, 'double');
            end
            
            % Basic mask processing with size validation
            if numel(size(mask)) >= 2 && all(size(mask) > 0)
                mask = imresize(mask, config.inputSize(1:2), 'nearest');
                if isa(mask, 'categorical')
                    % Keep as is if already categorical
                else
                    if size(mask, 3) > 1
                        mask = rgb2gray(mask);
                    end
                    % Simple binary conversion using DataTypeConverter for consistency
                    mask = DataTypeConverter.numericToCategorical(uint8(mask > 0.5), ...
                        ["background", "foreground"], [0, 1]);
                end
            else
                % Create default categorical mask using DataTypeConverter for consistency
                mask = DataTypeConverter.numericToCategorical(zeros(config.inputSize(1:2), 'uint8'), ...
                    ["background", "foreground"], [0, 1]);
            end
            
            data = {img, mask};
            fprintf('Error recovery successful.\n');
            
        catch recoveryME
            fprintf('Error recovery failed: %s\n', recoveryME.message);
            rethrow(ME); % Re-throw original error
        end
    end
end
