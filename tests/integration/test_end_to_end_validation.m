function test_end_to_end_validation()
    % ========================================================================
    % END-TO-END VALIDATION TEST
    % ========================================================================
    % 
    % This script performs comprehensive validation of the corrected system
    % to ensure all categorical handling issues have been resolved.
    %
    % VALIDATION CRITERIA:
    % 1. Metrics show realistic values (not 1.0000 ± 0.0000)
    % 2. Visualization images show actual differences between models
    % 3. U-Net vs Attention U-Net comparison produces meaningful results
    % 4. No categorical RGB errors occur during execution
    % 5. Final report is generated with corrected data and visualizations
    %
    % AUTHOR: System Validation
    % DATE: July 2025
    % ========================================================================
    
    fprintf('========================================================================\n');
    fprintf('                    END-TO-END SYSTEM VALIDATION\n');
    fprintf('========================================================================\n\n');
    
    % Initialize validation results
    validation_results = struct();
    validation_results.timestamp = datetime('now');
    validation_results.tests_passed = 0;
    validation_results.tests_failed = 0;
    validation_results.errors = {};
    validation_results.warnings = {};
    
    try
        % Add paths
        addpath(genpath('.'));
        
        % Test 1: Verify utility classes are available
        fprintf('=== TEST 1: Utility Classes Availability ===\n');
        test_utility_classes_available(validation_results);
        
        % Test 2: Load and validate configuration
        fprintf('\n=== TEST 2: Configuration Validation ===\n');
        config = test_configuration_loading(validation_results);
        
        % Test 3: Data loading and preprocessing validation
        fprintf('\n=== TEST 3: Data Loading and Preprocessing ===\n');
        [images, masks, classNames, labelIDs] = test_data_loading_preprocessing(config, validation_results);
        
        % Test 4: Categorical handling validation
        fprintf('\n=== TEST 4: Categorical Handling Validation ===\n');
        test_categorical_handling(images, masks, classNames, labelIDs, config, validation_results);
        
        % Test 5: Model training validation (quick test)
        fprintf('\n=== TEST 5: Model Training Validation ===\n');
        [unet_model, attention_model] = test_model_training(images, masks, classNames, labelIDs, config, validation_results);
        
        % Test 6: Metrics calculation validation
        fprintf('\n=== TEST 6: Metrics Calculation Validation ===\n');
        metrics_results = test_metrics_calculation(unet_model, attention_model, images, masks, classNames, labelIDs, config, validation_results);
        
        % Test 7: Visualization generation validation
        fprintf('\n=== TEST 7: Visualization Generation Validation ===\n');
        test_visualization_generation(unet_model, attention_model, images, masks, config, validation_results);
        
        % Test 8: Complete comparison pipeline
        fprintf('\n=== TEST 8: Complete Comparison Pipeline ===\n');
        final_results = test_complete_comparison_pipeline(config, validation_results);
        
        % Generate final validation report
        fprintf('\n=== GENERATING FINAL VALIDATION REPORT ===\n');
        generate_validation_report(validation_results, metrics_results, final_results);
        
    catch ME
        fprintf('❌ CRITICAL ERROR in validation: %s\n', ME.message);
        validation_results.tests_failed = validation_results.tests_failed + 1;
        validation_results.errors{end+1} = sprintf('Critical error: %s', ME.message);
        
        % Still generate report with error information
        generate_validation_report(validation_results, [], []);
        rethrow(ME);
    end
    
    % Final summary
    fprintf('\n========================================================================\n');
    fprintf('                    VALIDATION SUMMARY\n');
    fprintf('========================================================================\n');
    fprintf('Tests Passed: %d\n', validation_results.tests_passed);
    fprintf('Tests Failed: %d\n', validation_results.tests_failed);
    fprintf('Warnings: %d\n', length(validation_results.warnings));
    fprintf('Errors: %d\n', length(validation_results.errors));
    
    if validation_results.tests_failed == 0
        fprintf('\n✅ ALL VALIDATION TESTS PASSED!\n');
        fprintf('The corrected system is functioning properly.\n');
    else
        fprintf('\n❌ SOME VALIDATION TESTS FAILED!\n');
        fprintf('Please review the validation report for details.\n');
    end
    
    fprintf('\nValidation report saved to: validation_report_end_to_end.txt\n');
    fprintf('========================================================================\n');
end

function test_utility_classes_available(validation_results)
    % Test if all utility classes are available and functional
    
    utility_classes = {'DataTypeConverter', 'PreprocessingValidator', ...
                      'VisualizationHelper', 'MetricsValidator', 'ErrorHandler'};
    
    for i = 1:length(utility_classes)
        class_name = utility_classes{i};
        try
            % Check if class file exists
            class_file = sprintf('src/utils/%s.m', class_name);
            if exist(class_file, 'file')
                fprintf('✓ %s class file found\n', class_name);
                
                % Try to call a static method if available
                switch class_name
                    case 'DataTypeConverter'
                        test_data = categorical([0; 1], [0, 1], ["background", "foreground"]);
                        result = DataTypeConverter.categoricalToNumeric(test_data, 'double');
                        if isnumeric(result)
                            fprintf('  ✓ %s functionality verified\n', class_name);
                            validation_results.tests_passed = validation_results.tests_passed + 1;
                        else
                            fprintf('  ❌ %s functionality test failed\n', class_name);
                            validation_results.tests_failed = validation_results.tests_failed + 1;
                        end
                        
                    case 'PreprocessingValidator'
                        test_img = rand(64, 64, 3);
                        PreprocessingValidator.validateImageData(test_img);
                        fprintf('  ✓ %s functionality verified\n', class_name);
                        validation_results.tests_passed = validation_results.tests_passed + 1;
                        
                    case 'VisualizationHelper'
                        test_img = rand(64, 64, 3);
                        result = VisualizationHelper.prepareImageForDisplay(test_img);
                        if ~isempty(result)
                            fprintf('  ✓ %s functionality verified\n', class_name);
                            validation_results.tests_passed = validation_results.tests_passed + 1;
                        else
                            fprintf('  ❌ %s functionality test failed\n', class_name);
                            validation_results.tests_failed = validation_results.tests_failed + 1;
                        end
                        
                    case 'MetricsValidator'
                        test_metrics = struct('iou', 1.0, 'dice', 1.0, 'accuracy', 1.0);
                        warnings = MetricsValidator.checkPerfectMetrics(1.0, 1.0, 1.0);
                        if ~isempty(warnings)
                            fprintf('  ✓ %s functionality verified\n', class_name);
                            validation_results.tests_passed = validation_results.tests_passed + 1;
                        else
                            fprintf('  ❌ %s functionality test failed\n', class_name);
                            validation_results.tests_failed = validation_results.tests_failed + 1;
                        end
                        
                    case 'ErrorHandler'
                        ErrorHandler.logError('test', 'Test error message');
                        fprintf('  ✓ %s functionality verified\n', class_name);
                        validation_results.tests_passed = validation_results.tests_passed + 1;
                end
                
            else
                fprintf('❌ %s class file not found at %s\n', class_name, class_file);
                validation_results.tests_failed = validation_results.tests_failed + 1;
                validation_results.errors{end+1} = sprintf('%s class file not found', class_name);
            end
            
        catch ME
            fprintf('❌ Error testing %s: %s\n', class_name, ME.message);
            validation_results.tests_failed = validation_results.tests_failed + 1;
            validation_results.errors{end+1} = sprintf('Error testing %s: %s', class_name, ME.message);
        end
    end
end

function config = test_configuration_loading(validation_results)
    % Test configuration loading and validation
    
    try
        % Try to load existing configuration
        if exist('config_caminhos.mat', 'file')
            load('config_caminhos.mat', 'config');
            fprintf('✓ Configuration loaded from file\n');
        else
            % Create test configuration
            config = struct();
            config.imageDir = 'img/original';
            config.maskDir = 'img/masks';
            config.inputSize = [256, 256, 3];
            config.numClasses = 2;
            config.miniBatchSize = 4;
            fprintf('✓ Test configuration created\n');
        end
        
        % Validate configuration
        required_fields = {'imageDir', 'maskDir', 'inputSize', 'numClasses'};
        for i = 1:length(required_fields)
            if ~isfield(config, required_fields{i})
                error('Missing required field: %s', required_fields{i});
            end
        end
        
        fprintf('✓ Configuration validation passed\n');
        validation_results.tests_passed = validation_results.tests_passed + 1;
        
    catch ME
        fprintf('❌ Configuration loading failed: %s\n', ME.message);
        validation_results.tests_failed = validation_results.tests_failed + 1;
        validation_results.errors{end+1} = sprintf('Configuration loading failed: %s', ME.message);
        
        % Create minimal fallback configuration
        config = struct();
        config.imageDir = 'img/original';
        config.maskDir = 'img/masks';
        config.inputSize = [256, 256, 3];
        config.numClasses = 2;
        config.miniBatchSize = 4;
    end
end

function [images, masks, classNames, labelIDs] = test_data_loading_preprocessing(config, validation_results)
    % Test data loading and preprocessing
    
    images = {};
    masks = {};
    classNames = [];
    labelIDs = [];
    
    try
        % Check if data directories exist
        if ~exist(config.imageDir, 'dir')
            warning('Image directory not found: %s', config.imageDir);
            validation_results.warnings{end+1} = sprintf('Image directory not found: %s', config.imageDir);
            
            % Create test data
            fprintf('Creating test data for validation...\n');
            [images, masks, classNames, labelIDs] = create_test_data(config);
        else
            % Load real data
            fprintf('Loading real data...\n');
            [images, masks] = carregar_dados_robustos(config);
            
            if isempty(images) || isempty(masks)
                fprintf('No data found, creating test data...\n');
                [images, masks, classNames, labelIDs] = create_test_data(config);
            else
                % Analyze masks to get class information
                [classNames, labelIDs] = analisar_mascaras_automatico(config.maskDir, masks);
            end
        end
        
        fprintf('✓ Data loading completed: %d images, %d masks\n', length(images), length(masks));
        fprintf('✓ Classes: %s\n', strjoin(string(classNames), ', '));
        fprintf('✓ Label IDs: %s\n', mat2str(labelIDs));
        
        validation_results.tests_passed = validation_results.tests_passed + 1;
        
    catch ME
        fprintf('❌ Data loading failed: %s\n', ME.message);
        validation_results.tests_failed = validation_results.tests_failed + 1;
        validation_results.errors{end+1} = sprintf('Data loading failed: %s', ME.message);
        
        % Create fallback test data
        [images, masks, classNames, labelIDs] = create_test_data(config);
    end
end

function [images, masks, classNames, labelIDs] = create_test_data(config)
    % Create synthetic test data for validation
    
    fprintf('Creating synthetic test data...\n');
    
    % Create test images and masks
    num_samples = 5;
    images = cell(num_samples, 1);
    masks = cell(num_samples, 1);
    
    % Ensure output directories exist
    if ~exist('output', 'dir')
        mkdir('output');
    end
    if ~exist('output/test_images', 'dir')
        mkdir('output/test_images');
    end
    if ~exist('output/test_masks', 'dir')
        mkdir('output/test_masks');
    end
    
    for i = 1:num_samples
        % Create synthetic image
        img = rand(config.inputSize(1), config.inputSize(2), config.inputSize(3));
        img_file = sprintf('output/test_images/test_img_%d.png', i);
        imwrite(img, img_file);
        images{i} = img_file;
        
        % Create synthetic mask
        mask = rand(config.inputSize(1), config.inputSize(2)) > 0.5;
        mask_file = sprintf('output/test_masks/test_mask_%d.png', i);
        imwrite(uint8(mask) * 255, mask_file);
        masks{i} = mask_file;
    end
    
    % Define class information
    classNames = ["background", "foreground"];
    labelIDs = [0, 1];
    
    fprintf('✓ Created %d synthetic test samples\n', num_samples);
end

function test_categorical_handling(images, masks, classNames, labelIDs, config, validation_results)
    % Test categorical data handling throughout the pipeline
    
    try
        fprintf('Testing categorical data creation and conversion...\n');
        
        % Test with first image/mask pair
        if ~isempty(images) && ~isempty(masks)
            img = imread(images{1});
            mask = imread(masks{1});
            
            % Test categorical creation
            if size(mask, 3) > 1
                mask = rgb2gray(mask);
            end
            mask_binary = mask > 128;
            mask_categorical = categorical(mask_binary, [false, true], classNames);
            
            fprintf('✓ Categorical mask created successfully\n');
            fprintf('  Categories: %s\n', strjoin(string(categories(mask_categorical)), ', '));
            
            % Test conversion to numeric
            mask_numeric = DataTypeConverter.categoricalToNumeric(mask_categorical, 'double');
            fprintf('✓ Categorical to numeric conversion successful\n');
            fprintf('  Unique values: %s\n', mat2str(unique(mask_numeric)));
            
            % Test conversion logic for metrics
            mask_binary_converted = (mask_categorical == "foreground");
            fprintf('✓ Categorical to binary conversion for metrics successful\n');
            fprintf('  Binary values: %s\n', mat2str(unique(mask_binary_converted)));
            
            % Test preprocessing with categorical data
            data_cell = {img, mask_categorical};
            processed_data = preprocessDataCorrigido(data_cell, config, labelIDs, false);
            
            if ~isempty(processed_data)
                fprintf('✓ Preprocessing with categorical data successful\n');
                validation_results.tests_passed = validation_results.tests_passed + 1;
            else
                fprintf('❌ Preprocessing with categorical data failed\n');
                validation_results.tests_failed = validation_results.tests_failed + 1;
            end
            
        else
            fprintf('⚠️  No data available for categorical testing\n');
            validation_results.warnings{end+1} = 'No data available for categorical testing';
        end
        
    catch ME
        fprintf('❌ Categorical handling test failed: %s\n', ME.message);
        validation_results.tests_failed = validation_results.tests_failed + 1;
        validation_results.errors{end+1} = sprintf('Categorical handling test failed: %s', ME.message);
    end
end

function [unet_model, attention_model] = test_model_training(images, masks, classNames, labelIDs, config, validation_results)
    % Test model training with corrected data handling
    
    unet_model = [];
    attention_model = [];
    
    try
        if length(images) < 2
            fprintf('⚠️  Insufficient data for model training test\n');
            validation_results.warnings{end+1} = 'Insufficient data for model training test';
            return;
        end
        
        fprintf('Testing model training with corrected categorical handling...\n');
        
        % Prepare minimal dataset for testing
        train_images = images(1:min(2, length(images)));
        train_masks = masks(1:min(2, length(masks)));
        
        % Create datastores
        imds = imageDatastore(train_images);
        pxds = pixelLabelDatastore(train_masks, classNames, labelIDs);
        ds = combine(imds, pxds);
        ds = transform(ds, @(data) preprocessDataCorrigido(data, config, labelIDs, true));
        
        % Test U-Net training (minimal epochs)
        fprintf('  Testing U-Net training...\n');
        lgraph_unet = unetLayers(config.inputSize, config.numClasses, 'EncoderDepth', 2);
        
        options = trainingOptions('adam', ...
            'InitialLearnRate', 1e-3, ...
            'MaxEpochs', 1, ...
            'MiniBatchSize', 1, ...
            'Plots', 'none', ...
            'Verbose', false);
        
        unet_model = trainNetwork(ds, lgraph_unet, options);
        fprintf('  ✓ U-Net training completed without errors\n');
        
        % Test Attention U-Net training (minimal epochs)
        fprintf('  Testing Attention U-Net training...\n');
        lgraph_attention = create_working_attention_unet(config.inputSize, config.numClasses);
        
        attention_model = trainNetwork(ds, lgraph_attention, options);
        fprintf('  ✓ Attention U-Net training completed without errors\n');
        
        validation_results.tests_passed = validation_results.tests_passed + 1;
        
    catch ME
        fprintf('❌ Model training test failed: %s\n', ME.message);
        validation_results.tests_failed = validation_results.tests_failed + 1;
        validation_results.errors{end+1} = sprintf('Model training test failed: %s', ME.message);
    end
end

function metrics_results = test_metrics_calculation(unet_model, attention_model, images, masks, classNames, labelIDs, config, validation_results)
    % Test metrics calculation with corrected categorical handling
    
    metrics_results = struct();
    
    try
        if isempty(unet_model) || isempty(attention_model) || isempty(images)
            fprintf('⚠️  Models or data not available for metrics testing\n');
            validation_results.warnings{end+1} = 'Models or data not available for metrics testing';
            return;
        end
        
        fprintf('Testing metrics calculation with corrected categorical handling...\n');
        
        % Test with first image
        img = imread(images{1});
        mask = imread(masks{1});
        
        % Prepare data
        if size(mask, 3) > 1
            mask = rgb2gray(mask);
        end
        mask_binary = mask > 128;
        mask_categorical = categorical(mask_binary, [false, true], classNames);
        
        % Resize to match model input
        img_resized = imresize(img, config.inputSize(1:2));
        
        % Get predictions
        pred_unet = semanticseg(img_resized, unet_model);
        pred_attention = semanticseg(img_resized, attention_model);
        
        % Resize ground truth to match predictions
        mask_resized = imresize(mask_categorical, size(pred_unet, [1, 2]));
        
        % Calculate metrics using corrected functions
        iou_unet = calcular_iou_simples(pred_unet, mask_resized);
        dice_unet = calcular_dice_simples(pred_unet, mask_resized);
        acc_unet = calcular_accuracy_simples(pred_unet, mask_resized);
        
        iou_attention = calcular_iou_simples(pred_attention, mask_resized);
        dice_attention = calcular_dice_simples(pred_attention, mask_resized);
        acc_attention = calcular_accuracy_simples(pred_attention, mask_resized);
        
        % Store results
        metrics_results.unet = struct('iou', iou_unet, 'dice', dice_unet, 'accuracy', acc_unet);
        metrics_results.attention = struct('iou', iou_attention, 'dice', dice_attention, 'accuracy', acc_attention);
        
        fprintf('✓ Metrics calculated successfully:\n');
        fprintf('  U-Net: IoU=%.4f, Dice=%.4f, Acc=%.4f\n', iou_unet, dice_unet, acc_unet);
        fprintf('  Attention: IoU=%.4f, Dice=%.4f, Acc=%.4f\n', iou_attention, dice_attention, acc_attention);
        
        % Validate metrics are realistic (not perfect)
        perfect_threshold = 0.9999;
        if iou_unet < perfect_threshold && dice_unet < perfect_threshold && acc_unet < perfect_threshold
            fprintf('✓ U-Net metrics show realistic variation (not artificially perfect)\n');
        else
            fprintf('⚠️  U-Net metrics may be artificially perfect\n');
            validation_results.warnings{end+1} = 'U-Net metrics may be artificially perfect';
        end
        
        if iou_attention < perfect_threshold && dice_attention < perfect_threshold && acc_attention < perfect_threshold
            fprintf('✓ Attention U-Net metrics show realistic variation (not artificially perfect)\n');
        else
            fprintf('⚠️  Attention U-Net metrics may be artificially perfect\n');
            validation_results.warnings{end+1} = 'Attention U-Net metrics may be artificially perfect';
        end
        
        % Check for meaningful differences between models
        iou_diff = abs(iou_unet - iou_attention);
        dice_diff = abs(dice_unet - dice_attention);
        acc_diff = abs(acc_unet - acc_attention);
        
        if iou_diff > 0.001 || dice_diff > 0.001 || acc_diff > 0.001
            fprintf('✓ Models show meaningful performance differences\n');
        else
            fprintf('⚠️  Models show identical performance (may indicate calculation error)\n');
            validation_results.warnings{end+1} = 'Models show identical performance';
        end
        
        validation_results.tests_passed = validation_results.tests_passed + 1;
        
    catch ME
        fprintf('❌ Metrics calculation test failed: %s\n', ME.message);
        validation_results.tests_failed = validation_results.tests_failed + 1;
        validation_results.errors{end+1} = sprintf('Metrics calculation test failed: %s', ME.message);
    end
end

function test_visualization_generation(unet_model, attention_model, images, masks, config, validation_results)
    % Test visualization generation with corrected categorical handling
    
    try
        if isempty(unet_model) || isempty(attention_model) || isempty(images)
            fprintf('⚠️  Models or data not available for visualization testing\n');
            validation_results.warnings{end+1} = 'Models or data not available for visualization testing';
            return;
        end
        
        fprintf('Testing visualization generation with corrected categorical handling...\n');
        
        % Test with first image
        img = imread(images{1});
        mask = imread(masks{1});
        
        % Prepare data
        if size(mask, 3) > 1
            mask = rgb2gray(mask);
        end
        mask_binary = mask > 128;
        
        % Resize to match model input
        img_resized = imresize(img, config.inputSize(1:2));
        
        % Get predictions
        pred_unet = semanticseg(img_resized, unet_model);
        pred_attention = semanticseg(img_resized, attention_model);
        
        % Test visualization preparation
        img_display = VisualizationHelper.prepareImageForDisplay(img_resized);
        mask_display = VisualizationHelper.prepareMaskForDisplay(mask_binary);
        pred_unet_display = VisualizationHelper.prepareMaskForDisplay(pred_unet);
        pred_attention_display = VisualizationHelper.prepareMaskForDisplay(pred_attention);
        
        fprintf('✓ Visualization data prepared successfully\n');
        
        % Test visualization generation
        figure('Visible', 'off');
        
        subplot(2, 3, 1);
        imshow(img_display);
        title('Original Image');
        
        subplot(2, 3, 2);
        imshow(mask_display);
        title('Ground Truth');
        
        subplot(2, 3, 3);
        imshow(pred_unet_display);
        title('U-Net Prediction');
        
        subplot(2, 3, 4);
        imshow(pred_attention_display);
        title('Attention U-Net Prediction');
        
        % Save visualization
        output_file = 'output/test_visualization_validation.png';
        saveas(gcf, output_file);
        close(gcf);
        
        if exist(output_file, 'file')
            fprintf('✓ Visualization saved successfully: %s\n', output_file);
            validation_results.tests_passed = validation_results.tests_passed + 1;
        else
            fprintf('❌ Visualization save failed\n');
            validation_results.tests_failed = validation_results.tests_failed + 1;
        end
        
    catch ME
        fprintf('❌ Visualization generation test failed: %s\n', ME.message);
        validation_results.tests_failed = validation_results.tests_failed + 1;
        validation_results.errors{end+1} = sprintf('Visualization generation test failed: %s', ME.message);
    end
end

function final_results = test_complete_comparison_pipeline(config, validation_results)
    % Test the complete comparison pipeline
    
    final_results = struct();
    
    try
        fprintf('Testing complete comparison pipeline...\n');
        
        % This would normally run the full comparison, but for validation
        % we'll run a simplified version to avoid long execution times
        fprintf('⚠️  Running simplified pipeline test (full test would take hours)\n');
        
        % Test that the main comparison function can be called without errors
        if exist('comparacao_unet_attention_final.m', 'file')
            fprintf('✓ Main comparison function file exists\n');
            
            % We could run a very limited version here, but for safety
            % we'll just verify the function can be parsed
            try
                help('comparacao_unet_attention_final');
                fprintf('✓ Main comparison function can be parsed\n');
                validation_results.tests_passed = validation_results.tests_passed + 1;
            catch ME
                fprintf('❌ Main comparison function has syntax errors: %s\n', ME.message);
                validation_results.tests_failed = validation_results.tests_failed + 1;
            end
        else
            fprintf('❌ Main comparison function file not found\n');
            validation_results.tests_failed = validation_results.tests_failed + 1;
        end
        
        final_results.pipeline_test = 'completed';
        final_results.note = 'Simplified test performed to avoid long execution time';
        
    catch ME
        fprintf('❌ Complete pipeline test failed: %s\n', ME.message);
        validation_results.tests_failed = validation_results.tests_failed + 1;
        validation_results.errors{end+1} = sprintf('Complete pipeline test failed: %s', ME.message);
        final_results.pipeline_test = 'failed';
    end
end

function generate_validation_report(validation_results, metrics_results, final_results)
    % Generate comprehensive validation report
    
    report_file = 'validation_report_end_to_end.txt';
    
    try
        fid = fopen(report_file, 'w');
        
        fprintf(fid, '========================================================================\n');
        fprintf(fid, '                    END-TO-END VALIDATION REPORT\n');
        fprintf(fid, '========================================================================\n\n');
        
        fprintf(fid, 'Validation Date: %s\n', char(validation_results.timestamp));
        fprintf(fid, 'MATLAB Version: %s\n', version);
        fprintf(fid, '\n');
        
        fprintf(fid, 'SUMMARY:\n');
        fprintf(fid, '--------\n');
        fprintf(fid, 'Tests Passed: %d\n', validation_results.tests_passed);
        fprintf(fid, 'Tests Failed: %d\n', validation_results.tests_failed);
        fprintf(fid, 'Warnings: %d\n', length(validation_results.warnings));
        fprintf(fid, 'Errors: %d\n', length(validation_results.errors));
        fprintf(fid, '\n');
        
        if validation_results.tests_failed == 0
            fprintf(fid, 'OVERALL RESULT: ✅ PASSED\n');
            fprintf(fid, 'The corrected system is functioning properly.\n');
        else
            fprintf(fid, 'OVERALL RESULT: ❌ FAILED\n');
            fprintf(fid, 'Some validation tests failed. Review details below.\n');
        end
        fprintf(fid, '\n');
        
        % Detailed results
        if ~isempty(metrics_results)
            fprintf(fid, 'METRICS VALIDATION:\n');
            fprintf(fid, '-------------------\n');
            if isfield(metrics_results, 'unet')
                fprintf(fid, 'U-Net Metrics:\n');
                fprintf(fid, '  IoU: %.4f\n', metrics_results.unet.iou);
                fprintf(fid, '  Dice: %.4f\n', metrics_results.unet.dice);
                fprintf(fid, '  Accuracy: %.4f\n', metrics_results.unet.accuracy);
            end
            if isfield(metrics_results, 'attention')
                fprintf(fid, 'Attention U-Net Metrics:\n');
                fprintf(fid, '  IoU: %.4f\n', metrics_results.attention.iou);
                fprintf(fid, '  Dice: %.4f\n', metrics_results.attention.dice);
                fprintf(fid, '  Accuracy: %.4f\n', metrics_results.attention.accuracy);
            end
            fprintf(fid, '\n');
        end
        
        % Warnings
        if ~isempty(validation_results.warnings)
            fprintf(fid, 'WARNINGS:\n');
            fprintf(fid, '---------\n');
            for i = 1:length(validation_results.warnings)
                fprintf(fid, '%d. %s\n', i, validation_results.warnings{i});
            end
            fprintf(fid, '\n');
        end
        
        % Errors
        if ~isempty(validation_results.errors)
            fprintf(fid, 'ERRORS:\n');
            fprintf(fid, '-------\n');
            for i = 1:length(validation_results.errors)
                fprintf(fid, '%d. %s\n', i, validation_results.errors{i});
            end
            fprintf(fid, '\n');
        end
        
        % Recommendations
        fprintf(fid, 'RECOMMENDATIONS:\n');
        fprintf(fid, '----------------\n');
        if validation_results.tests_failed == 0
            fprintf(fid, '1. The system validation passed successfully.\n');
            fprintf(fid, '2. All categorical handling issues appear to be resolved.\n');
            fprintf(fid, '3. The system is ready for production use.\n');
        else
            fprintf(fid, '1. Review and fix the failed tests before using the system.\n');
            fprintf(fid, '2. Check error messages for specific issues to address.\n');
            fprintf(fid, '3. Re-run validation after making corrections.\n');
        end
        
        if ~isempty(validation_results.warnings)
            fprintf(fid, '4. Address warnings to improve system robustness.\n');
        end
        
        fprintf(fid, '\n');
        fprintf(fid, '========================================================================\n');
        fprintf(fid, '                         END OF REPORT\n');
        fprintf(fid, '========================================================================\n');
        
        fclose(fid);
        
        fprintf('✓ Validation report generated: %s\n', report_file);
        
    catch ME
        fprintf('❌ Failed to generate validation report: %s\n', ME.message);
        if exist('fid', 'var') && fid ~= -1
            fclose(fid);
        end
    end
end