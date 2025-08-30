%% ========================================================================
%% SCRIPT: VALIDAR TABELA 1 - CARACTERÍSTICAS DO DATASET
%% ========================================================================
%% 
%% AUTOR: Heitor Oliveira Gonçalves
%% LinkedIn: https://www.linkedin.com/in/heitorhog/
%% Data: Agosto 2025
%% Versão: 1.0
%%
%% DESCRIÇÃO:
%%   Script de validação para verificar se a Tabela 1 foi gerada corretamente
%%   e atende aos requisitos do artigo científico
%% ========================================================================

clear; clc;

fprintf('========================================================================\n');
fprintf('VALIDAÇÃO DA TABELA 1: CARACTERÍSTICAS DO DATASET\n');
fprintf('========================================================================\n\n');

%% 1. Verificar arquivos necessários
fprintf('1. Verificando arquivos necessários...\n');

arquivos_necessarios = {
    'src/validation/GeradorTabelaDataset.m';
    'gerar_tabela_dataset.m';
    'img/original';
    'img/masks';
};

todos_presentes = true;
for i = 1:length(arquivos_necessarios)
    if exist(arquivos_necessarios{i}, 'file') || exist(arquivos_necessarios{i}, 'dir')
        fprintf('   ✅ %s\n', arquivos_necessarios{i});
    else
        fprintf('   ❌ %s\n', arquivos_necessarios{i});
        todos_presentes = false;
    end
end

if ~todos_presentes
    fprintf('\n❌ Alguns arquivos necessários não foram encontrados.\n');
    return;
end

%% 2. Testar classe GeradorTabelaDataset
fprintf('\n2. Testando classe GeradorTabelaDataset...\n');

try
    % Adicionar caminho se necessário
    if ~exist('GeradorTabelaDataset', 'class')
        addpath('src/validation');
    end
    
    % Criar instância
    gerador = GeradorTabelaDataset('verbose', false);
    fprintf('   ✅ Classe instanciada com sucesso\n');
    
    % Testar análise do dataset
    sucesso = gerador.analisarDataset();
    if sucesso
        fprintf('   ✅ Análise do dataset executada com sucesso\n');
    else
        fprintf('   ❌ Falha na análise do dataset\n');
        return;
    end
    
    % Testar geração da tabela
    gerador.gerarTabelaLatex();
    if ~isempty(gerador.tabelaLatex)
        fprintf('   ✅ Tabela LaTeX gerada com sucesso\n');
    else
        fprintf('   ❌ Falha na geração da tabela LaTeX\n');
        return;
    end
    
catch ME
    fprintf('   ❌ Erro no teste da classe: %s\n', ME.message);
    return;
end

%% 3. Validar conteúdo da tabela
fprintf('\n3. Validando conteúdo da tabela...\n');

try
    % Verificar se características foram extraídas
    if isfield(gerador.caracteristicas, 'total_imagens') && gerador.caracteristicas.total_imagens > 0
        fprintf('   ✅ Total de imagens: %d\n', gerador.caracteristicas.total_imagens);
    else
        fprintf('   ❌ Total de imagens não encontrado ou inválido\n');
    end
    
    % Verificar resolução
    if isfield(gerador.caracteristicas, 'resolucao_processada')
        res = gerador.caracteristicas.resolucao_processada;
        fprintf('   ✅ Resolução processada: %dx%d\n', res(1), res(2));
    else
        fprintf('   ❌ Resolução não encontrada\n');
    end
    
    % Verificar material
    if isfield(gerador.caracteristicas, 'material')
        fprintf('   ✅ Material: %s\n', gerador.caracteristicas.material);
    else
        fprintf('   ❌ Material não especificado\n');
    end
    
    % Verificar divisão do dataset
    if isfield(gerador.caracteristicas, 'divisao_absoluta')
        divisao = gerador.caracteristicas.divisao_absoluta;
        fprintf('   ✅ Divisão do dataset: %d/%d/%d\n', divisao(1), divisao(2), divisao(3));
    else
        fprintf('   ❌ Divisão do dataset não encontrada\n');
    end
    
catch ME
    fprintf('   ❌ Erro na validação do conteúdo: %s\n', ME.message);
end

%% 4. Validar formato LaTeX
fprintf('\n4. Validando formato LaTeX...\n');

try
    tabela = gerador.tabelaLatex;
    
    % Verificar elementos essenciais do LaTeX
    elementos_latex = {
        '\\begin{table}';
        '\\end{table}';
        '\\begin{tabular}';
        '\\end{tabular}';
        '\\caption{';
        '\\label{';
        '\\hline';
    };
    
    for i = 1:length(elementos_latex)
        if contains(tabela, elementos_latex{i})
            fprintf('   ✅ %s\n', elementos_latex{i});
        else
            fprintf('   ❌ %s não encontrado\n', elementos_latex{i});
        end
    end
    
    % Verificar se contém dados essenciais
    dados_essenciais = {
        'Total de Imagens';
        'Resolução';
        'ASTM A572';
        'Treinamento';
        'Validação';
        'Teste';
    };
    
    fprintf('\n   Verificando dados essenciais na tabela:\n');
    for i = 1:length(dados_essenciais)
        if contains(tabela, dados_essenciais{i})
            fprintf('   ✅ %s\n', dados_essenciais{i});
        else
            fprintf('   ❌ %s não encontrado\n', dados_essenciais{i});
        end
    end
    
catch ME
    fprintf('   ❌ Erro na validação do LaTeX: %s\n', ME.message);
end

%% 5. Testar execução completa
fprintf('\n5. Testando execução completa...\n');

try
    % Executar script principal (modo silencioso)
    fprintf('   Executando gerar_tabela_dataset.m...\n');
    
    % Salvar estado atual do workspace
    vars_antes = who;
    
    % Executar em modo silencioso (capturar output)
    evalc('gerar_tabela_dataset');
    
    % Verificar se arquivos foram criados
    arquivos_saida = {
        'tabelas/tabela_dataset_caracteristicas.tex';
        'tabelas/tabela_dataset_caracteristicas_dados.mat';
        'tabelas/relatorio_dataset_caracteristicas.txt';
    };
    
    for i = 1:length(arquivos_saida)
        if exist(arquivos_saida{i}, 'file')
            fprintf('   ✅ %s criado\n', arquivos_saida{i});
        else
            fprintf('   ❌ %s não criado\n', arquivos_saida{i});
        end
    end
    
catch ME
    fprintf('   ❌ Erro na execução completa: %s\n', ME.message);
end

%% 6. Verificar integração com artigo
fprintf('\n6. Verificando integração com artigo...\n');

try
    if exist('artigo_cientifico_corrosao.tex', 'file')
        % Ler artigo
        fid = fopen('artigo_cientifico_corrosao.tex', 'r', 'n', 'UTF-8');
        conteudo_artigo = fread(fid, '*char')';
        fclose(fid);
        
        % Verificar se tabela foi inserida
        if contains(conteudo_artigo, 'TABELA 1: CARACTERÍSTICAS DO DATASET')
            fprintf('   ✅ Tabela inserida no artigo\n');
        else
            fprintf('   ⚠️ Tabela não encontrada no artigo\n');
        end
        
        % Verificar elementos da tabela no artigo
        if contains(conteudo_artigo, 'Total de Imagens')
            fprintf('   ✅ Conteúdo da tabela presente no artigo\n');
        else
            fprintf('   ❌ Conteúdo da tabela não encontrado no artigo\n');
        end
        
    else
        fprintf('   ⚠️ Arquivo do artigo não encontrado\n');
    end
    
catch ME
    fprintf('   ❌ Erro na verificação do artigo: %s\n', ME.message);
end

%% 7. Relatório final de validação
fprintf('\n========================================================================\n');
fprintf('RELATÓRIO FINAL DE VALIDAÇÃO\n');
fprintf('========================================================================\n');

try
    % Carregar dados se disponíveis
    if exist('tabelas/tabela_dataset_caracteristicas_dados.mat', 'file')
        dados = load('tabelas/tabela_dataset_caracteristicas_dados.mat');
        
        fprintf('Status: ✅ VALIDAÇÃO CONCLUÍDA COM SUCESSO\n\n');
        
        fprintf('Resumo dos dados extraídos:\n');
        fprintf('  - Total de imagens: %d\n', dados.caracteristicas.total_imagens);
        fprintf('  - Resolução original: %dx%d\n', dados.caracteristicas.resolucao_original(1), dados.caracteristicas.resolucao_original(2));
        fprintf('  - Resolução processada: %dx%d\n', dados.caracteristicas.resolucao_processada(1), dados.caracteristicas.resolucao_processada(2));
        fprintf('  - Material: %s\n', dados.caracteristicas.material);
        fprintf('  - Tipo de estrutura: %s\n', dados.caracteristicas.tipo_estrutura);
        fprintf('  - Número de classes: %d\n', dados.caracteristicas.num_classes);
        fprintf('  - Distribuição: Background %.1f%%, Corrosão %.1f%%\n', ...
            dados.caracteristicas.distribuicao_classes(1), dados.caracteristicas.distribuicao_classes(2));
        
        fprintf('\nDivisão do dataset:\n');
        for i = 1:length(dados.caracteristicas.divisao_nomes)
            fprintf('  - %s: %d imagens (%.1f%%)\n', ...
                dados.caracteristicas.divisao_nomes{i}, ...
                dados.caracteristicas.divisao_absoluta(i), ...
                dados.caracteristicas.divisao_percentual(i));
        end
        
        fprintf('\nArquivos gerados:\n');
        fprintf('  - Tabela LaTeX: tabelas/tabela_dataset_caracteristicas.tex\n');
        fprintf('  - Dados MATLAB: tabelas/tabela_dataset_caracteristicas_dados.mat\n');
        fprintf('  - Relatório: tabelas/relatorio_dataset_caracteristicas.txt\n');
        
        fprintf('\n✅ A Tabela 1 foi gerada com sucesso e está pronta para uso no artigo científico!\n');
        
    else
        fprintf('Status: ⚠️ VALIDAÇÃO PARCIAL\n');
        fprintf('Alguns arquivos de saída não foram encontrados.\n');
    end
    
catch ME
    fprintf('Status: ❌ ERRO NA VALIDAÇÃO\n');
    fprintf('Erro: %s\n', ME.message);
end

fprintf('\n========================================================================\n');