function executar_limpeza_codigo()
    % ========================================================================
    % EXECUTAR LIMPEZA DE CÓDIGO
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Script para executar a limpeza automática do código base,
    %   removendo arquivos duplicados e obsoletos do projeto.
    %
    % USO:
    %   >> executar_limpeza_codigo()
    %
    % FUNCIONALIDADES:
    %   - Identifica arquivos duplicados e obsoletos
    %   - Cria backup antes da remoção
    %   - Remove arquivos desnecessários
    %   - Reorganiza estrutura de pastas
    %   - Gera relatório detalhado
    %
    % AUTOR: Sistema de Segmentação Completo
    % DATA: Agosto 2025
    % ========================================================================
    
    clc;
    fprintf('========================================\n');
    fprintf('        LIMPEZA DE CÓDIGO BASE\n');
    fprintf('   Sistema de Segmentação Completo\n');
    fprintf('========================================\n\n');
    
    % Adicionar path necessário
    addpath('src/limpeza');
    
    % Verificar se a classe existe
    if ~exist('LimpadorCodigo', 'file')
        error('Classe LimpadorCodigo não encontrada. Verifique se src/limpeza/LimpadorCodigo.m existe.');
    end
    
    try
        % Criar instância do limpador
        limpador = LimpadorCodigo();
        
        % Executar limpeza
        limpador.executarLimpeza();
        
        fprintf('\n🎉 PROCESSO DE LIMPEZA FINALIZADO!\n');
        fprintf('📄 Consulte o arquivo relatorio_limpeza.txt para detalhes\n');
        
    catch ME
        fprintf('\n❌ ERRO durante limpeza: %s\n', ME.message);
        fprintf('📍 Local: %s (linha %d)\n', ME.stack(1).name, ME.stack(1).line);
        
        % Mostrar stack trace completo se necessário
        if length(ME.stack) > 1
            fprintf('\nStack trace completo:\n');
            for i = 1:length(ME.stack)
                fprintf('  %d. %s (linha %d)\n', i, ME.stack(i).name, ME.stack(i).line);
            end
        end
        
        rethrow(ME);
    end
end