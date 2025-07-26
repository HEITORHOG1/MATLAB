function results = validate_performance_optimizations()
    % ========================================================================
    % VALIDATE_PERFORMANCE_OPTIMIZATIONS - Validação das Otimizações de Performance
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Script de validação para verificar se todas as otimizações de performance
    %   implementadas na versão 3.0 estão funcionando corretamente.
    %
    % REQUISITOS: 8.5 (validação de qualidade)
    % ========================================================================
    
    fprintf('🔍 VALIDAÇÃO DAS OTIMIZAÇÕES DE PERFORMANCE\n');
    fprintf('==========================================\n\n');
    
    results = struct();
    results.timestamp = datestr(now);
    results.tests = {};
    results.passed = 0;
    results.failed = 0;
    
    try
        % Teste 1: DataLoader com Lazy Loading
        fprintf('📋 Teste 1: DataLoader com Lazy Loading\n');
        test1_result = test_dataloader_lazy_loading();
        results.tests{end+1} = struct('name', 'DataLoader Lazy Loading', 'result', test1_result);
        if test1_result.passed
            results.passed = results.passed + 1;
            fprintf('✅ PASSOU\n\n');
        else
            results.failed = results.failed + 1;
            fprintf('❌ FALHOU: %s\n\n', test1_result.error);
        end
        
        % Teste 2: DataPreprocessor com Cache Inteligente
        fprintf('📋 Teste 2: DataPreprocessor com Cache Inteligente\n');
        test2_result = test_preprocessor_cache();
        results.tests{end+1} = struct('name', 'DataPreprocessor Cache', 'result', test2_result);
        if test2_result.passed
            results.passed = results.passed + 1;
            fprintf('✅ PASSOU\n\n');
        else
            results.failed = results.failed + 1;
            fprintf('❌ FALHOU: %s\n\n', test2_result.error);
        end
        
        % Teste 3: ResourceMonitor
        fprintf('📋 Teste 3: ResourceMonitor\n');
        test3_result = test_resource_monitor();
        results.tests{end+1} = struct('name', 'ResourceMonitor', 'result', test3_result);
        if test3_result.passed
            results.passed = results.passed + 1;
            fprintf('✅ PASSOU\n\n');
        else
            results.failed = results.failed + 1;
            fprintf('❌ FALHOU: %s\n\n', test3_result.error);
        end
        
        % Teste 4: PerformanceProfiler
        fprintf('📋 Teste 4: PerformanceProfiler\n');
        test4_result = test_performance_profiler();
        results.tests{end+1} = struct('name', 'PerformanceProfiler', 'result', test4_result);
        if test4_result.passed
            results.passed = results.passed + 1;
            fprintf('✅ PASSOU\n\n');
        else
            results.failed = results.failed + 1;
            fprintf('❌ FALHOU: %s\n\n', test4_result.error);
        end
        
        % Teste 5: SystemMonitor
        fprintf('📋 Teste 5: SystemMonitor\n');
        test5_result = test_system_monitor();
        results.tests{end+1} = struct('name', 'SystemMonitor', 'result', test5_result);
        if test5_result.passed
            results.passed = results.passed + 1;
            fprintf('✅ PASSOU\n\n');
        else
            results.failed = results.failed + 1;
            fprintf('❌ FALHOU: %s\n\n', test5_result.error);
        end
        
        % Teste 6: Integração com MainInterface
        fprintf('📋 Teste 6: Integração com MainInterface\n');
        test6_result = test_maininterface_integration();
        results.tests{end+1} = struct('name', 'MainInterface Integration', 'result', test6_result);
        if test6_result.passed
            results.passed = results.passed + 1;
            fprintf('✅ PASSOU\n\n');
        else
            results.failed = results.failed + 1;
            fprintf('❌ FALHOU: %s\n\n', test6_result.error);
        end
        
        % Resumo final
        fprintf('📊 RESUMO DA VALIDAÇÃO\n');
        fprintf('=====================\n');
        fprintf('Total de testes: %d\n', results.passed + results.failed);
        fprintf('Testes aprovados: %d\n', results.passed);
        fprintf('Testes falharam: %d\n', results.failed);
        fprintf('Taxa de sucesso: %.1f%%\n', (results.passed / (results.passed + results.failed)) * 100);
        
        if results.failed == 0
            fprintf('\n🎉 TODOS OS TESTES PASSARAM! Otimizações de performance validadas.\n');
        else
            fprintf('\n⚠️  ALGUNS TESTES FALHARAM. Verifique os erros acima.\n');
        end
        
        % Salvar resultados
        save('output/reports/performance_validation_results.mat', 'results');
        
    catch ME
        fprintf('❌ ERRO CRÍTICO na validação: %s\n', ME.message);
        results.critical_error = ME.message;
    end
end

function result = test_dataloader_lazy_loading()
    % Testa funcionalidade de lazy loading do DataLoader
    
    result = struct('passed', false, 'error', '', 'details', struct());
    
    try
        % Criar configuração de teste
        config = struct();
        config.imageDir = 'img/original';
        config.maskDir = 'img/masks';
        
        % Verificar se diretórios existem
        if ~exist(config.imageDir, 'dir') || ~exist(config.maskDir, 'dir')
            result.error = 'Diretórios de teste não encontrados';
            return;
        end
        
        % Criar DataLoader
        loader = DataLoader(config);
        
        % Verificar propriedades de lazy loading
        if ~isprop(loader, 'lazyLoadingEnabled') || ~isprop(loader, 'maxMemoryUsage')
            result.error = 'Propriedades de lazy loading não encontradas';
            return;
        end
        
        % Carregar dados
        [images, masks] = loader.loadData();
        
        if isempty(images) || isempty(masks)
            result.error = 'Nenhum dado carregado';
            return;
        end
        
        % Inicializar lazy loading
        loader.initializeLazyLoading(images, masks);
        
        % Testar carregamento de amostra
        if length(images) > 0
            [img, mask] = loader.lazyLoadSample(1);
            if isempty(img) || isempty(mask)
                result.error = 'Lazy loading de amostra falhou';
                return;
            end
        end
        
        % Obter estatísticas
        stats = loader.getPerformanceStats();
        if ~isstruct(stats) || ~isfield(stats, 'lazyLoading')
            result.error = 'Estatísticas de performance não disponíveis';
            return;
        end
        
        result.passed = true;
        result.details.samplesLoaded = length(images);
        result.details.lazyLoadingEnabled = loader.lazyLoadingEnabled;
        result.details.memoryLimit = loader.maxMemoryUsage;
        
    catch ME
        result.error = ME.message;
    end
end

function result = test_preprocessor_cache()
    % Testa cache inteligente do DataPreprocessor
    
    result = struct('passed', false, 'error', '', 'details', struct());
    
    try
        % Criar configuração de teste
        config = struct();
        config.inputSize = [256, 256, 3];
        
        % Criar DataPreprocessor
        preprocessor = DataPreprocessor(config, 'EnableCache', true, 'CacheMaxSize', 100);
        
        % Verificar se cache está habilitado
        if ~preprocessor.cacheEnabled
            result.error = 'Cache não está habilitado';
            return;
        end
        
        % Criar dados de teste
        testImg = uint8(rand(256, 256, 3) * 255);
        testMask = uint8(rand(256, 256) * 255);
        testData = {testImg, testMask};
        
        % Preprocessar dados (primeira vez - cache miss)
        processedData1 = preprocessor.preprocess(testData);
        
        % Preprocessar mesmos dados (segunda vez - cache hit)
        processedData2 = preprocessor.preprocess(testData);
        
        % Verificar se dados são consistentes
        if ~isequal(size(processedData1{1}), size(processedData2{1}))
            result.error = 'Dados processados inconsistentes';
            return;
        end
        
        % Obter estatísticas do cache
        stats = preprocessor.getCacheStats();
        if ~isstruct(stats) || ~isfield(stats, 'enabled')
            result.error = 'Estatísticas do cache não disponíveis';
            return;
        end
        
        % Testar otimização de memória
        preprocessor.optimizeMemoryUsage();
        
        result.passed = true;
        result.details.cacheEnabled = stats.enabled;
        result.details.cacheSize = stats.size;
        result.details.hitRate = stats.hitRate;
        
    catch ME
        result.error = ME.message;
    end
end

function result = test_resource_monitor()
    % Testa ResourceMonitor
    
    result = struct('passed', false, 'error', '', 'details', struct());
    
    try
        % Criar ResourceMonitor
        monitor = ResourceMonitor('EnableMonitoring', true);
        
        % Obter informações de recursos
        resourceInfo = monitor.getResourceInfo();
        
        % Verificar estrutura das informações
        requiredFields = {'memory', 'cpu', 'gpu', 'system', 'timestamp'};
        for i = 1:length(requiredFields)
            if ~isfield(resourceInfo, requiredFields{i})
                result.error = sprintf('Campo obrigatório ausente: %s', requiredFields{i});
                return;
            end
        end
        
        % Verificar informações de memória
        if ~isfield(resourceInfo.memory, 'totalGB') || ...
           ~isfield(resourceInfo.memory, 'usedGB') || ...
           ~isfield(resourceInfo.memory, 'utilizationPercent')
            result.error = 'Informações de memória incompletas';
            return;
        end
        
        % Iniciar profiling
        monitor.startProfiling('test_profile');
        
        % Simular algum trabalho
        pause(0.1);
        
        % Parar profiling
        monitor.stopProfiling('test_profile');
        
        % Gerar recomendações
        recommendations = monitor.generateOptimizationRecommendations();
        
        % Limpar recursos
        monitor.cleanup();
        
        result.passed = true;
        result.details.memoryTotal = resourceInfo.memory.totalGB;
        result.details.memoryUsed = resourceInfo.memory.usedGB;
        result.details.cpuCores = resourceInfo.cpu.numCores;
        result.details.gpuAvailable = resourceInfo.gpu.available;
        result.details.recommendationsCount = length(recommendations);
        
    catch ME
        result.error = ME.message;
    end
end

function result = test_performance_profiler()
    % Testa PerformanceProfiler
    
    result = struct('passed', false, 'error', '', 'details', struct());
    
    try
        % Criar PerformanceProfiler
        profiler = PerformanceProfiler('EnableProfiling', true);
        
        % Testar profiling de função
        profiler.startFunctionProfiling('test_function');
        
        % Simular trabalho
        pause(0.1);
        
        profiler.endFunctionProfiling('test_function');
        
        % Identificar gargalos
        bottlenecks = profiler.identifyBottlenecks();
        
        % Gerar relatório
        report = profiler.generateBottleneckReport();
        
        if isempty(report)
            result.error = 'Relatório de gargalos vazio';
            return;
        end
        
        % Obter estatísticas
        stats = profiler.getProfilingStats();
        
        if ~isstruct(stats) || ~isfield(stats, 'enabled')
            result.error = 'Estatísticas de profiling não disponíveis';
            return;
        end
        
        % Limpar recursos
        profiler.cleanup();
        
        result.passed = true;
        result.details.profilingEnabled = stats.enabled;
        result.details.functionsProfiled = stats.functionsProfiled;
        result.details.bottlenecksFound = length(bottlenecks);
        result.details.reportGenerated = ~isempty(report);
        
    catch ME
        result.error = ME.message;
    end
end

function result = test_system_monitor()
    % Testa SystemMonitor
    
    result = struct('passed', false, 'error', '', 'details', struct());
    
    try
        % Criar SystemMonitor
        monitor = SystemMonitor('EnableMonitoring', true, 'EnableAutoReport', false);
        
        % Iniciar monitoramento
        monitor.startSystemMonitoring('test_session');
        
        % Simular trabalho
        pause(0.1);
        
        % Verificar saúde do sistema
        monitor.checkSystemHealth();
        
        % Obter estatísticas
        stats = monitor.getMonitoringStats();
        
        if ~isstruct(stats)
            result.error = 'Estatísticas de monitoramento não disponíveis';
            return;
        end
        
        % Gerar relatório
        report = monitor.generatePerformanceReport();
        
        if isempty(report)
            result.error = 'Relatório de performance vazio';
            return;
        end
        
        % Parar monitoramento
        monitor.stopSystemMonitoring();
        
        % Limpar recursos
        monitor.cleanup();
        
        result.passed = true;
        result.details.monitoringActive = isfield(stats, 'session');
        result.details.reportGenerated = ~isempty(report);
        result.details.alertsTotal = stats.alerts.total;
        
    catch ME
        result.error = ME.message;
    end
end

function result = test_maininterface_integration()
    % Testa integração com MainInterface
    
    result = struct('passed', false, 'error', '', 'details', struct());
    
    try
        % Criar MainInterface
        interface = MainInterface();
        
        % Verificar se propriedades de monitoramento existem
        if ~isprop(interface, 'systemMonitor') || ~isprop(interface, 'monitoringEnabled')
            result.error = 'Propriedades de monitoramento não encontradas na MainInterface';
            return;
        end
        
        % Verificar se métodos de monitoramento existem
        methods_list = methods(interface);
        required_methods = {'startSystemMonitoring', 'displaySystemStatus', 'generatePerformanceReport'};
        
        for i = 1:length(required_methods)
            if ~any(strcmp(methods_list, required_methods{i}))
                result.error = sprintf('Método obrigatório ausente: %s', required_methods{i});
                return;
            end
        end
        
        % Testar inicialização (sem executar interface completa)
        % Apenas verificar se não há erros na criação
        
        result.passed = true;
        result.details.monitoringEnabled = interface.monitoringEnabled;
        result.details.methodsAvailable = length(required_methods);
        
    catch ME
        result.error = ME.message;
    end
end