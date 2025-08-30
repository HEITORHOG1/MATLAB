% teste_gerador_performance.m
% Teste simples para a classe GeradorGraficosPerformance

clear; clc; close all;

fprintf('=== Teste da Classe GeradorGraficosPerformance ===\n');

% Adicionar caminhos
addpath('src/visualization');
addpath('src/data');
addpath('utils');

% Testar se a classe pode ser instanciada
try
    fprintf('Tentando criar instância da classe...\n');
    
    % Verificar se o arquivo existe
    if exist('src/visualization/GeradorGraficosPerformance.m', 'file')
        fprintf('✓ Arquivo da classe encontrado\n');
    else
        fprintf('✗ Arquivo da classe não encontrado\n');
        return;
    end
    
    % Tentar instanciar
    gerador = GeradorGraficosPerformance();
    fprintf('✓ Classe instanciada com sucesso\n');
    
    % Testar método principal
    fprintf('Testando geração de gráficos...\n');
    arquivo_teste = 'figuras/teste_performance.svg';
    gerador.gerarGraficosPerformance(arquivo_teste);
    
    if exist(arquivo_teste, 'file')
        fprintf('✓ Gráfico gerado com sucesso: %s\n', arquivo_teste);
    else
        fprintf('✗ Gráfico não foi gerado\n');
    end
    
catch ME
    fprintf('✗ Erro: %s\n', ME.message);
    fprintf('Arquivo: %s\n', ME.stack(1).file);
    fprintf('Linha: %d\n', ME.stack(1).line);
end

fprintf('\n=== Teste concluído ===\n');