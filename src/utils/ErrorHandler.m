classdef ErrorHandler < handle
    % ErrorHandler - Comprehensive error handling and logging system
    % 
    % This class provides centralized error handling, logging, and fallback
    % mechanisms for the categorical data processing pipeline.
    %
    % Features:
    % - Detailed logging for categorical conversions
    % - Warnings for data inconsistencies
    % - Fallback mechanisms for critical operations
    % - Debugging output for troubleshooting
    %
    % Requirements addressed: 3.3, 3.4, 6.1
    
    properties (Constant)
        LOG_LEVEL_DEBUG = 1;
        LOG_LEVEL_INFO = 2;
        LOG_LEVEL_WARNING = 3;
        LOG_LEVEL_ERROR = 4;
        LOG_LEVEL_CRITICAL = 5;
    end
    
    properties (Access = private)
        logLevel = 2; % Default to INFO level
        logFile = '';
        enableConsoleOutput = true;
        logBuffer = {};
    end
    
    methods (Static)
        function instance = getInstance()
            % Singleton pattern for global error handler
            persistent errorHandler;
            if isempty(errorHandler)
                errorHandler = ErrorHandler();
            end
            instance = errorHandler;
        end
    end
    
    methods (Access = private)
        function obj = ErrorHandler()
            % Private constructor for singleton pattern
            obj.logLevel = ErrorHandler.LOG_LEVEL_INFO;
            obj.enableConsoleOutput = true;
            obj.logBuffer = {};
        end
    end
    
    methods
        function setLogLevel(obj, level)
            % Set the minimum log level for output
            % Input: level - integer from 1 (DEBUG) to 5 (CRITICAL)
            if level >= 1 && level <= 5
                obj.logLevel = level;
            else
                obj.logWarning('ErrorHandler', 'Invalid log level. Using INFO level.');
                obj.logLevel = ErrorHandler.LOG_LEVEL_INFO;
            end
        end
        
        function setLogFile(obj, filename)
            % Set log file for persistent logging
            % Input: filename - path to log file
            try
                obj.logFile = filename;
                % Test write access
                fid = fopen(filename, 'a');
                if fid == -1
                    obj.logWarning('ErrorHandler', 'Cannot open log file. Using console only.');
                    obj.logFile = '';
                else
                    fclose(fid);
                    obj.logInfo('ErrorHandler', sprintf('Log file set to: %s', filename));
                end
            catch ME
                obj.logWarning('ErrorHandler', sprintf('Failed to set log file: %s', ME.message));
                obj.logFile = '';
            end
        end
        
        function enableConsole(obj, enable)
            % Enable or disable console output
            % Input: enable - logical
            obj.enableConsoleOutput = enable;
        end
        
        function logDebug(obj, context, message)
            % Log debug message
            obj.writeLog(ErrorHandler.LOG_LEVEL_DEBUG, 'DEBUG', context, message);
        end
        
        function logInfo(obj, context, message)
            % Log info message
            obj.writeLog(ErrorHandler.LOG_LEVEL_INFO, 'INFO', context, message);
        end
        
        function logWarning(obj, context, message)
            % Log warning message
            obj.writeLog(ErrorHandler.LOG_LEVEL_WARNING, 'WARNING', context, message);
        end
        
        function logError(obj, context, message)
            % Log error message
            obj.writeLog(ErrorHandler.LOG_LEVEL_ERROR, 'ERROR', context, message);
        end
        
        function logCritical(obj, context, message)
            % Log critical error message
            obj.writeLog(ErrorHandler.LOG_LEVEL_CRITICAL, 'CRITICAL', context, message);
        end
        
        function logCategoricalConversion(obj, context, inputType, outputType, inputSize, success, details)
            % Specialized logging for categorical conversions
            % Inputs:
            %   context - string describing the operation context
            %   inputType - input data type
            %   outputType - target output type
            %   inputSize - size of input data
            %   success - logical indicating if conversion succeeded
            %   details - struct with additional details (optional)
            
            if nargin < 7
                details = struct();
            end
            
            timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
            
            % Create detailed log message
            message = sprintf('[CATEGORICAL_CONVERSION] %s: %s->%s, size=%s, success=%s', ...
                context, inputType, outputType, mat2str(inputSize), mat2str(success));
            
            % Add details if provided
            if isstruct(details)
                detailFields = fieldnames(details);
                for i = 1:length(detailFields)
                    field = detailFields{i};
                    value = details.(field);
                    if isnumeric(value)
                        message = sprintf('%s, %s=%s', message, field, mat2str(value));
                    elseif ischar(value) || isstring(value)
                        message = sprintf('%s, %s=%s', message, field, value);
                    elseif iscell(value)
                        message = sprintf('%s, %s=[%s]', message, field, strjoin(value, ','));
                    end
                end
            end
            
            % Log at appropriate level
            if success
                obj.logInfo('CategoricalConversion', message);
            else
                obj.logError('CategoricalConversion', message);
            end
            
            % Store in buffer for analysis
            obj.logBuffer{end+1} = struct('timestamp', timestamp, 'context', context, ...
                'inputType', inputType, 'outputType', outputType, 'success', success, ...
                'details', details);
        end
        
        function logDataInconsistency(obj, context, inconsistencyType, description, severity)
            % Log data inconsistency warnings
            % Inputs:
            %   context - string describing where inconsistency was found
            %   inconsistencyType - type of inconsistency ('type_mismatch', 'value_range', etc.)
            %   description - detailed description of the issue
            %   severity - 'low', 'medium', 'high', 'critical'
            
            if nargin < 5
                severity = 'medium';
            end
            
            message = sprintf('[DATA_INCONSISTENCY] %s - %s: %s (severity: %s)', ...
                context, inconsistencyType, description, severity);
            
            % Log at appropriate level based on severity
            switch lower(severity)
                case 'low'
                    obj.logInfo('DataInconsistency', message);
                case 'medium'
                    obj.logWarning('DataInconsistency', message);
                case {'high', 'critical'}
                    obj.logError('DataInconsistency', message);
                otherwise
                    obj.logWarning('DataInconsistency', message);
            end
        end
        
        function result = executeWithFallback(obj, context, primaryFunction, fallbackFunction, varargin)
            % Execute function with fallback mechanism
            % Inputs:
            %   context - string describing the operation
            %   primaryFunction - function handle for primary operation
            %   fallbackFunction - function handle for fallback operation
            %   varargin - arguments to pass to functions
            % Output:
            %   result - result from primary or fallback function
            
            result = [];
            
            try
                % Attempt primary function
                obj.logDebug(context, 'Attempting primary operation');
                result = primaryFunction(varargin{:});
                obj.logInfo(context, 'Primary operation succeeded');
                
            catch primaryError
                obj.logWarning(context, sprintf('Primary operation failed: %s', primaryError.message));
                
                try
                    % Attempt fallback function
                    obj.logDebug(context, 'Attempting fallback operation');
                    result = fallbackFunction(varargin{:});
                    obj.logWarning(context, 'Fallback operation succeeded - results may be suboptimal');
                    
                catch fallbackError
                    obj.logError(context, sprintf('Fallback operation also failed: %s', fallbackError.message));
                    obj.logCritical(context, 'Both primary and fallback operations failed');
                    
                    % Re-throw the original error
                    rethrow(primaryError);
                end
            end
        end
        
        function debugCategoricalIssue(obj, context, data, expectedType, actualResult)
            % Comprehensive debugging output for categorical issues
            % Inputs:
            %   context - string describing the operation context
            %   data - the categorical data causing issues
            %   expectedType - expected output type
            %   actualResult - actual result obtained (optional)
            
            obj.logDebug(context, '=== CATEGORICAL DEBUG SESSION START ===');
            
            try
                % Basic data information
                if iscategorical(data)
                    cats = categories(data);
                    obj.logDebug(context, sprintf('Data type: categorical, size: %s', mat2str(size(data))));
                    obj.logDebug(context, sprintf('Categories: [%s]', strjoin(cats, ', ')));
                    obj.logDebug(context, sprintf('Number of categories: %d', length(cats)));
                    
                    % Category distribution
                    for i = 1:length(cats)
                        count = sum(data == cats{i});
                        percentage = count / numel(data) * 100;
                        obj.logDebug(context, sprintf('  %s: %d instances (%.1f%%)', cats{i}, count, percentage));
                    end
                    
                    % Double conversion analysis
                    doubleData = double(data);
                    uniqueDoubleVals = unique(doubleData);
                    obj.logDebug(context, sprintf('double(data) range: [%.3f, %.3f]', min(doubleData(:)), max(doubleData(:))));
                    obj.logDebug(context, sprintf('double(data) unique values: %s', mat2str(uniqueDoubleVals)));
                    
                    % Test common conversion patterns
                    if length(cats) == 2
                        obj.logDebug(context, 'Testing binary conversion patterns:');
                        
                        % Pattern 1: double(data) > 1
                        pattern1 = double(data) > 1;
                        obj.logDebug(context, sprintf('  (double(data) > 1): sum=%d, unique=%s', ...
                            sum(pattern1(:)), mat2str(unique(pattern1))));
                        
                        % Pattern 2: data == "foreground"
                        if any(contains(cats, 'foreground', 'IgnoreCase', true))
                            pattern2 = data == "foreground";
                            obj.logDebug(context, sprintf('  (data == "foreground"): sum=%d, unique=%s', ...
                                sum(pattern2(:)), mat2str(unique(double(pattern2)))));
                            
                            % Compare patterns
                            if ~isequal(pattern1, pattern2)
                                obj.logDataInconsistency(context, 'conversion_mismatch', ...
                                    'Different categorical conversion methods give different results', 'high');
                            end
                        end
                        
                        % Pattern 3: data == cats{2}
                        pattern3 = data == cats{2};
                        obj.logDebug(context, sprintf('  (data == "%s"): sum=%d, unique=%s', ...
                            cats{2}, sum(pattern3(:)), mat2str(unique(double(pattern3)))));
                    end
                    
                else
                    obj.logDebug(context, sprintf('Data type: %s (not categorical)', class(data)));
                    if isnumeric(data)
                        obj.logDebug(context, sprintf('Value range: [%.3f, %.3f]', min(data(:)), max(data(:))));
                        obj.logDebug(context, sprintf('Unique values: %s', mat2str(unique(data(:)))));
                    end
                end
                
                % Expected vs actual analysis
                if nargin >= 4
                    obj.logDebug(context, sprintf('Expected output type: %s', expectedType));
                    
                    if nargin >= 5 && ~isempty(actualResult)
                        obj.logDebug(context, sprintf('Actual result type: %s', class(actualResult)));
                        if isnumeric(actualResult)
                            obj.logDebug(context, sprintf('Actual result range: [%.3f, %.3f]', ...
                                min(actualResult(:)), max(actualResult(:))));
                        end
                    end
                end
                
            catch debugError
                obj.logError(context, sprintf('Error during categorical debugging: %s', debugError.message));
            end
            
            obj.logDebug(context, '=== CATEGORICAL DEBUG SESSION END ===');
        end
        
        function report = generateDiagnosticReport(obj)
            % Generate comprehensive diagnostic report
            % Output: report - struct with diagnostic information
            
            report = struct();
            report.timestamp = datestr(now);
            report.logLevel = obj.logLevel;
            report.totalLogEntries = length(obj.logBuffer);
            
            % Analyze conversion patterns
            conversionEntries = obj.logBuffer;
            if ~isempty(conversionEntries)
                % Extract success values from cell array of structs
                successValues = false(1, length(conversionEntries));
                inputTypes = cell(1, length(conversionEntries));
                outputTypes = cell(1, length(conversionEntries));
                
                for i = 1:length(conversionEntries)
                    if isstruct(conversionEntries{i}) && isfield(conversionEntries{i}, 'success')
                        successValues(i) = conversionEntries{i}.success;
                        inputTypes{i} = conversionEntries{i}.inputType;
                        outputTypes{i} = conversionEntries{i}.outputType;
                    end
                end
                
                successRate = sum(successValues) / length(successValues);
                report.conversionSuccessRate = successRate;
                
                % Most common input/output type combinations
                [uniqueInputs, ~, inputIdx] = unique(inputTypes);
                [uniqueOutputs, ~, outputIdx] = unique(outputTypes);
                
                report.commonInputTypes = uniqueInputs;
                report.commonOutputTypes = uniqueOutputs;
                
                % Failed conversions analysis
                failedCount = sum(~successValues);
                report.failedConversions = failedCount;
                report.failureRate = failedCount / length(successValues);
            else
                report.conversionSuccessRate = NaN;
                report.failedConversions = 0;
                report.failureRate = 0;
            end
            
            % Generate recommendations
            report.recommendations = obj.generateRecommendations(report);
            
            obj.logInfo('DiagnosticReport', sprintf('Generated diagnostic report: %.1f%% success rate, %d failed conversions', ...
                report.conversionSuccessRate * 100, report.failedConversions));
        end
        
        function clearLogBuffer(obj)
            % Clear the internal log buffer
            obj.logBuffer = {};
            obj.logInfo('ErrorHandler', 'Log buffer cleared');
        end
        
        function exportLogs(obj, filename)
            % Export logs to file
            % Input: filename - path to export file
            
            try
                fid = fopen(filename, 'w');
                if fid == -1
                    obj.logError('ErrorHandler', sprintf('Cannot open export file: %s', filename));
                    return;
                end
                
                fprintf(fid, 'Categorical Processing Log Export\n');
                fprintf(fid, 'Generated: %s\n', datestr(now));
                fprintf(fid, 'Total entries: %d\n\n', length(obj.logBuffer));
                
                for i = 1:length(obj.logBuffer)
                    entry = obj.logBuffer{i};
                    fprintf(fid, '[%s] %s: %s->%s (success: %s)\n', ...
                        entry.timestamp, entry.context, entry.inputType, ...
                        entry.outputType, mat2str(entry.success));
                    
                    if isstruct(entry.details) && ~isempty(fieldnames(entry.details))
                        fprintf(fid, '  Details: ');
                        fields = fieldnames(entry.details);
                        for j = 1:length(fields)
                            value = entry.details.(fields{j});
                            if isnumeric(value)
                                fprintf(fid, '%s=%s ', fields{j}, mat2str(value));
                            elseif ischar(value) || isstring(value)
                                fprintf(fid, '%s=%s ', fields{j}, char(value));
                            elseif iscell(value)
                                fprintf(fid, '%s=[%s] ', fields{j}, strjoin(value, ','));
                            else
                                fprintf(fid, '%s=<complex> ', fields{j});
                            end
                        end
                        fprintf(fid, '\n');
                    end
                end
                
                fclose(fid);
                obj.logInfo('ErrorHandler', sprintf('Logs exported to: %s', filename));
                
            catch ME
                obj.logError('ErrorHandler', sprintf('Failed to export logs: %s', ME.message));
            end
        end
    end
    
    methods (Access = private)
        function writeLog(obj, level, levelStr, context, message)
            % Internal method to write log messages
            if level < obj.logLevel
                return; % Skip if below minimum log level
            end
            
            timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
            logMessage = sprintf('[%s] %s [%s]: %s', timestamp, levelStr, context, message);
            
            % Console output
            if obj.enableConsoleOutput
                if level >= ErrorHandler.LOG_LEVEL_ERROR
                    fprintf(2, '%s\n', logMessage); % stderr for errors
                else
                    fprintf('%s\n', logMessage); % stdout for info/debug
                end
            end
            
            % File output
            if ~isempty(obj.logFile)
                try
                    fid = fopen(obj.logFile, 'a');
                    if fid ~= -1
                        fprintf(fid, '%s\n', logMessage);
                        fclose(fid);
                    end
                catch
                    % Silently fail file logging to avoid infinite recursion
                end
            end
        end
        
        function recommendations = generateRecommendations(obj, report)
            % Generate recommendations based on diagnostic report
            recommendations = {};
            
            if report.failureRate > 0.1 % More than 10% failure rate
                recommendations{end+1} = 'High conversion failure rate detected. Review categorical data structure consistency.';
            end
            
            if report.conversionSuccessRate < 0.9 && report.totalLogEntries > 10
                recommendations{end+1} = 'Consider standardizing categorical creation across all functions.';
            end
            
            if isfield(report, 'commonInputTypes') && length(report.commonInputTypes) > 3
                recommendations{end+1} = 'Multiple input types detected. Consider data type validation at entry points.';
            end
            
            if report.failedConversions > 0
                recommendations{end+1} = 'Implement additional fallback mechanisms for failed conversions.';
            end
            
            if isempty(recommendations)
                recommendations{end+1} = 'System appears to be functioning normally. Continue monitoring.';
            end
        end
    end
end