function teste_treinador_unet()
    % Teste básico da classe TreinadorUNet
    % Este script testa a funcionalidade básica do TreinadorUNet
    
    fprintf('=== TESTE DO TREINADOR U-NET ===\n');
    
    try
        % Definir caminhos de teste
        caminhoImagens = 'C:\Users\heito\Documents\MATLAB\img\original';
        caminhoMascaras = 'C:\Users\heito\Documents\MATLAB\img\masks';
        
        % Verificar se os caminhos existem
        if ~exist(caminhoImagens, 'dir')
            fprintf('❌ Caminho de imagens não encontrado: %s\n', caminhoImagens);
            fprintf('   Usando caminhos alternativos para teste...\n');
            caminhoImagens = 'data/images';
            caminhoMascaras = 'data/masks';
        end
        
        if ~exist(caminhoImagens, 'dir')
            fprintf('❌ Caminhos de teste não encontrados. Criando estrutura de teste...\n');
            mkdir('data/images');
            mkdir('data/masks');
            fprintf('   Estrutura criada. Adicione imagens de teste para continuar.\n');
            return;
        end
        
        % Criar instância do treinador
        fprintf('\n[1/4] Criando instância do TreinadorUNet...\n');
        treinador = TreinadorUNet(caminhoImagens, caminhoMascaras);
        fprintf('✅ TreinadorUNet criado com sucesso!\n');
        
        % Testar carregamento de dados
        fprintf('\n[2/4] Testando carregamento de dados...\n');
        try
            [imagens, mascaras] = treinador.carregarDados();
            fprintf('✅ Dados carregados: %d imagens, %d máscaras\n', ...
                length(imagens), length(mascaras));
        catch ME
            fprintf('❌ Erro no carregamento de dados: %s\n', ME.message);
            return;
        end
        
        % Testar criação da arquitetura
        fprintf('\n[3/4] Testando criação da arquitetura U-Net...\n');
        try
            rede = treinador.criarArquiteturaUNet();
            fprintf('✅ Arquitetura U-Net criada com sucesso!\n');
            fprintf('   Número de layers: %d\n', length(rede.Layers));
        catch ME
            fprintf('❌ Erro na criação da arquitetura: %s\n', ME.message);
            return;
        end
        
        % Testar configuração de treinamento
        fprintf('\n[4/4] Testando configuração de treinamento...\n');
        try
            opcoes = treinador.configurarTreinamento();
            fprintf('✅ Configuração de treinamento criada com sucesso!\n');
        catch ME
            fprintf('❌ Erro na configuração de treinamento: %s\n', ME.message);
            return;
        end
        
        fprintf('\n✅ TODOS OS TESTES PASSARAM!\n');
        fprintf('   O TreinadorUNet está pronto para uso.\n');
        
        % Perguntar se deve executar treinamento completo
        resposta = input('\nDeseja executar um treinamento completo? (s/n): ', 's');
        if strcmpi(resposta, 's')
            fprintf('\n=== EXECUTANDO TREINAMENTO COMPLETO ===\n');
            modelo = treinador.treinar();
            fprintf('✅ Treinamento concluído com sucesso!\n');
        else
            fprintf('Teste concluído sem treinamento completo.\n');
        end
        
    catch ME
        fprintf('❌ ERRO GERAL NO TESTE: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('   %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end