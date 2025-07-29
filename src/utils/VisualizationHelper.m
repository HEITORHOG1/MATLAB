classdef VisualizationHelper < handle
    % VisualizationHelper - Utility class for safe image and mask visualization
    % 
    % This class provides methods to safely prepare data for visualization,
    % handling categorical to numeric conversions and type validation.
    %
    % Methods:
    %   prepareImageForDisplay - Prepare image data for imshow
    %   prepareMaskForDisplay - Prepare mask data for visualization
    %   prepareComparisonData - Prepare data for side-by-side comparison
    %   safeImshow - Safe wrapper for imshow with error handling
    
    methods (Static)
        
        function imgData = prepareImageForDisplay(img)
            % Prepare image data for display with imshow
            % Handles type conversions and normalization
            %
            % Input:
            %   img - Image data (any numeric type or categorical)
            % Output:
            %   imgData - Image data ready for imshow (uint8 or double [0,1])
            
            try
                % Handle categorical data
                if iscategorical(img)
                    % Convert categorical to numeric for display
                    cats = categories(img);
                    if length(cats) == 2
                        % Binary categorical - convert to grayscale
                        imgData = uint8(img == cats{2}) * 255;
                    else
                        % Multi-class categorical - use label indices
                        imgData = uint8(double(img) - 1) * (255 / (length(cats) - 1));
                    end
                    return;
                end
                
                % Handle logical data
                if islogical(img)
                    imgData = uint8(img) * 255;
                    return;
                end
                
                % Handle numeric data
                if isnumeric(img)
                    % Check data range and type
                    if isa(img, 'uint8')
                        imgData = img;
                    else
                        % Convert to appropriate range
                        minVal = min(img(:));
                        maxVal = max(img(:));
                        
                        if minVal >= 0 && maxVal <= 1
                            % Data in [0,1] range - keep as double
                            imgData = double(img);
                        elseif minVal >= 0 && maxVal <= 255
                            % Data in [0,255] range - convert to uint8
                            imgData = uint8(img);
                        else
                            % Normalize to [0,1] range
                            if maxVal > minVal
                                imgData = (double(img) - minVal) / (maxVal - minVal);
                            else
                                imgData = zeros(size(img));
                            end
                        end
                    end
                else
                    error('VisualizationHelper:InvalidType', ...
                        'Unsupported data type for image display: %s', class(img));
                end
                
            catch ME
                warning('VisualizationHelper:PrepareImageFailed', ...
                    'Failed to prepare image for display: %s', ME.message);
                % Return zeros as fallback
                imgData = zeros(size(img), 'uint8');
            end
        end
        
        function maskData = prepareMaskForDisplay(mask)
            % Prepare mask data for visualization
            % Handles categorical to uint8 conversion for masks
            %
            % Input:
            %   mask - Mask data (categorical, logical, or numeric)
            % Output:
            %   maskData - Mask data ready for display (uint8 [0,255])
            
            try
                % Handle categorical masks
                if iscategorical(mask)
                    % Validate categorical structure
                    cats = categories(mask);
                    if length(cats) ~= 2
                        warning('VisualizationHelper:UnexpectedCategories', ...
                            'Expected 2 categories for binary mask, found %d', length(cats));
                    end
                    
                    % Convert to binary mask (foreground = 255, background = 0)
                    if any(contains(cats, 'foreground', 'IgnoreCase', true))
                        foregroundCat = cats{contains(cats, 'foreground', 'IgnoreCase', true)};
                        maskData = uint8(mask == foregroundCat) * 255;
                    else
                        % Use second category as foreground
                        maskData = uint8(mask == cats{end}) * 255;
                    end
                    return;
                end
                
                % Handle logical masks
                if islogical(mask)
                    maskData = uint8(mask) * 255;
                    return;
                end
                
                % Handle numeric masks
                if isnumeric(mask)
                    if isa(mask, 'uint8')
                        maskData = mask;
                    else
                        % Convert to binary and then uint8
                        if max(mask(:)) <= 1
                            % Assume [0,1] range
                            maskData = uint8(mask > 0.5) * 255;
                        else
                            % Assume [0,255] range or threshold at 1
                            maskData = uint8(mask > 1) * 255;
                        end
                    end
                else
                    error('VisualizationHelper:InvalidMaskType', ...
                        'Unsupported data type for mask display: %s', class(mask));
                end
                
            catch ME
                warning('VisualizationHelper:PrepareMaskFailed', ...
                    'Failed to prepare mask for display: %s', ME.message);
                % Return zeros as fallback
                maskData = zeros(size(mask), 'uint8');
            end
        end
        
        function [imgOut, maskOut, predOut] = prepareComparisonData(img, mask, pred)
            % Prepare image, mask, and prediction data for comparison visualization
            % Ensures all data types are compatible for side-by-side display
            %
            % Inputs:
            %   img - Original image
            %   mask - Ground truth mask
            %   pred - Prediction mask
            % Outputs:
            %   imgOut - Prepared image data
            %   maskOut - Prepared ground truth mask
            %   predOut - Prepared prediction mask
            
            try
                % Prepare image
                imgOut = VisualizationHelper.prepareImageForDisplay(img);
                
                % Prepare ground truth mask
                maskOut = VisualizationHelper.prepareMaskForDisplay(mask);
                
                % Prepare prediction mask
                predOut = VisualizationHelper.prepareMaskForDisplay(pred);
                
                % Ensure all outputs have compatible sizes
                imgSize = size(imgOut);
                maskSize = size(maskOut);
                predSize = size(predOut);
                
                % Check size compatibility
                if ~isequal(imgSize(1:2), maskSize(1:2)) || ~isequal(imgSize(1:2), predSize(1:2))
                    warning('VisualizationHelper:SizeMismatch', ...
                        'Size mismatch detected. Image: [%d,%d], Mask: [%d,%d], Pred: [%d,%d]', ...
                        imgSize(1), imgSize(2), maskSize(1), maskSize(2), predSize(1), predSize(2));
                end
                
            catch ME
                warning('VisualizationHelper:PrepareComparisonFailed', ...
                    'Failed to prepare comparison data: %s', ME.message);
                % Return original data as fallback
                imgOut = img;
                maskOut = mask;
                predOut = pred;
            end
        end
        
        function success = safeImshow(data, varargin)
            % Safe wrapper for imshow with comprehensive error handling
            % Attempts to display data and handles common visualization errors
            %
            % Inputs:
            %   data - Image data to display
            %   varargin - Additional arguments passed to imshow
            % Output:
            %   success - Boolean indicating if display was successful
            
            errorHandler = ErrorHandler.getInstance();
            context = 'VisualizationHelper.safeImshow';
            success = false;
            
            errorHandler.logDebug(context, sprintf('Attempting to display data: type=%s, size=%s', ...
                class(data), mat2str(size(data))));
            
            % Define primary and fallback display functions
            primaryDisplay = @() VisualizationHelper.performPrimaryDisplay(data, varargin);
            fallbackDisplay = @() VisualizationHelper.performFallbackDisplay(data, varargin);
            
            try
                % Execute with fallback mechanism
                success = errorHandler.executeWithFallback(context, primaryDisplay, fallbackDisplay);
                
                if success
                    errorHandler.logInfo(context, 'Image display successful');
                else
                    errorHandler.logError(context, 'All display methods failed');
                end
                
            catch ME
                errorHandler.logError(context, sprintf('Display failed completely: %s', ME.message));
                success = false;
            end
        end
        
        function success = performPrimaryDisplay(data, varargin)
            % Primary display method
            
            errorHandler = ErrorHandler.getInstance();
            context = 'VisualizationHelper.performPrimaryDisplay';
            
            % Validate input data
            if isempty(data)
                errorHandler.logDataInconsistency(context, 'empty_data', ...
                    'Cannot display empty data', 'high');
                error('VisualizationHelper:EmptyData', 'Cannot display empty data');
            end
            
            % Prepare data for display
            if iscategorical(data) || islogical(data)
                errorHandler.logDebug(context, 'Preparing mask data for display');
                displayData = VisualizationHelper.prepareMaskForDisplay(data);
            else
                errorHandler.logDebug(context, 'Preparing image data for display');
                displayData = VisualizationHelper.prepareImageForDisplay(data);
            end
            
            % Attempt to display
            if isempty(varargin)
                imshow(displayData);
            else
                imshow(displayData, varargin{:});
            end
            
            success = true;
        end
        
        function success = performFallbackDisplay(data, varargin)
            % Fallback display methods
            
            errorHandler = ErrorHandler.getInstance();
            context = 'VisualizationHelper.performFallbackDisplay';
            success = false;
            
            % Prepare data for display
            if iscategorical(data) || islogical(data)
                displayData = VisualizationHelper.prepareMaskForDisplay(data);
            else
                displayData = VisualizationHelper.prepareImageForDisplay(data);
            end
            
            % Try alternative display methods
            try
                errorHandler.logDebug(context, 'Trying imshow with explicit range');
                % Try with explicit range
                if isnumeric(displayData)
                    if isa(displayData, 'uint8')
                        imshow(displayData, [0 255]);
                    else
                        imshow(displayData, []);
                    end
                    success = true;
                    errorHandler.logInfo(context, 'Alternative imshow method succeeded');
                end
            catch ME2
                errorHandler.logWarning(context, sprintf('Alternative imshow failed: %s', ME2.message));
                
                % Final fallback - try imagesc
                try
                    errorHandler.logDebug(context, 'Trying imagesc as final fallback');
                    imagesc(displayData);
                    colormap gray;
                    axis image;
                    success = true;
                    errorHandler.logWarning(context, 'Final fallback (imagesc) succeeded');
                catch ME3
                    errorHandler.logError(context, sprintf('All display methods failed: %s', ME3.message));
                    error('VisualizationHelper:AllDisplayMethodsFailed', ...
                        'All display methods failed: %s', ME3.message);
                end
            end
        end
        
    end
end