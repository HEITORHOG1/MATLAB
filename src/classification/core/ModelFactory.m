% ModelFactory.m - Create and configure deep learning classification models
%
% Copyright (c) 2025 Corrosion Analysis System Contributors
% Licensed under the MIT License (see LICENSE file in project root)
%
% This class provides factory methods for creating different classification
% architectures with transfer learning support. Supported architectures:
%   - ResNet50: Pre-trained on ImageNet, ~25M parameters
%   - EfficientNet-B0: Pre-trained on ImageNet, ~5M parameters
%   - CustomCNN: Lightweight custom architecture, ~2M parameters
%
% Requirements addressed: 3.1, 3.2, 3.3, 3.4

classdef ModelFactory < handle
    % ModelFactory - Create and configure deep learning classification models
    %
    % This class provides factory methods for creating different classification
    % architectures with transfer learning support. Supported architectures:
    %   - ResNet50: Pre-trained on ImageNet, ~25M parameters
    %   - EfficientNet-B0: Pre-trained on ImageNet, ~5M parameters
    %   - CustomCNN: Lightweight custom architecture, ~2M parameters
    %
    % Requirements addressed: 3.1, 3.2, 3.3, 3.4
    
    methods (Static)
        function lgraph = createResNet50(numClasses, inputSize)
            % Create ResNet50-based classification model with transfer learning
            %
            % Inputs:
            %   numClasses - Number of output classes (default: 3)
            %   inputSize - [height, width, channels] (default: [224, 224, 3])
            %
            % Output:
            %   lgraph - Layer graph for ResNet50 classifier
            %
            % Architecture:
            %   - Base: Pre-trained ResNet50 from ImageNet
            %   - Modification: Replace final FC layer with new FC(numClasses)
            %   - Parameters: ~25M
            %
            % Requirements: 3.1, 3.4
            
            if nargin < 1 || isempty(numClasses)
                numClasses = 3;
            end
            
            if nargin < 2 || isempty(inputSize)
                inputSize = [224, 224, 3];
            end
            
            fprintf('Creating ResNet50 model...\n');
            fprintf('  Input size: [%d, %d, %d]\n', inputSize(1), inputSize(2), inputSize(3));
            fprintf('  Number of classes: %d\n', numClasses);
            
            % Load pre-trained ResNet50
            try
                net = resnet50;
            catch ME
                error('ModelFactory:ResNet50LoadError', ...
                    'Failed to load ResNet50. Ensure Deep Learning Toolbox Model for ResNet-50 Network is installed.\nError: %s', ...
                    ME.message);
            end
            
            % Convert to layer graph for modification
            lgraph = layerGraph(net);
            
            % Find the last learnable layer and the classification layer
            % ResNet50 has 'fc1000' as the final fully connected layer
            % and 'ClassificationLayer_predictions' as the output layer
            
            % Get layer names
            layerNames = {lgraph.Layers.Name};
            
            % Find final FC layer (typically 'fc1000')
            fcLayerIdx = find(contains(layerNames, 'fc1000'));
            if isempty(fcLayerIdx)
                error('ModelFactory:LayerNotFound', 'Could not find fc1000 layer in ResNet50');
            end
            fcLayerName = layerNames{fcLayerIdx};
            
            % Find classification output layer
            classLayerIdx = find(contains(layerNames, 'ClassificationLayer') | ...
                                contains(layerNames, 'output'));
            if isempty(classLayerIdx)
                error('ModelFactory:LayerNotFound', 'Could not find classification layer in ResNet50');
            end
            classLayerName = layerNames{classLayerIdx};
            
            % Find softmax layer
            softmaxLayerIdx = find(contains(layerNames, 'softmax') | ...
                                  contains(layerNames, 'prob'));
            if isempty(softmaxLayerIdx)
                error('ModelFactory:LayerNotFound', 'Could not find softmax layer in ResNet50');
            end
            softmaxLayerName = layerNames{softmaxLayerIdx};
            
            % Create new layers for our classification task
            newFCLayer = fullyConnectedLayer(numClasses, ...
                'Name', 'fc_corrosion', ...
                'WeightLearnRateFactor', 10, ...
                'BiasLearnRateFactor', 10);
            
            newSoftmaxLayer = softmaxLayer('Name', 'softmax_corrosion');
            newClassLayer = classificationLayer('Name', 'output_corrosion');
            
            % Replace the layers
            lgraph = replaceLayer(lgraph, fcLayerName, newFCLayer);
            lgraph = replaceLayer(lgraph, softmaxLayerName, newSoftmaxLayer);
            lgraph = replaceLayer(lgraph, classLayerName, newClassLayer);
            
            fprintf('ResNet50 model created successfully\n');
            fprintf('  Modified layers: %s -> fc_corrosion (%d classes)\n', ...
                fcLayerName, numClasses);
        end
        
        function lgraph = createEfficientNetB0(numClasses, inputSize)
            % Create EfficientNet-B0 classification model with transfer learning
            %
            % Inputs:
            %   numClasses - Number of output classes (default: 3)
            %   inputSize - [height, width, channels] (default: [224, 224, 3])
            %
            % Output:
            %   lgraph - Layer graph for EfficientNet-B0 classifier
            %
            % Architecture:
            %   - Base: Pre-trained EfficientNet-B0 from ImageNet
            %   - Modification: Replace classification head
            %   - Parameters: ~5M (more efficient than ResNet50)
            %
            % Requirements: 3.2, 3.4
            
            if nargin < 1 || isempty(numClasses)
                numClasses = 3;
            end
            
            if nargin < 2 || isempty(inputSize)
                inputSize = [224, 224, 3];
            end
            
            fprintf('Creating EfficientNet-B0 model...\n');
            fprintf('  Input size: [%d, %d, %d]\n', inputSize(1), inputSize(2), inputSize(3));
            fprintf('  Number of classes: %d\n', numClasses);
            
            % Load pre-trained EfficientNet-B0
            try
                net = efficientnetb0;
            catch ME
                error('ModelFactory:EfficientNetLoadError', ...
                    'Failed to load EfficientNet-B0. Ensure Deep Learning Toolbox Model for EfficientNet-b0 Network is installed.\nError: %s', ...
                    ME.message);
            end
            
            % Convert to layer graph
            lgraph = layerGraph(net);
            
            % Get layer names
            layerNames = {lgraph.Layers.Name};
            
            % Find final FC layer (typically 'efficientnet-b0|model|head|dense')
            fcLayerIdx = find(contains(layerNames, 'dense') & ...
                             (contains(layerNames, 'head') | contains(layerNames, 'fc')));
            if isempty(fcLayerIdx)
                % Try alternative naming
                fcLayerIdx = find(contains(layerNames, 'predictions'));
            end
            if isempty(fcLayerIdx)
                error('ModelFactory:LayerNotFound', 'Could not find final FC layer in EfficientNet-B0');
            end
            fcLayerName = layerNames{fcLayerIdx(end)}; % Take last match
            
            % Find classification output layer
            classLayerIdx = find(contains(layerNames, 'ClassificationLayer') | ...
                                contains(layerNames, 'classification-output'));
            if isempty(classLayerIdx)
                error('ModelFactory:LayerNotFound', 'Could not find classification layer in EfficientNet-B0');
            end
            classLayerName = layerNames{classLayerIdx(end)};
            
            % Find softmax layer
            softmaxLayerIdx = find(contains(layerNames, 'softmax'));
            if isempty(softmaxLayerIdx)
                error('ModelFactory:LayerNotFound', 'Could not find softmax layer in EfficientNet-B0');
            end
            softmaxLayerName = layerNames{softmaxLayerIdx(end)};
            
            % Create new layers
            newFCLayer = fullyConnectedLayer(numClasses, ...
                'Name', 'fc_corrosion', ...
                'WeightLearnRateFactor', 10, ...
                'BiasLearnRateFactor', 10);
            
            newSoftmaxLayer = softmaxLayer('Name', 'softmax_corrosion');
            newClassLayer = classificationLayer('Name', 'output_corrosion');
            
            % Replace the layers
            lgraph = replaceLayer(lgraph, fcLayerName, newFCLayer);
            lgraph = replaceLayer(lgraph, softmaxLayerName, newSoftmaxLayer);
            lgraph = replaceLayer(lgraph, classLayerName, newClassLayer);
            
            fprintf('EfficientNet-B0 model created successfully\n');
            fprintf('  Modified layers: %s -> fc_corrosion (%d classes)\n', ...
                fcLayerName, numClasses);
        end
        
        function lgraph = createCustomCNN(numClasses, inputSize)
            % Create custom lightweight CNN for corrosion classification
            %
            % Inputs:
            %   numClasses - Number of output classes (default: 3)
            %   inputSize - [height, width, channels] (default: [224, 224, 3])
            %
            % Output:
            %   lgraph - Layer graph for custom CNN classifier
            %
            % Architecture:
            %   - 4 convolutional blocks: Conv → BatchNorm → ReLU → MaxPool
            %   - Filter sizes: [32, 64, 128, 256]
            %   - 2 fully connected layers: FC(512) → Dropout(0.5) → FC(numClasses)
            %   - Parameters: ~2M (lightweight, faster inference)
            %
            % Requirements: 3.3
            
            if nargin < 1 || isempty(numClasses)
                numClasses = 3;
            end
            
            if nargin < 2 || isempty(inputSize)
                inputSize = [224, 224, 3];
            end
            
            fprintf('Creating Custom CNN model...\n');
            fprintf('  Input size: [%d, %d, %d]\n', inputSize(1), inputSize(2), inputSize(3));
            fprintf('  Number of classes: %d\n', numClasses);
            
            % Define filter sizes for convolutional blocks
            filterSizes = [32, 64, 128, 256];
            
            % Create layer array
            layers = [
                % Input layer
                imageInputLayer(inputSize, 'Name', 'input', 'Normalization', 'zscore')
                
                % Convolutional Block 1: 32 filters
                convolution2dLayer(3, filterSizes(1), 'Padding', 'same', 'Name', 'conv1')
                batchNormalizationLayer('Name', 'bn1')
                reluLayer('Name', 'relu1')
                maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool1')
                
                % Convolutional Block 2: 64 filters
                convolution2dLayer(3, filterSizes(2), 'Padding', 'same', 'Name', 'conv2')
                batchNormalizationLayer('Name', 'bn2')
                reluLayer('Name', 'relu2')
                maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool2')
                
                % Convolutional Block 3: 128 filters
                convolution2dLayer(3, filterSizes(3), 'Padding', 'same', 'Name', 'conv3')
                batchNormalizationLayer('Name', 'bn3')
                reluLayer('Name', 'relu3')
                maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool3')
                
                % Convolutional Block 4: 256 filters
                convolution2dLayer(3, filterSizes(4), 'Padding', 'same', 'Name', 'conv4')
                batchNormalizationLayer('Name', 'bn4')
                reluLayer('Name', 'relu4')
                maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool4')
                
                % Fully Connected Layers
                fullyConnectedLayer(512, 'Name', 'fc1')
                reluLayer('Name', 'relu_fc1')
                dropoutLayer(0.5, 'Name', 'dropout')
                
                fullyConnectedLayer(numClasses, 'Name', 'fc_output')
                softmaxLayer('Name', 'softmax')
                classificationLayer('Name', 'output')
            ];
            
            % Convert to layer graph
            lgraph = layerGraph(layers);
            
            fprintf('Custom CNN model created successfully\n');
            fprintf('  Architecture: 4 conv blocks [%d, %d, %d, %d] + 2 FC layers\n', ...
                filterSizes(1), filterSizes(2), filterSizes(3), filterSizes(4));
            fprintf('  Estimated parameters: ~2M\n');
        end
        
        function lgraph = configureTransferLearning(lgraph, numLayersToFineTune)
            % Configure layer learning rates for transfer learning
            %
            % Inputs:
            %   lgraph - Layer graph to configure
            %   numLayersToFineTune - Number of layers from end to fine-tune (default: 10)
            %
            % Output:
            %   lgraph - Configured layer graph with adjusted learning rates
            %
            % Strategy:
            %   - Freeze early layers (set learning rate to 0)
            %   - Fine-tune last N layers (keep default learning rate)
            %   - Train new classification head from scratch (higher learning rate)
            %
            % Requirements: 3.4
            
            if nargin < 2 || isempty(numLayersToFineTune)
                numLayersToFineTune = 10;
            end
            
            fprintf('Configuring transfer learning...\n');
            fprintf('  Layers to fine-tune: %d\n', numLayersToFineTune);
            
            % Get all layers
            layers = lgraph.Layers;
            numLayers = length(layers);
            
            % Calculate freeze threshold
            freezeThreshold = max(1, numLayers - numLayersToFineTune);
            
            % Iterate through layers and adjust learning rates
            numFrozen = 0;
            numFineTuned = 0;
            
            for i = 1:numLayers
                layer = layers(i);
                layerName = layer.Name;
                
                % Check if layer has learnable parameters
                hasWeights = isprop(layer, 'Weights') || ...
                            isprop(layer, 'WeightLearnRateFactor');
                
                if hasWeights
                    if i < freezeThreshold
                        % Freeze early layers
                        try
                            % Create new layer with frozen weights
                            if isa(layer, 'nnet.cnn.layer.Convolution2DLayer')
                                newLayer = convolution2dLayer(layer.FilterSize, ...
                                    layer.NumFilters, ...
                                    'Padding', layer.PaddingSize, ...
                                    'Stride', layer.Stride, ...
                                    'Name', layerName, ...
                                    'WeightLearnRateFactor', 0, ...
                                    'BiasLearnRateFactor', 0);
                                lgraph = replaceLayer(lgraph, layerName, newLayer);
                                numFrozen = numFrozen + 1;
                            elseif isa(layer, 'nnet.cnn.layer.FullyConnectedLayer')
                                newLayer = fullyConnectedLayer(layer.OutputSize, ...
                                    'Name', layerName, ...
                                    'WeightLearnRateFactor', 0, ...
                                    'BiasLearnRateFactor', 0);
                                lgraph = replaceLayer(lgraph, layerName, newLayer);
                                numFrozen = numFrozen + 1;
                            end
                        catch
                            % If replacement fails, skip this layer
                            continue;
                        end
                    else
                        % Fine-tune later layers (keep default learning rate)
                        numFineTuned = numFineTuned + 1;
                    end
                end
            end
            
            fprintf('Transfer learning configured:\n');
            fprintf('  Frozen layers: %d\n', numFrozen);
            fprintf('  Fine-tuned layers: %d\n', numFineTuned);
            fprintf('  New layers: trained from scratch with higher learning rate\n');
        end
    end
end
