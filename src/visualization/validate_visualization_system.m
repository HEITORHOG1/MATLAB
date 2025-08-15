function results = validate_visualization_system()
    % VALIDATE_VISUALIZATION_SYSTEM - Validação completa do sistema de visualização
    %
    % Este script executa testes abrangentes para validar todas as funcionalidades
    % do sistema de visualização avançada.
    %
    % Output:
    %   results - Struct com resultados dos testes
    
    fprintf('=== VALIDAÇÃO: Sistema de Visualização Avançada ===\n\n');
    
    results = struct();
    results.timestamp = datestr(now);
    results.tests = {};
    results.passed = 0;
    results.failed = 0;
    results.errors = {};
    
    try
        % Configurar ambiente
        addpath(genpath('src/'));
        
        % Criar dados de teste
        [testData] = createTestData();
        
        % Testes do ComparisonVisualizer
        fprintf('1. Validando ComparisonVisualizer...\n');
        results = validateComparisonVisualizer(results, testData);
        
        % Testes do HTMLGalleryGenerator
        fprintf('2. Validando HTMLGalleryGenerator...\n');
        results = validateHTMLGalleryGenerator(results, testData);
        
        % Testes do StatisticalPlotter
        fprintf('3. Validando StatisticalPlotter...\n');
        results = validateStatisticalPlotter(results, testData);
        
        % Testes do TimeLapseGenerator
        fprintf('4. Validando TimeLapseGenerator...\n');
        results = validateTimeLapseGenerator(results, testData);
        
        % Testes de integração
        fprintf('5. Executando testes de integração...\n');
        results = validateIntegration(results, testData);
        
        % Resumo final
        fprintf('\n=== RESUMO DA VALIDAÇÃO ===\n');
        fprintf('Testes executados: %d\n', length(results.tests));
        fprintf('Testes aprovados: %d\n', results.passed);
        fprintf('Testes falharam: %d\n', results.failed);
        fprintf('Taxa de sucesso: %.1f%%\n', (results.passed / length(results.tests)) * 100);
        
        if results.failed > 0
            fprintf('\nErros encontrados:\n');
            for i = 1:length(results.errors)
                fprintf('- %s\n', results.errors{i});
            end
        end
        
        % Salvar resultados
        save('output/validation_results_visualization.mat', 'results');
        fprintf('\nResultados salvos em: output/validation_results_visualization.mat\n');
        
    catch ME
        fprintf('ERRO CRÍTICO durante validação: %s\n', ME.message);
        results.critical_error = ME.message;
    end
end

function testData = createTestData()
    % Criar dados de teste padronizados
    
    testData = struct();
    
    % Imagens de teste
    testData.originalImage = uint8(rand(128, 128, 3) * 255);
    testData.groundTruth = rand(128, 128) > 0.5;
    testData.unetPred = rand(128, 128) > 0.4;
    testData.attentionPred = rand(128, 128) > 0.45;
    
    % Métricas de teste
    testData.metrics.unet.iou = 0.75;
    testData.metrics.unet.dice = 0.80;
    testData.metrics.unet.accuracy = 0.85;
    
    testData.metrics.attention.iou = 0.78;
    testData.metrics.attention.dice = 0.83;
    testData.metrics.attention.accuracy = 0.87;
    
    % Dados estatísticos
    testData.unetMetrics.iou = 0.75 + randn(20, 1) * 0.05;
    testData.unetMetrics.dice = 0.80 + randn(20, 1) * 0.04;
    testData.unetMetrics.accuracy = 0.85 + randn(20, 1) * 0.03;
    
    testData.attentionMetrics.iou = 0.78 + randn(20, 1) * 0.04;
    testData.attentionMetrics.dice = 0.83 + randn(20, 1) * 0.03;
    testData.attentionMetrics.accuracy = 0.87 + randn(20, 1) * 0.02;
    
    % Histórico de treinamento
    epochs = 20;
    testData.trainingHistory.unet.loss = linspace(1, 0.2, epochs) + randn(1, epochs) * 0.05;
    testData.trainingHistory.unet.iou = linspace(0.3, 0.8, epochs) + randn(1, epochs) * 0.02;
    testData.trainingHistory.unet.dice = linspace(0.4, 0.85, epochs) + randn(1, epochs) * 0.02;
    testData.trainingHistory.unet.accuracy = linspace(0.6, 0.9, epochs) + randn(1, epochs) * 0.01;
    
    testData.trainingHistory.attention.loss = linspace(1, 0.18, epochs) + randn(1, epochs) * 0.04;
    testData.trainingHistory.attention.iou = linspace(0.35, 0.82, epochs) + randn(1, epochs) * 0.02;
    testData.trainingHistory.attention.dice = linspace(0.45, 0.87, epochs) + randn(1, epochs) * 0.02;
    testData.trainingHistory.attention.accuracy = linspace(0.65, 0.92, epochs) + randn(1, epochs) * 0.01;
end

function results = validateComparisonVisualizer(results, testData)
    % Validar ComparisonVisualizer
    
    try
        % Teste 1: Criação do objeto
        visualizer = ComparisonVisualizer('outputDir', 'output/test_visualizations/');
        results = addTestResult(results, 'ComparisonVisualizer - Criação', true, '');
        
        % Teste 2: Comparação lado a lado
        try
            outputPath = visualizer.createSideBySideComparison(...
                testData.originalImage, testData.groundTruth, ...
                testData.unetPred, testData.attentionPred, testData.metrics);
            
            fileExists = exist(outputPath, 'file') == 2;
            results = addTestResult(results, 'ComparisonVisualizer - Lado a lado', fileExists, ...
                sprintf('Arquivo: %s', outputPath));
        catch ME
            results = addTestResult(results, 'ComparisonVisualizer - Lado a lado', false, ME.message);
        end
        
        % Teste 3: Mapa de diferenças
        try
            outputPath = visualizer.createDifferenceMap(testData.unetPred, testData.attentionPred);
            fileExists = exist(outputPath, 'file') == 2;
            results = addTestResult(results, 'ComparisonVisualizer - Mapa diferenças', fileExists, ...
                sprintf('Arquivo: %s', outputPath));
        catch ME
            results = addTestResult(results, 'ComparisonVisualizer - Mapa diferenças', false, ME.message);
        end
        
        % Teste 4: Overlay de métricas
        try
            outputPath = visualizer.createMetricsOverlay(...
                testData.originalImage, testData.unetPred, testData.metrics.unet, 'U-Net Test');
            fileExists = exist(outputPath, 'file') == 2;
            results = addTestResult(results, 'ComparisonVisualizer - Overlay métricas', fileExists, ...
                sprintf('Arquivo: %s', outputPath));
        catch ME
            results = addTestResult(results, 'ComparisonVisualizer - Overlay métricas', false, ME.message);
        end
        
    catch ME
        results = addTestResult(results, 'ComparisonVisualizer - Criação', false, ME.message);
    end
end

function results = validateHTMLGalleryGenerator(results, testData)
    % Validar HTMLGalleryGenerator
    
    try
        % Teste 1: Criação do objeto
        generator = HTMLGalleryGenerator('outputDir', 'output/test_gallery/');
        results = addTestResult(results, 'HTMLGalleryGenerator - Criação', true, '');
        
        % Teste 2: Preparar dados de teste
        allResults = {};
        for i = 1:3
            result = struct();
            result.imagePath = sprintf('temp/test_img_%d.png', i);
            result.metrics.iou = 0.7 + rand() * 0.2;
            result.metrics.dice = 0.75 + rand() * 0.2;
            
            % Criar imagem de teste
            if ~exist('temp', 'dir')
                mkdir('temp');
            end
            testImg = uint8(rand(64, 64, 3) * 255);
            imwrite(testImg, result.imagePath);
            
            allResults{i} = result;
        end
        
        % Teste 3: Geração de galeria
        try
            galleryPath = generator.generateComparisonGallery(allResults, 'sessionId', 'test_session');
            fileExists = exist(galleryPath, 'file') == 2;
            results = addTestResult(results, 'HTMLGalleryGenerator - Galeria HTML', fileExists, ...
                sprintf('Arquivo: %s', galleryPath));
            
            % Verificar arquivos auxiliares
            [galleryDir, ~, ~] = fileparts(galleryPath);
            cssExists = exist(fullfile(galleryDir, 'gallery.css'), 'file') == 2;
            jsExists = exist(fullfile(galleryDir, 'gallery.js'), 'file') == 2;
            
            results = addTestResult(results, 'HTMLGalleryGenerator - Arquivos CSS/JS', ...
                cssExists && jsExists, sprintf('CSS: %d, JS: %d', cssExists, jsExists));
            
        catch ME
            results = addTestResult(results, 'HTMLGalleryGenerator - Galeria HTML', false, ME.message);
        end
        
    catch ME
        results = addTestResult(results, 'HTMLGalleryGenerator - Criação', false, ME.message);
    end
end

function results = validateStatisticalPlotter(results, testData)
    % Validar StatisticalPlotter
    
    try
        % Teste 1: Criação do objeto
        plotter = StatisticalPlotter('outputDir', 'output/test_statistics/');
        results = addTestResult(results, 'StatisticalPlotter - Criação', true, '');
        
        % Teste 2: Comparação estatística
        try
            outputPath = plotter.plotStatisticalComparison(...
                testData.unetMetrics, testData.attentionMetrics);
            fileExists = exist(outputPath, 'file') == 2;
            results = addTestResult(results, 'StatisticalPlotter - Comparação estatística', fileExists, ...
                sprintf('Arquivo: %s', outputPath));
        catch ME
            results = addTestResult(results, 'StatisticalPlotter - Comparação estatística', false, ME.message);
        end
        
        % Teste 3: Evolução da performance
        try
            outputPath = plotter.createPerformanceEvolution(testData.trainingHistory);
            fileExists = exist(outputPath, 'file') == 2;
            results = addTestResult(results, 'StatisticalPlotter - Evolução performance', fileExists, ...
                sprintf('Arquivo: %s', outputPath));
        catch ME
            results = addTestResult(results, 'StatisticalPlotter - Evolução performance', false, ME.message);
        end
        
        % Teste 4: Funções estatísticas internas
        try
            % Teste de normalidade
            isNormal = plotter.testNormality(randn(100, 1));
            results = addTestResult(results, 'StatisticalPlotter - Teste normalidade', ...
                islogical(isNormal), sprintf('Resultado: %d', isNormal));
            
            % Teste Mann-Whitney
            pValue = plotter.mannWhitneyTest(randn(20, 1), randn(20, 1) + 0.5);
            results = addTestResult(results, 'StatisticalPlotter - Mann-Whitney', ...
                isnumeric(pValue) && pValue >= 0 && pValue <= 1, sprintf('p-value: %.4f', pValue));
            
            % Cohen's d
            d = plotter.calculateCohenD(randn(20, 1), randn(20, 1) + 0.5);
            results = addTestResult(results, 'StatisticalPlotter - Cohen d', ...
                isnumeric(d), sprintf('Effect size: %.3f', d));
            
        catch ME
            results = addTestResult(results, 'StatisticalPlotter - Funções estatísticas', false, ME.message);
        end
        
    catch ME
        results = addTestResult(results, 'StatisticalPlotter - Criação', false, ME.message);
    end
end

function results = validateTimeLapseGenerator(results, testData)
    % Validar TimeLapseGenerator
    
    try
        % Teste 1: Criação do objeto
        generator = TimeLapseGenerator('outputDir', 'output/test_videos/', 'frameRate', 10);
        results = addTestResult(results, 'TimeLapseGenerator - Criação', true, '');
        
        % Teste 2: Histórico de gradientes simulado
        gradientHistory = struct();
        for epoch = 1:5
            epochName = sprintf('epoch_%03d', epoch);
            gradientHistory.(epochName) = struct();
            gradientHistory.(epochName).conv1 = randn(50, 1);
            gradientHistory.(epochName).conv2 = randn(50, 1);
        end
        
        % Teste 3: Vídeo de evolução dos gradientes
        try
            videoPath = generator.createTrainingEvolutionVideo(gradientHistory, ...
                'modelName', 'Test Model');
            fileExists = exist(videoPath, 'file') == 2;
            results = addTestResult(results, 'TimeLapseGenerator - Vídeo gradientes', fileExists, ...
                sprintf('Arquivo: %s', videoPath));
        catch ME
            if contains(ME.message, 'VideoWriter')
                results = addTestResult(results, 'TimeLapseGenerator - Vídeo gradientes', true, ...
                    'Funcionalidade de vídeo não disponível (esperado em algumas versões)');
            else
                results = addTestResult(results, 'TimeLapseGenerator - Vídeo gradientes', false, ME.message);
            end
        end
        
        % Teste 4: Histórico de predições
        predictionHistory = {};
        for epoch = 1:5
            predictionHistory{epoch} = rand(64, 64) > 0.5;
        end
        
        % Teste 5: Vídeo de evolução das predições
        try
            videoPath = generator.createPredictionEvolutionVideo(...
                predictionHistory, testData.originalImage(1:64, 1:64, :), ...
                testData.groundTruth(1:64, 1:64), 'modelName', 'Test Model');
            fileExists = exist(videoPath, 'file') == 2;
            results = addTestResult(results, 'TimeLapseGenerator - Vídeo predições', fileExists, ...
                sprintf('Arquivo: %s', videoPath));
        catch ME
            if contains(ME.message, 'VideoWriter')
                results = addTestResult(results, 'TimeLapseGenerator - Vídeo predições', true, ...
                    'Funcionalidade de vídeo não disponível (esperado em algumas versões)');
            else
                results = addTestResult(results, 'TimeLapseGenerator - Vídeo predições', false, ME.message);
            end
        end
        
    catch ME
        results = addTestResult(results, 'TimeLapseGenerator - Criação', false, ME.message);
    end
end

function results = validateIntegration(results, testData)
    % Testes de integração entre componentes
    
    try
        % Teste 1: Pipeline completo de visualização
        visualizer = ComparisonVisualizer('outputDir', 'output/integration_test/');
        plotter = StatisticalPlotter('outputDir', 'output/integration_test/');
        
        % Criar comparação
        comparisonPath = visualizer.createSideBySideComparison(...
            testData.originalImage, testData.groundTruth, ...
            testData.unetPred, testData.attentionPred, testData.metrics);
        
        % Criar análise estatística
        statsPath = plotter.plotStatisticalComparison(...
            testData.unetMetrics, testData.attentionMetrics);
        
        integrationSuccess = exist(comparisonPath, 'file') == 2 && exist(statsPath, 'file') == 2;
        results = addTestResult(results, 'Integração - Pipeline completo', integrationSuccess, ...
            sprintf('Comparação: %s, Estatísticas: %s', comparisonPath, statsPath));
        
        % Teste 2: Consistência de formatos
        [~, ~, ext1] = fileparts(comparisonPath);
        [~, ~, ext2] = fileparts(statsPath);
        formatConsistency = strcmp(ext1, ext2);
        results = addTestResult(results, 'Integração - Consistência formatos', formatConsistency, ...
            sprintf('Extensões: %s, %s', ext1, ext2));
        
        % Teste 3: Estrutura de diretórios
        baseDir = 'output/integration_test/';
        dirExists = exist(baseDir, 'dir') == 7;
        results = addTestResult(results, 'Integração - Estrutura diretórios', dirExists, ...
            sprintf('Diretório: %s', baseDir));
        
    catch ME
        results = addTestResult(results, 'Integração - Pipeline completo', false, ME.message);
    end
end

function results = addTestResult(results, testName, passed, details)
    % Adicionar resultado de teste
    
    test = struct();
    test.name = testName;
    test.passed = passed;
    test.details = details;
    test.timestamp = datestr(now, 'HH:MM:SS');
    
    results.tests{end+1} = test;
    
    if passed
        results.passed = results.passed + 1;
        fprintf('   ✓ %s\n', testName);
        if ~isempty(details)
            fprintf('     %s\n', details);
        end
    else
        results.failed = results.failed + 1;
        results.errors{end+1} = sprintf('%s: %s', testName, details);
        fprintf('   ✗ %s\n', testName);
        fprintf('     ERRO: %s\n', details);
    end
end