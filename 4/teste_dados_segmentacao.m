function teste_dados_segmentacao(config)
    % Script para testar e verificar o formato dos dados
    % VERSÃO DEFINITIVA - TODOS OS ERROS CORRIGIDOS
    
    if nargin < 1
        % Tentar carregar configuração salva
        if exist('config_caminhos.mat', 'file')
            load('config_caminhos.mat', 'config');
            fprintf('Configuração carregada automaticamente.\n');
        else
            fprintf('Nenhuma configuração encontrada. Execute primeiro: executar_comparacao() e escolha opção 1\n');
            
            % Configuração interativa rápida
            fprintf('\n=== CONFIGURAÇÃO RÁPIDA ===\n');
            imageDir = input('Caminho do diretório das imagens: ', 's');
            maskDir = input('Caminho do diretório das máscaras: ', 's');
            
            if ~exist(imageDir, 'dir') || ~exist(maskDir, 'dir')
                error('Diretórios não encontrados!');
            end
            
            config = struct();
            config.imageDir = imageDir;
            config.maskDir = maskDir;
            config.inputSize = [256, 256, 3];
            config.numClasses = 2;
            
            save('config_caminhos.mat', 'config');
            fprintf('Configuração salva!\n');
        end
    end
    
    fprintf('\n=== TESTE DE FORMATO DOS DADOS (CORRIGIDO) ===\n');
    
    % Usar caminhos da configuração
    imageDir = config.imageDir;
    maskDir = config.maskDir;
    
    fprintf('Testando dados em:\n');
    fprintf('  Imagens: %s\n', imageDir);
    fprintf('  Máscaras: %s\n', maskDir);
    
    % Verificar se os diretorios existem
    if ~exist(imageDir, 'dir')
        error('Diretorio de imagens nao encontrado: %s', imageDir);
    end
    if ~exist(maskDir, 'dir')
        error('Diretorio de mascaras nao encontrado: %s', maskDir);
    end
    
    % Listar arquivos com múltiplas extensões
    extensoes = {'*.png', '*.jpg', '*.jpeg', '*.bmp', '*.tiff'};
    
    images = [];
    masks = [];
    
    for ext = extensoes
        img_files = dir(fullfile(imageDir, ext{1}));
        mask_files = dir(fullfile(maskDir, ext{1}));
        
        images = [images; img_files];
        masks = [masks; mask_files];
    end
    
    fprintf('Total de imagens: %d\n', length(images));
    fprintf('Total de mascaras: %d\n', length(masks));
    
    if isempty(images) || isempty(masks)
        error('Nenhuma imagem ou mascara encontrada!');
    end
    
    % Verificar correspondência de nomes
    [~, imgNames] = cellfun(@fileparts, {images.name}, 'UniformOutput', false);
    [~, maskNames] = cellfun(@fileparts, {masks.name}, 'UniformOutput', false);
    
    % Encontrar correspondências (considerando nomes diferentes)
    correspondencias = 0;
    for i = 1:length(imgNames)
        imgBase = extrair_base_nome(imgNames{i});
        for j = 1:length(maskNames)
            maskBase = extrair_base_nome(maskNames{j});
            if strcmp(imgBase, maskBase)
                correspondencias = correspondencias + 1;
                break;
            end
        end
    end
    
    fprintf('Pares imagem-mascara correspondentes: %d\n', correspondencias);
    
    if correspondencias == 0
        warning('Nem todas as imagens têm máscaras correspondentes ou vice-versa');
    end
    
    % Testar primeira imagem e máscara
    fprintf('\n--- Testando primeira imagem e mascara ---\n');
    
    imgPath = fullfile(imageDir, images(1).name);
    maskPath = fullfile(maskDir, masks(1).name);
    
    fprintf('Imagem: %s\n', images(1).name);
    img = imread(imgPath);
    fprintf('  Dimensoes: %dx%d', size(img,1), size(img,2));
    if size(img,3) > 1
        fprintf('x%d', size(img,3));
    end
    fprintf('\n');
    fprintf('  Tipo: %s\n', class(img));
    fprintf('  Valores: min=%d, max=%d\n', min(img(:)), max(img(:)));
    
    fprintf('\nMascara: %s\n', masks(1).name);
    mask = imread(maskPath);
    fprintf('  Dimensoes: %dx%d', size(mask,1), size(mask,2));
    if size(mask,3) > 1
        fprintf('x%d', size(mask,3));
        fprintf('\n  AVISO: Mascara tem %d canais. Convertendo para escala de cinza...\n', size(mask,3));
        mask = rgb2gray(mask);
    else
        fprintf('\n');
    end
    fprintf('  Tipo: %s\n', class(mask));
    
    uniqueVals = unique(mask(:));
    fprintf('  Valores unicos: ');
    if length(uniqueVals) <= 20
        fprintf('%d ', uniqueVals);
    else
        fprintf('%d ', uniqueVals(1:10));
        fprintf('... (%d valores únicos total)', length(uniqueVals));
    end
    fprintf('\n');
    
    % Análise de compatibilidade
    fprintf('\n--- Análise de Compatibilidade ---\n');
    if size(img,1) == size(mask,1) && size(img,2) == size(mask,2)
        fprintf('✓ Tamanhos compatíveis\n');
    else
        fprintf('⚠ Tamanhos diferentes - será necessário redimensionamento\n');
    end
    
    % Criar visualização
    try
        figure('Name', 'Teste de Dados', 'Position', [100 100 1200 400]);
        
        subplot(1,3,1);
        imshow(img);
        title('Imagem Original');
        
        subplot(1,3,2);
        imshow(mask, []);
        title(sprintf('Mascara (valores: %d-%d)', min(mask(:)), max(mask(:))));
        colorbar;
        
        subplot(1,3,3);
        % Redimensionar máscara se necessário para sobreposição
        if size(img,1) ~= size(mask,1) || size(img,2) ~= size(mask,2)
            mask_resized = imresize(mask, [size(img,1), size(img,2)], 'nearest');
        else
            mask_resized = mask;
        end
        
        % Converter imagem para RGB se necessário
        if size(img,3) == 1
            img_rgb = repmat(img, [1,1,3]);
        else
            img_rgb = img;
        end
        
        % Criar overlay
        overlay = img_rgb;
        mask_norm = double(mask_resized) / double(max(mask_resized(:)));
        overlay(:,:,1) = overlay(:,:,1) + uint8(mask_norm * 100);
        
        imshow(overlay);
        title('Sobreposição');
        
        fprintf('Visualização criada com sucesso!\n');
    catch ME
        fprintf('Erro ao criar visualização: %s\n', ME.message);
    end
    
    % Testar PixelLabelDatastore
    fprintf('\n--- Testando PixelLabelDatastore ---\n');
    
    try
        % Analisar valores únicos para definir classes
        if length(uniqueVals) > 2
            fprintf('AVISO: Mascara tem %d valores unicos. Será necessária binarização.\n', length(uniqueVals));
            threshold = mean(double(uniqueVals));
            fprintf('Threshold sugerido para binarização: %.2f\n', threshold);
            labelIDs = [0, 1];
        else
            labelIDs = uniqueVals;
        end
        
        classNames = ["background", "foreground"];
        fprintf('Classes: %s\n', strjoin(string(classNames), ', '));
        fprintf('Label IDs: %s\n', num2str(labelIDs));
        
        % Criar datastore de teste
        testMasks = {maskPath};
        pxds = pixelLabelDatastore(testMasks, classNames, labelIDs);
        
        % Ler uma mascara - CORREÇÃO DEFINITIVA
        C = read(pxds);
        fprintf('PixelLabelDatastore criado com sucesso!\n');
        fprintf('  Categorias na mascara: ');
        
        % Verificação robusta do tipo - CORREÇÃO FINAL DEFINITIVA
        try
            if iscell(C)
                fprintf('Dados em formato cell - ');
                if ~isempty(C) && iscategorical(C{1})
                    cats = categories(C{1});
                    fprintf('categorias: %s ', cats{:});
                else
                    fprintf('valores únicos: ');
                    if ~isempty(C)
                        vals = unique(C{1}(:));
                        fprintf('%d ', vals(1:min(10,end)));
                        if length(vals) > 10
                            fprintf('...');
                        end
                    end
                end
            elseif iscategorical(C)
                cats = categories(C);
                fprintf('%s ', cats{:});
            else
                fprintf('Dados não categóricos - valores únicos: ');
                vals = unique(C(:));
                fprintf('%d ', vals(1:min(10,end)));
                if length(vals) > 10
                    fprintf('...');
                end
            end
            fprintf('\n');
        catch ME_inner
            fprintf('ERRO ao analisar categorias: %s\n', ME_inner.message);
            fprintf('Tipo de dados retornado: %s\n', class(C));
            if iscell(C) && ~isempty(C)
                fprintf('Tipo do primeiro elemento: %s\n', class(C{1}));
            end
        end
        
    catch ME
        fprintf('ERRO ao criar PixelLabelDatastore: %s\n', ME.message);
        fprintf('Sugestões:\n');
        fprintf('  - Verifique se as máscaras estão no formato correto\n');
        fprintf('  - Execute converter_mascaras() se necessário\n');
    end
    
    % Verificar consistência das máscaras
    fprintf('\n--- Verificando Consistencia das Mascaras ---\n');
    
    numCheck = min(20, length(masks));
    fprintf('Analisando %d máscaras...\n', numCheck);
    
    allValues = [];
    multiChannelCount = 0;
    
    for i = 1:numCheck
        if mod(i, 5) == 0
            fprintf('  Processadas: %d/%d\n', i, numCheck);
        end
        
        maskPath = fullfile(maskDir, masks(i).name);
        mask = imread(maskPath);
        
        if size(mask, 3) > 1
            multiChannelCount = multiChannelCount + 1;
            mask = rgb2gray(mask);
        end
        
        vals = unique(mask(:));
        allValues = unique([allValues; vals]);
    end
    
    fprintf('\nResultados da análise:\n');
    fprintf('  Valores únicos em todas as máscaras: ');
    if length(allValues) <= 20
        fprintf('%d ', allValues);
    else
        fprintf('%d ', allValues(1:10));
        fprintf('... (%d valores únicos total)', length(allValues));
    end
    fprintf('\n');
    
    if multiChannelCount > 0
        fprintf('  ⚠ %d máscaras têm múltiplos canais (serão convertidas)\n', multiChannelCount);
    end
    
    if length(allValues) > 2
        fprintf('  ⚠ Máscaras contêm %d valores únicos (recomenda-se binarização)\n', length(allValues));
    end
    
    % Recomendações
    fprintf('\n--- Recomendações ---\n');
    if length(allValues) > 2 || multiChannelCount > 0
        fprintf('1. Execute converter_mascaras() para binarizar as máscaras\n');
        fprintf('2. Máscaras com múltiplos canais serão automaticamente convertidas\n');
    else
        fprintf('1. ✓ Máscaras já estão no formato adequado\n');
    end
    
    if correspondencias < length(images)
        fprintf('4. Verifique se todas as imagens têm máscaras correspondentes\n');
    else
        fprintf('4. ✓ Todas as imagens têm máscaras correspondentes\n');
    end
    
    % Atualizar configuração
    config.lastTest = datetime('now');
    config.numImages = length(images);
    config.numMasks = length(masks);
    config.needsConversion = (length(allValues) > 2 || multiChannelCount > 0);
    
    save('config_caminhos.mat', 'config');
    fprintf('\nConfiguração atualizada e salva!\n');
    
    fprintf('\n=== TESTE CONCLUIDO ===\n');
    if config.needsConversion
        fprintf('⚠ Dados precisam de pré-processamento (será feito automaticamente)\n');
    else
        fprintf('✓ Dados estão prontos para uso\n');
    end
end

function baseNome = extrair_base_nome(nomeCompleto)
    % Extrair nome base removendo sufixos comuns
    
    baseNome = nomeCompleto;
    
    % Remover sufixos comuns
    sufixos = {'_PRINCIPAL', '_CORROSAO', '_256', '_gray', '_mask', '_img'};
    
    for sufixo = sufixos
        baseNome = strrep(baseNome, sufixo{1}, '');
    end
    
    % Remover números no final
    baseNome = regexprep(baseNome, '_\d+$', '');
end

