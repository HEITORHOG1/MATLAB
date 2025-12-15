% verificar_fluxograma.m
% Script para verificar se o fluxograma está legível

% Abrir a imagem PNG
img = imread('figuras_classificacao/figura_fluxograma_metodologia.png');

% Criar figura para visualização
figure('Name', 'Verificação do Fluxograma', 'Position', [100, 100, 1200, 900]);
imshow(img);
title('Fluxograma da Metodologia de Classificação', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('\n=== VERIFICAÇÃO DO FLUXOGRAMA ===\n');
fprintf('Arquivo: figuras_classificacao/figura_fluxograma_metodologia.png\n');
fprintf('Resolução: %d x %d pixels\n', size(img, 2), size(img, 1));
fprintf('\nVerifique se:\n');
fprintf('  1. O texto está legível e não sobreposto\n');
fprintf('  2. As caixas têm tamanho adequado\n');
fprintf('  3. As setas conectam corretamente os elementos\n');
fprintf('  4. As cores estão bem definidas\n');
fprintf('  5. O layout está organizado e claro\n');
fprintf('\nPressione qualquer tecla para fechar...\n');

pause;
close all;
