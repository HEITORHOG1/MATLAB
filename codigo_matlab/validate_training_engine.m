% validate_training_engine.m - Validation script for TrainingEngine
%
% This script validates the TrainingEngine implementation by running
% integration tests with synthetic data.
%
% Requirements validated: 4.1, 4.3, 4.4, 7.1

function validate_training_engine()
    fprintf('\n');
    fprintf('========================================\n');
    fprintf('TrainingEngine Validation Script\n');
    fprintf('========================================\n');
    fprintf('\n');
    
    % Add paths
    addpath(genpath('src'));
    addpath(genpath('tests'));
    
    % Initialize error handler
    errorHandler = ErrorHandler.getInstance();
    logFile = fullfile('output', 'classification', 'logs', 'training_engine_validation.log');
    
    % Create log directory if needed
    logDir = fileparts(logFile);
    if ~exist(logDir, 'dir')
        mkdir(logDir);
    end
    
    errorHandler.setLogFile(logFile);
    errorHandler.logInfo('Validation', 'Starting TrainingEngine validation');
    
    try
        % Run integration tests
        fprintf('Running integration tests...\n\n');
        test_TrainingEngine();
        
        fprintf('\n');
        fprintf('========================================\n');
        fprintf('Validation Complete\n');
        fprintf('========================================\n');
        fprintf('\n');
        fprintf('Check log file for details: %s\n', logFile);
        fprintf('\n');
        
        errorHandler.logInfo('Validation', 'TrainingEngine validation completed successfully');
        
    catch ME
        fprintf('\n');
        fprintf('========================================\n');
        fprintf('Validation Failed\n');
        fprintf('========================================\n');
        fprintf('\n');
        fprintf('Error: %s\n', ME.message);
        fprintf('Stack trace:\n%s\n', ME.getReport());
        fprintf('\n');
        
        errorHandler.logError('Validation', sprintf('Validation failed: %s', ME.message));
        rethrow(ME);
    end
end
