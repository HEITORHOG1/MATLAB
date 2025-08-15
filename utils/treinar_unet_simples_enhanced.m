function result = treinar_unet_simples_enhanced(config)
    % ========================================================================
    % TREINAMENTO U-NET SIMPLES APRIMORADO - COM GERENCIAMENTO DE MODELOS
    % ========================================================================
    % 
    % AUTOR: Sistema de Melhorias de Segmentação
    % Data: Agosto 2025
    % Versão: 1.0 - Integração com sistema de gerenciamento
    %
    % DESCRIÇÃO:
    %   Versão aprimorada do treinamento U-Net com salvamento automático,
    %   carregamento de modelos pré-treinados e versionamento
    % ========================================================================
    
    % Adicionar sistema de gerenciamento de modelos
    addpath('src/model_management');
    
    % Inicializar componentes de gerenciamento
    modelSaver = ModelSaver(config);
    trainingIntegration = TrainingIntegration(config);
    
    if nargin < 1
        error('Configuração é necessária. Execute primeiro: executar_comparacao()');
    end
    
    fprintf('\n=== TREINAMENTO U-NET SIMPLES APRIMORADO ===\n');
    
    % Verificar se deve carregar modelo pré-treinado
    pretrainedModel = [];
    if isfield(config, 'loadPretrainedModel') && config.loadPretrainedModel
        fprintf('🔄 Verificando modelos pré-treinados...\n');
        
        try
            [pretrainedModel, pretrainedMetadata] = ModelLoader.loadBestModel('saved_models', 'iou_mean');
            if ~isempty(pretrainedModel)
                fprintf('✓ Modelo pré-treinado carregado!\n');
                fprintf('  Tipo: %s\n', pretrainedMetadata.modelType);
                if isfield(pretrainedMetadata, 'performance')
                    perf = pretrainedMetadata.performance;
                    if isfield(perf, 'iou_mean')
                        fprintf('  IoU: %.4f\n', perf.iou_mean);
                    end
                end
                
                % Perguntar se deseja usar como ponto de partida
                response = input('Usar este modelo como ponto de partida? (y/n): ', 's');
                if ~strcmpi(response, 'y')
                    pretrainedModel = [];
                end
            end
        catch ME
            fprintf('⚠ Erro ao carregar modelo pré-treinado: %s\n', ME.message);
            pretrainedModel = [];
        end
    end
    
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
    fprintf('Configuração do treinamento:\n');
    fprintf('  Imagens: %s\n', config.imageDir);
    fprintf('  Máscaras: %s\n', config.maskDir);
    fprintf('  Épocas: %d (teste rápido)\n', config.quickTest.maxEpochs);
    fprintf('  Batch size: %d\n', config.miniBatchSize);
    fprintf('  Modelo pré-treinado: %s\n', iif(~isempty(pretrainedModel), 'Sim', 'Não'));
    
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
    
    fprintf('Dados preparados:\n');
    fprintf('  Treinamento: %d amostras\n', numTrain);
    fprintf('  Validação: %d amostras\n', numVal);
    
    fprintf('Datastores criados com sucesso!\n');
    
    % Criar ou usar arquitetura
    fprintf('\nCriando arquitetura U-Net...\n');
    inputSize = config.inputSize;
    numClasses = config.numClasses;
    
    if ~isempty(pretrainedModel)
        % Usar modelo pré-treinado como base
        fprintf('Usando modelo pré-treinado como base...\n');
        lgraph = layerGraph(pretrainedModel);
    else
        % Criar nova arquitetura
        lgraph = unetLayers(inputSize, numClasses, 'EncoderDepth', 4);
    end
    
    fprintf('U-Net preparada com sucesso!\n');
    
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
    fprintf('Treinando U-Net aprimorada...\n');
    
    try
        net = trainNetwork(dsTrain, lgraph, options);
        fprintf('✓ Treinamento concluído!\n');
        fprintf('Fim: %s\n', string(datetime("now")));
        
        % Avaliar modelo
        fprintf('\n=== AVALIACAO RAPIDA ===\n');
        metricas = avaliar_modelo_simples_enhanced(net, dsVal, numVal);
        
        % Salvamento automático com sistema aprimorado
        fprintf('\n=== SALVAMENTO AUTOMATICO ===\n');
        try
            modelType = 'unet';
            savedPath = modelSaver.saveModel(net, modelType, metricas, config);
            
            fprintf('✓ Modelo salvo automaticamente: %s\n', savedPath);
            
            % Criar versão se sistema de versionamento estiver disponível
            try
                versioningSystem = ModelVersioning(config);
                versionPath = versioningSystem.createNewVersion(savedPath, modelType);
                fprintf('✓ Versão criada: %s\n', versionPath);
            catch
                fprintf('⚠ Sistema de versionamento não disponível\n');
            end
            
        catch ME
            fprintf('❌ Erro no salvamento automático: %s\n', ME.message);
            % Fallback para salvamento tradicional
            modelPath = 'unet_simples_enhanced.mat';
            save(modelPath, 'net', 'config', 'classNames', 'labelIDs', 'metricas');
            fprintf('Modelo salvo (modo tradicional): %s\n', modelPath);
        end
        
        % Preparar resultado
        result = struct();
        result.model = net;
        result.modelType = 'unet';
        result.metrics = metricas;
        result.config = config;
        result.classNames = classNames;
        result.labelIDs = labelIDs;
        result.trainingTime = datetime('now');
        
        if exist('savedPath', 'var')
            result.savedPath = savedPath;
        end
        
        fprintf('\n✓ TREINAMENTO APRIMORADO CONCLUIDO!\n');
        
    catch ME
        fprintf('❌ Erro durante o treinamento: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        result = struct();
        result.error = ME.message;
        
        rethrow(ME);
    end
end

function metricas = avaliar_modelo_simples_enhanced(net, dsVal, numValSamples)
    % Avaliação aprimorada do modelo com mais métricas
    
    try
        fprintf('Calculando métricas aprimoradas...\n');
        
        % Coletar predições
        reset(dsVal);
        numSamples = min(20, numValSamples);  % Aumentar número de amostras para avaliação
        
        ious = [];
        dices = [];
        accuracies = [];
        processingTimes = [];
        
        for i = 1:numSamples
            if hasdata(dsVal)
                data = read(dsVal);
                img = data{1};
                gt = data{2};
                
                % Medir tempo de inferência
                tic;
                pred = semanticseg(img, net);
                processingTime = toc;
                
                % Calcular métricas
                iou = calcular_iou_simples(pred, gt);
                dice = calcular_dice_simples(pred, gt);
                acc = calcular_accuracy_simples(pred, gt);
                
                ious = [ious, iou];
                dices = [dices, dice];
                accuracies = [accuracies, acc];
                processingTimes = [processingTimes, processingTime];
                
                fprintf('  Amostra %d: IoU=%.3f, Dice=%.3f, Acc=%.3f, Tempo=%.3fs\n', ...
                       i, iou, dice, acc, processingTime);
            end
        end
        
        % Estatísticas finais aprimoradas
        if ~isempty(ious)
            fprintf('\n--- Métricas Finais Aprimoradas ---\n');
            
            metricas = struct();
            
            % Métricas básicas
            metricas.iou_mean = mean(ious);
            metricas.iou_std = std(ious);
            metricas.iou_min = min(ious);
            metricas.iou_max = max(ious);
            
            metricas.dice_mean = mean(dices);
            metricas.dice_std = std(dices);
            metricas.dice_min = min(dices);
            metricas.dice_max = max(dices);
            
            metricas.acc_mean = mean(accuracies);
            metricas.acc_std = std(accuracies);
            metricas.acc_min = min(accuracies);
            metricas.acc_max = max(accuracies);
            
            % Métricas de performance
            metricas.processing_time_mean = mean(processingTimes);
            metricas.processing_time_std = std(processingTimes);
            metricas.fps = 1 / mean(processingTimes);
            
            % Informações adicionais
            metricas.num_samples = length(ious);
            metricas.evaluation_timestamp = datetime('now');
            
            % Exibir resultados
            fprintf('IoU: %.4f ± %.4f (min: %.4f, max: %.4f)\n', ...
                   metricas.iou_mean, metricas.iou_std, metricas.iou_min, metricas.iou_max);
            fprintf('Dice: %.4f ± %.4f (min: %.4f, max: %.4f)\n', ...
                   metricas.dice_mean, metricas.dice_std, metricas.dice_min, metricas.dice_max);
            fprintf('Acurácia: %.4f ± %.4f (min: %.4f, max: %.4f)\n', ...
                   metricas.acc_mean, metricas.acc_std, metricas.acc_min, metricas.acc_max);
            fprintf('Tempo de processamento: %.4f ± %.4f s (FPS: %.1f)\n', ...
                   metricas.processing_time_mean, metricas.processing_time_std, metricas.fps);
            
            % Salvar métricas detalhadas
            save('metricas_enhanced_simples.mat', 'metricas', 'ious', 'dices', 'accuracies', 'processingTimes');
            fprintf('Métricas detalhadas salvas em: metricas_enhanced_simples.mat\n');
        else
            fprintf('⚠ Nenhuma métrica calculada.\n');
            metricas = struct();
        end
        
    catch ME
        fprintf('❌ Erro na avaliação aprimorada: %s\n', ME.message);
        metricas = struct();
    end
end

function iou = calcular_iou_simples(pred, gt)
    % Calcular IoU simples (mantido para compatibilidade)
    
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

function dice = calcular_dice_simples(pred, gt)
    % Calcular coeficiente Dice
    
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
        
        % Calcular Dice
        intersection = sum(predBinary(:) & gtBinary(:));
        total = sum(predBinary(:)) + sum(gtBinary(:));
        
        if total == 0
            dice = 1; % Ambos são vazios
        else
            dice = 2 * intersection / total;
        end
    catch
        dice = 0; % Erro no cálculo
    end
end

function acc = calcular_accuracy_simples(pred, gt)
    % Calcular acurácia simples (mantido para compatibilidade)
    
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

function result = iif(condition, trueValue, falseValue)
    % Função auxiliar para operador ternário
    if condition
        result = trueValue;
    else
        result = falseValue;
    end
end