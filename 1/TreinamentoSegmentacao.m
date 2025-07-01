% Script Simplificado Para Treinamento de Segmentacao
% Versao basica sem divisao complexa - 26/06/2025

clc
clear all
close all

% Caminhos principais
basePath = 'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22';
imageDir = fullfile(basePath, 'original');
labelDir = fullfile(basePath, 'masks');

fprintf('Carregando dados...\n');

% Carregando dados
imds = imageDatastore(imageDir);
classNames = ["corrosao", "fundo"];
labelIDs = [255 0];
pxds = pixelLabelDatastore(labelDir, classNames, labelIDs);

fprintf('Imagens: %d\n', length(imds.Files));
fprintf('Mascaras: %d\n', length(pxds.Files));

% Verificando se temos dados suficientes
if length(imds.Files) < 5
    error('Numero insuficiente de imagens (minimo 5)');
end

% Testando carregamento de uma imagem
try
    testImg = readimage(imds, 1);
    testMask = readimage(pxds, 1);
    fprintf('Teste de carregamento: OK\n');
    fprintf('Tamanho imagem: %dx%d\n', size(testImg,1), size(testImg,2));
    fprintf('Tamanho mascara: %dx%d\n', size(testMask,1), size(testMask,2));
catch ME
    error('Erro ao carregar dados: %s', ME.message);
end

% Combinando datastores (usa 80% para treino automaticamente)
ds = pixelLabelImageDatastore(imds, pxds);

% Configuracao da rede
imageSize = [256 256];
numClasses = 2;

% Criando arquitetura U-Net
fprintf('Criando rede U-Net...\n');
lgraph = unetLayers(imageSize, numClasses);

% Mostrando arquitetura
figure(1);
plot(lgraph);
title('Arquitetura U-Net');

% Opcoes de treinamento ajustadas
fprintf('Configurando treinamento...\n');
options = trainingOptions('adam', ...
    'MiniBatchSize', 4, ...
    'MaxEpochs', 15, ...
    'InitialLearnRate', 5e-4, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ValidationFrequency', 10, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.5, ...
    'LearnRateDropPeriod', 8);

% Estimativa de tempo
numSamples = length(imds.Files);
estimatedMinutes = (numSamples / 4) * 15 * 3 / 60; % aproximado
fprintf('Tempo estimado: %.1f minutos\n', estimatedMinutes);

% Pergunta se quer continuar
fprintf('\nPressione Enter para iniciar treinamento...\n');
pause;

% Treinamento
fprintf('Iniciando treinamento...\n');
fprintf('Inicio: %s\n', datestr(now));

try
    net = trainNetwork(ds, lgraph, options);
    fprintf('Treinamento concluido: %s\n', datestr(now));
    
    % Salvando modelo
    fprintf('Salvando modelo...\n');
    save('modelo_corrosao_unet.mat', 'net', 'options', 'classNames', 'labelIDs');
    fprintf('Modelo salvo: modelo_corrosao_unet.mat\n');
    
    % Teste rapido
    fprintf('Testando modelo...\n');
    testImg = readimage(imds, 1);
    testMask = readimage(pxds, 1);
    resultado = semanticseg(testImg, net);
    
    % Visualizacao
    figure(2);
    subplot(2,2,1), imshow(testImg), title('Imagem Original');
    subplot(2,2,2), imshow(testMask), title('Mascara Ground Truth');
    subplot(2,2,3), imshow(resultado), title('Resultado da Rede');
    subplot(2,2,4), imshow(labeloverlay(testImg, resultado)), title('Overlay');
    sgtitle('Resultado do Teste');
    
    % Salvando figura de teste
    saveas(gcf, 'resultado_teste.png');
    
    fprintf('\n=== SUCESSO ===\n');
    fprintf('Modelo treinado e salvo!\n');
    fprintf('Use o arquivo: modelo_corrosao_unet.mat\n');
    
catch ME
    fprintf('\n=== ERRO NO TREINAMENTO ===\n');
    fprintf('Erro: %s\n', ME.message);
    error('Treinamento falhou');
end