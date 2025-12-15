%% evaluate_model.m
% Evaluate trained model on test set
%
% Usage: evaluate_model('resnet50')
%        evaluate_model('efficientnet')
%        evaluate_model('custom_cnn')
%
% Author: Heitor Oliveira Gonçalves
% Date: 2025-11-10

function results = evaluate_model(modelName)

if nargin < 1
    modelName = 'resnet50';  % Default
end

fprintf('=== Evaluating %s on Test Set ===\n\n', upper(modelName));

%% Paths
dataPath = '../processed_data';
modelPath = '../models';
resultsPath = '../results';

%% Load test data
fprintf('Loading test dataset...\n');
load(fullfile(dataPath, 'imdsTest.mat'), 'imdsTest');
fprintf('Test images: %d\n', numel(imdsTest.Files));

%% Load trained model
fprintf('\nLoading trained model...\n');

switch lower(modelName)
    case 'resnet50'
        modelFile = fullfile(modelPath, 'resnet50_best.mat');
    case 'efficientnet'
        modelFile = fullfile(modelPath, 'efficientnet_b0_best.mat');
    case 'custom_cnn'
        modelFile = fullfile(modelPath, 'custom_cnn_best.mat');
    otherwise
        error('Unknown model: %s', modelName);
end

if ~exist(modelFile, 'file')
    error('Model file not found: %s\nPlease train the model first.', modelFile);
end

load(modelFile, 'net', 'inputSize', 'classNames');
fprintf('✓ Model loaded from: %s\n', modelFile);

%% Prepare test data
augImdsTest = augmentedImageDatastore(inputSize(1:2), imdsTest);

%% Predict on test set
fprintf('\nRunning inference on test set...\n');
tic;
[YPred, scores] = classify(net, augImdsTest);
inferenceTime = toc;

fprintf('✓ Inference complete\n');
fprintf('  Total time: %.2f seconds\n', inferenceTime);
fprintf('  Time per image: %.2f ms\n', (inferenceTime / numel(imdsTest.Files)) * 1000);

%% Compute metrics
YTrue = imdsTest.Labels;

% Accuracy
accuracy = sum(YPred == YTrue) / numel(YTrue) * 100;

% Confusion matrix
C = confusionmat(YTrue, YPred);
C_normalized = C ./ sum(C, 2);  % Normalize by row (true labels)

% Per-class metrics
numClasses = numel(classNames);
precision = zeros(numClasses, 1);
recall = zeros(numClasses, 1);
f1score = zeros(numClasses, 1);

for i = 1:numClasses
    TP = C(i, i);
    FP = sum(C(:, i)) - TP;
    FN = sum(C(i, :)) - TP;
    
    precision(i) = TP / (TP + FP);
    recall(i) = TP / (TP + FN);
    f1score(i) = 2 * (precision(i) * recall(i)) / (precision(i) + recall(i));
end

%% Display results
fprintf('\n=== Test Set Results ===\n');
fprintf('Overall Accuracy: %.2f%%\n\n', accuracy);

fprintf('Per-Class Metrics:\n');
fprintf('%-15s %10s %10s %10s\n', 'Class', 'Precision', 'Recall', 'F1-Score');
fprintf('%s\n', repmat('-', 1, 50));
for i = 1:numClasses
    fprintf('%-15s %9.2f%% %9.2f%% %9.2f%%\n', ...
        classNames{i}, precision(i)*100, recall(i)*100, f1score(i)*100);
end

%% Plot confusion matrix
figure('Position', [100 100 800 700]);

% Plot normalized confusion matrix
confusionchart(C_normalized, classNames, ...
    'Title', sprintf('%s - Normalized Confusion Matrix', upper(modelName)), ...
    'RowSummary', 'row-normalized', ...
    'ColumnSummary', 'column-normalized');

% Save figure
confMatFile = fullfile(resultsPath, sprintf('%s_confusion_matrix.png', modelName));
saveas(gcf, confMatFile);
fprintf('\n✓ Confusion matrix saved to: %s\n', confMatFile);

%% Bootstrap confidence intervals
fprintf('\nComputing bootstrap confidence intervals (1000 iterations)...\n');

nBootstrap = 1000;
bootstrapAccuracy = zeros(nBootstrap, 1);

for i = 1:nBootstrap
    % Resample with replacement
    idx = randi(numel(YTrue), numel(YTrue), 1);
    YTrue_boot = YTrue(idx);
    YPred_boot = YPred(idx);
    
    % Compute accuracy
    bootstrapAccuracy(i) = sum(YPred_boot == YTrue_boot) / numel(YTrue_boot) * 100;
end

% Compute 95% confidence interval
ci_lower = prctile(bootstrapAccuracy, 2.5);
ci_upper = prctile(bootstrapAccuracy, 97.5);

fprintf('✓ Bootstrap complete\n');
fprintf('  Accuracy: %.2f%% [%.2f%%, %.2f%%] (95%% CI)\n', ...
    accuracy, ci_lower, ci_upper);

%% Save results
results = struct();
results.modelName = modelName;
results.accuracy = accuracy;
results.ci_lower = ci_lower;
results.ci_upper = ci_upper;
results.confusionMatrix = C;
results.confusionMatrixNormalized = C_normalized;
results.precision = precision;
results.recall = recall;
results.f1score = f1score;
results.classNames = classNames;
results.inferenceTime = inferenceTime;
results.timePerImage = (inferenceTime / numel(imdsTest.Files)) * 1000;

resultsFile = fullfile(resultsPath, sprintf('%s_test_results.mat', modelName));
save(resultsFile, 'results');

fprintf('\n✓ Results saved to: %s\n', resultsFile);

%% Summary
fprintf('\n=== Evaluation Summary ===\n');
fprintf('Model: %s\n', upper(modelName));
fprintf('Test Accuracy: %.2f%% ± %.2f%%\n', accuracy, (ci_upper - ci_lower)/2);
fprintf('Inference Time: %.2f ms per image\n', results.timePerImage);
fprintf('Throughput: %.1f images/second\n', 1000 / results.timePerImage);

end
