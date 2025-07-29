classdef MetricsValidator < handle
    % MetricsValidator - Utility class for validating metrics and categorical data
    % 
    % This class provides methods to:
    % - Validate metrics for artificially perfect scores
    % - Check categorical data structure consistency
    % - Provide warnings for suspicious metric patterns
    % - Debug categorical data conversion issues
    %
    % Requirements addressed: 4.1, 4.2, 6.1, 6.2
    
    methods (Static)
        function isValid = validateMetrics(metrics)
            % Validate if metrics are realistic (not artificially perfect)
            %
            % Input:
            %   metrics - struct with fields: iou, dice, accuracy (each with mean/std)
            %
            % Output:
            %   isValid - logical, true if metrics appear realistic
            
            isValid = true;
            
            if ~isstruct(metrics)
                warning('MetricsValidator:InvalidInput', 'Metrics must be a struct');
                isValid = false;
                return;
            end
            
            requiredFields = {'iou', 'dice', 'accuracy'};
            for i = 1:length(requiredFields)
                field = requiredFields{i};
                if ~isfield(metrics, field)
                    warning('MetricsValidator:MissingField', 'Missing required field: %s', field);
                    isValid = false;
                    continue;
                end
                
                metric = metrics.(field);
                if ~isstruct(metric) || ~isfield(metric, 'mean') || ~isfield(metric, 'std')
                    warning('MetricsValidator:InvalidStructure', ...
                        'Field %s must have mean and std subfields', field);
                    isValid = false;
                    continue;
                end
                
                % Check for artificially perfect metrics
                if metric.mean >= 0.9999 && metric.std < 0.0001
                    warning('MetricsValidator:PerfectMetrics', ...
                        'Suspicious perfect metric detected for %s: mean=%.4f, std=%.4f', ...
                        field, metric.mean, metric.std);
                    isValid = false;
                end
                
                % Check for unrealistic values
                if metric.mean < 0 || metric.mean > 1
                    warning('MetricsValidator:InvalidRange', ...
                        'Metric %s mean out of valid range [0,1]: %.4f', field, metric.mean);
                    isValid = false;
                end
                
                if metric.std < 0
                    warning('MetricsValidator:NegativeStd', ...
                        'Metric %s has negative standard deviation: %.4f', field, metric.std);
                    isValid = false;
                end
            end
        end
        
        function warnings = checkPerfectMetrics(iou, dice, accuracy)
            % Check for artificially perfect metrics and return warnings
            %
            % Inputs:
            %   iou, dice, accuracy - arrays of metric values
            %
            % Output:
            %   warnings - cell array of warning messages
            
            warnings = {};
            
            % Check IoU
            if all(iou >= 0.9999)
                warnings{end+1} = 'All IoU values are artificially perfect (>=0.9999)';
            end
            if std(iou) < 0.0001
                warnings{end+1} = sprintf('IoU standard deviation suspiciously low: %.6f', std(iou));
            end
            
            % Check Dice
            if all(dice >= 0.9999)
                warnings{end+1} = 'All Dice values are artificially perfect (>=0.9999)';
            end
            if std(dice) < 0.0001
                warnings{end+1} = sprintf('Dice standard deviation suspiciously low: %.6f', std(dice));
            end
            
            % Check Accuracy
            if all(accuracy >= 0.9999)
                warnings{end+1} = 'All Accuracy values are artificially perfect (>=0.9999)';
            end
            if std(accuracy) < 0.0001
                warnings{end+1} = sprintf('Accuracy standard deviation suspiciously low: %.6f', std(accuracy));
            end
            
            % Check for identical values (indicating calculation error)
            if length(unique(iou)) == 1
                warnings{end+1} = 'All IoU values are identical - possible calculation error';
            end
            if length(unique(dice)) == 1
                warnings{end+1} = 'All Dice values are identical - possible calculation error';
            end
            if length(unique(accuracy)) == 1
                warnings{end+1} = 'All Accuracy values are identical - possible calculation error';
            end
        end
        
        function corrected = correctCategoricalConversion(categorical_data)
            % Correct categorical to binary conversion logic
            %
            % Input:
            %   categorical_data - categorical array
            %
            % Output:
            %   corrected - double array with correct binary conversion
            
            if ~iscategorical(categorical_data)
                error('MetricsValidator:InvalidInput', 'Input must be categorical data');
            end
            
            % Get categories
            cats = categories(categorical_data);
            
            % Debug information
            fprintf('MetricsValidator Debug: Categorical categories: %s\n', strjoin(cats, ', '));
            fprintf('MetricsValidator Debug: Unique values in double(categorical): %s\n', ...
                mat2str(unique(double(categorical_data))));
            
            % Check if categories follow expected pattern
            if length(cats) == 2
                % Assume binary classification
                if any(contains(cats, 'foreground', 'IgnoreCase', true)) || ...
                   any(contains(cats, 'object', 'IgnoreCase', true)) || ...
                   any(contains(cats, '1', 'IgnoreCase', true))
                    
                    % Find foreground category
                    fg_idx = contains(cats, 'foreground', 'IgnoreCase', true) | ...
                             contains(cats, 'object', 'IgnoreCase', true) | ...
                             contains(cats, '1', 'IgnoreCase', true);
                    
                    if any(fg_idx)
                        fg_category = cats{fg_idx};
                        corrected = double(categorical_data == fg_category);
                    else
                        % Fallback: assume second category is foreground
                        corrected = double(categorical_data == cats{2});
                    end
                else
                    % Generic binary: assume second category is positive
                    corrected = double(categorical_data == cats{2});
                end
            else
                % Multi-class: convert to numeric indices
                corrected = double(categorical_data);
                warning('MetricsValidator:MultiClass', ...
                    'Multi-class categorical detected. Using numeric indices.');
            end
            
            fprintf('MetricsValidator Debug: Conversion result range: [%.3f, %.3f]\n', ...
                min(corrected(:)), max(corrected(:)));
        end
        
        function validated = validateCategoricalStructure(data)
            % Validate categorical data structure and provide debugging info
            %
            % Input:
            %   data - categorical array to validate
            %
            % Output:
            %   validated - struct with validation results and debug info
            
            validated = struct();
            validated.isValid = true;
            validated.warnings = {};
            validated.debugInfo = struct();
            
            if ~iscategorical(data)
                validated.isValid = false;
                validated.warnings{end+1} = 'Data is not categorical';
                return;
            end
            
            % Get basic info
            cats = categories(data);
            validated.debugInfo.categories = cats;
            validated.debugInfo.numCategories = length(cats);
            validated.debugInfo.dataSize = size(data);
            validated.debugInfo.uniqueValues = unique(double(data));
            
            % Check for empty categories
            for i = 1:length(cats)
                count = sum(data == cats{i});
                validated.debugInfo.categoryCounts.(cats{i}) = count;
                if count == 0
                    validated.warnings{end+1} = sprintf('Category "%s" has no instances', cats{i});
                end
            end
            
            % Check for standard binary segmentation pattern
            if length(cats) == 2
                hasBackground = any(contains(cats, 'background', 'IgnoreCase', true));
                hasForeground = any(contains(cats, 'foreground', 'IgnoreCase', true));
                
                if hasBackground && hasForeground
                    validated.debugInfo.isStandardBinary = true;
                else
                    validated.debugInfo.isStandardBinary = false;
                    validated.warnings{end+1} = 'Non-standard binary categories detected';
                end
            else
                validated.debugInfo.isStandardBinary = false;
                if length(cats) > 2
                    validated.warnings{end+1} = 'Multi-class categorical detected';
                else
                    validated.warnings{end+1} = 'Single-class categorical detected';
                end
            end
            
            % Check double conversion consistency
            doubleVals = double(data);
            expectedRange = [1, length(cats)];
            actualRange = [min(doubleVals(:)), max(doubleVals(:))];
            
            if ~isequal(expectedRange, actualRange)
                validated.warnings{end+1} = sprintf(...
                    'Double conversion range mismatch. Expected: [%d,%d], Actual: [%d,%d]', ...
                    expectedRange(1), expectedRange(2), actualRange(1), actualRange(2));
            end
            
            validated.debugInfo.doubleRange = actualRange;
            validated.debugInfo.expectedRange = expectedRange;
        end
        
        function debugCategoricalData(data, label)
            % Print detailed debugging information about categorical data
            %
            % Inputs:
            %   data - categorical array to debug
            %   label - string label for identification
            
            if nargin < 2
                label = 'Categorical Data';
            end
            
            fprintf('\n=== MetricsValidator Debug: %s ===\n', label);
            
            if ~iscategorical(data)
                fprintf('ERROR: Data is not categorical (type: %s)\n', class(data));
                return;
            end
            
            % Basic information
            fprintf('Size: %s\n', mat2str(size(data)));
            fprintf('Categories: %s\n', strjoin(categories(data), ', '));
            fprintf('Number of categories: %d\n', length(categories(data)));
            
            % Category counts
            cats = categories(data);
            fprintf('Category distribution:\n');
            for i = 1:length(cats)
                count = sum(data == cats{i});
                percentage = count / numel(data) * 100;
                fprintf('  %s: %d (%.1f%%)\n', cats{i}, count, percentage);
            end
            
            % Double conversion analysis
            doubleData = double(data);
            fprintf('Double conversion:\n');
            fprintf('  Range: [%.3f, %.3f]\n', min(doubleData(:)), max(doubleData(:)));
            fprintf('  Unique values: %s\n', mat2str(unique(doubleData)));
            
            % Common conversion patterns
            fprintf('Common conversions:\n');
            if length(cats) == 2
                % Binary case
                fg_candidates = {'foreground', 'object', '1'};
                for i = 1:length(fg_candidates)
                    if any(contains(cats, fg_candidates{i}, 'IgnoreCase', true))
                        fg_cat = cats{contains(cats, fg_candidates{i}, 'IgnoreCase', true)};
                        binary_result = double(data == fg_cat);
                        fprintf('  (data == "%s"): range [%.3f, %.3f], sum=%d\n', ...
                            fg_cat, min(binary_result(:)), max(binary_result(:)), sum(binary_result(:)));
                        break;
                    end
                end
            end
            
            fprintf('=== End Debug ===\n\n');
        end
        
        function report = validateComprehensiveResults(metrics, visualizations, categoricalData)
            % Comprehensive validation of all results including metrics, visualizations, and data
            %
            % Inputs:
            %   metrics - struct with metric results (iou, dice, accuracy)
            %   visualizations - struct with visualization file paths or image data
            %   categoricalData - struct with categorical data arrays for debugging
            %
            % Output:
            %   report - comprehensive validation report struct
            
            report = struct();
            report.timestamp = datestr(now);
            report.overallValid = true;
            report.warnings = {};
            report.errors = {};
            report.recommendations = {};
            
            fprintf('\n=== COMPREHENSIVE RESULT VALIDATION ===\n');
            fprintf('Timestamp: %s\n', report.timestamp);
            
            % 1. Validate Metrics
            fprintf('\n--- Metrics Validation ---\n');
            if nargin >= 1 && ~isempty(metrics)
                metricsValid = MetricsValidator.validateMetrics(metrics);
                report.metricsValid = metricsValid;
                
                if ~metricsValid
                    report.overallValid = false;
                    report.errors{end+1} = 'Metrics validation failed';
                end
                
                % Check for perfect metrics pattern
                if isfield(metrics, 'iou') && isfield(metrics, 'dice') && isfield(metrics, 'accuracy')
                    perfectWarnings = MetricsValidator.checkPerfectMetrics(...
                        metrics.iou.values, metrics.dice.values, metrics.accuracy.values);
                    
                    if ~isempty(perfectWarnings)
                        report.warnings = [report.warnings, perfectWarnings];
                        report.recommendations{end+1} = 'Check categorical conversion logic in metric calculations';
                    end
                end
                
                % Realistic range validation
                report = MetricsValidator.validateRealisticMetricRanges(metrics, report);
                
            else
                report.warnings{end+1} = 'No metrics provided for validation';
            end
            
            % 2. Validate Visualizations
            fprintf('\n--- Visualization Validation ---\n');
            if nargin >= 2 && ~isempty(visualizations)
                report = MetricsValidator.validateVisualizationQuality(visualizations, report);
            else
                report.warnings{end+1} = 'No visualizations provided for validation';
            end
            
            % 3. Debug Categorical Data
            fprintf('\n--- Categorical Data Debug ---\n');
            if nargin >= 3 && ~isempty(categoricalData)
                report = MetricsValidator.debugCategoricalDataComprehensive(categoricalData, report);
            else
                report.warnings{end+1} = 'No categorical data provided for debugging';
            end
            
            % 4. Generate Summary
            fprintf('\n--- Validation Summary ---\n');
            fprintf('Overall Valid: %s\n', mat2str(report.overallValid));
            fprintf('Total Warnings: %d\n', length(report.warnings));
            fprintf('Total Errors: %d\n', length(report.errors));
            fprintf('Total Recommendations: %d\n', length(report.recommendations));
            
            if ~isempty(report.warnings)
                fprintf('\nWarnings:\n');
                for i = 1:length(report.warnings)
                    fprintf('  %d. %s\n', i, report.warnings{i});
                end
            end
            
            if ~isempty(report.errors)
                fprintf('\nErrors:\n');
                for i = 1:length(report.errors)
                    fprintf('  %d. %s\n', i, report.errors{i});
                end
            end
            
            if ~isempty(report.recommendations)
                fprintf('\nRecommendations:\n');
                for i = 1:length(report.recommendations)
                    fprintf('  %d. %s\n', i, report.recommendations{i});
                end
            end
            
            fprintf('\n=== END VALIDATION REPORT ===\n\n');
        end
        
        function report = validateRealisticMetricRanges(metrics, report)
            % Validate that metrics fall within realistic ranges for segmentation tasks
            %
            % Inputs:
            %   metrics - struct with metric results
            %   report - validation report struct to update
            
            % Define realistic ranges for segmentation metrics
            realisticRanges = struct();
            realisticRanges.iou = [0.3, 0.95];      % IoU typically 30-95% for good segmentation
            realisticRanges.dice = [0.4, 0.97];     % Dice typically 40-97% for good segmentation  
            realisticRanges.accuracy = [0.7, 0.99]; % Accuracy typically 70-99% for segmentation
            
            % Minimum expected standard deviation (too low suggests calculation error)
            minStd = 0.01; % At least 1% variation expected across samples
            
            metricNames = {'iou', 'dice', 'accuracy'};
            
            for i = 1:length(metricNames)
                metricName = metricNames{i};
                
                if ~isfield(metrics, metricName)
                    continue;
                end
                
                metric = metrics.(metricName);
                range = realisticRanges.(metricName);
                
                % Check mean is in realistic range
                if metric.mean < range(1)
                    report.warnings{end+1} = sprintf(...
                        '%s mean (%.3f) is below typical range [%.2f-%.2f] - may indicate poor model performance', ...
                        upper(metricName), metric.mean, range(1), range(2));
                elseif metric.mean > range(2)
                    report.warnings{end+1} = sprintf(...
                        '%s mean (%.3f) is above typical range [%.2f-%.2f] - may indicate calculation error', ...
                        upper(metricName), metric.mean, range(1), range(2));
                end
                
                % Check for suspiciously low standard deviation
                if metric.std < minStd
                    report.warnings{end+1} = sprintf(...
                        '%s standard deviation (%.4f) is suspiciously low - expected variation >%.2f', ...
                        upper(metricName), metric.std, minStd);
                    report.recommendations{end+1} = sprintf(...
                        'Verify %s calculation logic and data diversity', upper(metricName));
                end
                
                % Check for perfect scores (exactly 1.0000)
                if abs(metric.mean - 1.0) < 0.0001
                    report.errors{end+1} = sprintf(...
                        '%s shows perfect score (%.4f) - likely calculation error', ...
                        upper(metricName), metric.mean);
                    report.recommendations{end+1} = sprintf(...
                        'Check categorical to binary conversion in %s calculation', upper(metricName));
                end
            end
        end
        
        function report = validateVisualizationQuality(visualizations, report)
            % Validate visualization image quality and detect common issues
            %
            % Inputs:
            %   visualizations - struct with visualization data or file paths
            %   report - validation report struct to update
            
            if isfield(visualizations, 'comparisonImage')
                img = visualizations.comparisonImage;
                
                % If it's a file path, try to load it
                if ischar(img) || isstring(img)
                    if exist(img, 'file')
                        try
                            img = imread(img);
                            fprintf('Loaded visualization image: %s\n', img);
                        catch ME
                            report.errors{end+1} = sprintf('Failed to load visualization: %s', ME.message);
                            return;
                        end
                    else
                        report.errors{end+1} = sprintf('Visualization file not found: %s', img);
                        return;
                    end
                end
                
                % Validate image data
                if isnumeric(img)
                    % Check image dimensions
                    imgSize = size(img);
                    fprintf('Visualization image size: %s\n', mat2str(imgSize));
                    
                    if length(imgSize) < 2
                        report.errors{end+1} = 'Visualization image has invalid dimensions';
                    elseif min(imgSize(1:2)) < 50
                        report.warnings{end+1} = 'Visualization image is very small - may be hard to interpret';
                    end
                    
                    % Check data range
                    imgMin = min(img(:));
                    imgMax = max(img(:));
                    fprintf('Visualization image range: [%.3f, %.3f]\n', imgMin, imgMax);
                    
                    % Check for valid image data
                    if imgMin == imgMax
                        report.errors{end+1} = 'Visualization image has uniform values - no visual information';
                    elseif imgMin < 0 || (imgMax > 1 && imgMax <= 255)
                        % Likely uint8 format
                        if imgMax > 255
                            report.warnings{end+1} = 'Visualization image values exceed uint8 range';
                        end
                    elseif imgMax > 1
                        report.warnings{end+1} = 'Visualization image has unusual value range';
                    end
                    
                    % Check for NaN or Inf values
                    if any(isnan(img(:)))
                        report.errors{end+1} = 'Visualization image contains NaN values';
                    end
                    if any(isinf(img(:)))
                        report.errors{end+1} = 'Visualization image contains Inf values';
                    end
                    
                else
                    report.errors{end+1} = sprintf('Visualization image has invalid type: %s', class(img));
                end
            end
            
            % Check for other visualization components
            if isfield(visualizations, 'originalImage')
                fprintf('Original image component found\n');
            end
            if isfield(visualizations, 'groundTruth')
                fprintf('Ground truth component found\n');
            end
            if isfield(visualizations, 'predictions')
                fprintf('Predictions component found\n');
            end
        end
        
        function report = debugCategoricalDataComprehensive(categoricalData, report)
            % Comprehensive debugging of categorical data with detailed analysis
            %
            % Inputs:
            %   categoricalData - struct with categorical arrays
            %   report - validation report struct to update
            
            if ~isstruct(categoricalData)
                report.warnings{end+1} = 'Categorical data is not a struct';
                return;
            end
            
            fields = fieldnames(categoricalData);
            fprintf('Found %d categorical data fields: %s\n', length(fields), strjoin(fields, ', '));
            
            for i = 1:length(fields)
                fieldName = fields{i};
                data = categoricalData.(fieldName);
                
                fprintf('\n--- Analyzing %s ---\n', fieldName);
                
                if ~iscategorical(data)
                    report.warnings{end+1} = sprintf('%s is not categorical (type: %s)', fieldName, class(data));
                    continue;
                end
                
                % Detailed analysis
                validated = MetricsValidator.validateCategoricalStructure(data);
                
                % Add warnings to report
                if ~validated.isValid
                    report.warnings{end+1} = sprintf('%s failed categorical validation', fieldName);
                end
                
                for j = 1:length(validated.warnings)
                    report.warnings{end+1} = sprintf('%s: %s', fieldName, validated.warnings{j});
                end
                
                % Print debug information
                MetricsValidator.debugCategoricalData(data, fieldName);
                
                % Check for common conversion issues
                if validated.debugInfo.numCategories == 2
                    % Test different conversion approaches
                    fprintf('Testing conversion approaches for %s:\n', fieldName);
                    
                    % Method 1: double(categorical) > 1
                    method1 = double(data) > 1;
                    fprintf('  Method 1 (double > 1): unique values = %s, sum = %d\n', ...
                        mat2str(unique(method1)), sum(method1(:)));
                    
                    % Method 2: categorical == "foreground"
                    if any(contains(validated.debugInfo.categories, 'foreground', 'IgnoreCase', true))
                        method2 = double(data == "foreground");
                        fprintf('  Method 2 (== "foreground"): unique values = %s, sum = %d\n', ...
                            mat2str(unique(method2)), sum(method2(:)));
                        
                        % Compare methods
                        if ~isequal(method1, method2)
                            report.warnings{end+1} = sprintf(...
                                '%s: Different conversion methods give different results!', fieldName);
                            report.recommendations{end+1} = sprintf(...
                                'Standardize categorical conversion for %s', fieldName);
                        end
                    end
                end
            end
        end
    end
end