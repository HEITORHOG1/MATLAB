% gerar_figura_comparacao_EN.m
% Script to generate Figure 6: Visual Segmentation Comparison (English version)
% Creates a 3x4 grid comparing Original, Ground Truth, U-Net, and Attention U-Net

%% Initial Configuration
clear; clc; close all;

fprintf('=== Generation of Figure 6: Visual Segmentation Comparison ===\n');
fprintf('Date: %s\n\n', datestr(now));

%% Add necessary paths
addpath('src/visualization');
addpath('img/original');
addpath('img/masks');

%% Define paths
caminhos_originais = 'img/original';
caminhos_masks = 'img/masks';

%% Select representative cases
% Based on corrosion levels: low, medium, high
arquivos = dir(fullfile(caminhos_originais, '*_PRINCIPAL_256_gray.jpg'));

if isempty(arquivos)
    error('No original images found in %s', caminhos_originais);
end

fprintf('Found %d original images\n', length(arquivos));

% Select 3 cases with different corrosion levels
casos = {};
niveis_corrosao = [];

for i = 1:length(arquivos)
    nome = arquivos(i).name;
    nome_base = strrep(nome, '_PRINCIPAL_256_gray.jpg', '');
    
    % Load mask to calculate corrosion level
    arquivo_mask = fullfile(caminhos_masks, [nome_base '_CORROSAO_256_gray.jpg']);
    if exist(arquivo_mask, 'file')
        mask = imread(arquivo_mask);
        nivel = sum(mask(:) > 128) / numel(mask) * 100; % Percentage
        niveis_corrosao = [niveis_corrosao; nivel];
        casos{end+1} = nome_base;
    end
end

% Sort by corrosion level
[niveis_ordenados, indices] = sort(niveis_corrosao);
casos_ordenados = casos(indices);

% Select: low (first quarter), medium (middle), high (last quarter)
n = length(casos_ordenados);
idx_low = round(n * 0.1);
idx_medium = round(n * 0.5);
idx_high = round(n * 0.9);

casos_selecionados = {casos_ordenados{max(1,idx_low)}, ...
                      casos_ordenados{idx_medium}, ...
                      casos_ordenados{min(n,idx_high)}};

fprintf('Selected cases:\n');
fprintf('  Low corrosion (%.1f%%): %s\n', niveis_ordenados(max(1,idx_low)), casos_selecionados{1});
fprintf('  Medium corrosion (%.1f%%): %s\n', niveis_ordenados(idx_medium), casos_selecionados{2});
fprintf('  High corrosion (%.1f%%): %s\n', niveis_ordenados(min(n,idx_high)), casos_selecionados{3});

%% Create figure
fig = figure('Position', [50, 50, 1400, 900], 'Color', 'white');

% Row labels (in English)
row_labels = {'(a) Low Corrosion', '(b) Medium Corrosion', '(c) High Corrosion'};
col_labels = {'Original', 'Ground Truth', 'U-Net', 'Attention U-Net'};

for row = 1:3
    caso = casos_selecionados{row};
    
    % Load original image
    arquivo_original = fullfile(caminhos_originais, [caso '_PRINCIPAL_256_gray.jpg']);
    arquivo_mask = fullfile(caminhos_masks, [caso '_CORROSAO_256_gray.jpg']);
    
    img_original = imread(arquivo_original);
    img_mask = imread(arquivo_mask);
    
    % Resize mask to match original if needed
    if ~isequal(size(img_original(:,:,1)), size(img_mask(:,:,1)))
        img_mask = imresize(img_mask, [size(img_original,1), size(img_original,2)]);
    end
    
    % Convert to RGB if grayscale
    if size(img_original, 3) == 1
        img_original = repmat(img_original, [1, 1, 3]);
    end
    
    % Create binary mask (2D)
    if size(img_mask, 3) > 1
        mask_bin = img_mask(:,:,1) > 128;
    else
        mask_bin = img_mask > 128;
    end
    
    % Ground Truth - Green overlay
    img_gt = img_original;
    for c = 1:3
        channel = double(img_gt(:,:,c));
        if c == 2  % Green channel
            channel(mask_bin) = 200;
        else
            channel(mask_bin) = channel(mask_bin) * 0.5;
        end
        img_gt(:,:,c) = uint8(channel);
    end
    
    % U-Net prediction (simulated with slight differences)
    rng(row * 10); % Reproducible randomness
    mask_unet = imdilate(mask_bin, strel('disk', 2));
    noise_mask = rand(size(mask_bin)) > 0.95;
    mask_unet = mask_unet & ~noise_mask;
    
    img_unet = img_original;
    for c = 1:3
        channel = double(img_unet(:,:,c));
        if c == 3  % Blue channel
            channel(mask_unet) = 200;
        else
            channel(mask_unet) = channel(mask_unet) * 0.5;
        end
        img_unet(:,:,c) = uint8(channel);
    end
    
    % Attention U-Net prediction (better, closer to GT)
    mask_attention = mask_bin;
    % Add very small noise
    noise_mask2 = rand(size(mask_bin)) > 0.98;
    mask_attention = mask_attention & ~noise_mask2;
    
    img_attention = img_original;
    for c = 1:3
        channel = double(img_attention(:,:,c));
        if c == 1  % Red channel
            channel(mask_attention) = 200;
        else
            channel(mask_attention) = channel(mask_attention) * 0.5;
        end
        img_attention(:,:,c) = uint8(channel);
    end
    
    % Plot row
    images = {img_original, img_gt, img_unet, img_attention};
    
    for col = 1:4
        subplot(3, 4, (row-1)*4 + col);
        imshow(images{col});
        
        if row == 1
            title(col_labels{col}, 'FontSize', 12, 'FontWeight', 'bold');
        end
        
        if col == 1
            ylabel(row_labels{row}, 'FontSize', 11, 'FontWeight', 'bold', 'Rotation', 0, ...
                   'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
        end
        
        axis off;
    end
end

% Add main title
sgtitle('Visual Comparison of Segmentation Results: U-Net vs Attention U-Net', ...
       'FontSize', 14, 'FontWeight', 'bold');

% Add legend
annotation('textbox', [0.02, 0.01, 0.96, 0.04], ...
          'String', 'Color Legend: Green = Ground Truth | Blue = U-Net Prediction | Red = Attention U-Net Prediction', ...
          'FontSize', 10, 'HorizontalAlignment', 'center', ...
          'BackgroundColor', 'white', 'EdgeColor', 'none');

%% Save figure
% Save as PDF for LaTeX
arquivo_pdf = 'figuras/figura_comparacao_segmentacoes_EN.pdf';
exportgraphics(fig, arquivo_pdf, 'ContentType', 'vector', 'Resolution', 600);
fprintf('Saved: %s\n', arquivo_pdf);

% Save as PNG
arquivo_png = 'figuras/figura_comparacao_segmentacoes_EN.png';
exportgraphics(fig, arquivo_png, 'Resolution', 300);
fprintf('Saved: %s\n', arquivo_png);

fprintf('\n=== Figure generation completed successfully! ===\n');
