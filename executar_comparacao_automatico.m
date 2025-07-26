function executar_comparacao_automatico()
    % ========================================================================
    % SCRIPT PRINCIPAL AUTOMATICO: COMPARACAO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 1.2 Final - Modo Automático
    %
    % DESCRIÇÃO:
    %   Script automático para comparação entre U-Net clássica e Attention U-Net
    %   Executa automaticamente sem interação do usuário
    %
    % USO:
    %   >> executar_comparacao_automatico()
    %
    % ========================================================================
    
    % Adicionar pasta atual e subdiretórios ao path do MATLAB
    pasta_atual = pwd;
    addpath(pasta_atual);
    addpath(fullfile(pasta_atual, 'scripts'));
    addpath(fullfile(pasta_atual, 'utils'));
    addpath(fullfile(pasta_atual, 'legacy'));
    
    clc;
    fprintf('=====================================\n');
    fprintf('   COMPARACAO U-NET vs ATTENTION U-NET\n');
    fprintf('      Script Automatico (Modo Batch)   \n');
    fprintf('      (Versão 1.2 - Corrigida)        \n');
    fprintf('=====================================\n\n');
    
    % Configurar caminhos automaticamente
    fprintf('=== CONFIGURACAO AUTOMATICA ===\n');
    try
        config = configurar_caminhos_automatico();
        fprintf('✓ Configuração realizada com sucesso!\n\n');
    catch ME
        fprintf('❌ Erro na configuração: %s\n', ME.message);
        
        % Tentar configuração manual como fallback
        fprintf('Tentando usar configuração existente...\n');
        if exist('config_caminhos.mat', 'file')
            load('config_caminhos.mat', 'config');
            fprintf('✓ Configuração carregada do arquivo existente\n');
        else
            error('Não foi possível configurar os caminhos automaticamente');
        end
    end
    
    % Executar teste básico dos dados
    fprintf('=== TESTE DOS DADOS ===\n');
    try
        teste_dados_segmentacao(config);
        fprintf('✓ Teste dos dados concluído!\n\n');
    catch ME
        fprintf('⚠️  Erro no teste dos dados: %s\n', ME.message);
        fprintf('Continuando mesmo assim...\n\n');
    end
    
    % Executar teste rápido
    fprintf('=== TESTE RAPIDO U-NET ===\n');
    try
        treinar_unet_simples(config);
        fprintf('✓ Teste rápido concluído!\n\n');
    catch ME
        fprintf('❌ Erro no teste rápido: %s\n', ME.message);
        fprintf('Continuando para comparação completa...\n\n');
    end
    
    % Executar comparação completa
    fprintf('=== COMPARACAO COMPLETA ===\n');
    try
        comparacao_unet_attention_final(config);
        fprintf('✓ Comparação completa concluída!\n\n');
    catch ME
        fprintf('❌ Erro na comparação completa: %s\n', ME.message);
        
        % Tentar executar cada parte separadamente
        fprintf('Tentando executar partes separadamente...\n');
        
        try
            fprintf('Executando teste de Attention U-Net...\n');
            teste_attention_unet_real();
            fprintf('✓ Teste Attention U-Net concluído!\n');
        catch ME2
            fprintf('❌ Erro no teste Attention U-Net: %s\n', ME2.message);
        end
    end
    
    fprintf('=====================================\n');
    fprintf('   EXECUCAO AUTOMATICA FINALIZADA     \n');
    fprintf('=====================================\n');
    
    % Mostrar resumo dos resultados disponíveis
    mostrar_resumo_resultados();
end

function mostrar_resumo_resultados()
    % Mostrar resumo dos arquivos de resultado disponíveis
    
    fprintf('\n=== RESUMO DOS RESULTADOS ===\n');
    
    % Verificar arquivos de resultado
    arquivos_resultado = {
        'config_caminhos.mat', 'Configuração dos caminhos';
        'modelo_unet.mat', 'Modelo U-Net treinado';
        'modelo_attention_unet.mat', 'Modelo Attention U-Net treinado';
        'resultados_comparacao.mat', 'Resultados da comparação';
        'metricas_teste_simples.mat', 'Métricas do teste simples';
        'unet_simples_teste.mat', 'Modelo U-Net teste simples'
    };
    
    fprintf('Arquivos disponíveis:\n');
    for i = 1:size(arquivos_resultado, 1)
        arquivo = arquivos_resultado{i, 1};
        descricao = arquivos_resultado{i, 2};
        
        if exist(arquivo, 'file')
            fprintf('  ✓ %s - %s\n', arquivo, descricao);
        else
            fprintf('  ❌ %s - %s (não encontrado)\n', arquivo, descricao);
        end
    end
    
    fprintf('\n');
    
    % Verificar diretório de saída
    if exist('output', 'dir')
        output_files = dir('output/*.png');
        if ~isempty(output_files)
            fprintf('Visualizações disponíveis em output/:\n');
            for i = 1:min(5, length(output_files))
                fprintf('  📊 %s\n', output_files(i).name);
            end
            if length(output_files) > 5
                fprintf('  ... e mais %d arquivos\n', length(output_files) - 5);
            end
        end
    end
    
    fprintf('========================================\n');
end
