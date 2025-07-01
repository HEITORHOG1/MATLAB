% Comparacao Ultra Simples U-Net vs Attention U-Net
% SEM complicacoes categoricas - 26/06/2025

clc
clear all
close all

fprintf('=== COMPARACAO SIMPLES: U-NET vs ATTENTION U-NET ===\n');

% Caminhos
basePath = 'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22';
imageDir = fullfile(basePath, 'original');
correctedMaskDir = fullfile(basePath, 'masks_corrected');

% Verificando pastas
if ~exist(correctedMaskDir, 'dir')
    error('Execute primeiro o script de correcao de mascaras!');
end

fprintf('Carregando dados...\n');

% Listas de arquivos
imageFiles = [dir(fullfile(imageDir, '*.jpg')); 
              dir(fullfile(imageDir, '*.png')); 
              dir(fullfile(imageDir, '*.bmp'))];
              
maskFiles = [dir(fullfile(correctedMaskDir, '*.jpg')); 
             dir(fullfile(correctedMaskDir, '*.png')); 
             dir(fullfile(correctedMaskDir, '*.bmp'))];

fprintf('Imagens: %d\n', length(imageFiles));
fprintf('Mascaras: %d\n', length(maskFiles));

% Limitando para teste rapido
numSamples = min(80, min(length(imageFiles), length(maskFiles)));
fprintf('Usando %d amostras para teste rapido\n', numSamples);

% Configuracoes
imageSize = [256 256 3];
numClasses = 2;
batchSize = 2;
maxEpochs = 8; % Bem reduzido para teste

fprintf('Preparando dados de treinamento...\n');

% Dividindo dados
numTrain = round(0.7 * numSamples); % 70% treino
numTest = numSamples - numTrain;    % 30% teste

% Preparando dados de treinamento
trainImages = zeros([imageSize numTrain], 'single');
trainMasks = zeros([imageSize(1:2) numClasses numTrain], 'single');

fprintf('Carregando dados de treinamento (%d amostras)...\n', numTrain);

for i = 1:numTrain
    if mod(i, 20) == 0
        fprintf('  Carregando %d/%d...\n', i, numTrain);
    end
    
    % Carregando imagem
    imgPath = fullfile(imageDir, imageFiles(i).name);
    img = imread(imgPath);
    img = imresize(img, imageSize(1:2));
    trainImages(:,:,:,i) = im2single(img);
    
    % Carregando mascara
    maskPath = fullfile(correctedMaskDir, maskFiles(i).name);
    mask = imread(maskPath);
    if size(mask, 3) > 1
        mask = rgb2gray(mask);
    end
    mask = imresize(mask, imageSize(1:2));
    
    % Convertendo para one-hot encoding
    mask_corrosao = mask > 127; % corrosao = true
    mask_fundo = ~mask_corrosao; % fundo = complemento
    
    trainMasks(:,:,1,i) = single(mask_fundo);   % canal 1 = fundo
    trainMasks(:,:,2,i) = single(mask_corrosao); % canal 2 = corrosao
end

fprintf('Dados de treinamento preparados!\n');

%% CRIANDO DATASTORES SIMPLES

% Criando datastores de array
dsImages = arrayDatastore(trainImages, 'IterationDimension', 4);
dsMasks = arrayDatastore(trainMasks, 'IterationDimension', 4);
dsTrain = combine(dsImages, dsMasks);

fprintf('Datastores criados com sucesso!\n');

%% MODELO 1: U-NET CLASSICA

fprintf('\n=== TREINANDO U-NET CLASSICA ===\n');
fprintf('Inicio: %s\n', datestr(now));

% Criando U-Net
lgraph_unet = unetLayers(imageSize, numClasses);

% Opcoes de treinamento
options = trainingOptions('adam', ...
    'MiniBatchSize', batchSize, ...
    'MaxEpochs', maxEpochs, ...
    'InitialLearnRate', 1e-3, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', false, ...
    'Plots', 'none');

try
    fprintf('Treinando U-Net classica...\n');
    net_unet = trainNetwork(dsTrain, lgraph_unet, options);
    fprintf('U-Net treinada com sucesso: %s\n', datestr(now));
    save('unet_simples_comparacao.mat', 'net_unet');
    
catch ME
    error('Erro na U-Net: %s', ME.message);
end

%% MODELO 2: ATTENTION U-NET

fprintf('\n=== TREINANDO ATTENTION U-NET ===\n');
fprintf('Inicio: %s\n', datestr(now));

% Criando Attention U-Net muito simples
lgraph_attention = createMiniAttentionUNet(imageSize, numClasses);

try
    fprintf('Treinando Attention U-Net...\n');
    reset(dsTrain);
    net_attention = trainNetwork(dsTrain, lgraph_attention, options);
    fprintf('Attention U-Net treinada com sucesso: %s\n', datestr(now));
    save('attention_simples_comparacao.mat', 'net_attention');
    
catch ME
    error('Erro na Attention U-Net: %s', ME.message);
end

%% TESTANDO E COMPARANDO

fprintf('\n=== TESTANDO MODELOS ===\n');

% Preparando dados de teste
testIndices = (numTrain+1):numSamples;
numTestUsed = min(5, length(testIndices)); % Testando so 5 imagens

unet_scores = zeros(numTestUsed, 3);
attention_scores = zeros(numTestUsed, 3);

for i = 1:numTestUsed
    idx = testIndices(i);
    fprintf('Teste %d/%d...\n', i, numTestUsed);
    
    % Carregando imagem de teste
    testImgPath = fullfile(imageDir, imageFiles(idx).name);
    testImg = imread(testImgPath);
    testImg = imresize(testImg, imageSize(1:2));
    
    % Carregando mascara ground truth
    testMaskPath = fullfile(correctedMaskDir, maskFiles(idx).name);
    testMask = imread(testMaskPath);
    if size(testMask, 3) > 1
        testMask = rgb2gray(testMask);
    end
    testMask = imresize(testMask, imageSize(1:2));
    gt_binary = testMask > 127; % true = corrosao
    
    % Fazendo predicoes
    pred_unet = semanticseg(testImg, net_unet);
    pred_attention = semanticseg(testImg, net_attention);
    
    % Convertendo predicoes para binario
    % Assumindo que classe 2 = corrosao
    pred_unet_bin = pred_unet == categorical(2, [1 2], ["fundo", "corrosao"]);
    pred_attention_bin = pred_attention == categorical(2, [1 2], ["fundo", "corrosao"]);
    
    % Calculando metricas
    [iou_u, dice_u, acc_u] = calcSimpleMetrics(gt_binary, pred_unet_bin);
    [iou_a, dice_a, acc_a] = calcSimpleMetrics(gt_binary, pred_attention_bin);
    
    unet_scores(i, :) = [iou_u, dice_u, acc_u];
    attention_scores(i, :) = [iou_a, dice_a, acc_a];
    
    % Visualizacao da primeira imagem
    if i == 1
        figure(1);
        subplot(2,3,1), imshow(testImg), title('Imagem Original');
        subplot(2,3,2), imshow(testMask), title('Ground Truth');
        subplot(2,3,3), imshow(pred_unet), title('U-Net Classica');
        subplot(2,3,4), imshow(pred_attention), title('Attention U-Net');
        subplot(2,3,5), imshow(labeloverlay(testImg, pred_unet)), title('U-Net Overlay');
        subplot(2,3,6), imshow(labeloverlay(testImg, pred_attention)), title('Attention Overlay');
        
        sgtitle('Comparacao: U-Net vs Attention U-Net');
        saveas(gcf, 'comparacao_simples_visual.png');
        
        fprintf('Visualizacao salva: comparacao_simples_visual.png\n');
    end
end

%% RESULTADOS FINAIS

% Calculando medias
mean_unet = mean(unet_scores, 1);
mean_attention = mean(attention_scores, 1);

fprintf('\n=== RESULTADOS DA COMPARACAO ===\n');
fprintf('U-Net Classica:\n');
fprintf('  IoU: %.3f ± %.3f\n', mean_unet(1), std(unet_scores(:,1)));
fprintf('  Dice: %.3f ± %.3f\n', mean_unet(2), std(unet_scores(:,2)));
fprintf('  Accuracy: %.3f ± %.3f\n', mean_unet(3), std(unet_scores(:,3)));

fprintf('\nAttention U-Net:\n');
fprintf('  IoU: %.3f ± %.3f\n', mean_attention(1), std(attention_scores(:,1)));
fprintf('  Dice: %.3f ± %.3f\n', mean_attention(2), std(attention_scores(:,2)));
fprintf('  Accuracy: %.3f ± %.3f\n', mean_attention(3), std(attention_scores(:,3)));

% Determinando vencedores
fprintf('\n=== VENCEDORES ===\n');
metrics_names = {'IoU', 'Dice', 'Accuracy'};

for i = 1:3
    diff = mean_attention(i) - mean_unet(i);
    if abs(diff) < 0.001
        fprintf('🤝 %s: EMPATE (%.3f vs %.3f)\n', metrics_names{i}, mean_attention(i), mean_unet(i));
    elseif diff > 0
        fprintf('🏆 %s: Attention U-Net VENCE (%.3f vs %.3f, +%.1f%%)\n', ...
                metrics_names{i}, mean_attention(i), mean_unet(i), diff*100);
    else
        fprintf('🏆 %s: U-Net Classica VENCE (%.3f vs %.3f, +%.1f%%)\n', ...
                metrics_names{i}, mean_unet(i), mean_attention(i), abs(diff)*100);
    end
end

% Grafico comparativo
figure(2);
bar_data = [mean_unet; mean_attention]';
b = bar(categorical(metrics_names), bar_data);
b(1).FaceColor = [0.2 0.6 0.8]; % Azul para U-Net
b(2).FaceColor = [0.8 0.4 0.2]; % Laranja para Attention
legend('U-Net Classica', 'Attention U-Net', 'Location', 'best');
ylabel('Score');
title('Comparacao Final: U-Net vs Attention U-Net');
grid on;
ylim([0 1]);

% Adicionando valores no grafico
for i = 1:3
    text(i-0.15, mean_unet(i)+0.02, sprintf('%.3f', mean_unet(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 10);
    text(i+0.15, mean_attention(i)+0.02, sprintf('%.3f', mean_attention(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 10);
end

saveas(gcf, 'grafico_comparacao_simples.png');

% Salvando resultados em CSV
results_table = table((1:numTestUsed)', unet_scores(:,1), unet_scores(:,2), unet_scores(:,3), ...
                     attention_scores(:,1), attention_scores(:,2), attention_scores(:,3), ...
                     'VariableNames', {'Teste', 'UNet_IoU', 'UNet_Dice', 'UNet_Acc', ...
                                      'Attention_IoU', 'Attention_Dice', 'Attention_Acc'});
writetable(results_table, 'resultados_comparacao_simples.csv');

% Resumo em arquivo texto
fid = fopen('resumo_comparacao_simples.txt', 'w');
fprintf(fid, 'COMPARACAO U-NET vs ATTENTION U-NET\n');
fprintf(fid, 'Data: %s\n\n', datestr(now));
fprintf(fid, 'Configuracoes:\n');
fprintf(fid, '- Amostras treinamento: %d\n', numTrain);
fprintf(fid, '- Amostras teste: %d\n', numTestUsed);
fprintf(fid, '- Epochs: %d\n', maxEpochs);
fprintf(fid, '- Batch size: %d\n\n', batchSize);
fprintf(fid, 'U-Net Classica:\n');
fprintf(fid, '  IoU: %.3f ± %.3f\n', mean_unet(1), std(unet_scores(:,1)));
fprintf(fid, '  Dice: %.3f ± %.3f\n', mean_unet(2), std(unet_scores(:,2)));
fprintf(fid, '  Accuracy: %.3f ± %.3f\n\n', mean_unet(3), std(unet_scores(:,3)));
fprintf(fid, 'Attention U-Net:\n');
fprintf(fid, '  IoU: %.3f ± %.3f\n', mean_attention(1), std(attention_scores(:,1)));
fprintf(fid, '  Dice: %.3f ± %.3f\n', mean_attention(2), std(attention_scores(:,2)));
fprintf(fid, '  Accuracy: %.3f ± %.3f\n', mean_attention(3), std(attention_scores(:,3)));
fclose(fid);

fprintf('\n=== COMPARACAO CONCLUIDA COM SUCESSO ===\n');
fprintf('Arquivos gerados:\n');
fprintf('1. Modelos:\n');
fprintf('   - unet_simples_comparacao.mat\n');
fprintf('   - attention_simples_comparacao.mat\n');
fprintf('2. Visualizacoes:\n');
fprintf('   - comparacao_simples_visual.png\n');
fprintf('   - grafico_comparacao_simples.png\n');
fprintf('3. Dados:\n');
fprintf('   - resultados_comparacao_simples.csv\n');
fprintf('   - resumo_comparacao_simples.txt\n');

%% FUNCOES AUXILIARES

function lgraph = createMiniAttentionUNet(imageSize, numClasses)
    % Attention U-Net minima e simples
    fprintf('Criando Mini Attention U-Net...\n');
    
    layers = [
        imageInputLayer(imageSize, 'Name', 'input')
        
        % Encoder muito simples
        convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'enc1')
        reluLayer('Name', 'relu1')
        maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool1')
        
        convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'enc2')
        reluLayer('Name', 'relu2')
        maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool2')
        
        % Bridge simples
        convolution2dLayer(3, 128, 'Padding', 'same', 'Name', 'bridge')
        reluLayer('Name', 'relu_bridge')
        
        % Decoder com "atencao" = gate simples
        transposedConv2dLayer(2, 64, 'Stride', 2, 'Name', 'up1')
        convolution2dLayer(1, 64, 'Name', 'gate1') % Gate de atencao
        sigmoidLayer('Name', 'att1')
        convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'dec1')
        reluLayer('Name', 'relu_dec1')
        
        transposedConv2dLayer(2, 32, 'Stride', 2, 'Name', 'up2')
        convolution2dLayer(1, 32, 'Name', 'gate2') % Gate de atencao
        sigmoidLayer('Name', 'att2')
        convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'dec2')
        reluLayer('Name', 'relu_dec2')
        
        % Saida
        convolution2dLayer(1, numClasses, 'Name', 'final')
        softmaxLayer('Name', 'softmax')
        pixelClassificationLayer('Name', 'output')
    ];
    
    lgraph = layerGraph(layers);
end

function [iou, dice, accuracy] = calcSimpleMetrics(gt, pred)
    % Calcula metricas de segmentacao
    intersection = sum(gt(:) & pred(:));
    union = sum(gt(:) | pred(:));
    
    if union > 0
        iou = intersection / union;
    else
        iou = 0;
    end
    
    if (sum(gt(:)) + sum(pred(:))) > 0
        dice = (2 * intersection) / (sum(gt(:)) + sum(pred(:)));
    else
        dice = 0;
    end
    
    accuracy = sum(gt(:) == pred(:)) / numel(gt);
end