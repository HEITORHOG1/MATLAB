function teste_dados_segmentacao(config)
    % Script para testar e verificar o formato dos dados
    % VERSÃO CORRIGIDA - Sem erros de compatibilidade
    
    if nargin < 1
        error('Configuração é necessária. Execute primeiro: executar_comparacao()');
    end
    
    fprintf('\n=== TESTE DE FORMATO DOS DADOS (CORRIGIDO) ===\n');
    
    % Verificar se os diretórios existem
    if ~exist(config.imageDir, 'dir')
        error('Diretório de imagens não encontrado: %s', config.imageDir);
    end
    
    if ~exist(config.maskDir, 'dir')
        error('Diretório de máscaras não encontrado: %s', config.maskDir);
    end
    
    fprintf('Testando dados em:\n');
    fprintf('  Imagens: %s\n', config.imageDir);
    fprintf('  Máscaras: %s\n', config.maskDir);
    
    % Carregar dados usando função robusta
    try
        if exist('carregar_dados_robustos', 'file')
            [images, masks] = carregar_dados_robustos(config);
        else
            % Implementação direta se função não for encontrada
            extensoes = {'*.png', '*.jpg', '*.jpeg', '*.bmp', '*.tiff'};
            images = [];
            masks = [];
            for ext = extensoes
                img_files = dir(fullfile(config.imageDir, ext{1}));
                mask_files = dir(fullfile(config.maskDir, ext{1}));
                images = [images; img_files];
                masks = [masks; mask_files];
            end
            images = arrayfun(@(x) fullfile(config.imageDir, x.name), images, 'UniformOutput', false);
            masks = arrayfun(@(x) fullfile(config.maskDir, x.name), masks, 'UniformOutput', false);
        end
        
        fprintf('Total de imagens: %d\n', length(images));
        fprintf('Total de mascaras: %d\n', length(masks));
        
        % Verificar correspondência
        numPairs = min(length(images), length(masks));
        fprintf('Pares imagem-mascara correspondentes: %d\n', numPairs);
        
        if numPairs == 0
            error('Nenhum par imagem-máscara encontrado!');
        end
        
    catch ME
        fprintf('❌ Erro ao carregar dados: %s\n', ME.message);
        return;
    end
    
    % Testar primeira imagem e máscara
    fprintf('\n--- Testando primeira imagem e mascara ---\n');
    
    try
        % Carregar primeira imagem
        img = imread(images{1});
        [~, imgName] = fileparts(images{1});
        fprintf('Imagem: %s\n', imgName);
        fprintf('  Dimensoes: %dx%d', size(img,1), size(img,2));
        if size(img,3) > 1
            fprintf('x%d', size(img,3));
        end
        fprintf('\n');
        fprintf('  Tipo: %s\n', class(img));
        fprintf('  Valores: min=%d, max=%d\n', min(img(:)), max(img(:)));
        
        % Carregar primeira máscara
        mask = imread(masks{1});
        [~, maskName] = fileparts(masks{1});
        fprintf('\nMascara: %s\n', maskName);
        fprintf('  Dimensoes: %dx%d', size(mask,1), size(mask,2));
        if size(mask,3) > 1
            fprintf('x%d', size(mask,3));
        end
        fprintf('\n');
        fprintf('  Tipo: %s\n', class(mask));
        fprintf('  Valores unicos: ');
        uniqueVals = unique(mask(:));
        fprintf('%d ', uniqueVals);
        fprintf('\n');
        
    catch ME
        fprintf('❌ Erro ao testar primeira imagem/máscara: %s\n', ME.message);
        return;
    end
    
    % Análise de compatibilidade
    fprintf('\n--- Análise de Compatibilidade ---\n');
    
    % Verificar tamanhos
    if size(img,1) == size(mask,1) && size(img,2) == size(mask,2)
        fprintf('✓ Tamanhos compatíveis\n');
    else
        fprintf('⚠ Tamanhos diferentes - redimensionamento será necessário\n');
    end
    
    % Criar visualização de teste
    try
        figure('Name', 'Teste de Dados', 'Position', [100 100 800 400]);
        
        subplot(1,3,1);
        imshow(img);
        title('Imagem Original');
        
        subplot(1,3,2);
        if size(mask,3) > 1
            imshow(mask);
        else
            imshow(mask, []);
        end
        title('Máscara');
        
        % Overlay
        subplot(1,3,3);
        if size(img,3) == 3 && size(mask,3) == 1
            % Criar overlay
            imgGray = rgb2gray(img);
            maskBin = mask > mean(uniqueVals);
            overlay = imfuse(imgGray, maskBin, 'blend');
            imshow(overlay);
        else
            imshow(img);
        end
        title('Overlay');
        
        fprintf('Visualização criada com sucesso!\n');
        
    catch ME
        fprintf('⚠ Erro na visualização: %s\n', ME.message);
    end
    
    % Testar PixelLabelDatastore
    fprintf('\n--- Testando PixelLabelDatastore ---\n');
    
    try
        % Analisar máscaras para determinar classes
        [classNames, labelIDs] = analisar_mascaras_automatico(config.maskDir, masks(1:min(5, length(masks))));
        
        fprintf('Classes: %s\n', strjoin(classNames, ', '));
        fprintf('Label IDs: ');
        fprintf(' %d', labelIDs);
        fprintf('\n');
        
        % Criar PixelLabelDatastore de teste
        testMasks = masks(1:min(3, length(masks)));
        pxds = pixelLabelDatastore(testMasks, classNames, labelIDs);
        
        fprintf('PixelLabelDatastore criado com sucesso!\n');
        
        % Testar leitura
        if hasdata(pxds)
            testMask = read(pxds);
            fprintf('  Categorias na mascara: ');
            cats = categories(testMask);
            for i = 1:length(cats)
                fprintf('Dados em formato cell - categorias: %s ', cats{i});
            end
            fprintf('\n');
        end
        
    catch ME
        fprintf('❌ Erro no PixelLabelDatastore: %s\n', ME.message);
    end
    
    % Verificar consistência das máscaras
    fprintf('\n--- Verificando Consistencia das Mascaras ---\n');
    
    try
        numCheck = min(20, length(masks));
        fprintf('Analisando %d máscaras...\n', numCheck);
        
        allValues = [];
        
        for i = 1:numCheck
            if mod(i, 5) == 0
                fprintf('  Processadas: %d/%d\n', i, numCheck);
            end
            
            mask = imread(masks{i});
            if size(mask, 3) > 1
                mask = rgb2gray(mask);
            end
            
            vals = unique(mask(:));
            allValues = unique([allValues; vals]);
        end
        
        fprintf('\nResultados da análise:\n');
        fprintf('  Valores únicos em todas as máscaras: ');
        fprintf('%d ', allValues);
        fprintf('\n');
        
    catch ME
        fprintf('❌ Erro na verificação de consistência: %s\n', ME.message);
    end
    
    % Recomendações
    fprintf('\n--- Recomendações ---\n');
    
    % Verificar formato das máscaras
    if length(allValues) == 2 && all(ismember(allValues, [0, 255]))
        fprintf('1. ✓ Máscaras já estão no formato adequado\n');
    elseif length(allValues) == 2
        fprintf('1. ⚠ Máscaras são binárias mas com valores %d e %d\n', allValues(1), allValues(2));
        fprintf('   Recomendação: Converter para 0 e 255\n');
    else
        fprintf('1. ⚠ Máscaras não são binárias (%d valores únicos)\n', length(allValues));
        fprintf('   Recomendação: Binarizar máscaras\n');
    end
    
    % Verificar tamanhos
    if size(img,1) ~= config.inputSize(1) || size(img,2) ~= config.inputSize(2)
        fprintf('2. ⚠ Imagens serão redimensionadas de %dx%d para %dx%d\n', ...
                size(img,1), size(img,2), config.inputSize(1), config.inputSize(2));
    else
        fprintf('2. ✓ Tamanhos das imagens já estão corretos\n');
    end
    
    % Verificar canais
    if size(img,3) ~= config.inputSize(3)
        if config.inputSize(3) == 3 && size(img,3) == 1
            fprintf('3. ⚠ Imagens em escala de cinza serão convertidas para RGB\n');
        elseif config.inputSize(3) == 1 && size(img,3) == 3
            fprintf('3. ⚠ Imagens RGB serão convertidas para escala de cinza\n');
        end
    else
        fprintf('3. ✓ Número de canais correto\n');
    end
    
    % Verificar correspondência
    if length(images) == length(masks)
        fprintf('4. ✓ Todas as imagens têm máscaras correspondentes\n');
    else
        fprintf('4. ⚠ Número de imagens (%d) diferente do número de máscaras (%d)\n', ...
                length(images), length(masks));
    end
    
    % Atualizar configuração se necessário
    try
        % Salvar informações descobertas
        config.dataInfo = struct();
        config.dataInfo.numImages = length(images);
        config.dataInfo.numMasks = length(masks);
        config.dataInfo.imageSize = [size(img,1), size(img,2), size(img,3)];
        config.dataInfo.maskValues = allValues;
        config.dataInfo.needsResize = (size(img,1) ~= config.inputSize(1)) || (size(img,2) ~= config.inputSize(2));
        config.dataInfo.needsConversion = ~(length(allValues) == 2 && all(ismember(allValues, [0, 255])));
        
        save('config_caminhos.mat', 'config');
        fprintf('\nConfiguração atualizada e salva!\n');
        
    catch ME
        fprintf('⚠ Erro ao salvar configuração: %s\n', ME.message);
    end
    
    fprintf('\n=== TESTE CONCLUIDO ===\n');
    fprintf('✓ Dados estão prontos para uso\n');
end
