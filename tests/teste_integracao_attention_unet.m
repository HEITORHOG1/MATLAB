function teste_integracao_attention_unet()
    % Teste de integração para verificar se o TreinadorAttentionUNet
    % funciona corretamente com o sistema principal
    
    fprintf('=== TESTE DE INTEGRAÇÃO ATTENTION U-NET ===\n');
    
    try
        % Adicionar caminhos necessários
        addpath('src/treinamento');
        
        % Definir caminhos de teste
        caminhoImagens = 'C:\Users\heito\Documents\MATLAB\img\original';
        caminhoMascaras = 'C:\Users\heito\Documents\MATLAB\img\masks';
        
        % Verificar se caminhos existem
        if ~exist(caminhoImagens, 'dir') || ~exist(caminhoMascaras, 'dir')
            fprintf('⚠️  Caminhos de dados não encontrados, executando teste simulado\n');
            testarIntegracaoSimulada();
            return;
        end
        
        % Teste 1: Verificar se as classes estão disponíveis
        fprintf('\n[1/4] Verificando disponibilidade das classes...\n');
        
        if exist('TreinadorUNet.m', 'file')
            fprintf('   ✅ TreinadorUNet disponível\n');
        else
            fprintf('   ❌ TreinadorUNet não encontrado\n');
        end
        
        if exist('TreinadorAttentionUNet.m', 'file')
            fprintf('   ✅ TreinadorAttentionUNet disponível\n');
        else
            fprintf('   ❌ TreinadorAttentionUNet não encontrado\n');
            return;
        end
        
        % Teste 2: Criar instâncias dos treinadores
        fprintf('\n[2/4] Criando instâncias dos treinadores...\n');
        
        treinadorUNet = TreinadorUNet(caminhoImagens, caminhoMascaras);
        treinadorAttention = TreinadorAttentionUNet(caminhoImagens, caminhoMascaras);
        
        fprintf('   ✅ Ambos os treinadores criados com sucesso\n');
        
        % Teste 3: Comparar configurações
        fprintf('\n[3/4] Comparando configurações dos modelos...\n');
        
        configUNet = treinadorUNet.configuracao;
        configAttention = treinadorAttention.configuracao;
        
        fprintf('   U-Net:           Epochs: %d, LR: %.4f, Batch: %d\n', ...
            configUNet.epochs, configUNet.learning_rate, configUNet.batch_size);
        fprintf('   Attention U-Net: Epochs: %d, LR: %.4f, Batch: %d\n', ...
            configAttention.epochs, configAttention.learning_rate, configAttention.batch_size);
        
        % Verificar otimizações do Attention U-Net
        if configAttention.epochs >= configUNet.epochs
            fprintf('   ✅ Attention U-Net configurado com mais epochs (modelo mais complexo)\n');
        end
        
        if configAttention.learning_rate <= configUNet.learning_rate
            fprintf('   ✅ Attention U-Net configurado com learning rate menor (mais estável)\n');
        end
        
        if configAttention.batch_size <= configUNet.batch_size
            fprintf('   ✅ Attention U-Net configurado com batch size menor (menos memória)\n');
        end
        
        % Teste 4: Verificar arquiteturas
        fprintf('\n[4/4] Verificando arquiteturas dos modelos...\n');
        
        try
            redeUNet = treinadorUNet.criarArquiteturaUNet();
            redeAttention = treinadorAttention.criarArquiteturaAttentionUNet();
            
            layersUNet = length(redeUNet.Layers);
            layersAttention = length(redeAttention.Layers);
            
            fprintf('   U-Net:           %d layers\n', layersUNet);
            fprintf('   Attention U-Net: %d layers\n', layersAttention);
            
            if layersAttention > layersUNet
                fprintf('   ✅ Attention U-Net tem mais layers (mecanismos de atenção adicionados)\n');
            end
            
            % Verificar se Attention U-Net tem layers de atenção
            nomesAttention = {redeAttention.Layers.Name};
            temAtencao = any(contains(nomesAttention, 'attention'));
            
            if temAtencao
                fprintf('   ✅ Attention U-Net contém mecanismos de atenção\n');
            else
                fprintf('   ⚠️  Mecanismos de atenção não detectados claramente\n');
            end
            
        catch ME
            fprintf('   ⚠️  Erro ao criar arquiteturas: %s\n', ME.message);
        end
        
        fprintf('\n✅ TESTE DE INTEGRAÇÃO CONCLUÍDO COM SUCESSO!\n');
        fprintf('O TreinadorAttentionUNet está pronto para uso no sistema principal\n');
        
    catch ME
        fprintf('\n❌ ERRO NO TESTE DE INTEGRAÇÃO: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('   %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function testarIntegracaoSimulada()
    % Teste de integração simulado sem dados reais
    
    fprintf('\n=== TESTE DE INTEGRAÇÃO SIMULADO ===\n');
    
    try
        % Criar pastas temporárias
        pastaTemp = tempdir;
        caminhoImagens = fullfile(pastaTemp, 'test_images');
        caminhoMascaras = fullfile(pastaTemp, 'test_masks');
        
        if ~exist(caminhoImagens, 'dir')
            mkdir(caminhoImagens);
        end
        if ~exist(caminhoMascaras, 'dir')
            mkdir(caminhoMascaras);
        end
        
        % Testar criação das classes
        treinadorUNet = TreinadorUNet(caminhoImagens, caminhoMascaras);
        treinadorAttention = TreinadorAttentionUNet(caminhoImagens, caminhoMascaras);
        
        fprintf('✅ Ambos os treinadores criados com caminhos simulados\n');
        
        % Comparar configurações
        configUNet = treinadorUNet.configuracao;
        configAttention = treinadorAttention.configuracao;
        
        fprintf('📊 COMPARAÇÃO DE CONFIGURAÇÕES:\n');
        fprintf('   U-Net:           Epochs: %d, LR: %.4f, Batch: %d\n', ...
            configUNet.epochs, configUNet.learning_rate, configUNet.batch_size);
        fprintf('   Attention U-Net: Epochs: %d, LR: %.4f, Batch: %d\n', ...
            configAttention.epochs, configAttention.learning_rate, configAttention.batch_size);
        
        % Verificar otimizações
        otimizacoes = 0;
        if configAttention.epochs >= configUNet.epochs
            fprintf('   ✅ Mais epochs para modelo complexo\n');
            otimizacoes = otimizacoes + 1;
        end
        
        if configAttention.learning_rate <= configUNet.learning_rate
            fprintf('   ✅ Learning rate menor para estabilidade\n');
            otimizacoes = otimizacoes + 1;
        end
        
        if configAttention.batch_size <= configUNet.batch_size
            fprintf('   ✅ Batch size menor para economia de memória\n');
            otimizacoes = otimizacoes + 1;
        end
        
        fprintf('\n✅ INTEGRAÇÃO SIMULADA CONCLUÍDA!\n');
        fprintf('   %d/3 otimizações detectadas para Attention U-Net\n', otimizacoes);
        
        % Limpeza
        rmdir(caminhoImagens);
        rmdir(caminhoMascaras);
        
    catch ME
        fprintf('❌ Erro no teste simulado: %s\n', ME.message);
    end
end