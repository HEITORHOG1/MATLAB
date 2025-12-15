% ========================================================================
% VALIDAÇÃO TASK 4 - IMPLEMENTAR GERAÇÃO DO TÍTULO E METADADOS
% ========================================================================
% 
% AUTOR: Heitor Oliveira Gonçalves
% Data: Agosto 2025
%
% DESCRIÇÃO:
%   Script para validar se a Task 4 foi completamente implementada
%   conforme os requisitos especificados
% ========================================================================

clear; clc;

fprintf('=== VALIDAÇÃO TASK 4: TÍTULO E METADADOS ===\n');
fprintf('Data: %s\n', datestr(now));

% Critérios de validação baseados nos sub-tasks
criterios = struct();
criterios.titulo_completo = false;
criterios.titulo_otimizado = false;
criterios.autores_definidos = false;
criterios.afiliacoes_completas = false;
criterios.resumo_estruturado = false;
criterios.palavras_chave_tecnicas = false;

try
    fprintf('\n1. Verificando arquivo LaTeX...\n');
    
    % Ler arquivo LaTeX
    arquivo_latex = 'artigo_cientifico_corrosao.tex';
    if ~exist(arquivo_latex, 'file')
        error('Arquivo LaTeX não encontrado: %s', arquivo_latex);
    end
    
    conteudo = fileread(arquivo_latex);
    
    % Sub-task 1: Título completo, objetivo e preciso
    fprintf('\n--- Sub-task 1: Título completo e otimizado ---\n');
    
    % Extrair título
    titulo_match = regexp(conteudo, '\\title\{([^}]+)\}', 'tokens');
    if ~isempty(titulo_match)
        titulo = titulo_match{1}{1};
        fprintf('Título encontrado: %s\n', titulo);
        
        % Verificar critérios do título
        tem_deteccao = contains(lower(titulo), 'detecção');
        tem_corrosao = contains(lower(titulo), 'corrosão');
        tem_astm = contains(lower(titulo), 'astm');
        tem_unet = contains(lower(titulo), 'u-net');
        tem_attention = contains(lower(titulo), 'attention');
        comprimento_ok = length(titulo) <= 150;
        
        criterios.titulo_completo = tem_deteccao && tem_corrosao && tem_astm;
        criterios.titulo_otimizado = tem_unet && tem_attention && comprimento_ok;
        
        fprintf('  ✓ Contém "detecção": %s\n', mat2str(tem_deteccao));
        fprintf('  ✓ Contém "corrosão": %s\n', mat2str(tem_corrosao));
        fprintf('  ✓ Contém "ASTM": %s\n', mat2str(tem_astm));
        fprintf('  ✓ Contém "U-Net": %s\n', mat2str(tem_unet));
        fprintf('  ✓ Contém "Attention": %s\n', mat2str(tem_attention));
        fprintf('  ✓ Comprimento adequado (≤150): %s (%d chars)\n', mat2str(comprimento_ok), length(titulo));
    else
        fprintf('  ❌ Título não encontrado\n');
    end
    
    % Sub-task 2: Autores e afiliações
    fprintf('\n--- Sub-task 2: Autores e afiliações ---\n');
    
    % Verificar seção de autores
    tem_autor_principal = contains(conteudo, 'Heitor Oliveira Gonçalves');
    tem_email_correspondente = contains(conteudo, '@');
    tem_multiplas_afiliacoes = contains(conteudo, 'Universidade Federal');
    tem_orcid = contains(conteudo, 'ORCID');
    
    criterios.autores_definidos = tem_autor_principal && tem_email_correspondente;
    criterios.afiliacoes_completas = tem_multiplas_afiliacoes && tem_orcid;
    
    fprintf('  ✓ Autor principal definido: %s\n', mat2str(tem_autor_principal));
    fprintf('  ✓ Email correspondente: %s\n', mat2str(tem_email_correspondente));
    fprintf('  ✓ Múltiplas afiliações: %s\n', mat2str(tem_multiplas_afiliacoes));
    fprintf('  ✓ ORCID incluído: %s\n', mat2str(tem_orcid));
    
    % Sub-task 3: Resumo estruturado
    fprintf('\n--- Sub-task 3: Resumo estruturado ---\n');
    
    % Verificar estrutura do resumo
    tem_objetivo = contains(conteudo, 'textbf{Objetivo:}');
    tem_metodologia = contains(conteudo, 'textbf{Metodologia:}');
    tem_resultados = contains(conteudo, 'textbf{Resultados:}');
    tem_conclusoes = contains(conteudo, 'textbf{Conclusões:}');
    tem_metricas = contains(conteudo, 'IoU') && contains(conteudo, 'Dice');
    tem_significancia = contains(conteudo, 'p <');
    
    criterios.resumo_estruturado = tem_objetivo && tem_metodologia && tem_resultados && tem_conclusoes && tem_metricas;
    
    fprintf('  ✓ Seção Objetivo: %s\n', mat2str(tem_objetivo));
    fprintf('  ✓ Seção Metodologia: %s\n', mat2str(tem_metodologia));
    fprintf('  ✓ Seção Resultados: %s\n', mat2str(tem_resultados));
    fprintf('  ✓ Seção Conclusões: %s\n', mat2str(tem_conclusoes));
    fprintf('  ✓ Métricas incluídas: %s\n', mat2str(tem_metricas));
    fprintf('  ✓ Significância estatística: %s\n', mat2str(tem_significancia));
    
    % Sub-task 4: Palavras-chave técnicas
    fprintf('\n--- Sub-task 4: Palavras-chave técnicas ---\n');
    
    % Verificar palavras-chave
    tem_palavras_chave_pt = contains(conteudo, 'textbf{Palavras-chave:}');
    tem_palavras_chave_en = contains(conteudo, 'textbf{Keywords:}');
    tem_deep_learning = contains(conteudo, 'Deep Learning');
    tem_segmentacao = contains(conteudo, 'Segmentação Semântica');
    tem_termos_tecnicos = contains(conteudo, 'Attention U-Net') && contains(conteudo, 'Redes Neurais');
    
    criterios.palavras_chave_tecnicas = tem_palavras_chave_pt && tem_palavras_chave_en && tem_deep_learning && tem_segmentacao;
    
    fprintf('  ✓ Palavras-chave em português: %s\n', mat2str(tem_palavras_chave_pt));
    fprintf('  ✓ Keywords em inglês: %s\n', mat2str(tem_palavras_chave_en));
    fprintf('  ✓ Contém "Deep Learning": %s\n', mat2str(tem_deep_learning));
    fprintf('  ✓ Contém "Segmentação Semântica": %s\n', mat2str(tem_segmentacao));
    fprintf('  ✓ Termos técnicos relevantes: %s\n', mat2str(tem_termos_tecnicos));
    
    % Verificar sistema de geração implementado
    fprintf('\n2. Verificando sistema de geração...\n');
    
    gerador_existe = exist('src/validation/GeradorMetadados.m', 'file');
    teste_existe = exist('teste_gerador_metadados.m', 'file');
    
    fprintf('  ✓ Classe GeradorMetadados: %s\n', mat2str(gerador_existe == 2));
    fprintf('  ✓ Script de teste: %s\n', mat2str(teste_existe == 2));
    
    % Resumo da validação
    fprintf('\n=== RESUMO DA VALIDAÇÃO ===\n');
    
    campos = fieldnames(criterios);
    total_criterios = length(campos);
    criterios_atendidos = 0;
    
    for i = 1:total_criterios
        campo = campos{i};
        atendido = criterios.(campo);
        criterios_atendidos = criterios_atendidos + atendido;
        
        status = '❌';
        if atendido
            status = '✅';
        end
        
        fprintf('%s %s\n', status, strrep(campo, '_', ' '));
    end
    
    percentual = (criterios_atendidos / total_criterios) * 100;
    
    fprintf('\nCritérios atendidos: %d/%d (%.1f%%)\n', criterios_atendidos, total_criterios, percentual);
    
    % Determinar status da task
    if percentual >= 90
        status_task = '✅ COMPLETA';
        fprintf('\n%s - Task 4 implementada com sucesso!\n', status_task);
    elseif percentual >= 70
        status_task = '⚠️ PARCIALMENTE COMPLETA';
        fprintf('\n%s - Task 4 precisa de ajustes menores.\n', status_task);
    else
        status_task = '❌ INCOMPLETA';
        fprintf('\n%s - Task 4 precisa de implementação adicional.\n', status_task);
    end
    
    % Verificar requisitos específicos (2.1, 2.2)
    fprintf('\n=== VERIFICAÇÃO DOS REQUISITOS ===\n');
    
    % Requisito 2.1: Título completo, objetivo, preciso e sintético
    req_2_1 = criterios.titulo_completo && criterios.titulo_otimizado;
    fprintf('Requisito 2.1 (Título): %s\n', mat2str(req_2_1));
    
    % Requisito 2.2: Resumo estruturado
    req_2_2 = criterios.resumo_estruturado;
    fprintf('Requisito 2.2 (Resumo): %s\n', mat2str(req_2_2));
    
    requisitos_ok = req_2_1 && req_2_2;
    fprintf('\nTodos os requisitos atendidos: %s\n', mat2str(requisitos_ok));
    
    if requisitos_ok
        fprintf('\n🎉 TASK 4 COMPLETAMENTE IMPLEMENTADA! 🎉\n');
        fprintf('Todos os sub-tasks foram executados conforme especificado.\n');
    else
        fprintf('\n⚠️ Alguns requisitos ainda precisam ser atendidos.\n');
    end
    
catch ME
    fprintf('❌ ERRO NA VALIDAÇÃO: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n=== FIM DA VALIDAÇÃO ===\n');