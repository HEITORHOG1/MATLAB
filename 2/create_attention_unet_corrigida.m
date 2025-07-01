function lgraph = create_attention_unet_corrigida(inputSize, numClasses)
    % ATTENTION U-NET CORRIGIDA PARA MATLAB
    % 
    % Esta implementação cria uma versão funcional da Attention U-Net
    % adaptada às limitações do MATLAB, mas mantendo os princípios
    % dos mecanismos de atenção.
    
    fprintf('Criando Attention U-Net corrigida...\n');
    
    % Verificar se Deep Learning Toolbox está disponível
    if ~license('test', 'Neural_Network_Toolbox')
        error('Deep Learning Toolbox é necessário para esta função');
    end
    
    try
        % Estratégia: Criar U-Net customizada com mecanismos de atenção simplificados
        lgraph = create_custom_attention_unet(inputSize, numClasses);
        
        % Verificar se a rede é válida
        analyzeNetwork(lgraph);
        fprintf('Attention U-Net criada e validada com sucesso!\n');
        
    catch ME
        fprintf('Erro na criação da Attention U-Net customizada: %s\n', ME.message);
        fprintf('Usando U-Net aprimorada como fallback...\n');
        lgraph = create_enhanced_unet_fallback(inputSize, numClasses);
    end
end

function lgraph = create_custom_attention_unet(inputSize, numClasses)
    % Criar Attention U-Net customizada com blocos de atenção simplificados
    
    % Inicializar grafo de camadas
    lgraph = layerGraph();
    
    % Parâmetros
    filterSizes = [64, 128, 256, 512, 1024];
    
    %% ENCODER PATH
    % Input layer
    lgraph = addLayers(lgraph, imageInputLayer(inputSize, 'Name', 'input', 'Normalization', 'none'));
    
    % Encoder blocks
    prevLayerName = 'input';
    skipConnections = {};
    
    for i = 1:length(filterSizes)-1
        blockName = sprintf('encoder_%d', i);
        
        % Convolutional block
        [lgraph, outputName] = add_conv_block(lgraph, prevLayerName, filterSizes(i), blockName);
        skipConnections{i} = outputName;
        
        % Max pooling
        poolName = sprintf('pool_%d', i);
        lgraph = addLayers(lgraph, maxPooling2dLayer(2, 'Stride', 2, 'Name', poolName));
        lgraph = connectLayers(lgraph, outputName, poolName);
        
        prevLayerName = poolName;
    end
    
    %% BOTTLENECK
    [lgraph, bottleneckOutput] = add_conv_block(lgraph, prevLayerName, filterSizes(end), 'bottleneck');
    
    %% DECODER PATH WITH ATTENTION
    prevLayerName = bottleneckOutput;
    
    for i = length(filterSizes)-1:-1:1
        % Upsampling
        upsampleName = sprintf('upsample_%d', i);
        lgraph = addLayers(lgraph, transposedConv2dLayer(2, filterSizes(i), 'Stride', 2, 'Name', upsampleName));
        lgraph = connectLayers(lgraph, prevLayerName, upsampleName);
        
        % Attention gate (simplified)
        skipConnection = skipConnections{i};
        [lgraph, attentionOutput] = add_attention_gate(lgraph, upsampleName, skipConnection, filterSizes(i), i);
        
        % Concatenation
        concatName = sprintf('concat_%d', i);
        lgraph = addLayers(lgraph, concatenationLayer(3, 2, 'Name', concatName));
        lgraph = connectLayers(lgraph, upsampleName, sprintf('%s/in1', concatName));
        lgraph = connectLayers(lgraph, attentionOutput, sprintf('%s/in2', concatName));
        
        % Decoder block
        blockName = sprintf('decoder_%d', i);
        [lgraph, outputName] = add_conv_block(lgraph, concatName, filterSizes(i), blockName);
        
        prevLayerName = outputName;
    end
    
    %% OUTPUT
    % Final convolution
    lgraph = addLayers(lgraph, [
        convolution2dLayer(1, numClasses, 'Name', 'final_conv', 'Padding', 'same')
        pixelClassificationLayer('Name', 'output')
    ]);
    lgraph = connectLayers(lgraph, prevLayerName, 'final_conv');
end

function [lgraph, outputName] = add_conv_block(lgraph, inputName, numFilters, blockName)
    % Adicionar bloco convolucional com batch normalization e ReLU
    
    conv1Name = sprintf('%s_conv1', blockName);
    bn1Name = sprintf('%s_bn1', blockName);
    relu1Name = sprintf('%s_relu1', blockName);
    conv2Name = sprintf('%s_conv2', blockName);
    bn2Name = sprintf('%s_bn2', blockName);
    relu2Name = sprintf('%s_relu2', blockName);
    
    layers = [
        convolution2dLayer(3, numFilters, 'Padding', 'same', 'Name', conv1Name, ...
                          'WeightL2Factor', 0.0001, 'BiasL2Factor', 0.0001)
        batchNormalizationLayer('Name', bn1Name)
        reluLayer('Name', relu1Name)
        convolution2dLayer(3, numFilters, 'Padding', 'same', 'Name', conv2Name, ...
                          'WeightL2Factor', 0.0001, 'BiasL2Factor', 0.0001)
        batchNormalizationLayer('Name', bn2Name)
        reluLayer('Name', relu2Name)
    ];
    
    lgraph = addLayers(lgraph, layers);
    lgraph = connectLayers(lgraph, inputName, conv1Name);
    
    outputName = relu2Name;
end

function [lgraph, outputName] = add_attention_gate(lgraph, gatingSignal, skipConnection, numFilters, gateIndex)
    % Adicionar gate de atenção simplificado
    
    gateName = sprintf('attention_gate_%d', gateIndex);
    
    % Gating signal processing
    gConvName = sprintf('%s_g_conv', gateName);
    lgraph = addLayers(lgraph, convolution2dLayer(1, numFilters/2, 'Name', gConvName, 'Padding', 'same'));
    lgraph = connectLayers(lgraph, gatingSignal, gConvName);
    
    % Skip connection processing
    xConvName = sprintf('%s_x_conv', gateName);
    lgraph = addLayers(lgraph, convolution2dLayer(1, numFilters/2, 'Name', xConvName, 'Padding', 'same'));
    lgraph = connectLayers(lgraph, skipConnection, xConvName);
    
    % Addition and activation
    addName = sprintf('%s_add', gateName);
    reluName = sprintf('%s_relu', gateName);
    psiName = sprintf('%s_psi', gateName);
    sigmoidName = sprintf('%s_sigmoid', gateName);
    
    lgraph = addLayers(lgraph, [
        additionLayer(2, 'Name', addName)
        reluLayer('Name', reluName)
        convolution2dLayer(1, 1, 'Name', psiName, 'Padding', 'same')
        sigmoidLayer('Name', sigmoidName)
    ]);
    
    lgraph = connectLayers(lgraph, gConvName, sprintf('%s/in1', addName));
    lgraph = connectLayers(lgraph, xConvName, sprintf('%s/in2', addName));
    
    % Apply attention weights
    multName = sprintf('%s_mult', gateName);
    lgraph = addLayers(lgraph, multiplicationLayer(2, 'Name', multName));
    lgraph = connectLayers(lgraph, skipConnection, sprintf('%s/in1', multName));
    lgraph = connectLayers(lgraph, sigmoidName, sprintf('%s/in2', multName));
    
    outputName = multName;
end

function lgraph = create_enhanced_unet_fallback(inputSize, numClasses)
    % Fallback: U-Net aprimorada quando Attention U-Net falha
    
    fprintf('Criando U-Net aprimorada como fallback...\n');
    
    % Criar U-Net base com maior profundidade
    lgraph = unetLayers(inputSize, numClasses, 'EncoderDepth', 5);
    
    % Adicionar regularização L2 a todas as camadas convolucionais
    layers = lgraph.Layers;
    
    for i = 1:length(layers)
        if isa(layers(i), 'nnet.cnn.layer.Convolution2DLayer')
            % Criar nova camada com regularização
            newLayer = convolution2dLayer( ...
                layers(i).FilterSize, ...
                layers(i).NumFilters, ...
                'Name', layers(i).Name, ...
                'Padding', layers(i).PaddingMode, ...
                'Stride', layers(i).Stride, ...
                'WeightL2Factor', 0.001, ...
                'BiasL2Factor', 0.001);
            
            % Substituir camada
            lgraph = replaceLayer(lgraph, layers(i).Name, newLayer);
        end
    end
    
    % Adicionar dropout após algumas camadas ReLU do encoder
    layers = lgraph.Layers;
    layerNames = {layers.Name};
    reluLayers = layerNames(contains(layerNames, 'ReLU') & contains(layerNames, 'Encoder'));
    
    % Adicionar dropout a cada segunda camada ReLU do encoder
    for i = 2:2:min(length(reluLayers), 6)
        reluName = reluLayers{i};
        dropoutName = strrep(reluName, 'ReLU', 'Dropout');
        
        try
            % Obter conexões da camada ReLU
            connections = lgraph.Connections;
            targetLayers = connections.Destination(strcmp(connections.Source, reluName));
            
            % Adicionar dropout
            lgraph = addLayers(lgraph, dropoutLayer(0.2, 'Name', dropoutName));
            
            % Reconectar
            for j = 1:length(targetLayers)
                lgraph = disconnectLayers(lgraph, reluName, targetLayers{j});
            end
            lgraph = connectLayers(lgraph, reluName, dropoutName);
            for j = 1:length(targetLayers)
                lgraph = connectLayers(lgraph, dropoutName, targetLayers{j});
            end
        catch
            % Se houver erro, continuar sem dropout nesta camada
            continue;
        end
    end
    
    fprintf('U-Net aprimorada criada com:\n');
    fprintf('  - EncoderDepth: 5\n');
    fprintf('  - Regularização L2: 0.001\n');
    fprintf('  - Dropout: 0.2 em camadas selecionadas\n');
end

