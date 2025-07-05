function treinar_unet_simples(config)
    % Treinamento simples da U-Net para teste rapido
    % VERSÃO DEFINITIVA - TODOS OS ERROS CORRIGIDOS
    
    if nargin < 1
        error('Configuração é necessária. Execute primeiro: executar_comparacao()');
    end
    
    fprintf('\n=== TREINAMENTO U-NET SIMPLES (TESTE CORRIGIDO) ===\n');
    
    % Validar e configurar parâmetros de teste
    if ~isfield(config, 'quickTest')
        config.quickTest = struct('numSamples', 50, 'maxEpochs', 5);
        fprintf('⚠ Campo quickTest não encontrado. Usando valores padrão.\n');
    end
    
    if ~isfield(config, 'miniBatchSize')
        config.miniBatchSize = 8;
        fprintf('⚠ Campo miniBatchSize não encontrado. Usando valor padrão: 8\n');
    end
    
    % Mostrar configuração
    fprintf('Configuração do teste:\n');
    fprintf('  Imagens: %s\n', config.imageDir);
    fprintf('  Máscaras: %s\n', config.maskDir);
    fprintf('  Épocas: %d (teste rápido)\n', config.quickTest.maxEpochs);
    fprintf('  Batch size: %d\n', config.miniBatchSize);
    
    % Carregar dados
    [images, masks] = carregar_dados_robustos(config);
    
    fprintf('Arquivos encontrados:\n');
    fprintf('  Imagens: %d\n', length(images));
    fprintf('  Máscaras: %d\n', length(masks));
    
    % Usar apenas uma amostra pequena para teste rápido
    numSamples = min(config.quickTest.numSamples, length(images));
    fprintf('Usando %d amostras para teste rápido\n', numSamples);
    
    % Selecionar amostras aleatórias
    indices = randperm(length(images), numSamples);
    selectedImages = images(indices);
    selectedMasks = masks(indices);
    
    % Analisar máscaras
    [classNames, labelIDs] = analisar_mascaras_automatico(config.maskDir, selectedMasks);
    
    % Dividir dados
    numTrain = round(0.8 * numSamples);
    numVal = numSamples - numTrain;
    
    trainImages = selectedImages(1:numTrain);
    trainMasks = selectedMasks(1:numTrain);
    valImages = selectedImages(numTrain+1:end);
    valMasks = selectedMasks(numTrain+1:end);
    
    fprintf('\nPreparando dados...\n');
    
    % Criar datastores
    imdsTrain = imageDatastore(trainImages);
    imdsVal = imageDatastore(valImages);
    
    pxdsTrain = pixelLabelDatastore(trainMasks, classNames, labelIDs);
    pxdsVal = pixelLabelDatastore(valMasks, classNames, labelIDs);
    
    % Combinar datastores
    dsTrain = combine(imdsTrain, pxdsTrain);
    dsVal = combine(imdsVal, pxdsVal);
    
    % Aplicar transformações
    dsTrain = transform(dsTrain, @(data) preprocessDataCorrigido(data, config, labelIDs, true));
    dsVal = transform(dsVal, @(data) preprocessDataCorrigido(data, config, labelIDs, false));
    
    % CORREÇÃO DEFINITIVA - Não usar .Files
    fprintf('Dados preparados:\n');
    fprintf('  Treinamento: %d amostras\n', numTrain);
    fprintf('  Validação: %d amostras\n', numVal);
    
    fprintf('Datastores criados com sucesso!\n');
    
    % Criar arquitetura U-Net
    fprintf('\nCriando arquitetura U-Net...\n');
    inputSize = config.inputSize;
    numClasses = config.numClasses;
    
    lgraph = unetLayers(inputSize, numClasses, 'EncoderDepth', 4);
    fprintf('U-Net criada com sucesso!\n');
    
    % Configurar opções de treinamento
    options = trainingOptions('adam', ...
        'InitialLearnRate', 1e-3, ...
        'MaxEpochs', config.quickTest.maxEpochs, ...
        'MiniBatchSize', config.miniBatchSize, ...
        'ValidationData', dsVal, ...
        'ValidationFrequency', 2, ...
        'Plots', 'training-progress', ...
        'Verbose', true, ...
        'ExecutionEnvironment', 'auto');
    
    % Treinar rede
    fprintf('\n=== INICIANDO TREINAMENTO ===\n');
    fprintf('Inicio: %s\n', string(datetime("now")));
    fprintf('Treinando U-Net simples...\n');
    
    try
        net = trainNetwork(dsTrain, lgraph, options);
        fprintf('✓ Treinamento concluído!\n');
        fprintf('Fim: %s\n', string(datetime("now")));
        
        % Salvar modelo
        modelPath = 'unet_simples_teste.mat';
        save(modelPath, 'net', 'config', 'classNames', 'labelIDs');
        fprintf('Modelo salvo em: %s\n', modelPath);
        
        % Avaliar modelo
        fprintf('\n=== AVALIACAO RAPIDA ===\n');
        avaliar_modelo_simples(net, dsVal, numVal);
        
    catch ME
        fprintf('❌ Erro durante o treinamento: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        rethrow(ME);
    end
end

function avaliar_modelo_simples(net, dsVal, numValSamples)
    % Avaliação simples do modelo
    
    try
        fprintf('Calculando métricas básicas...\n');
        
        % Coletar algumas predições
        reset(dsVal);
        numSamples = min(10, numValSamples);  % CORREÇÃO DEFINITIVA - Usar numValSamples
        
        ious = [];
        accuracies = [];
        
        for i = 1:numSamples
            if hasdata(dsVal)
                data = read(dsVal);
                img = data{1};
                gt = data{2};
                
                % Predição
                pred = semanticseg(img, net);
                
                % Calcular métricas
                iou = calcular_iou_simples(pred, gt);
                acc = calcular_accuracy_simples(pred, gt);
                
                ious = [ious, iou];
                accuracies = [accuracies, acc];
                
                fprintf('  Amostra %d: IoU=%.3f, Acc=%.3f\n', i, iou, acc);
            end
        end
        
        % Estatísticas finais
        if ~isempty(ious)
            fprintf('\n--- Métricas Finais ---\n');
            fprintf('IoU médio: %.4f ± %.4f\n', mean(ious), std(ious));
            fprintf('Acurácia média: %.4f ± %.4f\n', mean(accuracies), std(accuracies));
            
            % Salvar métricas
            metricas = struct();
            metricas.iou_mean = mean(ious);
            metricas.iou_std = std(ious);
            metricas.acc_mean = mean(accuracies);
            metricas.acc_std = std(accuracies);
            metricas.timestamp = datetime('now');
            
            save('metricas_teste_simples.mat', 'metricas');
            fprintf('Métricas salvas em: metricas_teste_simples.mat\n');
        else
            fprintf('⚠ Nenhuma métrica calculada.\n');
        end
        
    catch ME
        fprintf('❌ Erro na avaliação: %s\n', ME.message);
    end
end

function iou = calcular_iou_simples(pred, gt)
    % Calcular IoU simples
    
    try
        % Converter para binário
        if iscategorical(pred)
            predBinary = double(pred) > 1;
        else
            predBinary = pred > 0;
        end
        
        if iscategorical(gt)
            gtBinary = double(gt) > 1;
        else
            gtBinary = gt > 0;
        end
        
        % Calcular IoU
        intersection = sum(predBinary(:) & gtBinary(:));
        union = sum(predBinary(:) | gtBinary(:));
        
        if union == 0
            iou = 1; % Ambos são vazios
        else
            iou = intersection / union;
        end
    catch
        iou = 0; % Erro no cálculo
    end
end

function acc = calcular_accuracy_simples(pred, gt)
    % Calcular acurácia simples
    
    try
        % Converter para mesmo formato
        if iscategorical(pred)
            predVals = double(pred);
        else
            predVals = pred;
        end
        
        if iscategorical(gt)
            gtVals = double(gt);
        else
            gtVals = gt;
        end
        
        % Calcular acurácia
        correct = sum(predVals(:) == gtVals(:));
        total = numel(gtVals);
        acc = correct / total;
    catch
        acc = 0; % Erro no cálculo
    end
end
