%% train_custom_cnn.m
% Train custom lightweight CNN from scratch
%
% Custom CNN: 2M parameters, trained without pre-training
% Demonstrates the value of transfer learning by comparison
%
% Author: Heitor Oliveira Gonçalves
% Date: 2025-11-10

clear; clc; close all;

%% Configuration
dataPath = '../processed_data';
modelPath = '../models';
resultsPath = '../results';

learningRate = 1e-4;  % Higher learning rate for training from scratch
miniBatchSize = 32;
maxEpochs = 100;
inputSize = [224 224 3];
numClasses = 3;

fprintf('=== Training Custom CNN from Scratch ===\n\n');

%% Create directories
if ~exist(modelPath, 'dir'), mkdir(modelPath); end
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

%% Load dataset
fprintf('Loading dataset...\n');
load(fullfile(dataPath, 'imdsTrain.mat'), 'imdsTrain');
load(fullfile(dataPath, 'imdsVal.mat'), 'imdsVal');
load(fullfile(dataPath, 'classWeights.mat'), 'classWeights', 'classNames');

%% Data augmentation
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection', true, ...
    'RandYReflection', true, ...
    'RandRotation', [-15 15], ...
    'RandXScale', [0.8 1.2], ...
    'RandYScale', [0.8 1.2]);

augImdsTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain, ...
    'DataAugmentation', imageAugmenter);
augImdsVal = augmentedImageDatastore(inputSize(1:2), imdsVal);

%% Define custom CNN architecture
fprintf('\nDefining custom CNN architecture...\n');

layers = [
    % Input layer
    imageInputLayer(inputSize, 'Name', 'input')
    
    % Block 1: 32 filters
    convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'conv1')
    batchNormalizationLayer('Name', 'bn1')
    reluLayer('Name', 'relu1')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool1')
    
    % Block 2: 64 filters
    convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'conv2')
    batchNormalizationLayer('Name', 'bn2')
    reluLayer('Name', 'relu2')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool2')
    
    % Block 3: 128 filters
    convolution2dLayer(3, 128, 'Padding', 'same', 'Name', 'conv3')
    batchNormalizationLayer('Name', 'bn3')
    reluLayer('Name', 'relu3')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool3')
    
    % Block 4: 256 filters
    convolution2dLayer(3, 256, 'Padding', 'same', 'Name', 'conv4')
    batchNormalizationLayer('Name', 'bn4')
    reluLayer('Name', 'relu4')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool4')
    
    % Global average pooling
    globalAveragePooling2dLayer('Name', 'gap')
    
    % Fully connected layers
    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu_fc')
    dropoutLayer(0.5, 'Name', 'dropout')
    
    % Output layer
    fullyConnectedLayer(numClasses, 'Name', 'fc2')
    softmaxLayer('Name', 'softmax')
    classificationLayer('Name', 'classoutput')
];

fprintf('✓ Custom CNN architecture defined\n');
fprintf('  Architecture: 4 conv blocks + 2 FC layers\n');
fprintf('  Filters: 32 → 64 → 128 → 256\n');
fprintf('  Parameters: ~2M\n');

%% Training options
options = trainingOptions('adam', ...
    'InitialLearnRate', learningRate, ...
    'MaxEpochs', maxEpochs, ...
    'MiniBatchSize', miniBatchSize, ...
    'ValidationData', augImdsVal, ...
    'ValidationFrequency', 10, ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'gpu', ...
    'Shuffle', 'every-epoch', ...
    'OutputNetwork', 'best-validation-loss', ...
    'CheckpointPath', modelPath);

fprintf('\nTraining configuration:\n');
fprintf('  Learning rate: %.0e (higher for training from scratch)\n', learningRate);
fprintf('  Batch size: %d\n', miniBatchSize);
fprintf('  Max epochs: %d\n', maxEpochs);

%% Train network
fprintf('\n=== Starting Training (from scratch) ===\n');
fprintf('Note: Training from scratch typically requires more epochs\n\n');

tic;
[net, trainInfo] = trainNetwork(augImdsTrain, layers, options);
trainingTime = toc;

fprintf('\n=== Training Complete ===\n');
fprintf('Training time: %.2f minutes\n', trainingTime/60);
fprintf('Best validation accuracy: %.2f%%\n', max(trainInfo.ValidationAccuracy));

%% Save model
modelFile = fullfile(modelPath, 'custom_cnn_best.mat');
save(modelFile, 'net', 'trainInfo', 'inputSize', 'classNames');
fprintf('✓ Model saved to: %s\n', modelFile);

%% Plot training curves
figure('Position', [100 100 1200 400]);

subplot(1, 2, 1);
plot(trainInfo.TrainingLoss, 'b-', 'LineWidth', 1.5);
hold on;
plot(trainInfo.ValidationLoss, 'r-', 'LineWidth', 1.5);
xlabel('Iteration');
ylabel('Loss');
title('Training and Validation Loss');
legend('Training', 'Validation');
grid on;

subplot(1, 2, 2);
plot(trainInfo.TrainingAccuracy, 'b-', 'LineWidth', 1.5);
hold on;
plot(trainInfo.ValidationAccuracy, 'r-', 'LineWidth', 1.5);
xlabel('Iteration');
ylabel('Accuracy (%)');
title('Training and Validation Accuracy');
legend('Training', 'Validation');
grid on;

sgtitle('Custom CNN Training Progress (From Scratch)');
saveas(gcf, fullfile(resultsPath, 'custom_cnn_training_curves.png'));

fprintf('\n=== Custom CNN Training Summary ===\n');
fprintf('Model: Custom CNN (2M parameters)\n');
fprintf('Training: From scratch (no pre-training)\n');
fprintf('Training time: %.2f minutes\n', trainingTime/60);
fprintf('Best validation accuracy: %.2f%%\n', max(trainInfo.ValidationAccuracy));
fprintf('\nNote: Compare with transfer learning models to see the benefit of pre-training\n');
