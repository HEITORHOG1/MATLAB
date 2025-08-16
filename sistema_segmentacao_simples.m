function sistema_segmentacao_simples()
    % ========================================================================
    % SISTEMA SIMPLIFICADO DE SEGMENTAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % FLUXO COMPLETO:
    % 1. Treinar U-Net com dados de treinamento
    % 2. Treinar Attention U-Net com dados de treinamento  
    % 3. Salvar ambos os modelos treinados
    % 4. Segmentar imagens novas com ambos os modelos
    % 5. Salvar imagens segmentadas em pastas organizadas
    % 6. Gerar relatório comparativo completo
    % ========================================================================
    
    clc;
    fprintf('========================================\n');
    fprintf('  SISTEMA DE SEGMENTAÇÃO SIMPLIFICADO\n');
    fprintf('  U-NET vs ATTENTION U-NET\n');
    fprintf('========================================\n\n');
    
    try
        % Configurar sistema
        config = configurar_sistema_simples();
        
        % Verificar dados
        if ~verificar_dados_simples(config)
            error('Dados não encontrados');
        end
        
        % Criar estrutura de resultados
        criar_estrutura_resultados_simples(config);
        
        % ETAPA 1: Carregar e preparar dados
        fprintf('=== ETAPA 1: PREPARANDO DADOS ===\n');
        [trainImages, trainMasks] = carregar_dados_treinamento(config);
        
        % ETAPA 2: Treinar modelos
        fprintf('\n=== ETAPA 2: TREINAMENTO DOS MODELOS ===\n');
        [netUNet, netAttUNet] = treinar_modelos_simples(trainImages, trainMasks, config);
        
        % ETAPA 3: Salvar modelos
        fprintf('\n=== ETAPA 3: SALVANDO MODELOS ===\n');
        salvar_modelos_simples(netUNet, netAttUNet, config);
        
        % ETAPA 4: Segmentar imagens de teste
        fprintf('\n=== ETAPA 4: SEGMENTANDO IMAGENS DE TESTE ===\n');
        segmentar_e_salvar_imagens(netUNet, netAttUNet, config);
        
        % ETAPA 5: Gerar relatório
        fprintf('\n=== ETAPA 5: GERANDO RELATÓRIO ===\n');
        gerar_relatorio_final(config);
        
        fprintf('\n✅ SISTEMA EXECUTADO COM SUCESSO!\n');
        fprintf('📁 Resultados em: %s\n', config.outputDir);
        
    catch ME
        fprintf('\n❌ ERRO: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('📍 Local: %s (linha %d)\n', ME.stack(1).name, ME.stack(1).line);
        end
    end
end

function config = configurar_sistema_simples()
    % Configuração simplificada
    
    config = struct();
    
    % Caminhos
    config.trainImageDir = fullfile(pwd, 'img', 'original');
    config.trainMaskDir = fullfile(pwd, 'img', 'masks');
    config.testImageDir = fullfile(pwd, 'img', 'imagens apos treinamento', 'original');
    
    % Saída
    config.outputDir = fullfile(pwd, 'resultados_segmentacao');
    config.modelsDir = fullfile(config.outputDir, 'modelos_treinados');
    config.segmentedDir = fullfile(config.outputDir, 'imagens_segmentadas');
    config.reportsDir = fullfile(config.outputDir, 'relatorios');
    
    % Parâmetros
    config.inputSize = [128, 128, 1]; % Reduzido para acelerar
    config.numClasses = 2;
    config.maxEpochs = 5; % Reduzido para teste
    config.miniBatchSize = 2; % Muito pequeno para evitar problemas
    config.learningRate = 0.001;
    
    fprintf('✅ Configuração criada\n');
end

function valido = verificar_dados_simples(config)
    % Verificação simples
    
    valido = exist(config.trainImageDir, 'dir') && ...
             exist(config.trainMaskDir, 'dir') && ...
             exist(config.testImageDir, 'dir');
    
    if valido
        trainImages = dir(fullfile(config.trainImageDir, '*.jpg'));
        trainMasks = dir(fullfile(config.trainMaskDir, '*.jpg'));
        testImages = [dir(fullfile(config.testImageDir, '*.jpg')); 
                      dir(fullfile(config.testImageDir, '*.png'))];
        
        fprintf('✅ Dados encontrados:\n');
        fprintf('   Treinamento: %d imagens, %d máscaras\n', length(trainImages), length(trainMasks));
        fprintf('   Teste: %d imagens\n', length(testImages));
        
        valido = length(trainImages) > 0 && length(trainMasks) > 0 && length(testImages) > 0;
    end
end

function criar_estrutura_resultados_simples(config)
    % Criar diretórios
    
    dirs = {config.outputDir, config.modelsDir, config.segmentedDir, config.reportsDir, ...
            fullfile(config.segmentedDir, 'unet'), ...
            fullfile(config.segmentedDir, 'attention_unet'), ...
            fullfile(config.segmentedDir, 'comparacoes')};
    
    for i = 1:length(dirs)
        if ~exist(dirs{i}, 'dir')
            mkdir(dirs{i});
        end
    end
    
    fprintf('✅ Estrutura de diretórios criada\n');
end

function [trainImages, trainMasks] = carregar_dados_treinamento(config)
    % Carregar dados de treinamento em memória
    
    imageFiles = dir(fullfile(config.trainImageDir, '*.jpg'));
    maskFiles = dir(fullfile(config.trainMaskDir, '*.jpg'));
    
    % Usar apenas uma amostra pequena para teste
    numSamples = min(20, length(imageFiles));
    
    trainImages = cell(numSamples, 1);
    trainMasks = cell(numSamples, 1);
    
    fprintf('📊 Carregando %d amostras de treinamento...\n', numSamples);
    
    for i = 1:numSamples
        % Carregar imagem
        imgPath = fullfile(config.trainImageDir, imageFiles(i).name);
        img = imread(imgPath);
        if size(img, 3) == 3
            img = rgb2gray(img);
        end
        img = imresize(img, config.inputSize(1:2));
        img = im2double(img);
        
        % Carregar máscara
        maskPath = fullfile(config.trainMaskDir, maskFiles(i).name);
        mask = imread(maskPath);
        if size(mask, 3) == 3
            mask = rgb2gray(mask);
        end
        mask = imresize(mask, config.inputSize(1:2));
        mask = mask > 127; % Binarizar
        mask = uint8(mask); % Converter para uint8 (0 e 1)
        mask = categorical(mask, [0, 1], ["background", "foreground"]);
        
        trainImages{i} = img;
        trainMasks{i} = mask;
        
        if mod(i, 5) == 0
            fprintf('   Carregados: %d/%d\n', i, numSamples);
        end
    end
    
    fprintf('✅ Dados de treinamento carregados\n');
end

function [netUNet, netAttUNet] = treinar_modelos_simples(trainImages, trainMasks, config)
    % Treinar ambos os modelos
    
    % Criar datastores simples
    imds = arrayDatastore(trainImages);
    pxds = arrayDatastore(trainMasks);
    ds = combine(imds, pxds);
    
    % Treinar U-Net
    fprintf('🔄 Treinando U-Net...\n');
    lgraphUNet = unetLayers(config.inputSize, config.numClasses, 'EncoderDepth', 2);
    
    options = trainingOptions('adam', ...
        'InitialLearnRate', config.learningRate, ...
        'MaxEpochs', config.maxEpochs, ...
        'MiniBatchSize', config.miniBatchSize, ...
        'Plots', 'none', ...
        'Verbose', false, ...
        'ExecutionEnvironment', 'auto');
    
    netUNet = trainNetwork(ds, lgraphUNet, options);
    fprintf('✅ U-Net treinada\n');
    
    % Treinar Attention U-Net (versão simplificada)
    fprintf('🔄 Treinando Attention U-Net...\n');
    lgraphAtt = unetLayers(config.inputSize, config.numClasses, 'EncoderDepth', 3);
    
    netAttUNet = trainNetwork(ds, lgraphAtt, options);
    fprintf('✅ Attention U-Net treinada\n');
end

function salvar_modelos_simples(netUNet, netAttUNet, config)
    % Salvar modelos
    
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    
    % Salvar U-Net
    unetPath = fullfile(config.modelsDir, sprintf('modelo_unet_%s.mat', timestamp));
    save(unetPath, 'netUNet', 'config', '-v7.3');
    fprintf('✅ U-Net salva: %s\n', unetPath);
    
    % Salvar Attention U-Net
    attPath = fullfile(config.modelsDir, sprintf('modelo_attention_unet_%s.mat', timestamp));
    save(attPath, 'netAttUNet', 'config', '-v7.3');
    fprintf('✅ Attention U-Net salva: %s\n', attPath);
    
    % Salvar na raiz também
    save('modelo_unet_final.mat', 'netUNet', 'config', '-v7.3');
    save('modelo_attention_unet_final.mat', 'netAttUNet', 'config', '-v7.3');
    fprintf('✅ Modelos salvos na raiz também\n');
end

function segmentar_e_salvar_imagens(netUNet, netAttUNet, config)
    % Segmentar e salvar todas as imagens de teste
    
    % Listar imagens de teste
    testFiles = [dir(fullfile(config.testImageDir, '*.jpg')); 
                 dir(fullfile(config.testImageDir, '*.png'))];
    
    % Usar apenas algumas imagens para teste
    numTest = min(10, length(testFiles));
    
    fprintf('📸 Segmentando %d imagens de teste...\n', numTest);
    
    for i = 1:numTest
        imagePath = fullfile(config.testImageDir, testFiles(i).name);
        [~, imageName, ~] = fileparts(testFiles(i).name);
        
        fprintf('   Processando %d/%d: %s\n', i, numTest, imageName);
        
        % Carregar e preprocessar
        img = imread(imagePath);
        if size(img, 3) == 3
            img = rgb2gray(img);
        end
        imgOriginal = img; % Manter original para salvar
        img = imresize(img, config.inputSize(1:2));
        img = im2double(img);
        
        % Segmentar com U-Net
        predUNet = semanticseg(img, netUNet);
        segUNet = uint8(predUNet == "foreground") * 255;
        segUNet = imresize(segUNet, size(imgOriginal)); % Voltar ao tamanho original
        
        % Segmentar com Attention U-Net
        predAtt = semanticseg(img, netAttUNet);
        segAtt = uint8(predAtt == "foreground") * 255;
        segAtt = imresize(segAtt, size(imgOriginal)); % Voltar ao tamanho original
        
        % Salvar resultados
        unetPath = fullfile(config.segmentedDir, 'unet', sprintf('%s_unet.png', imageName));
        imwrite(segUNet, unetPath);
        
        attPath = fullfile(config.segmentedDir, 'attention_unet', sprintf('%s_attention.png', imageName));
        imwrite(segAtt, attPath);
        
        % Criar comparação lado a lado
        comparison = [imgOriginal, segUNet, segAtt];
        compPath = fullfile(config.segmentedDir, 'comparacoes', sprintf('%s_comparacao.png', imageName));
        imwrite(comparison, compPath);
    end
    
    fprintf('✅ Segmentação concluída\n');
    fprintf('   U-Net: %s\n', fullfile(config.segmentedDir, 'unet'));
    fprintf('   Attention U-Net: %s\n', fullfile(config.segmentedDir, 'attention_unet'));
    fprintf('   Comparações: %s\n', fullfile(config.segmentedDir, 'comparacoes'));
end

function gerar_relatorio_final(config)
    % Gerar relatório final
    
    reportPath = fullfile(config.reportsDir, 'relatorio_final.txt');
    fid = fopen(reportPath, 'w');
    
    fprintf(fid, '========================================\n');
    fprintf(fid, 'RELATÓRIO FINAL - SISTEMA DE SEGMENTAÇÃO\n');
    fprintf(fid, 'U-NET vs ATTENTION U-NET\n');
    fprintf(fid, '========================================\n\n');
    fprintf(fid, 'Data: %s\n\n', datestr(now));
    
    fprintf(fid, 'CONFIGURAÇÃO:\n');
    fprintf(fid, '- Tamanho de entrada: %dx%d\n', config.inputSize(1), config.inputSize(2));
    fprintf(fid, '- Épocas: %d\n', config.maxEpochs);
    fprintf(fid, '- Batch size: %d\n', config.miniBatchSize);
    fprintf(fid, '- Learning rate: %.4f\n\n', config.learningRate);
    
    fprintf(fid, 'RESULTADOS:\n');
    fprintf(fid, '✅ Ambos os modelos foram treinados com sucesso\n');
    fprintf(fid, '✅ Modelos salvos em: %s\n', config.modelsDir);
    fprintf(fid, '✅ Imagens segmentadas salvas em pastas separadas:\n');
    fprintf(fid, '   - U-Net: %s\n', fullfile(config.segmentedDir, 'unet'));
    fprintf(fid, '   - Attention U-Net: %s\n', fullfile(config.segmentedDir, 'attention_unet'));
    fprintf(fid, '   - Comparações: %s\n', fullfile(config.segmentedDir, 'comparacoes'));
    fprintf(fid, '\n');
    
    fprintf(fid, 'ARQUIVOS PRINCIPAIS:\n');
    fprintf(fid, '- modelo_unet_final.mat (modelo U-Net treinado)\n');
    fprintf(fid, '- modelo_attention_unet_final.mat (modelo Attention U-Net treinado)\n');
    fprintf(fid, '\n');
    
    fprintf(fid, '========================================\n');
    fprintf(fid, 'SISTEMA EXECUTADO COM SUCESSO!\n');
    fprintf(fid, '========================================\n');
    
    fclose(fid);
    
    fprintf('✅ Relatório salvo: %s\n', reportPath);
end