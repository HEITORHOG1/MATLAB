%% ========================================================================
%% SCRIPT: GERAR TABELA 1 - CARACTERÍSTICAS DO DATASET
%% ========================================================================
%% 
%% AUTOR: Heitor Oliveira Gonçalves
%% LinkedIn: https://www.linkedin.com/in/heitorhog/
%% Data: Agosto 2025
%% Versão: 1.0
%%
%% DESCRIÇÃO:
%%   Script para gerar Tabela 1 com características do dataset para o
%%   artigo científico sobre detecção de corrosão usando U-Net e Attention U-Net
%%
%% SAÍDAS:
%%   - tabela_dataset_caracteristicas.tex (tabela LaTeX)
%%   - tabela_dataset_caracteristicas_dados.mat (dados MATLAB)
%%   - relatorio_dataset_caracteristicas.txt (relatório detalhado)
%% ========================================================================

clear; clc;

fprintf('========================================================================\n');
fprintf('GERAÇÃO DA TABELA 1: CARACTERÍSTICAS DO DATASET\n');
fprintf('========================================================================\n\n');

try
    %% 1. Inicializar gerador de tabela
    fprintf('1. Inicializando gerador de tabela...\n');
    gerador = GeradorTabelaDataset('verbose', true);
    
    %% 2. Analisar dataset
    fprintf('\n2. Analisando dataset...\n');
    sucesso = gerador.analisarDataset();
    
    if ~sucesso
        error('Falha na análise do dataset');
    end
    
    %% 3. Gerar tabela LaTeX
    fprintf('\n3. Gerando tabela LaTeX...\n');
    gerador.gerarTabelaLatex();
    
    %% 4. Salvar arquivos
    fprintf('\n4. Salvando arquivos...\n');
    
    % Salvar na pasta tabelas
    if ~exist('tabelas', 'dir')
        mkdir('tabelas');
    end
    
    arquivo_tabela = fullfile('tabelas', 'tabela_dataset_caracteristicas.tex');
    gerador.salvarTabela(arquivo_tabela);
    
    %% 5. Gerar relatório
    fprintf('\n5. Gerando relatório...\n');
    arquivo_relatorio = fullfile('tabelas', 'relatorio_dataset_caracteristicas.txt');
    gerador.gerarRelatorio(arquivo_relatorio);
    
    %% 6. Exibir tabela
    fprintf('\n6. Exibindo tabela gerada...\n');
    gerador.exibirTabela();
    
    %% 7. Inserir tabela no artigo LaTeX
    fprintf('\n7. Inserindo tabela no artigo...\n');
    inserirTabelaNoArtigo(gerador.tabelaLatex);
    
    %% 8. Resumo final
    fprintf('\n========================================================================\n');
    fprintf('TABELA 1 GERADA COM SUCESSO!\n');
    fprintf('========================================================================\n');
    fprintf('Arquivos gerados:\n');
    fprintf('  - %s\n', arquivo_tabela);
    fprintf('  - %s\n', strrep(arquivo_tabela, '.tex', '_dados.mat'));
    fprintf('  - %s\n', arquivo_relatorio);
    fprintf('  - artigo_cientifico_corrosao.tex (atualizado)\n\n');
    
    fprintf('Características do dataset:\n');
    fprintf('  - Total de imagens: %d\n', gerador.caracteristicas.total_imagens);
    fprintf('  - Resolução: %dx%d pixels\n', gerador.caracteristicas.resolucao_processada(1), gerador.caracteristicas.resolucao_processada(2));
    fprintf('  - Material: %s\n', gerador.caracteristicas.material);
    fprintf('  - Divisão: %d/%d/%d (treino/validação/teste)\n', gerador.caracteristicas.divisao_absoluta);
    fprintf('\n');
    
catch ME
    fprintf('\n❌ ERRO na geração da tabela:\n');
    fprintf('   %s\n', ME.message);
    fprintf('   Arquivo: %s\n', ME.stack(1).file);
    fprintf('   Linha: %d\n\n', ME.stack(1).line);
    
    % Tentar diagnóstico
    fprintf('Diagnóstico:\n');
    if exist('src/validation/GeradorTabelaDataset.m', 'file')
        fprintf('  ✅ Classe GeradorTabelaDataset encontrada\n');
    else
        fprintf('  ❌ Classe GeradorTabelaDataset não encontrada\n');
    end
    
    if exist('img/original', 'dir')
        arquivos = dir('img/original/*.jpg');
        fprintf('  ✅ Diretório img/original encontrado (%d imagens)\n', length(arquivos));
    else
        fprintf('  ❌ Diretório img/original não encontrado\n');
    end
    
    if exist('img/masks', 'dir')
        arquivos = dir('img/masks/*.jpg');
        fprintf('  ✅ Diretório img/masks encontrado (%d máscaras)\n', length(arquivos));
    else
        fprintf('  ❌ Diretório img/masks não encontrado\n');
    end
end

%% ========================================================================
%% FUNÇÃO AUXILIAR: INSERIR TABELA NO ARTIGO
%% ========================================================================
function inserirTabelaNoArtigo(tabelaLatex)
    % Insere a tabela gerada no arquivo do artigo científico
    
    try
        arquivo_artigo = 'artigo_cientifico_corrosao.tex';
        
        if ~exist(arquivo_artigo, 'file')
            fprintf('   ⚠️ Arquivo do artigo não encontrado: %s\n', arquivo_artigo);
            return;
        end
        
        % Ler conteúdo atual do artigo
        fid = fopen(arquivo_artigo, 'r', 'n', 'UTF-8');
        if fid == -1
            error('Não foi possível abrir o arquivo do artigo');
        end
        conteudo = fread(fid, '*char')';
        fclose(fid);
        
        % Procurar por marcador da tabela ou seção de metodologia
        marcador_tabela = '% TABELA 1: CARACTERÍSTICAS DO DATASET';
        marcador_metodologia = '\section{Metodologia}';
        
        if contains(conteudo, marcador_tabela)
            % Substituir tabela existente
            inicio = strfind(conteudo, marcador_tabela);
            if ~isempty(inicio)
                % Encontrar fim da tabela anterior
                fim_tabela = strfind(conteudo(inicio:end), '\end{table}');
                if ~isempty(fim_tabela)
                    fim = inicio + fim_tabela(1) + length('\end{table}') - 1;
                    
                    % Substituir
                    novo_conteudo = [conteudo(1:inicio-1), ...
                                   sprintf('%s\n%s\n', marcador_tabela, tabelaLatex), ...
                                   conteudo(fim+1:end)];
                else
                    % Adicionar após marcador
                    novo_conteudo = strrep(conteudo, marcador_tabela, ...
                                         sprintf('%s\n%s', marcador_tabela, tabelaLatex));
                end
            end
        elseif contains(conteudo, marcador_metodologia)
            % Inserir após seção de metodologia
            pos = strfind(conteudo, marcador_metodologia);
            if ~isempty(pos)
                % Encontrar fim da linha
                fim_linha = strfind(conteudo(pos:end), sprintf('\n'));
                if ~isempty(fim_linha)
                    pos_insercao = pos + fim_linha(1);
                    
                    novo_conteudo = [conteudo(1:pos_insercao-1), ...
                                   sprintf('\n%s\n%s\n', marcador_tabela, tabelaLatex), ...
                                   conteudo(pos_insercao:end)];
                else
                    novo_conteudo = conteudo;
                end
            else
                novo_conteudo = conteudo;
            end
        else
            % Adicionar no final do documento (antes de \end{document})
            pos_fim = strfind(conteudo, '\end{document}');
            if ~isempty(pos_fim)
                novo_conteudo = [conteudo(1:pos_fim(1)-1), ...
                               sprintf('\n%s\n%s\n\n', marcador_tabela, tabelaLatex), ...
                               conteudo(pos_fim(1):end)];
            else
                novo_conteudo = [conteudo, sprintf('\n\n%s\n%s\n', marcador_tabela, tabelaLatex)];
            end
        end
        
        % Salvar arquivo atualizado
        fid = fopen(arquivo_artigo, 'w', 'n', 'UTF-8');
        if fid == -1
            error('Não foi possível escrever no arquivo do artigo');
        end
        fprintf(fid, '%s', novo_conteudo);
        fclose(fid);
        
        fprintf('   ✅ Tabela inserida no artigo: %s\n', arquivo_artigo);
        
    catch ME
        fprintf('   ⚠️ Erro ao inserir tabela no artigo: %s\n', ME.message);
    end
end