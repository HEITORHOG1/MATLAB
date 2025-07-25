function remover_arquivos_obsoletos()
% REMOVER_ARQUIVOS_OBSOLETOS - Remove arquivos duplicados e obsoletos
%
% Esta função remove arquivos identificados como duplicados ou obsoletos
% conforme especificado no documento de design.
%
% Referência: Tutorial MATLAB File Management
% https://www.mathworks.com/help/matlab/ref/delete.html

    fprintf('=== REMOVENDO ARQUIVOS OBSOLETOS ===\n\n');
    
    % Lista de arquivos duplicados/obsoletos para remover
    arquivos_obsoletos = {
        'README_CONFIGURACAO.md',
        'GUIA_CONFIGURACAO.md', 
        'STATUS_FINAL.md',
        'CORRECAO_CRITICA_CONCLUIDA.md'
    };
    
    % Remover arquivos obsoletos
    fprintf('Removendo arquivos duplicados/obsoletos:\n');
    for i = 1:length(arquivos_obsoletos)
        arquivo = arquivos_obsoletos{i};
        
        if exist(arquivo, 'file')
            try
                delete(arquivo);
                fprintf('  ✓ Removido: %s\n', arquivo);
            catch ME
                fprintf('  ❌ Erro ao remover %s: %s\n', arquivo, ME.message);
            end
        else
            fprintf('  → %s (não encontrado)\n', arquivo);
        end
    end
    
    % Identificar arquivos de teste similares para consolidação
    fprintf('\nIdentificando arquivos de teste para consolidação:\n');
    
    arquivos_teste = {
        'teste_treinamento_rapido.m',
        'teste_final_integridade.m', 
        'teste_projeto_automatizado.m',
        'teste_problemas_especificos.m',
        'teste_dados_segmentacao.m',
        'teste_attention_unet_real.m',
        'teste_correcao_critica.m'
    };
    
    % Mover arquivos de teste para diretório apropriado
    fprintf('\nMovendo arquivos de teste para tests/:\n');
    for i = 1:length(arquivos_teste)
        arquivo = arquivos_teste{i};
        destino = fullfile('tests', arquivo);
        
        if exist(arquivo, 'file')
            try
                movefile(arquivo, destino);
                fprintf('  ✓ Movido: %s → %s\n', arquivo, destino);
            catch ME
                fprintf('  ❌ Erro ao mover %s: %s\n', arquivo, ME.message);
            end
        else
            fprintf('  → %s (não encontrado)\n', arquivo);
        end
    end
    
    % Identificar outros arquivos duplicados
    fprintf('\nVerificando outros arquivos duplicados:\n');
    
    % Verificar se há múltiplos READMEs
    readme_files = dir('README*.md');
    if length(readme_files) > 1
        fprintf('  ⚠️  Encontrados múltiplos arquivos README:\n');
        for i = 1:length(readme_files)
            fprintf('    - %s\n', readme_files(i).name);
        end
    end
    
    fprintf('\n=== LIMPEZA CONCLUÍDA ===\n');
    
    % Criar relatório de limpeza
    criar_relatorio_limpeza(arquivos_obsoletos, arquivos_teste);
end

function criar_relatorio_limpeza(removidos, movidos)
% Criar relatório da limpeza realizada
    
    relatorio = sprintf(['# Relatório de Limpeza do Projeto\n\n' ...
        'Data: %s\n\n' ...
        '## Arquivos Removidos\n\n'], datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    
    for i = 1:length(removidos)
        relatorio = [relatorio sprintf('- %s (duplicado/obsoleto)\n', removidos{i})];
    end
    
    relatorio = [relatorio sprintf('\n## Arquivos Movidos\n\n')];
    
    for i = 1:length(movidos)
        relatorio = [relatorio sprintf('- %s → tests/%s\n', movidos{i}, movidos{i})];
    end
    
    relatorio = [relatorio sprintf(['\n## Próximos Passos\n\n' ...
        '1. Consolidar funcionalidades dos arquivos de teste em TestSuite.m\n' ...
        '2. Atualizar documentação principal (README.md)\n' ...
        '3. Criar docs/user_guide.md com instruções detalhadas\n'])];
    
    % Salvar relatório
    fid = fopen('output/reports/relatorio_limpeza.md', 'w', 'n', 'UTF-8');
    if fid ~= -1
        fprintf(fid, '%s', relatorio);
        fclose(fid);
        fprintf('\n✓ Relatório salvo em: output/reports/relatorio_limpeza.md\n');
    end
end