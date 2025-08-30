% executar_graficos_performance.m
% Script para gerar a Figura 5: Gráficos de performance comparativa
% 
% Este script cria boxplots das métricas IoU, Dice, F1-Score comparando
% U-Net e Attention U-Net com significância estatística e intervalos de confiança

%% Configuração inicial
clear; clc; close all;

fprintf('=== Geração da Figura 5: Gráficos de Performance Comparativa ===\n');
fprintf('Data: %s\n\n', datestr(now));

%% Adicionar caminhos necessários
addpath('src/visualization');
addpath('src/data');
addpath('utils');

%% Criar instância do gerador
try
    gerador = GeradorGraficosPerformance();
    fprintf('Gerador de gráficos inicializado com sucesso.\n');
catch ME
    fprintf('Erro ao inicializar gerador: %s\n', ME.message);
    return;
end

%% Definir arquivo de saída
arquivo_saida = 'figuras/figura_performance_comparativa.svg';

%% Gerar gráficos de performance
try
    fprintf('Gerando gráficos de performance...\n');
    gerador.gerarGraficosPerformance(arquivo_saida);
    
    fprintf('\n=== Gráficos gerados com sucesso! ===\n');
    fprintf('Arquivo principal salvo em: %s\n', arquivo_saida);
    
catch ME
    fprintf('Erro durante a geração dos gráficos: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

%% Gerar relatório estatístico detalhado
try
    fprintf('\nGerando relatório estatístico...\n');
    gerador.gerarRelatorioEstatistico('relatorio_analise_performance.txt');
    
catch ME
    fprintf('Erro ao gerar relatório: %s\n', ME.message);
end

%% Verificar resultados
arquivo_png = strrep(arquivo_saida, '.svg', '.png');
arquivo_eps = strrep(arquivo_saida, '.svg', '.eps');

if exist(arquivo_saida, 'file')
    fprintf('\nVerificação: Arquivos de figura criados com sucesso.\n');
    
    % Mostrar informações dos arquivos
    formatos = {arquivo_saida, arquivo_png, arquivo_eps};
    extensoes = {'SVG', 'PNG', 'EPS'};
    
    for i = 1:length(formatos)
        if exist(formatos{i}, 'file')
            info = dir(formatos{i});
            fprintf('  %s: %.2f KB (%s)\n', extensoes{i}, info.bytes/1024, info.date);
        end
    end
    
    % Abrir figura PNG para visualização
    if exist(arquivo_png, 'file')
        fprintf('\nAbrindo figura para visualização...\n');
        try
            img = imread(arquivo_png);
            figure('Name', 'Figura 5: Gráficos de Performance Comparativa', ...
                   'Position', [100, 100, 1200, 800]);
            imshow(img);
            title('Figura 5: Comparação de Performance - Boxplots das Métricas', ...
                  'FontSize', 14, 'FontWeight', 'bold');
        catch
            fprintf('Aviso: Não foi possível abrir a figura para visualização.\n');
        end
    end
else
    fprintf('\nErro: Arquivos de figura não foram criados.\n');
end

%% Verificar relatório estatístico
if exist('relatorio_analise_performance.txt', 'file')
    fprintf('\nRelatório estatístico gerado: relatorio_analise_performance.txt\n');
    
    % Mostrar primeiras linhas do relatório
    fprintf('\nPrimeiras linhas do relatório:\n');
    fprintf('----------------------------------------\n');
    try
        fid = fopen('relatorio_analise_performance.txt', 'r');
        for i = 1:10
            linha = fgetl(fid);
            if ischar(linha)
                fprintf('%s\n', linha);
            else
                break;
            end
        end
        fclose(fid);
        fprintf('----------------------------------------\n');
    catch
        fprintf('Erro ao ler relatório.\n');
    end
end

fprintf('\n=== Processo concluído ===\n');
fprintf('Arquivos gerados:\n');
fprintf('  - %s (figura principal)\n', arquivo_saida);
fprintf('  - %s (visualização)\n', arquivo_png);
fprintf('  - %s (publicação)\n', arquivo_eps);
fprintf('  - relatorio_analise_performance.txt (análise estatística)\n');