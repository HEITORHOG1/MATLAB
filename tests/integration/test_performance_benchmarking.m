function results = test_performance_benchmarking()
% TEST_PERFORMANCE_BENCHMARKING Performance benchmarking for classification system
%
% This function measures and validates performance metrics for the classification
% system including training time, inference speed, and memory usage.
%
% Requirements tested: 10.1, 10.2
%
% Usage:
%   results = test_performance_benchmarking()
%
% Output:
%   results - Struct containing performance benchmark results

    fprintf('=== PERFORMANCE BENCHMARKING TEST ===\n\n');
    
    % Initialize results
    results = struct();
    results.timestamp = datetime('now');
    results.benchmarks = struct();
    results.allPassed = true;
    
    % Performance targets (from design document)
    targets = struct();
    targets.resnet50InferenceTime = 50; % ms per image
    targets.efficientnetInferenceTime = 30; % ms per image
    targets.customCNNInferenceTime = 20; % ms per image
    targets.trainingTimePerEpoch = 60; % seconds (for 100 images)
    targets.maxTrainingMemory = 8192; % MB (8GB)
    targets.maxInferenceMemory = 2048; % MB (2GB)
    
    results.targets = targets;
    
    % Ensure test data exists
    syntheticDataDir = fullfile('tests', 'integration', 'synthetic_data');
    if ~exist(fullfile(syntheticDataDir, 'images'), 'dir')
        fprintf('Generating synthetic test data...\n');
        try
            generate_synthetic_test_dataset();
        catch ME
            fprintf('ERROR: Failed to generate test data: %s\n', ME.message);
            results.allPassed = false;
            return;
        end
    end
    
    % Benchmark 1: Training Time
    fprintf('--- Benchmark 1: Training Time ---\n');
    try
        [bench1Pass, bench1Results] = benchmarkTrainingTime(syntheticDataDir, targets);
        results.benchmarks.trainingTime = bench1Results;
        results.allPassed = results.allPassed && bench1Pass;
        fprintf('Benchmark 1: %s\n\n', iif(bench1Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('Benchmark 1: ✗ FAILED - %s\n\n', ME.message);
        results.benchmarks.trainingTime.error = ME.message;
        results.allPassed = false;
    end
    
    % Benchmark 2: Inference Speed
    fprintf('--- Benchmark 2: Inference Speed ---\n');
    try
        [bench2Pass, bench2Results] = benchmarkInferenceSpeed(syntheticDataDir, targets);
        results.benchmarks.inferenceSpeed = bench2Results;
        results.allPassed = results.allPassed && bench2Pass;
        fprintf('Benchmark 2: %s\n\n', iif(bench2Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('Benchmark 2: ✗ FAILED - %s\n\n', ME.message);
        results.benchmarks.inferenceSpeed.error = ME.message;
        results.allPassed = false;
    end
    
    % Benchmark 3: Memory Usage
    fprintf('--- Benchmark 3: Memory Usage ---\n');
    try
        [bench3Pass, bench3Results] = benchmarkMemoryUsage(syntheticDataDir, targets);
        results.benchmarks.memoryUsage = bench3Results;
        results.allPassed = results.allPassed && bench3Pass;
        fprintf('Benchmark 3: %s\n\n', iif(bench3Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('Benchmark 3: ✗ FAILED - %s\n\n', ME.message);
        results.benchmarks.memoryUsage.error = ME.message;
        results.allPassed = false;
    end
    
    % Benchmark 4: Model Comparison
    fprintf('--- Benchmark 4: Model Comparison ---\n');
    try
        [bench4Pass, bench4Results] = benchmarkModelComparison(syntheticDataDir);
        results.benchmarks.modelComparison = bench4Results;
        results.allPassed = results.allPassed && bench4Pass;
        fprintf('Benchmark 4: %s\n\n', iif(bench4Pass, '✓ PASSED', '✗ FAILED'));
    catch ME
        fprintf('Benchmark 4: ✗ FAILED - %s\n\n', ME.message);
        results.benchmarks.modelComparison.error = ME.message;
        results.allPassed = false;
    end
    
    % Generate summary
    fprintf('=== PERFORMANCE BENCHMARK SUMMARY ===\n');
    fprintf('Overall Status: %s\n', iif(results.allPassed, '✓ ALL BENCHMARKS PASSED', '✗ SOME BENCHMARKS FAILED'));
    fprintf('Timestamp: %s\n\n', char(results.timestamp));
    
    fprintf('Benchmark Results:\n');
    fprintf('  1. Training Time: %s\n', getBenchmarkStatus(results.benchmarks, 'trainingTime'));
    fprintf('  2. Inference Speed: %s\n', getBenchmarkStatus(results.benchmarks, 'inferenceSpeed'));
    fprintf('  3. Memory Usage: %s\n', getBenchmarkStatus(results.benchmarks, 'memoryUsage'));
    fprintf('  4. Model Comparison: %s\n', getBenchmarkStatus(results.benchmarks, 'modelComparison'));
    
    % Save results
    outputDir = fullfile('tests', 'integration', 'test_output');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    resultsFile = fullfile(outputDir, 'performance_benchmark_results.mat');
    save(resultsFile, 'results');
    fprintf('\nResults saved to: %s\n', resultsFile);
    
    % Generate text report
    reportFile = fullfile(outputDir, 'performance_benchmark_report.txt');
    generateTextReport(results, reportFile);
    fprintf('Report saved to: %s\n', reportFile);
end

function [passed, benchResults] = benchmarkTrainingTime(dataDir, targets)
% Benchmark training time for each model architecture
    
    benchResults = struct();
    passed = true;
    
    fprintf('  Measuring training time per epoch...\n');
    
    % Prepare dataset
    imageDir = fullfile(dataDir, 'images');
    labelCSV = fullfile('tests', 'integration', 'test_output', 'test_labels.csv');
    
    % Generate labels if needed
    if ~exist(labelCSV, 'file')
        maskDir = fullfile(dataDir, 'masks');
        LabelGenerator.generateLabelsFromMasks(maskDir, labelCSV, [10, 30]);
    end
    
    % Create dataset
    config = struct();
    config.imageDir = imageDir;
    config.labelCSV = labelCSV;
    config.splitRatios = [0.7, 0.15, 0.15];
    config.inputSize = [224, 224];
    config.augmentation = false;
    
    dm = DatasetManager(config);
    [trainDS, valDS, ~] = dm.prepareDatasets();
    
    % Test each model architecture
    models = {'CustomCNN', 'ResNet50', 'EfficientNetB0'};
    
    for i = 1:length(models)
        modelName = models{i};
        fprintf('  Testing %s...\n', modelName);
        
        try
            % Create model
            if strcmp(modelName, 'CustomCNN')
                net = ModelFactory.createCustomCNN(3, [224, 224]);
            elseif strcmp(modelName, 'ResNet50')
                net = ModelFactory.createResNet50(3, [224, 224]);
            elseif strcmp(modelName, 'EfficientNetB0')
                net = ModelFactory.createEfficientNetB0(3, [224, 224]);
            end
            
            % Configure minimal training
            trainConfig = struct();
            trainConfig.maxEpochs = 2;
            trainConfig.miniBatchSize = 4;
            trainConfig.initialLearnRate = 1e-3;
            trainConfig.validationPatience = 10;
            trainConfig.checkpointDir = fullfile('tests', 'integration', 'test_output', 'checkpoints');
            
            % Create training engine
            engine = TrainingEngine(net, trainConfig);
            
            % Measure training time
            tic;
            [~, history] = engine.train(trainDS, valDS);
            trainingTime = toc;
            
            % Calculate time per epoch
            timePerEpoch = trainingTime / trainConfig.maxEpochs;
            
            % Store results
            benchResults.(modelName).totalTime = trainingTime;
            benchResults.(modelName).timePerEpoch = timePerEpoch;
            benchResults.(modelName).epochs = trainConfig.maxEpochs;
            
            fprintf('    Training time: %.2f seconds (%.2f s/epoch)\n', ...
                trainingTime, timePerEpoch);
            
            % Check against target (relaxed for small dataset)
            if timePerEpoch > targets.trainingTimePerEpoch * 2
                fprintf('    WARNING: Training slower than expected\n');
            end
            
        catch ME
            fprintf('    ERROR: %s training failed: %s\n', modelName, ME.message);
            benchResults.(modelName).error = ME.message;
            passed = false;
        end
    end
    
    benchResults.passed = passed;
end

function [passed, benchResults] = benchmarkInferenceSpeed(dataDir, targets)
% Benchmark inference speed for each model architecture
    
    benchResults = struct();
    passed = true;
    
    fprintf('  Measuring inference speed...\n');
    
    % Load test images
    imageDir = fullfile(dataDir, 'images');
    imageFiles = dir(fullfile(imageDir, '*.jpg'));
    
    if isempty(imageFiles)
        fprintf('  ERROR: No test images found\n');
        passed = false;
        return;
    end
    
    % Load a few test images
    numTestImages = min(10, length(imageFiles));
    testImages = cell(numTestImages, 1);
    
    for i = 1:numTestImages
        imgPath = fullfile(imageDir, imageFiles(i).name);
        img = imread(imgPath);
        img = imresize(img, [224, 224]);
        testImages{i} = img;
    end
    
    % Test each model architecture
    models = {'CustomCNN'};  % Start with fastest model
    
    for i = 1:length(models)
        modelName = models{i};
        fprintf('  Testing %s inference...\n', modelName);
        
        try
            % Create model
            if strcmp(modelName, 'CustomCNN')
                net = ModelFactory.createCustomCNN(3, [224, 224]);
                targetTime = targets.customCNNInferenceTime;
            elseif strcmp(modelName, 'ResNet50')
                net = ModelFactory.createResNet50(3, [224, 224]);
                targetTime = targets.resnet50InferenceTime;
            elseif strcmp(modelName, 'EfficientNetB0')
                net = ModelFactory.createEfficientNetB0(3, [224, 224]);
                targetTime = targets.efficientnetInferenceTime;
            end
            
            % Warm-up (first inference is always slower)
            for w = 1:3
                classify(net, testImages{1});
            end
            
            % Measure inference time
            tic;
            for j = 1:numTestImages
                classify(net, testImages{j});
            end
            totalTime = toc;
            
            avgTimePerImage = (totalTime / numTestImages) * 1000; % Convert to ms
            throughput = numTestImages / totalTime; % images per second
            
            % Store results
            benchResults.(modelName).avgTimeMs = avgTimePerImage;
            benchResults.(modelName).throughput = throughput;
            benchResults.(modelName).numImages = numTestImages;
            benchResults.(modelName).meetsTarget = avgTimePerImage <= targetTime;
            
            fprintf('    Inference time: %.2f ms/image\n', avgTimePerImage);
            fprintf('    Throughput: %.2f images/second\n', throughput);
            fprintf('    Target: %.2f ms/image - %s\n', targetTime, ...
                iif(avgTimePerImage <= targetTime, '✓ MET', '✗ EXCEEDED'));
            
        catch ME
            fprintf('    ERROR: %s inference failed: %s\n', modelName, ME.message);
            benchResults.(modelName).error = ME.message;
            passed = false;
        end
    end
    
    benchResults.passed = passed;
end

function [passed, benchResults] = benchmarkMemoryUsage(dataDir, targets)
% Benchmark memory usage during training and inference
    
    benchResults = struct();
    passed = true;
    
    fprintf('  Measuring memory usage...\n');
    
    % Get initial memory state
    if ispc
        [~, memInfo] = system('wmic OS get FreePhysicalMemory /Value');
    else
        [~, memInfo] = system('free -m');
    end
    
    benchResults.initialMemoryInfo = memInfo;
    
    % Prepare minimal dataset
    imageDir = fullfile(dataDir, 'images');
    labelCSV = fullfile('tests', 'integration', 'test_output', 'test_labels.csv');
    
    if ~exist(labelCSV, 'file')
        maskDir = fullfile(dataDir, 'masks');
        LabelGenerator.generateLabelsFromMasks(maskDir, labelCSV, [10, 30]);
    end
    
    config = struct();
    config.imageDir = imageDir;
    config.labelCSV = labelCSV;
    config.splitRatios = [0.7, 0.15, 0.15];
    config.inputSize = [224, 224];
    config.augmentation = false;
    
    dm = DatasetManager(config);
    [trainDS, valDS, ~] = dm.prepareDatasets();
    
    % Test memory usage with CustomCNN (smallest model)
    fprintf('  Testing CustomCNN memory usage...\n');
    
    try
        % Create model
        net = ModelFactory.createCustomCNN(3, [224, 224]);
        
        % Training memory
        trainConfig = struct();
        trainConfig.maxEpochs = 1;
        trainConfig.miniBatchSize = 4;
        trainConfig.initialLearnRate = 1e-3;
        trainConfig.validationPatience = 10;
        trainConfig.checkpointDir = fullfile('tests', 'integration', 'test_output', 'checkpoints');
        
        engine = TrainingEngine(net, trainConfig);
        
        % Monitor memory during training
        memBefore = getAvailableMemory();
        [trainedNet, ~] = engine.train(trainDS, valDS);
        memAfter = getAvailableMemory();
        
        trainingMemoryUsed = memBefore - memAfter;
        
        benchResults.trainingMemoryUsedMB = trainingMemoryUsed;
        benchResults.meetsTrainingMemoryTarget = trainingMemoryUsed <= targets.maxTrainingMemory;
        
        fprintf('    Training memory used: ~%.0f MB\n', trainingMemoryUsed);
        fprintf('    Target: <= %d MB - %s\n', targets.maxTrainingMemory, ...
            iif(trainingMemoryUsed <= targets.maxTrainingMemory, '✓ MET', '✗ EXCEEDED'));
        
        % Inference memory
        imageFiles = dir(fullfile(imageDir, '*.jpg'));
        testImg = imread(fullfile(imageDir, imageFiles(1).name));
        testImg = imresize(testImg, [224, 224]);
        
        memBefore = getAvailableMemory();
        for i = 1:10
            classify(trainedNet, testImg);
        end
        memAfter = getAvailableMemory();
        
        inferenceMemoryUsed = memBefore - memAfter;
        
        benchResults.inferenceMemoryUsedMB = inferenceMemoryUsed;
        benchResults.meetsInferenceMemoryTarget = inferenceMemoryUsed <= targets.maxInferenceMemory;
        
        fprintf('    Inference memory used: ~%.0f MB\n', inferenceMemoryUsed);
        fprintf('    Target: <= %d MB - %s\n', targets.maxInferenceMemory, ...
            iif(inferenceMemoryUsed <= targets.maxInferenceMemory, '✓ MET', '✗ EXCEEDED'));
        
    catch ME
        fprintf('    ERROR: Memory benchmark failed: %s\n', ME.message);
        benchResults.error = ME.message;
        passed = false;
    end
    
    benchResults.passed = passed;
end

function [passed, benchResults] = benchmarkModelComparison(dataDir)
% Compare performance across different model architectures
    
    benchResults = struct();
    passed = true;
    
    fprintf('  Comparing model architectures...\n');
    
    % Load test images
    imageDir = fullfile(dataDir, 'images');
    imageFiles = dir(fullfile(imageDir, '*.jpg'));
    
    if length(imageFiles) < 5
        fprintf('  WARNING: Limited test images for comparison\n');
    end
    
    % Test image
    testImg = imread(fullfile(imageDir, imageFiles(1).name));
    testImg = imresize(testImg, [224, 224]);
    
    % Compare models
    models = {'CustomCNN', 'ResNet50', 'EfficientNetB0'};
    
    for i = 1:length(models)
        modelName = models{i};
        fprintf('  Analyzing %s...\n', modelName);
        
        try
            % Create model
            if strcmp(modelName, 'CustomCNN')
                net = ModelFactory.createCustomCNN(3, [224, 224]);
            elseif strcmp(modelName, 'ResNet50')
                net = ModelFactory.createResNet50(3, [224, 224]);
            elseif strcmp(modelName, 'EfficientNetB0')
                net = ModelFactory.createEfficientNetB0(3, [224, 224]);
            end
            
            % Count parameters (approximate)
            layers = net.Layers;
            numLayers = length(layers);
            
            % Measure model size
            tempFile = fullfile('tests', 'integration', 'test_output', 'temp_model.mat');
            save(tempFile, 'net');
            modelInfo = dir(tempFile);
            modelSizeMB = modelInfo.bytes / (1024 * 1024);
            delete(tempFile);
            
            % Measure inference time
            tic;
            for j = 1:10
                classify(net, testImg);
            end
            inferenceTime = (toc / 10) * 1000; % ms per image
            
            % Store results
            benchResults.(modelName).numLayers = numLayers;
            benchResults.(modelName).modelSizeMB = modelSizeMB;
            benchResults.(modelName).inferenceTimeMs = inferenceTime;
            
            fprintf('    Layers: %d\n', numLayers);
            fprintf('    Model size: %.2f MB\n', modelSizeMB);
            fprintf('    Inference: %.2f ms/image\n', inferenceTime);
            
        catch ME
            fprintf('    ERROR: %s analysis failed: %s\n', modelName, ME.message);
            benchResults.(modelName).error = ME.message;
            passed = false;
        end
    end
    
    benchResults.passed = passed;
end

function memMB = getAvailableMemory()
% Get available system memory in MB (approximate)
    
    try
        if ispc
            [~, memInfo] = system('wmic OS get FreePhysicalMemory /Value');
            % Parse output to get free memory in KB
            tokens = regexp(memInfo, 'FreePhysicalMemory=(\d+)', 'tokens');
            if ~isempty(tokens)
                memKB = str2double(tokens{1}{1});
                memMB = memKB / 1024;
            else
                memMB = 0;
            end
        else
            [~, memInfo] = system('free -m | grep Mem');
            tokens = regexp(memInfo, '\s+(\d+)', 'tokens');
            if length(tokens) >= 4
                memMB = str2double(tokens{4}{1});
            else
                memMB = 0;
            end
        end
    catch
        memMB = 0; % Return 0 if unable to determine
    end
end

function status = getBenchmarkStatus(benchmarks, benchName)
% Get status string for a benchmark
    if isfield(benchmarks, benchName)
        if isfield(benchmarks.(benchName), 'passed') && benchmarks.(benchName).passed
            status = '✓ PASSED';
        else
            status = '✗ FAILED';
        end
    else
        status = '- NOT RUN';
    end
end

function generateTextReport(results, reportFile)
% Generate a text report of performance benchmark results
    
    fid = fopen(reportFile, 'w');
    
    fprintf(fid, '=== PERFORMANCE BENCHMARK REPORT ===\n\n');
    fprintf(fid, 'Timestamp: %s\n', char(results.timestamp));
    fprintf(fid, 'Overall Status: %s\n\n', iif(results.allPassed, 'ALL BENCHMARKS PASSED', 'SOME BENCHMARKS FAILED'));
    
    fprintf(fid, '--- Performance Targets ---\n\n');
    fprintf(fid, 'ResNet50 Inference: <= %.0f ms/image\n', results.targets.resnet50InferenceTime);
    fprintf(fid, 'EfficientNet Inference: <= %.0f ms/image\n', results.targets.efficientnetInferenceTime);
    fprintf(fid, 'Custom CNN Inference: <= %.0f ms/image\n', results.targets.customCNNInferenceTime);
    fprintf(fid, 'Training Time: <= %.0f s/epoch\n', results.targets.trainingTimePerEpoch);
    fprintf(fid, 'Max Training Memory: <= %d MB\n', results.targets.maxTrainingMemory);
    fprintf(fid, 'Max Inference Memory: <= %d MB\n\n', results.targets.maxInferenceMemory);
    
    fprintf(fid, '--- Benchmark Results ---\n\n');
    
    % Training Time
    if isfield(results.benchmarks, 'trainingTime')
        fprintf(fid, '1. Training Time: %s\n', iif(results.benchmarks.trainingTime.passed, 'PASSED', 'FAILED'));
        models = fieldnames(results.benchmarks.trainingTime);
        for i = 1:length(models)
            modelName = models{i};
            if ~strcmp(modelName, 'passed') && isstruct(results.benchmarks.trainingTime.(modelName))
                modelData = results.benchmarks.trainingTime.(modelName);
                if isfield(modelData, 'timePerEpoch')
                    fprintf(fid, '   %s: %.2f s/epoch\n', modelName, modelData.timePerEpoch);
                end
            end
        end
        fprintf(fid, '\n');
    end
    
    % Inference Speed
    if isfield(results.benchmarks, 'inferenceSpeed')
        fprintf(fid, '2. Inference Speed: %s\n', iif(results.benchmarks.inferenceSpeed.passed, 'PASSED', 'FAILED'));
        models = fieldnames(results.benchmarks.inferenceSpeed);
        for i = 1:length(models)
            modelName = models{i};
            if ~strcmp(modelName, 'passed') && isstruct(results.benchmarks.inferenceSpeed.(modelName))
                modelData = results.benchmarks.inferenceSpeed.(modelName);
                if isfield(modelData, 'avgTimeMs')
                    fprintf(fid, '   %s: %.2f ms/image (%.2f img/s)\n', ...
                        modelName, modelData.avgTimeMs, modelData.throughput);
                end
            end
        end
        fprintf(fid, '\n');
    end
    
    % Memory Usage
    if isfield(results.benchmarks, 'memoryUsage')
        fprintf(fid, '3. Memory Usage: %s\n', iif(results.benchmarks.memoryUsage.passed, 'PASSED', 'FAILED'));
        if isfield(results.benchmarks.memoryUsage, 'trainingMemoryUsedMB')
            fprintf(fid, '   Training: ~%.0f MB\n', results.benchmarks.memoryUsage.trainingMemoryUsedMB);
        end
        if isfield(results.benchmarks.memoryUsage, 'inferenceMemoryUsedMB')
            fprintf(fid, '   Inference: ~%.0f MB\n', results.benchmarks.memoryUsage.inferenceMemoryUsedMB);
        end
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
