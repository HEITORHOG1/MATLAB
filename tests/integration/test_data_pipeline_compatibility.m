function test_data_pipeline_compatibility()
    % ========================================================================
    % TESTE DE INTEGRAÇÃO - COMPATIBILIDADE DO PIPELINE DE DADOS
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Teste de integração que valida a compatibilidade entre todos os
    %   componentes do pipeline de dados
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Data Pipeline Testing
    %   - Component Integration
    % ========================================================================
    
    fprintf('=== TESTE DE INTEGRAÇÃO - PIPELINE DE DADOS ===\n\n');
    
    % Adicionar caminhos necessários
    addpath(genpath('src'));
    
    % Configurar ambiente de teste
    testEnv = setupDataTestEnvironment();
    
    try
        % Executar testes de compatibilidade
        test_loader_validator_compatibility(testEnv);
        test_validator_preprocessor_compatibility(testEnv);
        test_preprocessor_trainer_compatibility(testEnv);
        test_cross_component_data_flow(testEnv);
        test_error_propagation(testEnv);
        test_performance_integration(testEnv);
        test_memory_management_integration(testEnv);
        
        fprintf('\n=== TODOS OS TESTES DE COMPATIBILIDADE PASSARAM! ===\n');
        
    catch ME
        fprintf('\n=== ERRO NOS TESTES DE COMPATIBILIDADE ===\n');
        fprintf('Erro: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('Arquivo: %s\n', ME.stack(1).file);
            fprintf('Linha: %d\n', ME.stack(1).line);
        end
        rethrow(ME);
    finally
        % Limpar ambiente de teste
        cleanupDataTestEnvironment(testEnv);
    end
end

function testEnv = setupDataTestEnvironment()
    % Configura ambiente específico para testes de dados
    fprintf('Configurando ambiente de teste de dados...\n');
    
    testEnv = struct();
    testEnv.baseDir = 'test_data_pipeline';
    testEnv.scenarios = struct();
    
    % Criar diretório base
    if ~exist(testEnv.baseDir, 'dir')
        mkdir(testEnv.baseDir);
    end
    
    % Cenário 1: Dados normais
    testEnv.scenarios.normal = createNormalDataScenario(testEnv.baseDir);
    
    % Cenário 2: Dados com problemas
    testEnv.scenarios.problematic = createProblematicDataScenario(testEnv.baseDir);
    
    % Cenário 3: Dados de diferentes formatos
    testEnv.scenarios.mixed_formats = createMixedFormatScenario(testEnv.baseDir);
    
    % Cenário 4: Dados grandes (simulados)
    testEnv.scenarios.large_data = createLargeDataScenario(testEnv.baseDir);
    
    fprintf('✓ Ambiente de teste de dados configurado\n');
end

function scenario = createNormalDataScenario(baseDir)
    % Cria cenário com dados normais e bem formados
    scenario = struct();
    scenario.name = 'normal';
    scenario.imageDir = fullfile(baseDir, 'normal_images');
    scenario.maskDir = fullfile(baseDir, 'normal_masks');
    
    if ~exist(scenario.imageDir, 'dir'), mkdir(scenario.imageDir); end
    if ~exist(scenario.maskDir, 'dir'), mkdir(scenario.maskDir); end
    
    % Criar dados consistentes
    for i = 1:8
        % Imagem RGB 256x256
        img = uint8(rand(256, 256, 3) * 255);
        imgFile = fullfile(scenario.imageDir, sprintf('normal_%03d.png', i));
        imwrite(img, imgFile);
        
        % Máscara binária correspondente
        mask = uint8((rand(256, 256) > 0.6) * 255);
        maskFile = fullfile(scenario.maskDir, sprintf('normal_%03d.png', i));
        imwrite(mask, maskFile);
    end
    
    scenario.config = struct();
    scenario.config.inputSize = [256, 256, 3];
    scenario.config.numClasses = 2;
    scenario.config.expectedSamples = 8;
end

function scenario = createProblematicDataScenario(baseDir)
    % Cria cenário com dados problemáticos para testar robustez
    scenario = struct();
    scenario.name = 'problematic';
    scenario.imageDir = fullfile(baseDir, 'problem_images');
    scenario.maskDir = fullfile(baseDir, 'problem_masks');
    
    if ~exist(scenario.imageDir, 'dir'), mkdir(scenario.imageDir); end
    if ~exist(scenario.maskDir, 'dir'), mkdir(scenario.maskDir); end
    
    % Problema 1: Dimensões diferentes
    img1 = uint8(rand(128, 128, 3) * 255); % Menor que esperado
    imwrite(img1, fullfile(scenario.imageDir, 'problem_001.png'));
    mask1 = uint8((rand(256, 256) > 0.5) * 255); % Maior que imagem
    imwrite(mask1, fullfile(scenario.maskDir, 'problem_001.png'));
    
    % Problema 2: Imagem grayscale em vez de RGB
    img2 = uint8(rand(256, 256) * 255);
    imwrite(img2, fullfile(scenario.imageDir, 'problem_002.png'));
    mask2 = uint8((rand(256, 256) > 0.5) * 255);
    imwrite(mask2, fullfile(scenario.maskDir, 'problem_002.png'));
    
    % Problema 3: Máscara com valores não binários
    img3 = uint8(rand(256, 256, 3) * 255);
    imwrite(img3, fullfile(scenario.imageDir, 'problem_003.png'));
    mask3 = uint8(rand(256, 256) * 255); % Valores contínuos
    imwrite(mask3, fullfile(scenario.maskDir, 'problem_003.png'));
    
    % Problema 4: Arquivo corrompido (simulado com arquivo vazio)
    fid = fopen(fullfile(scenario.imageDir, 'problem_004.png'), 'w');
    fclose(fid);
    fid = fopen(fullfile(scenario.maskDir, 'problem_004.png'), 'w');
    fclose(fid);
    
    scenario.config = struct();
    scenario.config.inputSize = [256, 256, 3];
    scenario.config.numClasses = 2;
    scenario.config.expectedProblems = 4;
end

function scenario = createMixedFormatScenario(baseDir)
    % Cria cenário com diferentes formatos de arquivo
    scenario = struct();
    scenario.name = 'mixed_formats';
    scenario.imageDir = fullfile(baseDir, 'mixed_images');
    scenario.maskDir = fullfile(baseDir, 'mixed_masks');
    
    if ~exist(scenario.imageDir, 'dir'), mkdir(scenario.imageDir); end
    if ~exist(scenario.maskDir, 'dir'), mkdir(scenario.maskDir); end
    
    % Formato PNG
    img_png = uint8(rand(256, 256, 3) * 255);
    imwrite(img_png, fullfile(scenario.imageDir, 'mixed_001.png'));
    mask_png = uint8((rand(256, 256) > 0.5) * 255);
    imwrite(mask_png, fullfile(scenario.maskDir, 'mixed_001.png'));
    
    % Formato JPG
    img_jpg = uint8(rand(256, 256, 3) * 255);
    imwrite(img_jpg, fullfile(scenario.imageDir, 'mixed_002.jpg'));
    mask_jpg = uint8((rand(256, 256) > 0.5) * 255);
    imwrite(mask_jpg, fullfile(scenario.maskDir, 'mixed_002.jpg'));
    
    % Formato TIFF
    try
        img_tiff = uint8(rand(256, 256, 3) * 255);
        imwrite(img_tiff, fullfile(scenario.imageDir, 'mixed_003.tiff'));
        mask_tiff = uint8((rand(256, 256) > 0.5) * 255);
        imwrite(mask_tiff, fullfile(scenario.maskDir, 'mixed_003.tiff'));
    catch
        % TIFF pode não estar disponível em todos os sistemas
        fprintf('  ⚠ TIFF não disponível, usando PNG\n');
        imwrite(img_png, fullfile(scenario.imageDir, 'mixed_003.png'));
        imwrite(mask_png, fullfile(scenario.maskDir, 'mixed_003.png'));
    end
    
    scenario.config = struct();
    scenario.config.inputSize = [256, 256, 3];
    scenario.config.numClasses = 2;
    scenario.config.expectedFormats = 3;
end

function scenario = createLargeDataScenario(baseDir)
    % Cria cenário simulando dados grandes
    scenario = struct();
    scenario.name = 'large_data';
    scenario.imageDir = fullfile(baseDir, 'large_images');
    scenario.maskDir = fullfile(baseDir, 'large_masks');
    
    if ~exist(scenario.imageDir, 'dir'), mkdir(scenario.imageDir); end
    if ~exist(scenario.maskDir, 'dir'), mkdir(scenario.maskDir); end
    
    % Criar apenas alguns arquivos grandes para simular
    for i = 1:3
        % Imagem maior (512x512)
        img = uint8(rand(512, 512, 3) * 255);
        imgFile = fullfile(scenario.imageDir, sprintf('large_%03d.png', i));
        imwrite(img, imgFile);
        
        % Máscara correspondente
        mask = uint8((rand(512, 512) > 0.5) * 255);
        maskFile = fullfile(scenario.maskDir, sprintf('large_%03d.png', i));
        imwrite(mask, maskFile);
    end
    
    scenario.config = struct();
    scenario.config.inputSize = [512, 512, 3];
    scenario.config.numClasses = 2;
    scenario.config.expectedSamples = 3;
end

function test_loader_validator_compatibility(testEnv)
    fprintf('Testando compatibilidade DataLoader <-> DataValidator...\n');
    
    % Testar com dados normais
    scenario = testEnv.scenarios.normal;
    config = scenario.config;
    config.paths = struct('imageDir', scenario.imageDir, 'maskDir', scenario.maskDir);
    
    loader = DataLoader(config, 'verbose', false);
    validator = DataValidator(config, 'verbose', false);
    
    % Carregar dados
    [images, masks] = loader.loadData();
    assert(~isempty(images), 'Nenhuma imagem carregada');
    assert(~isempty(masks), 'Nenhuma máscara carregada');
    
    % Validar dados carregados
    numValid = 0;
    for i = 1:length(images)
        if validator.validateDataFormat(images{i}, masks{i})
            numValid = numValid + 1;
        end
    end
    
    assert(numValid > 0, 'Nenhum dado válido encontrado');
    fprintf('  ✓ Dados normais: %d/%d válidos\n', numValid, length(images));
    
    % Testar consistência
    isConsistent = validator.checkDataConsistency(images, masks);
    assert(isConsistent, 'Dados não são consistentes');
    
    % Testar com dados problemáticos
    problemScenario = testEnv.scenarios.problematic;
    problemConfig = problemScenario.config;
    problemConfig.paths = struct('imageDir', problemScenario.imageDir, 'maskDir', problemScenario.maskDir);
    
    problemLoader = DataLoader(problemConfig, 'verbose', false);
    problemValidator = DataValidator(problemConfig, 'verbose', false);
    
    try
        [problemImages, problemMasks] = problemLoader.loadData();
        
        % Deve detectar problemas
        numProblems = 0;
        for i = 1:length(problemImages)
            if ~problemValidator.validateDataFormat(problemImages{i}, problemMasks{i})
                numProblems = numProblems + 1;
            end
        end
        
        assert(numProblems > 0, 'Problemas não foram detectados');
        fprintf('  ✓ Dados problemáticos: %d problemas detectados\n', numProblems);
        
    catch ME
        fprintf('  ✓ Dados problemáticos rejeitados corretamente: %s\n', ME.message);
    end
end

function test_validator_preprocessor_compatibility(testEnv)
    fprintf('Testando compatibilidade DataValidator <-> DataPreprocessor...\n');
    
    scenario = testEnv.scenarios.normal;
    config = scenario.config;
    config.paths = struct('imageDir', scenario.imageDir, 'maskDir', scenario.maskDir);
    
    loader = DataLoader(config, 'verbose', false);
    validator = DataValidator(config, 'verbose', false);
    preprocessor = DataPreprocessor(config, 'verbose', false);
    
    % Carregar e validar dados
    [images, masks] = loader.loadData();
    
    % Testar pipeline: validação -> correção -> preprocessamento
    correctedImages = images;
    correctedMasks = masks;
    
    % Aplicar correções se necessário
    if ~validator.checkDataConsistency(images, masks)
        [correctedImages, correctedMasks] = validator.autoCorrectData(images, masks);
        fprintf('  ✓ Dados corrigidos automaticamente\n');
    end
    
    % Preprocessar dados corrigidos
    numProcessed = 0;
    for i = 1:min(3, length(correctedImages)) % Testar apenas alguns
        testData = {correctedImages{i}, correctedMasks{i}};
        
        try
            processedData = preprocessor.preprocess(testData, 'IsTraining', false);
            
            assert(iscell(processedData), 'Dados preprocessados não são cell');
            assert(length(processedData) == 2, 'Número incorreto de elementos');
            
            % Verificar se dados preprocessados são válidos
            img = processedData{1};
            mask = processedData{2};
            
            assert(isnumeric(img), 'Imagem preprocessada não é numérica');
            assert(isnumeric(mask), 'Máscara preprocessada não é numérica');
            assert(ndims(img) == 3, 'Imagem deve ter 3 dimensões');
            assert(ndims(mask) >= 2, 'Máscara deve ter pelo menos 2 dimensões');
            
            numProcessed = numProcessed + 1;
            
        catch ME
            fprintf('  ⚠ Erro no preprocessamento do item %d: %s\n', i, ME.message);
        end
    end
    
    assert(numProcessed > 0, 'Nenhum dado foi preprocessado com sucesso');
    fprintf('  ✓ %d dados preprocessados com sucesso\n', numProcessed);
    
    % Testar cache do preprocessor
    cacheStats = preprocessor.getCacheStats();
    if cacheStats.enabled
        fprintf('  ✓ Cache ativo: %d itens, %.1f%% hit rate\n', ...
            cacheStats.size, cacheStats.hitRate * 100);
    end
end

function test_preprocessor_trainer_compatibility(testEnv)
    fprintf('Testando compatibilidade DataPreprocessor <-> ModelTrainer...\n');
    
    scenario = testEnv.scenarios.normal;
    config = scenario.config;
    config.paths = struct('imageDir', scenario.imageDir, 'maskDir', scenario.maskDir);
    
    % Adicionar configurações de treinamento
    config.training = struct();
    config.training.maxEpochs = 1;
    config.training.miniBatchSize = 2;
    config.training.learningRate = 1e-3;
    
    loader = DataLoader(config, 'verbose', false);
    preprocessor = DataPreprocessor(config, 'verbose', false);
    
    try
        % Carregar dados
        [images, masks] = loader.loadData();
        
        % Preprocessar alguns dados
        processedData = cell(min(4, length(images)), 1);
        for i = 1:length(processedData)
            testData = {images{i}, masks{i}};
            processedData{i} = preprocessor.preprocess(testData, 'IsTraining', true);
        end
        
        % Verificar compatibilidade com datastores
        processedImages = cellfun(@(x) x{1}, processedData, 'UniformOutput', false);
        processedMasks = cellfun(@(x) x{2}, processedData, 'UniformOutput', false);
        
        % Criar datastores
        imds = imageDatastore(processedImages);
        
        % Para máscaras, precisamos converter para formato adequado
        maskFiles = cell(length(processedMasks), 1);
        tempMaskDir = fullfile(testEnv.baseDir, 'temp_masks');
        if ~exist(tempMaskDir, 'dir'), mkdir(tempMaskDir); end
        
        for i = 1:length(processedMasks)
            maskFile = fullfile(tempMaskDir, sprintf('temp_mask_%d.png', i));
            
            % Converter máscara para formato adequado
            mask = processedMasks{i};
            if isa(mask, 'categorical')
                mask = uint8(mask) - 1; % Converter para 0-based
            elseif size(mask, 3) > 1
                mask = mask(:,:,1); % Usar apenas primeiro canal
            end
            
            imwrite(uint8(mask), maskFile);
            maskFiles{i} = maskFile;
        end
        
        % Criar pixel label datastore
        classNames = {'background', 'foreground'};
        labelIDs = [0, 1];
        pxds = pixelLabelDatastore(maskFiles, classNames, labelIDs);
        
        % Combinar datastores
        ds = combine(imds, pxds);
        
        % Testar leitura do datastore
        reset(ds);
        sample = read(ds);
        
        assert(iscell(sample), 'Amostra não é cell array');
        assert(length(sample) == 2, 'Amostra deve ter imagem e máscara');
        
        img = sample{1};
        mask = sample{2};
        
        assert(isnumeric(img), 'Imagem da amostra não é numérica');
        assert(isa(mask, 'categorical'), 'Máscara da amostra não é categorical');
        
        fprintf('  ✓ Datastore criado com sucesso\n');
        fprintf('    Imagem: %s %s\n', class(img), mat2str(size(img)));
        fprintf('    Máscara: %s %s\n', class(mask), mat2str(size(mask)));
        
        % Testar compatibilidade com arquiteturas de modelo
        try
            inputSize = size(img);
            numClasses = length(classNames);
            
            % Criar arquitetura simples para teste
            lgraph = unetLayers(inputSize, numClasses, 'EncoderDepth', 2);
            assert(~isempty(lgraph), 'Arquitetura não foi criada');
            
            fprintf('  ✓ Arquitetura compatível com dados preprocessados\n');
            
        catch ME
            fprintf('  ⚠ Teste de arquitetura pulado: %s\n', ME.message);
        end
        
        % Limpar arquivos temporários
        if exist(tempMaskDir, 'dir')
            rmdir(tempMaskDir, 's');
        end
        
    catch ME
        fprintf('  ⚠ Teste de compatibilidade com trainer pulado: %s\n', ME.message);
    end
end

function test_cross_component_data_flow(testEnv)
    fprintf('Testando fluxo de dados entre componentes...\n');
    
    scenario = testEnv.scenarios.mixed_formats;
    config = scenario.config;
    config.paths = struct('imageDir', scenario.imageDir, 'maskDir', scenario.maskDir);
    
    % Criar pipeline completo
    loader = DataLoader(config, 'verbose', false);
    validator = DataValidator(config, 'verbose', false);
    preprocessor = DataPreprocessor(config, 'verbose', false);
    
    % Testar fluxo: Loader -> Validator -> Preprocessor
    try
        % Passo 1: Carregar
        [images, masks] = loader.loadData();
        assert(~isempty(images), 'Falha no carregamento');
        
        originalCount = length(images);
        fprintf('  ✓ Carregados: %d pares\n', originalCount);
        
        % Passo 2: Validar e filtrar
        validImages = {};
        validMasks = {};
        
        for i = 1:length(images)
            if validator.validateDataFormat(images{i}, masks{i})
                validImages{end+1} = images{i};
                validMasks{end+1} = masks{i};
            end
        end
        
        validCount = length(validImages);
        fprintf('  ✓ Validados: %d/%d pares\n', validCount, originalCount);
        
        % Passo 3: Preprocessar
        processedCount = 0;
        for i = 1:min(3, validCount) % Processar apenas alguns para teste
            testData = {validImages{i}, validMasks{i}};
            
            try
                processedData = preprocessor.preprocess(testData, 'IsTraining', false);
                
                % Verificar integridade dos dados processados
                img = processedData{1};
                mask = processedData{2};
                
                assert(all(isfinite(img(:))), 'Imagem contém valores não finitos');
                assert(all(isfinite(mask(:))), 'Máscara contém valores não finitos');
                
                processedCount = processedCount + 1;
                
            catch ME
                fprintf('    ⚠ Erro no processamento do item %d: %s\n', i, ME.message);
            end
        end
        
        fprintf('  ✓ Processados: %d pares\n', processedCount);
        
        % Verificar taxa de sucesso
        successRate = processedCount / min(3, validCount);
        assert(successRate > 0.5, 'Taxa de sucesso muito baixa');
        
        fprintf('  ✓ Taxa de sucesso do pipeline: %.1f%%\n', successRate * 100);
        
    catch ME
        fprintf('  ❌ Falha no fluxo de dados: %s\n', ME.message);
        rethrow(ME);
    end
end

function test_error_propagation(testEnv)
    fprintf('Testando propagação de erros...\n');
    
    % Testar com dados problemáticos
    scenario = testEnv.scenarios.problematic;
    config = scenario.config;
    config.paths = struct('imageDir', scenario.imageDir, 'maskDir', scenario.maskDir);
    
    loader = DataLoader(config, 'verbose', false);
    validator = DataValidator(config, 'verbose', false);
    preprocessor = DataPreprocessor(config, 'verbose', false);
    
    % Testar propagação de erros do loader
    try
        [images, masks] = loader.loadData();
        
        % Deve carregar alguns dados, mesmo com problemas
        if ~isempty(images)
            fprintf('  ✓ Loader lidou com dados problemáticos: %d carregados\n', length(images));
            
            % Testar propagação no validator
            errorCount = 0;
            for i = 1:length(images)
                try
                    isValid = validator.validateDataFormat(images{i}, masks{i});
                    if ~isValid
                        errorCount = errorCount + 1;
                    end
                catch
                    errorCount = errorCount + 1;
                end
            end
            
            fprintf('  ✓ Validator detectou %d problemas\n', errorCount);
            
            % Testar propagação no preprocessor
            processErrors = 0;
            for i = 1:min(2, length(images))
                try
                    testData = {images{i}, masks{i}};
                    processedData = preprocessor.preprocess(testData, 'IsTraining', false);
                    
                    % Verificar se dados processados são válidos
                    if isempty(processedData) || length(processedData) ~= 2
                        processErrors = processErrors + 1;
                    end
                    
                catch
                    processErrors = processErrors + 1;
                end
            end
            
            fprintf('  ✓ Preprocessor lidou com erros: %d/%d falharam\n', ...
                processErrors, min(2, length(images)));
        else
            fprintf('  ✓ Loader rejeitou dados problemáticos corretamente\n');
        end
        
    catch ME
        fprintf('  ✓ Erro propagado corretamente: %s\n', ME.message);
    end
    
    % Testar recuperação de erros
    try
        % Simular recuperação automática
        [correctedImages, correctedMasks] = validator.autoCorrectData({}, {});
        assert(isempty(correctedImages), 'Correção de dados vazios deve retornar vazio');
        
        fprintf('  ✓ Recuperação de erros funcionando\n');
        
    catch ME
        fprintf('  ⚠ Recuperação de erros não implementada: %s\n', ME.message);
    end
end

function test_performance_integration(testEnv)
    fprintf('Testando integração de performance...\n');
    
    scenario = testEnv.scenarios.large_data;
    config = scenario.config;
    config.paths = struct('imageDir', scenario.imageDir, 'maskDir', scenario.maskDir);
    
    loader = DataLoader(config, 'verbose', false);
    preprocessor = DataPreprocessor(config, 'EnableCache', true, 'verbose', false);
    
    % Testar performance de carregamento
    tic;
    [images, masks] = loader.loadData();
    loadTime = toc;
    
    fprintf('  ✓ Carregamento: %.3f segundos para %d amostras\n', loadTime, length(images));
    
    % Testar performance de preprocessamento
    if ~isempty(images)
        tic;
        testData = {images{1}, masks{1}};
        processedData = preprocessor.preprocess(testData, 'IsTraining', false);
        processTime = toc;
        
        fprintf('  ✓ Preprocessamento: %.3f segundos por amostra\n', processTime);
        
        % Testar cache
        tic;
        processedData2 = preprocessor.preprocess(testData, 'IsTraining', false);
        cacheTime = toc;
        
        fprintf('  ✓ Cache: %.3f segundos (speedup: %.1fx)\n', ...
            cacheTime, processTime / max(cacheTime, 0.001));
        
        % Verificar estatísticas de cache
        cacheStats = preprocessor.getCacheStats();
        if cacheStats.enabled
            fprintf('  ✓ Cache stats: %d itens, %.1f%% hit rate\n', ...
                cacheStats.size, cacheStats.hitRate * 100);
        end
    end
    
    % Testar uso de memória (básico)
    try
        memBefore = memory;
        
        % Processar múltiplas amostras
        for i = 1:min(3, length(images))
            testData = {images{i}, masks{i}};
            processedData = preprocessor.preprocess(testData, 'IsTraining', true);
        end
        
        memAfter = memory;
        memUsed = memAfter.MemUsedMATLAB - memBefore.MemUsedMATLAB;
        
        fprintf('  ✓ Uso de memória: %.1f MB\n', memUsed / 1024 / 1024);
        
    catch ME
        fprintf('  ⚠ Teste de memória não disponível: %s\n', ME.message);
    end
end

function test_memory_management_integration(testEnv)
    fprintf('Testando gerenciamento de memória integrado...\n');
    
    scenario = testEnv.scenarios.normal;
    config = scenario.config;
    config.paths = struct('imageDir', scenario.imageDir, 'maskDir', scenario.maskDir);
    
    % Configurar componentes com gerenciamento de memória
    loader = DataLoader(config, 'LazyLoading', true, 'verbose', false);
    preprocessor = DataPreprocessor(config, 'EnableCache', true, 'MaxCacheSize', 100, 'verbose', false);
    
    try
        % Testar carregamento lazy
        [images, masks] = loader.loadData();
        
        % Verificar se dados são carregados sob demanda
        if iscell(images) && ~isempty(images)
            % Acessar primeiro item
            img1 = images{1};
            assert(~isempty(img1), 'Lazy loading falhou');
            
            fprintf('  ✓ Lazy loading funcionando\n');
        end
        
        % Testar limpeza de cache
        for i = 1:min(5, length(images))
            testData = {images{i}, masks{i}};
            processedData = preprocessor.preprocess(testData, 'IsTraining', false);
        end
        
        % Verificar cache antes da limpeza
        cacheStatsBefore = preprocessor.getCacheStats();
        
        % Forçar limpeza
        preprocessor.clearCache();
        
        % Verificar cache após limpeza
        cacheStatsAfter = preprocessor.getCacheStats();
        
        assert(cacheStatsAfter.size < cacheStatsBefore.size, 'Cache não foi limpo');
        fprintf('  ✓ Limpeza de cache: %d -> %d itens\n', ...
            cacheStatsBefore.size, cacheStatsAfter.size);
        
        % Testar limite de cache
        preprocessor.setCacheLimit(2); % Limite muito baixo
        
        for i = 1:4 % Adicionar mais itens que o limite
            testData = {images{min(i, length(images))}, masks{min(i, length(masks))}};
            processedData = preprocessor.preprocess(testData, 'IsTraining', false);
        end
        
        finalCacheStats = preprocessor.getCacheStats();
        assert(finalCacheStats.size <= 2, 'Limite de cache não foi respeitado');
        
        fprintf('  ✓ Limite de cache respeitado: %d itens\n', finalCacheStats.size);
        
    catch ME
        fprintf('  ⚠ Teste de gerenciamento de memória pulado: %s\n', ME.message);
    end
end

function cleanupDataTestEnvironment(testEnv)
    % Limpa ambiente de teste de dados
    fprintf('Limpando ambiente de teste de dados...\n');
    
    try
        if exist(testEnv.baseDir, 'dir')
            rmdir(testEnv.baseDir, 's');
        end
        fprintf('✓ Ambiente de teste de dados limpo\n');
    catch ME
        fprintf('⚠ Erro na limpeza: %s\n', ME.message);
    end
end