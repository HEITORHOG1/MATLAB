function demo_MetricsValidator()
    % Demonstration of MetricsValidator utility class
    % Shows how to use all methods for validating metrics and categorical data
    
    fprintf('=== MetricsValidator Demo ===\n\n');
    
    % Demo 1: Validate realistic metrics
    fprintf('1. Validating realistic metrics:\n');
    realistic_metrics = struct();
    realistic_metrics.iou = struct('mean', 0.75, 'std', 0.05);
    realistic_metrics.dice = struct('mean', 0.82, 'std', 0.04);
    realistic_metrics.accuracy = struct('mean', 0.88, 'std', 0.03);
    
    isValid = MetricsValidator.validateMetrics(realistic_metrics);
    fprintf('   Realistic metrics valid: %s\n\n', mat2str(isValid));
    
    % Demo 2: Validate suspicious perfect metrics
    fprintf('2. Validating suspicious perfect metrics:\n');
    perfect_metrics = struct();
    perfect_metrics.iou = struct('mean', 1.0000, 'std', 0.0000);
    perfect_metrics.dice = struct('mean', 1.0000, 'std', 0.0000);
    perfect_metrics.accuracy = struct('mean', 1.0000, 'std', 0.0000);
    
    warning('off', 'MetricsValidator:PerfectMetrics');
    isValid = MetricsValidator.validateMetrics(perfect_metrics);
    warning('on', 'MetricsValidator:PerfectMetrics');
    fprintf('   Perfect metrics valid: %s (should be false)\n\n', mat2str(isValid));
    
    % Demo 3: Check for perfect metrics patterns
    fprintf('3. Checking for perfect metrics patterns:\n');
    iou_perfect = ones(10, 1);
    dice_perfect = ones(10, 1);
    accuracy_perfect = ones(10, 1);
    
    warnings = MetricsValidator.checkPerfectMetrics(iou_perfect, dice_perfect, accuracy_perfect);
    fprintf('   Number of warnings for perfect metrics: %d\n', length(warnings));
    for i = 1:length(warnings)
        fprintf('   Warning %d: %s\n', i, warnings{i});
    end
    fprintf('\n');
    
    % Demo 4: Check realistic metrics
    fprintf('4. Checking realistic metrics patterns:\n');
    rng(42); % For reproducible results
    iou_realistic = 0.7 + 0.1 * randn(10, 1);
    dice_realistic = 0.8 + 0.05 * randn(10, 1);
    accuracy_realistic = 0.85 + 0.03 * randn(10, 1);
    
    warnings = MetricsValidator.checkPerfectMetrics(iou_realistic, dice_realistic, accuracy_realistic);
    fprintf('   Number of warnings for realistic metrics: %d\n', length(warnings));
    fprintf('\n');
    
    % Demo 5: Correct categorical conversion
    fprintf('5. Demonstrating categorical conversion correction:\n');
    
    % Standard binary categorical
    binary_data = categorical([0, 1, 0, 1, 1, 0], [0, 1], ["background", "foreground"]);
    fprintf('   Original categorical: %s\n', strjoin(string(binary_data), ', '));
    
    corrected = MetricsValidator.correctCategoricalConversion(binary_data);
    fprintf('   Corrected binary: %s\n', mat2str(corrected));
    fprintf('\n');
    
    % Demo 6: Validate categorical structure
    fprintf('6. Validating categorical structure:\n');
    validated = MetricsValidator.validateCategoricalStructure(binary_data);
    
    fprintf('   Is valid: %s\n', mat2str(validated.isValid));
    fprintf('   Is standard binary: %s\n', mat2str(validated.debugInfo.isStandardBinary));
    fprintf('   Number of categories: %d\n', validated.debugInfo.numCategories);
    fprintf('   Categories: %s\n', strjoin(validated.debugInfo.categories, ', '));
    fprintf('   Number of warnings: %d\n', length(validated.warnings));
    fprintf('\n');
    
    % Demo 7: Debug categorical data
    fprintf('7. Debugging categorical data:\n');
    MetricsValidator.debugCategoricalData(binary_data, 'Demo Binary Data');
    
    % Demo 8: Multi-class categorical example
    fprintf('8. Multi-class categorical example:\n');
    multiclass_data = categorical([1, 2, 3, 1, 2, 3, 1], [1, 2, 3], ["class1", "class2", "class3"]);
    
    validated_multi = MetricsValidator.validateCategoricalStructure(multiclass_data);
    fprintf('   Multi-class is standard binary: %s\n', mat2str(validated_multi.debugInfo.isStandardBinary));
    fprintf('   Multi-class warnings: %d\n', length(validated_multi.warnings));
    
    MetricsValidator.debugCategoricalData(multiclass_data, 'Demo Multi-class Data');
    
    % Demo 9: Common error scenarios
    fprintf('9. Common error scenarios:\n');
    
    % Wrong conversion logic demonstration
    fprintf('   Demonstrating why double(categorical) > 1 is wrong:\n');
    test_data = categorical([0, 1, 0, 1], [0, 1], ["background", "foreground"]);
    double_vals = double(test_data);
    wrong_conversion = double_vals > 1;  % This is the WRONG way
    correct_conversion = MetricsValidator.correctCategoricalConversion(test_data);
    
    fprintf('   Categorical data: %s\n', strjoin(string(test_data), ', '));
    fprintf('   double(categorical): %s\n', mat2str(double_vals));
    fprintf('   WRONG (double > 1): %s\n', mat2str(wrong_conversion));
    fprintf('   CORRECT conversion: %s\n', mat2str(correct_conversion));
    
    fprintf('\n=== Demo Complete ===\n');
end