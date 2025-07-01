function converter_mascaras(config)
    % Script para converter mascaras para formato padrao
    % VERSÃO DEFINITIVA - TODOS OS ERROS CORRIGIDOS
    
    if nargin < 1
        error('Configuração é necessária. Execute primeiro: executar_comparacao()');
    end
    
    fprintf('\n=== CONVERSAO DE MASCARAS (CORRIGIDA) ===\n');
    
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
    [needsConversion, conversionInfo] = analisar_necessidade_conversao(maskDir, masks);
    
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
            mask = converter_para_binario(mask, conversionInfo.threshold);
            
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
        verificar_conversao(outputDir);
        
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

function [needsConversion, info] = analisar_necessidade_conversao(maskDir, masks)
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

function maskBinary = converter_para_binario(mask, threshold)
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

function verificar_conversao(outputDir)
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

