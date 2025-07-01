function melhorias_treinamento()
    % MELHORIAS PARA O TREINAMENTO DE REDES DE SEGMENTAÇÃO
    % 
    % Este arquivo contém implementações de técnicas avançadas
    % para melhorar o treinamento e avaliação dos modelos.
end

function augmentedDatastore = criar_datastore_com_augmentation(imageDir, maskDir, config)
    % Criar datastore com data augmentation
    
    fprintf('Criando datastore com data augmentation...\n');
    
    % Listar arquivos
    imageFiles = [dir(fullfile(imageDir, '*.png')); dir(fullfile(imageDir, '*.jpg')); dir(fullfile(imageDir, '*.jpeg'))];
    maskFiles = [dir(fullfile(maskDir, '*.png')); dir(fullfile(maskDir, '*.jpg')); dir(fullfile(maskDir, '*.jpeg'))];
    
    % Criar listas de caminhos completos
    imagePaths = fullfile(imageDir, {imageFiles.name});
    maskPaths = fullfile(maskDir, {maskFiles.name});
    
    % Verificar correspondência
    if length(imagePaths) ~= length(maskPaths)
        warning('Número de imagens (%d) diferente do número de máscaras (%d)', ...
                length(imagePaths), length(maskPaths));
        minLength = min(length(imagePaths), length(maskPaths));
        imagePaths = imagePaths(1:minLength);
        maskPaths = maskPaths(1:minLength);
    end
    
    % Determinar classes das máscaras
    [classNames, labelIDs] = determinar_classes_mascaras(maskPaths{1});
    
    % Criar datastores base
    imds = imageDatastore(imagePaths);
    pxds = pixelLabelDatastore(maskPaths, classNames, labelIDs);
    
    % Combinar datastores
    combinedDS = combine(imds, pxds);
    
    % Aplicar transformações
    if config.useDataAugmentation
        fprintf('Aplicando data augmentation...\n');
        augmentedDatastore = transform(combinedDS, @(data) aplicar_augmentation_completo(data, config));
    else
        augmentedDatastore = transform(combinedDS, @(data) preprocessar_dados_basico(data, config));
    end
    
    fprintf('Datastore criado com sucesso!\n');
end

function [classNames, labelIDs] = determinar_classes_mascaras(maskPath)
    % Determinar automaticamente as classes das máscaras
    
    mask = imread(maskPath);
    if size(mask, 3) > 1
        mask = rgb2gray(mask);
    end
    
    uniqueVals = unique(mask(:));
    
    if length(uniqueVals) == 2
        classNames = ["background", "foreground"];
        labelIDs = double(uniqueVals');
    else
        % Binarizar se necessário
        threshold = mean(double(uniqueVals));
        classNames = ["background", "foreground"];
        labelIDs = [0, 1];
        fprintf('Máscaras serão binarizadas com threshold: %.2f\n', threshold);
    end
    
    fprintf('Classes detectadas: %s\n', strjoin(string(classNames), ', '));
    fprintf('Label IDs: %s\n', num2str(labelIDs));
end

function data = aplicar_augmentation_completo(data, config)
    % Aplicar conjunto completo de transformações de data augmentation
    
    img = data{1};
    mask = data{2};
    
    % Preprocessamento básico primeiro
    [img, mask] = preprocessar_dados_base(img, mask, config);
    
    % Aplicar augmentations com probabilidade
    if rand < config.augmentationProbability
        
        % 1. Flip horizontal
        if rand < 0.5
            img = fliplr(img);
            mask = fliplr(mask);
        end
        
        % 2. Flip vertical
        if rand < 0.3
            img = flipud(img);
            mask = flipud(mask);
        end
        
        % 3. Rotação
        if rand < 0.6
            angle = (rand - 0.5) * 2 * config.rotationRange;
            img = imrotate(img, angle, 'bilinear', 'crop');
            mask = imrotate(mask, angle, 'nearest', 'crop');
        end
        
        % 4. Ajuste de brilho
        if rand < 0.5
            brightness_factor = 1 + (rand - 0.5) * 2 * config.brightnessRange;
            img = img * brightness_factor;
            img = min(max(img, 0), 1);
        end
        
        % 5. Ajuste de contraste
        if rand < 0.4
            contrast_factor = 1 + (rand - 0.5) * 0.4;  % ±20%
            img = (img - 0.5) * contrast_factor + 0.5;
            img = min(max(img, 0), 1);
        end
        
        % 6. Ruído gaussiano
        if rand < 0.3
            noise_std = 0.02;
            noise = noise_std * randn(size(img));
            img = img + noise;
            img = min(max(img, 0), 1);
        end
        
        % 7. Deformação elástica (simplificada)
        if rand < 0.2
            [img, mask] = aplicar_deformacao_elastica(img, mask);
        end
    end
    
    data = {img, mask};
end

function data = preprocessar_dados_basico(data, config)
    % Preprocessamento básico sem augmentation
    
    img = data{1};
    mask = data{2};
    
    [img, mask] = preprocessar_dados_base(img, mask, config);
    
    data = {img, mask};
end

function [img, mask] = preprocessar_dados_base(img, mask, config)
    % Preprocessamento base comum a todos os dados
    
    % Redimensionar
    img = imresize(img, config.inputSize(1:2));
    mask = imresize(mask, config.inputSize(1:2), 'nearest');
    
    % Garantir 3 canais na imagem
    if size(img, 3) == 1
        img = repmat(img, [1, 1, 3]);
    elseif size(img, 3) > 3
        img = img(:,:,1:3);
    end
    
    % Normalizar imagem
    img = im2double(img);
    
    % Processar máscara
    if ~isa(mask, 'categorical')
        if size(mask, 3) > 1
            mask = rgb2gray(mask);
        end
        
        % Binarizar se necessário
        uniqueVals = unique(mask(:));
        if length(uniqueVals) > 2
            threshold = mean(double(uniqueVals));
            mask = uint8(mask > threshold);
            mask = mask * 255;  % 0 e 255
        end
    end
end

function [img, mask] = aplicar_deformacao_elastica(img, mask)
    % Aplicar deformação elástica simplificada
    
    try
        % Criar grid de deformação
        [h, w, ~] = size(img);
        [X, Y] = meshgrid(1:w, 1:h);
        
        % Parâmetros de deformação
        alpha = 10;  % Intensidade da deformação
        sigma = 3;   % Suavização
        
        % Gerar campos de deslocamento aleatórios
        dx = (rand(h, w) - 0.5) * 2 * alpha;
        dy = (rand(h, w) - 0.5) * 2 * alpha;
        
        % Suavizar campos de deslocamento
        dx = imgaussfilt(dx, sigma);
        dy = imgaussfilt(dy, sigma);
        
        % Aplicar deformação
        Xq = X + dx;
        Yq = Y + dy;
        
        % Interpolar imagem
        for c = 1:size(img, 3)
            img(:,:,c) = interp2(X, Y, img(:,:,c), Xq, Yq, 'linear', 0);
        end
        
        % Interpolar máscara (nearest neighbor)
        if size(mask, 3) == 1
            mask = interp2(X, Y, double(mask), Xq, Yq, 'nearest', 0);
            mask = uint8(mask);
        end
        
    catch
        % Se houver erro, retornar dados originais
        % (deformação elástica é opcional)
    end
end

function resultados = validacao_cruzada_k_fold(imageDir, maskDir, config, k)
    % Implementar validação cruzada k-fold
    
    fprintf('\n=== VALIDAÇÃO CRUZADA %d-FOLD ===\n', k);
    
    % Listar todos os arquivos
    imageFiles = [dir(fullfile(imageDir, '*.png')); dir(fullfile(imageDir, '*.jpg')); dir(fullfile(imageDir, '*.jpeg'))];
    maskFiles = [dir(fullfile(maskDir, '*.png')); dir(fullfile(maskDir, '*.jpg')); dir(fullfile(maskDir, '*.jpeg'))];
    
    n = min(length(imageFiles), length(maskFiles));
    
    % Dividir dados em k folds
    indices = randperm(n);
    foldSize = floor(n / k);
    
    resultados = struct();
    resultados.folds = cell(k, 1);
    resultados.unet_metrics = [];
    resultados.attention_metrics = [];
    
    for fold = 1:k
        fprintf('\n--- FOLD %d/%d ---\n', fold, k);
        
        % Definir índices de teste para este fold
        testStart = (fold - 1) * foldSize + 1;
        testEnd = min(fold * foldSize, n);
        testIdx = indices(testStart:testEnd);
        trainIdx = setdiff(indices, testIdx);
        
        fprintf('Treinamento: %d amostras, Teste: %d amostras\n', ...
                length(trainIdx), length(testIdx));
        
        % Criar datastores para este fold
        [dsTrain, dsTest] = criar_datastores_fold(imageFiles, maskFiles, ...
                                                  imageDir, maskDir, ...
                                                  trainIdx, testIdx, config);
        
        % Treinar e avaliar U-Net clássica
        fprintf('Treinando U-Net clássica...\n');
        [netUNet, infoUNet] = treinar_unet_classica(dsTrain, dsTest, config);
        metricsUNet = avaliar_modelo(netUNet, dsTest, config);
        
        % Treinar e avaliar Attention U-Net
        fprintf('Treinando Attention U-Net...\n');
        [netAttention, infoAttention] = treinar_attention_unet(dsTrain, dsTest, config);
        metricsAttention = avaliar_modelo(netAttention, dsTest, config);
        
        % Armazenar resultados
        resultados.folds{fold} = struct();
        resultados.folds{fold}.unet = metricsUNet;
        resultados.folds{fold}.attention = metricsAttention;
        resultados.folds{fold}.trainInfo = struct('unet', infoUNet, 'attention', infoAttention);
        
        % Acumular métricas
        resultados.unet_metrics = [resultados.unet_metrics; metricsUNet.segmentation.meanIoU];
        resultados.attention_metrics = [resultados.attention_metrics; metricsAttention.segmentation.meanIoU];
        
        fprintf('Fold %d - IoU U-Net: %.4f, IoU Attention: %.4f\n', ...
                fold, metricsUNet.segmentation.meanIoU, metricsAttention.segmentation.meanIoU);
    end
    
    % Calcular estatísticas finais
    resultados.unet_mean = mean(resultados.unet_metrics);
    resultados.unet_std = std(resultados.unet_metrics);
    resultados.attention_mean = mean(resultados.attention_metrics);
    resultados.attention_std = std(resultados.attention_metrics);
    
    % Teste estatístico
    [h, p] = ttest2(resultados.unet_metrics, resultados.attention_metrics);
    resultados.statistical_test = struct('h', h, 'p', p);
    
    % Exibir resultados finais
    fprintf('\n=== RESULTADOS FINAIS DA VALIDAÇÃO CRUZADA ===\n');
    fprintf('U-Net Clássica - IoU: %.4f ± %.4f\n', resultados.unet_mean, resultados.unet_std);
    fprintf('Attention U-Net - IoU: %.4f ± %.4f\n', resultados.attention_mean, resultados.attention_std);
    fprintf('Teste t-student: p = %.4f, significativo = %s\n', p, h ? 'Sim' : 'Não');
    
    % Salvar resultados
    save(fullfile(config.outputDir, 'resultados_validacao_cruzada.mat'), 'resultados');
end

function [dsTrain, dsTest] = criar_datastores_fold(imageFiles, maskFiles, imageDir, maskDir, trainIdx, testIdx, config)
    % Criar datastores para um fold específico
    
    % Caminhos de treinamento
    trainImagePaths = fullfile(imageDir, {imageFiles(trainIdx).name});
    trainMaskPaths = fullfile(maskDir, {maskFiles(trainIdx).name});
    
    % Caminhos de teste
    testImagePaths = fullfile(imageDir, {imageFiles(testIdx).name});
    testMaskPaths = fullfile(maskDir, {maskFiles(testIdx).name});
    
    % Determinar classes
    [classNames, labelIDs] = determinar_classes_mascaras(trainMaskPaths{1});
    
    % Criar datastores de treinamento
    imdsTrain = imageDatastore(trainImagePaths);
    pxdsTrain = pixelLabelDatastore(trainMaskPaths, classNames, labelIDs);
    dsTrain = combine(imdsTrain, pxdsTrain);
    
    if config.useDataAugmentation
        dsTrain = transform(dsTrain, @(data) aplicar_augmentation_completo(data, config));
    else
        dsTrain = transform(dsTrain, @(data) preprocessar_dados_basico(data, config));
    end
    
    % Criar datastores de teste
    imdsTest = imageDatastore(testImagePaths);
    pxdsTest = pixelLabelDatastore(testMaskPaths, classNames, labelIDs);
    dsTest = combine(imdsTest, pxdsTest);
    dsTest = transform(dsTest, @(data) preprocessar_dados_basico(data, config));
end

function [net, info] = treinar_unet_classica(dsTrain, dsVal, config)
    % Treinar U-Net clássica com early stopping
    
    % Criar arquitetura
    lgraph = unetLayers(config.inputSize, config.numClasses, 'EncoderDepth', 4);
    
    % Configurar opções de treinamento com early stopping
    options = trainingOptions('adam', ...
        'InitialLearnRate', config.initialLearningRate, ...
        'MaxEpochs', config.numEpochs, ...
        'MiniBatchSize', config.miniBatchSize, ...
        'ValidationData', dsVal, ...
        'ValidationFrequency', config.validationFrequency, ...
        'ValidationPatience', config.validationPatience, ...
        'Plots', 'none', ...  % Desabilitar plots para validação cruzada
        'Verbose', false, ...
        'ExecutionEnvironment', config.useGPU ? 'auto' : 'cpu');
    
    % Treinar
    [net, info] = trainNetwork(dsTrain, lgraph, options);
end

function [net, info] = treinar_attention_unet(dsTrain, dsVal, config)
    % Treinar Attention U-Net com early stopping
    
    % Criar arquitetura
    lgraph = create_attention_unet_corrigida(config.inputSize, config.numClasses);
    
    % Configurar opções de treinamento (learning rate menor)
    options = trainingOptions('adam', ...
        'InitialLearnRate', config.initialLearningRateAttention, ...
        'MaxEpochs', config.numEpochs, ...
        'MiniBatchSize', config.miniBatchSize, ...
        'ValidationData', dsVal, ...
        'ValidationFrequency', config.validationFrequency, ...
        'ValidationPatience', config.validationPatience, ...
        'Plots', 'none', ...
        'Verbose', false, ...
        'ExecutionEnvironment', config.useGPU ? 'auto' : 'cpu');
    
    % Treinar
    [net, info] = trainNetwork(dsTrain, lgraph, options);
end

function metrics = avaliar_modelo(net, dsTest, config)
    % Avaliar modelo usando métricas avançadas
    
    % Usar função de métricas avançadas
    metrics = calcular_metricas_completas(net, dsTest, config);
end

function otimizar_hiperparametros(imageDir, maskDir, config)
    % Otimização automática de hiperparâmetros usando grid search
    
    fprintf('\n=== OTIMIZAÇÃO DE HIPERPARÂMETROS ===\n');
    
    % Definir espaço de busca
    learningRates = [1e-4, 5e-4, 1e-3, 5e-3];
    batchSizes = [4, 8, 16];
    encoderDepths = [3, 4, 5];
    
    melhores_resultados = struct();
    melhores_resultados.melhor_iou = 0;
    melhores_resultados.melhores_params = [];
    
    total_combinacoes = length(learningRates) * length(batchSizes) * length(encoderDepths);
    combinacao_atual = 0;
    
    for lr = learningRates
        for bs = batchSizes
            for ed = encoderDepths
                combinacao_atual = combinacao_atual + 1;
                
                fprintf('\nCombinação %d/%d: LR=%.1e, BS=%d, ED=%d\n', ...
                        combinacao_atual, total_combinacoes, lr, bs, ed);
                
                % Configurar parâmetros temporários
                config_temp = config;
                config_temp.initialLearningRate = lr;
                config_temp.miniBatchSize = bs;
                config_temp.numEpochs = 10;  % Reduzir épocas para otimização
                
                try
                    % Treinar e avaliar com validação simples
                    resultado = treinar_e_avaliar_rapido(imageDir, maskDir, config_temp, ed);
                    
                    fprintf('  Resultado IoU: %.4f\n', resultado);
                    
                    % Verificar se é o melhor resultado
                    if resultado > melhores_resultados.melhor_iou
                        melhores_resultados.melhor_iou = resultado;
                        melhores_resultados.melhores_params = [lr, bs, ed];
                        
                        fprintf('  *** NOVO MELHOR RESULTADO! ***\n');
                    end
                    
                catch ME
                    fprintf('  Erro: %s\n', ME.message);
                    continue;
                end
            end
        end
    end
    
    % Exibir melhores parâmetros
    fprintf('\n=== MELHORES PARÂMETROS ENCONTRADOS ===\n');
    fprintf('IoU: %.4f\n', melhores_resultados.melhor_iou);
    fprintf('Learning Rate: %.1e\n', melhores_resultados.melhores_params(1));
    fprintf('Batch Size: %d\n', melhores_resultados.melhores_params(2));
    fprintf('Encoder Depth: %d\n', melhores_resultados.melhores_params(3));
    
    % Salvar resultados
    save(fullfile(config.outputDir, 'otimizacao_hiperparametros.mat'), 'melhores_resultados');
end

function iou = treinar_e_avaliar_rapido(imageDir, maskDir, config, encoderDepth)
    % Treinamento e avaliação rápidos para otimização de hiperparâmetros
    
    % Criar datastore
    ds = criar_datastore_com_augmentation(imageDir, maskDir, config);
    
    % Dividir dados (80/20)
    numSamples = length(ds.UnderlyingDatastores{1}.Files);
    numTrain = round(0.8 * numSamples);
    
    indices = randperm(numSamples);
    trainIndices = indices(1:numTrain);
    valIndices = indices(numTrain+1:end);
    
    dsTrain = subset(ds, trainIndices);
    dsVal = subset(ds, valIndices);
    
    % Criar e treinar modelo
    lgraph = unetLayers(config.inputSize, config.numClasses, 'EncoderDepth', encoderDepth);
    
    options = trainingOptions('adam', ...
        'InitialLearnRate', config.initialLearningRate, ...
        'MaxEpochs', config.numEpochs, ...
        'MiniBatchSize', config.miniBatchSize, ...
        'ValidationData', dsVal, ...
        'ValidationFrequency', 5, ...
        'ValidationPatience', 5, ...
        'Plots', 'none', ...
        'Verbose', false, ...
        'ExecutionEnvironment', 'cpu');  % Usar CPU para ser mais rápido
    
    [net, ~] = trainNetwork(dsTrain, lgraph, options);
    
    % Avaliar rapidamente
    metrics = calcular_metricas_completas(net, dsVal, config);
    iou = metrics.segmentation.meanIoU;
end

