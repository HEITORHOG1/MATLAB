function teste_treinamento_rapido()
    % ========================================================================
    % TESTE RÁPIDO DE TREINAMENTO - Pós Correção
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 1.2 Final
    %
    % DESCRIÇÃO:
    %   Teste super rápido do treinamento após correção crítica
    %
    % USO:
    %   >> teste_treinamento_rapido()
    %
    % VERSÃO: 1.0
    % DATA: Julho 2025
    % ========================================================================
    
    clc;
    fprintf('=====================================\n');
    fprintf('   TESTE RÁPIDO DE TREINAMENTO       \n');
    fprintf('   Pós-Correção Crítica              \n');
    fprintf('=====================================\n\n');
    
    try
        % Carregar configuração
        load('config_caminhos.mat', 'config');
        fprintf('✓ Configuração carregada\n');
        
        % Usar máscaras convertidas se disponíveis
        mask_converted_dir = fullfile(fileparts(config.maskDir), 'masks_converted');
        if exist(mask_converted_dir, 'dir')
            fprintf('✓ Usando máscaras convertidas\n');
            config.maskDir = mask_converted_dir;
        end
        
        % Carregar dados de teste (apenas 5 amostras)
        [images, masks] = carregar_dados_robustos(config);
        
        % Usar apenas 5 amostras para teste super rápido
        numSamples = min(5, length(images));
        images = images(1:numSamples);
        masks = masks(1:numSamples);
        
        fprintf('✓ Usando %d amostras para teste\n', numSamples);
        
        % Analisar máscaras
        [classNames, labelIDs] = analisar_mascaras_automatico(config.maskDir, masks);
        fprintf('✓ Classes: %s\n', strjoin(classNames, ', '));
        
        % Dividir dados (80% treino, 20% validação)
        numTrain = max(1, floor(0.8 * numSamples));
        trainIdx = 1:numTrain;
        valIdx = (numTrain+1):numSamples;
        
        if isempty(valIdx)
            valIdx = trainIdx; % Usar mesmo dado para validação se muito pequeno
        end
        
        % Criar datastores
        imdsTrain = imageDatastore(images(trainIdx));
        pxdsTrain = pixelLabelDatastore(masks(trainIdx), classNames, labelIDs);
        dsTrain = combine(imdsTrain, pxdsTrain);
        
        imdsVal = imageDatastore(images(valIdx));
        pxdsVal = pixelLabelDatastore(masks(valIdx), classNames, labelIDs);
        dsVal = combine(imdsVal, pxdsVal);
        
        % Aplicar preprocessamento corrigido
        dsTrain = transform(dsTrain, @(data) preprocessDataCorrigido(data, config, labelIDs, false));
        dsVal = transform(dsVal, @(data) preprocessDataCorrigido(data, config, labelIDs, false));
        
        fprintf('✓ Datastores criados com preprocessamento corrigido\n');
        
        % Testar leitura dos dados
        fprintf('\n=== TESTANDO LEITURA DOS DADOS ===\n');
        try
            reset(dsTrain);
            sample = read(dsTrain);
            fprintf('✓ Dados lidos com sucesso\n');
            fprintf('  Imagem: %s %s\n', class(sample{1}), mat2str(size(sample{1})));
            fprintf('  Máscara: %s %s\n', class(sample{2}), mat2str(size(sample{2})));
        catch ME
            error('Erro na leitura dos dados: %s', ME.message);
        end
        
        % Criar rede simples
        inputSize = config.inputSize;
        numClasses = config.numClasses;
        
        lgraph = unetLayers(inputSize, numClasses, 'EncoderDepth', 2); % Rede muito pequena
        fprintf('✓ Rede U-Net criada (depth=2 para teste rápido)\n');
        
        % Opções de treinamento super rápidas
        options = trainingOptions('adam', ...
            'InitialLearnRate', 1e-3, ...
            'MaxEpochs', 1, ...  % Apenas 1 época para teste
            'MiniBatchSize', 1, ... % Batch pequeno
            'ValidationData', dsVal, ...
            'ValidationFrequency', 1, ...
            'Plots', 'none', ...
            'Verbose', true, ...
            'ExecutionEnvironment', 'auto');
        
        fprintf('✓ Opções de treinamento configuradas (1 época)\n');
        
        % Teste de treinamento
        fprintf('\n=== INICIANDO TESTE DE TREINAMENTO ===\n');
        fprintf('Início: %s\n', datestr(now));
        
        try
            net = trainNetwork(dsTrain, lgraph, options);
            fprintf('✅ TREINAMENTO BEM-SUCEDIDO!\n');
            fprintf('Fim: %s\n', datestr(now));
            
            % Salvar modelo de teste
            save('modelo_teste_correcao.mat', 'net', 'config');
            fprintf('✓ Modelo salvo: modelo_teste_correcao.mat\n');
            
        catch ME
            fprintf('❌ Erro no treinamento: %s\n', ME.message);
            return;
        end
        
        fprintf('\n=====================================\n');
        fprintf('   RESULTADO FINAL                   \n');
        fprintf('=====================================\n');
        fprintf('✅ CORREÇÃO 100%% FUNCIONANDO!\n');
        fprintf('O problema categorical foi totalmente resolvido.\n');
        fprintf('O treinamento está funcionando normalmente.\n\n');
        
        fprintf('🚀 PRÓXIMOS PASSOS:\n');
        fprintf('1. Execute: executar_comparacao()\n');
        fprintf('2. Escolha opção 3 para teste rápido completo\n');
        fprintf('3. Escolha opção 5 para execução completa\n\n');
        
    catch ME
        fprintf('❌ Erro no teste: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('Arquivo: %s, Linha: %d\n', ME.stack(1).file, ME.stack(1).line);
        end
    end
end
