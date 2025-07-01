function corrigir_tudo()
    % Script para corrigir TODOS os problemas de uma vez
    
    fprintf('=== CORRIGINDO TODOS OS PROBLEMAS ===\n\n');
    
    % 1. Corrigir configuração
    fprintf('1. Corrigindo configuração...\n');
    config = struct();
    config.imageDir = 'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22\original';
    config.maskDir = 'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22\masks_converted';
    config.inputSize = [256, 256, 3];
    config.numClasses = 2;
    config.validationSplit = 0.2;
    config.miniBatchSize = 8;
    config.maxEpochs = 20;
    config.quickTest = struct('numSamples', 50, 'maxEpochs', 5);
    
    % Verificar se o diretório de máscaras existe
    if ~exist(config.maskDir, 'dir')
        % Tentar encontrar o diretório correto
        possibleDirs = {
            'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22\masks_converted',
            'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22\masks_converted_converted',
            'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22\masks_converted_converted_converted',
            'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22\masks_converted_converted_converted_converted'
        };
        
        for i = 1:length(possibleDirs)
            if exist(possibleDirs{i}, 'dir')
                config.maskDir = possibleDirs{i};
                fprintf('  Diretório de máscaras encontrado: %s\n', config.maskDir);
                break;
            end
        end
    end
    
    save('config_caminhos.mat', 'config');
    fprintf('  ✓ Configuração salva!\n\n');
    
    % 2. Adicionar path das funções auxiliares
    fprintf('2. Configurando paths...\n');
    addpath(pwd);
    fprintf('  ✓ Path configurado!\n\n');
    
    % 3. Verificar se as funções existem
    fprintf('3. Verificando funções...\n');
    if exist('funcoes_auxiliares.m', 'file')
        fprintf('  ✓ funcoes_auxiliares.m encontrado\n');
    else
        fprintf('  ❌ funcoes_auxiliares.m NÃO encontrado\n');
    end
    
    % 4. Testar carregamento de dados
    fprintf('\n4. Testando carregamento de dados...\n');
    try
        % Implementação direta para teste
        extensoes = {'*.png', '*.jpg', '*.jpeg', '*.bmp', '*.tiff'};
        images = [];
        masks = [];
        
        for ext = extensoes
            img_files = dir(fullfile(config.imageDir, ext{1}));
            mask_files = dir(fullfile(config.maskDir, ext{1}));
            images = [images; img_files];
            masks = [masks; mask_files];
        end
        
        fprintf('  ✓ Imagens encontradas: %d\n', length(images));
        fprintf('  ✓ Máscaras encontradas: %d\n', length(masks));
        
        if length(images) > 0 && length(masks) > 0
            fprintf('  ✓ Dados carregados com sucesso!\n');
        else
            fprintf('  ❌ Nenhum dado encontrado!\n');
        end
        
    catch ME
        fprintf('  ❌ Erro ao carregar dados: %s\n', ME.message);
    end
    
    % 5. Criar script de execução simplificado
    fprintf('\n5. Criando script de execução simplificado...\n');
    
    % Criar executar_simples.m
    fid = fopen('executar_simples.m', 'w');
    fprintf(fid, 'function executar_simples()\n');
    fprintf(fid, '    %% Script simplificado para executar a comparação\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    fprintf(''=== EXECUÇÃO SIMPLIFICADA ===\\n\\n'');\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Carregar configuração\n');
    fprintf(fid, '    load(''config_caminhos.mat'', ''config'');\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Executar comparação\n');
    fprintf(fid, '    try\n');
    fprintf(fid, '        comparacao_unet_attention_final(config);\n');
    fprintf(fid, '    catch ME\n');
    fprintf(fid, '        fprintf(''Erro: %%s\\n'', ME.message);\n');
    fprintf(fid, '        fprintf(''Tentando versão simplificada...\\n'');\n');
    fprintf(fid, '        comparacao_simples_direta(config);\n');
    fprintf(fid, '    end\n');
    fprintf(fid, 'end\n');
    fclose(fid);
    
    fprintf('  ✓ executar_simples.m criado!\n');
    
    % 6. Criar versão simplificada da comparação
    criar_comparacao_simples();
    
    fprintf('\n=== CORREÇÕES CONCLUÍDAS ===\n');
    fprintf('\nPara executar:\n');
    fprintf('1. Digite: executar_simples\n');
    fprintf('2. Ou digite: comparacao_simples_direta(config)\n');
    
end

function criar_comparacao_simples()
    % Criar versão simplificada que funciona
    
    fid = fopen('comparacao_simples_direta.m', 'w');
    fprintf(fid, 'function comparacao_simples_direta(config)\n');
    fprintf(fid, '    %% Comparação simplificada e direta\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    fprintf(''=== COMPARAÇÃO SIMPLIFICADA ===\\n\\n'');\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Carregar dados diretamente\n');
    fprintf(fid, '    fprintf(''Carregando dados...\\n'');\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    imageFiles = dir(fullfile(config.imageDir, ''*.png''));\n');
    fprintf(fid, '    maskFiles = dir(fullfile(config.maskDir, ''*.png''));\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    if isempty(imageFiles) || isempty(maskFiles)\n');
    fprintf(fid, '        error(''Nenhum arquivo encontrado!'');\n');
    fprintf(fid, '    end\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Usar apenas algumas amostras\n');
    fprintf(fid, '    numSamples = min(20, length(imageFiles), length(maskFiles));\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    images = cell(numSamples, 1);\n');
    fprintf(fid, '    masks = cell(numSamples, 1);\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    for i = 1:numSamples\n');
    fprintf(fid, '        images{i} = fullfile(config.imageDir, imageFiles(i).name);\n');
    fprintf(fid, '        masks{i} = fullfile(config.maskDir, maskFiles(i).name);\n');
    fprintf(fid, '    end\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    fprintf(''Usando %%d amostras\\n'', numSamples);\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Dividir dados\n');
    fprintf(fid, '    numTrain = round(0.7 * numSamples);\n');
    fprintf(fid, '    trainImages = images(1:numTrain);\n');
    fprintf(fid, '    trainMasks = masks(1:numTrain);\n');
    fprintf(fid, '    valImages = images(numTrain+1:end);\n');
    fprintf(fid, '    valMasks = masks(numTrain+1:end);\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Criar datastores\n');
    fprintf(fid, '    fprintf(''Criando datastores...\\n'');\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    classNames = ["background", "foreground"];\n');
    fprintf(fid, '    labelIDs = [0, 1];\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    imdsTrain = imageDatastore(trainImages);\n');
    fprintf(fid, '    imdsVal = imageDatastore(valImages);\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    pxdsTrain = pixelLabelDatastore(trainMasks, classNames, labelIDs);\n');
    fprintf(fid, '    pxdsVal = pixelLabelDatastore(valMasks, classNames, labelIDs);\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Combinar e transformar\n');
    fprintf(fid, '    dsTrain = combine(imdsTrain, pxdsTrain);\n');
    fprintf(fid, '    dsVal = combine(imdsVal, pxdsVal);\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    dsTrain = transform(dsTrain, @(data) preprocessSimples(data, config));\n');
    fprintf(fid, '    dsVal = transform(dsVal, @(data) preprocessSimples(data, config));\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Treinar U-Net\n');
    fprintf(fid, '    fprintf(''\\n=== TREINANDO U-NET ===\\n'');\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    lgraph = unetLayers(config.inputSize, config.numClasses, ''EncoderDepth'', 3);\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    options = trainingOptions(''adam'', ...\n');
    fprintf(fid, '        ''InitialLearnRate'', 1e-3, ...\n');
    fprintf(fid, '        ''MaxEpochs'', 5, ...\n');
    fprintf(fid, '        ''MiniBatchSize'', 4, ...\n');
    fprintf(fid, '        ''ValidationData'', dsVal, ...\n');
    fprintf(fid, '        ''ValidationFrequency'', 2, ...\n');
    fprintf(fid, '        ''Plots'', ''training-progress'', ...\n');
    fprintf(fid, '        ''Verbose'', true, ...\n');
    fprintf(fid, '        ''ExecutionEnvironment'', ''auto'');\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    try\n');
    fprintf(fid, '        net = trainNetwork(dsTrain, lgraph, options);\n');
    fprintf(fid, '        fprintf(''✓ Treinamento concluído!\\n'');\n');
    fprintf(fid, '        save(''modelo_unet_simples.mat'', ''net'');\n');
    fprintf(fid, '    catch ME\n');
    fprintf(fid, '        fprintf(''Erro no treinamento: %%s\\n'', ME.message);\n');
    fprintf(fid, '    end\n');
    fprintf(fid, 'end\n');
    fprintf(fid, '\n');
    fprintf(fid, 'function dataOut = preprocessSimples(data, config)\n');
    fprintf(fid, '    %% Pré-processamento simplificado\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    img = data{1};\n');
    fprintf(fid, '    mask = data{2};\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Redimensionar\n');
    fprintf(fid, '    img = imresize(img, config.inputSize(1:2));\n');
    fprintf(fid, '    mask = imresize(mask, config.inputSize(1:2), ''nearest'');\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Garantir 3 canais na imagem\n');
    fprintf(fid, '    if size(img, 3) == 1\n');
    fprintf(fid, '        img = repmat(img, [1, 1, 3]);\n');
    fprintf(fid, '    end\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Processar máscara\n');
    fprintf(fid, '    if size(mask, 3) > 1\n');
    fprintf(fid, '        mask = rgb2gray(mask);\n');
    fprintf(fid, '    end\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Converter máscara para categorical\n');
    fprintf(fid, '    mask = mask > 127;\n');
    fprintf(fid, '    mask = categorical(double(mask), [0, 1], ["background", "foreground"]);\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    %% Normalizar imagem\n');
    fprintf(fid, '    img = im2double(img);\n');
    fprintf(fid, '    \n');
    fprintf(fid, '    dataOut = {img, mask};\n');
    fprintf(fid, 'end\n');
    fclose(fid);
    
    fprintf('  ✓ comparacao_simples_direta.m criado!\n');
end
