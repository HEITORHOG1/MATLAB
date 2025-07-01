% Script Final - Treinamento Direto com Mascaras Corrigidas
% 26/06/2025

clc
clear all
close all

fprintf('=== TREINAMENTO DIRETO COM MASCARAS CORRIGIDAS ===\n');

% Caminhos
basePath = 'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22';
imageDir = fullfile(basePath, 'original');
correctedMaskDir = fullfile(basePath, 'masks_corrected'); % Pasta que foi criada pelo script anterior

% Verificando se as pastas existem
if ~exist(imageDir, 'dir')
    error('Pasta de imagens nao encontrada: %s', imageDir);
end

if ~exist(correctedMaskDir, 'dir')
    error('Pasta de mascaras corrigidas nao encontrada: %s\nExecute primeiro o script de correcao!', correctedMaskDir);
end

% Carregando dados
fprintf('Carregando dados corrigidos...\n');
imds = imageDatastore(imageDir);
classNames = ["corrosao", "fundo"];
labelIDs = [255 0];
pxds = pixelLabelDatastore(correctedMaskDir, classNames, labelIDs);

fprintf('Imagens: %d\n', length(imds.Files));
fprintf('Mascaras corrigidas: %d\n', length(pxds.Files));

% Escolha do modelo
fprintf('\nEscolha o modelo:\n');
fprintf('1. U-Net 256x256 (Recomendada - 15-20 min)\n');
fprintf('2. U-Net 128x128 (Mais rapida - 10-15 min)\n');
fprintf('3. SegNet 256x256 (Alternativa - 15-20 min)\n');

modelChoice = input('Opcao (1-3): ');

if isempty(modelChoice) || modelChoice < 1 || modelChoice > 3
    modelChoice = 1;
    fprintf('Usando U-Net 256x256 como padrao\n');
end

% Configuracao baseada na escolha
switch modelChoice
    case 1
        fprintf('\n=== U-NET 256x256 ===\n');
        imageSize = [256 256 3];
        modelName = 'unet_256_final';
        batchSize = 4;
        maxEpochs = 20;
        learningRate = 1e-3;
        
    case 2
        fprintf('\n=== U-NET 128x128 ===\n');
        imageSize = [128 128 3];
        modelName = 'unet_128_final';
        batchSize = 8;
        maxEpochs = 25;
        learningRate = 1e-3;
        
    case 3
        fprintf('\n=== SEGNET 256x256 ===\n');
        imageSize = [256 256 3];
        modelName = 'segnet_256_final';
        batchSize = 4;
        maxEpochs = 20;
        learningRate = 1e-3;
end

numClasses = length(classNames);

% Criando arquitetura
fprintf('Criando arquitetura...\n');
if modelChoice == 3
    % SegNet
    lgraph = segnetLayers(imageSize, numClasses);
else
    % U-Net
    lgraph = unetLayers(imageSize, numClasses);
end

fprintf('Arquitetura criada: %s\n', modelName);

% Criando datastore combinado
fprintf('Criando datastore...\n');
ds = pixelLabelImageDatastore(imds, pxds);

% Configuracoes de treinamento
fprintf('Configurando treinamento...\n');
options = trainingOptions('adam', ...
    'MiniBatchSize', batchSize, ...
    'MaxEpochs', maxEpochs, ...
    'InitialLearnRate', learningRate, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ValidationFrequency', 15, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', floor(maxEpochs/2), ...
    'LearnRateDropFactor', 0.5, ...
    'L2Regularization', 1e-4);

% Estimativa de tempo
numSamples = length(imds.Files);
estimatedMinutes = (numSamples / batchSize) * maxEpochs * 1.5 / 60;

fprintf('\nConfiguracoes de treinamento:\n');
fprintf('  Modelo: %s\n', strrep(modelName, '_', ' '));
fprintf('  Tamanho entrada: %dx%d\n', imageSize(1), imageSize(2));
fprintf('  Batch size: %d\n', batchSize);
fprintf('  Epochs: %d\n', maxEpochs);
fprintf('  Learning rate: %g\n', learningRate);
fprintf('  Amostras: %d\n', numSamples);
fprintf('  Tempo estimado: %.1f minutos\n', estimatedMinutes);

fprintf('\n=== PRONTO PARA TREINAR ===\n');
fprintf('Pressione Enter para iniciar o treinamento...\n');
pause;

% Treinamento
fprintf('\n=== INICIANDO TREINAMENTO ===\n');
fprintf('Modelo: %s\n', modelName);
fprintf('Inicio: %s\n', datestr(now));

try
    % Treinando a rede
    net = trainNetwork(ds, lgraph, options);
    
    fprintf('\n=== TREINAMENTO CONCLUIDO ===\n');
    fprintf('Fim: %s\n', datestr(now));
    
    % Salvando modelo
    modelFile = sprintf('%s.mat', modelName);
    save(modelFile, 'net', 'options', 'classNames', 'labelIDs', 'imageSize');
    fprintf('Modelo salvo: %s\n', modelFile);
    
    % Teste do modelo treinado
    fprintf('\n=== TESTANDO MODELO ===\n');
    
    % Carregando imagens de teste
    testImg = readimage(imds, 1);
    testMask = readimage(pxds, 1);
    
    fprintf('Fazendo predicao...\n');
    resultado = semanticseg(testImg, net);
    
    % Visualizacao dos resultados
    figure(1);
    subplot(2,2,1), imshow(testImg), title('Imagem Original');
    subplot(2,2,2), imshow(testMask), title('Ground Truth');
    subplot(2,2,3), imshow(resultado), title('Resultado da IA');
    subplot(2,2,4), imshow(labeloverlay(testImg, resultado)), title('Sobreposicao');
    
    sgtitle(sprintf('Resultado Final - %s', strrep(modelName, '_', ' ')));
    
    % Salvando figura
    resultFigFile = sprintf('%s_resultado.png', modelName);
    saveas(gcf, resultFigFile);
    fprintf('Resultado visual salvo: %s\n', resultFigFile);
    
    % Calculando metricas basicas
    fprintf('\n=== CALCULANDO METRICAS ===\n');
    try
        % Convertendo para binario para calcular metricas
        if isa(testMask, 'categorical')
            gtBin = testMask == classNames(1); % corrosao
        else
            gtBin = imbinarize(testMask);
        end
        
        if isa(resultado, 'categorical')
            predBin = resultado == classNames(1); % corrosao
        else
            predBin = imbinarize(resultado);
        end
        
        % Metricas
        intersection = sum(gtBin(:) & predBin(:));
        union = sum(gtBin(:) | predBin(:));
        
        if union > 0
            iou = intersection / union;
        else
            iou = 0;
        end
        
        dice = (2 * intersection) / (sum(gtBin(:)) + sum(predBin(:)));
        accuracy = sum(gtBin(:) == predBin(:)) / numel(gtBin);
        
        fprintf('Metricas calculadas:\n');
        fprintf('  IoU (Intersection over Union): %.3f\n', iou);
        fprintf('  Dice Score: %.3f\n', dice);
        fprintf('  Accuracy: %.3f\n', accuracy);
        
        % Salvando metricas
        metricsFile = sprintf('%s_metricas.txt', modelName);
        fid = fopen(metricsFile, 'w');
        fprintf(fid, 'Metricas do Modelo: %s\n', modelName);
        fprintf(fid, 'Data: %s\n', datestr(now));
        fprintf(fid, 'IoU: %.3f\n', iou);
        fprintf(fid, 'Dice: %.3f\n', dice);
        fprintf(fid, 'Accuracy: %.3f\n', accuracy);
        fclose(fid);
        fprintf('Metricas salvas: %s\n', metricsFile);
        
    catch
        fprintf('Nao foi possivel calcular metricas automaticamente\n');
    end
    
    % Testando com mais imagens
    fprintf('\n=== TESTE ADICIONAL ===\n');
    if length(imds.Files) >= 3
        figure(2);
        for i = 1:3
            testImg = readimage(imds, i);
            resultado = semanticseg(testImg, net);
            
            subplot(3,3,(i-1)*3+1), imshow(testImg), title(sprintf('Imagem %d', i));
            subplot(3,3,(i-1)*3+2), imshow(readimage(pxds, i)), title(sprintf('GT %d', i));
            subplot(3,3,(i-1)*3+3), imshow(resultado), title(sprintf('Pred %d', i));
        end
        sgtitle('Teste com Multiplas Imagens');
        
        multiTestFile = sprintf('%s_teste_multiplo.png', modelName);
        saveas(gcf, multiTestFile);
        fprintf('Teste multiplo salvo: %s\n', multiTestFile);
    end
    
    fprintf('\n=== SUCESSO TOTAL ===\n');
    fprintf('Treinamento finalizado com sucesso!\n');
    fprintf('\nArquivos gerados:\n');
    fprintf('1. Modelo treinado: %s\n', modelFile);
    fprintf('2. Resultado visual: %s\n', resultFigFile);
    if exist('metricsFile', 'var')
        fprintf('3. Metricas: %s\n', metricsFile);
    end
    if exist('multiTestFile', 'var')
        fprintf('4. Teste multiplo: %s\n', multiTestFile);
    end
    
    fprintf('\n=== COMO USAR O MODELO ===\n');
    fprintf('Para usar o modelo treinado:\n');
    fprintf('1. load(''%s'')  %% Carrega o modelo\n', modelFile);
    fprintf('2. resultado = semanticseg(sua_imagem, net);  %% Segmenta\n');
    fprintf('3. imshow(labeloverlay(sua_imagem, resultado));  %% Visualiza\n');
    
catch ME
    fprintf('\n=== ERRO NO TREINAMENTO ===\n');
    fprintf('Erro: %s\n', ME.message);
    
    if contains(ME.message, 'memory') || contains(ME.message, 'Memory')
        fprintf('\nSolucao para problema de memoria:\n');
        fprintf('- Escolha opcao 2 (U-Net 128x128)\n');
        fprintf('- Feche outros programas\n');
        fprintf('- Reinicie MATLAB\n');
    elseif contains(ME.message, 'GPU')
        fprintf('\nSolucao para problema de GPU:\n');
        fprintf('- Execute: gpuDevice([]);\n');
        fprintf('- Reinicie MATLAB\n');
    else
        fprintf('\nTente:\n');
        fprintf('- Executar: clear all; close all;\n');
        fprintf('- Escolher modelo menor (opcao 2)\n');
        fprintf('- Reiniciar MATLAB\n');
    end
    
    error('Treinamento falhou');
end

fprintf('\nScript finalizado!\n');