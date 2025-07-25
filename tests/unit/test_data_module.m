function test_data_module()
    % ========================================================================
    % TESTE DO MÓDULO DE DADOS - SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 3.0 - Refatoração Modular
    %
    % DESCRIÇÃO:
    %   Teste unitário para validar as classes DataLoader, DataPreprocessor
    %   e DataValidator
    % ========================================================================
    
    fprintf('=== TESTE DO MÓDULO DE DADOS ===\n');
    
    try
        % Configuração de teste
        config = struct(...
            'imageDir', 'img/original', ...
            'maskDir', 'img/masks', ...
            'inputSize', [256, 256, 3]);
        
        % Teste 1: DataLoader
        fprintf('\n1. Testando DataLoader...\n');
        
        % Verificar se os diretórios existem
        if ~exist(config.imageDir, 'dir') || ~exist(config.maskDir, 'dir')
            fprintf('⚠️  Diretórios de teste não encontrados, criando dados simulados...\n');
            config = createTestData();
        end
        
        dataLoader = DataLoader(config);
        [images, masks] = dataLoader.loadData('Verbose', true);
        
        if ~isempty(images) && ~isempty(masks)
            fprintf('✓ DataLoader: %d pares carregados com sucesso\n', length(images));
            
            % Teste de divisão de dados
            [trainData, valData, testData] = dataLoader.splitData(images, masks, ...
                'TrainRatio', 0.7, 'ValRatio', 0.2, 'TestRatio', 0.1);
            
            fprintf('✓ Divisão de dados: Treino=%d, Val=%d, Teste=%d\n', ...
                trainData.size, valData.size, testData.size);
        else
            fprintf('❌ DataLoader: Nenhum dado carregado\n');
            return;
        end
        
        % Teste 2: DataValidator
        fprintf('\n2. Testando DataValidator...\n');
        
        validator = DataValidator(config);
        
        % Testar alguns pares
        numToTest = min(5, length(images));
        validCount = 0;
        
        for i = 1:numToTest
            if validator.validateDataFormat(images{i}, masks{i})
                validCount = validCount + 1;
            end
        end
        
        fprintf('✓ DataValidator: %d/%d pares válidos\n', validCount, numToTest);
        
        % Teste de consistência
        isConsistent = validator.checkDataConsistency(images, masks);
        if isConsistent
            fprintf('✓ Consistência de dados verificada\n');
        else
            fprintf('⚠️  Problemas de consistência detectados\n');
        end
        
        % Teste 3: DataPreprocessor
        fprintf('\n3. Testando DataPreprocessor...\n');
        
        preprocessor = DataPreprocessor(config, 'EnableCache', true);
        
        % Testar preprocessamento
        if ~isempty(images) && ~isempty(masks)
            testData = {images{1}, masks{1}};
            processedData = preprocessor.preprocess(testData, 'IsTraining', false);
            
            if iscell(processedData) && length(processedData) == 2
                img = processedData{1};
                mask = processedData{2};
                
                fprintf('✓ Preprocessamento: Imagem %s, Máscara %s\n', ...
                    class(img), class(mask));
                fprintf('  - Dimensões imagem: %s\n', mat2str(size(img)));
                fprintf('  - Dimensões máscara: %s\n', mat2str(size(mask)));
                
                % Testar augmentation
                augmentedData = preprocessor.preprocess(testData, ...
                    'IsTraining', true, 'UseAugmentation', true);
                
                if iscell(augmentedData) && length(augmentedData) == 2
                    fprintf('✓ Data augmentation funcionando\n');
                else
                    fprintf('❌ Erro no data augmentation\n');
                end
                
            else
                fprintf('❌ Erro no preprocessamento\n');
            end
        end
        
        % Estatísticas do cache
        cacheStats = preprocessor.getCacheStats();
        if cacheStats.enabled
            fprintf('✓ Cache: %d itens, %.1f%% hit rate\n', ...
                cacheStats.size, cacheStats.hitRate * 100);
        end
        
        % Teste 4: Integração completa
        fprintf('\n4. Testando integração completa...\n');
        
        % Simular pipeline completo
        [correctedImages, correctedMasks] = validator.autoCorrectData(images, masks);
        fprintf('✓ Correção automática: %d pares corrigidos\n', length(correctedImages));
        
        % Preprocessar dados corrigidos
        if ~isempty(correctedImages)
            testData = {correctedImages{1}, correctedMasks{1}};
            finalData = preprocessor.preprocess(testData, 'IsTraining', true);
            
            if iscell(finalData) && length(finalData) == 2
                fprintf('✓ Pipeline completo funcionando\n');
            else
                fprintf('❌ Erro no pipeline completo\n');
            end
        end
        
        % Relatório final
        fprintf('\n=== RELATÓRIO FINAL ===\n');
        validator.printReport();
        
        fprintf('\n✅ TODOS OS TESTES DO MÓDULO DE DADOS CONCLUÍDOS\n');
        
    catch ME
        fprintf('\n❌ ERRO NO TESTE: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function config = createTestData()
    % Cria dados de teste simulados se os diretórios não existirem
    
    fprintf('Criando dados de teste simulados...\n');
    
    % Criar diretórios temporários
    testImageDir = 'temp_test_images';
    testMaskDir = 'temp_test_masks';
    
    if ~exist(testImageDir, 'dir')
        mkdir(testImageDir);
    end
    
    if ~exist(testMaskDir, 'dir')
        mkdir(testMaskDir);
    end
    
    % Criar algumas imagens e máscaras de teste
    for i = 1:5
        % Criar imagem sintética
        img = uint8(rand(256, 256, 3) * 255);
        imgPath = fullfile(testImageDir, sprintf('test_img_%03d.png', i));
        imwrite(img, imgPath);
        
        % Criar máscara sintética
        mask = uint8(rand(256, 256) > 0.5) * 255;
        maskPath = fullfile(testMaskDir, sprintf('test_img_%03d.png', i));
        imwrite(mask, maskPath);
    end
    
    config = struct(...
        'imageDir', testImageDir, ...
        'maskDir', testMaskDir, ...
        'inputSize', [256, 256, 3]);
    
    fprintf('✓ Dados de teste criados em %s e %s\n', testImageDir, testMaskDir);
end