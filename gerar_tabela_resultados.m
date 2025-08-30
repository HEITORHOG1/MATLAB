function sucesso = gerar_tabela_resultados()
    % ========================================================================
    % GERADOR DE TABELA DE RESULTADOS QUANTITATIVOS COMPARATIVOS
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Agosto 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Script principal para gerar tabela científica com resultados 
    %   quantitativos comparativos entre U-Net e Attention U-Net
    %
    % FUNCIONALIDADES:
    %   - Extração de dados experimentais dos arquivos .mat
    %   - Cálculo de estatísticas descritivas completas
    %   - Análise estatística comparativa (teste t-student)
    %   - Geração de tabela LaTeX formatada para artigo científico
    %   - Geração de relatório em texto simples
    %
    % SAÍDAS:
    %   - tabelas/tabela_resultados_quantitativos.tex (LaTeX)
    %   - tabelas/relatorio_tabela_resultados_quantitativos.txt (Texto)
    %   - tabelas/dados_tabela_resultados_quantitativos.mat (Dados)
    % ========================================================================
    
    try
        fprintf('\n========================================================================\n');
        fprintf('GERADOR DE TABELA DE RESULTADOS QUANTITATIVOS COMPARATIVOS\n');
        fprintf('========================================================================\n');
        fprintf('Projeto: Detecção de Corrosão com U-Net vs Attention U-Net\n');
        fprintf('Autor: Heitor Oliveira Gonçalves\n');
        fprintf('Data: %s\n', datestr(now, 'dd/mm/yyyy HH:MM:SS'));
        fprintf('========================================================================\n');
        
        % Adicionar caminhos necessários
        addpath('src/validation');
        addpath('utils');
        
        % Verificar dependências
        fprintf('\n🔍 Verificando dependências...\n');
        verificarDependencias();
        
        % Inicializar gerador
        fprintf('\n🚀 Inicializando gerador de tabela...\n');
        gerador = GeradorTabelaResultados('verbose', true);
        
        % Gerar tabela completa
        fprintf('\n📊 Gerando tabela de resultados quantitativos...\n');
        sucesso = gerador.gerarTabelaCompleta();
        
        if sucesso
            % Exibir resumo
            gerador.exibirResumo();
            
            % Verificar arquivos gerados
            verificarArquivosGerados();
            
            fprintf('\n========================================================================\n');
            fprintf('✅ TABELA DE RESULTADOS QUANTITATIVOS GERADA COM SUCESSO!\n');
            fprintf('========================================================================\n');
            fprintf('\nArquivos gerados:\n');
            fprintf('📄 LaTeX: tabelas/tabela_resultados_quantitativos.tex\n');
            fprintf('📄 Texto: tabelas/relatorio_tabela_resultados_quantitativos.txt\n');
            fprintf('💾 Dados: tabelas/dados_tabela_resultados_quantitativos.mat\n');
            fprintf('\n💡 A tabela está pronta para inclusão no artigo científico!\n');
            fprintf('========================================================================\n');
        else
            error('Falha na geração da tabela de resultados quantitativos');
        end
        
    catch ME
        fprintf('\n❌ ERRO na geração da tabela: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        sucesso = false;
    end
end

function verificarDependencias()
    % Verifica se todas as dependências estão disponíveis
    
    dependencias = {
        'src/validation/GeradorTabelaResultados.m'
        'utils/analise_estatistica_comparativa.m'
    };
    
    for i = 1:length(dependencias)
        if ~exist(dependencias{i}, 'file')
            error('Dependência não encontrada: %s', dependencias{i});
        end
    end
    
    fprintf('   ✅ Todas as dependências encontradas\n');
    
    % Verificar se diretório de saída existe
    if ~exist('tabelas', 'dir')
        mkdir('tabelas');
        fprintf('   📁 Diretório "tabelas" criado\n');
    end
end

function verificarArquivosGerados()
    % Verifica se todos os arquivos foram gerados corretamente
    
    arquivos_esperados = {
        'tabelas/tabela_resultados_quantitativos.tex'
        'tabelas/relatorio_tabela_resultados_quantitativos.txt'
        'tabelas/dados_tabela_resultados_quantitativos.mat'
    };
    
    fprintf('\n📋 Verificando arquivos gerados:\n');
    
    for i = 1:length(arquivos_esperados)
        arquivo = arquivos_esperados{i};
        if exist(arquivo, 'file')
            info = dir(arquivo);
            fprintf('   ✅ %s (%.1f KB)\n', arquivo, info.bytes/1024);
        else
            fprintf('   ❌ %s (não encontrado)\n', arquivo);
        end
    end
end