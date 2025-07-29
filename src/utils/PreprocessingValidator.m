classdef PreprocessingValidator < handle
    % PreprocessingValidator - Utility class for validating and preparing data for preprocessing
    % 
    % This class provides static methods for validating image and mask data
    % before preprocessing operations, with special focus on preparing data
    % for RGB operations and categorical operations.
    %
    % Key Features:
    % - Image data validation methods
    % - Mask data validation methods  
    % - Data preparation for RGB operations
    % - Data preparation for categorical operations
    % - Comprehensive error handling and reporting
    
    methods (Static)
        
        function validateImageData(img)
            % Validate image data for preprocessing operations
            %
            % Input:
            %   img - image data to validate
            %
            % Throws error if validation fails
            
            errorHandler = ErrorHandler.getInstance();
            context = 'PreprocessingValidator.validateImageData';
            
            errorHandler.logDebug(context, sprintf('Starting image validation: type=%s, size=%s', ...
                class(img), mat2str(size(img))));
            
            try
                % Check if data exists
                if isempty(img)
                    errorHandler.logError(context, 'Image data is empty');
                    error('PreprocessingValidator:EmptyImage', 'Image data is empty');
                end
                
                % Check data type
                validImageTypes = {'uint8', 'uint16', 'single', 'double'};
                if ~ismember(class(img), validImageTypes)
                    errorHandler.logDataInconsistency(context, 'invalid_type', ...
                        sprintf('Image type %s not in valid types [%s]', class(img), strjoin(validImageTypes, ', ')), 'high');
                    error('PreprocessingValidator:InvalidImageType', ...
                        'Image must be of type: %s. Got: %s', ...
                        strjoin(validImageTypes, ', '), class(img));
                end
                
                % Check dimensions
                imgSize = size(img);
                if length(imgSize) < 2
                    errorHandler.logDataInconsistency(context, 'insufficient_dimensions', ...
                        sprintf('Image has %d dimensions, need at least 2', length(imgSize)), 'critical');
                    error('PreprocessingValidator:InvalidDimensions', ...
                        'Image must have at least 2 dimensions. Got: %d', length(imgSize));
                end
                
                if length(imgSize) > 4
                    errorHandler.logDataInconsistency(context, 'too_many_dimensions', ...
                        sprintf('Image has %d dimensions, maximum is 4', length(imgSize)), 'medium');
                    error('PreprocessingValidator:TooManyDimensions', ...
                        'Image has too many dimensions: %d', length(imgSize));
                end
                
                % Check for valid image dimensions
                if any(imgSize(1:2) < 1)
                    errorHandler.logDataInconsistency(context, 'invalid_spatial_size', ...
                        sprintf('Image spatial dimensions must be positive: %s', mat2str(imgSize(1:2))), 'critical');
                    error('PreprocessingValidator:InvalidSize', ...
                        'Image height and width must be positive. Got size: %s', mat2str(imgSize));
                end
                
                % Check value ranges based on data type
                switch class(img)
                    case 'uint8'
                        if any(img(:) > 255)
                            errorHandler.logDataInconsistency(context, 'value_range_exceeded', ...
                                'uint8 image values exceed 255', 'high');
                            error('PreprocessingValidator:InvalidRange', ...
                                'uint8 image values must be in range [0, 255]');
                        end
                    case 'uint16'
                        if any(img(:) > 65535)
                            errorHandler.logDataInconsistency(context, 'value_range_exceeded', ...
                                'uint16 image values exceed 65535', 'high');
                            error('PreprocessingValidator:InvalidRange', ...
                                'uint16 image values must be in range [0, 65535]');
                        end
                    case {'single', 'double'}
                        minVal = min(img(:));
                        maxVal = max(img(:));
                        if minVal < 0 || maxVal > 1
                            errorHandler.logDataInconsistency(context, 'suspicious_range', ...
                                sprintf('Floating point image values outside [0,1]: [%g, %g]', minVal, maxVal), 'low');
                            warning('PreprocessingValidator:SuspiciousRange', ...
                                'Floating point image values outside [0,1] range: [%g, %g]', minVal, maxVal);
                        end
                end
                
                % Check for NaN or Inf values
                if any(isnan(img(:)))
                    errorHandler.logDataInconsistency(context, 'nan_values', ...
                        'Image contains NaN values', 'critical');
                    error('PreprocessingValidator:NaNValues', 'Image contains NaN values');
                end
                
                if any(isinf(img(:)))
                    errorHandler.logDataInconsistency(context, 'inf_values', ...
                        'Image contains Inf values', 'critical');
                    error('PreprocessingValidator:InfValues', 'Image contains Inf values');
                end
                
                errorHandler.logInfo(context, sprintf('Image validation passed: %s, size %s', ...
                    class(img), mat2str(size(img))));
                
            catch ME
                errorHandler.logError(context, sprintf('Image validation failed: %s', ME.message));
                errorHandler.logError(context, sprintf('Data type: %s, size: %s', ...
                    class(img), mat2str(size(img))));
                
                if isnumeric(img) && ~isempty(img)
                    errorHandler.logError(context, sprintf('Value range: [%g, %g]', ...
                        min(img(:)), max(img(:))));
                end
                
                rethrow(ME);
            end
        end
        
        function validateMaskData(mask)
            % Validate mask data for preprocessing operations
            %
            % Input:
            %   mask - mask data to validate
            %
            % Throws error if validation fails
            
            try
                % Check if data exists
                if isempty(mask)
                    error('PreprocessingValidator:EmptyMask', 'Mask data is empty');
                end
                
                % Check data type
                validMaskTypes = {'uint8', 'double', 'single', 'logical', 'categorical'};
                if ~ismember(class(mask), validMaskTypes)
                    error('PreprocessingValidator:InvalidMaskType', ...
                        'Mask must be of type: %s. Got: %s', ...
                        strjoin(validMaskTypes, ', '), class(mask));
                end
                
                % Check dimensions
                maskSize = size(mask);
                if length(maskSize) < 2
                    error('PreprocessingValidator:InvalidDimensions', ...
                        'Mask must have at least 2 dimensions. Got: %d', length(maskSize));
                end
                
                if length(maskSize) > 3
                    error('PreprocessingValidator:TooManyDimensions', ...
                        'Mask has too many dimensions: %d', length(maskSize));
                end
                
                % Check for valid mask dimensions
                if any(maskSize(1:2) < 1)
                    error('PreprocessingValidator:InvalidSize', ...
                        'Mask height and width must be positive. Got size: %s', mat2str(maskSize));
                end
                
                % Validate based on data type
                if iscategorical(mask)
                    % Validate categorical structure
                    validation = DataTypeConverter.validateCategoricalStructure(mask);
                    if ~validation.isValid
                        error('PreprocessingValidator:InvalidCategorical', ...
                            'Categorical mask validation failed: %s', strjoin(validation.errors, '; '));
                    end
                    
                    % Issue warnings if any
                    for i = 1:length(validation.warnings)
                        warning('PreprocessingValidator:CategoricalWarning', validation.warnings{i});
                    end
                    
                elseif islogical(mask)
                    % Logical masks are always valid for binary segmentation
                    
                elseif isnumeric(mask)
                    % Check value ranges for numeric masks
                    minVal = min(mask(:));
                    maxVal = max(mask(:));
                    
                    switch class(mask)
                        case 'uint8'
                            if maxVal > 255
                                error('PreprocessingValidator:InvalidRange', ...
                                    'uint8 mask values must be in range [0, 255]');
                            end
                            % Check if it's binary (0/255) or multi-class
                            uniqueVals = unique(mask(:));
                            if length(uniqueVals) == 2 && ~isequal(sort(uniqueVals), [0; 255])
                                warning('PreprocessingValidator:UnexpectedValues', ...
                                    'Binary uint8 mask expected values [0, 255], got [%s]', ...
                                    mat2str(uniqueVals'));
                            end
                            
                        case {'double', 'single'}
                            if minVal < 0 || maxVal > 1
                                warning('PreprocessingValidator:SuspiciousRange', ...
                                    'Floating point mask values outside [0,1] range: [%g, %g]', minVal, maxVal);
                            end
                            % Check if it's binary (0/1)
                            uniqueVals = unique(mask(:));
                            if length(uniqueVals) == 2 && ~isequal(sort(uniqueVals), [0; 1])
                                warning('PreprocessingValidator:UnexpectedValues', ...
                                    'Binary floating point mask expected values [0, 1], got [%s]', ...
                                    mat2str(uniqueVals'));
                            end
                    end
                    
                    % Check for NaN or Inf values
                    if any(isnan(mask(:)))
                        error('PreprocessingValidator:NaNValues', 'Mask contains NaN values');
                    end
                    
                    if any(isinf(mask(:)))
                        error('PreprocessingValidator:InfValues', 'Mask contains Inf values');
                    end
                end
                
                fprintf('Mask validation passed: %s, size %s\n', class(mask), mat2str(size(mask)));
                
            catch ME
                fprintf('Mask validation failed:\n');
                fprintf('  Data type: %s\n', class(mask));
                fprintf('  Data size: %s\n', mat2str(size(mask)));
                if isnumeric(mask) && ~isempty(mask)
                    fprintf('  Value range: [%g, %g]\n', min(mask(:)), max(mask(:)));
                elseif iscategorical(mask)
                    fprintf('  Categories: [%s]\n', strjoin(categories(mask), ', '));
                end
                rethrow(ME);
            end
        end
        
        function data = prepareForRGBOperation(data)
            % Prepare data for RGB operations (like rgb2gray, imresize)
            %
            % Input:
            %   data - input data that needs to be prepared for RGB operations
            %
            % Output:
            %   data - data converted to appropriate type for RGB operations
            
            errorHandler = ErrorHandler.getInstance();
            context = 'PreprocessingValidator.prepareForRGBOperation';
            originalType = class(data);
            
            errorHandler.logInfo(context, sprintf('Preparing data for RGB operation: %s', originalType));
            
            try
                % RGB operations require numeric data (not categorical)
                if iscategorical(data)
                    % Convert categorical to uint8 for RGB operations
                    errorHandler.logDebug(context, 'Converting categorical data to uint8 for RGB operations');
                    data = DataTypeConverter.categoricalToNumeric(data, 'uint8');
                    errorHandler.logInfo(context, 'Converted categorical to uint8');
                    
                elseif islogical(data)
                    % Convert logical to uint8
                    errorHandler.logDebug(context, 'Converting logical data to uint8');
                    data = uint8(data) * 255;
                    errorHandler.logInfo(context, 'Converted logical to uint8');
                    
                elseif isnumeric(data)
                    % Numeric data - ensure it's in appropriate format
                    switch class(data)
                        case {'double', 'single'}
                            % Floating point - check range and convert if needed
                            minVal = min(data(:));
                            maxVal = max(data(:));
                            
                            if minVal >= 0 && maxVal <= 1
                                % Normalized range - keep as is for RGB operations
                                errorHandler.logInfo(context, sprintf('%s data in normalized range [0,1]', class(data)));
                            elseif minVal >= 0 && maxVal <= 255
                                % Likely uint8 range in floating point
                                errorHandler.logDebug(context, 'Converting floating point data in [0,255] range to uint8');
                                data = uint8(data);
                                errorHandler.logInfo(context, 'Converted floating point to uint8');
                            else
                                % Unusual range - normalize to [0,1]
                                errorHandler.logDataInconsistency(context, 'unusual_range', ...
                                    sprintf('Data has unusual range [%g, %g], normalizing to [0,1]', minVal, maxVal), 'medium');
                                if maxVal > minVal
                                    data = (data - minVal) / (maxVal - minVal);
                                    errorHandler.logInfo(context, sprintf('Normalized from range [%g, %g] to [0,1]', minVal, maxVal));
                                else
                                    errorHandler.logDataInconsistency(context, 'constant_value', ...
                                        'Data has constant value - no normalization needed', 'low');
                                    errorHandler.logInfo(context, 'Data has constant value');
                                end
                            end
                            
                        case {'uint8', 'uint16'}
                            % Integer types are fine for RGB operations
                            errorHandler.logInfo(context, sprintf('%s data - no conversion needed', class(data)));
                            
                        otherwise
                            errorHandler.logDataInconsistency(context, 'unknown_numeric_type', ...
                                sprintf('Unknown numeric type for RGB operation: %s', class(data)), 'medium');
                            warning('PreprocessingValidator:UnknownNumericType', ...
                                'Unknown numeric type for RGB operation: %s', class(data));
                    end
                    
                else
                    errorHandler.logError(context, sprintf('Cannot prepare data of type %s for RGB operations', class(data)));
                    error('PreprocessingValidator:UnsupportedType', ...
                        'Cannot prepare data of type %s for RGB operations', class(data));
                end
                
                % Final validation
                if iscategorical(data)
                    errorHandler.logError(context, 'Data is still categorical after RGB preparation');
                    error('PreprocessingValidator:ConversionFailed', ...
                        'Data is still categorical after RGB preparation');
                end
                
                errorHandler.logInfo(context, sprintf('RGB preparation complete: %s -> %s', originalType, class(data)));
                
            catch ME
                errorHandler.logError(context, sprintf('RGB preparation failed: %s', ME.message));
                errorHandler.logError(context, sprintf('Input type: %s, size: %s', originalType, mat2str(size(data))));
                rethrow(ME);
            end
        end
        
        function data = prepareForCategoricalOperation(data)
            % Prepare data for categorical operations (like training, evaluation)
            %
            % Input:
            %   data - input data that needs to be prepared for categorical operations
            %
            % Output:
            %   data - data converted to categorical format
            
            try
                originalType = class(data);
                fprintf('Preparing data for categorical operation: %s -> ', originalType);
                
                if iscategorical(data)
                    % Already categorical - validate structure
                    validation = DataTypeConverter.validateCategoricalStructure(data);
                    if ~validation.isValid
                        error('PreprocessingValidator:InvalidCategorical', ...
                            'Categorical data validation failed: %s', strjoin(validation.errors, '; '));
                    end
                    
                    % Issue warnings if any
                    for i = 1:length(validation.warnings)
                        warning('PreprocessingValidator:CategoricalWarning', validation.warnings{i});
                    end
                    
                    fprintf('categorical (validated)\n');
                    
                else
                    % Convert to categorical
                    data = DataTypeConverter.numericToCategorical(data);
                    fprintf('categorical (converted from %s)\n', originalType);
                end
                
                % Final validation
                if ~iscategorical(data)
                    error('PreprocessingValidator:ConversionFailed', ...
                        'Data is not categorical after categorical preparation');
                end
                
            catch ME
                fprintf('Error preparing data for categorical operation:\n');
                fprintf('  Input type: %s\n', originalType);
                fprintf('  Input size: %s\n', mat2str(size(data)));
                rethrow(ME);
            end
        end
        
        function result = validateDataCompatibility(img, mask)
            % Validate that image and mask data are compatible
            %
            % Inputs:
            %   img - image data
            %   mask - mask data
            %
            % Output:
            %   result - struct with compatibility validation results
            
            result = struct();
            result.isCompatible = true;
            result.warnings = {};
            result.errors = {};
            
            try
                % Check dimensions compatibility
                imgSize = size(img);
                maskSize = size(mask);
                
                % Compare spatial dimensions (first 2 dimensions)
                if ~isequal(imgSize(1:2), maskSize(1:2))
                    result.isCompatible = false;
                    result.errors{end+1} = sprintf('Spatial dimensions mismatch: image %s vs mask %s', ...
                        mat2str(imgSize(1:2)), mat2str(maskSize(1:2)));
                end
                
                % Check if image has color channels
                if length(imgSize) >= 3 && imgSize(3) > 1
                    result.warnings{end+1} = sprintf('Image has %d channels - may need conversion for some operations', imgSize(3));
                end
                
                % Check data type compatibility
                imgType = class(img);
                maskType = class(mask);
                
                % Warn about potential type conversion needs
                if strcmp(imgType, 'categorical') || strcmp(maskType, 'categorical')
                    if ~strcmp(imgType, maskType)
                        result.warnings{end+1} = sprintf('Mixed data types: image %s, mask %s - conversions may be needed', imgType, maskType);
                    end
                end
                
                % Check value ranges for numeric data
                if isnumeric(img) && isnumeric(mask)
                    imgRange = [min(img(:)), max(img(:))];
                    maskRange = [min(mask(:)), max(mask(:))];
                    
                    % Check if ranges suggest different normalization
                    if (imgRange(2) <= 1 && maskRange(2) > 1) || (imgRange(2) > 1 && maskRange(2) <= 1)
                        result.warnings{end+1} = sprintf('Different value ranges: image [%g,%g], mask [%g,%g]', ...
                            imgRange(1), imgRange(2), maskRange(1), maskRange(2));
                    end
                end
                
                result.imageSize = imgSize;
                result.maskSize = maskSize;
                result.imageType = imgType;
                result.maskType = maskType;
                
            catch ME
                result.isCompatible = false;
                result.errors{end+1} = ME.message;
            end
        end
        
        function reportValidationSummary(validationResults)
            % Report a summary of validation results
            %
            % Input:
            %   validationResults - struct or cell array of validation results
            
            fprintf('\n=== Preprocessing Validation Summary ===\n');
            
            if isstruct(validationResults)
                % Single validation result
                PreprocessingValidator.reportSingleValidation(validationResults);
            elseif iscell(validationResults)
                % Multiple validation results
                for i = 1:length(validationResults)
                    fprintf('\nValidation %d:\n', i);
                    PreprocessingValidator.reportSingleValidation(validationResults{i});
                end
            else
                fprintf('Invalid validation results format\n');
            end
            
            fprintf('========================================\n\n');
        end
        
        function isValid = validateImageMaskPair(img, mask)
            % Validate that image and mask are compatible for processing
            %
            % Inputs:
            %   img - image data
            %   mask - mask data (categorical, logical, or numeric)
            %
            % Output:
            %   isValid - boolean indicating if pair is valid
            
            errorHandler = ErrorHandler.getInstance();
            context = 'PreprocessingValidator.validateImageMaskPair';
            
            errorHandler.logDebug(context, sprintf('Validating image-mask pair: img=%s[%s], mask=%s[%s]', ...
                class(img), mat2str(size(img)), class(mask), mat2str(size(mask))));
            
            isValid = false;
            
            try
                % Validate individual components first
                PreprocessingValidator.validateImageData(img);
                PreprocessingValidator.validateMaskData(mask);
                
                % Check size compatibility
                imgSize = size(img);
                maskSize = size(mask);
                
                % For images, we care about height and width (first 2 dimensions)
                if length(imgSize) >= 2 && length(maskSize) >= 2
                    if imgSize(1) ~= maskSize(1) || imgSize(2) ~= maskSize(2)
                        errorHandler.logDataInconsistency(context, 'size_mismatch', ...
                            sprintf('Image size [%d,%d] does not match mask size [%d,%d]', ...
                            imgSize(1), imgSize(2), maskSize(1), maskSize(2)), 'high');
                        error('PreprocessingValidator:SizeMismatch', ...
                            'Image size [%d,%d] does not match mask size [%d,%d]', ...
                            imgSize(1), imgSize(2), maskSize(1), maskSize(2));
                    end
                else
                    errorHandler.logError(context, 'Invalid dimensions for image or mask');
                    error('PreprocessingValidator:InvalidDimensions', ...
                        'Image and mask must have at least 2 dimensions');
                end
                
                % Additional compatibility checks
                if iscategorical(mask)
                    cats = categories(mask);
                    if length(cats) ~= 2
                        errorHandler.logDataInconsistency(context, 'category_count', ...
                            sprintf('Expected 2 categories for binary mask, got %d', length(cats)), 'medium');
                        warning('PreprocessingValidator:UnexpectedCategories', ...
                            'Expected 2 categories for binary mask, got %d', length(cats));
                    end
                end
                
                % Check for data type compatibility
                if isnumeric(img) && isnumeric(mask)
                    % Both numeric - check value ranges
                    imgRange = [min(img(:)), max(img(:))];
                    maskRange = [min(mask(:)), max(mask(:))];
                    
                    errorHandler.logDebug(context, sprintf('Value ranges - img: [%g,%g], mask: [%g,%g]', ...
                        imgRange(1), imgRange(2), maskRange(1), maskRange(2)));
                end
                
                isValid = true;
                errorHandler.logInfo(context, 'Image-mask pair validation successful');
                
            catch ME
                errorHandler.logError(context, sprintf('Image-mask pair validation failed: %s', ME.message));
                isValid = false;
                rethrow(ME);
            end
        end
        
        function isValid = validateCategoricalData(data)
            % Validate categorical data structure and content
            %
            % Input:
            %   data - categorical data to validate
            %
            % Output:
            %   isValid - boolean indicating if data is valid
            
            errorHandler = ErrorHandler.getInstance();
            context = 'PreprocessingValidator.validateCategoricalData';
            
            errorHandler.logDebug(context, sprintf('Validating categorical data: size=%s', ...
                mat2str(size(data))));
            
            isValid = false;
            
            try
                % Check if data is categorical
                if ~iscategorical(data)
                    errorHandler.logError(context, 'Input data must be categorical');
                    error('PreprocessingValidator:NotCategorical', 'Input data must be categorical');
                end
                
                % Check categories
                cats = categories(data);
                if isempty(cats)
                    errorHandler.logError(context, 'Categorical data has no categories');
                    error('PreprocessingValidator:NoCategories', 'Categorical data has no categories');
                end
                
                % For binary segmentation, expect exactly 2 categories
                if length(cats) ~= 2
                    errorHandler.logDataInconsistency(context, 'category_count', ...
                        sprintf('Expected 2 categories for binary segmentation, got %d', length(cats)), 'medium');
                    warning('PreprocessingValidator:UnexpectedCategoryCount', ...
                        'Expected 2 categories for binary segmentation, got %d', length(cats));
                end
                
                % Check for expected category names
                expectedPatterns = {'background', 'foreground'};
                hasExpectedPattern = false;
                
                for i = 1:length(expectedPatterns)
                    if any(contains(cats, expectedPatterns{i}, 'IgnoreCase', true))
                        hasExpectedPattern = true;
                        break;
                    end
                end
                
                if ~hasExpectedPattern
                    errorHandler.logDataInconsistency(context, 'category_names', ...
                        sprintf('Categories [%s] do not follow expected pattern', strjoin(cats, ', ')), 'low');
                    warning('PreprocessingValidator:UnexpectedCategoryNames', ...
                        'Categories [%s] do not follow expected pattern [background, foreground]', ...
                        strjoin(cats, ', '));
                end
                
                % Check for empty categories
                for i = 1:length(cats)
                    if sum(data == cats{i}) == 0
                        errorHandler.logDataInconsistency(context, 'empty_category', ...
                            sprintf('Category "%s" has no instances', cats{i}), 'medium');
                        warning('PreprocessingValidator:EmptyCategory', ...
                            'Category "%s" has no instances in the data', cats{i});
                    end
                end
                
                % Check data distribution
                catCounts = countcats(data);
                totalCount = sum(catCounts);
                
                for i = 1:length(cats)
                    percentage = (catCounts(i) / totalCount) * 100;
                    errorHandler.logDebug(context, sprintf('Category "%s": %d instances (%.1f%%)', ...
                        cats{i}, catCounts(i), percentage));
                    
                    % Warn about extreme imbalance
                    if percentage < 1.0
                        errorHandler.logDataInconsistency(context, 'class_imbalance', ...
                            sprintf('Category "%s" represents only %.1f%% of data', cats{i}, percentage), 'low');
                        warning('PreprocessingValidator:ClassImbalance', ...
                            'Category "%s" represents only %.1f%% of data', cats{i}, percentage);
                    end
                end
                
                isValid = true;
                errorHandler.logInfo(context, sprintf('Categorical data validation successful: %d categories, %d total instances', ...
                    length(cats), totalCount));
                
            catch ME
                errorHandler.logError(context, sprintf('Categorical data validation failed: %s', ME.message));
                isValid = false;
                rethrow(ME);
            end
        end
        
    end
    
    methods (Static, Access = private)
        
        function reportSingleValidation(result)
            % Report a single validation result
            %
            % Input:
            %   result - validation result struct
            
            if isfield(result, 'isCompatible')
                % Compatibility validation
                if result.isCompatible
                    fprintf('✓ Data compatibility: PASSED\n');
                else
                    fprintf('✗ Data compatibility: FAILED\n');
                end
                
                if isfield(result, 'imageSize') && isfield(result, 'maskSize')
                    fprintf('  Image size: %s (%s)\n', mat2str(result.imageSize), result.imageType);
                    fprintf('  Mask size: %s (%s)\n', mat2str(result.maskSize), result.maskType);
                end
                
            elseif isfield(result, 'isValid')
                % General validation
                if result.isValid
                    fprintf('✓ Validation: PASSED\n');
                else
                    fprintf('✗ Validation: FAILED\n');
                end
            end
            
            % Report errors
            if isfield(result, 'errors') && ~isempty(result.errors)
                fprintf('  Errors:\n');
                for i = 1:length(result.errors)
                    fprintf('    - %s\n', result.errors{i});
                end
            end
            
            % Report warnings
            if isfield(result, 'warnings') && ~isempty(result.warnings)
                fprintf('  Warnings:\n');
                for i = 1:length(result.warnings)
                    fprintf('    - %s\n', result.warnings{i});
                end
            end
        end
        
    end
end