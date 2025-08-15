classdef ResultsOrganizer < handle
    % RESULTSORGANIZER Automatic organization of segmentation results
    % 
    % This class provides comprehensive organization of segmentation results
    % into structured directories with consistent naming and metadata.
    
    properties
        baseOutputDir = 'output'
        namingConvention = 'timestamp_metrics'
        compressionEnabled = true
        sessionMetadata = struct()
    end
    
    methods
        function obj = ResultsOrganizer(config)
            % Constructor with optional configuration
            if nargin > 0 && isstruct(config)
                if isfield(config, 'baseOutputDir')
                    obj.baseOutputDir = config.baseOutputDir;
                end
                if isfield(config, 'namingConvention')
                    obj.namingConvention = config.namingConvention;
                end
                if isfield(config, 'compressionEnabled')
                    obj.compressionEnabled = config.compressionEnabled;
                end
            end
            
            % Ensure base directory exists
            if ~exist(obj.baseOutputDir, 'dir')
                mkdir(obj.baseOutputDir);
            end
        end
        
        function sessionId = organizeResults(obj, unetResults, attentionResults, config)
            % Organize results from a comparison session
            % 
            % Inputs:
            %   unetResults - struct array with U-Net segmentation results
            %   attentionResults - struct array with Attention U-Net results  
            %   config - configuration struct with training parameters
            %
            % Output:
            %   sessionId - unique identifier for this session
            
            % Generate unique session ID
            sessionId = obj.generateSessionId();
            
            % Create directory structure
            sessionDir = obj.createDirectoryStructure(sessionId);
            
            % Store session metadata
            obj.sessionMetadata.(sessionId) = struct(...
                'timestamp', now, ...
                'sessionDir', sessionDir, ...
                'config', config, ...
                'unetCount', length(unetResults), ...
                'attentionCount', length(attentionResults) ...
            );
            
            % Organize U-Net results
            obj.organizeModelResults(unetResults, sessionDir, 'unet');
            
            % Organize Attention U-Net results  
            obj.organizeModelResults(attentionResults, sessionDir, 'attention_unet');
            
            % Create comparison visualizations
            obj.createComparisons(unetResults, attentionResults, sessionDir);
            
            % Save session metadata
            obj.saveSessionMetadata(sessionId, sessionDir);
            
            fprintf('Results organized in session: %s\n', sessionId);
        end       
 
        function sessionDir = createDirectoryStructure(obj, sessionId)
            % Create hierarchical directory structure for session
            
            sessionDir = fullfile(obj.baseOutputDir, 'sessions', sessionId);
            
            % Create main directories
            dirs = {
                sessionDir,
                fullfile(sessionDir, 'models'),
                fullfile(sessionDir, 'segmentations', 'unet'),
                fullfile(sessionDir, 'segmentations', 'attention_unet'),
                fullfile(sessionDir, 'comparisons'),
                fullfile(sessionDir, 'statistics'),
                fullfile(sessionDir, 'metadata')
            };
            
            for i = 1:length(dirs)
                if ~exist(dirs{i}, 'dir')
                    mkdir(dirs{i});
                end
            end
        end
        
        function organizeModelResults(obj, results, sessionDir, modelType)
            % Organize results for a specific model type
            
            segmentationDir = fullfile(sessionDir, 'segmentations', modelType);
            
            for i = 1:length(results)
                result = results(i);
                
                % Generate consistent filename
                filename = obj.generateResultFilename(result, i);
                
                % Copy segmentation image
                destPath = '';
                if isfield(result, 'segmentationPath') && exist(result.segmentationPath, 'file')
                    [~, ~, ext] = fileparts(result.segmentationPath);
                    destPath = fullfile(segmentationDir, [filename ext]);
                    copyfile(result.segmentationPath, destPath);
                end
                
                % Save metrics as JSON
                metricsPath = fullfile(segmentationDir, [filename '_metrics.json']);
                obj.saveMetricsAsJSON(result.metrics, metricsPath);
                
                % Update result with new paths
                results(i).organizedPath = destPath;
                results(i).metricsPath = metricsPath;
            end
        end
        
        function createComparisons(obj, unetResults, attentionResults, sessionDir)
            % Create side-by-side comparison visualizations
            
            comparisonDir = fullfile(sessionDir, 'comparisons');
            
            % Ensure we have matching results
            minCount = min(length(unetResults), length(attentionResults));
            
            for i = 1:minCount
                try
                    % Generate comparison filename
                    compFilename = sprintf('comparison_%03d.png', i);
                    compPath = fullfile(comparisonDir, compFilename);
                    
                    % Create side-by-side comparison (placeholder implementation)
                    obj.createSideBySideComparison(unetResults(i), attentionResults(i), compPath);
                    
                catch ME
                    warning('Failed to create comparison %d: %s', i, ME.message);
                end
            end
        end 
       
        function generateHTMLIndex(obj, sessionId)
            % Generate navigable HTML index for session results
            
            if ~isfield(obj.sessionMetadata, sessionId)
                error('Session %s not found', sessionId);
            end
            
            sessionData = obj.sessionMetadata.(sessionId);
            sessionDir = sessionData.sessionDir;
            
            % HTML content
            htmlContent = obj.buildHTMLContent(sessionId, sessionData);
            
            % Write HTML file
            htmlPath = fullfile(sessionDir, 'index.html');
            fid = fopen(htmlPath, 'w');
            if fid == -1
                error('Could not create HTML file: %s', htmlPath);
            end
            
            fprintf(fid, '%s', htmlContent);
            fclose(fid);
            
            fprintf('HTML index created: %s\n', htmlPath);
        end
        
        function exportMetadata(obj, sessionId, format)
            % Export session metadata in specified format
            
            if ~isfield(obj.sessionMetadata, sessionId)
                error('Session %s not found', sessionId);
            end
            
            sessionData = obj.sessionMetadata.(sessionId);
            sessionDir = sessionData.sessionDir;
            metadataDir = fullfile(sessionDir, 'metadata');
            
            switch lower(format)
                case 'json'
                    obj.exportAsJSON(sessionData, metadataDir);
                case 'csv'
                    obj.exportAsCSV(sessionData, metadataDir);
                otherwise
                    error('Unsupported format: %s', format);
            end
        end
        
        function compressOldResults(obj, daysOld)
            % Compress results older than specified days
            
            if nargin < 2
                daysOld = 30; % Default to 30 days
            end
            
            sessionsDir = fullfile(obj.baseOutputDir, 'sessions');
            if ~exist(sessionsDir, 'dir')
                return;
            end
            
            % Find old sessions
            sessionDirs = dir(sessionsDir);
            sessionDirs = sessionDirs([sessionDirs.isdir] & ~ismember({sessionDirs.name}, {'.', '..'}));
            
            cutoffDate = datetime('now') - days(daysOld);
            
            for i = 1:length(sessionDirs)
                sessionPath = fullfile(sessionsDir, sessionDirs(i).name);
                
                % Check if session is old enough
                if sessionDirs(i).datenum < datenum(cutoffDate)
                    obj.compressSession(sessionPath);
                end
            end
        end   
 end
    
    methods (Access = private)
        function sessionId = generateSessionId(obj)
            % Generate unique session identifier
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            sessionId = sprintf('session_%s', timestamp);
        end
        
        function filename = generateResultFilename(obj, result, index)
            % Generate consistent filename for result
            
            switch obj.namingConvention
                case 'timestamp_metrics'
                    if isfield(result, 'metrics') && isfield(result.metrics, 'iou')
                        iou_str = sprintf('iou%.3f', result.metrics.iou);
                        filename = sprintf('img_%03d_%s_%s', index, datestr(now, 'HHMMSS'), iou_str);
                    else
                        filename = sprintf('img_%03d_%s', index, datestr(now, 'HHMMSS'));
                    end
                case 'simple'
                    filename = sprintf('img_%03d', index);
                otherwise
                    filename = sprintf('result_%03d', index);
            end
        end
        
        function saveMetricsAsJSON(obj, metrics, filepath)
            % Save metrics structure as JSON file
            
            try
                % Convert metrics to JSON-compatible format
                jsonStr = obj.structToJSON(metrics);
                
                % Write to file
                fid = fopen(filepath, 'w');
                if fid ~= -1
                    fprintf(fid, '%s', jsonStr);
                    fclose(fid);
                end
            catch ME
                warning('Failed to save metrics as JSON: %s', ME.message);
            end
        end
        
        function jsonStr = structToJSON(obj, s)
            % Simple struct to JSON conversion (Octave compatible)
            
            if isstruct(s)
                fields = fieldnames(s);
                jsonParts = cell(length(fields), 1);
                
                for i = 1:length(fields)
                    field = fields{i};
                    value = s.(field);
                    
                    if isnumeric(value) && isscalar(value)
                        jsonParts{i} = sprintf('"%s": %.6f', field, value);
                    elseif ischar(value)
                        jsonParts{i} = sprintf('"%s": "%s"', field, value);
                    elseif isstruct(value)
                        jsonParts{i} = sprintf('"%s": "struct"', field);
                    else
                        try
                            jsonParts{i} = sprintf('"%s": "%s"', field, num2str(value));
                        catch
                            jsonParts{i} = sprintf('"%s": "complex_data"', field);
                        end
                    end
                end
                
                % Use simple string concatenation instead of strjoin for Octave compatibility
                jsonStr = '{\n';
                for i = 1:length(jsonParts)
                    jsonStr = [jsonStr '  ' jsonParts{i}];
                    if i < length(jsonParts)
                        jsonStr = [jsonStr ','];
                    end
                    jsonStr = [jsonStr '\n'];
                end
                jsonStr = [jsonStr '}'];
            else
                jsonStr = '{}';
            end
        end   
     
        function createSideBySideComparison(obj, unetResult, attentionResult, outputPath)
            % Create side-by-side comparison visualization (placeholder)
            
            try
                % This is a placeholder implementation
                % In a full implementation, this would create actual image comparisons
                
                % Create a simple text file indicating comparison was attempted
                [outputDir, ~, ~] = fileparts(outputPath);
                textPath = fullfile(outputDir, 'comparison_info.txt');
                
                fid = fopen(textPath, 'a');
                if fid ~= -1
                    fprintf(fid, 'Comparison created for U-Net vs Attention U-Net\n');
                    fprintf(fid, 'U-Net IoU: %.4f, Attention IoU: %.4f\n', ...
                        unetResult.metrics.iou, attentionResult.metrics.iou);
                    fclose(fid);
                end
                
            catch ME
                warning('Failed to create comparison: %s', ME.message);
            end
        end
        
        function saveSessionMetadata(obj, sessionId, sessionDir)
            % Save session metadata to file
            
            metadataPath = fullfile(sessionDir, 'metadata', 'session_info.mat');
            sessionData = obj.sessionMetadata.(sessionId);
            
            try
                save(metadataPath, 'sessionData');
            catch ME
                warning('Failed to save session metadata: %s', ME.message);
            end
        end
        
        function htmlContent = buildHTMLContent(obj, sessionId, sessionData)
            % Build HTML content for session index
            
            htmlContent = sprintf(['<!DOCTYPE html>\n' ...
                '<html>\n<head>\n' ...
                '<title>Segmentation Results - %s</title>\n' ...
                '<style>\n' ...
                'body { font-family: Arial, sans-serif; margin: 20px; }\n' ...
                '.header { background-color: #f0f0f0; padding: 10px; border-radius: 5px; }\n' ...
                '.section { margin: 20px 0; }\n' ...
                '.metrics { background-color: #e8f4f8; padding: 10px; border-radius: 5px; }\n' ...
                '</style>\n</head>\n<body>\n'], sessionId);
            
            % Header
            htmlContent = [htmlContent sprintf(['<div class="header">\n' ...
                '<h1>Segmentation Results</h1>\n' ...
                '<p>Session: %s</p>\n' ...
                '<p>Generated: %s</p>\n' ...
                '</div>\n'], sessionId, datestr(sessionData.timestamp))];
            
            % Summary
            htmlContent = [htmlContent sprintf(['<div class="section">\n' ...
                '<h2>Summary</h2>\n' ...
                '<div class="metrics">\n' ...
                '<p>U-Net Results: %d images</p>\n' ...
                '<p>Attention U-Net Results: %d images</p>\n' ...
                '</div>\n</div>\n'], sessionData.unetCount, sessionData.attentionCount)];
            
            % Directory structure
            htmlContent = [htmlContent '<div class="section">\n<h2>Directory Structure</h2>\n<ul>\n'];
            htmlContent = [htmlContent '<li><a href="segmentations/unet/">U-Net Segmentations</a></li>\n'];
            htmlContent = [htmlContent '<li><a href="segmentations/attention_unet/">Attention U-Net Segmentations</a></li>\n'];
            htmlContent = [htmlContent '<li><a href="comparisons/">Comparisons</a></li>\n'];
            htmlContent = [htmlContent '<li><a href="statistics/">Statistics</a></li>\n'];
            htmlContent = [htmlContent '</ul>\n</div>\n'];
            
            htmlContent = [htmlContent '</body>\n</html>'];
        end 
       
        function exportAsJSON(obj, sessionData, metadataDir)
            % Export session data as JSON
            
            jsonPath = fullfile(metadataDir, 'session_summary.json');
            
            % Create summary structure
            summary = struct();
            summary.sessionId = sessionData.sessionDir;
            summary.timestamp = datestr(sessionData.timestamp);
            summary.unetCount = sessionData.unetCount;
            summary.attentionCount = sessionData.attentionCount;
            
            if isfield(sessionData, 'config')
                summary.config = sessionData.config;
            end
            
            % Convert to JSON and save
            jsonStr = obj.structToJSON(summary);
            
            fid = fopen(jsonPath, 'w');
            if fid ~= -1
                fprintf(fid, '%s', jsonStr);
                fclose(fid);
                fprintf('JSON metadata exported: %s\n', jsonPath);
            end
        end
        
        function exportAsCSV(obj, sessionData, metadataDir)
            % Export session data as CSV
            
            csvPath = fullfile(metadataDir, 'session_summary.csv');
            
            fid = fopen(csvPath, 'w');
            if fid ~= -1
                % Write header
                fprintf(fid, 'Field,Value\n');
                
                % Write data
                fprintf(fid, 'SessionId,%s\n', sessionData.sessionDir);
                fprintf(fid, 'Timestamp,%s\n', datestr(sessionData.timestamp));
                fprintf(fid, 'UNetCount,%d\n', sessionData.unetCount);
                fprintf(fid, 'AttentionCount,%d\n', sessionData.attentionCount);
                
                fclose(fid);
                fprintf('CSV metadata exported: %s\n', csvPath);
            end
        end
        
        function compressSession(obj, sessionPath)
            % Compress a session directory (placeholder implementation)
            
            try
                % Create compressed archive name
                [parentDir, sessionName, ~] = fileparts(sessionPath);
                archivePath = fullfile(parentDir, [sessionName '.zip']);
                
                % Simple compression using zip (if available)
                if exist('zip', 'file') == 2
                    zip(archivePath, sessionPath);
                    
                    % Remove original directory after successful compression
                    if exist(archivePath, 'file')
                        rmdir(sessionPath, 's');
                        fprintf('Compressed session: %s\n', archivePath);
                    end
                else
                    fprintf('Compression not available for session: %s\n', sessionName);
                end
                
            catch ME
                warning('Failed to compress session %s: %s', sessionPath, ME.message);
            end
        end
    end
end