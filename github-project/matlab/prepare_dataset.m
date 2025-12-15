%% prepare_dataset.m
% Prepare corrosion dataset for training
% 
% This script:
% 1. Loads images from data/ directory
% 2. Creates train/validation/test splits (70%/15%/15%)
% 3. Applies stratified sampling to maintain class balance
% 4. Saves imageDatastore objects for training
%
% Author: Heitor Oliveira Gonçalves
% Date: 2025-11-10
% Institution: Catholic University of Petrópolis (UCP)

clear; clc; close all;

%% Configuration
dataPath = '../data';  % Path to dataset
outputPath = '../processed_data';  % Output path for processed data
imageSize = [224 224 3];  % Input size for models
trainRatio = 0.70;  % 70% for training
valRatio = 0.15;    % 15% for validation
testRatio = 0.15;   % 15% for test
randomSeed = 42;    % For reproducibility

fprintf('=== Corrosion Dataset Preparation ===\n\n');

%% Set random seed for reproducibility
rng(randomSeed);

%% Load dataset
fprintf('Loading dataset from: %s\n', dataPath);

% Create imageDatastore
imds = imageDatastore(dataPath, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

% Display dataset statistics
fprintf('\nDataset Statistics:\n');
fprintf('Total images: %d\n', numel(imds.Files));

% Count images per class
labelCounts = countEachLabel(imds);
fprintf('\nClass Distribution:\n');
disp(labelCounts);

% Calculate percentages
totalImages = sum(labelCounts.Count);
labelCounts.Percentage = (labelCounts.Count / totalImages) * 100;
fprintf('\nClass Percentages:\n');
disp(labelCounts);

%% Verify class names
expectedClasses = {'class_0', 'class_1', 'class_2'};
actualClasses = string(labelCounts.Label);

if ~all(ismember(expectedClasses, actualClasses))
    error('Dataset must contain folders: class_0, class_1, class_2');
end

fprintf('\n✓ Class structure verified\n');

%% Split dataset with stratified sampling
fprintf('\nSplitting dataset (stratified):\n');
fprintf('  Training:   %.0f%%\n', trainRatio * 100);
fprintf('  Validation: %.0f%%\n', valRatio * 100);
fprintf('  Test:       %.0f%%\n', testRatio * 100);

% Split into train and temp (val+test)
[imdsTrain, imdsTemp] = splitEachLabel(imds, trainRatio, 'randomized');

% Split temp into validation and test
valTestRatio = valRatio / (valRatio + testRatio);
[imdsVal, imdsTest] = splitEachLabel(imdsTemp, valTestRatio, 'randomized');

% Display split statistics
fprintf('\nSplit Statistics:\n');
fprintf('Training set:   %d images\n', numel(imdsTrain.Files));
fprintf('Validation set: %d images\n', numel(imdsVal.Files));
fprintf('Test set:       %d images\n', numel(imdsTest.Files));

% Verify class distribution in each split
fprintf('\nTraining set distribution:\n');
disp(countEachLabel(imdsTrain));

fprintf('\nValidation set distribution:\n');
disp(countEachLabel(imdsVal));

fprintf('\nTest set distribution:\n');
disp(countEachLabel(imdsTest));

%% Compute class weights for imbalanced dataset
fprintf('\nComputing class weights for imbalanced dataset:\n');

trainLabels = imdsTrain.Labels;
classNames = categories(trainLabels);
numClasses = numel(classNames);
N = numel(trainLabels);

classWeights = zeros(numClasses, 1);
for i = 1:numClasses
    n_c = sum(trainLabels == classNames{i});
    classWeights(i) = N / (numClasses * n_c);
    fprintf('  %s: weight = %.4f (n = %d)\n', classNames{i}, classWeights(i), n_c);
end

%% Create output directory
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

%% Save processed datastores
fprintf('\nSaving processed datastores...\n');

save(fullfile(outputPath, 'imdsTrain.mat'), 'imdsTrain');
save(fullfile(outputPath, 'imdsVal.mat'), 'imdsVal');
save(fullfile(outputPath, 'imdsTest.mat'), 'imdsTest');
save(fullfile(outputPath, 'classWeights.mat'), 'classWeights', 'classNames');

fprintf('✓ Saved to: %s\n', outputPath);

%% Display sample images
fprintf('\nDisplaying sample images from each class...\n');

figure('Position', [100 100 1200 400]);
for i = 1:numClasses
    className = classNames{i};
    
    % Get images from this class
    idx = find(imdsTrain.Labels == className);
    
    % Display first image
    subplot(1, numClasses, i);
    img = readimage(imdsTrain, idx(1));
    imshow(img);
    title(sprintf('%s\n(%d images)', className, numel(idx)));
end

sgtitle('Sample Images from Training Set');

% Save figure
saveas(gcf, fullfile(outputPath, 'sample_images.png'));
fprintf('✓ Sample images saved\n');

%% Summary
fprintf('\n=== Dataset Preparation Complete ===\n');
fprintf('Ready for training!\n');
fprintf('\nNext steps:\n');
fprintf('  1. Run train_resnet50.m to train ResNet50\n');
fprintf('  2. Run train_efficientnet.m to train EfficientNet-B0\n');
fprintf('  3. Run train_custom_cnn.m to train Custom CNN\n');
