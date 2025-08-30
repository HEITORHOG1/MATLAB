% executar_figura_comparacao.m
% Script para gerar a Figura 4: Comparação visual de segmentações
% 
% Este script cria um grid 4x3 comparando imagens originais, ground truth,
% segmentações U-Net e Attention U-Net para casos de sucesso, desafio e limitação

%% Configuração inicial
clear; clc; close all;

fprintf('=== Geração da Figura 4: Comparação Visual de Segmentações ===\n');
fprintf('Data: %s\n\n', datestr(now));

%% Adicionar caminhos necessários
addpath('src/visualization');

%% Criar instância do gerador
try
    gerador = GeradorFiguraComparacao();
    fprintf('Gerador de figura inicializado com sucesso.\n');
catch ME
    fprintf('Erro ao inicializar gerador: %s\n', ME.message);
    return;
end

%% Definir arquivo de saída
arquivo_saida = 'figuras/figura_comparacao_segmentacoes.png';

%% Gerar figura de comparação
try
    fprintf('Gerando figura de comparação...\n');
    gerador.gerarFiguraComparacao(arquivo_saida);
    
    fprintf('\n=== Figura gerada com sucesso! ===\n');
    fprintf('Arquivo salvo em: %s\n', arquivo_saida);
    fprintf('Arquivo EPS salvo em: %s\n', strrep(arquivo_saida, '.png', '.eps'));
    
catch ME
    fprintf('Erro durante a geração da figura: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

%% Verificar resultado
if exist(arquivo_saida, 'file')
    fprintf('\nVerificação: Arquivo de figura criado com sucesso.\n');
    
    % Mostrar informações do arquivo
    info = dir(arquivo_saida);
    fprintf('Tamanho do arquivo: %.2f KB\n', info.bytes/1024);
    fprintf('Data de criação: %s\n', info.date);
    
    % Abrir figura para visualização
    fprintf('\nAbrindo figura para visualização...\n');
    try
        img = imread(arquivo_saida);
        figure('Name', 'Figura 4: Comparação Visual de Segmentações', ...
               'Position', [100, 100, 1200, 900]);
        imshow(img);
        title('Figura 4: Comparação Visual de Segmentações - U-Net vs Attention U-Net', ...
              'FontSize', 14, 'FontWeight', 'bold');
    catch
        fprintf('Aviso: Não foi possível abrir a figura para visualização.\n');
    end
else
    fprintf('\nErro: Arquivo de figura não foi criado.\n');
end

fprintf('\n=== Processo concluído ===\n');