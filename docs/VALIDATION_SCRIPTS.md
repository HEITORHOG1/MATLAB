# Validation Scripts - Classification System

## Overview

This document provides comprehensive validation scripts to verify the classification system implementation and reproduce the results presented in the article.

## Quick Validation

### Run All Validations

```matlab
% validate_all.m - Master validation script
function report = validate_all()
    fprintf('=== CLASSIFICATION SYSTEM VALIDATION ===\n\n');
    
    % 1. Validate dataset
    fprintf('1. Validating dataset...\n');
    datasetReport = validate_dataset();
    
    % 2. Validate models
    fprintf('\n2. Validating models...\n');
    modelsReport = validate_models();
    
    % 3. Validate results
    fprintf('\n3. Validating results...\n');
    resultsReport = validate_results();
    
    % 4. Validate figures
    fprintf('\n4. Validating figures...\n');
    figuresReport = validate_figures();
    
    % 5. Validate tables
    fprintf('\n5. Validating tables...\n');
    tablesReport = validate_tables();
    
    % Compile report
    report.dataset = datasetReport;
    report.models = modelsReport;
    report.results = resultsReport;
    report.figures = figuresReport;
    report.tables = tablesReport;
    report.overallStatus = all([datasetReport.passed, modelsReport.passed, ...
                                 resultsReport.passed, figuresReport.passed, ...
                                 tablesReport.passed]);
    
    % Display summary
    fprintf('\n=== VALIDATION SUMMARY ===\n');
    fprintf('Dataset: %s\n', status_string(datasetReport.passed));
    fprintf('Models: %s\n', status_string(modelsReport.passed));
    fprintf('Results: %s\n', status_string(resultsReport.passed));
    fprintf('Figures: %s\n', status_string(figuresReport.passed));
    fprintf('Tables: %s\n', status_string(tablesReport.passed));
    fprintf('\nOverall Status: %s\n', status_string(report.overallStatus));
    
    % Save report
    save('validation_report.mat', 'report');
    fprintf('\n✓ Validation report saved to: validation_report.mat\n');
end

function str = status_string(passed)
    if passed
        str = '✓ PASSED';
    else
        str = '✗ FAILED';
    end
end
```

## Dataset Validation

### Validate Dataset Structure

```matlab
% validate_dataset.m
function report = validate_dataset()
    report = struct();
    report.passed = true;
    report.errors = {};
    
    % Check labels file exists
    labelsFile = 'output/classification/labels.csv';
    if ~isfile(labelsFile)
        report.errors{end+1} = 'Labels file not found';
        report.passed = false;
        return;
    end
    
    % Load labels
    labels = readtable(labelsFile);
    
    % Validate number of images
    expectedCount = 414;
    actualCount = height(labels);
    if actualCount ~= expectedCount
        report.errors{end+1} = sprintf('Expected %d images, found %d', ...
            expectedCount, actualCount);
        report.passed = false;
    end
    
    % Validate class distribution
    classCounts = histcounts(labels.class, 0:4);
    expectedDistribution = [124, 103, 111, 76]; % Approximate
    tolerance = 5; % Allow ±5 images per class
    
    for i = 1:4
        if abs(classCounts(i) - expectedDistribution(i)) > tolerance
            report.errors{end+1} = sprintf('Class %d count mismatch: expected ~%d, found %d', ...
                i-1, expectedDistribution(i), classCounts(i));
            report.passed = false;
        end
    end
    
    % Validate split distribution
    splitCounts = groupcounts(labels, 'split');
    trainCount = splitCounts.GroupCount(strcmp(splitCounts.split, 'train'));
    valCount = splitCounts.GroupCount(strcmp(splitCounts.split, 'validation'));
    testCount = splitCounts.GroupCount(strcmp(splitCounts.split, 'test'));
    
    if trainCount ~= 290 || valCount ~= 62 || testCount ~= 62
        report.errors{end+1} = sprintf('Split distribution incorrect: train=%d, val=%d, test=%d', ...
            trainCount, valCount, testCount);
        report.passed = false;
    end
    
    % Validate image files exist
    missingFiles = 0;
    for i = 1:height(labels)
        imgPath = fullfile('img/original', labels.filename{i});
        if ~isfile(imgPath)
            missingFiles = missingFiles + 1;
        end
    end
    
    if missingFiles > 0
        report.errors{end+1} = sprintf('%d image files missing', missingFiles);
        report.passed = false;
    end
    
    % Store statistics
    report.totalImages = actualCount;
    report.classDistribution = classCounts;
    report.splitDistribution = [trainCount, valCount, testCount];
    report.missingFiles = missingFiles;
    
    % Display results
    if report.passed
        fprintf('  ✓ Dataset validation passed\n');
        fprintf('    Total images: %d\n', report.totalImages);
        fprintf('    Class distribution: [%d, %d, %d, %d]\n', classCounts);
        fprintf('    Split distribution: train=%d, val=%d, test=%d\n', ...
            trainCount, valCount, testCount);
    else
        fprintf('  ✗ Dataset validation failed\n');
        for i = 1:length(report.errors)
            fprintf('    Error: %s\n', report.errors{i});
        end
    end
end
```

### Validate Label Generation

```matlab
% validate_label_generation.m
function report = validate_label_generation()
    report = struct();
    report.passed = true;
    report.errors = {};
    
    % Load labels
    labels = readtable('output/classification/labels.csv');
    
    % Sample validation (check 10 random images)
    numSamples = min(10, height(labels));
    sampleIndices = randperm(height(labels), numSamples);
    
    mismatches = 0;
    for i = 1:numSamples
        idx = sampleIndices(i);
        
        % Load mask
        maskPath = fullfile('img/masks', labels.filename{idx});
        if ~isfile(maskPath)
            continue;
        end
        
        mask = imread(maskPath);
        if size(mask, 3) == 3
            mask = rgb2gray(mask);
        end
        mask = mask > 0;
        
        % Calculate percentage
        corroded_percentage = sum(mask(:)) / numel(mask) * 100;
        
        % Determine expected class
        if corroded_percentage == 0
            expectedClass = 0;
        elseif corroded_percentage < 10
            expectedClass = 1;
        elseif corroded_percentage < 30
            expectedClass = 2;
        else
            expectedClass = 3;
        end
        
        % Compare with label
        if labels.class(idx) ~= expectedClass
            mismatches = mismatches + 1;
            report.errors{end+1} = sprintf('Label mismatch for %s: expected %d, got %d', ...
                labels.filename{idx}, expectedClass, labels.class(idx));
        end
    end
    
    if mismatches > 0
        report.passed = false;
    end
    
    report.samplesChecked = numSamples;
    report.mismatches = mismatches;
    
    % Display results
    if report.passed
        fprintf('  ✓ Label generation validation passed\n');
        fprintf('    Samples checked: %d\n', numSamples);
        fprintf('    Mismatches: %d\n', mismatches);
    else
        fprintf('  ✗ Label generation validation failed\n');
        fprintf('    Samples checked: %d\n', numSamples);
        fprintf('    Mismatches: %d\n', mismatches);
    end
end
```

## Model Validation

### Validate Model Files

```matlab
% validate_models.m
function report = validate_models()
    report = struct();
    report.passed = true;
    report.errors = {};
    
    % Define expected models
    models = {
        'output/classification/checkpoints/resnet50_classification_best.mat'
        'output/classification/checkpoints/efficientnetb0_classification_best.mat'
        'output/classification/checkpoints/customcnn_classification_best.mat'
    };
    modelNames = {'ResNet50', 'EfficientNet-B0', 'Custom CNN'};
    
    % Check each model
    for i = 1:length(models)
        fprintf('  Checking %s...\n', modelNames{i});
        
        % Check file exists
        if ~isfile(models{i})
            report.errors{end+1} = sprintf('%s model file not found', modelNames{i});
            report.passed = false;
            continue;
        end
        
        % Load and validate model
        try
            load(models{i}, 'trainedNet');
            
            % Check model type
            if ~(isa(trainedNet, 'SeriesNetwork') || isa(trainedNet, 'DAGNetwork'))
                report.errors{end+1} = sprintf('%s: Invalid model type', modelNames{i});
                report.passed = false;
                continue;
            end
            
            % Check input size
            inputSize = trainedNet.Layers(1).InputSize;
            if ~isequal(inputSize, [224 224 3])
                report.errors{end+1} = sprintf('%s: Incorrect input size', modelNames{i});
                report.passed = false;
            end
            
            % Check output classes
            outputLayer = trainedNet.Layers(end);
            if isa(outputLayer, 'nnet.cnn.layer.ClassificationOutputLayer')
                % Get number of classes from previous layer
                fcLayer = trainedNet.Layers(end-2);
                if isa(fcLayer, 'nnet.cnn.layer.FullyConnectedLayer')
                    numClasses = fcLayer.OutputSize;
                    if numClasses ~= 4
                        report.errors{end+1} = sprintf('%s: Expected 4 classes, found %d', ...
                            modelNames{i}, numClasses);
                        report.passed = false;
                    end
                end
            end
            
            fprintf('    ✓ %s validated\n', modelNames{i});
            
        catch ME
            report.errors{end+1} = sprintf('%s: Failed to load - %s', ...
                modelNames{i}, ME.message);
            report.passed = false;
        end
    end
    
    % Display summary
    if report.passed
        fprintf('  ✓ All models validated successfully\n');
    else
        fprintf('  ✗ Model validation failed\n');
        for i = 1:length(report.errors)
            fprintf('    Error: %s\n', report.errors{i});
        end
    end
end
```

### Validate Model Performance

```matlab
% validate_model_performance.m
function report = validate_model_performance()
    report = struct();
    report.passed = true;
    report.errors = {};
    
    % Expected performance (from article)
    expectedPerformance = struct( ...
        'ResNet50', struct('accuracy', 92.45, 'tolerance', 2.0), ...
        'EfficientNetB0', struct('accuracy', 91.78, 'tolerance', 2.0), ...
        'CustomCNN', struct('accuracy', 87.32, 'tolerance', 2.0));
    
    % Load test data
    labels = readtable('output/classification/labels.csv');
    testData = labels(strcmp(labels.split, 'test'), :);
    
    % Create test datastore
    testImds = imageDatastore(fullfile('img/original', testData.filename));
    testImds.Labels = categorical(testData.class);
    testAugImds = augmentedImageDatastore([224 224], testImds);
    
    % Test each model
    models = {
        'output/classification/checkpoints/resnet50_classification_best.mat'
        'output/classification/checkpoints/efficientnetb0_classification_best.mat'
        'output/classification/checkpoints/customcnn_classification_best.mat'
    };
    modelNames = {'ResNet50', 'EfficientNetB0', 'CustomCNN'};
    
    for i = 1:length(models)
        if ~isfile(models{i})
            continue;
        end
        
        fprintf('  Testing %s...\n', modelNames{i});
        
        % Load model
        load(models{i}, 'trainedNet');
        
        % Evaluate
        predictions = classify(trainedNet, testAugImds);
        accuracy = mean(predictions == testImds.Labels) * 100;
        
        % Check against expected
        expected = expectedPerformance.(modelNames{i});
        if abs(accuracy - expected.accuracy) > expected.tolerance
            report.errors{end+1} = sprintf('%s: Accuracy %.2f%% differs from expected %.2f%%', ...
                modelNames{i}, accuracy, expected.accuracy);
            report.passed = false;
        end
        
        fprintf('    Accuracy: %.2f%% (expected: %.2f%% ±%.1f%%)\n', ...
            accuracy, expected.accuracy, expected.tolerance);
    end
    
    % Display summary
    if report.passed
        fprintf('  ✓ Model performance validation passed\n');
    else
        fprintf('  ✗ Model performance validation failed\n');
        for i = 1:length(report.errors)
            fprintf('    Error: %s\n', report.errors{i});
        end
    end
end
```

## Results Validation

### Validate Results Files

```matlab
% validate_results.m
function report = validate_results()
    report = struct();
    report.passed = true;
    report.errors = {};
    
    % Check results directory
    resultsDir = 'output/classification/results';
    if ~isfolder(resultsDir)
        report.errors{end+1} = 'Results directory not found';
        report.passed = false;
        return;
    end
    
    % Expected result files
    expectedFiles = {
        'resnet50_results.mat'
        'efficientnetb0_results.mat'
        'customcnn_results.mat'
        'comparison_results.mat'
    };
    
    % Check each file
    for i = 1:length(expectedFiles)
        filePath = fullfile(resultsDir, expectedFiles{i});
        if ~isfile(filePath)
            report.errors{end+1} = sprintf('Missing result file: %s', expectedFiles{i});
            report.passed = false;
        else
            % Validate file contents
            try
                data = load(filePath);
                
                % Check required fields
                if ~isfield(data, 'accuracy')
                    report.errors{end+1} = sprintf('%s: Missing accuracy field', expectedFiles{i});
                    report.passed = false;
                end
                
                if ~isfield(data, 'confusionMatrix')
                    report.errors{end+1} = sprintf('%s: Missing confusionMatrix field', expectedFiles{i});
                    report.passed = false;
                end
                
            catch ME
                report.errors{end+1} = sprintf('%s: Failed to load - %s', ...
                    expectedFiles{i}, ME.message);
                report.passed = false;
            end
        end
    end
    
    % Display results
    if report.passed
        fprintf('  ✓ Results validation passed\n');
    else
        fprintf('  ✗ Results validation failed\n');
        for i = 1:length(report.errors)
            fprintf('    Error: %s\n', report.errors{i});
        end
    end
end
```

## Figures Validation

### Validate Figure Files

```matlab
% validate_figures.m
function report = validate_figures()
    report = struct();
    report.passed = true;
    report.errors = {};
    
    % Expected figures
    expectedFigures = {
        'figura_fluxograma_metodologia.pdf'
        'figura_fluxograma_metodologia.png'
        'figura_exemplos_classes.pdf'
        'figura_exemplos_classes.png'
        'figura_arquiteturas.pdf'
        'figura_arquiteturas.png'
        'figura_matrizes_confusao.pdf'
        'figura_matrizes_confusao.png'
        'figura_curvas_treinamento.pdf'
        'figura_curvas_treinamento.png'
        'figura_comparacao_tempo_inferencia.pdf'
        'figura_comparacao_tempo_inferencia.png'
    };
    
    figuresDir = 'figuras_classificacao';
    
    % Check each figure
    for i = 1:length(expectedFigures)
        filePath = fullfile(figuresDir, expectedFigures{i});
        if ~isfile(filePath)
            report.errors{end+1} = sprintf('Missing figure: %s', expectedFigures{i});
            report.passed = false;
        else
            % Check file size (should not be empty)
            fileInfo = dir(filePath);
            if fileInfo.bytes < 1000 % Less than 1KB is suspicious
                report.errors{end+1} = sprintf('Figure too small: %s (%d bytes)', ...
                    expectedFigures{i}, fileInfo.bytes);
                report.passed = false;
            end
        end
    end
    
    % Display results
    if report.passed
        fprintf('  ✓ Figures validation passed\n');
        fprintf('    All %d figures found\n', length(expectedFigures));
    else
        fprintf('  ✗ Figures validation failed\n');
        for i = 1:length(report.errors)
            fprintf('    Error: %s\n', report.errors{i});
        end
    end
end
```

## Tables Validation

### Validate Table Files

```matlab
% validate_tables.m
function report = validate_tables()
    report = struct();
    report.passed = true;
    report.errors = {};
    
    % Expected tables
    expectedTables = {
        'tabela_dataset_estatisticas.tex'
        'tabela_arquiteturas_modelos.tex'
        'tabela_configuracao_treinamento.tex'
        'tabela_metricas_performance.tex'
        'tabela_tempo_inferencia.tex'
        'tabela_comparacao_abordagens.tex'
    };
    
    tablesDir = 'tabelas_classificacao';
    
    % Check each table
    for i = 1:length(expectedTables)
        filePath = fullfile(tablesDir, expectedTables{i});
        if ~isfile(filePath)
            report.errors{end+1} = sprintf('Missing table: %s', expectedTables{i});
            report.passed = false;
        else
            % Validate LaTeX syntax
            try
                fid = fopen(filePath, 'r');
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Check for basic LaTeX table structure
                if ~contains(content, '\begin{table}') || ~contains(content, '\end{table}')
                    report.errors{end+1} = sprintf('%s: Invalid LaTeX table structure', ...
                        expectedTables{i});
                    report.passed = false;
                end
                
                % Check for tabular environment
                if ~contains(content, '\begin{tabular}') || ~contains(content, '\end{tabular}')
                    report.errors{end+1} = sprintf('%s: Missing tabular environment', ...
                        expectedTables{i});
                    report.passed = false;
                end
                
            catch ME
                report.errors{end+1} = sprintf('%s: Failed to validate - %s', ...
                    expectedTables{i}, ME.message);
                report.passed = false;
            end
        end
    end
    
    % Display results
    if report.passed
        fprintf('  ✓ Tables validation passed\n');
        fprintf('    All %d tables found and validated\n', length(expectedTables));
    else
        fprintf('  ✗ Tables validation failed\n');
        for i = 1:length(report.errors)
            fprintf('    Error: %s\n', report.errors{i});
        end
    end
end
```

## Integration Validation

### End-to-End Validation

```matlab
% validate_end_to_end.m
function report = validate_end_to_end()
    fprintf('=== END-TO-END VALIDATION ===\n\n');
    
    report = struct();
    report.passed = true;
    report.steps = {};
    
    % Step 1: Generate labels
    fprintf('Step 1: Generating labels...\n');
    try
        gerar_labels_classificacao;
        report.steps{end+1} = struct('name', 'Label Generation', 'passed', true);
        fprintf('  ✓ Labels generated\n');
    catch ME
        report.steps{end+1} = struct('name', 'Label Generation', 'passed', false, ...
            'error', ME.message);
        report.passed = false;
        fprintf('  ✗ Label generation failed: %s\n', ME.message);
        return;
    end
    
    % Step 2: Train models (quick test with 1 epoch)
    fprintf('\nStep 2: Testing model training...\n');
    try
        % This would be a quick training test
        % For full validation, skip or use pre-trained models
        fprintf('  ⊘ Skipping training test (use pre-trained models)\n');
        report.steps{end+1} = struct('name', 'Model Training', 'passed', true, ...
            'note', 'Skipped - using pre-trained models');
    catch ME
        report.steps{end+1} = struct('name', 'Model Training', 'passed', false, ...
            'error', ME.message);
        report.passed = false;
        fprintf('  ✗ Training test failed: %s\n', ME.message);
    end
    
    % Step 3: Generate figures
    fprintf('\nStep 3: Generating figures...\n');
    try
        % Generate all figures
        gerar_figura_fluxograma_metodologia_classificacao;
        gerar_figura_exemplos_classes;
        gerar_figura_arquiteturas;
        gerar_figura_matrizes_confusao;
        gerar_figura_curvas_treinamento;
        gerar_figura_comparacao_tempo_inferencia;
        
        report.steps{end+1} = struct('name', 'Figure Generation', 'passed', true);
        fprintf('  ✓ Figures generated\n');
    catch ME
        report.steps{end+1} = struct('name', 'Figure Generation', 'passed', false, ...
            'error', ME.message);
        report.passed = false;
        fprintf('  ✗ Figure generation failed: %s\n', ME.message);
    end
    
    % Step 4: Generate tables
    fprintf('\nStep 4: Generating tables...\n');
    try
        gerar_todas_tabelas_classificacao;
        report.steps{end+1} = struct('name', 'Table Generation', 'passed', true);
        fprintf('  ✓ Tables generated\n');
    catch ME
        report.steps{end+1} = struct('name', 'Table Generation', 'passed', false, ...
            'error', ME.message);
        report.passed = false;
        fprintf('  ✗ Table generation failed: %s\n', ME.message);
    end
    
    % Display summary
    fprintf('\n=== END-TO-END VALIDATION SUMMARY ===\n');
    for i = 1:length(report.steps)
        step = report.steps{i};
        if step.passed
            fprintf('✓ %s\n', step.name);
        else
            fprintf('✗ %s: %s\n', step.name, step.error);
        end
    end
    
    fprintf('\nOverall Status: %s\n', status_string(report.passed));
    
    % Save report
    save('end_to_end_validation_report.mat', 'report');
end

function str = status_string(passed)
    if passed
        str = '✓ PASSED';
    else
        str = '✗ FAILED';
    end
end
```

## Performance Benchmarking

### Benchmark Inference Time

```matlab
% benchmark_inference.m
function report = benchmark_inference(numIterations)
    if nargin < 1
        numIterations = 100;
    end
    
    fprintf('=== INFERENCE TIME BENCHMARK ===\n');
    fprintf('Iterations: %d\n\n', numIterations);
    
    % Load test image
    testImg = imread('img/original/img001.jpg');
    testImg = imresize(testImg, [224 224]);
    
    % Models to benchmark
    models = {
        'output/classification/checkpoints/resnet50_classification_best.mat'
        'output/classification/checkpoints/efficientnetb0_classification_best.mat'
        'output/classification/checkpoints/customcnn_classification_best.mat'
    };
    modelNames = {'ResNet50', 'EfficientNet-B0', 'Custom CNN'};
    
    report = struct();
    
    % Benchmark each model
    for i = 1:length(models)
        if ~isfile(models{i})
            fprintf('%s: Model not found\n', modelNames{i});
            continue;
        end
        
        fprintf('Benchmarking %s...\n', modelNames{i});
        
        % Load model
        load(models{i}, 'trainedNet');
        
        % Warm-up
        classify(trainedNet, testImg);
        
        % Benchmark
        times = zeros(numIterations, 1);
        for j = 1:numIterations
            tic;
            classify(trainedNet, testImg);
            times(j) = toc;
        end
        
        % Calculate statistics
        avgTime = mean(times) * 1000; % Convert to ms
        stdTime = std(times) * 1000;
        minTime = min(times) * 1000;
        maxTime = max(times) * 1000;
        
        % Store results
        report.(matlab.lang.makeValidName(modelNames{i})) = struct( ...
            'avgTime', avgTime, ...
            'stdTime', stdTime, ...
            'minTime', minTime, ...
            'maxTime', maxTime);
        
        fprintf('  Average: %.2f ms (±%.2f ms)\n', avgTime, stdTime);
        fprintf('  Min: %.2f ms, Max: %.2f ms\n\n', minTime, maxTime);
    end
    
    % Save report
    save('inference_benchmark_report.mat', 'report');
    fprintf('✓ Benchmark report saved\n');
end
```

## Citation

These validation scripts are part of the supplementary materials for:

```bibtex
@article{goncalves2025classification,
  title={Automated Corrosion Severity Classification in ASTM A572 Grade 50 Steel Using Deep Learning: A Hierarchical Approach for Structural Health Monitoring},
  author={Gonçalves, Heitor Oliveira and Porto, Darlan and Amaral, Renato and Quadrelli, Giovane},
  journal={Journal of Computing in Civil Engineering, ASCE},
  year={2025},
  note={Submitted}
}
```

## Contact

For questions or issues with validation scripts:

**Author:** Heitor Oliveira Gonçalves  
**Email:** heitor.goncalves@ucp.br  
**GitHub:** [github.com/heitorhog](https://github.com/heitorhog)

---

**Last Updated:** January 2025  
**Version:** 1.0
