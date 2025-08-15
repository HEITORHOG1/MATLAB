classdef FileManager < handle
    % FILEMANAGER Utilities for file management, compression, and cleanup
    % 
    % This class provides comprehensive file management capabilities including
    % automatic compression, cleanup of old files, and disk space management.
    
    properties (Constant)
        DEFAULT_COMPRESSION_DAYS = 30
        DEFAULT_CLEANUP_DAYS = 90
        MIN_FREE_SPACE_GB = 1
    end
    
    properties
        baseDirectory = 'output'
        compressionEnabled = true
        cleanupEnabled = true
        logFile = ''
    end
    
    methods
        function obj = FileManager(config)
            % Constructor with optional configuration
            
            if nargin > 0 && isstruct(config)
                if isfield(config, 'baseDirectory')
                    obj.baseDirectory = config.baseDirectory;
                end
                if isfield(config, 'compressionEnabled')
                    obj.compressionEnabled = config.compressionEnabled;
                end
                if isfield(config, 'cleanupEnabled')
                    obj.cleanupEnabled = config.cleanupEnabled;
                end
            end
            
            % Setup log file
            obj.logFile = fullfile(obj.baseDirectory, 'file_management.log');
        end
        
        function success = compressOldFiles(obj, daysOld)
            % Compress files older than specified days
            
            if nargin < 2
                daysOld = obj.DEFAULT_COMPRESSION_DAYS;
            end
            
            success = false;
            
            try
                obj.logMessage(sprintf('Starting compression of files older than %d days', daysOld));
                
                % Find directories to compress
                sessionsDir = fullfile(obj.baseDirectory, 'sessions');
                if ~exist(sessionsDir, 'dir')
                    obj.logMessage('No sessions directory found');
                    return;
                end
                
                % Get list of session directories
                sessionDirs = obj.getOldDirectories(sessionsDir, daysOld);
                
                compressedCount = 0;
                for i = 1:length(sessionDirs)
                    if obj.compressDirectory(sessionDirs{i})
                        compressedCount = compressedCount + 1;
                    end
                end
                
                obj.logMessage(sprintf('Compressed %d directories', compressedCount));
                success = true;
                
            catch ME
                obj.logMessage(sprintf('Compression failed: %s', ME.message));
            end
        end  
      
        function success = cleanupOldFiles(obj, daysOld)
            % Remove compressed files older than specified days
            
            if nargin < 2
                daysOld = obj.DEFAULT_CLEANUP_DAYS;
            end
            
            success = false;
            
            try
                obj.logMessage(sprintf('Starting cleanup of files older than %d days', daysOld));
                
                % Find compressed files to remove
                compressedFiles = obj.getOldCompressedFiles(daysOld);
                
                removedCount = 0;
                for i = 1:length(compressedFiles)
                    if obj.removeFile(compressedFiles{i})
                        removedCount = removedCount + 1;
                    end
                end
                
                obj.logMessage(sprintf('Removed %d old compressed files', removedCount));
                success = true;
                
            catch ME
                obj.logMessage(sprintf('Cleanup failed: %s', ME.message));
            end
        end
        
        function freeSpaceGB = checkDiskSpace(obj)
            % Check available disk space in GB
            
            try
                % Get disk space information
                if ispc
                    [status, result] = system(['dir /-c "' obj.baseDirectory '"']);
                    if status == 0
                        % Parse Windows dir output (simplified)
                        freeSpaceGB = 1; % Placeholder
                    else
                        freeSpaceGB = 1;
                    end
                else
                    [status, result] = system(['df -BG "' obj.baseDirectory '"']);
                    if status == 0
                        % Parse Unix df output (simplified)
                        lines = strsplit(result, '\n');
                        if length(lines) >= 2
                            parts = strsplit(strtrim(lines{2}));
                            if length(parts) >= 4
                                freeSpaceStr = parts{4};
                                freeSpaceGB = str2double(regexprep(freeSpaceStr, '[^0-9.]', ''));
                            else
                                freeSpaceGB = 1;
                            end
                        else
                            freeSpaceGB = 1;
                        end
                    else
                        freeSpaceGB = 1;
                    end
                end
                
            catch ME
                obj.logMessage(sprintf('Failed to check disk space: %s', ME.message));
                freeSpaceGB = 1; % Conservative estimate
            end
        end
        
        function success = ensureFreeSpace(obj, requiredGB)
            % Ensure minimum free space by cleaning up if necessary
            
            if nargin < 2
                requiredGB = obj.MIN_FREE_SPACE_GB;
            end
            
            success = false;
            
            try
                currentFreeSpace = obj.checkDiskSpace();
                
                if currentFreeSpace >= requiredGB
                    success = true;
                    return;
                end
                
                obj.logMessage(sprintf('Low disk space: %.2f GB available, %.2f GB required', ...
                    currentFreeSpace, requiredGB));
                
                % Try compression first
                if obj.compressionEnabled
                    obj.compressOldFiles(obj.DEFAULT_COMPRESSION_DAYS / 2); % More aggressive
                end
                
                % Check space again
                currentFreeSpace = obj.checkDiskSpace();
                if currentFreeSpace >= requiredGB
                    success = true;
                    return;
                end
                
                % Try cleanup if still not enough space
                if obj.cleanupEnabled
                    obj.cleanupOldFiles(obj.DEFAULT_CLEANUP_DAYS / 2); % More aggressive
                end
                
                % Final check
                currentFreeSpace = obj.checkDiskSpace();
                success = (currentFreeSpace >= requiredGB);
                
            catch ME
                obj.logMessage(sprintf('Failed to ensure free space: %s', ME.message));
            end
        end        

        function report = generateSpaceReport(obj)
            % Generate comprehensive disk space usage report
            
            report = struct();
            
            try
                % Basic space information
                report.totalFreeSpace = obj.checkDiskSpace();
                report.baseDirectory = obj.baseDirectory;
                report.timestamp = datetime('now');
                
                % Count sessions and their sizes
                sessionsDir = fullfile(obj.baseDirectory, 'sessions');
                if exist(sessionsDir, 'dir')
                    [sessionCount, totalSize] = obj.countDirectoryContents(sessionsDir);
                    report.sessionCount = sessionCount;
                    report.totalSizeMB = totalSize;
                else
                    report.sessionCount = 0;
                    report.totalSizeMB = 0;
                end
                
                % Count compressed files
                compressedFiles = obj.findCompressedFiles();
                report.compressedCount = length(compressedFiles);
                
                % Recommendations
                report.recommendations = obj.generateRecommendations(report);
                
            catch ME
                obj.logMessage(sprintf('Failed to generate space report: %s', ME.message));
                report.error = ME.message;
            end
        end
    end
    
    methods (Access = private)
        function logMessage(obj, message)
            % Log message to file and console
            
            timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
            logEntry = sprintf('[%s] %s\n', timestamp, message);
            
            % Print to console
            fprintf('%s', logEntry);
            
            % Write to log file
            try
                fid = fopen(obj.logFile, 'a');
                if fid ~= -1
                    fprintf(fid, '%s', logEntry);
                    fclose(fid);
                end
            catch
                % Ignore log file errors
            end
        end
        
        function oldDirs = getOldDirectories(obj, parentDir, daysOld)
            % Get list of directories older than specified days
            
            oldDirs = {};
            
            try
                dirInfo = dir(parentDir);
                dirInfo = dirInfo([dirInfo.isdir] & ~ismember({dirInfo.name}, {'.', '..'}));
                
                cutoffDate = now - daysOld;
                
                for i = 1:length(dirInfo)
                    if dirInfo(i).datenum < cutoffDate
                        oldDirs{end+1} = fullfile(parentDir, dirInfo(i).name);
                    end
                end
                
            catch ME
                obj.logMessage(sprintf('Failed to get old directories: %s', ME.message));
            end
        end
        
        function success = compressDirectory(obj, dirPath)
            % Compress a single directory
            
            success = false;
            
            try
                [parentDir, dirName, ~] = fileparts(dirPath);
                archivePath = fullfile(parentDir, [dirName '.zip']);
                
                % Skip if already compressed
                if exist(archivePath, 'file')
                    return;
                end
                
                % Compress using zip if available
                if exist('zip', 'file') == 2
                    zip(archivePath, dirPath);
                    
                    % Verify compression was successful
                    if exist(archivePath, 'file')
                        % Remove original directory
                        rmdir(dirPath, 's');
                        obj.logMessage(sprintf('Compressed: %s', dirName));
                        success = true;
                    end
                else
                    obj.logMessage('ZIP compression not available');
                end
                
            catch ME
                obj.logMessage(sprintf('Failed to compress %s: %s', dirPath, ME.message));
            end
        end   
     
        function compressedFiles = getOldCompressedFiles(obj, daysOld)
            % Get list of compressed files older than specified days
            
            compressedFiles = {};
            
            try
                sessionsDir = fullfile(obj.baseDirectory, 'sessions');
                if ~exist(sessionsDir, 'dir')
                    return;
                end
                
                zipFiles = dir(fullfile(sessionsDir, '*.zip'));
                cutoffDate = now - daysOld;
                
                for i = 1:length(zipFiles)
                    if zipFiles(i).datenum < cutoffDate
                        compressedFiles{end+1} = fullfile(sessionsDir, zipFiles(i).name);
                    end
                end
                
            catch ME
                obj.logMessage(sprintf('Failed to get old compressed files: %s', ME.message));
            end
        end
        
        function success = removeFile(obj, filePath)
            % Safely remove a file
            
            success = false;
            
            try
                if exist(filePath, 'file')
                    delete(filePath);
                    [~, fileName, ~] = fileparts(filePath);
                    obj.logMessage(sprintf('Removed: %s', fileName));
                    success = true;
                end
                
            catch ME
                obj.logMessage(sprintf('Failed to remove %s: %s', filePath, ME.message));
            end
        end
        
        function [count, sizeMB] = countDirectoryContents(obj, dirPath)
            % Count directories and calculate total size
            
            count = 0;
            sizeMB = 0;
            
            try
                if ~exist(dirPath, 'dir')
                    return;
                end
                
                dirInfo = dir(dirPath);
                dirInfo = dirInfo([dirInfo.isdir] & ~ismember({dirInfo.name}, {'.', '..'}));
                count = length(dirInfo);
                
                % Calculate approximate size (simplified)
                for i = 1:length(dirInfo)
                    subDir = fullfile(dirPath, dirInfo(i).name);
                    subDirInfo = dir(fullfile(subDir, '**', '*'));
                    subDirInfo = subDirInfo(~[subDirInfo.isdir]);
                    
                    for j = 1:length(subDirInfo)
                        sizeMB = sizeMB + subDirInfo(j).bytes / (1024 * 1024);
                    end
                end
                
            catch ME
                obj.logMessage(sprintf('Failed to count directory contents: %s', ME.message));
            end
        end
        
        function compressedFiles = findCompressedFiles(obj)
            % Find all compressed files in the base directory
            
            compressedFiles = {};
            
            try
                sessionsDir = fullfile(obj.baseDirectory, 'sessions');
                if exist(sessionsDir, 'dir')
                    zipFiles = dir(fullfile(sessionsDir, '*.zip'));
                    for i = 1:length(zipFiles)
                        compressedFiles{end+1} = fullfile(sessionsDir, zipFiles(i).name);
                    end
                end
                
            catch ME
                obj.logMessage(sprintf('Failed to find compressed files: %s', ME.message));
            end
        end
        
        function recommendations = generateRecommendations(obj, report)
            % Generate space management recommendations
            
            recommendations = {};
            
            try
                % Check if compression is needed
                if report.sessionCount > 10 && obj.compressionEnabled
                    recommendations{end+1} = 'Consider compressing old sessions to save space';
                end
                
                % Check if cleanup is needed
                if report.compressedCount > 20 && obj.cleanupEnabled
                    recommendations{end+1} = 'Consider removing very old compressed files';
                end
                
                % Check free space
                if report.totalFreeSpace < obj.MIN_FREE_SPACE_GB * 2
                    recommendations{end+1} = 'Low disk space - enable automatic cleanup';
                end
                
                % Check total usage
                if report.totalSizeMB > 1000 % 1GB
                    recommendations{end+1} = 'Large amount of data stored - review retention policy';
                end
                
            catch ME
                obj.logMessage(sprintf('Failed to generate recommendations: %s', ME.message));
            end
        end
    end
end