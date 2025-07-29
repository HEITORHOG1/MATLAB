function test_comprehensive_validation()
    % Test comprehensive result validation functionality
    % Tests requirements 6.1, 6.2, 6.3, 6.4
    
    fprintf('Testing comprehensive result validation...\n');
    
    % Test 1: Realistic metric ranges validation
    test_realistic_metric_ranges();
    
    % Test 2: Perfect metrics detection
    test_perfect_metrics_detection();
    
    % Test 3: Visualization quality validation
    test_visualization_quality_validation();
    
    % Test 4: Comprehensive categorical debugging
    test_comprehensive_categorical_debugging();
    
    % Test 5: Full comprehensive validation
    test_full_comprehensive_validation();
    
    fprintf('All comprehensive validation tests passed!\n');
end

function test_realistic_metric_ranges()
    fprintf('  Testing realistic metric ranges validation...\n');
    
    % Create test report structure
    report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
    
    % Test case 1: Normal realistic metrics
    metrics_normal = struct();
    metrics_normal.iou = struct('mean', 0.75, 'std', 0.05, 'values', [0.70, 0.75, 0.80, 0.72, 0.78]);
    metrics_normal.dice = struct('mean', 0.80, 'std', 0.04, 'values', [0.78, 0.82, 0.79, 0.81, 0.80]);
    metrics_normal.accuracy = struct('mean', 0.85, 'std', 0.03, 'values', [0.83, 0.87, 0.84, 0.86, 0.85]);
    
    report = MetricsValidator.validateRealisticMetricRanges(metrics_normal, report);
    
    % Should have minimal warnings for normal metrics
    assert(length(report.warnings) <= 1, 'Normal metrics should not generate many warnings');
    
    % Test case 2: Unrealistically high metrics
    report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
    metrics_high = struct();
    metrics_high.iou = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(5,1));
    metrics_high.dice = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(5,1));
    metrics_high.accuracy = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(5,1));
    
    report = MetricsValidator.validateRealisticMetricRanges(metrics_high, report);
    
    % Debug: show what was generated
    fprintf('    Generated %d warnings, %d errors\n', length(report.warnings), length(report.errors));
    
    % Should generate warnings for unrealistic metrics
    assert(length(report.warnings) >= 1, 'High metrics should generate warnings');
    assert(length(report.errors) >= 1, 'Perfect metrics should generate errors');
    
    % Test case 3: Unrealistically low metrics
    report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
    metrics_low = struct();
    metrics_low.iou = struct('mean', 0.15, 'std', 0.02, 'values', ones(5,1)*0.15);
    metrics_low.dice = struct('mean', 0.20, 'std', 0.03, 'values', ones(5,1)*0.20);
    metrics_low.accuracy = struct('mean', 0.50, 'std', 0.05, 'values', ones(5,1)*0.50);
    
    report = MetricsValidator.validateRealisticMetricRanges(metrics_low, report);
    
    % Should generate warnings for low metrics
    assert(length(report.warnings) >= 3, 'Low metrics should generate warnings');
    
    fprintf('    Realistic metric ranges validation passed\n');
end

function test_perfect_metrics_detection()
    fprintf('  Testing perfect metrics detection...\n');
    
    % Create artificially perfect metrics
    perfect_iou = ones(10, 1);
    perfect_dice = ones(10, 1);
    perfect_accuracy = ones(10, 1);
    
    warnings = MetricsValidator.checkPerfectMetrics(perfect_iou, perfect_dice, perfect_accuracy);
    
    % Should detect multiple issues
    assert(length(warnings) >= 6, 'Should detect perfect values and low std for all metrics');
    
    % Check specific warning types
    perfect_warnings = contains(warnings, 'artificially perfect');
    std_warnings = contains(warnings, 'standard deviation');
    identical_warnings = contains(warnings, 'identical');
    
    assert(sum(perfect_warnings) >= 3, 'Should detect perfect values for all metrics');
    assert(sum(std_warnings) >= 3, 'Should detect low std for all metrics');
    assert(sum(identical_warnings) >= 3, 'Should detect identical values for all metrics');
    
    fprintf('    Perfect metrics detection passed\n');
end

function test_visualization_quality_validation()
    fprintf('  Testing visualization quality validation...\n');
    
    % Test case 1: Valid visualization
    report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
    
    % Create test image
    test_img = uint8(rand(100, 100, 3) * 255);
    visualizations = struct('comparisonImage', test_img);
    
    report = MetricsValidator.validateVisualizationQuality(visualizations, report);
    
    % Should pass with minimal issues
    assert(length(report.errors) == 0, 'Valid image should not generate errors');
    
    % Test case 2: Invalid visualization - uniform values
    report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
    uniform_img = ones(50, 50) * 128;
    visualizations = struct('comparisonImage', uniform_img);
    
    report = MetricsValidator.validateVisualizationQuality(visualizations, report);
    
    % Should detect uniform values
    assert(length(report.errors) >= 1, 'Uniform image should generate error');
    uniform_error = contains(report.errors, 'uniform values');
    assert(any(uniform_error), 'Should detect uniform values error');
    
    % Test case 3: Invalid visualization - NaN values
    report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
    nan_img = rand(50, 50);
    nan_img(1:10, 1:10) = NaN;
    visualizations = struct('comparisonImage', nan_img);
    
    report = MetricsValidator.validateVisualizationQuality(visualizations, report);
    
    % Should detect NaN values
    assert(length(report.errors) >= 1, 'NaN image should generate error');
    nan_error = contains(report.errors, 'NaN');
    assert(any(nan_error), 'Should detect NaN values error');
    
    fprintf('    Visualization quality validation passed\n');
end

function test_comprehensive_categorical_debugging()
    fprintf('  Testing comprehensive categorical debugging...\n');
    
    % Create test categorical data
    report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
    
    % Standard binary categorical
    standard_cat = categorical([0; 1; 0; 1; 1], [0, 1], ["background", "foreground"]);
    
    % Non-standard categorical
    nonstandard_cat = categorical([1; 2; 1; 2; 2], [1, 2], ["class1", "class2"]);
    
    categoricalData = struct();
    categoricalData.groundTruth = standard_cat;
    categoricalData.predictions = nonstandard_cat;
    
    % Test comprehensive debugging
    report = MetricsValidator.debugCategoricalDataComprehensive(categoricalData, report);
    
    % Should generate warnings for non-standard categorical
    assert(length(report.warnings) >= 1, 'Should detect non-standard categorical');
    
    % Check for conversion method comparison warnings
    conversion_warnings = contains(report.warnings, 'conversion methods');
    if any(conversion_warnings)
        fprintf('    Detected conversion method differences (expected)\n');
    end
    
    fprintf('    Comprehensive categorical debugging passed\n');
end

function test_full_comprehensive_validation()
    fprintf('  Testing full comprehensive validation...\n');
    
    % Create comprehensive test data
    
    % Metrics with issues
    metrics = struct();
    metrics.iou = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(5,1));
    metrics.dice = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(5,1));
    metrics.accuracy = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(5,1));
    
    % Visualization with issues
    uniform_img = ones(50, 50) * 128;
    visualizations = struct('comparisonImage', uniform_img);
    
    % Categorical data with issues
    problematic_cat = categorical([1; 2; 1; 2; 2], [1, 2], ["class1", "class2"]);
    categoricalData = struct('predictions', problematic_cat);
    
    % Run comprehensive validation
    report = MetricsValidator.validateComprehensiveResults(metrics, visualizations, categoricalData);
    
    % Should detect multiple issues
    assert(~report.overallValid, 'Should detect overall validation failure');
    assert(length(report.warnings) >= 3, 'Should generate multiple warnings');
    assert(length(report.errors) >= 3, 'Should generate multiple errors');
    assert(length(report.recommendations) >= 1, 'Should provide recommendations');
    
    % Check that report contains expected fields
    assert(isfield(report, 'timestamp'), 'Report should have timestamp');
    assert(isfield(report, 'overallValid'), 'Report should have overall validity');
    assert(isfield(report, 'metricsValid'), 'Report should have metrics validity');
    
    fprintf('    Full comprehensive validation passed\n');
end