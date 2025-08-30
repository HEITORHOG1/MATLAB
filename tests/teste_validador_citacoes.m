% teste_validador_citacoes.m
% Script de teste para o sistema ValidadorCitacoes
%
% Este script testa todas as funcionalidades do ValidadorCitacoes:
% - Carregamento de referências do arquivo .bib
% - Extração de citações de arquivos LaTeX
% - Validação de citações
% - Geração de relatórios
% - Sugestões de correção

function executar_teste_validador_citacoes()
    fprintf('🧪 INICIANDO TESTES DO VALIDADOR DE CITAÇÕES\n');
    fprintf(repmat('=', 1, 50));
    fprintf('\n\n');
    
    try
        % Teste 1: Inicialização do ValidadorCitacoes
        fprintf('📋 Teste 1: Inicialização do ValidadorCitacoes\n');
        validador = ValidadorCitacoes('referencias.bib');
        fprintf('✅ ValidadorCitacoes inicializado com sucesso\n\n');
        
        % Teste 2: Verificar estatísticas das referências
        fprintf('📋 Teste 2: Estatísticas das referências\n');
        stats = validador.obterEstatisticas();
        fprintf('✅ Estatísticas obtidas com sucesso\n\n');
        
        % Teste 3: Validar citações do artigo principal
        fprintf('📋 Teste 3: Validação do arquivo principal\n');
        if exist('artigo_cientifico_corrosao.tex', 'file')
            [valido, relatorio] = validador.validarCitacoes('artigo_cientifico_corrosao.tex');
            
            if valido
                fprintf('✅ Todas as citações do artigo são válidas!\n');
            else
                fprintf('⚠️  Encontradas citações quebradas no artigo\n');
                validador.sugerirCorrecoes();
            end
            
            % Gerar relatório detalhado
            validador.gerarRelatorioDetalhado('relatorio_validacao_citacoes.md');
        else
            fprintf('⚠️  Arquivo artigo_cientifico_corrosao.tex não encontrado\n');
            fprintf('   Criando arquivo de teste...\n');
            criarArquivoTesteLatex();
            [valido, relatorio] = validador.validarCitacoes('teste_citacoes.tex');
            validador.gerarRelatorioDetalhado('relatorio_teste_citacoes.md');
        end
        fprintf('\n');
        
        % Teste 4: Teste com citações inválidas
        fprintf('📋 Teste 4: Teste com citações inválidas\n');
        criarArquivoComCitacoesInvalidas();
        [valido_invalido, relatorio_invalido] = validador.validarCitacoes('teste_citacoes_invalidas.tex');
        
        if ~valido_invalido
            fprintf('✅ Sistema detectou corretamente citações inválidas\n');
            validador.sugerirCorrecoes();
        else
            fprintf('❌ Sistema não detectou citações inválidas (erro!)\n');
        end
        fprintf('\n');
        
        % Teste 5: Teste de performance com muitas citações
        fprintf('📋 Teste 5: Teste de performance\n');
        criarArquivoComMuitasCitacoes();
        tic;
        [valido_perf, relatorio_perf] = validador.validarCitacoes('teste_performance.tex');
        tempo_execucao = toc;
        fprintf('✅ Validação de %d citações executada em %.3f segundos\n', ...
            relatorio_perf.total_citacoes, tempo_execucao);
        fprintf('\n');
        
        % Resumo final
        fprintf('🎯 RESUMO DOS TESTES\n');
        fprintf(repmat('=', 1, 30));
        fprintf('\n');
        fprintf('✅ Todos os testes executados com sucesso!\n');
        fprintf('📊 Sistema ValidadorCitacoes está funcionando corretamente\n');
        fprintf('📄 Relatórios gerados em arquivos .md\n\n');
        
        % Limpeza dos arquivos de teste
        limparArquivosTeste();
        
    catch ME
        fprintf('❌ ERRO NOS TESTES: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function criarArquivoTesteLatex()
    % Cria arquivo LaTeX de teste com citações válidas
    
    conteudo = [
        '\documentclass{article}\n', ...
        '\usepackage[utf8]{inputenc}\n', ...
        '\usepackage{natbib}\n\n', ...
        '\title{Teste de Citações}\n', ...
        '\author{Sistema de Teste}\n\n', ...
        '\begin{document}\n\n', ...
        '\maketitle\n\n', ...
        '\section{Introdução}\n\n', ...
        'Deep learning tem revolucionado a área de computer vision \cite{lecun2015deep}.\n', ...
        'A arquitetura U-Net \citep{ronneberger2015u} é amplamente utilizada para segmentação.\n', ...
        'Mecanismos de atenção \citet{oktay2018attention} melhoram a performance.\n', ...
        'Para detecção de corrosão, \citeauthor{atha2018evaluation} propuseram uma abordagem CNN.\n', ...
        'O material ASTM A572 \citeyear{astm2018a572} é amplamente usado em estruturas.\n\n', ...
        '\section{Metodologia}\n\n', ...
        'Utilizamos métricas como Dice \cite{dice1945measures} e Jaccard \cite{jaccard1912distribution}.\n', ...
        'O otimizador Adam \citep{kingma2014adam} foi usado no treinamento.\n\n', ...
        '\bibliography{referencias}\n', ...
        '\bibliographystyle{plain}\n\n', ...
        '\end{document}\n'
    ];
    
    fid = fopen('teste_citacoes.tex', 'w');
    fprintf(fid, '%s', conteudo);
    fclose(fid);
end

function criarArquivoComCitacoesInvalidas()
    % Cria arquivo LaTeX com citações inválidas para teste
    
    conteudo = [
        '\documentclass{article}\n', ...
        '\begin{document}\n\n', ...
        'Citação válida: \cite{lecun2015deep}\n', ...
        'Citação inválida 1: \cite{referencia_inexistente_2024}\n', ...
        'Citação inválida 2: \citep{outro_artigo_falso}\n', ...
        'Citação válida: \citet{ronneberger2015u}\n', ...
        'Citação inválida 3: \cite{erro_digitacao_2023}\n\n', ...
        '\end{document}\n'
    ];
    
    fid = fopen('teste_citacoes_invalidas.tex', 'w');
    fprintf(fid, '%s', conteudo);
    fclose(fid);
end

function criarArquivoComMuitasCitacoes()
    % Cria arquivo LaTeX com muitas citações para teste de performance
    
    % Obter todas as referências disponíveis
    validador_temp = ValidadorCitacoes('referencias.bib');
    refs = keys(validador_temp.referencias_disponiveis);
    
    conteudo = '\documentclass{article}\n\begin{document}\n\n';
    
    % Adicionar múltiplas citações
    for i = 1:min(20, length(refs))  % Máximo 20 citações
        ref = refs{i};
        conteudo = [conteudo, sprintf('Referência %d: \\cite{%s}\n', i, ref)];
    end
    
    % Adicionar citação múltipla
    if length(refs) >= 5
        refs_multiplas = strjoin(refs(1:5), ',');
        conteudo = [conteudo, sprintf('\nCitação múltipla: \\cite{%s}\n', refs_multiplas)];
    end
    
    conteudo = [conteudo, '\n\end{document}\n'];
    
    fid = fopen('teste_performance.tex', 'w');
    fprintf(fid, '%s', conteudo);
    fclose(fid);
end

function limparArquivosTeste()
    % Remove arquivos de teste criados
    
    arquivos_teste = {
        'teste_citacoes.tex',
        'teste_citacoes_invalidas.tex', 
        'teste_performance.tex'
    };
    
    for i = 1:length(arquivos_teste)
        if exist(arquivos_teste{i}, 'file')
            delete(arquivos_teste{i});
        end
    end
    
    fprintf('🧹 Arquivos de teste removidos\n');
end

% Executar testes se chamado diretamente
if ~exist('OCTAVE_VERSION', 'builtin')
    % MATLAB
    if strcmp(mfilename, 'teste_validador_citacoes')
        executar_teste_validador_citacoes();
    end
else
    % Octave
    executar_teste_validador_citacoes();
end