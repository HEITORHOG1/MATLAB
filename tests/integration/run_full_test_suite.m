function results = run_full_test_suite()
% RUN_FULL_TEST_SUITE Execute complete test suite for classification system
%
% This function runs all unit tests, integration tests, and generates a
% comprehensive test coverage report for the classification system.
%
% Requirements tested: All testing requirements
%
% Usage:
%   results = run_full_test_suite()
%
% Output:
%   results - Struct containing all test results and coverage information

    fprintf('╔════════════════════════════════════════════════════════════╗\n');
    fprintf('║     CLASSIFICATION SYSTEM - FULL TEST SUITE               ║\n');
    fprintf('╚════════════════════════════════════════════════════════════╝\n\n');
    
    % Initialize results
    results = struct();
    results.timestamp = datetime('now');
    results.suites = struct();
    results.allPassed = true;
    results.summary = struct();
    
    % Create output directory
    outputDir = fullfile('tests', 'integration', 'test_output');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Suite 1: Unit Tests
    fprintf('\n═══════════════════════════════════════════════════════════\n');
    fprintf('SUITE 1: UNIT TESTS\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    try
        [suite1Pass, suite1Results] = runUnitTests();
        results.suites.unitTests = suite1Results;
        results.allPassed = results.allPassed && suite1Pass;
        fprintf('\nSuite 1: %s\n', iif(suite1Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('\nSuite 1: ✗ FAILED - %s\n', ME.message);
        results.suites.unitTests.error = ME.message;
        results.allPassed = false;
    end
    
    % Suite 2: Integration Tests
    fprintf('\n═══════════════════════════════════════════════════════════\n');
    fprintf('SUITE 2: INTEGRATION TESTS\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    try
        [suite2Pass, suite2Results] = runIntegrationTests();
        results.suites.integrationTests = suite2Results;
        results.allPassed = results.allPassed && suite2Pass;
        fprintf('\nSuite 2: %s\n', iif(suite2Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('\nSuite 2: ✗ FAILED - %s\n', ME.message);
        results.suites.integrationTests.error = ME.message;
        results.allPassed = false;
    end
    
    % Suite 3: End-to-End Pipeline Test
    fprintf('\n═══════════════════════════════════════════════════════════\n');
    fprintf('SUITE 3: END-TO-END PIPELINE TEST\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    try
        [suite3Pass, suite3Results] = runPipelineTest();
        results.suites.pipelineTest = suite3Results;
        results.allPassed = results.allPassed && suite3Pass;
        fprintf('\nSuite 3: %s\n', iif(suite3Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('\nSuite 3: ✗ FAILED - %s\n', ME.message);
        results.suites.pipelineTest.error = ME.message;
        results.allPassed = false;
    end
    
    % Suite 4: Infrastructure Integration Test
    fprintf('\n═══════════════════════════════════════════════════════════\n');
    fprintf('SUITE 4: INFRASTRUCTURE INTEGRATION TEST\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    try
        [suite4Pass, suite4Results] = runInfrastructureTest();
        results.suites.infrastructureTest = suite4Results;
        results.allPassed = results.allPassed && suite4Pass;
        fprintf('\nSuite 4: %s\n', iif(suite4Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('\nSuite 4: ✗ FAILED - %s\n', ME.message);
        results.suites.infrastructureTest.error = ME.message;
        results.allPassed = false;
    end
    
    % Suite 5: Performance Benchmarking
    fprintf('\n═══════════════════════════════════════════════════════════\n');
    fprintf('SUITE 5: PERFORMANCE BENCHMARKING\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    try
        [suite5Pass, suite5Results] = runPerformanceBenchmarks();
        results.suites.performanceBenchmarks = suite5Results;
        results.allPassed = results.allPassed && suite5Pass;
        fprintf('\nSuite 5: %s\n', iif(suite5Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('\nSuite 5: ✗ FAILED - %s\n', ME.message);
        results.suites.performanceBenchmarks.error = ME.message;
        results.allPassed = false;
    end
    
    % Generate summary statistics
    results.summary = generateSummaryStatistics(results);
    
    % Display final summary
    displayFinalSummary(results);
    
    % Save results
    resultsFile = fullfile(outputDir, 'full_test_suite_results.mat');
    save(resultsFile, 'results');
    fprintf('\n📁 Results saved to: %s\n', resultsFile);
    
    % Generate comprehensive report
    reportFile = fullfile(outputDir, 'full_test_suite_report.txt');
    generateComprehensiveReport(results, reportFile);
    fprintf('📄 Report saved to: %s\n', reportFile);
    
    % Generate HTML report (optional)
    htmlReportFile = fullfile(outputDir, 'full_test_suite_report.html');
    generateHTMLReport(results, htmlReportFile);
    fprintf('🌐 HTML report saved to: %s\n', htmlReportFile);
end

function [passed, suiteResults] = runUnitTests()
% Run all unit tests
    
    suiteResults = struct();
    passed = true;
    
    fprintf('Running unit tests...\n\n');
    
    % List of unit test files
    unitTests = {
        'test_LabelGenerator.m',
        'test_DatasetManager.m',
        'test_ModelFactory.m',
        'test_EvaluationEngine.m'
    };
    
    testDir = fullfile('tests', 'unit');
    suiteResults.tests = struct();
    suiteResults.totalTests = 0;
    suiteResults.passedTests = 0;
    suiteResults.failedTests = 0;
    
    for i = 1:length(unitTests)
        testFile = unitTests{i};
        testPath = fullfile(testDir, testFile);
        
        if exist(testPath, 'file')
            fprintf('  Running %s...\n', testFile);
            try
                % Run the test
                [~, testName, ~] = fileparts(testFile);
                testFunc = str2func(testName);
                testResult = testFunc();
                
                suiteResults.tests.(testName) = testResult;
                suiteResults.totalTests = suiteResults.totalTests + 1;
                
                if testResult.allPassed
                    suiteResults.passedTests = suiteResults.passedTests + 1;
                    fprintf('    ✓ PASSED\n');
                else
                    suiteResults.failedTests = suiteResults.failedTests + 1;
                    fprintf('    ✗ FAILED\n');
                    passed = false;
                end
            catch ME
                fprintf('    ✗ ERROR: %s\n', ME.message);
                suiteResults.tests.(testName).error = ME.message;
                suiteResults.totalTests = suiteResults.totalTests + 1;
                suiteResults.failedTests = suiteResults.failedTests + 1;
                passed = false;
            end
        else
            fprintf('  ⚠ Test file not found: %s\n', testFile);
        end
    end
    
    fprintf('\n  Unit Tests Summary: %d/%d passed\n', ...
        suiteResults.passedTests, suiteResults.totalTests);
    
    suiteResults.passed = passed;
end

function [passed, suiteResults] = runIntegrationTests()
% Run integration tests
    
    suiteResults = struct();
    passed = true;
    
    fprintf('Running integration tests...\n\n');
    
    % List of integration test files
    integrationTests = {
        'test_TrainingEngine.m',
        'test_VisualizationEngine.m'
    };
    
    testDir = fullfile('tests', 'integration');
    suiteResults.tests = struct();
    suiteResults.totalTests = 0;
    suiteResults.passedTests = 0;
    suiteResults.failedTests = 0;
    
    for i = 1:length(integrationTests)
        testFile = integrationTests{i};
        testPath = fullfile(testDir, testFile);
        
        if exist(testPath, 'file')
            fprintf('  Running %s...\n', testFile);
            try
                % Run the test
                [~, testName, ~] = fileparts(testFile);
                testFunc = str2func(testName);
                testResult = testFunc();
                
                suiteResults.tests.(testName) = testResult;
                suiteResults.totalTests = suiteResults.totalTests + 1;
                
                if testResult.allPassed
                    suiteResults.passedTests = suiteResults.passedTests + 1;
                    fprintf('    ✓ PASSED\n');
                else
                    suiteResults.failedTests = suiteResults.failedTests + 1;
                    fprintf('    ✗ FAILED\n');
                    passed = false;
                end
            catch ME
                fprintf('    ✗ ERROR: %s\n', ME.message);
                suiteResults.tests.(testName).error = ME.message;
                suiteResults.totalTests = suiteResults.totalTests + 1;
                suiteResults.failedTests = suiteResults.failedTests + 1;
                passed = false;
            end
        else
            fprintf('  ⚠ Test file not found: %s\n', testFile);
        end
    end
    
    fprintf('\n  Integration Tests Summary: %d/%d passed\n', ...
        suiteResults.passedTests, suiteResults.totalTests);
    
    suiteResults.passed = passed;
end

function [passed, suiteResults] = runPipelineTest()
% Run end-to-end pipeline test
    
    fprintf('Running complete pipeline test...\n\n');
    
    try
        suiteResults = test_complete_pipeline();
        passed = suiteResults.allPassed;
    catch ME
        fprintf('Pipeline test failed: %s\n', ME.message);
        suiteResults = struct();
        suiteResults.error = ME.message;
        suiteResults.allPassed = false;
        passed = false;
    end
end

function [passed, suiteResults] = runInfrastructureTest()
% Run infrastructure integration test
    
    fprintf('Running infrastructure integration test...\n\n');
    
    try
        suiteResults = test_infrastructure_integration();
        passed = suiteResults.allPassed;
    catch ME
        fprintf('Infrastructure test failed: %s\n', ME.message);
        suiteResults = struct();
        suiteResults.error = ME.message;
        suiteResults.allPassed = false;
        passed = false;
    end
end

function [passed, suiteResults] = runPerformanceBenchmarks()
% Run performance benchmarking
    
    fprintf('Running performance benchmarks...\n\n');
    
    try
        suiteResults = test_performance_benchmarking();
        passed = suiteResults.allPassed;
    catch ME
        fprintf('Performance benchmarking failed: %s\n', ME.message);
        suiteResults = struct();
        suiteResults.error = ME.message;
        suiteResults.allPassed = false;
        passed = false;
    end
end

function summary = generateSummaryStatistics(results)
% Generate summary statistics from all test results
    
    summary = struct();
    summary.totalSuites = 5;
    summary.passedSuites = 0;
    summary.failedSuites = 0;
    summary.totalTests = 0;
    summary.passedTests = 0;
    summary.failedTests = 0;
    
    % Count suite results
    suiteNames = fieldnames(results.suites);
    for i = 1:length(suiteNames)
        suiteName = suiteNames{i};
        suite = results.suites.(suiteName);
        
        if isfield(suite, 'passed') && suite.passed
            summary.passedSuites = summary.passedSuites + 1;
        else
            summary.failedSuites = summary.failedSuites + 1;
        end
        
        % Count individual tests if available
        if isfield(suite, 'totalTests')
            summary.totalTests = summary.totalTests + suite.totalTests;
            summary.passedTests = summary.passedTests + suite.passedTests;
            summary.failedTests = summary.failedTests + suite.failedTests;
        end
    end
    
    % Calculate pass rate
    if summary.totalSuites > 0
        summary.suitePassRate = (summary.passedSuites / summary.totalSuites) * 100;
    else
        summary.suitePassRate = 0;
    end
    
    if summary.totalTests > 0
        summary.testPassRate = (summary.passedTests / summary.totalTests) * 100;
    else
        summary.testPassRate = 0;
    end
end

function displayFinalSummary(results)
% Display final summary of all test results
    
    fprintf('\n\n');
    fprintf('╔════════════════════════════════════════════════════════════╗\n');
    fprintf('║                    FINAL TEST SUMMARY                      ║\n');
    fprintf('╚════════════════════════════════════════════════════════════╝\n\n');
    
    fprintf('Overall Status: %s\n\n', iif(results.allPassed, '✓ ALL TESTS PASSED', '✗ SOME TESTS FAILED'));
    
    fprintf('Test Suites:\n');
    fprintf('  Total: %d\n', results.summary.totalSuites);
    fprintf('  Passed: %d\n', results.summary.passedSuites);
    fprintf('  Failed: %d\n', results.summary.failedSuites);
    fprintf('  Pass Rate: %.1f%%\n\n', results.summary.suitePassRate);
    
    if results.summary.totalTests > 0
        fprintf('Individual Tests:\n');
        fprintf('  Total: %d\n', results.summary.totalTests);
        fprintf('  Passed: %d\n', results.summary.passedTests);
        fprintf('  Failed: %d\n', results.summary.failedTests);
        fprintf('  Pass Rate: %.1f%%\n\n', results.summary.testPassRate);
    end
    
    fprintf('Suite Results:\n');
    fprintf('  1. Unit Tests: %s\n', getSuiteStatus(results.suites, 'unitTests'));
    fprintf('  2. Integration Tests: %s\n', getSuiteStatus(results.suites, 'integrationTests'));
    fprintf('  3. Pipeline Test: %s\n', getSuiteStatus(results.suites, 'pipelineTest'));
    fprintf('  4. Infrastructure Test: %s\n', getSuiteStatus(results.suites, 'infrastructureTest'));
    fprintf('  5. Performance Benchmarks: %s\n', getSuiteStatus(results.suites, 'performanceBenchmarks'));
    
    fprintf('\nTimestamp: %s\n', char(results.timestamp));
end

function status = getSuiteStatus(suites, suiteName)
% Get status string for a suite
    if isfield(suites, suiteName)
        if isfield(suites.(suiteName), 'passed') && suites.(suiteName).passed
            status = '✓ PASSED';
        else
            status = '✗ FAILED';
        end
    else
        status = '- NOT RUN';
    end
end

function generateComprehensiveReport(results, reportFile)
% Generate comprehensive text report
    
    fid = fopen(reportFile, 'w');
    
    fprintf(fid, '═══════════════════════════════════════════════════════════\n');
    fprintf(fid, '     CLASSIFICATION SYSTEM - FULL TEST SUITE REPORT\n');
    fprintf(fid, '═══════════════════════════════════════════════════════════\n\n');
    
    fprintf(fid, 'Timestamp: %s\n', char(results.timestamp));
    fprintf(fid, 'Overall Status: %s\n\n', iif(results.allPassed, 'ALL TESTS PASSED', 'SOME TESTS FAILED'));
    
    fprintf(fid, '--- Summary Statistics ---\n\n');
    fprintf(fid, 'Test Suites: %d total, %d passed, %d failed (%.1f%% pass rate)\n', ...
        results.summary.totalSuites, results.summary.passedSuites, ...
        results.summary.failedSuites, results.summary.suitePassRate);
    
    if results.summary.totalTests > 0
        fprintf(fid, 'Individual Tests: %d total, %d passed, %d failed (%.1f%% pass rate)\n\n', ...
            results.summary.totalTests, results.summary.passedTests, ...
            results.summary.failedTests, results.summary.testPassRate);
    end
    
    fprintf(fid, '--- Suite Results ---\n\n');
    
    suiteNames = {'unitTests', 'integrationTests', 'pipelineTest', ...
        'infrastructureTest', 'performanceBenchmarks'};
    suiteTitles = {'Unit Tests', 'Integration Tests', 'Pipeline Test', ...
        'Infrastructure Test', 'Performance Benchmarks'};
    
    for i = 1:length(suiteNames)
        suiteName = suiteNames{i};
        suiteTitle = suiteTitles{i};
        
        fprintf(fid, '%d. %s: %s\n', i, suiteTitle, getSuiteStatus(results.suites, suiteName));
        
        if isfield(results.suites, suiteName)
            suite = results.suites.(suiteName);
            if isfield(suite, 'totalTests')
                fprintf(fid, '   Tests: %d/%d passed\n', suite.passedTests, suite.totalTests);
            end
            if isfield(suite, 'error')
                fprintf(fid, '   Error: %s\n', suite.error);
            end
        end
        fprintf(fid, '\n');
    end
    
    fprintf(fid, '--- End of Report ---\n');
    fclose(fid);
end

function generateHTMLReport(results, htmlFile)
% Generate HTML report
    
    fid = fopen(htmlFile, 'w');
    
    fprintf(fid, '<!DOCTYPE html>\n<html>\n<head>\n');
    fprintf(fid, '<title>Classification System Test Report</title>\n');
    fprintf(fid, '<style>\n');
    fprintf(fid, 'body { font-family: Arial, sans-serif; margin: 20px; }\n');
    fprintf(fid, 'h1 { color: #333; }\n');
    fprintf(fid, '.passed { color: green; font-weight: bold; }\n');
    fprintf(fid, '.failed { color: red; font-weight: bold; }\n');
    fprintf(fid, 'table { border-collapse: collapse; width: 100%%; margin: 20px 0; }\n');
    fprintf(fid, 'th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }\n');
    fprintf(fid, 'th { background-color: #4CAF50; color: white; }\n');
    fprintf(fid, '</style>\n');
    fprintf(fid, '</head>\n<body>\n');
    
    fprintf(fid, '<h1>Classification System - Full Test Suite Report</h1>\n');
    fprintf(fid, '<p><strong>Timestamp:</strong> %s</p>\n', char(results.timestamp));
    fprintf(fid, '<p><strong>Overall Status:</strong> <span class="%s">%s</span></p>\n', ...
        iif(results.allPassed, 'passed', 'failed'), ...
        iif(results.allPassed, 'ALL TESTS PASSED', 'SOME TESTS FAILED'));
    
    fprintf(fid, '<h2>Summary Statistics</h2>\n');
    fprintf(fid, '<table>\n');
    fprintf(fid, '<tr><th>Metric</th><th>Value</th></tr>\n');
    fprintf(fid, '<tr><td>Total Suites</td><td>%d</td></tr>\n', results.summary.totalSuites);
    fprintf(fid, '<tr><td>Passed Suites</td><td>%d</td></tr>\n', results.summary.passedSuites);
    fprintf(fid, '<tr><td>Failed Suites</td><td>%d</td></tr>\n', results.summary.failedSuites);
    fprintf(fid, '<tr><td>Suite Pass Rate</td><td>%.1f%%</td></tr>\n', results.summary.suitePassRate);
    
    if results.summary.totalTests > 0
        fprintf(fid, '<tr><td>Total Tests</td><td>%d</td></tr>\n', results.summary.totalTests);
        fprintf(fid, '<tr><td>Passed Tests</td><td>%d</td></tr>\n', results.summary.passedTests);
        fprintf(fid, '<tr><td>Failed Tests</td><td>%d</td></tr>\n', results.summary.failedTests);
        fprintf(fid, '<tr><td>Test Pass Rate</td><td>%.1f%%</td></tr>\n', results.summary.testPassRate);
    end
    
    fprintf(fid, '</table>\n');
    
    fprintf(fid, '<h2>Suite Results</h2>\n');
    fprintf(fid, '<table>\n');
    fprintf(fid, '<tr><th>Suite</th><th>Status</th><th>Details</th></tr>\n');
    
    suiteNames = {'unitTests', 'integrationTests', 'pipelineTest', ...
        'infrastructureTest', 'performanceBenchmarks'};
    suiteTitles = {'Unit Tests', 'Integration Tests', 'Pipeline Test', ...
        'Infrastructure Test', 'Performance Benchmarks'};
    
    for i = 1:length(suiteNames)
        suiteName = suiteNames{i};
        suiteTitle = suiteTitles{i};
        status = getSuiteStatus(results.suites, suiteName);
        
        fprintf(fid, '<tr><td>%s</td><td class="%s">%s</td><td>', ...
            suiteTitle, iif(contains(status, 'PASSED'), 'passed', 'failed'), status);
        
        if isfield(results.suites, suiteName) && isfield(results.suites.(suiteName), 'totalTests')
            fprintf(fid, '%d/%d tests passed', ...
                results.suites.(suiteName).passedTests, ...
                results.suites.(suiteName).totalTests);
        end
        
        fprintf(fid, '</td></tr>\n');
    end
    
    fprintf(fid, '</table>\n');
    fprintf(fid, '</body>\n</html>\n');
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
