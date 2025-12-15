%% train_efficientnet.m
% Train EfficientNet-B0 model for corrosion severity classification
%
% This script trains EfficientNet-B0 with transfer learning
% EfficientNet-B0: 5M parameters, optimal accuracy/efficiency balance
%
% Author: Heitor Oliveira Gonçalves
% Date: 2025-11-10

clear; clc; close all;

%% Configuration
dataPath = '../processed_data';
modelPath = '../models';
resultsPath = '../results';

learningRate = 1e-5;
miniBatchSize = 32;
maxEpochs = 100;
inputSize = [224 224 3];
numClasses = 3;

fprintf('=== Training EfficientNet-B0 for Corrosion Classification ===\n\n');

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

%% Load EfficientNet-B0
fprintf('\nLoading pre-trained EfficientNet-B0...\n');
net = efficientnetb0;
fprintf('✓ EfficientNet-B0 loaded (5M parameters)\n');

%% Modify network
lgraph = layerGraph(net);

newFCLayer = fullyConnectedLayer(numClasses, ...
    'Name', 'fc_corrosion', ...
    'WeightLearnRateFactor', 10, ...
    'BiasLearnRateFactor', 10);

lgraph = replaceLayer(lgraph, 'efficientnet-b0|model|head|dense|MatMul', newFCLayer);

newClassLayer = classificationLayer('Name', 'classoutput');
lgraph = replaceLayer(lgraph, 'ClassificationLayer_efficientnet-b0|model|head|dense|Softmax', newClassLayer);

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

%% Train
fprintf('\n=== Starting Training ===\n\n');
tic;
[net, trainInfo] = trainNetwork(augImdsTrain, lgraph, options);
trainingTime = toc;

fprintf('\n=== Training Complete ===\n');
fprintf('Training time: %.2f minutes\n', trainingTime/60);
fprintf('Best validation accuracy: %.2f%%\n', max(trainInfo.ValidationAccuracy));

%% Save model
modelFile = fullfile(modelPath, 'efficientnet_b0_best.mat');
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

sgtitle('EfficientNet-B0 Training Progress');
saveas(gcf, fullfile(resultsPath, 'efficientnet_training_curves.png'));

fprintf('\n=== EfficientNet-B0 Training Complete ===\n');
