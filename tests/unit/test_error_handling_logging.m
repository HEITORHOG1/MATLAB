function test_error_handling_logging()
    % Test comprehensive error handling and logging system
    % Tests Requirements: 3.3, 3.4, 6.1
    
    fprintf('\n=== Testing Error Handling and Logging System ===\n');
    
    % Initialize error handler
    errorHandler = ErrorHandler.getInstance();
    errorHandler.setLogLevel(ErrorHandler.LOG_LEVEL_DEBUG);
    errorHandler.enableConsole(true);
    
    % Clear any existing log buffer
    errorHandler.clearLogBuffer();
    
    % Test 1: Categorical conversion logging
    fprintf('\n--- Test 1: Categorical Conversion Logging ---\n');
    test_categorical_conversion_logging(errorHandler);
    
    % Test 2: Data inconsistency warnings
    fprintf('\n--- Test 2: Data Inconsistency Warnings ---\n');
    test_data_inconsistency_warnings(errorHandler);
    
    % Test 3: Fallback mechanisms
    fprintf('\n--- Test 3: Fallback Mechanisms ---\n');
    test_fallback_mechanisms(errorHandler);
    
    % Test 4: Debugging output
    fprintf('\n--- Test 4: Debugging Output ---\n');
    test_debugging_output(errorHandler);
    
    % Test 5: Comprehensive validation
    fprintf('\n--- Test 5: Comprehensive Validation ---\n');
    test_comprehensive_validation(errorHandler);
    
    % Generate diagnostic report
    fprintf('\n--- Diagnostic Report ---\n');
    report = errorHandler.generateDiagnosticReport();
    display_report(report);
    
    % Export logs for analysis
    logFile = 'test_error_handling_logs.txt';
    errorHandler.exportLogs(logFile);
    fprintf('Logs exported to: %s\n', logFile);
    
    fprintf('\n=== Error Handling and Logging Tests Complete ===\n');
end

function test_categorical_conversion_logging(errorHandler)
    % Test detailed logging for categorical conversions
    
    try
        % Create test categorical data with standard structure
        testData = categorical([0, 1, 0, 1, 1], [0, 1], ["background", "foreground"]);
        
        % Test successful conversion
        fprintf('Testing successful categorical conversion...\n');
        result = DataTypeConverter.categoricalToNumeric(testData, 'double');
        
        % Test conversion with non-standard categories
        fprintf('Testing conversion with non-standard categories...\n');
        nonStandardData = categorical([0, 1, 0, 1], [0, 1], ["class0", "class1"]);
        try
            result2 = DataTypeConverter.categoricalToNumeric(nonStandardData, 'uint8');
        catch ME
            fprintf('Expected error for non-standard categories: %s\n', ME.message);
        end
        
        % Test failed conversion (invalid target type)
        fprintf('Testing failed conversion with invalid target type...\n');
        try
            result3 = DataTypeConverter.categoricalToNumeric(testData, 'invalid_type');
        catch ME
            fprintf('Expected error for invalid target type: %s\n', ME.message);
        end
        
    catch ME
        fprintf('Error in categorical conversion logging test: %s\n', ME.message);
    end
end

function test_data_inconsistency_warnings(errorHandler)
    % Test warnings for detected data inconsistencies
    
    try
        % Test image validation with inconsistent data
        fprintf('Testing image validation with inconsistent data...\n');
        
        % Test with data outside expected range
        badImage = rand(100, 100) * 300; % Values > 1 for double
        try
            PreprocessingValidator.validateImageData(badImage);
        catch ME
            fprintf('Expected validation error: %s\n', ME.message);
        end
        
        % Test with NaN values
        nanImage = rand(50, 50);
        nanImage(25, 25) = NaN;
        try
            PreprocessingValidator.validateImageData(nanImage);
        catch ME
            fprintf('Expected NaN error: %s\n', ME.message);
        end
        
        % Test mask validation with inconsistent categorical
        fprintf('Testing mask validation with inconsistent categorical...\n');
        inconsistentMask = categorical([1, 2, 3, 1, 2], [1, 2, 3], ["bg", "fg", "other"]);
        try
            PreprocessingValidator.validateMaskData(inconsistentMask);
        catch ME
            fprintf('Expected categorical structure error: %s\n', ME.message);
        end
        
    catch ME
        fprintf('Error in data inconsistency test: %s\n', ME.message);
    end
end

function test_fallback_mechanisms(errorHandler)
    % Test fallback mechanisms for critical operations
    
    try
        fprintf('Testing fallback mechanisms...\n');
        
        % Test safe conversion with fallback
        problematicData = categorical([1, 2, 1, 2], [1, 2], ["a", "b"]);
        
        % This should trigger fallback mechanism
        try
            result = DataTypeConverter.safeConversion(problematicData, 'double', 'test_fallback');
            fprintf('Fallback conversion result range: [%.3f, %.3f]\n', min(result(:)), max(result(:)));
        catch ME
            fprintf('Fallback also failed: %s\n', ME.message);
        end
        
        % Test visualization fallback
        fprintf('Testing visualization fallback...\n');
        testImage = rand(50, 50);
        success = VisualizationHelper.safeImshow(testImage);
        fprintf('Visualization success: %s\n', mat2str(success));
        close all; % Close any figures created
        
    catch ME
        fprintf('Error in fallback mechanism test: %s\n', ME.message);
    end
end

function test_debugging_output(errorHandler)
    % Test debugging output for troubleshooting categorical issues
    
    try
        fprintf('Testing debugging output...\n');
        
        % Create various categorical data scenarios
        scenarios = {
            categorical([0, 1, 0, 1], [0, 1], ["background", "foreground"]), 'Standard binary';
            categorical([1, 2, 1, 2], [1, 2], ["bg", "fg"]), 'Non-standard names';
            categorical([0, 1, 2, 0, 1], [0, 1, 2], ["bg", "fg", "other"]), 'Multi-class';
            categorical([true, false, true], [false, true], ["no", "yes"]), 'Logical-based'
        };
        
        for i = 1:size(scenarios, 1)
            data = scenarios{i, 1};
            description = scenarios{i, 2};
            
            fprintf('\nDebugging scenario: %s\n', description);
            errorHandler.debugCategoricalIssue(sprintf('test_scenario_%d', i), data, 'double');
        end
        
    catch ME
        fprintf('Error in debugging output test: %s\n', ME.message);
    end
end

function test_comprehensive_validation(errorHandler)
    % Test comprehensive result validation
    
    try
        fprintf('Testing comprehensive validation...\n');
        
        % Create mock metrics with various issues
        metrics = struct();
        
        % Perfect metrics (should trigger warnings)
        metrics.iou = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(1, 10));
        metrics.dice = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(1, 10));
        metrics.accuracy = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(1, 10));
        
        % Test validation
        isValid = MetricsValidator.validateMetrics(metrics);
        fprintf('Perfect metrics validation result: %s\n', mat2str(isValid));
        
        % Test with realistic metrics
        realisticMetrics = struct();
        realisticMetrics.iou = struct('mean', 0.75, 'std', 0.05, 'values', 0.7 + 0.1*rand(1, 10));
        realisticMetrics.dice = struct('mean', 0.82, 'std', 0.04, 'values', 0.78 + 0.08*rand(1, 10));
        realisticMetrics.accuracy = struct('mean', 0.91, 'std', 0.02, 'values', 0.89 + 0.04*rand(1, 10));
        
        isValidRealistic = MetricsValidator.validateMetrics(realisticMetrics);
        fprintf('Realistic metrics validation result: %s\n', mat2str(isValidRealistic));
        
        % Test comprehensive validation with mock data
        mockVisualizations = struct('comparisonImage', rand(100, 100));
        mockCategoricalData = struct();
        mockCategoricalData.groundTruth = categorical([0, 1, 0, 1], [0, 1], ["background", "foreground"]);
        mockCategoricalData.predictions = categorical([0, 1, 1, 1], [0, 1], ["background", "foreground"]);
        
        report = MetricsValidator.validateComprehensiveResults(realisticMetrics, mockVisualizations, mockCategoricalData);
        
    catch ME
        fprintf('Error in comprehensive validation test: %s\n', ME.message);
    end
end

function display_report(report)
    % Display diagnostic report
    
    fprintf('Diagnostic Report Summary:\n');
    fprintf('  Timestamp: %s\n', report.timestamp);
    fprintf('  Total log entries: %d\n', report.totalLogEntries);
    fprintf('  Conversion success rate: %.1f%%\n', report.conversionSuccessRate * 100);
    fprintf('  Failed conversions: %d\n', report.failedConversions);
    fprintf('  Failure rate: %.1f%%\n', report.failureRate * 100);
    
    if isfield(report, 'recommendations') && ~isempty(report.recommendations)
        fprintf('  Recommendations:\n');
        for i = 1:length(report.recommendations)
            fprintf('    %d. %s\n', i, report.recommendations{i});
        end
    end
end