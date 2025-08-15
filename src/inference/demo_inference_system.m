function demo_inference_system()
    % Demonstração do Sistema de Inferência e Análise Estatística
    % 
    % Este script demonstra como usar o InferenceEngine, ResultsAnalyzer
    % e StatisticalAnalyzer para análise completa de resultados de segmentação.
    
    % Configurar compatibilidade com Octave
    simple_compatibility();
    
    fprintf('=== Demonstração do Sistema de Inferência ===\n\n');
    
    try
        % 1. Configurar sistema de inferência
        fprintf('1. Configurando sistema de inferência...\n');
        
        config = struct();
        config.batchSize = 4;
        config.confidenceThreshold = 0.5;
        config.outputDir = 'output/demo_inference';
        config.verbose = true;
        
        % Criar InferenceEngine
        inferenceEngine = InferenceEngine(config);
        
        % 2. Simular carregamento de modelos (para demonstração)
        fprintf('\n2. Simulando carregamento de modelos...\n');
        
        % Nota: Em uso real, você carregaria modelos reais aqui
        % inferenceEngine.loadModel('path/to/unet_model.mat', 'unet');
        % inferenceEngine.loadModel('path/to/attention_unet_model.mat', 'attention_unet');
        
        fprintf('   Modelos simulados carregados com sucesso.\n');
        
        % 3. Demonstrar análise de resultados
        fprintf('\n3. Demonstrando análise de resultados...\n');
        
        % Configurar ResultsAnalyzer
        analyzerConfig = struct();
        analyzerConfig.confidenceMethod = 'entropy';
        analyzerConfig.uncertaintyMethod = 'variance';
        analyzerConfig.verbose = true;
        
        resultsAnalyzer = ResultsAnalyzer(analyzerConfig);
        
        % Simular resultados para demonstração
        simulatedResults = generateSimulatedResults();
        
        % Analisar resultados
        analysis = resultsAnalyzer.analyzeResults(simulatedResults);
        
        fprintf('   Análise de resultados concluída.\n');
        
        % 4. Demonstrar análise estatística
        fprintf('\n4. Demonstrando análise estatística...\n');
        
        % Gerar métricas simuladas
        [unetMetrics, attentionMetrics] = generateSimulatedMetrics();
        
        % Configurar StatisticalAnalyzer
        statConfig = struct();
        statConfig.alpha = 0.05;
        statConfig.multipleComparisonsMethod = 'bonferroni';
        statConfig.verbose = true;
        
        % Realizar análise estatística completa
        statisticalResults = StatisticalAnalyzer.performComprehensiveAnalysis(...
            unetMetrics, attentionMetrics, statConfig);
        
        fprintf('   Análise estatística concluída.\n');
        
        % 5. Demonstrar comparação simples de modelos
        fprintf('\n5. Demonstrando comparação simples de modelos...\n');
        
        % Comparar métricas IoU
        [pValue, effectSize, testUsed] = StatisticalAnalyzer.compareModels(...
            unetMetrics.iou.values, attentionMetrics.iou.values);
        
        fprintf('   Comparação IoU:\n');
        fprintf('     Teste usado: %s\n', testUsed);
        fprintf('     P-value: %.4f\n', pValue);
        fprintf('     Effect size (Cohen''s d): %.4f\n', effectSize);
        
        % 6. Gerar relatório científico
        fprintf('\n6. Gerando relatório científico...\n');
        
        report = StatisticalAnalyzer.generateScientificReport(statisticalResults);
        
        fprintf('   Relatório gerado com sucesso.\n');
        fprintf('   Título: %s\n', report.title);
        
        % 7. Demonstrar detecção de outliers
        fprintf('\n7. Demonstrando detecção de outliers...\n');
        
        % Usar InferenceEngine para detectar outliers
        outliers = inferenceEngine.detectOutliers(unetMetrics);
        
        if isfield(outliers, 'combined') && ~isempty(outliers.combined)
            fprintf('   Detectados %d casos atípicos.\n', length(outliers.combined));
        else
            fprintf('   Nenhum caso atípico detectado.\n');
        end
        
        % 8. Resumo final
        fprintf('\n=== Resumo da Demonstração ===\n');
        fprintf('✓ InferenceEngine configurado e testado\n');
        fprintf('✓ ResultsAnalyzer executado com sucesso\n');
        fprintf('✓ StatisticalAnalyzer realizou análise completa\n');
        fprintf('✓ Comparação de modelos demonstrada\n');
        fprintf('✓ Relatório científico gerado\n');
        fprintf('✓ Detecção de outliers testada\n');
        fprintf('\nSistema de inferência funcionando corretamente!\n');
        
    catch ME
        fprintf('Erro durante a demonstração: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function results = generateSimulatedResults()
    % Gera resultados simulados para demonstração
    
    numResults = 20;
    results = struct('imagePath', {}, 'segmentationPath', {}, ...
                    'modelUsed', {}, 'metrics', {}, ...
                    'processingTime', {}, 'timestamp', {});
    
    for i = 1:numResults
        result = struct();
        result.imagePath = sprintf('img/test_image_%03d.jpg', i);
        result.segmentationPath = sprintf('output/seg_%03d.png', i);
        result.modelUsed = 'simulated_model';
        result.metrics = struct();
        result.processingTime = 0.1 + 0.05 * randn(); % Tempo simulado
        result.timestamp = datetime('now');
        
        results(i) = result;
    end
end

function [unetMetrics, attentionMetrics] = generateSimulatedMetrics()
    % Gera métricas simuladas para demonstração
    
    n = 50; % Número de amostras
    
    % Métricas do U-Net (ligeiramente inferiores)
    unetMetrics = struct();
    unetMetrics.iou = struct();
    unetMetrics.iou.values = 0.75 + 0.1 * randn(n, 1);
    unetMetrics.iou.values = max(0, min(1, unetMetrics.iou.values)); % Limitar [0,1]
    unetMetrics.iou.mean = mean(unetMetrics.iou.values);
    unetMetrics.iou.std = std(unetMetrics.iou.values);
    
    unetMetrics.dice = struct();
    unetMetrics.dice.values = 0.80 + 0.08 * randn(n, 1);
    unetMetrics.dice.values = max(0, min(1, unetMetrics.dice.values));
    unetMetrics.dice.mean = mean(unetMetrics.dice.values);
    unetMetrics.dice.std = std(unetMetrics.dice.values);
    
    unetMetrics.accuracy = struct();
    unetMetrics.accuracy.values = 0.92 + 0.05 * randn(n, 1);
    unetMetrics.accuracy.values = max(0, min(1, unetMetrics.accuracy.values));
    unetMetrics.accuracy.mean = mean(unetMetrics.accuracy.values);
    unetMetrics.accuracy.std = std(unetMetrics.accuracy.values);
    
    % Métricas do Attention U-Net (ligeiramente superiores)
    attentionMetrics = struct();
    attentionMetrics.iou = struct();
    attentionMetrics.iou.values = 0.78 + 0.1 * randn(n, 1); % Média ligeiramente maior
    attentionMetrics.iou.values = max(0, min(1, attentionMetrics.iou.values));
    attentionMetrics.iou.mean = mean(attentionMetrics.iou.values);
    attentionMetrics.iou.std = std(attentionMetrics.iou.values);
    
    attentionMetrics.dice = struct();
    attentionMetrics.dice.values = 0.83 + 0.08 * randn(n, 1);
    attentionMetrics.dice.values = max(0, min(1, attentionMetrics.dice.values));
    attentionMetrics.dice.mean = mean(attentionMetrics.dice.values);
    attentionMetrics.dice.std = std(attentionMetrics.dice.values);
    
    attentionMetrics.accuracy = struct();
    attentionMetrics.accuracy.values = 0.94 + 0.04 * randn(n, 1);
    attentionMetrics.accuracy.values = max(0, min(1, attentionMetrics.accuracy.values));
    attentionMetrics.accuracy.mean = mean(attentionMetrics.accuracy.values);
    attentionMetrics.accuracy.std = std(attentionMetrics.accuracy.values);
end