function demo_comprehensive_validation()
    % Demo script for comprehensive result validation functionality
    % Shows how to use MetricsValidator for complete system validation
    % 
    % This demo addresses requirements:
    % - 6.1: Validate realistic metric ranges
    % - 6.2: Detect artificially perfect metrics
    % - 6.3: Validate visualization quality
    % - 6.4: Debug categorical data issues
    
    fprintf('=== MetricsValidator Comprehensive Validation Demo ===\n\n');
    
    % Demo 1: Basic metrics validation
    demo_basic_metrics_validation();
    
    % Demo 2: Perfect metrics detection
    demo_perfect_metrics_detection();
    
    % Demo 3: Visualization quality validation
    demo_visualization_validation();
    
    % Demo 4: Categorical data debugging
    demo_categorical_debugging();
    
    % Demo 5: Complete comprehensive validation
    demo_complete_validation();
    
    fprintf('\n=== Demo completed successfully! ===\n');
end

function demo_basic_metrics_validation()
    fprintf('--- Demo 1: Basic Metrics Validation ---\n');
    
    % Create sample metrics with different quality levels
    
    % Good metrics (realistic)
    good_metrics = struct();
    good_metrics.iou = struct('mean', 0.75, 'std', 0.08);
    good_metrics.dice = struct('mean', 0.82, 'std', 0.06);
    good_metrics.accuracy = struct('mean', 0.88, 'std', 0.04);
    
    fprintf('Testing good metrics:\n');
    isValid = MetricsValidator.validateMetrics(good_metrics);
    fprintf('  Result: %s\n', mat2str(isValid));
    
    % Poor metrics (unrealistically low)
    poor_metrics = struct();
    poor_metrics.iou = struct('mean', 0.15, 'std', 0.02);
    poor_metrics.dice = struct('mean', 0.25, 'std', 0.03);
    poor_metrics.accuracy = struct('mean', 0.45, 'std', 0.05);
    
    fprintf('\nTesting poor metrics:\n');
    isValid = MetricsValidator.validateMetrics(poor_metrics);
    fprintf('  Result: %s\n', mat2str(isValid));
    
    % Perfect metrics (suspicious)
    perfect_metrics = struct();
    perfect_metrics.iou = struct('mean', 1.0000, 'std', 0.0000);
    perfect_metrics.dice = struct('mean', 1.0000, 'std', 0.0000);
    perfect_metrics.accuracy = struct('mean', 1.0000, 'std', 0.0000);
    
    fprintf('\nTesting perfect metrics (suspicious):\n');
    isValid = MetricsValidator.validateMetrics(perfect_metrics);
    fprintf('  Result: %s\n', mat2str(isValid));
    
    fprintf('\n');
end

function demo_perfect_metrics_detection()
    fprintf('--- Demo 2: Perfect Metrics Detection ---\n');
    
    % Create arrays of metric values
    
    % Realistic metrics with natural variation
    realistic_iou = [0.72, 0.68, 0.75, 0.71, 0.73, 0.69, 0.74, 0.70];
    realistic_dice = [0.81, 0.78, 0.83, 0.80, 0.82, 0.79, 0.84, 0.81];
    realistic_accuracy = [0.87, 0.85, 0.89, 0.86, 0.88, 0.84, 0.90, 0.87];
    
    fprintf('Testing realistic metrics:\n');
    warnings = MetricsValidator.checkPerfectMetrics(realistic_iou, realistic_dice, realistic_accuracy);
    fprintf('  Warnings found: %d\n', length(warnings));
    for i = 1:length(warnings)
        fprintf('    %s\n', warnings{i});
    end
    
    % Perfect metrics (indicating calculation error)
    perfect_iou = ones(1, 8);
    perfect_dice = ones(1, 8);
    perfect_accuracy = ones(1, 8);
    
    fprintf('\nTesting perfect metrics:\n');
    warnings = MetricsValidator.checkPerfectMetrics(perfect_iou, perfect_dice, perfect_accuracy);
    fprintf('  Warnings found: %d\n', length(warnings));
    for i = 1:min(3, length(warnings)) % Show first 3 warnings
        fprintf('    %s\n', warnings{i});
    end
    if length(warnings) > 3
        fprintf('    ... and %d more warnings\n', length(warnings) - 3);
    end
    
    fprintf('\n');
end

function demo_visualization_validation()
    fprintf('--- Demo 3: Visualization Quality Validation ---\n');
    
    % Create test report structure
    report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
    
    % Test 1: Good visualization
    fprintf('Testing good visualization:\n');
    good_img = uint8(rand(150, 400, 3) * 255); % Random colorful image
    good_viz = struct('comparisonImage', good_img);
    
    MetricsValidator.validateVisualizationQuality(good_viz, report);
    fprintf('  Errors: %d, Warnings: %d\n', length(report.errors), length(report.warnings));
    
    % Test 2: Problematic visualization (uniform)
    fprintf('\nTesting problematic visualization (uniform):\n');
    report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
    uniform_img = ones(100, 300) * 128; % Uniform gray image
    bad_viz = struct('comparisonImage', uniform_img);
    
    MetricsValidator.validateVisualizationQuality(bad_viz, report);
    fprintf('  Errors: %d, Warnings: %d\n', length(report.errors), length(report.warnings));
    if ~isempty(report.errors)
        fprintf('    Error: %s\n', report.errors{1});
    end
    
    % Test 3: Visualization with NaN values
    fprintf('\nTesting visualization with NaN values:\n');
    report = struct('warnings', {{}}, 'errors', {{}}, 'recommendations', {{}});
    nan_img = rand(80, 200);
    nan_img(1:20, 1:50) = NaN; % Add NaN region
    nan_viz = struct('comparisonImage', nan_img);
    
    MetricsValidator.validateVisualizationQuality(nan_viz, report);
    fprintf('  Errors: %d, Warnings: %d\n', length(report.errors), length(report.warnings));
    if ~isempty(report.errors)
        fprintf('    Error: %s\n', report.errors{1});
    end
    
    fprintf('\n');
end

function demo_categorical_debugging()
    fprintf('--- Demo 4: Categorical Data Debugging ---\n');
    
    % Create different types of categorical data
    
    % Standard binary segmentation categorical
    fprintf('Standard binary categorical:\n');
    standard_cat = categorical([0; 1; 0; 1; 1; 0; 1; 0], [0, 1], ["background", "foreground"]);
    MetricsValidator.debugCategoricalData(standard_cat, 'Standard Binary');
    
    % Non-standard categorical
    fprintf('Non-standard categorical:\n');
    nonstandard_cat = categorical([1; 2; 1; 2; 2; 1], [1, 2], ["class_a", "class_b"]);
    MetricsValidator.debugCategoricalData(nonstandard_cat, 'Non-standard');
    
    % Multi-class categorical
    fprintf('Multi-class categorical:\n');
    multiclass_cat = categorical([1; 2; 3; 1; 2; 3; 2], [1, 2, 3], ["bg", "obj1", "obj2"]);
    MetricsValidator.debugCategoricalData(multiclass_cat, 'Multi-class');
    
    % Test categorical structure validation
    fprintf('Validating categorical structure:\n');
    validated = MetricsValidator.validateCategoricalStructure(standard_cat);
    fprintf('  Is valid: %s\n', mat2str(validated.isValid));
    fprintf('  Is standard binary: %s\n', mat2str(validated.debugInfo.isStandardBinary));
    fprintf('  Warnings: %d\n', length(validated.warnings));
    
    fprintf('\n');
end

function demo_complete_validation()
    fprintf('--- Demo 5: Complete Comprehensive Validation ---\n');
    
    % Create a complete test scenario
    
    % Metrics with issues (perfect scores)
    problematic_metrics = struct();
    problematic_metrics.iou = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(10,1));
    problematic_metrics.dice = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(10,1));
    problematic_metrics.accuracy = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(10,1));
    
    % Visualization with issues (uniform)
    problematic_img = ones(100, 300) * 200;
    problematic_viz = struct('comparisonImage', uint8(problematic_img));
    
    % Categorical data for debugging
    cat_data = struct();
    cat_data.groundTruth = categorical([0; 1; 0; 1; 1], [0, 1], ["background", "foreground"]);
    cat_data.predictions = categorical([1; 2; 1; 2; 2], [1, 2], ["neg", "pos"]);
    
    fprintf('Running comprehensive validation on problematic data...\n');
    
    % Run comprehensive validation
    report = MetricsValidator.validateComprehensiveResults(problematic_metrics, problematic_viz, cat_data);
    
    % Display summary
    fprintf('\n--- Validation Summary ---\n');
    fprintf('Overall Valid: %s\n', mat2str(report.overallValid));
    fprintf('Total Warnings: %d\n', length(report.warnings));
    fprintf('Total Errors: %d\n', length(report.errors));
    fprintf('Total Recommendations: %d\n', length(report.recommendations));
    
    % Show some key findings
    if ~isempty(report.errors)
        fprintf('\nKey Errors Found:\n');
        for i = 1:min(3, length(report.errors))
            fprintf('  • %s\n', report.errors{i});
        end
    end
    
    if ~isempty(report.recommendations)
        fprintf('\nKey Recommendations:\n');
        for i = 1:min(3, length(report.recommendations))
            fprintf('  • %s\n', report.recommendations{i});
        end
    end
    
    fprintf('\n--- Now testing with corrected data ---\n');
    
    % Create corrected data
    corrected_metrics = struct();
    corrected_metrics.iou = struct('mean', 0.78, 'std', 0.06, 'values', [0.72, 0.81, 0.75, 0.83, 0.76]);
    corrected_metrics.dice = struct('mean', 0.85, 'std', 0.04, 'values', [0.82, 0.88, 0.83, 0.89, 0.84]);
    corrected_metrics.accuracy = struct('mean', 0.91, 'std', 0.03, 'values', [0.89, 0.94, 0.90, 0.93, 0.91]);
    
    % Better visualization
    corrected_img = uint8(rand(100, 300, 3) * 255);
    corrected_viz = struct('comparisonImage', corrected_img);
    
    % Consistent categorical data
    corrected_cat_data = struct();
    corrected_cat_data.groundTruth = categorical([0; 1; 0; 1; 1], [0, 1], ["background", "foreground"]);
    corrected_cat_data.predictions = categorical([0; 1; 0; 0; 1], [0, 1], ["background", "foreground"]);
    
    % Run validation on corrected data
    corrected_report = MetricsValidator.validateComprehensiveResults(corrected_metrics, corrected_viz, corrected_cat_data);
    
    fprintf('Corrected Results:\n');
    fprintf('Overall Valid: %s\n', mat2str(corrected_report.overallValid));
    fprintf('Total Warnings: %d\n', length(corrected_report.warnings));
    fprintf('Total Errors: %d\n', length(corrected_report.errors));
    
    fprintf('\n');
end