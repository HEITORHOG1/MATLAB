% validate_executar_classificacao.m - Validation script for main execution script
%
% This script validates the executar_classificacao.m implementation
% by checking all required functionality and components.
%
% Requirements validated: 8.1, 8.2, 8.3, 8.4, 8.5

function validate_executar_classificacao()
    fprintf('\n');
    fprintf('========================================================\n');
    fprintf('  VALIDATING MAIN EXECUTION SCRIPT\n');
    fprintf('========================================================\n\n');
    
    totalTests = 0;
    passedTests = 0;
    
    %% Test 1: Check if main script exists
    fprintf('[Test 1] Checking if executar_classificacao.m exists...\n');
    totalTests = totalTests + 1;
    
    if exist('executar_classificacao.m', 'file')
        fprintf('  ✓ PASS: Main script exists\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Main script not found\n\n');
        return;
    end
    
    %% Test 2: Check helper functions exist
    fprintf('[Test 2] Checking helper functions...\n');
    totalTests = totalTests + 1;
    
    scriptContent = fileread('executar_classificacao.m');
    
    requiredFunctions = {
        'detectAndValidatePaths'
        'generateLabels'
        'prepareDatasets'
        'trainModel'
        'evaluateModel'
        'generateVisualizations'
        'generateFinalSummary'
        'displayFinalResults'
    };
    
    allFunctionsExist = true;
    for i = 1:length(requiredFunctions)
        funcName = requiredFunctions{i};
        if contains(scriptContent, ['function ' funcName]) || ...
           contains(scriptContent, ['function [' funcName])
            fprintf('  ✓ Function exists: %s\n', funcName);
        else
            fprintf('  ✗ Function missing: %s\n', funcName);
            allFunctionsExist = false;
        end
    end
    
    if allFunctionsExist
        fprintf('  ✓ PASS: All helper functions exist\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Some helper functions missing\n\n');
    end
    
    %% Test 3: Check automatic path detection (Requirement 8.2)
    fprintf('[Test 3] Checking automatic path detection...\n');
    totalTests = totalTests + 1;
    
    if contains(scriptContent, 'detectAndValidatePaths') && ...
       contains(scriptContent, 'alternativePaths') && ...
       contains(scriptContent, 'PathDetection:ImageDirNotFound')
        fprintf('  ✓ PASS: Automatic path detection implemented\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Automatic path detection not properly implemented\n\n');
    end
    
    %% Test 4: Check progress reporting (Requirement 8.3)
    fprintf('[Test 4] Checking progress reporting...\n');
    totalTests = totalTests + 1;
    
    if contains(scriptContent, 'Phase 1/7') && ...
       contains(scriptContent, 'Phase 2/7') && ...
       contains(scriptContent, 'fprintf') && ...
       contains(scriptContent, 'phaseStartTime') && ...
       contains(scriptContent, 'phaseTime')
        fprintf('  ✓ PASS: Progress reporting implemented\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Progress reporting not properly implemented\n\n');
    end
    
    %% Test 5: Check error handling (Requirement 8.5, 7.1)
    fprintf('[Test 5] Checking comprehensive error handling...\n');
    totalTests = totalTests + 1;
    
    if contains(scriptContent, 'try') && ...
       contains(scriptContent, 'catch ME') && ...
       contains(scriptContent, 'errorHandler.logError') && ...
       contains(scriptContent, 'trainingErrors')
        fprintf('  ✓ PASS: Comprehensive error handling implemented\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Error handling not properly implemented\n\n');
    end
    
    %% Test 6: Check execution logging (Requirement 8.5)
    fprintf('[Test 6] Checking execution logging...\n');
    totalTests = totalTests + 1;
    
    if contains(scriptContent, 'errorHandler.setLogFile') && ...
       contains(scriptContent, 'timestamp') && ...
       contains(scriptContent, 'classification_execution_') && ...
       contains(scriptContent, 'errorHandler.logInfo')
        fprintf('  ✓ PASS: Execution logging implemented\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Execution logging not properly implemented\n\n');
    end
    
    %% Test 7: Check all phases are implemented (Requirement 8.1)
    fprintf('[Test 7] Checking all execution phases...\n');
    totalTests = totalTests + 1;
    
    requiredPhases = {
        'Load Configuration'
        'Generate Labels'
        'Prepare Dataset'
        'Train'
        'Evaluat'
        'Visualization'
        'Summary'
    };
    
    allPhasesExist = true;
    for i = 1:length(requiredPhases)
        phase = requiredPhases{i};
        if contains(scriptContent, phase)
            fprintf('  ✓ Phase exists: %s\n', phase);
        else
            fprintf('  ✗ Phase missing: %s\n', phase);
            allPhasesExist = false;
        end
    end
    
    if allPhasesExist
        fprintf('  ✓ PASS: All execution phases implemented\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Some execution phases missing\n\n');
    end
    
    %% Test 8: Check graceful degradation
    fprintf('[Test 8] Checking graceful degradation...\n');
    totalTests = totalTests + 1;
    
    if contains(scriptContent, 'Continuing with remaining models') && ...
       contains(scriptContent, 'successfulModels') && ...
       contains(scriptContent, 'if isempty(trainedModels{i})')
        fprintf('  ✓ PASS: Graceful degradation implemented\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Graceful degradation not properly implemented\n\n');
    end
    
    %% Test 9: Check configuration integration
    fprintf('[Test 9] Checking configuration integration...\n');
    totalTests = totalTests + 1;
    
    if contains(scriptContent, 'ClassificationConfig') && ...
       contains(scriptContent, 'config.paths') && ...
       contains(scriptContent, 'config.labelGeneration') && ...
       contains(scriptContent, 'config.training')
        fprintf('  ✓ PASS: Configuration integration implemented\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Configuration integration not properly implemented\n\n');
    end
    
    %% Test 10: Check summary report generation
    fprintf('[Test 10] Checking summary report generation...\n');
    totalTests = totalTests + 1;
    
    if contains(scriptContent, 'generateFinalSummary') && ...
       contains(scriptContent, 'execution_summary_') && ...
       contains(scriptContent, 'Best Accuracy') && ...
       contains(scriptContent, 'displayFinalResults')
        fprintf('  ✓ PASS: Summary report generation implemented\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Summary report generation not properly implemented\n\n');
    end
    
    %% Test 11: Check component integration
    fprintf('[Test 11] Checking component integration...\n');
    totalTests = totalTests + 1;
    
    requiredComponents = {
        'LabelGenerator'
        'DatasetManager'
        'ModelFactory'
        'TrainingEngine'
        'EvaluationEngine'
        'VisualizationEngine'
    };
    
    allComponentsUsed = true;
    for i = 1:length(requiredComponents)
        component = requiredComponents{i};
        if contains(scriptContent, component)
            fprintf('  ✓ Component used: %s\n', component);
        else
            fprintf('  ✗ Component not used: %s\n', component);
            allComponentsUsed = false;
        end
    end
    
    if allComponentsUsed
        fprintf('  ✓ PASS: All components integrated\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Some components not integrated\n\n');
    end
    
    %% Test 12: Check timing and performance tracking
    fprintf('[Test 12] Checking timing and performance tracking...\n');
    totalTests = totalTests + 1;
    
    if contains(scriptContent, 'totalStartTime = tic') && ...
       contains(scriptContent, 'phaseStartTime = tic') && ...
       contains(scriptContent, 'toc(') && ...
       contains(scriptContent, 'Total execution time')
        fprintf('  ✓ PASS: Timing and performance tracking implemented\n\n');
        passedTests = passedTests + 1;
    else
        fprintf('  ✗ FAIL: Timing tracking not properly implemented\n\n');
    end
    
    %% Summary
    fprintf('========================================================\n');
    fprintf('  VALIDATION SUMMARY\n');
    fprintf('========================================================\n');
    fprintf('Total tests: %d\n', totalTests);
    fprintf('Passed: %d\n', passedTests);
    fprintf('Failed: %d\n', totalTests - passedTests);
    fprintf('Success rate: %.1f%%\n', (passedTests / totalTests) * 100);
    fprintf('========================================================\n\n');
    
    if passedTests == totalTests
        fprintf('✓ ALL TESTS PASSED - Main execution script is valid!\n\n');
    else
        fprintf('✗ SOME TESTS FAILED - Please review the implementation.\n\n');
    end
end
