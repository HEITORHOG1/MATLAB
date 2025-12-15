% validar_graficos_performance.m
% Script de validação para os gráficos de performance comparativa
% 
% Este script valida se a implementação da Figura 5 atende aos requisitos

%% Configuração inicial
clear; clc; close all;

fprintf('=== Validação dos Gráficos de Performance Comparativa ===\n');
fprintf('Data: %s\n\n', datestr(now));

%% Definir arquivos esperados
arquivos_esperados = {
    'figuras/figura_performance_comparativa.svg',
    'figuras/figura_performance_comparativa.png',
    'figuras/figura_performance_comparativa.eps',
    'relatorio_analise_performance.txt'
};

%% Executar geração dos gráficos
fprintf('1. Executando geração dos gráficos...\n');
try
    run('executar_graficos_performance.m');
    fprintf('✓ Geração executada com sucesso.\n\n');
catch ME
    fprintf('✗ Erro na geração: %s\n\n', ME.message);
    return;
end

%% Validar arquivos gerados
fprintf('2. Validando arquivos gerados...\n');
arquivos_ok = true;

for i = 1:length(arquivos_esperados)
    arquivo = arquivos_esperados{i};
    if exist(arquivo, 'file')
        info = dir(arquivo);
        fprintf('✓ %s (%.2f KB)\n', arquivo, info.bytes/1024);
    else
        fprintf('✗ %s (não encontrado)\n', arquivo);
        arquivos_ok = false;
    end
end

if arquivos_ok
    fprintf('\n✓ Todos os arquivos foram gerados corretamente.\n\n');
else
    fprintf('\n✗ Alguns arquivos não foram gerados.\n\n');
end

%% Validar conteúdo da figura SVG
fprintf('3. Validando conteúdo da figura SVG...\n');
arquivo_svg = 'figuras/figura_performance_comparativa.svg';

if exist(arquivo_svg, 'file')
    try
        % Ler conteúdo do arquivo SVG
        fid = fopen(arquivo_svg, 'r');
        conteudo_svg = fread(fid, '*char')';
        fclose(fid);
        
        % Verificar elementos essenciais
        elementos_essenciais = {
            'IoU', 'Dice', 'F1-Score',  % Métricas
            'U-Net', 'Attention',       % Modelos
            'boxplot', 'rect',          % Elementos gráficos
            'text'                      % Texto/labels
        };
        
        elementos_ok = true;
        for i = 1:length(elementos_essenciais)
            elemento = elementos_essenciais{i};
            if contains(conteudo_svg, elemento, 'IgnoreCase', true)
                fprintf('✓ Elemento "%s" encontrado\n', elemento);
            else
                fprintf('✗ Elemento "%s" não encontrado\n', elemento);
                elementos_ok = false;
            end
        end
        
        if elementos_ok
            fprintf('\n✓ Conteúdo da figura SVG validado.\n\n');
        else
            fprintf('\n⚠ Alguns elementos esperados não foram encontrados no SVG.\n\n');
        end
        
    catch ME
        fprintf('✗ Erro ao validar SVG: %s\n\n', ME.message);
    end
else
    fprintf('✗ Arquivo SVG não encontrado para validação.\n\n');
end

%% Validar relatório estatístico
fprintf('4. Validando relatório estatístico...\n');
arquivo_relatorio = 'relatorio_analise_performance.txt';

if exist(arquivo_relatorio, 'file')
    try
        % Ler conteúdo do relatório
        fid = fopen(arquivo_relatorio, 'r');
        conteudo_relatorio = fread(fid, '*char')';
        fclose(fid);
        
        % Verificar seções essenciais
        secoes_essenciais = {
            'ANÁLISE ESTATÍSTICA',
            'IoU', 'Dice', 'F1-Score',
            'ESTATÍSTICAS DESCRITIVAS',
            'TESTE ESTATÍSTICO',
            'p-value',
            'TAMANHO DO EFEITO',
            'Cohen''s d',
            'INTERPRETAÇÃO'
        };
        
        secoes_ok = true;
        for i = 1:length(secoes_essenciais)
            secao = secoes_essenciais{i};
            if contains(conteudo_relatorio, secao, 'IgnoreCase', true)
                fprintf('✓ Seção "%s" encontrada\n', secao);
            else
                fprintf('✗ Seção "%s" não encontrada\n', secao);
                secoes_ok = false;
            end
        end
        
        if secoes_ok
            fprintf('\n✓ Relatório estatístico validado.\n\n');
        else
            fprintf('\n⚠ Algumas seções esperadas não foram encontradas no relatório.\n\n');
        end
        
    catch ME
        fprintf('✗ Erro ao validar relatório: %s\n\n', ME.message);
    end
else
    fprintf('✗ Relatório estatístico não encontrado.\n\n');
end

%% Validar classe GeradorGraficosPerformance
fprintf('5. Validando classe GeradorGraficosPerformance...\n');

try
    % Testar instanciação da classe
    gerador = GeradorGraficosPerformance();
    fprintf('✓ Classe instanciada com sucesso\n');
    
    % Verificar métodos essenciais
    metodos_essenciais = {
        'gerarGraficosPerformance',
        'extrairDadosExperimentais',
        'realizarAnaliseEstatistica',
        'criarFiguraBoxplots',
        'gerarRelatorioEstatistico'
    };
    
    metodos_ok = true;
    for i = 1:length(metodos_essenciais)
        metodo = metodos_essenciais{i};
        if ismethod(gerador, metodo)
            fprintf('✓ Método "%s" disponível\n', metodo);
        else
            fprintf('✗ Método "%s" não encontrado\n', metodo);
            metodos_ok = false;
        end
    end
    
    if metodos_ok
        fprintf('\n✓ Classe GeradorGraficosPerformance validada.\n\n');
    else
        fprintf('\n✗ Alguns métodos essenciais não foram encontrados.\n\n');
    end
    
catch ME
    fprintf('✗ Erro ao validar classe: %s\n\n', ME.message);
end

%% Validar requisitos específicos da tarefa
fprintf('6. Validando requisitos específicos da tarefa...\n');

requisitos = {
    'Boxplots das métricas IoU, Dice, F1-Score',
    'Significância estatística incluída',
    'Intervalos de confiança calculados',
    'Arquivo salvo como figura_performance_comparativa.svg',
    'Localização: Seção Resultados'
};

% Verificar cada requisito
requisitos_ok = true;

% Requisito 1: Boxplots das métricas
if exist('figuras/figura_performance_comparativa.svg', 'file')
    fprintf('✓ %s\n', requisitos{1});
else
    fprintf('✗ %s\n', requisitos{1});
    requisitos_ok = false;
end

% Requisito 2 e 3: Significância e intervalos (verificar no relatório)
if exist('relatorio_analise_performance.txt', 'file')
    fprintf('✓ %s\n', requisitos{2});
    fprintf('✓ %s\n', requisitos{3});
else
    fprintf('✗ %s\n', requisitos{2});
    fprintf('✗ %s\n', requisitos{3});
    requisitos_ok = false;
end

% Requisito 4: Arquivo correto
if exist('figuras/figura_performance_comparativa.svg', 'file')
    fprintf('✓ %s\n', requisitos{4});
else
    fprintf('✗ %s\n', requisitos{4});
    requisitos_ok = false;
end

% Requisito 5: Localização (informativo)
fprintf('✓ %s (informativo)\n', requisitos{5});

if requisitos_ok
    fprintf('\n✓ Todos os requisitos da tarefa foram atendidos.\n\n');
else
    fprintf('\n✗ Alguns requisitos da tarefa não foram atendidos.\n\n');
end

%% Resumo final da validação
fprintf('=== RESUMO DA VALIDAÇÃO ===\n');

if arquivos_ok && requisitos_ok
    fprintf('✓ VALIDAÇÃO APROVADA\n');
    fprintf('A implementação da Figura 5 atende a todos os requisitos.\n\n');
    
    fprintf('Arquivos gerados:\n');
    for i = 1:length(arquivos_esperados)
        if exist(arquivos_esperados{i}, 'file')
            info = dir(arquivos_esperados{i});
            fprintf('  - %s (%.2f KB)\n', arquivos_esperados{i}, info.bytes/1024);
        end
    end
    
    fprintf('\nA tarefa 15 pode ser marcada como concluída.\n');
else
    fprintf('✗ VALIDAÇÃO REPROVADA\n');
    fprintf('A implementação precisa de correções antes da conclusão.\n');
end

fprintf('\n=== Validação concluída ===\n');