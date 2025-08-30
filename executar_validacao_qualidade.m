function resultado = executar_validacao_qualidade()
    % executar_validacao_qualidade - Executa validação completa de qualidade científica
    %
    % Este script executa o sistema de validação de qualidade I-R-B-MB-E
    % para o artigo científico sobre detecção de corrosão
    %
    % Output:
    %   resultado - Estrutura com resultados da validação
    
    try
        fprintf('=== SISTEMA DE VALIDAÇÃO DE QUALIDADE CIENTÍFICA ===\n');
        fprintf('Artigo: Detecção Automatizada de Corrosão em Vigas W ASTM A572 Grau 50\n\n');
        
        % Verificar se arquivos existem
        arquivo_artigo = 'artigo_cientifico_corrosao.tex';
        arquivo_referencias = 'referencias.bib';
        
        if ~exist(arquivo_artigo, 'file')
            error('Arquivo do artigo não encontrado: %s', arquivo_artigo);
        end
        
        if ~exist(arquivo_referencias, 'file')
            error('Arquivo de referências não encontrado: %s', arquivo_referencias);
        end
        
        % Criar instância do validador
        validador = ValidadorQualidadeCientifica();
        
        % Executar validação completa
        resultado = validador.validar_artigo_completo(arquivo_artigo, arquivo_referencias);
        
        % Exibir estatísticas finais
        fprintf('=== ESTATÍSTICAS FINAIS ===\n');
        fprintf('Arquivo validado: %s\n', arquivo_artigo);
        fprintf('Nível de qualidade alcançado: %s\n', resultado.nivel_geral);
        fprintf('Pontuação geral: %.2f/5.0\n', resultado.pontuacao_geral);
        
        % Determinar se artigo está pronto para publicação
        if strcmp(resultado.nivel_geral, 'E') || strcmp(resultado.nivel_geral, 'MB')
            fprintf('\n✓ ARTIGO APROVADO para submissão científica!\n');
        elseif strcmp(resultado.nivel_geral, 'B')
            fprintf('\n⚠ ARTIGO NECESSITA MELHORIAS antes da submissão\n');
        else
            fprintf('\n✗ ARTIGO REQUER REVISÃO SUBSTANCIAL\n');
        end
        
        fprintf('=======================================\n');
        
    catch ME
        fprintf('ERRO na execução da validação: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        
        resultado = struct();
        resultado.erro = true;
        resultado.mensagem = ME.message;
    end
end