% ========================================================================
% TESTE DO GERADOR DE METADADOS - ARTIGO CIENTÍFICO
% ========================================================================
% 
% AUTOR: Heitor Oliveira Gonçalves
% Data: Agosto 2025
%
% DESCRIÇÃO:
%   Script para testar e validar a geração de metadados do artigo científico
% ========================================================================

clear; clc;

fprintf('=== TESTE DO GERADOR DE METADADOS ===\n');
fprintf('Data: %s\n', datestr(now));

try
    % Adicionar caminho das classes
    addpath('src/validation');
    
    % Criar instância do gerador
    fprintf('\n1. Inicializando GeradorMetadados...\n');
    gerador = GeradorMetadados('verbose', true);
    
    % Gerar metadados completos
    fprintf('\n2. Gerando metadados completos...\n');
    sucesso = gerador.gerarMetadadosCompletos();
    
    if sucesso
        fprintf('\n3. Validando resultados...\n');
        
        % Exibir título
        fprintf('\n--- TÍTULO ---\n');
        fprintf('Principal: %s\n', gerador.titulo.principal);
        fprintf('Curto: %s\n', gerador.titulo.curto);
        fprintf('Qualidade: %s\n', gerador.titulo.nivel_qualidade);
        
        % Exibir autores
        fprintf('\n--- AUTORES ---\n');
        fprintf('Total de autores: %d\n', gerador.autores.total);
        fprintf('Autor principal: %s\n', gerador.autores.principal.nome);
        fprintf('Email correspondente: %s\n', gerador.autores.principal.email);
        
        % Exibir resumo
        fprintf('\n--- RESUMO ---\n');
        fprintf('Comprimento: %d caracteres\n', length(gerador.resumo.completo));
        fprintf('Qualidade: %s\n', gerador.resumo.nivel_qualidade);
        
        % Exibir palavras-chave
        fprintf('\n--- PALAVRAS-CHAVE ---\n');
        fprintf('Quantidade (PT): %d\n', length(gerador.palavrasChave.portugues));
        fprintf('Quantidade (EN): %d\n', length(gerador.palavrasChave.ingles));
        fprintf('Qualidade: %s\n', gerador.palavrasChave.nivel_qualidade);
        
        % Qualidade geral
        fprintf('\n--- QUALIDADE GERAL ---\n');
        fprintf('Nível: %s\n', gerador.metadados.qualidade_geral);
        fprintf('Pontuação: %.1f/5.0\n', gerador.metadados.pontuacao);
        
        % Gerar relatório
        fprintf('\n4. Gerando relatório...\n');
        relatorio = gerador.gerarRelatorioMetadados();
        
        fprintf('\n✅ TESTE CONCLUÍDO COM SUCESSO!\n');
        fprintf('Qualidade alcançada: %s\n', gerador.metadados.qualidade_geral);
        
        % Verificar se atende aos requisitos (nível B ou superior)
        if ismember(gerador.metadados.qualidade_geral, {'B', 'MB', 'E'})
            fprintf('✅ Metadados atendem aos requisitos de qualidade.\n');
        else
            fprintf('⚠️ Metadados precisam de melhorias.\n');
        end
        
    else
        fprintf('❌ Falha na geração de metadados.\n');
    end
    
catch ME
    fprintf('❌ ERRO NO TESTE: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n=== FIM DO TESTE ===\n');