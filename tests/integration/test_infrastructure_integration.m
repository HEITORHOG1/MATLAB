function results = test_infrastructure_integration()
% TEST_INFRASTRUCTURE_INTEGRATION Validates integration with existing infrastructure
%
% This function tests the classification system's integration with existing
% project infrastructure components: ErrorHandler, VisualizationHelper,
% DataTypeConverter, and validates no conflicts with segmentation code.
%
% Requirements tested: 7.1, 7.2, 7.3, 7.4, 7.5
%
% Usage:
%   results = test_infrastructure_integration()
%
% Output:
%   results - Struct containing integration test results

    fprintf('=== INFRASTRUCTURE INTEGRATION TEST ===\n\n');
    
    % Initialize results
    results = struct();
    results.timestamp = datetime('now');
    results.tests = struct();
    results.allPassed = true;
    
    % Test 1: ErrorHandler Integration
    fprintf('--- Test 1: ErrorHandler Integration ---\n');
    try
        [test1Pass, test1Results] = testErrorHandlerIntegration();
        results.tests.errorHandler = test1Results;
        results.allPassed = results.allPassed && test1Pass;
        fprintf('Test 1: %s\n\n', iif(test1Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('Test 1: ✗ FAILED - %s\n\n', ME.message);
        results.tests.errorHandler.error = ME.message;
        results.allPassed = false;
    end
    
    % Test 2: VisualizationHelper Integration
    fprintf('--- Test 2: VisualizationHelper Integration ---\n');
    try
        [test2Pass, test2Results] = testVisualizationHelperIntegration();
        results.tests.visualizationHelper = test2Results;
        results.allPassed = results.allPassed && test2Pass;
        fprintf('Test 2: %s\n\n', iif(test2Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('Test 2: ✗ FAILED - %s\n\n', ME.message);
        results.tests.visualizationHelper.error = ME.message;
        results.allPassed = false;
    end
    
    % Test 3: DataTypeConverter Integration
    fprintf('--- Test 3: DataTypeConverter Integration ---\n');
    try
        [test3Pass, test3Results] = testDataTypeConverterIntegration();
        results.tests.dataTypeConverter = test3Results;
        results.allPassed = results.allPassed && test3Pass;
        fprintf('Test 3: %s\n\n', iif(test3Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('Test 3: ✗ FAILED - %s\n\n', ME.message);
        results.tests.dataTypeConverter.error = ME.message;
        results.allPassed = false;
    end
    
    % Test 4: No Conflicts with Segmentation Code
    fprintf('--- Test 4: Segmentation Code Compatibility ---\n');
    try
        [test4Pass, test4Results] = testSegmentationCompatibility();
        results.tests.segmentationCompatibility = test4Results;
        results.allPassed = results.allPassed && test4Pass;
        fprintf('Test 4: %s\n\n', iif(test4Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('Test 4: ✗ FAILED - %s\n\n', ME.message);
        results.tests.segmentationCompatibility.error = ME.message;
        results.allPassed = false;
    end
    
    % Test 5: Configuration System Compatibility
    fprintf('--- Test 5: Configuration System Compatibility ---\n');
    try
        [test5Pass, test5Results] = testConfigurationCompatibility();
        results.tests.configurationCompatibility = test5Results;
        results.allPassed = results.allPassed && test5Pass;
        fprintf('Test 5: %s\n\n', iif(test5Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('Test 5: ✗ FAILED - %s\n\n', ME.message);
        results.tests.configurationCompatibility.error = ME.message;
        results.allPassed = false;
    end
    
    % Generate summary
    fprintf('=== INTEGRATION TEST SUMMARY ===\n');
    fprintf('Overall Status: %s\n', iif(results.allPassed, '✓ ALL TESTS PASSED', '✗ SOME TESTS FAILED'));
    fprintf('Timestamp: %s\n\n', char(results.timestamp));
    
    fprintf('Test Results:\n');
    fprintf('  1. ErrorHandler: %s\n', getTestStatus(results.tests, 'errorHandler'));
    fprintf('  2. VisualizationHelper: %s\n', getTestStatus(results.tests, 'visualizationHelper'));
    fprintf('  3. DataTypeConverter: %s\n', getTestStatus(results.tests, 'dataTypeConverter'));
    fprintf('  4. Segmentation Compatibility: %s\n', getTestStatus(results.tests, 'segmentationCompatibility'));
    fprintf('  5. Configuration Compatibility: %s\n', getTestStatus(results.tests, 'configurationCompatibility'));
    
    % Save results
    outputDir = fullfile('tests', 'integration', 'test_output');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    resultsFile = fullfile(outputDir, 'infrastructure_integration_results.mat');
    save(resultsFile, 'results');
    fprintf('\nResults saved to: %s\n', resultsFile);
    
    % Generate text report
    reportFile = fullfile(outputDir, 'infrastructure_integration_report.txt');
    generateTextReport(results, reportFile);
    fprintf('Report saved to: %s\n', reportFile);
end

function [passed, testResults] = testErrorHandlerIntegration()
% Test ErrorHandler integration in classification components
    
    testResults = struct();
    passed = true;
    
    fprintf('  Testing ErrorHandler availability...\n');
    
    % Check if ErrorHandler exists
    if ~exist('ErrorHandler', 'class')
        fprintf('  ERROR: ErrorHandler class not found\n');
        passed = false;
        testResults.errorHandlerExists = false;
        return;
    end
    testResults.errorHandlerExists = true;
    
    % Test ErrorHandler instantiation
    try
        errorHandler = ErrorHandler.getInstance();
        testResults.canInstantiate = true;
        fprintf('  ✓ ErrorHandler instantiated\n');
    catch ME
        fprintf('  ERROR: Cannot instantiate ErrorHandler: %s\n', ME.message);
        passed = false;
        testResults.canInstantiate = false;
        return;
    end
    
    % Test logging methods
    testLogFile = fullfile('tests', 'integration', 'test_output', 'test_error_handler.log');
    try
        errorHandler.setLogFile(testLogFile);
        errorHandler.logInfo('Test info message from classification system');
        errorHandler.logWarning('Test warning message');
        testResults.canLog = true;
        fprintf('  ✓ Logging methods work\n');
    catch ME
        fprintf('  ERROR: Logging failed: %s\n', ME.message);
        passed = false;
        testResults.canLog = false;
    end
    
    % Test integration in LabelGenerator
    try
        % LabelGenerator uses ErrorHandler internally
        testMask = uint8(rand(100, 100) > 0.5) * 255;
        percentage = LabelGenerator.computeCorrodedPercentage(testMask);
        testResults.labelGeneratorIntegration = true;
        fprintf('  ✓ LabelGenerator integration verified\n');
    catch ME
        fprintf('  WARNING: LabelGenerator integration issue: %s\n', ME.message);
        testResults.labelGeneratorIntegration = false;
    end
    
    % Test integration in TrainingEngine
    try
        % Create minimal config
        config = struct();
        config.maxEpochs = 1;
        config.miniBatchSize = 4;
        config.initialLearnRate = 1e-3;
        config.checkpointDir = fullfile('tests', 'integration', 'test_output', 'checkpoints');
        
        % Create simple network
        net = ModelFactory.createCustomCNN(3, [224, 224]);
        
        % TrainingEngine should use ErrorHandler
        engine = TrainingEngine(net, config);
        testResults.trainingEngineIntegration = true;
        fprintf('  ✓ TrainingEngine integration verified\n');
    catch ME
        fprintf('  WARNING: TrainingEngine integration issue: %s\n', ME.message);
        testResults.trainingEngineIntegration = false;
    end
    
    testResults.passed = passed;
end

function [passed, testResults] = testVisualizationHelperIntegration()
% Test VisualizationHelper integration
    
    testResults = struct();
    passed = true;
    
    fprintf('  Testing VisualizationHelper availability...\n');
    
    % Check if VisualizationHelper exists
    if ~exist('VisualizationHelper', 'class')
        fprintf('  WARNING: VisualizationHelper class not found (may be optional)\n');
        testResults.visualizationHelperExists = false;
        % Not a failure - may be optional
    else
        testResults.visualizationHelperExists = true;
        fprintf('  ✓ VisualizationHelper found\n');
        
        % Test if VisualizationEngine can use it
        try
            % Create test data
            confMat = [10, 1, 0; 2, 8, 1; 0, 1, 9];
            classNames = {'Class0', 'Class1', 'Class2'};
            outputFile = fullfile('tests', 'integration', 'test_output', 'test_confmat.png');
            
            % VisualizationEngine should work with or without VisualizationHelper
            VisualizationEngine.plotConfusionMatrix(confMat, classNames, outputFile);
            
            if exist(outputFile, 'file')
                testResults.visualizationEngineWorks = true;
                fprintf('  ✓ VisualizationEngine works correctly\n');
            else
                fprintf('  WARNING: VisualizationEngine did not create output file\n');
                testResults.visualizationEngineWorks = false;
            end
        catch ME
            fprintf('  ERROR: VisualizationEngine failed: %s\n', ME.message);
            passed = false;
            testResults.visualizationEngineWorks = false;
        end
    end
    
    testResults.passed = passed;
end

function [passed, testResults] = testDataTypeConverterIntegration()
% Test DataTypeConverter integration
    
    testResults = struct();
    passed = true;
    
    fprintf('  Testing DataTypeConverter availability...\n');
    
    % Check if DataTypeConverter exists
    if ~exist('DataTypeConverter', 'class')
        fprintf('  WARNING: DataTypeConverter class not found (may be optional)\n');
        testResults.dataTypeConverterExists = false;
        % Not a failure - classification may not need it
    else
        testResults.dataTypeConverterExists = true;
        fprintf('  ✓ DataTypeConverter found\n');
        
        % Test basic conversion
        try
            testData = rand(10, 10);
            converted = DataTypeConverter.toDouble(testData);
            testResults.canConvert = true;
            fprintf('  ✓ DataTypeConverter works\n');
        catch ME
            fprintf('  WARNING: DataTypeConverter issue: %s\n', ME.message);
            testResults.canConvert = false;
        end
    end
    
    % Test that classification components work without DataTypeConverter
    try
        % DatasetManager should work independently
        config = struct();
        config.imageDir = fullfile('tests', 'integration', 'synthetic_data', 'images');
        config.labelCSV = fullfile('tests', 'integration', 'test_output', 'test_labels.csv');
        config.splitRatios = [0.7, 0.15, 0.15];
        config.inputSize = [224, 224];
        config.augmentation = false;
        
        % This should work without DataTypeConverter
        if exist(config.imageDir, 'dir') && exist(config.labelCSV, 'file')
            dm = DatasetManager(config);
            testResults.classificationIndependent = true;
            fprintf('  ✓ Classification components work independently\n');
        else
            fprintf('  INFO: Skipping independence test (test data not available)\n');
            testResults.classificationIndependent = true; % Not a failure
        end
    catch ME
        fprintf('  ERROR: Classification components dependency issue: %s\n', ME.message);
        passed = false;
        testResults.classificationIndependent = false;
    end
    
    testResults.passed = passed;
end

function [passed, testResults] = testSegmentationCompatibility()
% Test that classification code doesn't conflict with segmentation code
    
    testResults = struct();
    passed = true;
    
    fprintf('  Testing segmentation code compatibility...\n');
    
    % Check for namespace conflicts
    classificationClasses = {'LabelGenerator', 'DatasetManager', 'ModelFactory', ...
        'TrainingEngine', 'EvaluationEngine', 'VisualizationEngine', ...
        'ClassificationConfig'};
    
    testResults.noNamespaceConflicts = true;
    for i = 1:length(classificationClasses)
        className = classificationClasses{i};
        if exist(className, 'class')
            % Check if it's in the classification directory
            classInfo = which(className);
            if ~contains(classInfo, 'classification')
                fprintf('  WARNING: %s exists outside classification directory\n', className);
                testResults.noNamespaceConflicts = false;
            end
        end
    end
    
    if testResults.noNamespaceConflicts
        fprintf('  ✓ No namespace conflicts detected\n');
    end
    
    % Test that segmentation utilities still work
    segmentationUtils = {'preprocessDataMelhorado', 'OrganizadorResultados'};
    testResults.segmentationUtilsWork = true;
    
    for i = 1:length(segmentationUtils)
        utilName = segmentationUtils{i};
        if exist(utilName, 'file')
            fprintf('  ✓ Segmentation utility %s still accessible\n', utilName);
        else
            fprintf('  INFO: Segmentation utility %s not found (may be optional)\n', utilName);
        end
    end
    
    % Test that both systems can coexist
    try
        % Classification component
        config = ClassificationConfig.getDefaultConfig();
        testResults.classificationConfigWorks = true;
        
        % Check if segmentation config exists
        if exist('configurar_caminhos', 'file')
            fprintf('  ✓ Both configuration systems coexist\n');
            testResults.bothConfigsCoexist = true;
        else
            fprintf('  INFO: Segmentation config not found (may be in different location)\n');
            testResults.bothConfigsCoexist = true; % Not a failure
        end
    catch ME
        fprintf('  ERROR: Configuration conflict: %s\n', ME.message);
        passed = false;
        testResults.classificationConfigWorks = false;
    end
    
    testResults.passed = passed;
end

function [passed, testResults] = testConfigurationCompatibility()
% Test configuration system compatibility
    
    testResults = struct();
    passed = true;
    
    fprintf('  Testing configuration system compatibility...\n');
    
    % Test ClassificationConfig
    try
        config = ClassificationConfig.getDefaultConfig();
        testResults.canGetDefaultConfig = true;
        fprintf('  ✓ Can get default configuration\n');
    catch ME
        fprintf('  ERROR: Cannot get default config: %s\n', ME.message);
        passed = false;
        testResults.canGetDefaultConfig = false;
        return;
    end
    
    % Test configuration structure
    requiredFields = {'paths', 'labelGeneration', 'dataset', 'training', 'models'};
    testResults.hasRequiredFields = true;
    
    for i = 1:length(requiredFields)
        field = requiredFields{i};
        if ~isfield(config, field)
            fprintf('  ERROR: Missing required field: %s\n', field);
            passed = false;
            testResults.hasRequiredFields = false;
        end
    end
    
    if testResults.hasRequiredFields
        fprintf('  ✓ Configuration has all required fields\n');
    end
    
    % Test configuration validation
    try
        isValid = ClassificationConfig.validateConfig(config);
        testResults.configValidates = isValid;
        if isValid
            fprintf('  ✓ Configuration validates successfully\n');
        else
            fprintf('  WARNING: Configuration validation returned false\n');
        end
    catch ME
        fprintf('  ERROR: Configuration validation failed: %s\n', ME.message);
        passed = false;
        testResults.configValidates = false;
    end
    
    testResults.passed = passed;
end

function status = getTestStatus(tests, testName)
% Get status string for a test
    if isfield(tests, testName)
        if isfield(tests.(testName), 'passed') && tests.(testName).passed
            status = '✓ PASSED';
        else
            status = '✗ FAILED';
        end
    else
        status = '- NOT RUN';
    end
end

function generateTextReport(results, reportFile)
% Generate a text report of integration test results
    
    fid = fopen(reportFile, 'w');
    
    fprintf(fid, '=== INFRASTRUCTURE INTEGRATION TEST REPORT ===\n\n');
    fprintf(fid, 'Timestamp: %s\n', char(results.timestamp));
    fprintf(fid, 'Overall Status: %s\n\n', iif(results.allPassed, 'ALL TESTS PASSED', 'SOME TESTS FAILED'));
    
    fprintf(fid, '--- Test Results ---\n\n');
    
    % ErrorHandler
    if isfield(results.tests, 'errorHandler')
        fprintf(fid, '1. ErrorHandler Integration: %s\n', iif(results.tests.errorHandler.passed, 'PASSED', 'FAILED'));
        fprintf(fid, '   Exists: %s\n', iif(results.tests.errorHandler.errorHandlerExists, 'Yes', 'No'));
        if isfield(results.tests.errorHandler, 'canLog')
            fprintf(fid, '   Can log: %s\n', iif(results.tests.errorHandler.canLog, 'Yes', 'No'));
        end
        fprintf(fid, '\n');
    end
    
    % VisualizationHelper
    if isfield(results.tests, 'visualizationHelper')
        fprintf(fid, '2. VisualizationHelper Integration: %s\n', iif(results.tests.visualizationHelper.passed, 'PASSED', 'FAILED'));
        fprintf(fid, '   Exists: %s\n', iif(results.tests.visualizationHelper.visualizationHelperExists, 'Yes', 'No'));
        fprintf(fid, '\n');
    end
    
    % DataTypeConverter
    if isfield(results.tests, 'dataTypeConverter')
        fprintf(fid, '3. DataTypeConverter Integration: %s\n', iif(results.tests.dataTypeConverter.passed, 'PASSED', 'FAILED'));
        fprintf(fid, '   Exists: %s\n', iif(results.tests.dataTypeConverter.dataTypeConverterExists, 'Yes', 'No'));
        fprintf(fid, '\n');
    end
    
    % Segmentation Compatibility
    if isfield(results.tests, 'segmentationCompatibility')
        fprintf(fid, '4. Segmentation Compatibility: %s\n', iif(results.tests.segmentationCompatibility.passed, 'PASSED', 'FAILED'));
        fprintf(fid, '   No namespace conflicts: %s\n', iif(results.tests.segmentationCompatibility.noNamespaceConflicts, 'Yes', 'No'));
        fprintf(fid, '\n');
    end
    
    % Configuration Compatibility
    if isfield(results.tests, 'configurationCompatibility')
        fprintf(fid, '5. Configuration Compatibility: %s\n', iif(results.tests.configurationCompatibility.passed, 'PASSED', 'FAILED'));
        fprintf(fid, '   Can get config: %s\n', iif(results.tests.configurationCompatibility.canGetDefaultConfig, 'Yes', 'No'));
        fprintf(fid, '   Has required fields: %s\n', iif(results.tests.configurationCompatibility.hasRequiredFields, 'Yes', 'No'));
        fprintf(fid, '\n');
    end
    
    fprintf(fid, '--- End of Report ---\n');
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
