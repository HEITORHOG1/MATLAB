% RUN_TASK_11_TESTS Master script for Task 11: End-to-end integration and testing
%
% This script executes all subtasks of Task 11 in sequence:
%   11.1 - Create synthetic test dataset
%   11.2 - Run complete pipeline test
%   11.3 - Validate integration with existing infrastructure
%   11.4 - Perform performance benchmarking
%   11.5 - Run full test suite
%
% Usage:
%   >> run_task_11_tests
%
% Or with output capture:
%   >> results = run_task_11_tests()
%
% Output:
%   results - Struct containing all test results

function results = run_task_11_tests()
    
    fprintf('╔════════════════════════════════════════════════════════════╗\n');
    fprintf('║   TASK 11: END-TO-END INTEGRATION AND TESTING             ║\n');
    fprintf('╚════════════════════════════════════════════════════════════╝\n\n');
    
    % Initialize results
    results = struct();
    results.timestamp = datetime('now');
    results.subtasks = struct();
    results.allPassed = true;
    
    % Add necessary paths
    fprintf('Setting up paths...\n');
    addpath(genpath('src/classification'));
    addpath(genpath('tests'));
    fprintf('✓ Paths configured\n\n');
    
    % Subtask 11.1: Create synthetic test dataset
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('SUBTASK 11.1: CREATE SYNTHETIC TEST DATASET\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    try
        cd('tests/integration');
        generate_synthetic_test_dataset();
        cd('../..');
        
        results.subtasks.syntheticDataset.passed = true;
        results.subtasks.syntheticDataset.status = 'PASSED';
        fprintf('\n✓ Subtask 11.1: PASSED\n\n');
    catch ME
        fprintf('\n✗ Subtask 11.1: FAILED - %s\n\n', ME.message);
        results.subtasks.syntheticDataset.passed = false;
        results.subtasks.syntheticDataset.status = 'FAILED';
        results.subtasks.syntheticDataset.error = ME.message;
        results.allPassed = false;
        cd('../..');
    end
    
    % Subtask 11.2: Run complete pipeline test
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('SUBTASK 11.2: RUN COMPLETE PIPELINE TEST\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    try
        cd('tests/integration');
        pipelineResults = test_complete_pipeline();
        cd('../..');
        
        results.subtasks.pipelineTest = pipelineResults;
        results.subtasks.pipelineTest.status = iif(pipelineResults.allPassed, 'PASSED', 'FAILED');
        results.allPassed = results.allPassed && pipelineResults.allPassed;
        fprintf('\n✓ Subtask 11.2: %s\n\n', results.subtasks.pipelineTest.status);
    catch ME
        fprintf('\n✗ Subtask 11.2: FAILED - %s\n\n', ME.message);
        results.subtasks.pipelineTest.passed = false;
        results.subtasks.pipelineTest.status = 'FAILED';
        results.subtasks.pipelineTest.error = ME.message;
        results.allPassed = false;
        cd('../..');
    end
    
    % Subtask 11.3: Validate integration with existing infrastructure
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('SUBTASK 11.3: VALIDATE INFRASTRUCTURE INTEGRATION\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    try
        cd('tests/integration');
        infraResults = test_infrastructure_integration();
        cd('../..');
        
        results.subtasks.infrastructureTest = infraResults;
        results.subtasks.infrastructureTest.status = iif(infraResults.allPassed, 'PASSED', 'FAILED');
        results.allPassed = results.allPassed && infraResults.allPassed;
        fprintf('\n✓ Subtask 11.3: %s\n\n', results.subtasks.infrastructureTest.status);
    catch ME
        fprintf('\n✗ Subtask 11.3: FAILED - %s\n\n', ME.message);
        results.subtasks.infrastructureTest.passed = false;
        results.subtasks.infrastructureTest.status = 'FAILED';
        results.subtasks.infrastructureTest.error = ME.message;
        results.allPassed = false;
        cd('../..');
    end
    
    % Subtask 11.4: Perform performance benchmarking
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('SUBTASK 11.4: PERFORM PERFORMANCE BENCHMARKING\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    try
        cd('tests/integration');
        perfResults = test_performance_benchmarking();
        cd('../..');
        
        results.subtasks.performanceBenchmark = perfResults;
        results.subtasks.performanceBenchmark.status = iif(perfResults.allPassed, 'PASSED', 'FAILED');
        results.allPassed = results.allPassed && perfResults.allPassed;
        fprintf('\n✓ Subtask 11.4: %s\n\n', results.subtasks.performanceBenchmark.status);
    catch ME
        fprintf('\n✗ Subtask 11.4: FAILED - %s\n\n', ME.message);
        results.subtasks.performanceBenchmark.passed = false;
        results.subtasks.performanceBenchmark.status = 'FAILED';
        results.subtasks.performanceBenchmark.error = ME.message;
        results.allPassed = false;
        cd('../..');
    end
    
    % Subtask 11.5: Run full test suite
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('SUBTASK 11.5: RUN FULL TEST SUITE\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    try
        cd('tests/integration');
        suiteResults = run_full_test_suite();
        cd('../..');
        
        results.subtasks.fullTestSuite = suiteResults;
        results.subtasks.fullTestSuite.status = iif(suiteResults.allPassed, 'PASSED', 'FAILED');
        results.allPassed = results.allPassed && suiteResults.allPassed;
        fprintf('\n✓ Subtask 11.5: %s\n\n', results.subtasks.fullTestSuite.status);
    catch ME
        fprintf('\n✗ Subtask 11.5: FAILED - %s\n\n', ME.message);
        results.subtasks.fullTestSuite.passed = false;
        results.subtasks.fullTestSuite.status = 'FAILED';
        results.subtasks.fullTestSuite.error = ME.message;
        results.allPassed = false;
        cd('../..');
    end
    
    % Generate final summary
    fprintf('\n\n');
    fprintf('╔════════════════════════════════════════════════════════════╗\n');
    fprintf('║              TASK 11 - FINAL SUMMARY                       ║\n');
    fprintf('╚════════════════════════════════════════════════════════════╝\n\n');
    
    fprintf('Overall Status: %s\n\n', iif(results.allPassed, '✓ ALL SUBTASKS PASSED', '✗ SOME SUBTASKS FAILED'));
    fprintf('Timestamp: %s\n\n', char(results.timestamp));
    
    fprintf('Subtask Results:\n');
    fprintf('  11.1 Create Synthetic Dataset: %s\n', getSubtaskStatus(results.subtasks, 'syntheticDataset'));
    fprintf('  11.2 Complete Pipeline Test: %s\n', getSubtaskStatus(results.subtasks, 'pipelineTest'));
    fprintf('  11.3 Infrastructure Integration: %s\n', getSubtaskStatus(results.subtasks, 'infrastructureTest'));
    fprintf('  11.4 Performance Benchmarking: %s\n', getSubtaskStatus(results.subtasks, 'performanceBenchmark'));
    fprintf('  11.5 Full Test Suite: %s\n', getSubtaskStatus(results.subtasks, 'fullTestSuite'));
    
    % Save consolidated results
    outputDir = fullfile('tests', 'integration', 'test_output');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    resultsFile = fullfile(outputDir, 'task_11_results.mat');
    save(resultsFile, 'results');
    fprintf('\n📁 Results saved to: %s\n', resultsFile);
    
    % Generate consolidated report
    reportFile = fullfile(outputDir, 'task_11_report.txt');
    generateConsolidatedReport(results, reportFile);
    fprintf('📄 Report saved to: %s\n', reportFile);
    
    % Final message
    fprintf('\n');
    if results.allPassed
        fprintf('🎉 SUCCESS! All Task 11 subtasks completed successfully.\n');
        fprintf('   The classification system has passed all integration and testing requirements.\n');
    else
        fprintf('⚠️  ATTENTION: Some subtasks failed. Please review the reports for details.\n');
        fprintf('   Check: %s\n', reportFile);
    end
    fprintf('\n');
end

function status = getSubtaskStatus(subtasks, subtaskName)
% Get status string for a subtask
    if isfield(subtasks, subtaskName)
        if isfield(subtasks.(subtaskName), 'status')
            status = subtasks.(subtaskName).status;
        elseif isfield(subtasks.(subtaskName), 'passed')
            status = iif(subtasks.(subtaskName).passed, 'PASSED', 'FAILED');
        else
            status = 'UNKNOWN';
        end
    else
        status = 'NOT RUN';
    end
end

function generateConsolidatedReport(results, reportFile)
% Generate consolidated report for Task 11
    
    fid = fopen(reportFile, 'w');
    
    fprintf(fid, '═══════════════════════════════════════════════════════════\n');
    fprintf(fid, '   TASK 11: END-TO-END INTEGRATION AND TESTING - REPORT\n');
    fprintf(fid, '═══════════════════════════════════════════════════════════\n\n');
    
    fprintf(fid, 'Timestamp: %s\n', char(results.timestamp));
    fprintf(fid, 'Overall Status: %s\n\n', iif(results.allPassed, 'ALL SUBTASKS PASSED', 'SOME SUBTASKS FAILED'));
    
    fprintf(fid, '--- Subtask Results ---\n\n');
    
    % Subtask 11.1
    fprintf(fid, '11.1 Create Synthetic Test Dataset: %s\n', getSubtaskStatus(results.subtasks, 'syntheticDataset'));
    if isfield(results.subtasks, 'syntheticDataset') && isfield(results.subtasks.syntheticDataset, 'error')
        fprintf(fid, '     Error: %s\n', results.subtasks.syntheticDataset.error);
    end
    fprintf(fid, '\n');
    
    % Subtask 11.2
    fprintf(fid, '11.2 Run Complete Pipeline Test: %s\n', getSubtaskStatus(results.subtasks, 'pipelineTest'));
    if isfield(results.subtasks, 'pipelineTest') && isfield(results.subtasks.pipelineTest, 'phases')
        phases = results.subtasks.pipelineTest.phases;
        phaseNames = fieldnames(phases);
        for i = 1:length(phaseNames)
            phaseName = phaseNames{i};
            if isfield(phases.(phaseName), 'passed')
                fprintf(fid, '     %s: %s\n', phaseName, iif(phases.(phaseName).passed, 'PASSED', 'FAILED'));
            end
        end
    end
    fprintf(fid, '\n');
    
    % Subtask 11.3
    fprintf(fid, '11.3 Validate Infrastructure Integration: %s\n', getSubtaskStatus(results.subtasks, 'infrastructureTest'));
    if isfield(results.subtasks, 'infrastructureTest') && isfield(results.subtasks.infrastructureTest, 'tests')
        tests = results.subtasks.infrastructureTest.tests;
        testNames = fieldnames(tests);
        for i = 1:length(testNames)
            testName = testNames{i};
            if isfield(tests.(testName), 'passed')
                fprintf(fid, '     %s: %s\n', testName, iif(tests.(testName).passed, 'PASSED', 'FAILED'));
            end
        end
    end
    fprintf(fid, '\n');
    
    % Subtask 11.4
    fprintf(fid, '11.4 Perform Performance Benchmarking: %s\n', getSubtaskStatus(results.subtasks, 'performanceBenchmark'));
    if isfield(results.subtasks, 'performanceBenchmark') && isfield(results.subtasks.performanceBenchmark, 'benchmarks')
        benchmarks = results.subtasks.performanceBenchmark.benchmarks;
        benchmarkNames = fieldnames(benchmarks);
        for i = 1:length(benchmarkNames)
            benchmarkName = benchmarkNames{i};
            if isfield(benchmarks.(benchmarkName), 'passed')
                fprintf(fid, '     %s: %s\n', benchmarkName, iif(benchmarks.(benchmarkName).passed, 'PASSED', 'FAILED'));
            end
        end
    end
    fprintf(fid, '\n');
    
    % Subtask 11.5
    fprintf(fid, '11.5 Run Full Test Suite: %s\n', getSubtaskStatus(results.subtasks, 'fullTestSuite'));
    if isfield(results.subtasks, 'fullTestSuite') && isfield(results.subtasks.fullTestSuite, 'summary')
        summary = results.subtasks.fullTestSuite.summary;
        fprintf(fid, '     Total Suites: %d\n', summary.totalSuites);
        fprintf(fid, '     Passed Suites: %d\n', summary.passedSuites);
        fprintf(fid, '     Failed Suites: %d\n', summary.failedSuites);
        fprintf(fid, '     Pass Rate: %.1f%%\n', summary.suitePassRate);
    end
    fprintf(fid, '\n');
    
    fprintf(fid, '--- Requirements Coverage ---\n\n');
    fprintf(fid, 'Task 11 validates the following requirements:\n');
    fprintf(fid, '  - Requirements 2.1, 2.4: Dataset preparation and validation\n');
    fprintf(fid, '  - Requirements 8.1-8.5: Complete execution pipeline\n');
    fprintf(fid, '  - Requirements 7.1-7.5: Infrastructure integration\n');
    fprintf(fid, '  - Requirements 10.1-10.2: Performance benchmarking\n');
    fprintf(fid, '  - All testing requirements: Comprehensive test coverage\n\n');
    
    fprintf(fid, '--- Conclusion ---\n\n');
    if results.allPassed
        fprintf(fid, 'All Task 11 subtasks completed successfully.\n');
        fprintf(fid, 'The classification system has passed all integration and testing requirements.\n');
        fprintf(fid, 'The system is ready for production use.\n');
    else
        fprintf(fid, 'Some subtasks failed. Review the detailed reports for each subtask.\n');
        fprintf(fid, 'Address the failures before proceeding to production deployment.\n');
    end
    
    fprintf(fid, '\n--- End of Report ---\n');
    fclose(fid);
end

function result = iif(condition, trueVal, falseVal)
% Inline if function
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end
