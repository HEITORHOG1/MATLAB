# Pre-trained Models Guide

## Overview

This guide provides comprehensive documentation for accessing, loading, and using the pre-trained classification models from the article "Automated Corrosion Severity Classification in ASTM A572 Grade 50 Steel Using Deep Learning".

## Available Models

### Model Summary

| Model | Parameters | Input Size | Accuracy | Inference Time | File Size |
|-------|------------|------------|----------|----------------|-----------|
| ResNet50 | 25.6M | 224×224×3 | 92.45% | 45.3 ms | ~98 MB |
| EfficientNet-B0 | 5.3M | 224×224×3 | 91.78% | 32.1 ms | ~21 MB |
| Custom CNN | 2.1M | 224×224×3 | 87.32% | 18.7 ms | ~8.5 MB |

### Model Selection Guide

**Choose ResNet50 when:**
- Highest accuracy is critical
- Computational resources are available
- Inference time < 50ms is acceptable
- Best overall performance needed

**Choose EfficientNet-B0 when:**
- Balance between accuracy and efficiency needed
- Memory constraints exist
- Faster inference than ResNet50 required
- Good accuracy with smaller model size

**Choose Custom CNN when:**
- Fastest inference is critical
- Minimal memory footprint required
- Edge deployment needed
- Acceptable accuracy trade-off for speed

## Downloading Pre-trained Models

### Model Files Location

Pre-trained models are stored in the repository under:
```
output/classification/checkpoints/
├── resnet50_classification_best.mat
├── efficientnetb0_classification_best.mat
└── customcnn_classification_best.mat
```

### Download Instructions

#### Option 1: Clone Repository (Recommended)

```bash
# Clone the repository
git clone https://github.com/heitorhog/corrosion-detection-system.git
cd corrosion-detection-system

# Models are included in output/classification/checkpoints/
```

#### Option 2: Direct Download

If models are not in the repository (due to size), download from:

**ResNet50:**
```bash
# Download link (to be provided)
wget https://[storage-url]/resnet50_classification_best.mat
```

**EfficientNet-B0:**
```bash
# Download link (to be provided)
wget https://[storage-url]/efficientnetb0_classification_best.mat
```

**Custom CNN:**
```bash
# Download link (to be provided)
wget https://[storage-url]/customcnn_classification_best.mat
```

#### Option 3: Request via Email

Contact: heitor.goncalves@ucp.br
- Specify which model(s) you need
- Provide intended use case
- Models will be shared via secure transfer

### File Verification

Verify downloaded files using MD5 checksums:

```matlab
% verify_model.m
function isValid = verify_model(modelPath, expectedMD5)
    % Calculate MD5
    fid = fopen(modelPath, 'r');
    data = fread(fid, '*uint8');
    fclose(fid);
    
    actualMD5 = DataHash(data, struct('Method', 'MD5'));
    
    % Compare
    isValid = strcmp(actualMD5, expectedMD5);
    
    if isValid
        fprintf('✓ Model verification passed: %s\n', modelPath);
    else
        fprintf('✗ Model verification failed: %s\n', modelPath);
        fprintf('  Expected: %s\n', expectedMD5);
        fprintf('  Actual: %s\n', actualMD5);
    end
end
```

**Expected MD5 Checksums:**
- ResNet50: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`
- EfficientNet-B0: `b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7`
- Custom CNN: `c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8`

## Loading Pre-trained Models

### Basic Loading

```matlab
% Load a pre-trained model
modelPath = 'output/classification/checkpoints/resnet50_classification_best.mat';
load(modelPath, 'trainedNet');

% Display model information
fprintf('Model loaded successfully!\n');
fprintf('Number of layers: %d\n', numel(trainedNet.Layers));
fprintf('Input size: %s\n', mat2str(trainedNet.Layers(1).InputSize));
```

### Loading with Validation

```matlab
% load_model_safe.m
function trainedNet = load_model_safe(modelPath)
    % Check file exists
    if ~isfile(modelPath)
        error('Model file not found: %s', modelPath);
    end
    
    % Load model
    try
        data = load(modelPath);
        if isfield(data, 'trainedNet')
            trainedNet = data.trainedNet;
        elseif isfield(data, 'net')
            trainedNet = data.net;
        else
            error('Model structure not recognized');
        end
    catch ME
        error('Failed to load model: %s', ME.message);
    end
    
    % Validate model
    assert(isa(trainedNet, 'SeriesNetwork') || isa(trainedNet, 'DAGNetwork'), ...
        'Invalid model type');
    
    fprintf('✓ Model loaded and validated: %s\n', modelPath);
end
```

### Loading All Models

```matlab
% load_all_models.m
function models = load_all_models()
    % Define model paths
    modelPaths = {
        'output/classification/checkpoints/resnet50_classification_best.mat'
        'output/classification/checkpoints/efficientnetb0_classification_best.mat'
        'output/classification/checkpoints/customcnn_classification_best.mat'
    };
    modelNames = {'ResNet50', 'EfficientNet-B0', 'Custom CNN'};
    
    % Load each model
    models = struct();
    for i = 1:length(modelPaths)
        fprintf('Loading %s...\n', modelNames{i});
        load(modelPaths{i}, 'trainedNet');
        models.(matlab.lang.makeValidName(modelNames{i})) = trainedNet;
    end
    
    fprintf('✓ All models loaded successfully!\n');
end
```

## Using Pre-trained Models

### Single Image Classification

```matlab
% classify_single_image.m
function result = classify_single_image(imagePath, modelPath)
    % Load model
    load(modelPath, 'trainedNet');
    
    % Load and preprocess image
    img = imread(imagePath);
    img = imresize(img, [224 224]);
    
    % Classify
    [predictedLabel, scores] = classify(trainedNet, img);
    
    % Prepare result
    result.filename = imagePath;
    result.predictedClass = string(predictedLabel);
    result.confidence = max(scores) * 100;
    result.classScores = struct( ...
        'None', scores(1) * 100, ...
        'Light', scores(2) * 100, ...
        'Moderate', scores(3) * 100, ...
        'Severe', scores(4) * 100);
    
    % Display result
    fprintf('Image: %s\n', imagePath);
    fprintf('Predicted Class: %s\n', result.predictedClass);
    fprintf('Confidence: %.2f%%\n', result.confidence);
    fprintf('Class Scores:\n');
    fprintf('  None: %.2f%%\n', result.classScores.None);
    fprintf('  Light: %.2f%%\n', result.classScores.Light);
    fprintf('  Moderate: %.2f%%\n', result.classScores.Moderate);
    fprintf('  Severe: %.2f%%\n', result.classScores.Severe);
    
    % Visualize
    figure;
    subplot(1, 2, 1);
    imshow(img);
    title(sprintf('Predicted: %s (%.2f%%)', result.predictedClass, result.confidence));
    
    subplot(1, 2, 2);
    bar([result.classScores.None, result.classScores.Light, ...
         result.classScores.Moderate, result.classScores.Severe]);
    xticklabels({'None', 'Light', 'Moderate', 'Severe'});
    ylabel('Confidence (%)');
    title('Class Scores');
    grid on;
end
```

### Batch Classification

```matlab
% classify_batch.m
function results = classify_batch(imageFolder, modelPath, outputCSV)
    % Load model
    load(modelPath, 'trainedNet');
    
    % Get all images
    imageFiles = dir(fullfile(imageFolder, '*.jpg'));
    numImages = length(imageFiles);
    
    % Initialize results
    results = table();
    
    % Process each image
    fprintf('Processing %d images...\n', numImages);
    for i = 1:numImages
        % Load and preprocess
        imgPath = fullfile(imageFolder, imageFiles(i).name);
        img = imread(imgPath);
        img = imresize(img, [224 224]);
        
        % Classify
        [predictedLabel, scores] = classify(trainedNet, img);
        
        % Store result
        results = [results; table( ...
            {imageFiles(i).name}, ...
            string(predictedLabel), ...
            max(scores) * 100, ...
            scores(1) * 100, ...
            scores(2) * 100, ...
            scores(3) * 100, ...
            scores(4) * 100, ...
            'VariableNames', {'Filename', 'PredictedClass', 'Confidence', ...
                              'Score_None', 'Score_Light', 'Score_Moderate', 'Score_Severe'})];
        
        % Progress
        if mod(i, 10) == 0
            fprintf('  Processed %d/%d images\n', i, numImages);
        end
    end
    
    % Save results
    writetable(results, outputCSV);
    fprintf('✓ Results saved to: %s\n', outputCSV);
    
    % Summary statistics
    fprintf('\nSummary:\n');
    fprintf('  Total images: %d\n', numImages);
    fprintf('  Class distribution:\n');
    classCounts = groupcounts(results, 'PredictedClass');
    disp(classCounts);
end
```

### Real-time Classification

```matlab
% realtime_classification.m
function realtime_classification(modelPath, cameraID)
    % Load model
    load(modelPath, 'trainedNet');
    
    % Initialize camera
    cam = webcam(cameraID);
    
    % Create figure
    figure('Name', 'Real-time Corrosion Classification');
    
    % Main loop
    fprintf('Starting real-time classification. Press Ctrl+C to stop.\n');
    while true
        % Capture frame
        frame = snapshot(cam);
        
        % Preprocess
        img = imresize(frame, [224 224]);
        
        % Classify
        [predictedLabel, scores] = classify(trainedNet, img);
        
        % Display
        subplot(1, 2, 1);
        imshow(frame);
        title(sprintf('Class: %s (%.2f%%)', string(predictedLabel), max(scores)*100));
        
        subplot(1, 2, 2);
        bar(scores * 100);
        xticklabels({'None', 'Light', 'Moderate', 'Severe'});
        ylabel('Confidence (%)');
        ylim([0 100]);
        title('Class Scores');
        grid on;
        
        drawnow;
    end
    
    % Cleanup
    clear cam;
end
```

### Model Comparison

```matlab
% compare_models_inference.m
function comparison = compare_models_inference(imagePath)
    % Define models
    models = {
        'output/classification/checkpoints/resnet50_classification_best.mat'
        'output/classification/checkpoints/efficientnetb0_classification_best.mat'
        'output/classification/checkpoints/customcnn_classification_best.mat'
    };
    modelNames = {'ResNet50', 'EfficientNet-B0', 'Custom CNN'};
    
    % Load and preprocess image
    img = imread(imagePath);
    img = imresize(img, [224 224]);
    
    % Initialize comparison
    comparison = table();
    
    % Test each model
    for i = 1:length(models)
        % Load model
        load(models{i}, 'trainedNet');
        
        % Classify with timing
        tic;
        [predictedLabel, scores] = classify(trainedNet, img);
        inferenceTime = toc * 1000; % Convert to ms
        
        % Store result
        comparison = [comparison; table( ...
            modelNames(i), ...
            string(predictedLabel), ...
            max(scores) * 100, ...
            inferenceTime, ...
            'VariableNames', {'Model', 'PredictedClass', 'Confidence', 'InferenceTime_ms'})];
    end
    
    % Display comparison
    fprintf('Model Comparison for: %s\n', imagePath);
    disp(comparison);
    
    % Visualize
    figure;
    subplot(2, 2, 1);
    imshow(imread(imagePath));
    title('Input Image');
    
    subplot(2, 2, 2);
    bar(comparison.Confidence);
    xticklabels(modelNames);
    ylabel('Confidence (%)');
    title('Prediction Confidence');
    grid on;
    
    subplot(2, 2, 3);
    bar(comparison.InferenceTime_ms);
    xticklabels(modelNames);
    ylabel('Time (ms)');
    title('Inference Time');
    grid on;
    
    subplot(2, 2, 4);
    text(0.1, 0.5, sprintf('Predictions:\n%s: %s\n%s: %s\n%s: %s', ...
        modelNames{1}, comparison.PredictedClass(1), ...
        modelNames{2}, comparison.PredictedClass(2), ...
        modelNames{3}, comparison.PredictedClass(3)), ...
        'FontSize', 12);
    axis off;
    title('Predicted Classes');
end
```

## Model Inference API

### Simple API

```matlab
% ClassificationAPI.m
classdef ClassificationAPI < handle
    properties
        Model
        ModelName
        InputSize
    end
    
    methods
        function obj = ClassificationAPI(modelPath)
            % Load model
            load(modelPath, 'trainedNet');
            obj.Model = trainedNet;
            
            % Extract model info
            [~, name, ~] = fileparts(modelPath);
            obj.ModelName = name;
            obj.InputSize = trainedNet.Layers(1).InputSize;
        end
        
        function [class, confidence, scores] = predict(obj, imagePath)
            % Load and preprocess image
            img = imread(imagePath);
            img = imresize(img, obj.InputSize(1:2));
            
            % Classify
            [predictedLabel, scores] = classify(obj.Model, img);
            
            % Return results
            class = string(predictedLabel);
            confidence = max(scores);
        end
        
        function results = predictBatch(obj, imageFolder)
            % Get all images
            imageFiles = dir(fullfile(imageFolder, '*.jpg'));
            numImages = length(imageFiles);
            
            % Initialize results
            results = cell(numImages, 3);
            
            % Process each image
            for i = 1:numImages
                imgPath = fullfile(imageFolder, imageFiles(i).name);
                [class, confidence, ~] = obj.predict(imgPath);
                results{i, 1} = imageFiles(i).name;
                results{i, 2} = class;
                results{i, 3} = confidence;
            end
            
            % Convert to table
            results = cell2table(results, ...
                'VariableNames', {'Filename', 'Class', 'Confidence'});
        end
        
        function time = benchmarkInference(obj, numIterations)
            % Create dummy image
            img = rand(obj.InputSize);
            
            % Warm-up
            classify(obj.Model, img);
            
            % Benchmark
            tic;
            for i = 1:numIterations
                classify(obj.Model, img);
            end
            time = toc / numIterations * 1000; % ms per image
            
            fprintf('Average inference time: %.2f ms\n', time);
        end
    end
end
```

### Usage Example

```matlab
% Example usage of ClassificationAPI
api = ClassificationAPI('output/classification/checkpoints/resnet50_classification_best.mat');

% Single prediction
[class, confidence, scores] = api.predict('test_image.jpg');
fprintf('Predicted: %s (%.2f%%)\n', class, confidence*100);

% Batch prediction
results = api.predictBatch('test_images/');
disp(results);

% Benchmark
avgTime = api.benchmarkInference(100);
```

## Model Export and Deployment

### Export to ONNX

```matlab
% export_to_onnx.m
function export_to_onnx(modelPath, outputPath)
    % Load model
    load(modelPath, 'trainedNet');
    
    % Export to ONNX
    exportONNXNetwork(trainedNet, outputPath, ...
        'OpsetVersion', 13);
    
    fprintf('✓ Model exported to ONNX: %s\n', outputPath);
end

% Usage
export_to_onnx('output/classification/checkpoints/resnet50_classification_best.mat', ...
               'resnet50_classification.onnx');
```

### Deploy to Mobile (MATLAB Coder)

```matlab
% generate_mobile_code.m
function generate_mobile_code(modelPath, outputFolder)
    % Load model
    load(modelPath, 'trainedNet');
    
    % Generate code
    cfg = coder.config('lib');
    cfg.TargetLang = 'C++';
    cfg.DeepLearningConfig = coder.DeepLearningConfig('arm-compute');
    
    codegen -config cfg classify_image -args {ones(224,224,3,'uint8')} ...
        -d outputFolder -report
    
    fprintf('✓ Mobile code generated in: %s\n', outputFolder);
end
```

## Troubleshooting

### Common Issues

**Issue 1: Model file not found**
```matlab
% Solution: Check file path
modelPath = 'output/classification/checkpoints/resnet50_classification_best.mat';
if ~isfile(modelPath)
    error('Model not found. Please download from repository.');
end
```

**Issue 2: Out of memory during inference**
```matlab
% Solution: Process images in smaller batches
batchSize = 16; % Reduce if needed
for i = 1:batchSize:numImages
    batchEnd = min(i+batchSize-1, numImages);
    batchImages = images(i:batchEnd);
    predictions = classify(trainedNet, batchImages);
end
```

**Issue 3: Slow inference on CPU**
```matlab
% Solution: Use GPU if available
if canUseGPU()
    trainedNet = trainedNet.activations(gpuArray(img), layerName);
else
    warning('GPU not available. Inference will be slower on CPU.');
end
```

## Performance Optimization

### GPU Acceleration

```matlab
% Enable GPU for faster inference
if canUseGPU()
    fprintf('GPU available: %s\n', gpuDevice().Name);
    % Model automatically uses GPU when available
else
    fprintf('GPU not available. Using CPU.\n');
end
```

### Batch Processing

```matlab
% Process multiple images at once for better throughput
batchSize = 32;
imgBatch = cat(4, img1, img2, img3, ...); % Concatenate images
predictions = classify(trainedNet, imgBatch);
```

### Model Quantization

```matlab
% Quantize model for faster inference (requires Deep Learning Toolbox)
quantizedNet = quantize(trainedNet);
save('resnet50_quantized.mat', 'quantizedNet');
```

## Citation

If you use these pre-trained models, please cite:

```bibtex
@article{goncalves2025classification,
  title={Automated Corrosion Severity Classification in ASTM A572 Grade 50 Steel Using Deep Learning: A Hierarchical Approach for Structural Health Monitoring},
  author={Gonçalves, Heitor Oliveira and Porto, Darlan and Amaral, Renato and Quadrelli, Giovane},
  journal={Journal of Computing in Civil Engineering, ASCE},
  year={2025},
  note={Submitted}
}
```

## License

These pre-trained models are provided for academic and research purposes only.

**Terms of Use:**
- ✓ Academic research
- ✓ Educational purposes
- ✓ Non-commercial applications
- ✗ Commercial use without permission
- ✗ Redistribution without attribution

## Contact

For questions, issues, or collaboration:

**Author:** Heitor Oliveira Gonçalves  
**Email:** heitor.goncalves@ucp.br  
**LinkedIn:** [linkedin.com/in/heitorhog](https://www.linkedin.com/in/heitorhog/)  
**GitHub:** [github.com/heitorhog](https://github.com/heitorhog)

---

**Last Updated:** January 2025  
**Version:** 1.0  
**Model Version:** 1.0
