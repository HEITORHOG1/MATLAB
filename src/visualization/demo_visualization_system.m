function demo_visualization_system()
    % DEMO_VISUALIZATION_SYSTEM - Demonstração completa do sistema de visualização
    %
    % Este script demonstra todas as funcionalidades do sistema de visualização:
    % - ComparisonVisualizer para comparações lado a lado
    % - HTMLGalleryGenerator para galerias interativas
    % - StatisticalPlotter para análises estatísticas
    % - TimeLapseGenerator para vídeos time-lapse
    
    fprintf('=== DEMO: Sistema de Visualização Avançada ===\n\n');
    
    try
        % Configurar ambiente
        addpath(genpath('src/'));
        
        % Criar dados de exemplo
        fprintf('1. Criando dados de exemplo...\n');
        [originalImage, groundTruth, unetPred, attentionPred, metrics, trainingHistory] = createSampleData();
        
        % Demonstrar ComparisonVisualizer
        fprintf('2. Testando ComparisonVisualizer...\n');
        demoComparisonVisualizer(originalImage, groundTruth, unetPred, attentionPred, metrics);
        
        % Demonstrar HTMLGalleryGenerator
        fprintf('3. Testando HTMLGalleryGenerator...\n');
        demoHTMLGalleryGenerator();
        
        % Demonstrar StatisticalPlotter
        fprintf('4. Testando StatisticalPlotter...\n');
        demoStatisticalPlotter(metrics, trainingHistory);
        
        % Demonstrar TimeLapseGenerator
        fprintf('5. Testando TimeLapseGenerator...\n');
        demoTimeLapseGenerator(originalImage, groundTruth, trainingHistory);
        
        fprintf('\n=== DEMO CONCLUÍDO COM SUCESSO ===\n');
        fprintf('Verifique os arquivos gerados em:\n');
        fprintf('- output/visualizations/\n');
        fprintf('- output/gallery/\n');
        fprintf('- output/statistics/\n');
        fprintf('- output/videos/\n\n');
        
    catch ME
        fprintf('ERRO durante demonstração: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function [originalImage, groundTruth, unetPred, attentionPred, metrics, trainingHistory] = createSampleData()
    % Criar dados sintéticos para demonstração
    
    % Imagem original (256x256 RGB)
    originalImage = uint8(rand(256, 256, 3) * 255);
    
    % Ground truth (máscara binária)
    [X, Y] = meshgrid(1:256, 1:256);
    center = [128, 128];
    radius = 50;
    groundTruth = sqrt((X - center(1)).^2 + (Y - center(2)).^2) < radius;
    
    % Predições simuladas (com ruído)
    unetPred = groundTruth;
    % Adicionar ruído ao U-Net
    noise1 = rand(256, 256) > 0.95;
    unetPred = unetPred | noise1;
    unetPred = unetPred & ~(rand(256, 256) > 0.98);
    
    attentionPred = groundTruth;
    % Adicionar ruído diferente ao Attention U-Net
    noise2 = rand(256, 256) > 0.97;
    attentionPred = attentionPred | noise2;
    attentionPred = attentionPred & ~(rand(256, 256) > 0.99);
    
    % Calcular métricas
    metrics = struct();
    
    % Métricas U-Net
    unet_intersection = sum(sum(unetPred & groundTruth));
    unet_union = sum(sum(unetPred | groundTruth));
    metrics.unet.iou = unet_intersection / unet_union;
    metrics.unet.dice = 2 * unet_intersection / (sum(sum(unetPred)) + sum(sum(groundTruth)));
    metrics.unet.accuracy = sum(sum(unetPred == groundTruth)) / numel(groundTruth);
    
    % Métricas Attention U-Net
    att_intersection = sum(sum(attentionPred & groundTruth));
    att_union = sum(sum(attentionPred | groundTruth));
    metrics.attention.iou = att_intersection / att_union;
    metrics.attention.dice = 2 * att_intersection / (sum(sum(attentionPred)) + sum(sum(groundTruth)));
    metrics.attention.accuracy = sum(sum(attentionPred == groundTruth)) / numel(groundTruth);
    
    % Histórico de treinamento simulado
    numEpochs = 50;
    trainingHistory = struct();
    
    % U-Net history
    trainingHistory.unet.loss = 1 - linspace(0.3, 0.9, numEpochs) + randn(1, numEpochs) * 0.05;
    trainingHistory.unet.iou = linspace(0.3, 0.85, numEpochs) + randn(1, numEpochs) * 0.02;
    trainingHistory.unet.dice = linspace(0.4, 0.88, numEpochs) + randn(1, numEpochs) * 0.02;
    trainingHistory.unet.accuracy = linspace(0.7, 0.92, numEpochs) + randn(1, numEpochs) * 0.01;
    
    % Attention U-Net history (ligeiramente melhor)
    trainingHistory.attention.loss = 1 - linspace(0.35, 0.92, numEpochs) + randn(1, numEpochs) * 0.04;
    trainingHistory.attention.iou = linspace(0.35, 0.88, numEpochs) + randn(1, numEpochs) * 0.02;
    trainingHistory.attention.dice = linspace(0.45, 0.91, numEpochs) + randn(1, numEpochs) * 0.02;
    trainingHistory.attention.accuracy = linspace(0.72, 0.94, numEpochs) + randn(1, numEpochs) * 0.01;
    
    fprintf('   - Dados sintéticos criados com sucesso\n');
end

function demoComparisonVisualizer(originalImage, groundTruth, unetPred, attentionPred, metrics)
    % Demonstrar funcionalidades do ComparisonVisualizer
    
    try
        % Criar visualizador
        visualizer = ComparisonVisualizer('outputDir', 'output/visualizations/');
        
        % Comparação lado a lado
        fprintf('   - Criando comparação lado a lado...\n');
        sideBySidePath = visualizer.createSideBySideComparison(...
            originalImage, groundTruth, unetPred, attentionPred, metrics, ...
            'title', 'Demonstração - Comparação de Modelos');
        
        % Mapa de diferenças
        fprintf('   - Criando mapa de diferenças...\n');
        diffMapPath = visualizer.createDifferenceMap(unetPred, attentionPred, ...
            'title', 'Demonstração - Mapa de Diferenças');
        
        % Overlay de métricas para U-Net
        fprintf('   - Criando overlay de métricas (U-Net)...\n');
        unetOverlayPath = visualizer.createMetricsOverlay(...
            originalImage, unetPred, metrics.unet, 'U-Net');
        
        % Overlay de métricas para Attention U-Net
        fprintf('   - Criando overlay de métricas (Attention U-Net)...\n');
        attentionOverlayPath = visualizer.createMetricsOverlay(...
            originalImage, attentionPred, metrics.attention, 'Attention U-Net');
        
        fprintf('   ✓ ComparisonVisualizer testado com sucesso\n');
        
    catch ME
        fprintf('   ✗ Erro no ComparisonVisualizer: %s\n', ME.message);
    end
end

function demoHTMLGalleryGenerator()
    % Demonstrar funcionalidades do HTMLGalleryGenerator
    
    try
        % Criar gerador de galeria
        generator = HTMLGalleryGenerator('outputDir', 'output/gallery/');
        
        % Criar dados de exemplo para galeria
        allResults = {};
        for i = 1:5
            result = struct();
            result.imagePath = sprintf('temp/demo_image_%03d.png', i);
            result.comparisonPath = sprintf('temp/demo_comparison_%03d.png', i);
            result.metrics.iou = 0.7 + rand() * 0.2;
            result.metrics.dice = 0.75 + rand() * 0.2;
            
            % Criar imagens de exemplo se não existirem
            if ~exist(result.imagePath, 'file')
                if ~exist('temp', 'dir')
                    mkdir('temp');
                end
                demoImg = uint8(rand(128, 128, 3) * 255);
                imwrite(demoImg, result.imagePath);
            end
            
            if ~exist(result.comparisonPath, 'file')
                demoComp = uint8(rand(256, 128, 3) * 255);
                imwrite(demoComp, result.comparisonPath);
            end
            
            allResults{i} = result;
        end
        
        % Gerar galeria HTML
        fprintf('   - Gerando galeria HTML interativa...\n');
        galleryPath = generator.generateComparisonGallery(allResults, ...
            'sessionId', 'demo_session');
        
        fprintf('   ✓ HTMLGalleryGenerator testado com sucesso\n');
        fprintf('     Galeria disponível em: %s\n', galleryPath);
        
    catch ME
        fprintf('   ✗ Erro no HTMLGalleryGenerator: %s\n', ME.message);
    end
end

function demoStatisticalPlotter(metrics, trainingHistory)
    % Demonstrar funcionalidades do StatisticalPlotter
    
    try
        % Criar plotter estatístico
        plotter = StatisticalPlotter('outputDir', 'output/statistics/');
        
        % Gerar dados de múltiplas execuções para análise estatística
        numSamples = 30;
        
        unetMetrics = struct();
        unetMetrics.iou = metrics.unet.iou + randn(numSamples, 1) * 0.05;
        unetMetrics.dice = metrics.unet.dice + randn(numSamples, 1) * 0.04;
        unetMetrics.accuracy = metrics.unet.accuracy + randn(numSamples, 1) * 0.03;
        
        attentionMetrics = struct();
        attentionMetrics.iou = metrics.attention.iou + randn(numSamples, 1) * 0.04;
        attentionMetrics.dice = metrics.attention.dice + randn(numSamples, 1) * 0.03;
        attentionMetrics.accuracy = metrics.attention.accuracy + randn(numSamples, 1) * 0.02;
        
        % Comparação estatística
        fprintf('   - Criando gráficos de comparação estatística...\n');
        statsPath = plotter.plotStatisticalComparison(unetMetrics, attentionMetrics, ...
            'title', 'Demonstração - Análise Estatística Comparativa');
        
        % Evolução da performance
        fprintf('   - Criando gráfico de evolução da performance...\n');
        evolutionPath = plotter.createPerformanceEvolution(trainingHistory, ...
            'title', 'Demonstração - Evolução do Treinamento');
        
        fprintf('   ✓ StatisticalPlotter testado com sucesso\n');
        
    catch ME
        fprintf('   ✗ Erro no StatisticalPlotter: %s\n', ME.message);
    end
end

function demoTimeLapseGenerator(originalImage, groundTruth, trainingHistory)
    % Demonstrar funcionalidades do TimeLapseGenerator
    
    try
        % Criar gerador de time-lapse
        generator = TimeLapseGenerator('outputDir', 'output/videos/', 'frameRate', 5);
        
        % Criar histórico de gradientes simulado
        fprintf('   - Criando histórico de gradientes simulado...\n');
        gradientHistory = struct();
        for epoch = 1:10
            epochName = sprintf('epoch_%03d', epoch);
            gradientHistory.(epochName) = struct();
            gradientHistory.(epochName).conv1 = randn(100, 1) * (1 - epoch/15);
            gradientHistory.(epochName).conv2 = randn(100, 1) * (1 - epoch/12);
            gradientHistory.(epochName).conv3 = randn(100, 1) * (1 - epoch/10);
        end
        
        % Vídeo de evolução dos gradientes
        fprintf('   - Criando vídeo de evolução dos gradientes...\n');
        gradientVideoPath = generator.createTrainingEvolutionVideo(gradientHistory, ...
            'title', 'Demonstração - Evolução dos Gradientes', ...
            'modelName', 'U-Net Demo');
        
        % Criar histórico de predições simulado
        fprintf('   - Criando histórico de predições simulado...\n');
        predictionHistory = {};
        for epoch = 1:10
            % Simular melhoria gradual da predição
            noise_level = 0.3 * (1 - epoch/12);
            pred = groundTruth;
            noise = rand(size(groundTruth)) < noise_level;
            pred = pred & ~noise;
            predictionHistory{epoch} = pred;
        end
        
        % Vídeo de evolução das predições
        fprintf('   - Criando vídeo de evolução das predições...\n');
        predVideoPath = generator.createPredictionEvolutionVideo(...
            predictionHistory, originalImage, groundTruth, ...
            'title', 'Demonstração - Evolução das Predições', ...
            'modelName', 'U-Net Demo');
        
        fprintf('   ✓ TimeLapseGenerator testado com sucesso\n');
        
    catch ME
        fprintf('   ✗ Erro no TimeLapseGenerator: %s\n', ME.message);
        if contains(ME.message, 'VideoWriter')
            fprintf('     Nota: Funcionalidade de vídeo pode não estar disponível nesta versão do MATLAB\n');
        end
    end
end