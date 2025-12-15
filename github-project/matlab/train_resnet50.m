%% train_resnet50.m
% Train ResNet50 model for corrosion severity classification
%
% This script:
% 1. Loads pre-trained ResNet50 from ImageNet
% 2. Replaces final classification layer for 3 classes
% 3. Applies data augmentation
% 4. Trains with transfer learning
% 5. Saves best model based on validation accuracy
%
% Author: Heitor Oliveira Gonçalves
% Date: 2025-11-10
% Institution: Catholic University of Petrópolis (UCP)

clear; clc; close all;

%% Configuration
dataPath = '../processed_data';
modelPath = '../models';
resultsPath = '../results';

% Training hyperparameters
learningRate = 1e-5;  % Low learning rate for fine-tuning
miniBatchSize = 32;
maxEpochs = 100;
validationFrequency = 10;
earlyStopping = 10;  % Patience for early stopping

% Image parameters
inputSize = [224 224 3];
numClasses = 3;

fprintf('=== Training ResNet50 for Corrosion Classification ===\n\n');

%% Create output directories
if ~exist(modelPath, 'dir'), mkdir(modelPath); end
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

%% Load prepared dataset
fprintf('Loading prepared dataset...\n');
load(fullfile(dataPath, 'imdsTrain.mat'), 'imdsTrain');
load(fullfile(dataPath, 'imdsVal.mat'), 'imdsVal');
load(fullfile(dataPath, 'classWeights.mat'), 'classWeights', 'classNames');

fprintf('Training images: %d\n', numel(imdsTrain.Files));
fprintf('Validation images: %d\n', numel(imdsVal.Files));

%% Data Augmentation
fprintf('\nConfiguring data augmentation...\n');

imageAugmenter = imageDataAugmenter( ...
    'RandXReflection', true, ...  % Random horizontal flip
    'RandYReflection', true, ...  % Random vertical flip
    'RandRotation', [-15 15], ... % Random rotation ±15 degrees
    'RandXScale', [0.8 1.2], ...  % Random scale
    'RandYScale', [0.8 1.2]);

% Create augmented image datastore for training
augImdsTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain, ...
    'DataAugmentation', imageAugmenter, ...
    'ColorPreprocessing', 'gray2rgb');

% Validation datastore (no augmentation)
augImdsVal = augmentedImageDatastore(inputSize(1:2), imdsVal, ...
    'ColorPreprocessing', 'gray2rgb');

fprintf('✓ Data augmentation configured\n');

%% Load pre-trained ResNet50
fprintf('\nLoading pre-trained ResNet50 from ImageNet...\n');

net = resnet50;
fprintf('✓ ResNet50 loaded (25M parameters)\n');

%% Modify network for transfer learning
fprintf('\nModifying network for 3-class classification...\n');

% Get layer graph
lgraph = layerGraph(net);

% Find and replace final layers
numLayers = numel(lgraph.Layers);
fprintf('Original network has %d layers\n', numLayers);

% Replace final fully connected layer
newFCLayer = fullyConnectedLayer(numClasses, ...
    'Name', 'fc_corrosion', ...
    'WeightLearnRateFactor', 10, ...
    'BiasLearnRateFactor', 10);

lgraph = replaceLayer(lgraph, 'fc1000', newFCLayer);

% Replace classification layer
newClassLayer = classificationLayer('Name', 'classoutput_corrosion');
lgraph = replaceLayer(lgraph, 'ClassificationLayer_predictions', newClassLayer);

fprintf('✓ Network modified for corrosion classification\n');

%% Training options
fprintf('\nConfiguring training options...\n');

options = trainingOptions('adam', ...
    'InitialLearnRate', learningRate, ...
    'MaxEpochs', maxEpochs, ...
    'MiniBatchSize', miniBatchSize, ...
    'ValidationData', augImdsVal, ...
    'ValidationFrequency', validationFrequency, ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'gpu', ...
    'Shuffle', 'every-epoch', ...
    'OutputNetwork', 'best-validation-loss', ...
    'CheckpointPath', modelPath);

fprintf('Training configuration:\n');
fprintf('  Optimizer: Adam\n');
fprintf('  Learning rate: %.0e\n', learningRate);
fprintf('  Batch size: %d\n', miniBatchSize);
fprintf('  Max epochs: %d\n', maxEpochs);
fprintf('  Early stopping patience: %d epochs\n', earlyStopping);

%% Train network
fprintf('\n=== Starting Training ===\n');
fprintf('This may take several hours depending on your GPU...\n\n');

tic;
[net, trainInfo] = trainNetwork(augImdsTrain, lgraph, options);
trainingTime = toc;

fprintf('\n=== Training Complete ===\n');
fprintf('Training time: %.2f minutes\n', trainingTime/60);
fprintf('Final validation accuracy: %.2f%%\n', trainInfo.FinalValidationAccuracy);

%% Save trained model
fprintf('\nSaving trained model...\n');

modelFile = fullfile(modelPath, 'resnet50_best.mat');
save(modelFile, 'net', 'trainInfo', 'inputSize', 'classNames');

fprintf('✓ Model saved to: %s\n', modelFile);

%% Save training info
fprintf('\nSaving training information...\n');

trainingInfoFile = fullfile(resultsPath, 'resnet50_training_info.mat');
save(trainingInfoFile, 'trainInfo', 'trainingTime');

fprintf('✓ Training info saved\n');

%% Plot training curves
fprintf('\nGenerating training curves...\n');

figure('Position', [100 100 1200 400]);

% Plot training and validation loss
subplot(1, 2, 1);
plot(trainInfo.TrainingLoss, 'b-', 'LineWidth', 1.5);
hold on;
plot(trainInfo.ValidationLoss, 'r-', 'LineWidth', 1.5);
xlabel('Iteration');
ylabel('Loss');
title('Training and Validation Loss');
legend('Training', 'Validation');
grid on;

% Plot training and validation accuracy
subplot(1, 2, 2);
plot(trainInfo.TrainingAccuracy, 'b-', 'LineWidth', 1.5);
hold on;
plot(trainInfo.ValidationAccuracy, 'r-', 'LineWidth', 1.5);
xlabel('Iteration');
ylabel('Accuracy (%)');
title('Training and Validation Accuracy');
legend('Training', 'Validation');
grid on;

sgtitle('ResNet50 Training Progress');

% Save figure
saveas(gcf, fullfile(resultsPath, 'resnet50_training_curves.png'));
fprintf('✓ Training curves saved\n');

%% Summary
fprintf('\n=== ResNet50 Training Summary ===\n');
fprintf('Model: ResNet50 (25M parameters)\n');
fprintf('Training time: %.2f minutes\n', trainingTime/60);
fprintf('Best validation accuracy: %.2f%%\n', max(trainInfo.ValidationAccuracy));
fprintf('Best validation loss: %.4f\n', min(trainInfo.ValidationLoss));
fprintf('\nModel saved to: %s\n', modelFile);
fprintf('\nNext steps:\n');
fprintf('  1. Run evaluate_model.m to evaluate on test set\n');
fprintf('  2. Run inference_time_analysis.m to measure inference speed\n');
fprintf('  3. Compare with other models (EfficientNet-B0, Custom CNN)\n');
