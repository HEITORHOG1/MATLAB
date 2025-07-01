% Script para Analise de Mascaras - Versao Limpa
% 26/06/2025

clc
close all
clear all

% Definindo os caminhos base
basePath = 'C:\Users\heito\Pictures\imagens_divididas_processadas_2025-06-22-20250626T224937Z-1-001\imagens_divididas_processadas_2025-06-22';

% Caminhos das pastas
imageDir = fullfile(basePath, 'original');
maskDir = fullfile(basePath, 'masks');
resultsDir = fullfile(basePath, 'analise_mascaras');

% Criando pasta de resultados
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

fprintf('=== ANALISE DE MASCARAS EXISTENTES ===\n');

% Carregando arquivos
imageFiles = [dir(fullfile(imageDir, '*.jpg')); 
              dir(fullfile(imageDir, '*.png')); 
              dir(fullfile(imageDir, '*.bmp'))];

maskFiles = [dir(fullfile(maskDir, '*.jpg')); 
             dir(fullfile(maskDir, '*.png')); 
             dir(fullfile(maskDir, '*.bmp'))];

fprintf('Imagens encontradas: %d\n', length(imageFiles));
fprintf('Mascaras encontradas: %d\n', length(maskFiles));

if length(imageFiles) == 0
    error('Nenhuma imagem encontrada!');
end

if length(maskFiles) == 0
    error('Nenhuma mascara encontrada!');
end

% Analisando as mascaras existentes
fprintf('\n=== ANALISANDO MASCARAS ===\n');

% Separando mascaras por tipo (baseado no nome)
corrosao_masks = {};
principal_masks = {};

for i = 1:length(maskFiles)
    filename = maskFiles(i).name;
    if contains(upper(filename), 'CORROSAO')
        corrosao_masks{end+1} = fullfile(maskDir, filename);
    else
        principal_masks{end+1} = fullfile(maskDir, filename);
    end
end

fprintf('Mascaras de corrosao encontradas: %d\n', length(corrosao_masks));
fprintf('Mascaras principais encontradas: %d\n', length(principal_masks));

% Analisando propriedades das mascaras
mask_areas = [];
mask_densities = [];
mask_names = {};

all_masks = [corrosao_masks, principal_masks];

for i = 1:min(10, length(all_masks))
    fprintf('Analisando mascara %d/%d...\n', i, min(10, length(all_masks)));
    
    mask_path = all_masks{i};
    [~, mask_name, ~] = fileparts(mask_path);
    mask_names{i} = mask_name;
    
    % Carregando mascara
    M = imread(mask_path);
    
    % Convertendo para binario se necessario
    if size(M, 3) == 3
        M = rgb2gray(M);
    end
    M_bin = imbinarize(M);
    
    % Calculando propriedades
    area = sum(M_bin(:));
    total_pixels = numel(M_bin);
    density = area / total_pixels;
    
    mask_areas(i) = area;
    mask_densities(i) = density;
    
    fprintf('  Area: %d pixels (%.2f%% da imagem)\n', area, density*100);
    
    % Criando visualizacao para as primeiras mascaras
    if i <= 6
        % Encontrando imagem correspondente
        corresponding_image = '';
        for j = 1:length(imageFiles)
            img_name = imageFiles(j).name;
            if contains(mask_name, extractBefore(img_name, '.')) || ...
               contains(extractBefore(img_name, '.'), mask_name)
                corresponding_image = fullfile(imageDir, img_name);
                break;
            end
        end
        
        % Se nao encontrou, usa a primeira imagem
        if isempty(corresponding_image) && ~isempty(imageFiles)
            corresponding_image = fullfile(imageDir, imageFiles(1).name);
        end
        
        % Visualizacao
        figure(i);
        if ~isempty(corresponding_image)
            I = imread(corresponding_image);
            subplot(1,3,1), imshow(I), title('Imagem Original');
            subplot(1,3,2), imshow(M), title('Mascara');
            subplot(1,3,3), imshow(labeloverlay(I, M_bin)), title('Overlay');
        else
            subplot(1,2,1), imshow(M), title('Mascara');
            subplot(1,2,2), imhist(M), title('Histograma');
        end
        
        sgtitle(sprintf('%s - Area: %d pixels (%.1f%%)', mask_name, area, density*100), ...
                'Interpreter', 'none');
        
        % Salvando figura
        figFile = fullfile(resultsDir, sprintf('analise_mascara_%d.png', i));
        saveas(gcf, figFile);
    end
end

% Criando relatorio estatistico
fprintf('\n=== ESTATISTICAS DAS MASCARAS ===\n');
if ~isempty(mask_areas)
    fprintf('Area media: %.0f +- %.0f pixels\n', mean(mask_areas), std(mask_areas));
    fprintf('Densidade media: %.3f +- %.3f (%.1f%% +- %.1f%%)\n', ...
            mean(mask_densities), std(mask_densities), ...
            mean(mask_densities)*100, std(mask_densities)*100);
    fprintf('Area minima: %.0f pixels\n', min(mask_areas));
    fprintf('Area maxima: %.0f pixels\n', max(mask_areas));
end

% Salvando dados em tabela
if ~isempty(mask_names)
    results_table = table(mask_names', mask_areas', mask_densities', ...
                         'VariableNames', {'Nome_Mascara', 'Area_Pixels', 'Densidade'});
    
    csvFile = fullfile(resultsDir, 'analise_mascaras.csv');
    writetable(results_table, csvFile);
    
    matFile = fullfile(resultsDir, 'dados_mascaras.mat');
    save(matFile, 'results_table', 'mask_areas', 'mask_densities', 'mask_names');
    
    fprintf('\nArquivos salvos:\n');
    fprintf('  CSV: %s\n', csvFile);
    fprintf('  MAT: %s\n', matFile);
end

fprintf('\nAnalise concluida! Verifique a pasta: %s\n', resultsDir);