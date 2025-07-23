function inicio_rapido()
    % ========================================================================
    % INÍCIO RÁPIDO - Projeto U-Net vs Attention U-Net
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Função de início rápido que verifica a configuração e executa
    %   automaticamente os passos necessários.
    %
    % USO:
    %   >> inicio_rapido()
    %
    % VERSÃO: 1.0
    % DATA: Julho 2025
    % ========================================================================
    
    clc;
    fprintf('🚀 INÍCIO RÁPIDO - U-Net vs Attention U-Net\n');
    fprintf('==========================================\n\n');
    
    % Verificar se a configuração existe e é válida
    if exist('config_caminhos.mat', 'file')
        fprintf('✓ Configuração encontrada!\n');
        
        % Carregar e verificar
        load('config_caminhos.mat', 'config');
        
        if validar_configuracao_rapida(config)
            fprintf('✓ Configuração válida!\n');
            fprintf('  Imagens: %s\n', config.imageDir);
            fprintf('  Máscaras: %s\n\n', config.maskDir);
            
            % Contar arquivos
            contagem = contar_arquivos(config);
            fprintf('📊 Dados encontrados:\n');
            fprintf('   Imagens: %d arquivos\n', contagem.imagens);
            fprintf('   Máscaras: %d arquivos\n\n', contagem.mascaras);
            
            if contagem.imagens > 0 && contagem.mascaras > 0
                fprintf('🎯 Tudo pronto! Iniciando execução automática...\n\n');
                
                % Pausa para o usuário ver as informações
                fprintf('Pressione qualquer tecla para continuar (ou Ctrl+C para cancelar)...\n');
                pause;
                
                % Executar comparação automática
                executar_comparacao_automatica();
                
            else
                fprintf('⚠️  Nenhum arquivo encontrado nas pastas configuradas.\n');
                fprintf('   Verifique se suas imagens estão nos locais corretos.\n\n');
                oferecer_opcoes_sem_dados();
            end
            
        else
            fprintf('❌ Configuração inválida. Reconfigurando...\n\n');
            reconfigurar();
        end
        
    else
        fprintf('⚙️  Primeira execução detectada. Configurando...\n\n');
        configuracao_inicial_automatica();
        
        fprintf('\n🎯 Configuração concluída! Execute novamente:\n');
        fprintf('   >> inicio_rapido()\n\n');
    end
end

function valido = validar_configuracao_rapida(config)
    % Validação rápida da configuração
    
    valido = false;
    
    try
        if isfield(config, 'imageDir') && isfield(config, 'maskDir')
            if exist(config.imageDir, 'dir') && exist(config.maskDir, 'dir')
                valido = true;
            end
        end
    catch
        valido = false;
    end
end

function contagem = contar_arquivos(config)
    % Conta arquivos de imagem e máscara
    
    contagem = struct();
    
    try
        imgs = dir(fullfile(config.imageDir, '*.{jpg,jpeg,png,bmp,tif,tiff}'));
        masks = dir(fullfile(config.maskDir, '*.{jpg,jpeg,png,bmp,tif,tiff}'));
        
        contagem.imagens = length(imgs);
        contagem.mascaras = length(masks);
    catch
        contagem.imagens = 0;
        contagem.mascaras = 0;
    end
end

function executar_comparacao_automatica()
    % Executa a comparação completa automaticamente
    
    fprintf('🤖 EXECUÇÃO AUTOMÁTICA INICIADA\n');
    fprintf('===============================\n\n');
    
    % Carregar configuração
    load('config_caminhos.mat', 'config');
    
    % Sequência automática otimizada
    passos = {
        'Testando formato dos dados...', @() teste_dados_segmentacao(config);
        'Executando teste rápido...', @() treinar_unet_simples(config);
        'Comparação U-Net vs Attention U-Net...', @() comparacao_unet_attention_final(config)
    };
    
    for i = 1:size(passos, 1)
        fprintf('[%d/%d] %s\n', i, size(passos, 1), passos{i, 1});
        
        try
            passos{i, 2}();
            fprintf('✓ Passo %d concluído!\n\n', i);
        catch ME
            fprintf('❌ Erro no passo %d: %s\n', i, ME.message);
            
            if i == 1
                fprintf('⚠️  Erro crítico nos dados. Interrompendo execução.\n');
                fprintf('   Verifique suas imagens e máscaras.\n\n');
                return;
            else
                fprintf('⚠️  Erro não crítico. Continuando...\n\n');
            end
        end
    end
    
    fprintf('🎉 EXECUÇÃO AUTOMÁTICA CONCLUÍDA!\n');
    fprintf('=================================\n');
    fprintf('Verifique os resultados salvos em:\n');
    fprintf('- resultados_comparacao.mat\n');
    fprintf('- relatorio_comparacao.txt\n\n');
end

function oferecer_opcoes_sem_dados()
    % Oferece opções quando não há dados
    
    fprintf('OPÇÕES DISPONÍVEIS:\n');
    fprintf('==================\n');
    fprintf('1. Verificar configuração atual: testar_configuracao()\n');
    fprintf('2. Reconfigurar caminhos: configuracao_inicial_automatica()\n');
    fprintf('3. Configuração manual: configurar_caminhos()\n');
    fprintf('4. Menu principal: executar_comparacao()\n\n');
    
    fprintf('DICA: Certifique-se de que seus arquivos estão em:\n');
    fprintf('📁 Imagens: C:\\Users\\heito\\Pictures\\imagens matlab\\original\n');
    fprintf('📁 Máscaras: C:\\Users\\heito\\Pictures\\imagens matlab\\masks\n\n');
end

function reconfigurar()
    % Reconfiguração automática
    
    fprintf('🔧 Iniciando reconfiguração...\n\n');
    
    try
        configuracao_inicial_automatica();
        fprintf('✓ Reconfiguração concluída!\n\n');
    catch ME
        fprintf('❌ Erro na reconfiguração: %s\n', ME.message);
        fprintf('Execute manualmente: configurar_caminhos()\n\n');
    end
end
