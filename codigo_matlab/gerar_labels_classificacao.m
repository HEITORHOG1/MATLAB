% gerar_labels_classificacao.m - Generate classification labels from segmentation masks
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This script automates the conversion of binary segmentation masks into
% categorical severity labels for the corrosion classification system.
% It uses the LabelGenerator class to process all masks and generates
% a CSV file with labels and summary statistics.
%
% Requirements: 1.5
%
% Usage:
%   Run this script directly: gerar_labels_classificacao
%   Or with custom config: gerar_labels_classificacao('custom_config.mat')
%
% Outputs:
%   - CSV file with columns: filename, corroded_percentage, severity_class
%   - Summary statistics report in console and log file
%   - Statistics MAT file for further analysis

function gerar_labels_classificacao(configFile)
    % Main function to generate labels from masks
    %
    % Args:
    %   configFile (optional): Path to custom configuration file
    
    fprintf('\n=== Corrosion Classification Label Generation ===\n\n');
    
    % Load configuration
    if nargin < 1 || isempty(configFile)
        fprintf('Loading default configuration...\n');
        config = ClassificationConfig();
    else
        fprintf('Loading configuration from: %s\n', configFile);
        config = ClassificationConfig(configFile);
    end
    
    % Display configuration
    fprintf('\nConfiguration Summary:\n');
    fprintf('  Mask Directory: %s\n', config.paths.maskDir);
    fprintf('  Output CSV: %s\n', config.labelGeneration.outputCSV);
    fprintf('  Thresholds: [%.1f%%, %.1f%%]\n', ...
        config.labelGeneration.thresholds(1), ...
        config.labelGeneration.thresholds(2));
    fprintf('  Class Names: %s\n', strjoin(config.labelGeneration.classNames, ', '));
    fprintf('\n');
    
    % Validate input directory exists
    if ~exist(config.paths.maskDir, 'dir')
        error('Mask directory not found: %s\nPlease check the configuration.', ...
            config.paths.maskDir);
    end
    
    % Initialize error handler for logging
    errorHandler = ErrorHandler.getInstance();
    logFile = fullfile(config.paths.logsDir, ...
        sprintf('label_generation_%s.txt', datestr(now, 'yyyymmdd_HHMMSS')));
    errorHandler.setLogFile(logFile);
    
    errorHandler.logInfo('Script', '=== Starting Label Generation ===');
    errorHandler.logInfo('Script', sprintf('Mask directory: %s', config.paths.maskDir));
    errorHandler.logInfo('Script', sprintf('Output CSV: %s', config.labelGeneration.outputCSV));
    
    % Create LabelGenerator instance
    fprintf('Initializing LabelGenerator...\n');
    labelGen = LabelGenerator(config.labelGeneration.thresholds, errorHandler);
    
    % Generate labels from masks
    fprintf('Processing masks...\n');
    startTime = tic;
    
    try
        [labels, stats] = labelGen.generateLabelsFromMasks(...
            config.paths.maskDir, ...
            config.labelGeneration.outputCSV);
        
        elapsedTime = toc(startTime);
        
        % Display results
        fprintf('\n=== Label Generation Complete ===\n');
        fprintf('Processing time: %.2f seconds\n', elapsedTime);
        fprintf('Total files processed: %d\n', stats.totalFiles);
        fprintf('Successfully processed: %d\n', stats.successCount);
        fprintf('Failed: %d\n', stats.failureCount);
        
        if stats.failureCount > 0
            fprintf('\nFailed files:\n');
            for i = 1:length(stats.failedFiles)
                fprintf('  - %s\n', stats.failedFiles{i});
            end
        end
        
        % Display class distribution
        fprintf('\n--- Class Distribution ---\n');
        for i = 1:config.labelGeneration.numClasses
            className = config.labelGeneration.classNames{i};
            count = stats.classDistribution(i);
            percentage = (count / stats.successCount) * 100;
            fprintf('Class %d (%s): %d samples (%.1f%%)\n', ...
                i-1, className, count, percentage);
        end
        
        % Display corroded percentage statistics
        fprintf('\n--- Corroded Percentage Statistics ---\n');
        fprintf('Range: [%.2f%%, %.2f%%]\n', ...
            stats.percentageRange(1), stats.percentageRange(2));
        fprintf('Mean: %.2f%% (±%.2f%%)\n', ...
            stats.percentageMean, stats.percentageStd);
        
        % Check for class imbalance
        maxCount = max(stats.classDistribution);
        minCount = min(stats.classDistribution);
        if minCount > 0
            imbalanceRatio = maxCount / minCount;
            if imbalanceRatio > 3
                fprintf('\n*** WARNING: Class imbalance detected! ***\n');
                fprintf('Imbalance ratio: %.1f:1\n', imbalanceRatio);
                fprintf('Consider using stratified sampling or class weights during training.\n');
            end
        end
        
        % Save statistics to MAT file
        statsFile = fullfile(config.paths.resultsDir, 'label_generation_stats.mat');
        save(statsFile, 'stats', 'labels', 'config');
        fprintf('\nStatistics saved to: %s\n', statsFile);
        
        % Generate summary report
        generateSummaryReport(labels, stats, config);
        
        % Log completion
        errorHandler.logInfo('Script', '=== Label Generation Completed Successfully ===');
        errorHandler.logInfo('Script', sprintf('Total time: %.2f seconds', elapsedTime));
        
        fprintf('\nLog file saved to: %s\n', logFile);
        fprintf('\n=== Process Complete ===\n\n');
        
    catch ME
        elapsedTime = toc(startTime);
        
        % Log error
        errorHandler.logError('Script', sprintf('Label generation failed: %s', ME.message));
        errorHandler.logError('Script', sprintf('Stack trace: %s', ME.getReport()));
        
        % Display error
        fprintf('\n*** ERROR: Label generation failed ***\n');
        fprintf('Error message: %s\n', ME.message);
        fprintf('Elapsed time: %.2f seconds\n', elapsedTime);
        fprintf('Check log file for details: %s\n', logFile);
        
        rethrow(ME);
    end
end

function generateSummaryReport(labels, stats, config)
    % Generate a detailed summary report in text format
    %
    % Args:
    %   labels: Table with generated labels
    %   stats: Statistics struct
    %   config: Configuration object
    
    reportFile = fullfile(config.paths.resultsDir, 'label_generation_report.txt');
    
    fid = fopen(reportFile, 'w');
    if fid == -1
        warning('Could not create summary report file: %s', reportFile);
        return;
    end
    
    try
        % Write header
        fprintf(fid, '=======================================================\n');
        fprintf(fid, '  CORROSION CLASSIFICATION LABEL GENERATION REPORT\n');
        fprintf(fid, '=======================================================\n\n');
        fprintf(fid, 'Generated: %s\n\n', datestr(now));
        
        % Configuration section
        fprintf(fid, '--- Configuration ---\n');
        fprintf(fid, 'Mask Directory: %s\n', config.paths.maskDir);
        fprintf(fid, 'Output CSV: %s\n', config.labelGeneration.outputCSV);
        fprintf(fid, 'Thresholds: [%.1f%%, %.1f%%]\n', ...
            config.labelGeneration.thresholds(1), ...
            config.labelGeneration.thresholds(2));
        fprintf(fid, 'Class Names: %s\n\n', strjoin(config.labelGeneration.classNames, ', '));
        
        % Processing summary
        fprintf(fid, '--- Processing Summary ---\n');
        fprintf(fid, 'Total files: %d\n', stats.totalFiles);
        fprintf(fid, 'Successfully processed: %d\n', stats.successCount);
        fprintf(fid, 'Failed: %d\n', stats.failureCount);
        fprintf(fid, 'Success rate: %.1f%%\n\n', ...
            (stats.successCount / stats.totalFiles) * 100);
        
        % Failed files
        if stats.failureCount > 0
            fprintf(fid, '--- Failed Files ---\n');
            for i = 1:length(stats.failedFiles)
                fprintf(fid, '%d. %s\n', i, stats.failedFiles{i});
            end
            fprintf(fid, '\n');
        end
        
        % Class distribution
        fprintf(fid, '--- Class Distribution ---\n');
        for i = 1:config.labelGeneration.numClasses
            className = config.labelGeneration.classNames{i};
            count = stats.classDistribution(i);
            percentage = (count / stats.successCount) * 100;
            fprintf(fid, 'Class %d (%s):\n', i-1, className);
            fprintf(fid, '  Count: %d\n', count);
            fprintf(fid, '  Percentage: %.1f%%\n', percentage);
        end
        fprintf(fid, '\n');
        
        % Class imbalance analysis
        maxCount = max(stats.classDistribution);
        minCount = min(stats.classDistribution);
        if minCount > 0
            imbalanceRatio = maxCount / minCount;
            fprintf(fid, '--- Class Balance Analysis ---\n');
            fprintf(fid, 'Imbalance ratio: %.2f:1\n', imbalanceRatio);
            if imbalanceRatio > 3
                fprintf(fid, 'WARNING: Significant class imbalance detected!\n');
                fprintf(fid, 'Recommendation: Use stratified sampling or class weights.\n');
            else
                fprintf(fid, 'Class distribution is reasonably balanced.\n');
            end
            fprintf(fid, '\n');
        end
        
        % Corroded percentage statistics
        fprintf(fid, '--- Corroded Percentage Statistics ---\n');
        fprintf(fid, 'Minimum: %.2f%%\n', stats.percentageRange(1));
        fprintf(fid, 'Maximum: %.2f%%\n', stats.percentageRange(2));
        fprintf(fid, 'Mean: %.2f%%\n', stats.percentageMean);
        fprintf(fid, 'Standard Deviation: %.2f%%\n', stats.percentageStd);
        fprintf(fid, '\n');
        
        % Sample data
        fprintf(fid, '--- Sample Labels (first 10) ---\n');
        fprintf(fid, '%-30s %15s %15s\n', 'Filename', 'Corroded %', 'Class');
        fprintf(fid, '%s\n', repmat('-', 1, 62));
        numSamples = min(10, height(labels));
        for i = 1:numSamples
            fprintf(fid, '%-30s %14.2f%% %15d\n', ...
                labels.filename{i}, ...
                labels.corroded_percentage(i), ...
                labels.severity_class(i));
        end
        fprintf(fid, '\n');
        
        % Footer
        fprintf(fid, '=======================================================\n');
        fprintf(fid, 'End of Report\n');
        fprintf(fid, '=======================================================\n');
        
        fclose(fid);
        
        fprintf('Summary report saved to: %s\n', reportFile);
        
    catch ME
        fclose(fid);
        warning('Error writing summary report: %s', ME.message);
    end
end
