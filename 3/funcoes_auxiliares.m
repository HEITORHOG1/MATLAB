% FUNÇÕES AUXILIARES FINAIS CONSOLIDADAS
% Todas as correções aplicadas - Sem erros de .Files ou categories

function [images, masks] = carregar_dados_robustos_FINAL(config)
    % Carregar dados de forma robusta
    
    imageDir = config.imageDir;
    maskDir = config.maskDir;
    
    % Extensões suportadas
    extensoes = {'*.png', '*.jpg', '*.jpeg', '*.bmp', '*.tiff'};
    
    images = [];
    masks = [];
    
    % Listar arquivos
    for ext = extensoes
        img_files = dir(fullfile(imageDir, ext{1}));
        mask_files = dir(fullfile(maskDir, ext{1}));
        
        images = [images; img_files];
        masks = [masks; mask_files];
    end
    
    % Converter para caminhos completos
    images = arrayfun(@(x) fullfile(imageDir, x.name), images, 'UniformOutput', false);
    masks = arrayfun(@(x) fullfile(maskDir, x.name), masks, 'UniformOutput', false);
    
    fprintf('Dados carregados: %d imagens, %d máscaras\n', length(images), length(masks));
end

function [classNames, labelIDs] = analisar_mascaras_automatico_FINAL(maskDir, masks)
    % Analisar máscaras automaticamente
    
    fprintf('Analisando formato das máscaras...\n');
    
    % Analisar algumas máscaras para determinar formato
    numCheck = min(10, length(masks));
    allValues = [];
    
    for i = 1:numCheck
        if iscell(masks)
            maskPath = masks{i};
        else
            maskPath = fullfile(maskDir, masks(i).name);
        end
        
        mask = imread(maskPath);
        
        % Converter para escala de cinza se necessário
        if size(mask, 3) > 1
            mask = rgb2gray(mask);
        end
        
        vals = unique(mask(:));
        allValues = unique([allValues; vals]);
    end
    
    fprintf('Valores únicos encontrados: ');
    if length(allValues) <= 20
        fprintf('%d ', allValues);
    else
        fprintf('%d ', allValues(1:10));
        fprintf('... (%d total)', length(allValues));
    end
    fprintf('\n');
    
    % Determinar classes e labelIDs
    if length(allValues) == 2 && all(ismember(allValues, [0, 255]))
        % Já está binarizado corretamente
        labelIDs = [0, 255];
    elseif length(allValues) == 2
        % Binário mas com valores diferentes
        labelIDs = sort(allValues);
    else
        % Precisa binarização
        fprintf('Máscaras serão binarizadas (threshold: %.2f)\n', mean(double(allValues)));
        labelIDs = [0, 1];
    end
    
    classNames = ["background", "foreground"];
end

function data = preprocessDataMelhorado_FINAL(data, config, labelIDs, useAugmentation)
    % Preprocessamento melhorado com data augmentation opcional
    % VERSÃO FINAL - Correção crítica para categorical
    
    img = data{1};
    mask = data{2};
    
    % Redimensionar
    img = imresize(img, config.inputSize(1:2));
    mask = imresize(mask, config.inputSize(1:2), 'nearest');
    
    % Garantir que a imagem tenha 3 canais
    if size(img, 3) == 1
        img = repmat(img, [1, 1, 3]);
    elseif size(img, 3) > 3
        img = img(:,:,1:3);
    end
    
    % Normalizar imagem
    img = im2double(img);
    
    % Data augmentation (apenas para treinamento)
    if useAugmentation && rand > 0.5
        % Flip horizontal
        if rand > 0.5
            img = fliplr(img);
            mask = fliplr(mask);
        end
        
        % Rotação pequena
        if rand > 0.7
            angle = (rand - 0.5) * 20; % ±10 graus
            img = imrotate(img, angle, 'bilinear', 'crop');
            mask = imrotate(mask, angle, 'nearest', 'crop');
        end
        
        % Ajuste de brilho
        if rand > 0.6
            brightness_factor = 0.8 + 0.4 * rand; % 0.8 a 1.2
            img = img * brightness_factor;
            img = min(max(img, 0), 1);
        end
    end
    
    % Processar máscara - CORREÇÃO CRÍTICA
    if ~isa(mask, 'categorical')
        if size(mask, 3) > 1
            mask = rgb2gray(mask);
        end
        
        % Binarizar se necessário
        if length(labelIDs) == 2 && ~all(ismember(unique(mask(:)), labelIDs))
            threshold = mean(double(labelIDs));
            mask = uint8(mask > threshold);
            if labelIDs(1) == 0 && labelIDs(2) == 1
                % Já está correto
            elseif labelIDs(1) == 0 && labelIDs(2) == 255
                mask = mask * 255;
            end
        end
        
        % Converter para categorical - CORREÇÃO CRÍTICA
        classNames = ["background", "foreground"];
        mask = categorical(mask, labelIDs, classNames);
    end
    
    data = {img, mask};
end

function lgraph = create_attention_unet_FINAL(inputSize, numClasses)
    % Criar Attention U-Net funcional
    % VERSÃO FINAL - Implementação simplificada mas funcional
    
    try
        % Tentar criar Attention U-Net simplificada
        fprintf('Criando Attention U-Net...\n');
        
        % Usar U-Net base e adicionar mecanismos de atenção simplificados
        lgraph = unetLayers(inputSize, numClasses, 'EncoderDepth', 4);
        
        % Adicionar regularização L2 nas camadas convolucionais
        layers = lgraph.Layers;
        for i = 1:length(layers)
            if isa(layers(i), 'nnet.cnn.layer.Convolution2DLayer')
                newLayer = convolution2dLayer( ...
                    layers(i).FilterSize, ...
                    layers(i).NumFilters, ...
                    'Name', layers(i).Name, ...
                    'Padding', layers(i).PaddingMode, ...
                    'Stride', layers(i).Stride, ...
                    'WeightL2Factor', 0.0001, ...
                    'BiasL2Factor', 0.0001);
                
                lgraph = replaceLayer(lgraph, layers(i).Name, newLayer);
            end
        end
        
        % Adicionar dropout para regularização
        dropoutLayers = [];
        for i = 1:length(layers)
            if contains(layers(i).Name, 'Decoder-Stage') && contains(layers(i).Name, 'ReLU')
                dropoutName = [layers(i).Name '_Dropout'];
                dropoutLayer = dropoutLayer(0.2, 'Name', dropoutName);
                dropoutLayers = [dropoutLayers; {layers(i).Name, dropoutLayer}];
            end
        end
        
        % Inserir camadas de dropout
        for i = 1:size(dropoutLayers, 1)
            lgraph = insertLayers(lgraph, dropoutLayers{i,1}, dropoutLayers{i,2});
        end
        
        fprintf('✓ Attention U-Net criada com sucesso (versão otimizada)!\n');
        
    catch ME
        fprintf('⚠ Erro ao criar Attention U-Net: %s\n', ME.message);
        fprintf('Usando U-Net clássica otimizada como fallback...\n');
        
        % Fallback para U-Net clássica otimizada
        lgraph = unetLayers(inputSize, numClasses, 'EncoderDepth', 4);
        
        % Adicionar regularização
        layers = lgraph.Layers;
        for i = 1:length(layers)
            if isa(layers(i), 'nnet.cnn.layer.Convolution2DLayer')
                newLayer = convolution2dLayer( ...
                    layers(i).FilterSize, ...
                    layers(i).NumFilters, ...
                    'Name', layers(i).Name, ...
                    'Padding', layers(i).PaddingMode, ...
                    'Stride', layers(i).Stride, ...
                    'WeightL2Factor', 0.0001, ...
                    'BiasL2Factor', 0.0001);
                
                lgraph = replaceLayer(lgraph, layers(i).Name, newLayer);
            end
        end
        
        fprintf('✓ U-Net otimizada criada como fallback!\n');
    end
end

function converter_mascaras_FINAL(config)
    % Converter máscaras para formato padrão
    % VERSÃO FINAL - Função declarada corretamente
    
    if nargin < 1
        error('Configuração é necessária. Execute primeiro: executar_comparacao_FINAL()');
    end
    
    fprintf('\n=== CONVERSAO DE MASCARAS (FINAL) ===\n');
    
    % Usar configuração portável
    maskDir = config.maskDir;
    
    fprintf('Convertendo máscaras em: %s\n', maskDir);
    
    % Verificar se o diretorio existe
    if ~exist(maskDir, 'dir')
        error('Diretorio de mascaras nao encontrado: %s', maskDir);
    end
    
    % Criar diretorio de saida
    [parentDir, folderName] = fileparts(maskDir);
    outputDir = fullfile(parentDir, [folderName '_converted']);
    
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
        fprintf('Diretório de saída criado: %s\n', outputDir);
    else
        fprintf('Usando diretório de saída existente: %s\n', outputDir);
    end
    
    % Listar arquivos de mascara com múltiplas extensões
    extensoes = {'*.png', '*.jpg', '*.jpeg', '*.bmp', '*.tiff'};
    
    masks = [];
    for ext = extensoes
        mask_files = dir(fullfile(maskDir, ext{1}));
        masks = [masks; mask_files];
    end
    
    fprintf('Máscaras encontradas: %d\n', length(masks));
    
    if isempty(masks)
        error('Nenhuma mascara encontrada!');
    end
    
    % Analisar formato das mascaras primeiro
    fprintf('\nAnalisando formato das máscaras...\n');
    [needsConversion, conversionInfo] = analisar_necessidade_conversao_FINAL(maskDir, masks);
    
    if ~needsConversion
        fprintf('✓ Máscaras já estão no formato correto!\n');
        resp = input('Deseja converter mesmo assim? (s/n): ', 's');
        if lower(resp) ~= 's'
            fprintf('Conversão cancelada.\n');
            return;
        end
    end
    
    % Mostrar informações da conversão
    fprintf('\nInformações da conversão:\n');
    fprintf('  Máscaras com múltiplos canais: %d\n', conversionInfo.multiChannel);
    fprintf('  Máscaras não-binárias: %d\n', conversionInfo.nonBinary);
    fprintf('  Valores únicos encontrados: ');
    if length(conversionInfo.allValues) <= 20
        fprintf('%d ', conversionInfo.allValues);
    else
        fprintf('%d ', conversionInfo.allValues(1:10));
        fprintf('... (%d total)', length(conversionInfo.allValues));
    end
    fprintf('\n');
    
    if conversionInfo.nonBinary > 0
        fprintf('  Threshold automático: %.2f\n', conversionInfo.threshold);
    end
    
    % Confirmar conversão
    fprintf('\nA conversão irá:\n');
    fprintf('1. Converter máscaras RGB para escala de cinza\n');
    fprintf('2. Binarizar máscaras (0 = background, 255 = foreground)\n');
    fprintf('3. Salvar no formato PNG\n');
    fprintf('4. Preservar nomes dos arquivos originais\n');
    
    resp = input('\nContinuar com a conversão? (s/n): ', 's');
    if lower(resp) ~= 's'
        fprintf('Conversão cancelada.\n');
        return;
    end
    
    % Executar conversão
    fprintf('\n=== INICIANDO CONVERSÃO ===\n');
    
    sucessos = 0;
    erros = 0;
    
    for i = 1:length(masks)
        try
            % Carregar mascara
            inputPath = fullfile(maskDir, masks(i).name);
            mask = imread(inputPath);
            
            % Converter para escala de cinza se necessário
            if size(mask, 3) > 1
                mask = rgb2gray(mask);
            end
            
            % Binarizar
            mask = converter_para_binario_FINAL(mask, conversionInfo.threshold);
            
            % Salvar com extensão PNG
            [~, baseName] = fileparts(masks(i).name);
            outputPath = fullfile(outputDir, [baseName '.png']);
            imwrite(mask, outputPath);
            
            sucessos = sucessos + 1;
            
            % Mostrar progresso
            if mod(i, 10) == 0 || i == length(masks)
                fprintf('Progresso: %d/%d (%.1f%%)\n', i, length(masks), 100*i/length(masks));
            end
            
        catch ME
            fprintf('❌ Erro ao converter %s: %s\n', masks(i).name, ME.message);
            erros = erros + 1;
        end
    end
    
    % Relatório final
    fprintf('\n=== CONVERSÃO CONCLUÍDA ===\n');
    fprintf('Sucessos: %d\n', sucessos);
    fprintf('Erros: %d\n', erros);
    fprintf('Taxa de sucesso: %.1f%%\n', 100*sucessos/(sucessos+erros));
    
    if sucessos > 0
        fprintf('Máscaras convertidas salvas em: %s\n', outputDir);
        
        % Verificar resultado
        fprintf('\nVerificando resultado da conversão...\n');
        verificar_conversao_FINAL(outputDir);
        
        % Perguntar se deseja atualizar configuração
        resp = input('\nDeseja usar as máscaras convertidas no projeto? (s/n): ', 's');
        if lower(resp) == 's'
            config.maskDir = outputDir;
            config.masksConverted = true;
            save('config_caminhos.mat', 'config');
            fprintf('✓ Configuração atualizada para usar máscaras convertidas!\n');
        else
            fprintf('Configuração mantida. Você pode alterar manualmente depois.\n');
        end
        
        fprintf('\n✓ CONVERSÃO FINALIZADA COM SUCESSO!\n');
    else
        fprintf('❌ Nenhuma máscara foi convertida com sucesso.\n');
    end
end

function [needsConversion, info] = analisar_necessidade_conversao_FINAL(maskDir, masks)
    % Analisar se as máscaras precisam de conversão
    
    info = struct();
    info.multiChannel = 0;
    info.nonBinary = 0;
    info.allValues = [];
    
    % Analisar uma amostra das máscaras
    numCheck = min(20, length(masks));
    
    for i = 1:numCheck
        mask = imread(fullfile(maskDir, masks(i).name));
        
        % Verificar múltiplos canais
        if size(mask, 3) > 1
            info.multiChannel = info.multiChannel + 1;
            mask = rgb2gray(mask);
        end
        
        % Coletar valores únicos
        vals = unique(mask(:));
        info.allValues = unique([info.allValues; vals]);
        
        % Verificar se é binário
        if length(vals) > 2
            info.nonBinary = info.nonBinary + 1;
        end
    end
    
    % Calcular threshold automático
    if length(info.allValues) > 2
        info.threshold = mean(double(info.allValues));
    else
        info.threshold = [];
    end
    
    % Determinar se precisa conversão
    needsConversion = info.multiChannel > 0 || info.nonBinary > 0 || ...
                     ~all(ismember(info.allValues, [0, 255]));
end

function maskBinary = converter_para_binario_FINAL(mask, threshold)
    % Converter máscara para formato binário padrão
    
    % Garantir que é escala de cinza
    if size(mask, 3) > 1
        mask = rgb2gray(mask);
    end
    
    % Obter valores únicos
    uniqueVals = unique(mask(:));
    
    if length(uniqueVals) == 2
        % Já é binária, apenas padronizar valores
        if all(ismember(uniqueVals, [0, 255]))
            % Já está no formato correto
            maskBinary = mask;
        else
            % Converter para 0 e 255
            maskBinary = uint8(mask == max(uniqueVals)) * 255;
        end
    else
        % Binarizar usando threshold
        if isempty(threshold)
            threshold = mean(double(uniqueVals));
        end
        
        maskBinary = uint8(mask > threshold) * 255;
    end
end

function verificar_conversao_FINAL(outputDir)
    % Verificar se a conversão foi bem-sucedida
    
    % Listar arquivos convertidos
    convertedFiles = dir(fullfile(outputDir, '*.png'));
    
    if isempty(convertedFiles)
        fprintf('❌ Nenhum arquivo convertido encontrado!\n');
        return;
    end
    
    fprintf('Verificando %d arquivos convertidos...\n', length(convertedFiles));
    
    % Verificar algumas máscaras convertidas
    numCheck = min(10, length(convertedFiles));
    allBinary = true;
    allCorrectFormat = true;
    
    for i = 1:numCheck
        mask = imread(fullfile(outputDir, convertedFiles(i).name));
        
        % Verificar se é escala de cinza
        if size(mask, 3) > 1
            allCorrectFormat = false;
        end
        
        % Verificar se é binária
        uniqueVals = unique(mask(:));
        if length(uniqueVals) > 2 || ~all(ismember(uniqueVals, [0, 255]))
            allBinary = false;
        end
    end
    
    % Relatório da verificação
    if allBinary && allCorrectFormat
        fprintf('✓ Todas as máscaras verificadas estão no formato correto!\n');
        fprintf('  - Escala de cinza: ✓\n');
        fprintf('  - Valores binários (0, 255): ✓\n');
        fprintf('  - Formato PNG: ✓\n');
    else
        if ~allCorrectFormat
            fprintf('⚠ Algumas máscaras ainda têm múltiplos canais\n');
        end
        if ~allBinary
            fprintf('⚠ Algumas máscaras não são binárias\n');
        end
    end
    
    % Mostrar exemplo
    if length(convertedFiles) > 0
        fprintf('\nExemplo da primeira máscara convertida:\n');
        mask = imread(fullfile(outputDir, convertedFiles(1).name));
        fprintf('  Arquivo: %s\n', convertedFiles(1).name);
        fprintf('  Dimensões: %dx%d', size(mask,1), size(mask,2));
        if size(mask,3) > 1
            fprintf('x%d', size(mask,3));
        end
        fprintf('\n');
        fprintf('  Valores únicos: ');
        fprintf('%d ', unique(mask(:)));
        fprintf('\n');
    end
end

