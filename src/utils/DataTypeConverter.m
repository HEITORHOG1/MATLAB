classdef DataTypeConverter < handle
    % DataTypeConverter - Utility class for safe data type conversions
    % 
    % This class provides static methods for converting between different
    % data types commonly used in image processing and machine learning,
    % with special focus on categorical to numeric conversions.
    %
    % Key Features:
    % - Safe categorical to numeric conversions
    % - Validation methods for data type checking
    % - Error handling with graceful fallbacks
    % - Standardized categorical creation
    
    methods (Static)
        
        function output = categoricalToNumeric(data, targetType)
            % Convert categorical data to numeric types
            % 
            % Inputs:
            %   data - categorical array
            %   targetType - (optional) target type ('double', 'uint8', 'single', 'logical')
            %              Default: 'uint8'
            %
            % Output:
            %   output - converted numeric array
            
            % Handle optional targetType parameter
            if nargin < 2
                targetType = 'uint8'; % Default type for mask data
            end
            
            errorHandler = ErrorHandler.getInstance();
            context = 'DataTypeConverter.categoricalToNumeric';
            
            % Log conversion attempt
            errorHandler.logDebug(context, sprintf('Starting conversion: %s -> %s, size: %s', ...
                class(data), targetType, mat2str(size(data))));
            
            try
                % Validate input
                if ~iscategorical(data)
                    errorHandler.logError(context, 'Input data must be categorical');
                    error('DataTypeConverter:InvalidInput', 'Input data must be categorical');
                end
                
                % Validate target type
                validTypes = {'double', 'uint8', 'single', 'logical'};
                if ~ismember(targetType, validTypes)
                    errorHandler.logError(context, sprintf('Invalid target type: %s', targetType));
                    error('DataTypeConverter:InvalidTargetType', ...
                        'Target type must be one of: %s', strjoin(validTypes, ', '));
                end
                
                % Get categories and validate structure
                cats = categories(data);
                if length(cats) ~= 2
                    errorHandler.logDataInconsistency(context, 'category_count', ...
                        sprintf('Expected exactly 2 categories, got %d', length(cats)), 'high');
                    error('DataTypeConverter:InvalidCategories', ...
                        'Expected exactly 2 categories, got %d', length(cats));
                end
                
                % Check if categories follow expected pattern
                expectedCats = ["background", "foreground"];
                if ~isequal(sort(cats), sort(expectedCats))
                    errorHandler.logDataInconsistency(context, 'category_names', ...
                        sprintf('Categories [%s] do not match expected pattern [%s]', ...
                        strjoin(cats, ', '), strjoin(expectedCats, ', ')), 'medium');
                    warning('DataTypeConverter:UnexpectedCategories', ...
                        'Categories do not match expected pattern ["background", "foreground"]. Got: [%s]', ...
                        strjoin(cats, ', '));
                end
                
                % Debug categorical data before conversion
                errorHandler.debugCategoricalIssue(context, data, targetType);
                
                % Convert based on target type
                switch targetType
                    case 'logical'
                        % Convert to logical (true for foreground)
                        output = (data == "foreground");
                        
                    case 'double'
                        % Convert to double (0 for background, 1 for foreground)
                        output = double(data == "foreground");
                        
                    case 'single'
                        % Convert to single (0 for background, 1 for foreground)
                        output = single(data == "foreground");
                        
                    case 'uint8'
                        % Convert to uint8 (0 for background, 255 for foreground)
                        output = uint8(data == "foreground") * 255;
                        
                    otherwise
                        errorHandler.logError(context, sprintf('Unsupported target type: %s', targetType));
                        error('DataTypeConverter:UnsupportedType', ...
                            'Unsupported target type: %s', targetType);
                end
                
                % Log successful conversion with details
                details = struct();
                details.categories = cats;
                details.outputRange = [min(output(:)), max(output(:))];
                details.outputSum = sum(output(:));
                
                errorHandler.logCategoricalConversion(context, class(data), targetType, ...
                    size(data), true, details);
                
            catch ME
                % Log failed conversion
                details = struct();
                if iscategorical(data)
                    details.categories = categories(data);
                end
                details.errorMessage = ME.message;
                
                errorHandler.logCategoricalConversion(context, class(data), targetType, ...
                    size(data), false, details);
                
                % Provide detailed error information
                errorHandler.logError(context, sprintf('Conversion failed: %s', ME.message));
                errorHandler.logError(context, sprintf('Input type: %s, size: %s, target: %s', ...
                    class(data), mat2str(size(data)), targetType));
                
                if iscategorical(data)
                    errorHandler.logError(context, sprintf('Categories: [%s]', ...
                        strjoin(categories(data), ', ')));
                end
                
                rethrow(ME);
            end
        end
        
        function output = numericToCategorical(data, classNames, labelIDs)
            % Convert numeric data to categorical
            %
            % Inputs:
            %   data - numeric array (logical, double, uint8, single)
            %   classNames - cell array of class names (optional)
            %   labelIDs - array of label IDs (optional)
            %
            % Output:
            %   output - categorical array
            
            try
                % Set default parameters for binary classification
                if nargin < 2 || isempty(classNames)
                    classNames = ["background", "foreground"];
                end
                if nargin < 3 || isempty(labelIDs)
                    labelIDs = [0, 1];
                end
                
                % Validate inputs
                if ~isnumeric(data) && ~islogical(data)
                    error('DataTypeConverter:InvalidInput', ...
                        'Input data must be numeric or logical');
                end
                
                if length(classNames) ~= length(labelIDs)
                    error('DataTypeConverter:MismatchedParameters', ...
                        'classNames and labelIDs must have the same length');
                end
                
                % Convert based on input type
                if islogical(data)
                    % Logical data: false -> background, true -> foreground
                    binaryData = data;
                elseif isa(data, 'uint8')
                    % uint8 data: assume 0 -> background, >0 -> foreground
                    binaryData = data > 0;
                else
                    % double/single data: assume threshold at 0.5
                    binaryData = data > 0.5;
                end
                
                % Create categorical with standardized structure
                output = categorical(binaryData, labelIDs, classNames);
                
            catch ME
                % Provide detailed error information
                fprintf('Error in numericToCategorical conversion:\n');
                fprintf('  Input type: %s\n', class(data));
                fprintf('  Input size: %s\n', mat2str(size(data)));
                fprintf('  Input range: [%g, %g]\n', min(data(:)), max(data(:)));
                rethrow(ME);
            end
        end
        
        function isValid = validateDataType(data, expectedTypes)
            % Validate if data matches expected types
            %
            % Inputs:
            %   data - data to validate
            %   expectedTypes - cell array of expected type strings
            %
            % Output:
            %   isValid - logical indicating if data type is valid
            
            try
                if ischar(expectedTypes)
                    expectedTypes = {expectedTypes};
                end
                
                dataType = class(data);
                isValid = ismember(dataType, expectedTypes);
                
                if ~isValid
                    fprintf('Data type validation failed:\n');
                    fprintf('  Actual type: %s\n', dataType);
                    fprintf('  Expected types: [%s]\n', strjoin(expectedTypes, ', '));
                end
                
            catch ME
                fprintf('Error in validateDataType:\n');
                fprintf('  Data class: %s\n', class(data));
                rethrow(ME);
                isValid = false;
            end
        end
        
        function output = safeConversion(data, targetType, context)
            % Perform safe conversion with comprehensive error handling
            %
            % Inputs:
            %   data - input data
            %   targetType - target type string
            %   context - string describing the conversion context (optional)
            %
            % Output:
            %   output - converted data
            
            if nargin < 3
                context = 'unknown';
            end
            
            errorHandler = ErrorHandler.getInstance();
            fullContext = sprintf('DataTypeConverter.safeConversion[%s]', context);
            
            % Define primary and fallback conversion functions
            primaryConversion = @() DataTypeConverter.performPrimaryConversion(data, targetType, fullContext);
            fallbackConversion = @() DataTypeConverter.performFallbackConversion(data, targetType, fullContext);
            
            % Execute with fallback mechanism
            output = errorHandler.executeWithFallback(fullContext, primaryConversion, fallbackConversion);
        end
        
        function output = performPrimaryConversion(data, targetType, context)
            % Primary conversion logic (extracted for fallback mechanism)
            
            errorHandler = ErrorHandler.getInstance();
            inputType = class(data);
            
            % Log conversion attempt
            errorHandler.logInfo(context, sprintf('Primary conversion: %s -> %s', inputType, targetType));
            
            % Handle different conversion scenarios
            if strcmp(inputType, targetType)
                % No conversion needed
                output = data;
                errorHandler.logDebug(context, 'No conversion needed - types match');
                return;
            end
            
            if iscategorical(data)
                % Categorical to numeric conversion
                output = DataTypeConverter.categoricalToNumeric(data, targetType);
                
            elseif isnumeric(data) || islogical(data)
                % Numeric to numeric conversion
                switch targetType
                    case 'double'
                        output = double(data);
                    case 'single'
                        output = single(data);
                    case 'uint8'
                        if islogical(data)
                            output = uint8(data) * 255;
                        else
                            % Normalize to [0,255] range
                            dataMin = min(data(:));
                            dataMax = max(data(:));
                            if dataMax > dataMin
                                normalized = (data - dataMin) / (dataMax - dataMin);
                                output = uint8(normalized * 255);
                            else
                                output = uint8(data);
                            end
                        end
                    case 'logical'
                        if isa(data, 'uint8')
                            output = data > 0;
                        else
                            output = data > 0.5;
                        end
                    case 'categorical'
                        output = DataTypeConverter.numericToCategorical(data);
                    otherwise
                        error('DataTypeConverter:UnsupportedConversion', ...
                            'Unsupported target type: %s', targetType);
                end
                
            else
                error('DataTypeConverter:UnsupportedInputType', ...
                    'Unsupported input type: %s', inputType);
            end
            
            % Validate conversion result
            if ~strcmp(class(output), targetType)
                errorHandler.logDataInconsistency(context, 'type_mismatch', ...
                    sprintf('Conversion result type (%s) does not match target (%s)', ...
                    class(output), targetType), 'medium');
                warning('DataTypeConverter:ConversionMismatch', ...
                    'Conversion result type (%s) does not match target (%s)', ...
                    class(output), targetType);
            end
        end
        
        function output = performFallbackConversion(data, targetType, context)
            % Fallback conversion logic for when primary conversion fails
            
            errorHandler = ErrorHandler.getInstance();
            
            errorHandler.logWarning(context, 'Attempting fallback conversion');
            
            if iscategorical(data) && ismember(targetType, {'double', 'single'})
                % Fallback: use double() conversion (may not be correct but won't crash)
                output = cast(double(data), targetType);
                
                errorHandler.logDataInconsistency(context, 'fallback_used', ...
                    'Used fallback categorical conversion - results may be incorrect', 'high');
                
                warning('DataTypeConverter:FallbackUsed', ...
                    'Used fallback conversion - results may be incorrect');
            else
                error('DataTypeConverter:NoFallbackAvailable', ...
                    'No fallback conversion available for %s -> %s', class(data), targetType);
            end
        end
        
        function validated = validateCategoricalStructure(data)
            % Validate that categorical data has the expected structure
            %
            % Input:
            %   data - categorical array to validate
            %
            % Output:
            %   validated - struct with validation results
            
            validated = struct();
            validated.isValid = true;
            validated.warnings = {};
            validated.errors = {};
            
            try
                if ~iscategorical(data)
                    validated.isValid = false;
                    validated.errors{end+1} = 'Data is not categorical';
                    return;
                end
                
                % Check categories
                cats = categories(data);
                validated.categories = cats;
                validated.numCategories = length(cats);
                
                % Check for expected binary structure
                expectedCats = ["background", "foreground"];
                if length(cats) ~= 2
                    validated.warnings{end+1} = sprintf('Expected 2 categories, found %d', length(cats));
                end
                
                if ~isequal(sort(cats), sort(expectedCats))
                    validated.warnings{end+1} = sprintf('Categories [%s] do not match expected [%s]', ...
                        strjoin(cats, ', '), strjoin(expectedCats, ', '));
                end
                
                % Check value distribution
                uniqueVals = unique(data);
                validated.uniqueValues = uniqueVals;
                validated.numUniqueValues = length(uniqueVals);
                
                % Check if all categories are represented
                if length(uniqueVals) < length(cats)
                    validated.warnings{end+1} = 'Not all categories are represented in the data';
                end
                
                % Check double conversion behavior
                doubleVals = double(data);
                validated.doubleRange = [min(doubleVals(:)), max(doubleVals(:))];
                
                % Warn if double conversion doesn't give expected 1,2 values
                expectedDoubleVals = [1, 2];
                actualDoubleVals = unique(doubleVals);
                if ~isequal(sort(actualDoubleVals), sort(expectedDoubleVals))
                    validated.warnings{end+1} = sprintf('double() conversion gives [%s], expected [1, 2]', ...
                        mat2str(actualDoubleVals));
                end
                
            catch ME
                validated.isValid = false;
                validated.errors{end+1} = ME.message;
            end
        end
        
        function rgbData = categoricalToRGB(data, colorMap)
            % Convert categorical data to RGB representation
            %
            % Inputs:
            %   data - categorical array
            %   colorMap - (optional) color map for categories
            %              Default: [0,0,0] for background, [255,255,255] for foreground
            %
            % Output:
            %   rgbData - RGB image (uint8, size: [H, W, 3])
            
            errorHandler = ErrorHandler.getInstance();
            context = 'DataTypeConverter.categoricalToRGB';
            
            % Handle optional colorMap parameter
            if nargin < 2
                % Default color map: black background, white foreground
                colorMap = [0, 0, 0;      % background
                           255, 255, 255]; % foreground
            end
            
            errorHandler.logDebug(context, sprintf('Converting categorical to RGB: size=%s', ...
                mat2str(size(data))));
            
            try
                % Validate input
                if ~iscategorical(data)
                    errorHandler.logError(context, 'Input data must be categorical');
                    error('DataTypeConverter:InvalidInput', 'Input data must be categorical');
                end
                
                % Get categories
                cats = categories(data);
                if length(cats) ~= 2
                    errorHandler.logDataInconsistency(context, 'category_count', ...
                        sprintf('Expected exactly 2 categories, got %d', length(cats)), 'high');
                    error('DataTypeConverter:InvalidCategories', ...
                        'Expected exactly 2 categories for RGB conversion, got %d', length(cats));
                end
                
                % Validate color map
                if size(colorMap, 1) ~= 2 || size(colorMap, 2) ~= 3
                    errorHandler.logError(context, 'Color map must be 2x3 matrix');
                    error('DataTypeConverter:InvalidColorMap', ...
                        'Color map must be 2x3 matrix [background_rgb; foreground_rgb]');
                end
                
                % Initialize RGB output
                [h, w] = size(data);
                rgbData = zeros(h, w, 3, 'uint8');
                
                % Convert categorical to logical for indexing
                if any(contains(cats, 'foreground', 'IgnoreCase', true))
                    foregroundMask = (data == cats{contains(cats, 'foreground', 'IgnoreCase', true)});
                else
                    % Use second category as foreground
                    foregroundMask = (data == cats{2});
                end
                
                backgroundMask = ~foregroundMask;
                
                % Apply colors
                for c = 1:3
                    channel = rgbData(:, :, c);
                    channel(backgroundMask) = colorMap(1, c);  % background color
                    channel(foregroundMask) = colorMap(2, c);  % foreground color
                    rgbData(:, :, c) = channel;
                end
                
                errorHandler.logInfo(context, sprintf('RGB conversion successful: %s -> [%d,%d,3]', ...
                    mat2str(size(data)), h, w));
                
                output = rgbData;
                
            catch ME
                errorHandler.logError(context, sprintf('RGB conversion failed: %s', ME.message));
                rethrow(ME);
            end
        end
        
    end
end