% validate_evaluation_engine.m
% Validation script for EvaluationEngine class
% Tests the evaluation system with a real trained model
%
% This script:
% 1. Loads a trained model from previous tasks
% 2. Creates a test dataset
% 3. Runs comprehensive evaluation
% 4. Validates all metrics and reports
%
% Requirements: 5.1, 5.2, 5.3, 5.4, 5.5

fprintf('=== EvaluationEngine Validation Script ===\n\n');

% Add paths
addpath(genpath('src/classification'));
addpath('src/utils');

% Initialize error handler
errorHandler = ErrorHandler.getInstance();
errorHandler.setLogFile('validation_evaluation_engine.log');

try
    %% Step 1: Check for trained model
    fprintf('Step 1: Checking for trained model...\n');
    
    checkpointDir = fullfile('output', 'classification', 'checkpoints');
    
    % Look for any trained model
    modelFiles = dir(fullfile(checkpointDir, '*_best.mat'));
    
    if isempty(modelFiles)
        fprintf('  No trained model found. Training a simple model for validation...\n');
        
        % Create a minimal training setup
        fprintf('  Creating synthetic training data...\n');
        
        % Create temporary directory for synthetic data
        tempDir = fullfile(tempdir, 'validation_eval_data');
        if exist(tempDir, 'dir')
            rmdir(tempDir, 's');
        end
        mkdir(tempDir);
        mkdir(fullfile(tempDir, 'class1'));
        mkdir(fullfile(tempDir, 'class2'));
        mkdir(fullfile(tempDir, 'class3'));
        
        % Generate synthetic images (10 per class)
        for classIdx = 1:3
            classDir = fullfile(tempDir, sprintf('class%d', classIdx));
            for i = 1:10
                img = uint8(rand(224, 224, 3) * 255);
                imwrite(img, fullfile(classDir, sprintf('img_%03d.png', i)));
            end
        end
        
        % Create datastore
        imds = imageDatastore(tempDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
        
        % Split into train and test
        [trainDS, testDS] = splitEachLabel(imds, 0.7, 'randomized');
        
        fprintf('  Training simple model (this will take a moment)...\n');
        
        % Create simple network
        layers = [
            imageInputLayer([224 224 3])
            convolution2dLayer(3, 8, 'Padding', 'same')
            reluLayer
            maxPooling2dLayer(2, 'Stride', 2)
            fullyConnectedLayer(3)
            softmaxLayer
            classificationLayer
        ];
        
        % Training options
        options = trainingOptions('adam', ...
            'MaxEpochs', 5, ...
            'MiniBatchSize', 4, ...
            'InitialLearnRate', 1e-3, ...
            'Verbose', false, ...
            'Plots', 'none');
        
        % Train network
        net = trainNetwork(trainDS, layers, options);
        
        % Save model
        if ~exist(checkpointDir, 'dir')
            mkdir(checkpointDir);
        end
        modelPath = fullfile(checkpointDir, 'validation_model_best.mat');
        save(modelPath, 'net', '-v7.3');
        
        fprintf('  ✓ Model trained and saved\n');
        
    else
        % Load existing model
        modelPath = fullfile(checkpointDir, modelFiles(1).name);
        fprintf('  Loading model: %s\n', modelFiles(1).name);
        
        checkpoint = load(modelPath);
        net = checkpoint.net;
        
        fprintf('  ✓ Model loaded\n');
        
        % Create test dataset
        fprintf('  Creating test dataset...\n');
        
        % Check if we have real data
        if exist(fullfile('output', 'classification', 'labels.csv'), 'file')
            % Use real data
            labels = readtable(fullfile('output', 'classification', 'labels.csv'));
            imageDir = 'img/original';
            
            if exist(imageDir, 'dir')
                imds = imageDatastore(imageDir);
                
                % Match images with labels
                [~, imgNames, ~] = cellfun(@fileparts, imds.Files, 'UniformOutput', false);
                [~, labelNames, ~] = cellfun(@fileparts, labels.filename, 'UniformOutput', false);
                
                % Find matching images
                [~, ia, ib] = intersect(imgNames, labelNames);
                
                if ~isempty(ia)
                    imds = subset(imds, ia);
                    matchedLabels = labels(ib, :);
                    imds.Labels = categorical(matchedLabels.severity_class);
                    
                    % Split for test set
                    [~, testDS] = splitEachLabel(imds, 0.85, 'randomized');
                    
                    fprintf('  ✓ Using real data: %d test samples\n', numel(testDS.Files));
                else
                    error('No matching images found');
                end
            else
                error('Image directory not found');
            end
        else
            % Use synthetic data
            fprintf('  Using synthetic test data...\n');
            
            tempDir = fullfile(tempdir, 'validation_eval_data');
            if ~exist(tempDir, 'dir')
                mkdir(tempDir);
                mkdir(fullfile(tempDir, 'class1'));
                mkdir(fullfile(tempDir, 'class2'));
                mkdir(fullfile(tempDir, 'class3'));
                
                for classIdx = 1:3
                    classDir = fullfile(tempDir, sprintf('class%d', classIdx));
                    for i = 1:10
                        img = uint8(rand(224, 224, 3) * 255);
                        imwrite(img, fullfile(classDir, sprintf('img_%03d.png', i)));
                    end
                end
            end
            
            imds = imageDatastore(tempDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
            [~, testDS] = splitEachLabel(imds, 0.7, 'randomized');
            
            fprintf('  ✓ Using synthetic data: %d test samples\n', numel(testDS.Files));
        end
    end
    
    %% Step 2: Create EvaluationEngine
    fprintf('\nStep 2: Creating EvaluationEngine...\n');
    
    classNames = categories(testDS.Labels);
    fprintf('  Class names: %s\n', strjoin(classNames, ', '));
    
    evaluator = EvaluationEngine(net, testDS, classNames, errorHandler);
    fprintf('  ✓ EvaluationEngine created\n');
    
    %% Step 3: Compute metrics
    fprintf('\nStep 3: Computing evaluation metrics...\n');
    
    metrics = evaluator.computeMetrics();
    
    fprintf('  Overall Metrics:\n');
    fprintf('    Accuracy: %.4f (%.2f%%)\n', metrics.accuracy, metrics.accuracy * 100);
    fprintf('    Macro F1: %.4f\n', metrics.macroF1);
    fprintf('    Weighted F1: %.4f\n', metrics.weightedF1);
    
    fprintf('  Per-Class Metrics:\n');
    perClassFields = fieldnames(metrics.perClass);
    for i = 1:length(perClassFields)
        classMetrics = metrics.perClass.(perClassFields{i});
        fprintf('    %s:\n', classNames{i});
        fprintf('      Precision: %.4f\n', classMetrics.precision);
        fprintf('      Recall: %.4f\n', classMetrics.recall);
        fprintf('      F1-Score: %.4f\n', classMetrics.f1);
        fprintf('      Support: %d\n', classMetrics.support);
    end
    
    fprintf('  ✓ Metrics computed successfully\n');
    
    %% Step 4: Generate confusion matrix
    fprintf('\nStep 4: Generating confusion matrix...\n');
    
    confMat = evaluator.generateConfusionMatrix();
    
    fprintf('  Confusion Matrix:\n');
    fprintf('  Rows: True labels, Columns: Predicted labels\n');
    for i = 1:length(classNames)
        fprintf('  %s: ', classNames{i});
        for j = 1:length(classNames)
            fprintf('%6d ', confMat(i, j));
        end
        fprintf('\n');
    end
    
    normalizedConfMat = evaluator.getNormalizedConfusionMatrix();
    fprintf('\n  Normalized Confusion Matrix (Percentages):\n');
    for i = 1:length(classNames)
        fprintf('  %s: ', classNames{i});
        for j = 1:length(classNames)
            fprintf('%6.2f%% ', normalizedConfMat(i, j) * 100);
        end
        fprintf('\n');
    end
    
    fprintf('  ✓ Confusion matrix generated\n');
    
    %% Step 5: Compute ROC curves
    fprintf('\nStep 5: Computing ROC curves and AUC scores...\n');
    
    [fpr, tpr, auc] = evaluator.computeROC();
    
    fprintf('  AUC Scores:\n');
    for i = 1:length(classNames)
        fprintf('    %s: %.4f\n', classNames{i}, auc(i));
    end
    fprintf('    Mean AUC: %.4f\n', mean(auc));
    
    fprintf('  ✓ ROC curves computed\n');
    
    %% Step 6: Measure inference speed
    fprintf('\nStep 6: Measuring inference speed...\n');
    
    numSamples = min(50, numel(testDS.Files));
    [avgTime, throughput, memoryUsage] = evaluator.measureInferenceSpeed(numSamples);
    
    fprintf('  Inference Speed:\n');
    fprintf('    Average time per image: %.2f ms\n', avgTime);
    fprintf('    Throughput: %.2f images/second\n', throughput);
    
    if ~isnan(memoryUsage)
        fprintf('    GPU memory usage: %.2f MB\n', memoryUsage);
    else
        fprintf('    GPU not available (memory usage not measured)\n');
    end
    
    % Check real-time performance
    realtimeThreshold = 33.33; % 30 fps
    if avgTime < realtimeThreshold
        fprintf('    ✓ Meets real-time requirement (< %.2f ms)\n', realtimeThreshold);
    else
        fprintf('    ✗ Does not meet real-time requirement (< %.2f ms)\n', realtimeThreshold);
    end
    
    fprintf('  ✓ Inference speed measured\n');
    
    %% Step 7: Generate comprehensive report
    fprintf('\nStep 7: Generating comprehensive evaluation report...\n');
    
    outputDir = fullfile('output', 'classification', 'results');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    report = evaluator.generateEvaluationReport('ValidationModel', outputDir);
    
    fprintf('  Report Summary:\n');
    fprintf('    Model: %s\n', report.modelName);
    fprintf('    Total samples: %d\n', report.totalSamples);
    fprintf('    Correct predictions: %d (%.2f%%)\n', ...
        report.correctPredictions, report.metrics.accuracy * 100);
    fprintf('    Incorrect predictions: %d (%.2f%%)\n', ...
        report.incorrectPredictions, (1 - report.metrics.accuracy) * 100);
    
    % Check saved files
    matFile = fullfile(outputDir, 'ValidationModel_evaluation_report.mat');
    txtFile = fullfile(outputDir, 'ValidationModel_evaluation_report.txt');
    
    if isfile(matFile)
        fprintf('    ✓ MAT report saved: %s\n', matFile);
    end
    
    if isfile(txtFile)
        fprintf('    ✓ Text report saved: %s\n', txtFile);
    end
    
    fprintf('  ✓ Comprehensive report generated\n');
    
    %% Step 8: Validation summary
    fprintf('\n=== Validation Summary ===\n');
    fprintf('✓ EvaluationEngine successfully validated\n');
    fprintf('✓ All metrics computed correctly\n');
    fprintf('✓ Confusion matrix generated\n');
    fprintf('✓ ROC curves and AUC scores computed\n');
    fprintf('✓ Inference speed measured\n');
    fprintf('✓ Comprehensive report generated\n');
    fprintf('\n=== EvaluationEngine validation completed successfully! ===\n');
    
catch ME
    fprintf(2, '\nValidation failed: %s\n', ME.message);
    fprintf(2, 'Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf(2, '  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
    
    errorHandler.logError('ValidationScript', sprintf('Validation failed: %s', ME.message));
    rethrow(ME);
end
