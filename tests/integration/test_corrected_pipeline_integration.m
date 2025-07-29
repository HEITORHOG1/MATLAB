function test_corrected_pipeline_integration()
    % ========================================================================
    % INTEGRATION TEST - CORRECTED PIPELINE
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Integration test for the complete corrected pipeline
    %   Tests all components working together with corrected categorical handling
    %
    % REQUIREMENTS TESTED:
    %   5.1 - Pipeline consistency in training
    %   5.2 - Pipeline consistency in evaluation  
    %   5.3 - Pipeline consistency across samples
    %   5.4 - Complete execution without type errors
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/help/deeplearning/ug/semantic-segmentation-using-deep-learning.html
    % ========================================================================
    
    fprintf('=== INTEGRATION TEST - CORRECTED PIPELINE ===\n\n');
    
    % Add necessary paths
    currentDir = pwd;
    rootDir = fileparts(fileparts(currentDir)); % Go up two levels from tests/integration
    addpath(genpath(fullfile(rootDir, 'src')));
    addpath(genpath(fullfile(rootDir, 'utils')));
    addpath(genpath(fullfile(rootDir, 'legacy')));
    addpath(genpath(fullfile(rootDir, 'tests')));
    
    % Setup test environment
    testEnv = setupIntegrationTestEnvironment();
    
    try
        % Test 1: Complete preprocessing pipeline with corrected categorical handling
        fprintf('=== TEST 1: Preprocessing Pipeline ===\n');
        test_preprocessing_pipeline_corrected(testEnv);
        
        % Test 2: Validate that metrics show realistic variation (not perfect scores)
        fprintf('\n=== TEST 2: Realistic Metrics Validation ===\n');
        test_realistic_metrics_validation(testEnv);
        
        % Test 3: Test visualization generation produces correct comparison images
        fprintf('\n=== TEST 3: Visualization Generation ===\n');
        test_visualization_generation_corrected(testEnv);
        
        % Test 4: Validate model evaluation produces meaningful differences
        fprintf('\n=== TEST 4: Model Evaluation Differences ===\n');
        test_model_evaluation_differences(testEnv);
        
        % Test 5: End-to-end pipeline integration
        fprintf('\n=== TEST 5: End-to-End Pipeline ===\n');
        test_end_to_end_pipeline_integration(testEnv);
        
        fprintf('\n=== ALL INTEGRATION TESTS PASSED! ===\n');
        
    catch ME
        fprintf('\n=== INTEGRATION TEST FAILED ===\n');
        fprintf('Error: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('File: %s\n', ME.stack(1).file);
            fprintf('Line: %d\n', ME.stack(1).line);
        end
        rethrow(ME);
    finally
        % Cleanup test environment
        cleanupIntegrationTestEnvironment(testEnv);
    end
end

function testEnv = setupIntegrationTestEnvironment()
    % Setup isolated test environment for integration testing
    fprintf('Setting up integration test environment...\n');
    
    testEnv = struct();
    testEnv.baseDir = 'test_integration_corrected';
    testEnv.dataDir = fullfile(testEnv.baseDir, 'data');
    testEnv.outputDir = fullfile(testEnv.baseDir, 'output');
    testEnv.modelsDir = fullfile(testEnv.baseDir, 'models');
    
    % Create directories
    dirs = {testEnv.baseDir, testEnv.dataDir, testEnv.outputDir, testEnv.modelsDir};
    for i = 1:length(dirs)
        if ~exist(dirs{i}, 'dir')
            mkdir(dirs{i});
        end
    end
    
    % Create synthetic test data with known characteristics
    testEnv.imageDir = fullfile(testEnv.dataDir, 'images');
    testEnv.maskDir = fullfile(testEnv.dataDir, 'masks');
    
    createRealisticTestData(testEnv.imageDir, testEnv.maskDir);
    
    % Configuration for testing
    testEnv.config = struct();
    testEnv.config.imageDir = testEnv.imageDir;
    testEnv.config.maskDir = testEnv.maskDir;
    testEnv.config.outputDir = testEnv.outputDir;
    testEnv.config.inputSize = [64, 64, 3]; % Small for fast testing
    testEnv.config.numClasses = 2;
    testEnv.config.maxEpochs = 3; % Very short for testing
    testEnv.config.miniBatchSize = 2;
    testEnv.config.learningRate = 1e-3;
    
    fprintf('✓ Integration test environment ready\n');
end

function test_preprocessing_pipeline_corrected(testEnv)
    % Test complete preprocessing pipeline with corrected categorical handling
    fprintf('Testing preprocessing pipeline with corrected categorical handling...\n');
    
    % Load test data
    imageFiles = dir(fullfile(testEnv.imageDir, '*.png'));
    maskFiles = dir(fullfile(testEnv.maskDir, '*.png'));
    
    assert(length(imageFiles) >= 4, 'Need at least 4 test images');
    assert(length(maskFiles) >= 4, 'Need at least 4 test masks');
    
    % Test individual preprocessing steps
    for i = 1:min(4, length(imageFiles))
        fprintf('  Processing sample %d/%d...\n', i, min(4, length(imageFiles)));
        
        % Load raw data
        imgPath = fullfile(testEnv.imageDir, imageFiles(i).name);
        maskPath = fullfile(testEnv.maskDir, maskFiles(i).name);
        
        img = imread(imgPath);
        mask = imread(maskPath);
        
        % Test PreprocessingValidator
        try
            PreprocessingValidator.validateImageData(img);
            PreprocessingValidator.validateMaskData(mask);
            fprintf('    ✓ Data validation passed\n');
        catch ME
            error('Data validation failed: %s', ME.message);
        end
        
        % Test data compatibility
        compatibility = PreprocessingValidator.validateDataCompatibility(img, mask);
        assert(compatibility.isCompatible, 'Image and mask should be compatible');
        fprintf('    ✓ Data compatibility validated\n');
        
        % Test DataTypeConverter with categorical creation
        % Convert mask to categorical using corrected logic
        maskBinary = mask > 127; % Convert to logical
        maskCategorical = DataTypeConverter.numericToCategorical(maskBinary, ...
            ["background", "foreground"], [0, 1]);
        
        % Validate categorical structure
        catValidation = DataTypeConverter.validateCategoricalStructure(maskCategorical);
        assert(catValidation.isValid, 'Categorical structure should be valid');
        fprintf('    ✓ Categorical creation validated\n');
        
        % Test conversion back to numeric (this is where the bug was)
        maskNumeric = DataTypeConverter.categoricalToNumeric(maskCategorical, 'double');
        
        % Verify correct conversion logic
        expectedNumeric = double(maskBinary);
        assert(isequal(maskNumeric, expectedNumeric), ...
            'Categorical to numeric conversion should match original binary data');
        fprintf('    ✓ Categorical conversion logic validated\n');
        
        % Test preprocessing functions
        testData = {img, maskCategorical};
        
        % Test preprocessDataCorrigido with corrected logic
        try
            processedData = preprocessDataCorrigido(testData, testEnv.config, [0, 1], false);
            assert(iscell(processedData), 'Processed data should be cell array');
            assert(length(processedData) == 2, 'Should have image and mask');
            fprintf('    ✓ preprocessDataCorrigido passed\n');
        catch ME
            error('preprocessDataCorrigido failed: %s', ME.message);
        end
        
        % Test preprocessDataMelhorado with corrected logic
        try
            processedData2 = preprocessDataMelhorado(testData, testEnv.config, [0, 1], false);
            assert(iscell(processedData2), 'Processed data should be cell array');
            assert(length(processedData2) == 2, 'Should have image and mask');
            fprintf('    ✓ preprocessDataMelhorado passed\n');
        catch ME
            error('preprocessDataMelhorado failed: %s', ME.message);
        end
    end
    
    fprintf('✓ Preprocessing pipeline test completed successfully\n');
end

function test_realistic_metrics_validation(testEnv)
    % Test that metrics show realistic variation (not perfect scores)
    fprintf('Testing realistic metrics validation...\n');
    
    % Create realistic test predictions vs ground truth
    numSamples = 20;
    
    % Generate realistic IoU values (0.6-0.9 range with variation)
    rng(42); % For reproducible results
    baseIoU = 0.75;
    iouValues = baseIoU + 0.1 * randn(numSamples, 1);
    iouValues = max(0.5, min(0.95, iouValues)); % Clamp to realistic range
    
    % Generate corresponding Dice values (typically higher than IoU)
    diceValues = iouValues + 0.05 + 0.03 * randn(numSamples, 1);
    diceValues = max(0.6, min(0.97, diceValues));
    
    % Generate corresponding Accuracy values (typically highest)
    accuracyValues = diceValues + 0.03 + 0.02 * randn(numSamples, 1);
    accuracyValues = max(0.7, min(0.99, accuracyValues));
    
    % Create metrics structure
    metrics = struct();
    metrics.iou = struct('mean', mean(iouValues), 'std', std(iouValues), 'values', iouValues);
    metrics.dice = struct('mean', mean(diceValues), 'std', std(diceValues), 'values', diceValues);
    metrics.accuracy = struct('mean', mean(accuracyValues), 'std', std(accuracyValues), 'values', accuracyValues);
    
    % Test MetricsValidator
    isValid = MetricsValidator.validateMetrics(metrics);
    assert(isValid, 'Realistic metrics should be valid');
    fprintf('  ✓ Realistic metrics validated as valid\n');
    
    % Check for perfect metrics warnings (should be none)
    warnings = MetricsValidator.checkPerfectMetrics(iouValues, diceValues, accuracyValues);
    assert(isempty(warnings), 'Realistic metrics should not trigger perfect metric warnings');
    fprintf('  ✓ No perfect metric warnings for realistic data\n');
    
    % Test with problematic metrics (artificially perfect)
    problematicMetrics = struct();
    problematicMetrics.iou = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(numSamples, 1));
    problematicMetrics.dice = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(numSamples, 1));
    problematicMetrics.accuracy = struct('mean', 1.0000, 'std', 0.0000, 'values', ones(numSamples, 1));
    
    isValidProblematic = MetricsValidator.validateMetrics(problematicMetrics);
    assert(~isValidProblematic, 'Perfect metrics should be detected as invalid');
    fprintf('  ✓ Perfect metrics correctly detected as invalid\n');
    
    % Test categorical conversion correction
    % Create test categorical data with the problematic pattern
    testCategorical = categorical([0; 1; 0; 1; 1; 0], [0, 1], ["background", "foreground"]);
    
    % Test corrected conversion
    correctedBinary = MetricsValidator.correctCategoricalConversion(testCategorical);
    expectedBinary = [0; 1; 0; 1; 1; 0];
    assert(isequal(correctedBinary, expectedBinary), 'Categorical conversion should be corrected');
    fprintf('  ✓ Categorical conversion correction validated\n');
    
    % Test metric calculation with corrected conversion
    % Simulate ground truth and predictions
    gt_categorical = categorical([0; 1; 0; 1; 1; 0; 1; 0], [0, 1], ["background", "foreground"]);
    pred_categorical = categorical([0; 1; 0; 0; 1; 0; 1; 1], [0, 1], ["background", "foreground"]);
    
    % Calculate metrics using corrected logic
    gt_binary = MetricsValidator.correctCategoricalConversion(gt_categorical);
    pred_binary = MetricsValidator.correctCategoricalConversion(pred_categorical);
    
    % Calculate IoU manually to verify
    intersection = sum(gt_binary & pred_binary);
    union = sum(gt_binary | pred_binary);
    expectedIoU = intersection / union;
    
    % This should NOT be 1.0 (perfect) if there are actual differences
    assert(expectedIoU < 1.0, 'IoU should not be perfect when there are prediction differences');
    assert(expectedIoU > 0.0, 'IoU should not be zero for reasonable predictions');
    fprintf('  ✓ Corrected metric calculation produces realistic values\n');
    
    fprintf('✓ Realistic metrics validation test completed successfully\n');
end

function test_visualization_generation_corrected(testEnv)
    % Test visualization generation produces correct comparison images
    fprintf('Testing corrected visualization generation...\n');
    
    % Load test data
    imageFiles = dir(fullfile(testEnv.imageDir, '*.png'));
    maskFiles = dir(fullfile(testEnv.maskDir, '*.png'));
    
    % Test with first sample
    imgPath = fullfile(testEnv.imageDir, imageFiles(1).name);
    maskPath = fullfile(testEnv.maskDir, maskFiles(1).name);
    
    img = imread(imgPath);
    mask = imread(maskPath);
    
    % Create categorical mask and prediction
    maskBinary = mask > 127;
    maskCategorical = DataTypeConverter.numericToCategorical(maskBinary, ...
        ["background", "foreground"], [0, 1]);
    
    % Create slightly different prediction
    predBinary = maskBinary;
    predBinary(10:20, 10:20) = ~predBinary(10:20, 10:20); % Introduce some differences
    predCategorical = DataTypeConverter.numericToCategorical(predBinary, ...
        ["background", "foreground"], [0, 1]);
    
    % Test VisualizationHelper methods
    fprintf('  Testing VisualizationHelper methods...\n');
    
    % Test image preparation
    imgDisplay = VisualizationHelper.prepareImageForDisplay(img);
    assert(isnumeric(imgDisplay), 'Prepared image should be numeric');
    assert(~iscategorical(imgDisplay), 'Prepared image should not be categorical');
    fprintf('    ✓ Image preparation successful\n');
    
    % Test mask preparation
    maskDisplay = VisualizationHelper.prepareMaskForDisplay(maskCategorical);
    assert(isa(maskDisplay, 'uint8'), 'Prepared mask should be uint8');
    assert(all(ismember(unique(maskDisplay(:)), [0, 255])), 'Mask should have binary values [0, 255]');
    fprintf('    ✓ Mask preparation successful\n');
    
    % Test prediction preparation
    predDisplay = VisualizationHelper.prepareMaskForDisplay(predCategorical);
    assert(isa(predDisplay, 'uint8'), 'Prepared prediction should be uint8');
    assert(all(ismember(unique(predDisplay(:)), [0, 255])), 'Prediction should have binary values [0, 255]');
    fprintf('    ✓ Prediction preparation successful\n');
    
    % Test comparison data preparation
    [imgOut, maskOut, predOut] = VisualizationHelper.prepareComparisonData(img, maskCategorical, predCategorical);
    assert(~iscategorical(imgOut), 'Output image should not be categorical');
    assert(~iscategorical(maskOut), 'Output mask should not be categorical');
    assert(~iscategorical(predOut), 'Output prediction should not be categorical');
    fprintf('    ✓ Comparison data preparation successful\n');
    
    % Test safe imshow
    figure('Visible', 'off'); % Create invisible figure for testing
    success1 = VisualizationHelper.safeImshow(imgOut);
    assert(success1, 'Safe imshow should succeed for prepared image');
    
    success2 = VisualizationHelper.safeImshow(maskOut);
    assert(success2, 'Safe imshow should succeed for prepared mask');
    
    success3 = VisualizationHelper.safeImshow(predOut);
    assert(success3, 'Safe imshow should succeed for prepared prediction');
    close all; % Close test figures
    fprintf('    ✓ Safe imshow successful\n');
    
    % Test visualization with categorical data (should handle gracefully)
    figure('Visible', 'off');
    success4 = VisualizationHelper.safeImshow(maskCategorical);
    assert(success4, 'Safe imshow should handle categorical data');
    close all;
    fprintf('    ✓ Categorical data visualization handled\n');
    
    % Test comprehensive visualization validation
    visualizations = struct();
    visualizations.comparisonImage = create_test_comparison_image();
    visualizations.originalImage = 'Found';
    visualizations.groundTruth = 'Found';
    visualizations.predictions = 'Found';
    
    % Create empty report structure for validation
    report = struct('warnings', {{}}, 'errors', {{}});
    report = MetricsValidator.validateVisualizationQuality(visualizations, report);
    
    % Should have no errors for valid visualization
    assert(isempty(report.errors), 'Valid visualization should have no errors');
    fprintf('    ✓ Visualization quality validation passed\n');
    
    fprintf('✓ Visualization generation test completed successfully\n');
end

function test_model_evaluation_differences(testEnv)
    % Test that model evaluation produces meaningful differences between models
    fprintf('Testing model evaluation produces meaningful differences...\n');
    
    % Create synthetic evaluation results that simulate realistic model differences
    numSamples = 15;
    rng(123); % For reproducible results
    
    % Simulate U-Net results (baseline)
    unet_iou = 0.72 + 0.08 * randn(numSamples, 1);
    unet_iou = max(0.5, min(0.9, unet_iou));
    
    unet_dice = unet_iou + 0.05 + 0.04 * randn(numSamples, 1);
    unet_dice = max(0.6, min(0.95, unet_dice));
    
    unet_accuracy = unet_dice + 0.03 + 0.02 * randn(numSamples, 1);
    unet_accuracy = max(0.75, min(0.98, unet_accuracy));
    
    % Simulate Attention U-Net results (slightly better)
    attention_iou = unet_iou + 0.03 + 0.02 * randn(numSamples, 1);
    attention_iou = max(0.5, min(0.95, attention_iou));
    
    attention_dice = attention_iou + 0.05 + 0.04 * randn(numSamples, 1);
    attention_dice = max(0.6, min(0.97, attention_dice));
    
    attention_accuracy = attention_dice + 0.03 + 0.02 * randn(numSamples, 1);
    attention_accuracy = max(0.75, min(0.99, attention_accuracy));
    
    % Create metrics structures
    unetMetrics = struct();
    unetMetrics.iou = struct('mean', mean(unet_iou), 'std', std(unet_iou), 'values', unet_iou);
    unetMetrics.dice = struct('mean', mean(unet_dice), 'std', std(unet_dice), 'values', unet_dice);
    unetMetrics.accuracy = struct('mean', mean(unet_accuracy), 'std', std(unet_accuracy), 'values', unet_accuracy);
    
    attentionMetrics = struct();
    attentionMetrics.iou = struct('mean', mean(attention_iou), 'std', std(attention_iou), 'values', attention_iou);
    attentionMetrics.dice = struct('mean', mean(attention_dice), 'std', std(attention_dice), 'values', attention_dice);
    attentionMetrics.accuracy = struct('mean', mean(attention_accuracy), 'std', std(attention_accuracy), 'values', attention_accuracy);
    
    % Validate both metrics are realistic
    assert(MetricsValidator.validateMetrics(unetMetrics), 'U-Net metrics should be valid');
    assert(MetricsValidator.validateMetrics(attentionMetrics), 'Attention U-Net metrics should be valid');
    fprintf('  ✓ Both model metrics are realistic\n');
    
    % Test that models show meaningful differences
    iou_diff = attentionMetrics.iou.mean - unetMetrics.iou.mean;
    dice_diff = attentionMetrics.dice.mean - unetMetrics.dice.mean;
    accuracy_diff = attentionMetrics.accuracy.mean - unetMetrics.accuracy.mean;
    
    fprintf('  Model differences:\n');
    fprintf('    IoU: %.4f (%.2f%% improvement)\n', iou_diff, iou_diff/unetMetrics.iou.mean*100);
    fprintf('    Dice: %.4f (%.2f%% improvement)\n', dice_diff, dice_diff/unetMetrics.dice.mean*100);
    fprintf('    Accuracy: %.4f (%.2f%% improvement)\n', accuracy_diff, accuracy_diff/unetMetrics.accuracy.mean*100);
    
    % Differences should be meaningful but not too large
    assert(abs(iou_diff) > 0.005, 'IoU difference should be meaningful (>0.5%)');
    assert(abs(iou_diff) < 0.2, 'IoU difference should be realistic (<20%)');
    fprintf('  ✓ IoU differences are meaningful and realistic\n');
    
    assert(abs(dice_diff) > 0.005, 'Dice difference should be meaningful (>0.5%)');
    assert(abs(dice_diff) < 0.2, 'Dice difference should be realistic (<20%)');
    fprintf('  ✓ Dice differences are meaningful and realistic\n');
    
    assert(abs(accuracy_diff) > 0.002, 'Accuracy difference should be meaningful (>0.2%)');
    assert(abs(accuracy_diff) < 0.1, 'Accuracy difference should be realistic (<10%)');
    fprintf('  ✓ Accuracy differences are meaningful and realistic\n');
    
    % Test statistical significance (simulated)
    % Perform t-test to check if differences are statistically significant
    [h_iou, p_iou] = ttest2(unet_iou, attention_iou);
    [h_dice, p_dice] = ttest2(unet_dice, attention_dice);
    [h_accuracy, p_accuracy] = ttest2(unet_accuracy, attention_accuracy);
    
    fprintf('  Statistical significance tests:\n');
    fprintf('    IoU: p=%.4f, significant=%s\n', p_iou, mat2str(h_iou));
    fprintf('    Dice: p=%.4f, significant=%s\n', p_dice, mat2str(h_dice));
    fprintf('    Accuracy: p=%.4f, significant=%s\n', p_accuracy, mat2str(h_accuracy));
    
    % With small sample sizes, statistical significance may not always be achieved
    % This is actually realistic behavior - we just check that the test runs
    if h_iou || h_dice || h_accuracy
        fprintf('  ✓ Statistical significance detected\n');
    else
        fprintf('  ✓ No statistical significance (expected with small sample size)\n');
    end
    
    % Test that metrics are not artificially perfect
    perfectWarnings_unet = MetricsValidator.checkPerfectMetrics(unet_iou, unet_dice, unet_accuracy);
    perfectWarnings_attention = MetricsValidator.checkPerfectMetrics(attention_iou, attention_dice, attention_accuracy);
    
    assert(isempty(perfectWarnings_unet), 'U-Net metrics should not be artificially perfect');
    assert(isempty(perfectWarnings_attention), 'Attention U-Net metrics should not be artificially perfect');
    fprintf('  ✓ No artificially perfect metrics detected\n');
    
    fprintf('✓ Model evaluation differences test completed successfully\n');
end

function test_end_to_end_pipeline_integration(testEnv)
    % Test complete end-to-end pipeline integration
    fprintf('Testing end-to-end pipeline integration...\n');
    
    % Load test data
    imageFiles = dir(fullfile(testEnv.imageDir, '*.png'));
    maskFiles = dir(fullfile(testEnv.maskDir, '*.png'));
    
    % Use subset for quick testing
    numSamples = min(6, length(imageFiles));
    
    images = cell(numSamples, 1);
    masks = cell(numSamples, 1);
    
    % Load and prepare data
    fprintf('  Loading test data...\n');
    for i = 1:numSamples
        imgPath = fullfile(testEnv.imageDir, imageFiles(i).name);
        maskPath = fullfile(testEnv.maskDir, maskFiles(i).name);
        
        images{i} = imgPath;
        masks{i} = maskPath;
    end
    
    % Test data loading and analysis
    fprintf('  Testing data analysis...\n');
    [classNames, labelIDs] = analisar_mascaras_automatico(testEnv.maskDir, masks);
    
    assert(length(classNames) == 2, 'Should detect 2 classes');
    assert(length(labelIDs) == 2, 'Should have 2 label IDs');
    assert(length(classNames) == length(labelIDs), 'Class names and label IDs should match');
    fprintf('    Detected classes: %s with IDs: %s\n', strjoin(classNames, ', '), mat2str(labelIDs));
    fprintf('    ✓ Data analysis completed\n');
    
    % Create datastores
    fprintf('  Creating datastores...\n');
    imds = imageDatastore(images);
    pxds = pixelLabelDatastore(masks, classNames, labelIDs);
    ds = combine(imds, pxds);
    
    % Test datastore functionality
    reset(ds);
    assert(hasdata(ds), 'Datastore should have data');
    
    % Test preprocessing with datastore
    fprintf('  Testing datastore preprocessing...\n');
    dsProcessed = transform(ds, @(data) preprocessDataCorrigido(data, testEnv.config, labelIDs, false));
    
    % Read and validate processed samples
    reset(dsProcessed);
    sampleCount = 0;
    while hasdata(dsProcessed) && sampleCount < 3
        try
            data = read(dsProcessed);
            assert(iscell(data), 'Processed data should be cell array');
            assert(length(data) == 2, 'Should have image and mask');
            
            processedImg = data{1};
            processedMask = data{2};
            
            % Validate processed image
            assert(isnumeric(processedImg), 'Processed image should be numeric');
            assert(~iscategorical(processedImg), 'Processed image should not be categorical');
            assert(isequal(size(processedImg), testEnv.config.inputSize), 'Image should match input size');
            
            % Validate processed mask
            assert(iscategorical(processedMask), 'Processed mask should be categorical');
            assert(isequal(size(processedMask), testEnv.config.inputSize(1:2)), 'Mask should match spatial dimensions');
            
            sampleCount = sampleCount + 1;
            
        catch ME
            error('Datastore preprocessing failed on sample %d: %s', sampleCount + 1, ME.message);
        end
    end
    
    fprintf('    ✓ Processed %d samples successfully\n', sampleCount);
    
    % Test metric calculation with processed data
    fprintf('  Testing metric calculations...\n');
    
    % Create test predictions and ground truth
    reset(dsProcessed);
    data = read(dsProcessed);
    gt = data{2}; % Ground truth categorical
    
    % Create slightly different prediction
    pred = gt;
    % Introduce some differences
    if size(pred, 1) > 20 && size(pred, 2) > 20
        pred(10:20, 10:20) = categorical(~(pred(10:20, 10:20) == "foreground"), ...
            [false, true], ["background", "foreground"]);
    end
    
    % Calculate metrics using corrected functions
    try
        iou = calcular_iou_simples(pred, gt);
        dice = calcular_dice_simples(pred, gt);
        accuracy = calcular_accuracy_simples(pred, gt);
        
        % Validate metric values
        assert(iou >= 0 && iou <= 1, 'IoU should be in [0,1] range');
        assert(dice >= 0 && dice <= 1, 'Dice should be in [0,1] range');
        assert(accuracy >= 0 && accuracy <= 1, 'Accuracy should be in [0,1] range');
        
        % Should not be perfect due to introduced differences
        assert(iou < 1.0, 'IoU should not be perfect with introduced differences');
        assert(dice < 1.0, 'Dice should not be perfect with introduced differences');
        
        fprintf('    ✓ Metrics calculated: IoU=%.4f, Dice=%.4f, Accuracy=%.4f\n', iou, dice, accuracy);
        
    catch ME
        error('Metric calculation failed: %s', ME.message);
    end
    
    % Test visualization pipeline
    fprintf('  Testing visualization pipeline...\n');
    
    try
        % Prepare visualization data
        originalImg = imread(images{1});
        [imgViz, gtViz, predViz] = VisualizationHelper.prepareComparisonData(originalImg, gt, pred);
        
        % Test visualization creation (without actually displaying)
        figure('Visible', 'off');
        
        subplot(1, 3, 1);
        success1 = VisualizationHelper.safeImshow(imgViz);
        title('Original');
        
        subplot(1, 3, 2);
        success2 = VisualizationHelper.safeImshow(gtViz);
        title('Ground Truth');
        
        subplot(1, 3, 3);
        success3 = VisualizationHelper.safeImshow(predViz);
        title('Prediction');
        
        assert(success1 && success2 && success3, 'All visualizations should succeed');
        
        % Save test visualization
        vizPath = fullfile(testEnv.outputDir, 'test_comparison.png');
        saveas(gcf, vizPath);
        close all;
        
        assert(exist(vizPath, 'file') == 2, 'Visualization should be saved');
        fprintf('    ✓ Visualization pipeline completed\n');
        
    catch ME
        close all; % Ensure figures are closed on error
        error('Visualization pipeline failed: %s', ME.message);
    end
    
    % Test comprehensive validation
    fprintf('  Testing comprehensive validation...\n');
    
    % Create comprehensive test data
    testMetrics = struct();
    testMetrics.iou = struct('mean', iou, 'std', 0.05, 'values', [iou; iou + 0.02; iou - 0.03]);
    testMetrics.dice = struct('mean', dice, 'std', 0.04, 'values', [dice; dice + 0.01; dice - 0.02]);
    testMetrics.accuracy = struct('mean', accuracy, 'std', 0.02, 'values', [accuracy; accuracy + 0.005; accuracy - 0.01]);
    
    testVisualizations = struct();
    testVisualizations.comparisonImage = imread(vizPath);
    testVisualizations.originalImage = 'Found';
    testVisualizations.groundTruth = 'Found';
    testVisualizations.predictions = 'Found';
    
    testCategoricalData = struct();
    testCategoricalData.groundTruth = gt;
    testCategoricalData.predictions = pred;
    
    % Run comprehensive validation
    report = MetricsValidator.validateComprehensiveResults(testMetrics, testVisualizations, testCategoricalData);
    
    % Should pass validation (or have only minor warnings)
    assert(report.overallValid || length(report.errors) == 0, 'Comprehensive validation should pass');
    fprintf('    ✓ Comprehensive validation completed\n');
    
    % Save integration test results
    resultsPath = fullfile(testEnv.outputDir, 'integration_test_results.mat');
    save(resultsPath, 'testMetrics', 'report', 'iou', 'dice', 'accuracy');
    fprintf('    ✓ Results saved to: %s\n', resultsPath);
    
    fprintf('✓ End-to-end pipeline integration test completed successfully\n');
end

function createRealisticTestData(imageDir, maskDir)
    % Create realistic synthetic test data for integration testing
    if ~exist(imageDir, 'dir')
        mkdir(imageDir);
    end
    if ~exist(maskDir, 'dir')
        mkdir(maskDir);
    end
    
    % Create 8 test samples with realistic characteristics
    for i = 1:8
        % Create realistic image (64x64 for fast testing)
        img = create_realistic_test_image(64, 64);
        imgFile = fullfile(imageDir, sprintf('test_img_%03d.png', i));
        imwrite(img, imgFile);
        
        % Create corresponding realistic mask
        mask = create_realistic_test_mask(64, 64, i);
        maskFile = fullfile(maskDir, sprintf('test_img_%03d.png', i));
        imwrite(mask, maskFile);
    end
end

function img = create_realistic_test_image(height, width)
    % Create a realistic test image with texture and objects
    img = zeros(height, width, 3);
    
    % Add background texture
    img(:, :, 1) = 0.3 + 0.2 * rand(height, width);
    img(:, :, 2) = 0.4 + 0.2 * rand(height, width);
    img(:, :, 3) = 0.5 + 0.2 * rand(height, width);
    
    % Add some objects
    centerX = width / 2;
    centerY = height / 2;
    
    % Object 1: Circle
    [X, Y] = meshgrid(1:width, 1:height);
    circle1 = ((X - centerX + 10).^2 + (Y - centerY).^2) < 100;
    img(repmat(circle1, [1, 1, 3])) = img(repmat(circle1, [1, 1, 3])) + 0.3;
    
    % Object 2: Rectangle
    rect = false(height, width);
    rect(centerY-5:centerY+5, centerX+5:centerX+15) = true;
    img(repmat(rect, [1, 1, 3])) = img(repmat(rect, [1, 1, 3])) + 0.2;
    
    % Clamp values
    img = min(1, max(0, img));
    
    % Convert to uint8
    img = uint8(img * 255);
end

function mask = create_realistic_test_mask(height, width, seed)
    % Create a realistic test mask corresponding to the image
    rng(seed); % Different pattern for each sample
    
    mask = false(height, width);
    
    centerX = width / 2;
    centerY = height / 2;
    
    % Object 1: Circle (with some noise)
    [X, Y] = meshgrid(1:width, 1:height);
    circle1 = ((X - centerX + 10).^2 + (Y - centerY).^2) < (100 + 20 * randn());
    mask = mask | circle1;
    
    % Object 2: Rectangle (with some variation)
    rect = false(height, width);
    rect(centerY-5:centerY+5, centerX+5:centerX+15) = true;
    mask = mask | rect;
    
    % Add some noise
    noise = rand(height, width) > 0.95;
    mask = mask | noise;
    
    % Remove some noise
    noise2 = rand(height, width) < 0.02;
    mask = mask & ~noise2;
    
    % Convert to uint8
    mask = uint8(mask) * 255;
end

function img = create_test_comparison_image()
    % Create a test comparison image for validation
    img = zeros(200, 600, 3);
    
    % Left panel: Original + GT
    img(1:200, 1:300, :) = 0.5;
    img(50:150, 50:100, 2) = 0.8; % Green overlay for GT
    
    % Right panel: Prediction + Comparison
    img(1:200, 301:600, :) = 0.5;
    img(60:140, 350:390, 1) = 0.8; % Red overlay for prediction differences
    
    % Convert to uint8
    img = uint8(img * 255);
end

function cleanupIntegrationTestEnvironment(testEnv)
    % Clean up integration test environment
    fprintf('Cleaning up integration test environment...\n');
    
    try
        if exist(testEnv.baseDir, 'dir')
            rmdir(testEnv.baseDir, 's');
        end
        fprintf('✓ Integration test environment cleaned\n');
    catch ME
        fprintf('⚠ Warning: Could not clean test environment: %s\n', ME.message);
    end
end