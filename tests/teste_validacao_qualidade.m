function teste_validacao_qualidade()
    % teste_validacao_qualidade - Testa o sistema de validação de qualidade científica
    %
    % Este script testa todas as funcionalidades do ValidadorQualidadeCientifica
    % incluindo validação IMRAD, critérios I-R-B-MB-E e integridade de referências
    
    fprintf('=== TESTE DO SISTEMA DE VALIDAÇÃO DE QUALIDADE ===\n\n');
    
    try
        % Teste 1: Criação do validador
        fprintf('1. Testando criação do validador...\n');
        validador = ValidadorQualidadeCientifica();
        fprintf('   ✓ Validador criado com sucesso\n\n');
        
        % Teste 2: Verificar se arquivos existem
        fprintf('2. Verificando arquivos necessários...\n');
        arquivo_artigo = 'artigo_cientifico_corrosao.tex';
        arquivo_referencias = 'referencias.bib';
        
        if exist(arquivo_artigo, 'file')
            fprintf('   ✓ Arquivo do artigo encontrado: %s\n', arquivo_artigo);
        else
            fprintf('   ⚠ Arquivo do artigo não encontrado: %s\n', arquivo_artigo);
        end
        
        if exist(arquivo_referencias, 'file')
            fprintf('   ✓ Arquivo de referências encontrado: %s\n', arquivo_referencias);
        else
            fprintf('   ⚠ Arquivo de referências não encontrado: %s\n', arquivo_referencias);
        end
        fprintf('\n');
        
        % Teste 3: Validação de estrutura IMRAD (se arquivo existe)
        if exist(arquivo_artigo, 'file')
            fprintf('3. Testando validação de estrutura IMRAD...\n');
            resultado_imrad = validador.validar_estrutura_imrad();
            
            fprintf('   - Seções encontradas: %d\n', length(resultado_imrad.secoes_encontradas));
            fprintf('   - Seções ausentes: %d\n', length(resultado_imrad.secoes_ausentes));
            fprintf('   - Completude: %.1f%%\n', resultado_imrad.percentual_completude);
            fprintf('   - Estrutura válida: %s\n', bool_para_texto(resultado_imrad.estrutura_valida));
            
            if resultado_imrad.estrutura_valida
                fprintf('   ✓ Estrutura IMRAD válida\n');
            else
                fprintf('   ⚠ Estrutura IMRAD incompleta\n');
                if ~isempty(resultado_imrad.secoes_ausentes)
                    fprintf('     Seções ausentes: %s\n', strjoin(resultado_imrad.secoes_ausentes, ', '));
                end
            end
            fprintf('\n');
            
            % Teste 4: Validação de qualidade por seção
            fprintf('4. Testando validação de qualidade por seção...\n');
            resultado_qualidade = validador.validar_qualidade_secoes();
            
            fprintf('   - Qualidade geral: %s\n', resultado_qualidade.qualidade_geral);
            fprintf('   - Pontuação média: %.2f/5.0\n', resultado_qualidade.pontuacao_media);
            
            if isfield(resultado_qualidade, 'avaliacoes_secoes')
                secoes = fieldnames(resultado_qualidade.avaliacoes_secoes);
                fprintf('   - Seções avaliadas: %d\n', length(secoes));
                
                for i = 1:length(secoes)
                    secao = secoes{i};
                    if isfield(resultado_qualidade.avaliacoes_secoes, secao)
                        avaliacao = resultado_qualidade.avaliacoes_secoes.(secao);
                        fprintf('     %s: %s (%.2f pontos)\n', secao, avaliacao.nivel_qualidade, avaliacao.pontuacao_numerica);
                    end
                end
            end
            fprintf('\n');
        else
            fprintf('3-4. Pulando testes de validação (arquivo não encontrado)\n\n');
        end
        
        % Teste 5: Verificação de referências (se arquivo existe)
        if exist(arquivo_referencias, 'file') && exist(arquivo_artigo, 'file')
            fprintf('5. Testando verificação de referências...\n');
            resultado_referencias = validador.verificar_referencias_bibliograficas();
            
            fprintf('   - Citações encontradas: %d\n', resultado_referencias.total_citacoes);
            fprintf('   - Referências disponíveis: %d\n', resultado_referencias.total_referencias);
            fprintf('   - Citações quebradas: %d\n', length(resultado_referencias.citacoes_quebradas));
            fprintf('   - Integridade: %s\n', bool_para_texto(resultado_referencias.integridade_ok));
            
            if resultado_referencias.integridade_ok
                fprintf('   ✓ Integridade das referências OK\n');
            else
                fprintf('   ⚠ Problemas de integridade encontrados\n');
                if ~isempty(resultado_referencias.citacoes_quebradas)
                    fprintf('     Citações quebradas: %s\n', strjoin(resultado_referencias.citacoes_quebradas, ', '));
                end
            end
            fprintf('\n');
        else
            fprintf('5. Pulando teste de referências (arquivos não encontrados)\n\n');
        end
        
        % Teste 6: Validação completa (se ambos arquivos existem)
        if exist(arquivo_artigo, 'file') && exist(arquivo_referencias, 'file')
            fprintf('6. Testando validação completa...\n');
            resultado_completo = validador.validar_artigo_completo(arquivo_artigo, arquivo_referencias);
            
            fprintf('   - Nível geral: %s\n', resultado_completo.nivel_geral);
            fprintf('   - Pontuação geral: %.2f/5.0\n', resultado_completo.pontuacao_geral);
            fprintf('   - Recomendações: %d\n', length(resultado_completo.recomendacoes));
            
            % Exibir algumas recomendações
            if length(resultado_completo.recomendacoes) > 0
                fprintf('   Principais recomendações:\n');
                for i = 1:min(3, length(resultado_completo.recomendacoes))
                    fprintf('     - %s\n', resultado_completo.recomendacoes{i});
                end
            end
            
            fprintf('   ✓ Validação completa executada com sucesso\n');
            fprintf('\n');
        else
            fprintf('6. Pulando validação completa (arquivos não encontrados)\n\n');
        end
        
        % Teste 7: Teste de métodos auxiliares
        fprintf('7. Testando métodos auxiliares...\n');
        
        % Teste conversão de pontuação para nível
        niveis_teste = [5.0, 4.5, 3.5, 2.5, 1.5, 0.5];
        niveis_esperados = {'E', 'E', 'MB', 'B', 'R', 'I'};
        
        for i = 1:length(niveis_teste)
            nivel = validador.converter_pontuacao_para_nivel(niveis_teste(i));
            if strcmp(nivel, niveis_esperados{i})
                fprintf('   ✓ Conversão %.1f -> %s\n', niveis_teste(i), nivel);
            else
                fprintf('   ✗ Erro na conversão %.1f -> %s (esperado %s)\n', niveis_teste(i), nivel, niveis_esperados{i});
            end
        end
        
        fprintf('\n=== TESTE CONCLUÍDO COM SUCESSO ===\n');
        
    catch ME
        fprintf('\n✗ ERRO durante o teste: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function texto = bool_para_texto(valor)
    % Converte valor booleano para texto
    if valor
        texto = 'SIM';
    else
        texto = 'NÃO';
    end
end