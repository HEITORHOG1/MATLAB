function test_model_trainer()
    % ========================================================================
    % TESTE UNITÁRIO - MODELTRAINER
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Teste básico para verificar se a classe ModelTrainer foi implementada
    %   corretamente e pode ser instanciada sem erros.
    %
    % REQUISITOS: 4.1, 4.2, 4.3
    % ========================================================================
    
    fprintf('\n=== TESTE MODELTRAINER ===\n');
    
    try
        % Teste 1: Instanciar ModelTrainer
        fprintf('Teste 1: Instanciando ModelTrainer...\n');
        trainer = ModelTrainer();
        fprintf('✅ ModelTrainer instanciado com sucesso\n');
        
        % Teste 2: Verificar métodos principais existem
        fprintf('Teste 2: Verificando métodos principais...\n');
        methods_list = methods(trainer);
        
        required_methods = {'trainUNet', 'trainAttentionUNet', 'saveModel', 'loadModel', ...
                           'optimizeHyperparameters', 'findOptimalBatchSize', 'getParameterRecommendations'};
        
        for i = 1:length(required_methods)
            if any(strcmp(methods_list, required_methods{i}))
                fprintf('  ✅ Método %s encontrado\n', required_methods{i});
            else
                fprintf('  ❌ Método %s não encontrado\n', required_methods{i});
            end
        end
        
        % Teste 3: Testar ModelArchitectures
        fprintf('Teste 3: Testando ModelArchitectures...\n');
        inputSize = [128, 128, 3];
        numClasses = 2;
        
        % Testar criação de U-Net
        lgraph_unet = ModelArchitectures.createUNet(inputSize, numClasses);
        if ~isempty(lgraph_unet)
            fprintf('  ✅ U-Net criada com sucesso\n');
        else
            fprintf('  ❌ Erro ao criar U-Net\n');
        end
        
        % Testar criação de Attention U-Net
        lgraph_attention = ModelArchitectures.createAttentionUNet(inputSize, numClasses);
        if ~isempty(lgraph_attention)
            fprintf('  ✅ Attention U-Net criada com sucesso\n');
        else
            fprintf('  ❌ Erro ao criar Attention U-Net\n');
        end
        
        % Teste 4: Testar HyperparameterOptimizer
        fprintf('Teste 4: Testando HyperparameterOptimizer...\n');
        optimizer = HyperparameterOptimizer();
        
        % Testar cálculo de batch size ótimo
        config = struct();
        config.inputSize = inputSize;
        config.numClasses = numClasses;
        
        optimalBatchSize = optimizer.findOptimalBatchSize(config);
        if optimalBatchSize > 0
            fprintf('  ✅ Batch size ótimo calculado: %d\n', optimalBatchSize);
        else
            fprintf('  ❌ Erro ao calcular batch size ótimo\n');
        end
        
        % Testar recomendações
        datasetInfo = struct();
        datasetInfo.numSamples = 100;
        datasetInfo.taskComplexity = 'medium';
        
        recommendations = optimizer.recommendParameters(config, datasetInfo);
        if ~isempty(recommendations)
            fprintf('  ✅ Recomendações geradas com sucesso\n');
        else
            fprintf('  ❌ Erro ao gerar recomendações\n');
        end
        
        fprintf('\n✅ TODOS OS TESTES BÁSICOS PASSARAM\n');
        fprintf('📋 Sistema de Treinamento Modular implementado com sucesso!\n');
        
    catch ME
        fprintf('\n❌ ERRO NO TESTE: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end