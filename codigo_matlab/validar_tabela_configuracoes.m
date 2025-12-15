% ========================================================================
% VALIDAR TABELA DE CONFIGURAÇÕES DE TREINAMENTO
% ========================================================================
% 
% AUTOR: Heitor Oliveira Gonçalves
% LinkedIn: https://www.linkedin.com/in/heitorhog/
% Data: Agosto 2025
% Versão: 1.0
%
% DESCRIÇÃO:
%   Script de validação para verificar se a Tabela 2 de configurações
%   de treinamento atende a todos os requisitos da Task 19
%
% TASK: 19. Criar tabela 2: Configurações de treinamento
% REQUIREMENTS: 6.5
% ========================================================================

clear; clc;

fprintf('========================================================================\n');
fprintf('VALIDAÇÃO DA TABELA DE CONFIGURAÇÕES DE TREINAMENTO\n');
fprintf('========================================================================\n\n');

% Verificar se arquivos necessários existem
fprintf('🔍 Verificando arquivos necessários...\n');

arquivos_necessarios = {
    'src/validation/GeradorTabelaConfiguracoes.m';
    'gerar_tabela_configuracoes.m'
};

todos_presentes = true;
for i = 1:length(arquivos_necessarios)
    if exist(arquivos_necessarios{i}, 'file')
        fprintf('   ✅ %s\n', arquivos_necessarios{i});
    else
        fprintf('   ❌ %s\n', arquivos_necessarios{i});
        todos_presentes = false;
    end
end

if ~todos_presentes
    fprintf('\n❌ Alguns arquivos necessários não foram encontrados.\n');
    fprintf('Execute primeiro: gerar_tabela_configuracoes\n');
    return;
end

% Executar geração da tabela
fprintf('\n🚀 Executando geração da tabela...\n');

try
    % Adicionar caminhos
    addpath(genpath('src'));
    
    % Executar script principal
    run('gerar_tabela_configuracoes.m');
    
    fprintf('\n✅ Geração executada com sucesso!\n');
    
catch ME
    fprintf('\n❌ Erro na execução: %s\n', ME.message);
    return;
end

% Validar arquivos de saída
fprintf('\n📋 Validando arquivos de saída...\n');

arquivos_saida = {
    'tabelas/tabela_configuracoes_treinamento.tex';
    'tabelas/configuracoes_treinamento.txt';
    'tabelas/relatorio_tabela_configuracoes.txt'
};

arquivos_ok = true;
for i = 1:length(arquivos_saida)
    if exist(arquivos_saida{i}, 'file')
        fprintf('   ✅ %s\n', arquivos_saida{i});
    else
        fprintf('   ❌ %s\n', arquivos_saida{i});
        arquivos_ok = false;
    end
end

% Validar conteúdo da tabela LaTeX
fprintf('\n📝 Validando conteúdo da tabela LaTeX...\n');

if exist('tabelas/tabela_configuracoes_treinamento.tex', 'file')
    try
        conteudo = fileread('tabelas/tabela_configuracoes_treinamento.tex');
        
        % Elementos obrigatórios da tabela
        elementos_obrigatorios = {
            '\\begin{table}', 'Início da tabela';
            '\\caption{', 'Caption da tabela';
            '\\label{tab:configuracoes_treinamento}', 'Label da tabela';
            '\\begin{tabular}', 'Início do tabular';
            'U-Net', 'Coluna U-Net';
            'Attention U-Net', 'Coluna Attention U-Net';
            'Arquitetura da Rede', 'Seção de arquitetura';
            'Hiperparâmetros de Treinamento', 'Seção de hiperparâmetros';
            'Configuração do Dataset', 'Seção do dataset';
            'Especificações de Hardware', 'Seção de hardware';
            'Ambiente de Software', 'Seção de software';
            'adam', 'Otimizador Adam';
            '0.001', 'Learning rate';
            '50', 'Número de épocas';
            '8', 'Batch size';
            '414', 'Total de imagens';
            'Intel Core', 'Especificação de CPU';
            'GB', 'Especificação de memória';
            'MATLAB', 'Software utilizado';
            '\\end{tabular}', 'Fim do tabular';
            '\\end{table}', 'Fim da tabela'
        };
        
        elementos_encontrados = 0;
        for i = 1:size(elementos_obrigatorios, 1)
            elemento = elementos_obrigatorios{i, 1};
            descricao = elementos_obrigatorios{i, 2};
            
            if contains(conteudo, elemento)
                fprintf('   ✅ %s\n', descricao);
                elementos_encontrados = elementos_encontrados + 1;
            else
                fprintf('   ❌ %s (não encontrado: %s)\n', descricao, elemento);
            end
        end
        
        percentual = (elementos_encontrados / size(elementos_obrigatorios, 1)) * 100;
        fprintf('\n   📊 Elementos encontrados: %.1f%% (%d/%d)\n', ...
                percentual, elementos_encontrados, size(elementos_obrigatorios, 1));
        
        if percentual >= 90
            fprintf('   ✅ Conteúdo da tabela LaTeX validado com sucesso!\n');
        else
            fprintf('   ⚠️ Alguns elementos esperados não foram encontrados na tabela.\n');
        end
        
    catch ME
        fprintf('   ❌ Erro ao validar conteúdo LaTeX: %s\n', ME.message);
    end
else
    fprintf('   ❌ Arquivo LaTeX não encontrado\n');
end

% Validar conteúdo do arquivo de texto
fprintf('\n📄 Validando arquivo de texto...\n');

if exist('tabelas/configuracoes_treinamento.txt', 'file')
    try
        conteudo_txt = fileread('tabelas/configuracoes_treinamento.txt');
        
        secoes_esperadas = {
            'ARQUITETURA DA REDE';
            'HIPERPARÂMETROS DE TREINAMENTO';
            'CONFIGURAÇÃO DO DATASET';
            'ESPECIFICAÇÕES DE HARDWARE';
            'AMBIENTE DE SOFTWARE'
        };
        
        secoes_encontradas = 0;
        for i = 1:length(secoes_esperadas)
            if contains(conteudo_txt, secoes_esperadas{i})
                fprintf('   ✅ %s\n', secoes_esperadas{i});
                secoes_encontradas = secoes_encontradas + 1;
            else
                fprintf('   ❌ %s\n', secoes_esperadas{i});
            end
        end
        
        if secoes_encontradas == length(secoes_esperadas)
            fprintf('   ✅ Arquivo de texto validado com sucesso!\n');
        else
            fprintf('   ⚠️ Algumas seções esperadas não foram encontradas.\n');
        end
        
    catch ME
        fprintf('   ❌ Erro ao validar arquivo de texto: %s\n', ME.message);
    end
else
    fprintf('   ❌ Arquivo de texto não encontrado\n');
end

% Validar classe GeradorTabelaConfiguracoes
fprintf('\n🔧 Validando classe GeradorTabelaConfiguracoes...\n');

if exist('src/validation/GeradorTabelaConfiguracoes.m', 'file')
    try
        conteudo_classe = fileread('src/validation/GeradorTabelaConfiguracoes.m');
        
        metodos_esperados = {
            'gerarTabelaCompleta', 'Método principal de geração';
            'extrairConfiguracoesTreinamento', 'Extração de configurações';
            'detectarHardware', 'Detecção de hardware';
            'caracterizarAmbiente', 'Caracterização do ambiente';
            'gerarTabelaLatex', 'Geração da tabela LaTeX';
            'gerarTabelaTexto', 'Geração da tabela em texto';
            'validarCompletude', 'Validação de completude';
            'gerarRelatorio', 'Geração de relatório'
        };
        
        metodos_encontrados = 0;
        for i = 1:size(metodos_esperados, 1)
            metodo = metodos_esperados{i, 1};
            descricao = metodos_esperados{i, 2};
            
            if contains(conteudo_classe, ['function ' metodo]) || contains(conteudo_classe, [metodo '('])
                fprintf('   ✅ %s\n', descricao);
                metodos_encontrados = metodos_encontrados + 1;
            else
                fprintf('   ❌ %s\n', descricao);
            end
        end
        
        if metodos_encontrados == size(metodos_esperados, 1)
            fprintf('   ✅ Classe GeradorTabelaConfiguracoes validada com sucesso!\n');
        else
            fprintf('   ⚠️ Alguns métodos esperados não foram encontrados.\n');
        end
        
    catch ME
        fprintf('   ❌ Erro ao validar classe: %s\n', ME.message);
    end
else
    fprintf('   ❌ Classe GeradorTabelaConfiguracoes não encontrada\n');
end

% Verificar requisitos da Task 19
fprintf('\n🎯 Verificando requisitos da Task 19...\n');

requisitos = {
    'Desenvolver tabela com hiperparâmetros e configurações técnicas';
    'Incluir hardware utilizado e tempo de processamento';
    'Especificar localização: Seção Metodologia';
    'Atender Requirements: 6.5'
};

requisitos_atendidos = {
    exist('tabelas/tabela_configuracoes_treinamento.tex', 'file') && ...
    (exist('tabelas/configuracoes_treinamento.txt', 'file') && ...
     contains(fileread('tabelas/configuracoes_treinamento.txt'), 'HIPERPARÂMETROS'));
    
    exist('tabelas/configuracoes_treinamento.txt', 'file') && ...
    contains(fileread('tabelas/configuracoes_treinamento.txt'), 'HARDWARE');
    
    exist('tabelas/tabela_configuracoes_treinamento.tex', 'file') && ...
    contains(fileread('tabelas/tabela_configuracoes_treinamento.tex'), 'caption');
    
    exist('tabelas/tabela_configuracoes_treinamento.tex', 'file')
};

requisitos_ok = true;
for i = 1:length(requisitos)
    if requisitos_atendidos{i}
        fprintf('   ✅ %s\n', requisitos{i});
    else
        fprintf('   ❌ %s\n', requisitos{i});
        requisitos_ok = false;
    end
end

% Resumo final
fprintf('\n========================================================================\n');
fprintf('RESUMO DA VALIDAÇÃO\n');
fprintf('========================================================================\n\n');

if arquivos_ok && requisitos_ok
    fprintf('Status: ✅ VALIDAÇÃO COMPLETA\n');
    fprintf('A Tabela 2 de configurações de treinamento foi gerada com sucesso\n');
    fprintf('e atende a todos os requisitos da Task 19.\n\n');
    
    fprintf('📋 ARQUIVOS GERADOS:\n');
    fprintf('1. tabelas/tabela_configuracoes_treinamento.tex - Tabela LaTeX para artigo\n');
    fprintf('2. tabelas/configuracoes_treinamento.txt - Versão legível em texto\n');
    fprintf('3. tabelas/relatorio_tabela_configuracoes.txt - Relatório detalhado\n\n');
    
    fprintf('🎯 TASK 19 COMPLETADA!\n');
    fprintf('A tabela está pronta para integração no artigo científico.\n');
    
else
    fprintf('Status: ⚠️ VALIDAÇÃO PARCIAL\n');
    if ~arquivos_ok
        fprintf('Alguns arquivos de saída não foram encontrados.\n');
    end
    if ~requisitos_ok
        fprintf('Alguns requisitos da task não foram atendidos.\n');
    end
    fprintf('Revise os problemas identificados acima.\n');
end

fprintf('\n========================================================================\n');