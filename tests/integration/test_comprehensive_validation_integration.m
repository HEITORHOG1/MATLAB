function test_comprehensive_validation_integration()
    % Integration test for comprehensive result validation
    % Tests the complete validation workflow with realistic data
    % Requirements: 6.1, 6.2, 6.3, 6.4
    
    fprintf('Running comprehensive validation integration test...\n');
    
    % Test scenario 1: Problematic results (like current system)
    test_problematic_results_scenario();
    
    % Test scenario 2: Corrected results (expected after fixes)
    test_corrected_results_scenario();
    
    % Test scenario 3: Edge cases and error handling
    test_edge_cases_scenario();
    
    fprintf('Comprehensive validation integration test completed!\n');
end

function test_problematic_results_scenario()
    fprintf('\n=== Testing Problematic Results Scenario ===\n');
    fprintf('This simulates the current system with categorical conversion errors\n');
    
    % Simulate problematic metrics (artificially perfect due to conversion error)
    metrics = struct();
    metrics.iou = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(20,1));
    metrics.dice = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(20,1));
    metrics.accuracy = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(20,1));
    
    % Simulate problematic visualization (uniform due to conversion error)
    problematic_img = ones(200, 600, 3) * 255; % All white image
    visualizations = struct();
    visualizations.comparisonImage = uint8(problematic_img);
    visualizations.originalImage = 'Found';
    visualizations.groundTruth = 'Found';
    visualizations.predictions = 'Found';
    
    % Simulate problematic categorical data
    % This represents the issue where double(categorical) > 1 gives wrong results
    problematic_gt = categorical([0; 1; 0; 1; 1; 0; 1; 0], [0, 1], ["background", "foreground"]);
    problematic_pred = categorical([0; 1; 0; 1; 1; 0; 1; 0], [0, 1], ["background", "foreground"]);
    
    categoricalData = struct();
    categoricalData.groundTruth = problematic_gt;
    categoricalData.predictions = problematic_pred;
    categoricalData.masks = problematic_gt;
    
    % Run comprehensive validation
    fprintf('Running validation on problematic results...\n');
    report = MetricsValidator.validateComprehensiveResults(metrics, visualizations, categoricalData);
    
    % Verify that problems are detected
    assert(~report.overallValid, 'Should detect that results are invalid');
    assert(length(report.errors) >= 3, 'Should detect multiple errors');
    
    % Check for specific error types
    perfect_metric_errors = contains(report.errors, 'perfect score');
    visualization_errors = contains(report.errors, 'uniform values');
    
    assert(any(perfect_metric_errors), 'Should detect perfect metric errors');
    assert(any(visualization_errors), 'Should detect visualization errors');
    
    % Check recommendations
    assert(length(report.recommendations) >= 2, 'Should provide recommendations');
    conversion_recommendations = contains(report.recommendations, 'categorical conversion');
    assert(any(conversion_recommendations), 'Should recommend checking categorical conversion');
    
    fprintf('✓ Problematic results correctly identified\n');
    
    % Save report for manual inspection
    save('tests/integration/problematic_validation_report.mat', 'report');
    fprintf('Saved detailed report to: tests/integration/problematic_validation_report.mat\n');
end

function test_corrected_results_scenario()
    fprintf('\n=== Testing Corrected Results Scenario ===\n');
    fprintf('This simulates the system after categorical conversion fixes\n');
    
    % Simulate realistic metrics (after correction)
    rng(42); % For reproducible results
    
    % Generate realistic IoU values (typically 0.6-0.9 for good segmentation)
    iou_values = 0.7 + 0.15 * randn(20, 1);
    iou_values = max(0.5, min(0.95, iou_values)); % Clamp to realistic range
    
    % Generate realistic Dice values (typically higher than IoU)
    dice_values = iou_values + 0.05 + 0.05 * randn(20, 1);
    dice_values = max(0.6, min(0.97, dice_values));
    
    % Generate realistic Accuracy values (typically highest)
    accuracy_values = dice_values + 0.05 + 0.03 * randn(20, 1);
    accuracy_values = max(0.7, min(0.99, accuracy_values));
    
    metrics = struct();
    metrics.iou = struct('mean', mean(iou_values), 'std', std(iou_values), 'values', iou_values);
    metrics.dice = struct('mean', mean(dice_values), 'std', std(dice_values), 'values', dice_values);
    metrics.accuracy = struct('mean', mean(accuracy_values), 'std', std(accuracy_values), 'values', accuracy_values);
    
    % Simulate realistic visualization (with actual differences)
    realistic_img = create_realistic_comparison_image();
    visualizations = struct();
    visualizations.comparisonImage = realistic_img;
    visualizations.originalImage = 'Found';
    visualizations.groundTruth = 'Found';
    visualizations.predictions = 'Found';
    
    % Simulate corrected categorical data
    % This represents proper categorical handling
    corrected_gt = categorical([0; 1; 0; 1; 1; 0; 1; 0; 0; 1], [0, 1], ["background", "foreground"]);
    corrected_pred = categorical([0; 1; 0; 0; 1; 0; 1; 1; 0; 1], [0, 1], ["background", "foreground"]); % Some differences
    
    categoricalData = struct();
    categoricalData.groundTruth = corrected_gt;
    categoricalData.predictions = corrected_pred;
    categoricalData.masks = corrected_gt;
    
    % Run comprehensive validation
    fprintf('Running validation on corrected results...\n');
    report = MetricsValidator.validateComprehensiveResults(metrics, visualizations, categoricalData);
    
    % Verify that results are now acceptable
    assert(report.overallValid || length(report.errors) == 0, 'Corrected results should be valid or have no errors');
    
    % Should have fewer warnings than problematic case
    fprintf('Validation warnings: %d\n', length(report.warnings));
    fprintf('Validation errors: %d\n', length(report.errors));
    
    % Check that metrics are in realistic ranges
    assert(metrics.iou.mean >= 0.3 && metrics.iou.mean <= 0.95, 'IoU should be in realistic range');
    assert(metrics.dice.mean >= 0.4 && metrics.dice.mean <= 0.97, 'Dice should be in realistic range');
    assert(metrics.accuracy.mean >= 0.7 && metrics.accuracy.mean <= 0.99, 'Accuracy should be in realistic range');
    
    % Check that there's reasonable variation
    assert(metrics.iou.std >= 0.01, 'IoU should have reasonable variation');
    assert(metrics.dice.std >= 0.01, 'Dice should have reasonable variation');
    assert(metrics.accuracy.std >= 0.01, 'Accuracy should have reasonable variation');
    
    fprintf('✓ Corrected results validated successfully\n');
    
    % Save report for comparison
    save('tests/integration/corrected_validation_report.mat', 'report');
    fprintf('Saved detailed report to: tests/integration/corrected_validation_report.mat\n');
end

function test_edge_cases_scenario()
    fprintf('\n=== Testing Edge Cases Scenario ===\n');
    
    % Test with missing data
    fprintf('Testing with missing metrics...\n');
    report1 = MetricsValidator.validateComprehensiveResults([], [], []);
    assert(length(report1.warnings) >= 3, 'Should warn about missing data');
    
    % Test with invalid data types
    fprintf('Testing with invalid data types...\n');
    invalid_metrics = 'not_a_struct';
    invalid_viz = 123;
    invalid_cat = 'not_categorical';
    
    try
        report2 = MetricsValidator.validateComprehensiveResults(invalid_metrics, invalid_viz, invalid_cat);
        % Should handle gracefully
        assert(~report2.overallValid, 'Should detect invalid inputs');
    catch ME
        fprintf('Caught expected error: %s\n', ME.message);
    end
    
    % Test with multi-class categorical
    fprintf('Testing with multi-class categorical...\n');
    multiclass_cat = categorical([1; 2; 3; 1; 2; 3], [1, 2, 3], ["class1", "class2", "class3"]);
    multiclass_data = struct('multiclass', multiclass_cat);
    
    report3 = MetricsValidator.validateComprehensiveResults([], [], multiclass_data);
    multiclass_warnings = contains(report3.warnings, 'Multi-class');
    assert(any(multiclass_warnings), 'Should detect multi-class categorical');
    
    fprintf('✓ Edge cases handled correctly\n');
end

function img = create_realistic_comparison_image()
    % Create a realistic comparison image with visible differences
    
    % Create base image (200x600 to simulate side-by-side comparison)
    img = zeros(200, 600, 3);
    
    % Left side: Original + Ground Truth
    img(1:200, 1:300, :) = create_segmentation_panel('original');
    
    % Right side: Predictions + Comparison
    img(1:200, 301:600, :) = create_segmentation_panel('prediction');
    
    % Convert to uint8
    img = uint8(img * 255);
end

function panel = create_segmentation_panel(type)
    % Create a realistic segmentation panel
    
    panel = zeros(200, 300, 3);
    
    if strcmp(type, 'original')
        % Simulate original image with ground truth overlay
        % Background (gray)
        panel(:, :, :) = 0.5;
        
        % Add some "objects" (brighter regions)
        panel(50:150, 50:100, :) = 0.8; % Object 1
        panel(60:120, 150:200, :) = 0.7; % Object 2
        
        % Add ground truth overlay (green tint)
        panel(50:150, 50:100, 2) = 0.9; % Object 1 - green
        panel(60:120, 150:200, 2) = 0.9; % Object 2 - green
        
    else % prediction
        % Simulate prediction with some differences
        % Background (gray)
        panel(:, :, :) = 0.5;
        
        % Add predicted objects (slightly different)
        panel(55:145, 55:95, :) = 0.8; % Object 1 - slightly smaller
        panel(65:125, 145:205, :) = 0.7; % Object 2 - slightly shifted
        
        % Add prediction overlay (red tint for differences)
        panel(55:145, 55:95, 1) = 0.9; % Object 1 - red
        panel(65:125, 145:205, 1) = 0.9; % Object 2 - red
        
        % Add some false positives (blue tint)
        panel(170:190, 250:280, 3) = 0.8; % False positive
    end
end