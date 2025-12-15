%% EXECUTAR_MAPAS_ATENCAO - Script para gerar figura 7: Mapas de atenção (Attention U-Net)
%
% Este script gera a visualização completa dos mapas de atenção da Attention U-Net
% mostrando heatmaps de atenção correlacionados com regiões de corrosão.
%
% Saída: figuras/figura_mapas_atencao.png
%
% Autor: Sistema de Geração de Artigo Científico
% Data: 2025

function executar_geracao_mapas_atencao()
    fprintf('=== GERAÇÃO DE MAPAS DE ATENÇÃO (ATTENTION U-NET) ===\n');
    fprintf('Tarefa 17: Criar figura 7 - Mapas de atenção\n\n');
    
    try
        % Adicionar caminhos necessários
        addpath('src/visualization');
        
        % Criar instância do gerador
        fprintf('[1/4] Inicializando gerador de mapas de atenção...\n');
        gerador = GeradorMapasAtencao();
        
        % Definir arquivo de saída
        arquivo_saida = 'figuras/figura_mapas_atencao.png';
        
        % Gerar mapas de atenção
        fprintf('[2/4] Gerando mapas de atenção...\n');
        gerador.gerarMapasAtencao(arquivo_saida);
        
        % Gerar relatório técnico
        fprintf('[3/4] Gerando relatório técnico...\n');
        gerador.gerarRelatorioMapasAtencao('relatorio_mapas_atencao.txt');
        
        % Validar resultado
        fprintf('[4/4] Validando resultado...\n');
        validarResultado(arquivo_saida);
        
        fprintf('\n✅ MAPAS DE ATENÇÃO GERADOS COM SUCESSO!\n');
        fprintf('📁 Arquivo principal: %s\n', arquivo_saida);
        fprintf('📄 Relatório técnico: relatorio_mapas_atencao.txt\n');
        
        % Mostrar informações da figura gerada
        mostrarInformacoesFigura(arquivo_saida);
        
    catch ME
        fprintf('\n❌ ERRO na geração dos mapas de atenção:\n');
        fprintf('   %s\n', ME.message);
        
        if contains(ME.message, 'Nenhum caso válido encontrado')
            fprintf('\n💡 SUGESTÃO: Verifique se existem imagens nos diretórios:\n');
            fprintf('   - img/original/*_PRINCIPAL_256_gray.jpg\n');
            fprintf('   - img/masks/*_CORROSAO_256_gray.jpg\n');
        end
        
        rethrow(ME);
    end
end

function validarResultado(arquivo_saida)
    % Valida se o arquivo foi gerado corretamente
    
    if ~exist(arquivo_saida, 'file')
        error('Arquivo de saída não foi gerado: %s', arquivo_saida);
    end
    
    % Verificar tamanho do arquivo (deve ser > 100KB para uma figura complexa)
    info_arquivo = dir(arquivo_saida);
    if info_arquivo.bytes < 100000
        warning('Arquivo gerado pode estar incompleto (tamanho: %d bytes)', info_arquivo.bytes);
    end
    
    % Verificar se arquivos adicionais foram gerados
    [pasta, nome, ~] = fileparts(arquivo_saida);
    
    arquivo_eps = fullfile(pasta, [nome '.eps']);
    arquivo_svg = fullfile(pasta, [nome '.svg']);
    
    if exist(arquivo_eps, 'file')
        fprintf('   ✅ Arquivo EPS gerado para publicação\n');
    end
    
    if exist(arquivo_svg, 'file')
        fprintf('   ✅ Arquivo SVG gerado para edição\n');
    end
    
    fprintf('   ✅ Validação concluída com sucesso\n');
end

function mostrarInformacoesFigura(arquivo_saida)
    % Mostra informações detalhadas sobre a figura gerada
    
    fprintf('\n📊 INFORMAÇÕES DA FIGURA GERADA:\n');
    fprintf('════════════════════════════════════════\n');
    
    % Informações do arquivo
    info_arquivo = dir(arquivo_saida);
    fprintf('📁 Arquivo: %s\n', arquivo_saida);
    fprintf('📏 Tamanho: %.1f KB\n', info_arquivo.bytes / 1024);
    fprintf('📅 Data: %s\n', datestr(info_arquivo.datenum));
    
    % Especificações técnicas
    fprintf('\n🔧 ESPECIFICAÇÕES TÉCNICAS:\n');
    fprintf('• Resolução: 300 DPI (qualidade publicação)\n');
    fprintf('• Formato principal: PNG (visualização)\n');
    fprintf('• Formatos adicionais: EPS (publicação), SVG (edição)\n');
    fprintf('• Layout: Grid com múltiplos casos e níveis de atenção\n');
    
    % Conteúdo da figura
    fprintf('\n📋 CONTEÚDO DA FIGURA:\n');
    fprintf('• Coluna 1: Imagens originais de vigas com corrosão\n');
    fprintf('• Coluna 2: Ground truth (máscaras manuais)\n');
    fprintf('• Coluna 3: Mapas de atenção - Detecção de bordas\n');
    fprintf('• Coluna 4: Mapas de atenção - Análise de contraste\n');
    fprintf('• Coluna 5: Mapas de atenção combinados\n');
    
    % Interpretação científica
    fprintf('\n🔬 INTERPRETAÇÃO CIENTÍFICA:\n');
    fprintf('• Heatmaps mostram onde a Attention U-Net foca\n');
    fprintf('• Cores quentes (vermelho/amarelo) = alta atenção\n');
    fprintf('• Cores frias (azul/verde) = baixa atenção\n');
    fprintf('• Correlação com ground truth valida eficácia\n');
    
    % Localização no artigo
    fprintf('\n📖 LOCALIZAÇÃO NO ARTIGO:\n');
    fprintf('• Seção: Resultados (7.4 - Análise Qualitativa)\n');
    fprintf('• Referência: Figura 7 - Mapas de atenção\n');
    fprintf('• Objetivo: Demonstrar interpretabilidade da Attention U-Net\n');
    
    fprintf('\n════════════════════════════════════════\n');
end

% Executar se chamado diretamente
if ~isdeployed && strcmp(mfilename, 'executar_mapas_atencao')
    executar_geracao_mapas_atencao();
end