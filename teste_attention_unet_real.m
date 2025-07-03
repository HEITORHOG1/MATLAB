function teste_attention_unet_real()
    % TESTE ESPECÍFICO DA ATTENTION U-NET
    % Verifica se a implementação está realmente funcionando
    
    fprintf('========================================\n');
    fprintf('   TESTE DA ATTENTION U-NET REAL\n');
    fprintf('========================================\n\n');
    
    % Parâmetros de teste
    inputSize = [256, 256, 3];
    numClasses = 2;
    
    fprintf('1. Testando criação da Attention U-Net...\n');
    
    try
        % Criar Attention U-Net
        tic;
        lgraph = create_working_attention_unet(inputSize, numClasses);
        tempoCreacao = toc;
        
        fprintf('✅ Attention U-Net criada em %.2f segundos\n', tempoCreacao);
        
        % Analisar estrutura da rede
        fprintf('\n2. Analisando estrutura da rede...\n');
        
        layers = lgraph.Layers;
        connections = lgraph.Connections;
        
        fprintf('   Número de camadas: %d\n', length(layers));
        fprintf('   Número de conexões: %d\n', height(connections));
        
        % Contar attention gates
        attentionLayers = contains({layers.Name}, 'att_');
        numAttentionLayers = sum(attentionLayers);
        
        fprintf('   Camadas de atenção: %d\n', numAttentionLayers);
        
        % Verificar tipos de camadas específicas
        convLayers = sum(contains({layers.Name}, 'conv'));
        reluLayers = sum(contains({layers.Name}, 'relu'));
        sigmoidLayers = sum(contains({layers.Name}, 'sigmoid'));
        multiplyLayers = sum(contains({layers.Name}, 'out'));
        
        fprintf('   Camadas convolucionais: %d\n', convLayers);
        fprintf('   Camadas ReLU: %d\n', reluLayers);
        fprintf('   Camadas sigmoid (atenção): %d\n', sigmoidLayers);
        fprintf('   Camadas de multiplicação: %d\n', multiplyLayers);
        
        % Verificar se tem características de Attention U-Net
        hasAttentionGates = sigmoidLayers >= 3 && multiplyLayers >= 3;
        
        if hasAttentionGates
            fprintf('✅ CONFIRMADO: Rede possui Attention Gates!\n');
        else
            fprintf('⚠️ AVISO: Rede pode não ter Attention Gates completos\n');
        end
        
        % Testar validação da rede
        fprintf('\n3. Validando arquitetura da rede...\n');
        
        try
            analyzeNetwork(lgraph);
            fprintf('✅ Rede validada com sucesso!\n');
            redeValida = true;
        catch analyzeErr
            fprintf('⚠️ Problemas na validação: %s\n', analyzeErr.message);
            redeValida = false;
        end
        
        % Criar dados sintéticos para teste
        fprintf('\n4. Testando com dados sintéticos...\n');
        
        % Criar 4 imagens sintéticas
        numTestImages = 4;
        testImages = rand(inputSize(1), inputSize(2), inputSize(3), numTestImages, 'single') * 255;
        testMasks = rand(inputSize(1), inputSize(2), numTestImages, 'single') > 0.5;
        
        % Criar datastores temporários
        tempImageDir = fullfile(tempdir, 'test_images');
        tempMaskDir = fullfile(tempdir, 'test_masks');
        
        if ~exist(tempImageDir, 'dir'), mkdir(tempImageDir); end
        if ~exist(tempMaskDir, 'dir'), mkdir(tempMaskDir); end
        
        % Salvar imagens de teste
        for i = 1:numTestImages
            imwrite(uint8(testImages(:,:,:,i)), fullfile(tempImageDir, sprintf('img_%d.png', i)));
            imwrite(uint8(testMasks(:,:,i)*255), fullfile(tempMaskDir, sprintf('mask_%d.png', i)));
        end
        
        % Criar datastores
        imds = imageDatastore(tempImageDir);
        pxds = pixelLabelDatastore(tempMaskDir, {'background', 'object'}, [0, 255]);
        
        ds = combine(imds, pxds);
        
        % Testar treinamento rápido (1 época)
        fprintf('   Testando treinamento (1 época)...\n');
        
        if redeValida
            try
                options = trainingOptions('adam', ...
                    'InitialLearnRate', 1e-3, ...
                    'MaxEpochs', 1, ...
                    'MiniBatchSize', 2, ...
                    'Verbose', false, ...
                    'Plots', 'none', ...
                    'ExecutionEnvironment', 'auto');
                
                tic;
                net = trainNetwork(ds, lgraph, options);
                tempoTreino = toc;
                
                fprintf('✅ Treinamento teste concluído em %.2f segundos\n', tempoTreino);
                
                % Testar predição
                fprintf('   Testando predição...\n');
                
                % Resetar datastore e ler primeira imagem
                reset(imds);
                testImg = read(imds);
                if iscell(testImg)
                    testImg = testImg{1};
                end
                
                tic;
                prediction = semanticseg(testImg, net);
                tempoPrediction = toc;
                
                fprintf('✅ Predição realizada em %.4f segundos\n', tempoPrediction);
                
                % Verificar output
                predSize = size(prediction);
                expectedSize = inputSize(1:2);
                
                if isequal(predSize, expectedSize)
                    fprintf('✅ Tamanho da predição correto: %dx%d\n', predSize);
                else
                    fprintf('⚠️ Tamanho da predição incorreto: %dx%d (esperado: %dx%d)\n', ...
                        predSize, expectedSize);
                end
                
                testeCompleto = true;
                
            catch trainErr
                fprintf('❌ Erro no treinamento: %s\n', trainErr.message);
                testeCompleto = false;
            end
        else
            fprintf('⚠️ Pulando teste de treinamento devido a problemas na rede\n');
            testeCompleto = false;
        end
        
        % Limpar arquivos temporários
        try
            rmdir(tempImageDir, 's');
            rmdir(tempMaskDir, 's');
        catch
            % Ignorar erros de limpeza
        end
        
        % Resumo final
        fprintf('\n========================================\n');
        fprintf('   RESUMO DO TESTE\n');
        fprintf('========================================\n');
        
        fprintf('Criação da rede: %s\n', ifelse(true, '✅ OK', '❌ FALHOU'));
        fprintf('Attention Gates: %s\n', ifelse(hasAttentionGates, '✅ PRESENTES', '❌ AUSENTES'));
        fprintf('Validação: %s\n', ifelse(redeValida, '✅ OK', '❌ FALHOU'));
        fprintf('Treinamento: %s\n', ifelse(testeCompleto, '✅ OK', '❌ FALHOU'));
        
        if hasAttentionGates && redeValida && testeCompleto
            fprintf('\n🎉 SUCESSO: Attention U-Net está funcionando corretamente!\n');
            fprintf('   A rede possui attention gates reais e é capaz de treinar.\n');
        elseif hasAttentionGates && redeValida
            fprintf('\n✅ PARCIAL: Attention U-Net criada corretamente mas não testada completamente.\n');
        else
            fprintf('\n⚠️ PROBLEMAS: Attention U-Net não está funcionando como esperado.\n');
        end
        
        fprintf('\n');
        
    catch ME
        fprintf('❌ ERRO CRÍTICO: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function result = ifelse(condition, trueValue, falseValue)
    if condition
        result = trueValue;
    else
        result = falseValue;
    end
end
