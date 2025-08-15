function validate_inference_system()
    % Validação do Sistema de Inferência e Análise Estatística
    % 
    % Este script valida todas as funcionalidades do sistema de inferência
    % para garantir que estão funcionando corretamente.
    
    % Configurar compatibilidade com Octave
    simple_compatibility();
    
    fprintf('=== Validação do Sistema de Inferência ===\n\n');
    
    allTestsPassed = true;
    
    try
        % Teste 1: InferenceEngine
        fprintf('Teste 1: Validando InferenceEngine...\n');
        testPassed = testInferenceEngine();
        allTestsPassed = allTestsPassed && testPassed;
        
        % Teste 2: ResultsAnalyzer
        fprintf('Teste 2: Validando ResultsAnalyzer...\n');
        testPassed = testResultsAnalyzer();
        allTestsPassed = allTestsPassed && testPassed;
        
        % Teste 3: StatisticalAnalyzer
        fprintf('Teste 3: Validando StatisticalAnalyzer...\n');
        testPassed = testStatisticalAnalyzer();
        allTestsPassed = allTestsPassed && testPassed;
        
        % Teste 4: Integração
        fprintf('Teste 4: Validando integração entre componentes...\n');
        testPassed = testIntegration();
        allTestsPassed = allTestsPassed && testPassed;
        
        % Resultado final
        fprintf('\n=== Resultado da Validação ===\n');
        if allTestsPassed
            fprintf('✓ Todos os testes passaram! Sistema funcionando corretamente.\n');
        else
            fprintf('✗ Alguns testes falharam. Verifique os erros acima.\n');
        end
        
    catch ME
        fprintf('Erro durante a validação: %s\n', ME.message);
        allTestsPassed = false;
    end
end

function passed = testInferenceEngine()
    % Testa funcionalidades do InferenceEngine
    
    passed = true;
    
    try
        % Criar InferenceEngine
        config = struct('batchSize', 2, 'verbose', false);
        engine = InferenceEngine(config);
        
        % Testar propriedades
        assert(engine.batchSize == 2, 'Batch size não configurado corretamente');
        assert(~engine.verbose, 'Verbose não configurado corretamente');
        
        % Testar geração de estatísticas com dados simulados
        mockResults = generateMockResults();
        stats = engine.generateStatistics({mockResults});
        
        assert(isfield(stats, 'totalSamples'), 'Estatísticas não contêm totalSamples');
        assert(isfield(stats, 'timestamp'), 'Estatísticas não contêm timestamp');
        
        % Testar detecção de outliers
        mockMetrics = generateMockMetrics();
        outliers = engine.detectOutliers(mockMetrics);
        
        assert(isfield(outliers, 'combined'), 'Outliers não contêm campo combined');
        
        fprintf('  ✓ InferenceEngine passou em todos os testes\n');
        
    catch ME
        fprintf('  ✗ InferenceEngine falhou: %s\n', ME.message);
        passed = false;
    end
end

function passed = testResultsAnalyzer()
    % Testa funcionalidades do ResultsAnalyzer
    
    passed = true;
    
    try
        % Criar ResultsAnalyzer
        config = struct('verbose', false);
        analyzer = ResultsAnalyzer(config);
        
        % Testar propriedades
        assert(strcmp(analyzer.confidenceMethod, 'entropy'), 'Método de confiança padrão incorreto');
        assert(strcmp(analyzer.uncertaintyMethod, 'variance'), 'Método de incerteza padrão incorreto');
        
        % Testar cálculo de confiança e incerteza
        mockResults = generateMockResults();
        [confidence, uncertainty] = analyzer.calculateConfidenceUncertainty(mockResults);
        
        assert(length(confidence) == length(mockResults), 'Tamanho do array de confiança incorreto');
        assert(length(uncertainty) == length(mockResults), 'Tamanho do array de incerteza incorreto');
        
        % Testar detecção de anomalias
        outliers = analyzer.detectAnomalousResults(mockResults, confidence, uncertainty);
        
        assert(isfield(outliers, 'combined'), 'Outliers não contêm campo combined');
        
        fprintf('  ✓ ResultsAnalyzer passou em todos os testes\n');
        
    catch ME
        fprintf('  ✗ ResultsAnalyzer falhou: %s\n', ME.message);
        passed = false;
    end
end

function passed = testStatisticalAnalyzer()
    % Testa funcionalidades do StatisticalAnalyzer
    
    passed = true;
    
    try
        % Gerar dados de teste
        data1 = 0.7 + 0.1 * randn(30, 1);
        data2 = 0.75 + 0.1 * randn(30, 1);
        
        % Testar comparação simples
        [pValue, effectSize, testUsed] = StatisticalAnalyzer.compareModels(data1, data2);
        
        assert(~isnan(pValue), 'P-value é NaN');
        assert(~isnan(effectSize), 'Effect size é NaN');
        assert(~isempty(testUsed), 'Teste usado não especificado');
        
        % Testar análise completa
        unetMetrics = struct('iou', struct('values', data1), ...
                           'dice', struct('values', data1 + 0.05), ...
                           'accuracy', struct('values', data1 + 0.1));
        
        attentionMetrics = struct('iou', struct('values', data2), ...
                                'dice', struct('values', data2 + 0.05), ...
                                'accuracy', struct('values', data2 + 0.1));
        
        config = struct('verbose', false);
        results = StatisticalAnalyzer.performComprehensiveAnalysis(...
            unetMetrics, attentionMetrics, config);
        
        assert(isfield(results, 'comparisons'), 'Resultados não contêm comparações');
        assert(isfield(results, 'effectSizes'), 'Resultados não contêm effect sizes');
        assert(isfield(results, 'interpretation'), 'Resultados não contêm interpretação');
        
        % Testar geração de relatório
        report = StatisticalAnalyzer.generateScientificReport(results);
        
        assert(isfield(report, 'title'), 'Relatório não contém título');
        assert(isfield(report, 'timestamp'), 'Relatório não contém timestamp');
        
        fprintf('  ✓ StatisticalAnalyzer passou em todos os testes\n');
        
    catch ME
        fprintf('  ✗ StatisticalAnalyzer falhou: %s\n', ME.message);
        passed = false;
    end
end

function passed = testIntegration()
    % Testa integração entre componentes
    
    passed = true;
    
    try
        % Criar componentes
        engine = InferenceEngine(struct('verbose', false));
        analyzer = ResultsAnalyzer(struct('verbose', false));
        
        % Gerar dados de teste
        mockResults = generateMockResults();
        
        % Testar fluxo completo
        [confidence, uncertainty] = analyzer.calculateConfidenceUncertainty(mockResults);
        outliers = analyzer.detectAnomalousResults(mockResults, confidence, uncertainty);
        
        % Verificar que os componentes trabalham juntos
        assert(length(confidence) == length(mockResults), 'Integração falhou: tamanhos inconsistentes');
        assert(isfield(outliers, 'combined'), 'Integração falhou: outliers mal formados');
        
        % Testar com StatisticalAnalyzer
        unetMetrics = generateMockMetrics();
        attentionMetrics = generateMockMetrics();
        
        % Modificar ligeiramente as métricas do attention para simular diferença
        if isfield(attentionMetrics, 'iou') && isfield(attentionMetrics.iou, 'values')
            attentionMetrics.iou.values = attentionMetrics.iou.values + 0.02;
        end
        
        results = StatisticalAnalyzer.performComprehensiveAnalysis(...
            unetMetrics, attentionMetrics, struct('verbose', false));
        
        assert(isfield(results, 'summary'), 'Integração falhou: resumo não gerado');
        
        fprintf('  ✓ Integração entre componentes funcionando corretamente\n');
        
    catch ME
        fprintf('  ✗ Teste de integração falhou: %s\n', ME.message);
        passed = false;
    end
end

function results = generateMockResults()
    % Gera resultados simulados para teste
    
    numResults = 5;
    results = struct('imagePath', {}, 'segmentationPath', {}, ...
                    'modelUsed', {}, 'metrics', {}, ...
                    'processingTime', {}, 'timestamp', {});
    
    for i = 1:numResults
        result = struct();
        result.imagePath = sprintf('test_img_%d.jpg', i);
        result.segmentationPath = sprintf('test_seg_%d.png', i);
        result.modelUsed = 'test_model';
        result.metrics = struct();
        result.processingTime = 0.1 + 0.02 * randn();
        result.timestamp = datetime('now');
        
        results(i) = result;
    end
end

function metrics = generateMockMetrics()
    % Gera métricas simuladas para teste
    
    n = 20;
    
    metrics = struct();
    metrics.iou = struct();
    metrics.iou.values = 0.7 + 0.1 * randn(n, 1);
    metrics.iou.values = max(0, min(1, metrics.iou.values));
    
    metrics.dice = struct();
    metrics.dice.values = 0.75 + 0.1 * randn(n, 1);
    metrics.dice.values = max(0, min(1, metrics.dice.values));
    
    metrics.accuracy = struct();
    metrics.accuracy.values = 0.9 + 0.05 * randn(n, 1);
    metrics.accuracy.values = max(0, min(1, metrics.accuracy.values));
end