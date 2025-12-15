function validate_setup()
    % validate_setup - Validate classification system setup
    %
    % This function verifies that the classification system directory structure
    % and configuration are properly set up.
    %
    % Usage:
    %   validate_setup()
    
    fprintf('\n=== Validating Classification System Setup ===\n\n');
    
    allPassed = true;
    
    % Check 1: Verify directory structure
    fprintf('1. Checking directory structure...\n');
    requiredDirs = {
        'src/classification/core'
        'src/classification/models'
        'src/classification/utils'
        'output/classification/checkpoints'
        'output/classification/results'
        'output/classification/figures'
        'output/classification/latex'
        'output/classification/logs'
    };
    
    for i = 1:length(requiredDirs)
        if isfolder(requiredDirs{i})
            fprintf('   ✓ %s\n', requiredDirs{i});
        else
            fprintf('   ✗ %s (MISSING)\n', requiredDirs{i});
            allPassed = false;
        end
    end
    fprintf('\n');
    
    % Check 2: Verify ClassificationConfig exists
    fprintf('2. Checking ClassificationConfig.m...\n');
    configFile = 'src/classification/utils/ClassificationConfig.m';
    if isfile(configFile)
        fprintf('   ✓ ClassificationConfig.m exists\n');
        
        % Try to instantiate it
        try
            config = ClassificationConfig();
            fprintf('   ✓ ClassificationConfig can be instantiated\n');
            
            % Verify key properties exist
            if isprop(config, 'paths') && isprop(config, 'training') && ...
               isprop(config, 'models') && isprop(config, 'evaluation')
                fprintf('   ✓ ClassificationConfig has required properties\n');
            else
                fprintf('   ✗ ClassificationConfig missing required properties\n');
                allPassed = false;
            end
        catch ME
            fprintf('   ✗ Failed to instantiate ClassificationConfig: %s\n', ME.message);
            allPassed = false;
        end
    else
        fprintf('   ✗ ClassificationConfig.m not found\n');
        allPassed = false;
    end
    fprintf('\n');
    
    % Check 3: Verify configuration values
    if exist('config', 'var')
        fprintf('3. Checking configuration values...\n');
        
        % Check paths
        if isfield(config.paths, 'imageDir') && isfield(config.paths, 'maskDir')
            fprintf('   ✓ Path configuration is valid\n');
        else
            fprintf('   ✗ Path configuration is incomplete\n');
            allPassed = false;
        end
        
        % Check label generation
        if isfield(config.labelGeneration, 'thresholds') && ...
           length(config.labelGeneration.thresholds) == 2
            fprintf('   ✓ Label generation configuration is valid\n');
        else
            fprintf('   ✗ Label generation configuration is incomplete\n');
            allPassed = false;
        end
        
        % Check dataset
        if isfield(config.dataset, 'splitRatios') && ...
           abs(sum(config.dataset.splitRatios) - 1.0) < 1e-6
            fprintf('   ✓ Dataset configuration is valid\n');
        else
            fprintf('   ✗ Dataset configuration is incomplete\n');
            allPassed = false;
        end
        
        % Check training
        if isfield(config.training, 'maxEpochs') && ...
           isfield(config.training, 'miniBatchSize')
            fprintf('   ✓ Training configuration is valid\n');
        else
            fprintf('   ✗ Training configuration is incomplete\n');
            allPassed = false;
        end
        
        % Check models
        if isfield(config.models, 'architectures') && ...
           ~isempty(config.models.architectures)
            fprintf('   ✓ Model configuration is valid\n');
        else
            fprintf('   ✗ Model configuration is incomplete\n');
            allPassed = false;
        end
        
        fprintf('\n');
    end
    
    % Check 4: Verify README exists
    fprintf('4. Checking documentation...\n');
    readmeFile = 'src/classification/README.md';
    if isfile(readmeFile)
        fprintf('   ✓ README.md exists\n');
    else
        fprintf('   ✗ README.md not found\n');
        allPassed = false;
    end
    fprintf('\n');
    
    % Final summary
    fprintf('==============================================\n');
    if allPassed
        fprintf('✓ All validation checks passed!\n');
        fprintf('Classification system setup is complete.\n');
    else
        fprintf('✗ Some validation checks failed.\n');
        fprintf('Please review the errors above.\n');
    end
    fprintf('==============================================\n\n');
    
    if ~allPassed
        error('Setup validation failed. Please fix the issues above.');
    end
end
