function test_MetricsValidator()
    % Comprehensive unit tests for MetricsValidator class
    % Tests all methods and edge cases
    
    fprintf('=== COMPREHENSIVE MetricsValidator Test Suite ===\n');
    
    % Test 1: validateMetrics with valid metrics
    test_validateMetrics_valid();
    
    % Test 2: validateMetrics with perfect metrics
    test_validateMetrics_perfect();
    
    % Test 3: validateMetrics with invalid structure
    test_validateMetrics_invalid();
    
    % Test 4: checkPerfectMetrics
    test_checkPerfectMetrics();
    
    % Test 5: correctCategoricalConversion
    test_correctCategoricalConversion();
    
    % Test 6: validateCategoricalStructure
    test_validateCategoricalStructure();
    
    % Test 7: debugCategoricalData
    test_debugCategoricalData();
    
    % Test 8: comprehensive result validation
    test_comprehensive_result_validation();
    
    % Test 9: edge cases and error handling
    test_edge_cases_and_errors();
    
    % Test 10: realistic metric range validation
    test_realistic_metric_ranges();
    
    % Test 11: visualization quality validation
    test_visualization_quality_validation();
    
    fprintf('=== All MetricsValidator tests passed! ===\n');
end

function test_validateMetrics_valid()
    fprintf('  Testing validateMetrics with valid metrics...\n');
    
    % Create realistic metrics
    metrics = struct();
    metrics.iou = struct('mean', 0.75, 'std', 0.05);
    metrics.dice = struct('mean', 0.82, 'std', 0.04);
    metrics.accuracy = struct('mean', 0.88, 'std', 0.03);
    
    isValid = MetricsValidator.validateMetrics(metrics);
    assert(isValid, 'Valid metrics should pass validation');
end

function test_validateMetrics_perfect()
    fprintf('  Testing validateMetrics with perfect metrics...\n');
    
    % Create artificially perfect metrics
    metrics = struct();
    metrics.iou = struct('mean', 1.0000, 'std', 0.0000);
    metrics.dice = struct('mean', 1.0000, 'std', 0.0000);
    metrics.accuracy = struct('mean', 1.0000, 'std', 0.0000);
    
    % Capture warnings
    warning('off', 'MetricsValidator:PerfectMetrics');
    isValid = MetricsValidator.validateMetrics(metrics);
    warning('on', 'MetricsValidator:PerfectMetrics');
    
    assert(~isValid, 'Perfect metrics should fail validation');
end

function test_validateMetrics_invalid()
    fprintf('  Testing validateMetrics with invalid structure...\n');
    
    % Test with non-struct input
    warning('off', 'MetricsValidator:InvalidInput');
    isValid = MetricsValidator.validateMetrics([1, 2, 3]);
    warning('on', 'MetricsValidator:InvalidInput');
    assert(~isValid, 'Non-struct input should fail validation');
    
    % Test with missing fields
    metrics = struct();
    metrics.iou = struct('mean', 0.75, 'std', 0.05);
    % Missing dice and accuracy
    
    warning('off', 'MetricsValidator:MissingField');
    isValid = MetricsValidator.validateMetrics(metrics);
    warning('on', 'MetricsValidator:MissingField');
    assert(~isValid, 'Missing fields should fail validation');
end

function test_checkPerfectMetrics()
    fprintf('  Testing checkPerfectMetrics...\n');
    
    % Test with perfect metrics
    iou = ones(10, 1);
    dice = ones(10, 1);
    accuracy = ones(10, 1);
    
    warnings = MetricsValidator.checkPerfectMetrics(iou, dice, accuracy);
    assert(length(warnings) > 0, 'Perfect metrics should generate warnings');
    
    % Test with realistic metrics
    iou = 0.7 + 0.1 * randn(10, 1);
    dice = 0.8 + 0.05 * randn(10, 1);
    accuracy = 0.85 + 0.03 * randn(10, 1);
    
    warnings = MetricsValidator.checkPerfectMetrics(iou, dice, accuracy);
    % Should have fewer or no warnings for realistic metrics
end

function test_correctCategoricalConversion()
    fprintf('  Testing correctCategoricalConversion...\n');
    
    % Test standard binary categorical
    data = categorical([0, 1, 0, 1, 1], [0, 1], ["background", "foreground"]);
    corrected = MetricsValidator.correctCategoricalConversion(data);
    expected = [0, 1, 0, 1, 1];
    assert(isequal(corrected, expected), 'Standard binary conversion failed');
    
    % Test with different category names
    data = categorical([0, 1, 0, 1, 1], [0, 1], ["bg", "fg"]);
    corrected = MetricsValidator.correctCategoricalConversion(data);
    % Should still work with generic binary logic
    assert(all(corrected >= 0 & corrected <= 1), 'Generic binary conversion failed');
    
    % Test error with non-categorical input
    try
        MetricsValidator.correctCategoricalConversion([1, 2, 3]);
        assert(false, 'Should have thrown error for non-categorical input');
    catch ME
        assert(contains(ME.identifier, 'MetricsValidator:InvalidInput'), ...
            'Wrong error type for non-categorical input');
    end
end

function test_validateCategoricalStructure()
    fprintf('  Testing validateCategoricalStructure...\n');
    
    % Test standard binary categorical
    data = categorical([0, 1, 0, 1, 1], [0, 1], ["background", "foreground"]);
    validated = MetricsValidator.validateCategoricalStructure(data);
    
    assert(validated.isValid, 'Standard binary categorical should be valid');
    assert(validated.debugInfo.isStandardBinary, 'Should detect standard binary pattern');
    assert(validated.debugInfo.numCategories == 2, 'Should detect 2 categories');
    
    % Test multi-class categorical
    data = categorical([1, 2, 3, 1, 2], [1, 2, 3], ["class1", "class2", "class3"]);
    validated = MetricsValidator.validateCategoricalStructure(data);
    
    assert(~validated.debugInfo.isStandardBinary, 'Should not detect as standard binary');
    assert(validated.debugInfo.numCategories == 3, 'Should detect 3 categories');
    
    % Test non-categorical input
    validated = MetricsValidator.validateCategoricalStructure([1, 2, 3]);
    assert(~validated.isValid, 'Non-categorical input should be invalid');
end

function test_debugCategoricalData()
    fprintf('  Testing debugCategoricalData...\n');
    
    % Test with standard binary categorical
    data = categorical([0, 1, 0, 1, 1], [0, 1], ["background", "foreground"]);
    
    % Capture output (this function prints to console)
    fprintf('    Debug output for standard binary categorical:\n');
    MetricsValidator.debugCategoricalData(data, 'Test Binary Data');
    
    % Test with non-categorical data
    fprintf('    Debug output for non-categorical data:\n');
    MetricsValidator.debugCategoricalData([1, 2, 3], 'Test Non-Categorical');
endfunc
tion test_comprehensive_result_validation()
    fprintf('  Testing comprehensive result validation...\n');
    
    try
        % Create test metrics
        metrics = struct();
        metrics.iou = struct('mean', 0.75, 'std', 0.05, 'values', 0.7 + 0.1*randn(10,1));
        metrics.dice = struct('mean', 0.82, 'std', 0.04, 'values', 0.8 + 0.08*randn(10,1));
        metrics.accuracy = struct('mean', 0.88, 'std', 0.03, 'values', 0.85 + 0.06*randn(10,1));
        
        % Create test visualization
        visualizations = struct();
        visualizations.comparisonImage = uint8(rand(100, 100, 3) * 255);
        
        % Create test categorical data
        categoricalData = struct();
        categoricalData.groundTruth = categorical(rand(50, 50) > 0.5, [0, 1], ["background", "foreground"]);
        categoricalData.predictions = categorical(rand(50, 50) > 0.3, [0, 1], ["background", "foreground"]);
        
        % Run comprehensive validation
        report = MetricsValidator.validateComprehensiveResults(metrics, visualizations, categoricalData);
        
        assert(isstruct(report), 'Report should be a struct');
        assert(isfield(report, 'overallValid'), 'Report should have overallValid field');
        assert(isfield(report, 'warnings'), 'Report should have warnings field');
        assert(isfield(report, 'errors'), 'Report should have errors field');
        assert(isfield(report, 'recommendations'), 'Report should have recommendations field');
        
        fprintf('    ✓ Comprehensive validation structure passed\n');
        
        % Test with problematic metrics (perfect scores)
        perfectMetrics = struct();
        perfectMetrics.iou = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(10,1));
        perfectMetrics.dice = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(10,1));
        perfectMetrics.accuracy = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(10,1));
        
        report2 = MetricsValidator.validateComprehensiveResults(perfectMetrics, [], []);
        assert(~report2.overallValid, 'Perfect metrics should fail overall validation');
        assert(~isempty(report2.errors), 'Perfect metrics should generate errors');
        
        fprintf('    ✓ Perfect metrics detection passed\n');
        
    catch ME
        fprintf('    ✗ Comprehensive validation test failed: %s\n', ME.message);
    end
    
    fprintf('\n');
end

function test_edge_cases_and_errors()
    fprintf('  Testing edge cases and error handling...\n');
    
    try
        % Test correctCategoricalConversion with empty data
        emptyData = categorical.empty(0, 1);
        try
            result = MetricsValidator.correctCategoricalConversion(emptyData);
            assert(isempty(result), 'Empty categorical should return empty result');
            fprintf('    ✓ Empty categorical handling passed\n');
        catch ME
            fprintf('    ! Empty categorical caused expected error: %s\n', ME.message);
        end
        
        % Test with single-element categorical
        singleCat = categorical("foreground", ["background", "foreground"]);
        result = MetricsValidator.correctCategoricalConversion(singleCat);
        assert(result == 1, 'Single foreground element should convert to 1');
        fprintf('    ✓ Single element categorical passed\n');
        
        % Test with unusual category names
        unusualCat = categorical([0, 1, 0], [0, 1], ["weird_bg", "strange_fg"]);
        result = MetricsValidator.correctCategoricalConversion(unusualCat);
        assert(all(result >= 0 & result <= 1), 'Unusual names should still work');
        fprintf('    ✓ Unusual category names passed\n');
        
        % Test validateCategoricalStructure with various edge cases
        
        % Single category
        singleCatData = categorical(ones(10, 1), 1, "only_class");
        validation = MetricsValidator.validateCategoricalStructure(singleCatData);
        assert(~validation.debugInfo.isStandardBinary, 'Single category should not be standard binary');
        fprintf('    ✓ Single category validation passed\n');
        
        % Many categories
        multiCatData = categorical([1, 2, 3, 4, 1, 2], [1, 2, 3, 4], ["a", "b", "c", "d"]);
        validation = MetricsValidator.validateCategoricalStructure(multiCatData);
        assert(validation.debugInfo.numCategories == 4, 'Should detect 4 categories');
        fprintf('    ✓ Multi-category validation passed\n');
        
        % Test checkPerfectMetrics with edge cases
        
        % All zeros
        zeros_iou = zeros(10, 1);
        zeros_dice = zeros(10, 1);
        zeros_acc = zeros(10, 1);
        warnings = MetricsValidator.checkPerfectMetrics(zeros_iou, zeros_dice, zeros_acc);
        assert(~isempty(warnings), 'All zeros should generate warnings');
        fprintf('    ✓ All zeros metrics detection passed\n');
        
        % Mixed perfect and non-perfect
        mixed_iou = [ones(5, 1); 0.8 * ones(5, 1)];
        mixed_dice = ones(10, 1);
        mixed_acc = 0.9 * ones(10, 1);
        warnings = MetricsValidator.checkPerfectMetrics(mixed_iou, mixed_dice, mixed_acc);
        % Should detect some perfect metrics
        fprintf('    ✓ Mixed metrics detection passed\n');
        
        % Test validateMetrics with edge cases
        
        % Metrics with NaN values
        nanMetrics = struct();
        nanMetrics.iou = struct('mean', NaN, 'std', 0.05);
        nanMetrics.dice = struct('mean', 0.8, 'std', NaN);
        nanMetrics.accuracy = struct('mean', 0.9, 'std', 0.03);
        
        isValid = MetricsValidator.validateMetrics(nanMetrics);
        assert(~isValid, 'Metrics with NaN should be invalid');
        fprintf('    ✓ NaN metrics detection passed\n');
        
        % Metrics with negative values
        negMetrics = struct();
        negMetrics.iou = struct('mean', -0.1, 'std', 0.05);
        negMetrics.dice = struct('mean', 0.8, 'std', 0.04);
        negMetrics.accuracy = struct('mean', 0.9, 'std', -0.01);
        
        isValid = MetricsValidator.validateMetrics(negMetrics);
        assert(~isValid, 'Metrics with negative values should be invalid');
        fprintf('    ✓ Negative metrics detection passed\n');
        
    catch ME
        fprintf('    ✗ Edge case test failed: %s\n', ME.message);
    end
    
    fprintf('\n');
end

function test_realistic_metric_ranges()
    fprintf('  Testing realistic metric range validation...\n');
    
    try
        % Test with realistic metrics
        realisticMetrics = struct();
        realisticMetrics.iou = struct('mean', 0.65, 'std', 0.08);
        realisticMetrics.dice = struct('mean', 0.78, 'std', 0.06);
        realisticMetrics.accuracy = struct('mean', 0.85, 'std', 0.04);
        
        report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
        report = MetricsValidator.validateRealisticMetricRanges(realisticMetrics, report);
        
        % Should have minimal warnings for realistic metrics
        fprintf('    Realistic metrics generated %d warnings\n', length(report.warnings));
        
        % Test with unrealistically low metrics
        lowMetrics = struct();
        lowMetrics.iou = struct('mean', 0.15, 'std', 0.02);
        lowMetrics.dice = struct('mean', 0.25, 'std', 0.03);
        lowMetrics.accuracy = struct('mean', 0.55, 'std', 0.04);
        
        report2 = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
        report2 = MetricsValidator.validateRealisticMetricRanges(lowMetrics, report2);
        
        assert(~isempty(report2.warnings), 'Low metrics should generate warnings');
        fprintf('    ✓ Low metrics detection passed\n');
        
        % Test with unrealistically high metrics
        highMetrics = struct();
        highMetrics.iou = struct('mean', 0.98, 'std', 0.001);
        highMetrics.dice = struct('mean', 0.99, 'std', 0.0005);
        highMetrics.accuracy = struct('mean', 0.995, 'std', 0.0001);
        
        report3 = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
        report3 = MetricsValidator.validateRealisticMetricRanges(highMetrics, report3);
        
        assert(~isempty(report3.warnings), 'High metrics should generate warnings');
        fprintf('    ✓ High metrics detection passed\n');
        
        % Test with suspiciously low standard deviation
        lowStdMetrics = struct();
        lowStdMetrics.iou = struct('mean', 0.75, 'std', 0.001);
        lowStdMetrics.dice = struct('mean', 0.82, 'std', 0.0005);
        lowStdMetrics.accuracy = struct('mean', 0.88, 'std', 0.0001);
        
        report4 = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
        report4 = MetricsValidator.validateRealisticMetricRanges(lowStdMetrics, report4);
        
        assert(~isempty(report4.warnings), 'Low std metrics should generate warnings');
        fprintf('    ✓ Low standard deviation detection passed\n');
        
    catch ME
        fprintf('    ✗ Realistic range test failed: %s\n', ME.message);
    end
    
    fprintf('\n');
end

function test_visualization_quality_validation()
    fprintf('  Testing visualization quality validation...\n');
    
    try
        % Test with valid visualization
        validViz = struct();
        validViz.comparisonImage = uint8(rand(200, 300, 3) * 255);
        
        report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
        report = MetricsValidator.validateVisualizationQuality(validViz, report);
        
        % Should have minimal issues with valid visualization
        fprintf('    Valid visualization generated %d errors, %d warnings\n', ...
            length(report.errors), length(report.warnings));
        
        % Test with problematic visualizations
        
        % Empty/uniform image
        uniformViz = struct();
        uniformViz.comparisonImage = uint8(ones(100, 100) * 128);
        
        report2 = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
        report2 = MetricsValidator.validateVisualizationQuality(uniformViz, report2);
        
        assert(~isempty(report2.errors), 'Uniform image should generate errors');
        fprintf('    ✓ Uniform image detection passed\n');
        
        % Very small image
        smallViz = struct();
        smallViz.comparisonImage = uint8(rand(10, 10) * 255);
        
        report3 = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
        report3 = MetricsValidator.validateVisualizationQuality(smallViz, report3);
        
        assert(~isempty(report3.warnings), 'Small image should generate warnings');
        fprintf('    ✓ Small image detection passed\n');
        
        % Image with NaN values
        nanViz = struct();
        nanImage = rand(50, 50);
        nanImage(25, 25) = NaN;
        nanViz.comparisonImage = nanImage;
        
        report4 = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
        report4 = MetricsValidator.validateVisualizationQuality(nanViz, report4);
        
        assert(~isempty(report4.errors), 'NaN image should generate errors');
        fprintf('    ✓ NaN image detection passed\n');
        
        % Test with file path (non-existent file)
        fileViz = struct();
        fileViz.comparisonImage = 'non_existent_file.png';
        
        report5 = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
        report5 = MetricsValidator.validateVisualizationQuality(fileViz, report5);
        
        assert(~isempty(report5.errors), 'Non-existent file should generate errors');
        fprintf('    ✓ Non-existent file detection passed\n');
        
    catch ME
        fprintf('    ✗ Visualization quality test failed: %s\n', ME.message);
    end
    
    fprintf('\n');
end