function [images, masks] = carregar_dados_robustos(config)
    % ========================================================================
    % CARREGAMENTO ROBUSTO DE DADOS - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 1.2 Final
    %
    % DESCRIÇÃO:
    %   Carregar dados de forma robusta e segura com validação completa
    % 
    % ENTRADA:
    %   config - Estrutura com configurações (imageDir, maskDir, etc.)
    %
    % SAÍDA:
    %   images - Cell array com caminhos das imagens
    %   masks  - Cell array com caminhos das máscaras
    
    imageDir = config.imageDir;
    maskDir = config.maskDir;
    
    % Verificar se os diretórios existem
    if ~exist(imageDir, 'dir')
        error('Diretório de imagens não encontrado: %s', imageDir);
    end
    
    if ~exist(maskDir, 'dir')
        error('Diretório de máscaras não encontrado: %s', maskDir);
    end
    
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
    if ~isempty(images)
        images = arrayfun(@(x) fullfile(imageDir, x.name), images, 'UniformOutput', false);
    else
        images = {};
    end
    
    if ~isempty(masks)
        masks = arrayfun(@(x) fullfile(maskDir, x.name), masks, 'UniformOutput', false);
    else
        masks = {};
    end
    
    fprintf('Dados carregados: %d imagens, %d máscaras\n', length(images), length(masks));
    
    % Verificar se temos dados suficientes
    if length(images) == 0
        error('Nenhuma imagem encontrada em: %s', imageDir);
    end
    
    if length(masks) == 0
        error('Nenhuma máscara encontrada em: %s', maskDir);
    end
    
    if length(images) ~= length(masks)
        warning('Número de imagens (%d) não corresponde ao número de máscaras (%d)', ...
            length(images), length(masks));
    end
end
