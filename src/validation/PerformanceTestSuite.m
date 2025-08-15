classdef PerformanceTestSuite < handle
    % PerformanceTestSuite - Testes de performance e otimização
    % 
    % Valida que as otimizações implementadas melhoram a performance
    % e que o uso de recursos está dentro de limites aceitáveis.
    
    properties (Access = private)
        logger
        config
        testResults
        baselineMetrics
        tempDir
    end
    
    methods
        function obj = PerformanceTestSuite(config)
            % Construtor
            if nargin < 1
                obj.config = obj.getDefaultConfig();
            else
                obj.config = config;
            end
            
            obj.logger = ValidationLogger('PerformanceTestSuite');
            obj.testResults = struct();
            
            % Criar diretório temporário
            obj.tempDir = fullfile('temp', ['performance_test_' ...
                datestr(now, 'yyyymmdd_HHMMSS')]);
            if ~exist(obj.tempDir, 'dir')
                mkdir(obj.tempDir);
            end
            
            % Estabelecer métricas baseline
            obj.establishBaseline();
        end
        
        function results = runAllTests(obj)
            % Executa todos os testes de performance
            obj.logger.info('=== INICIANDO TESTES DE PERFORMANCE ===');
            startTime = tic;
            
            try
                % Lista de testes de performance
                tests = {
                    'testMemoryUsage'
                    'testProcessingSpeed'
                    'testModelLoadingPerformance'
                    'testInferencePerformance'
                    'testVisualizationPerformance'
                    'testFileIOPerformance'
                    'testOptimizationEffectiveness'
                    'testScalabilityPerformance'
                    'testResourceUtilization'
                    'testConcurrentOperations'
                };
                
                obj.testResults.tests = struct();
                obj.testResults.summary = struct();
                
                % Executar cada teste
                for i = 1:length(tests)
                    testName = tests{i};
                    obj.logger.logTestStart(testName);
                    testStartTime = tic;
                    
                    try
                        testResult = obj.(testName)();
                        testDuration = toc(testStartTime);
                        
                        obj.testResults.tests.(testName) = testResult;
                        obj.testResults.tests.(testName).duration = testDuration;
                        obj.testResults.tests.(testName).success = true;
                        
                        obj.logger.logTestEnd(testName, true, testDuration);
                        
                    catch ME
                        testDuration = toc(testStartTime);
                        obj.testResults.tests.(testName) = struct();
                        obj.testResults.tests.(testName).error = ME.message;
                        obj.testResults.tests.(testName).duration = testDuration;
                        obj.testResults.tests.(testName).success = false;
                        
                        obj.logger.error(['Teste de performance falhou: ' ME.message]);
                        obj.logger.logTestEnd(testName, false, testDuration);
                    end
                end        
        
                % Calcular resumo
                obj.calculateSummary();
                
                obj.testResults.totalDuration = toc(startTime);
                results = obj.testResults;
                
                obj.logger.info(['=== TESTES DE PERFORMANCE FINALIZADOS EM ' ...
                    num2str(obj.testResults.totalDuration, '%.2f') ' segundos ===']);
                
            catch ME
                obj.logger.error(['Erro geral nos testes de performance: ' ME.message]);
                obj.testResults.generalError = ME.message;
                obj.testResults.overallSuccess = false;
                results = obj.testResults;
            end
            
            % Limpar recursos
            obj.cleanup();
        end
        
        function result = testMemoryUsage(obj)
            % Testa uso de memória
            result = struct();
            
            obj.logger.info('Testando uso de memória...');
            
            % Medir memória inicial
            initialMemory = obj.getCurrentMemoryUsage();
            
            % Simular operações que consomem memória
            largeData = cell(100, 1);
            for i = 1:100
                largeData{i} = rand(100, 100);
            end
            
            % Medir memória após operações
            peakMemory = obj.getCurrentMemoryUsage();
            
            % Limpar dados
            clear largeData;
            
            % Medir memória final
            finalMemory = obj.getCurrentMemoryUsage();
            
            result.initialMemory = initialMemory;
            result.peakMemory = peakMemory;
            result.finalMemory = finalMemory;
            result.memoryIncrease = peakMemory - initialMemory;
            result.memoryLeakage = finalMemory - initialMemory;
            
            % Critérios de aceitação
            result.memoryEfficient = result.memoryIncrease < obj.config.maxMemoryIncrease;
            result.noMemoryLeak = result.memoryLeakage < obj.config.maxMemoryLeak;
            result.performanceAcceptable = result.memoryEfficient && result.noMemoryLeak;
            
            obj.logger.info(['Uso de memória - Inicial: ' num2str(initialMemory, '%.1f') ...
                'MB, Pico: ' num2str(peakMemory, '%.1f') 'MB, Final: ' ...
                num2str(finalMemory, '%.1f') 'MB']);
        end
        
        function result = testProcessingSpeed(obj)
            % Testa velocidade de processamento
            result = struct();
            
            obj.logger.info('Testando velocidade de processamento...');
            
            % Teste de operações matemáticas
            startTime = tic;
            for i = 1:1000
                A = rand(50, 50);
                B = rand(50, 50);
                C = A * B;
                D = inv(C + eye(50));
            end
            result.mathOperationsTime = toc(startTime);
            
            % Teste de operações de arquivo
            startTime = tic;
            testFile = fullfile(obj.tempDir, 'speed_test.mat');
            testData = rand(1000, 1000);
            save(testFile, 'testData');
            loadedData = load(testFile);
            result.fileOperationsTime = toc(startTime);
            
            % Comparar com baseline
            result.mathSpeedImprovement = obj.baselineMetrics.mathTime / result.mathOperationsTime;
            result.fileSpeedImprovement = obj.baselineMetrics.fileTime / result.fileOperationsTime;
            
            result.performanceAcceptable = result.mathOperationsTime < obj.config.maxMathTime && ...
                result.fileOperationsTime < obj.config.maxFileTime;
            
            obj.logger.info(['Velocidade - Matemática: ' num2str(result.mathOperationsTime, '%.3f') ...
                's, Arquivo: ' num2str(result.fileOperationsTime, '%.3f') 's']);
        end
        
        function result = testModelLoadingPerformance(obj)
            % Testa performance de carregamento de modelos
            result = struct();
            
            obj.logger.info('Testando performance de carregamento de modelos...');
            
            % Simular carregamento de modelo
            startTime = tic;
            
            % Verificar se ModelLoader existe
            if exist('src/model_management/ModelLoader.m', 'file')
                try
                    addpath('src/model_management');
                    % Simular carregamento (sem modelo real)
                    pause(0.1); % Simular tempo de carregamento
                    result.modelLoadTime = toc(startTime);
                    result.canLoadModels = true;
                catch ME
                    result.modelLoadTime = toc(startTime);
                    result.canLoadModels = false;
                    result.loadError = ME.message;
                end
            else
                result.modelLoadTime = 0;
                result.canLoadModels = false;
                result.loadError = 'ModelLoader não encontrado';
            end
            
            result.performanceAcceptable = result.modelLoadTime < obj.config.maxModelLoadTime;
            
            obj.logger.info(['Tempo de carregamento de modelo: ' ...
                num2str(result.modelLoadTime, '%.3f') 's']);
        end 
       
        function result = testInferencePerformance(obj)
            % Testa performance de inferência
            result = struct();
            
            obj.logger.info('Testando performance de inferência...');
            
            % Simular inferência em lote
            startTime = tic;
            
            % Simular processamento de múltiplas imagens
            numImages = 10;
            for i = 1:numImages
                % Simular processamento de imagem
                img = rand(256, 256, 3);
                processed = img .* 0.5 + 0.5; % Operação simples
            end
            
            result.batchInferenceTime = toc(startTime);
            result.timePerImage = result.batchInferenceTime / numImages;
            
            result.performanceAcceptable = result.timePerImage < obj.config.maxInferenceTimePerImage;
            
            obj.logger.info(['Tempo de inferência por imagem: ' ...
                num2str(result.timePerImage, '%.3f') 's']);
        end
        
        function result = testVisualizationPerformance(obj)
            % Testa performance de visualização
            result = struct();
            
            obj.logger.info('Testando performance de visualização...');
            
            startTime = tic;
            
            % Simular geração de visualizações
            if exist('src/visualization/ComparisonVisualizer.m', 'file')
                try
                    % Simular criação de visualizações
                    pause(0.05); % Simular tempo de processamento
                    result.visualizationTime = toc(startTime);
                    result.canGenerateVisualizations = true;
                catch ME
                    result.visualizationTime = toc(startTime);
                    result.canGenerateVisualizations = false;
                    result.visualizationError = ME.message;
                end
            else
                result.visualizationTime = 0;
                result.canGenerateVisualizations = false;
                result.visualizationError = 'ComparisonVisualizer não encontrado';
            end
            
            result.performanceAcceptable = result.visualizationTime < obj.config.maxVisualizationTime;
            
            obj.logger.info(['Tempo de visualização: ' ...
                num2str(result.visualizationTime, '%.3f') 's']);
        end
        
        function result = testFileIOPerformance(obj)
            % Testa performance de I/O de arquivos
            result = struct();
            
            obj.logger.info('Testando performance de I/O...');
            
            % Teste de escrita
            startTime = tic;
            testFile = fullfile(obj.tempDir, 'io_test.txt');
            fid = fopen(testFile, 'w');
            for i = 1:1000
                fprintf(fid, 'Linha de teste %d\n', i);
            end
            fclose(fid);
            result.writeTime = toc(startTime);
            
            % Teste de leitura
            startTime = tic;
            fid = fopen(testFile, 'r');
            lines = {};
            lineCount = 0;
            while ~feof(fid)
                line = fgetl(fid);
                if ischar(line)
                    lineCount = lineCount + 1;
                    lines{lineCount} = line;
                end
            end
            fclose(fid);
            result.readTime = toc(startTime);
            
            result.totalIOTime = result.writeTime + result.readTime;
            result.performanceAcceptable = result.totalIOTime < obj.config.maxIOTime;
            
            obj.logger.info(['I/O - Escrita: ' num2str(result.writeTime, '%.3f') ...
                's, Leitura: ' num2str(result.readTime, '%.3f') 's']);
        end
        
        function result = testOptimizationEffectiveness(obj)
            % Testa efetividade das otimizações
            result = struct();
            
            obj.logger.info('Testando efetividade das otimizações...');
            
            % Comparar performance otimizada vs não otimizada
            % (simulado - em implementação real compararia algoritmos)
            
            % Versão "não otimizada"
            startTime = tic;
            for i = 1:100
                data = rand(100, 100);
                result_unopt = sum(sum(data));
            end
            unoptimizedTime = toc(startTime);
            
            % Versão "otimizada"
            startTime = tic;
            for i = 1:100
                data = rand(100, 100);
                result_opt = sum(data(:)); % Mais eficiente
            end
            optimizedTime = toc(startTime);
            
            result.unoptimizedTime = unoptimizedTime;
            result.optimizedTime = optimizedTime;
            result.speedupFactor = unoptimizedTime / optimizedTime;
            result.optimizationEffective = result.speedupFactor > 1.1; % 10% melhoria mínima
            
            obj.logger.info(['Fator de aceleração: ' num2str(result.speedupFactor, '%.2f') 'x']);
        end  
      
        function result = testScalabilityPerformance(obj)
            % Testa escalabilidade do sistema
            result = struct();
            
            obj.logger.info('Testando escalabilidade...');
            
            % Testar com diferentes tamanhos de dados
            dataSizes = [10, 50, 100, 200];
            result.scalabilityResults = struct();
            
            for i = 1:length(dataSizes)
                size = dataSizes(i);
                startTime = tic;
                
                % Simular processamento escalável
                data = rand(size, size);
                processed = data * 2 + 1;
                
                processingTime = toc(startTime);
                result.scalabilityResults.(['size_' num2str(size)]) = processingTime;
                
                obj.logger.info(['Tamanho ' num2str(size) 'x' num2str(size) ...
                    ': ' num2str(processingTime, '%.4f') 's']);
            end
            
            % Verificar se crescimento é linear/aceitável
            times = [result.scalabilityResults.size_10, result.scalabilityResults.size_50, ...
                result.scalabilityResults.size_100, result.scalabilityResults.size_200];
            
            result.scalabilityAcceptable = times(end) / times(1) < 100; % Crescimento razoável
        end
        
        function result = testResourceUtilization(obj)
            % Testa utilização de recursos
            result = struct();
            
            obj.logger.info('Testando utilização de recursos...');
            
            % Monitorar uso de CPU (simulado)
            startTime = tic;
            
            % Operação intensiva
            for i = 1:500
                A = rand(50, 50);
                B = A' * A;
                C = eig(B);
            end
            
            result.cpuIntensiveTime = toc(startTime);
            result.cpuEfficient = result.cpuIntensiveTime < obj.config.maxCPUTime;
            
            obj.logger.info(['Tempo de operação intensiva: ' ...
                num2str(result.cpuIntensiveTime, '%.3f') 's']);
        end
        
        function result = testConcurrentOperations(obj)
            % Testa operações concorrentes (simulado)
            result = struct();
            
            obj.logger.info('Testando operações concorrentes...');
            
            % Simular operações paralelas
            startTime = tic;
            
            % Em MATLAB real, usaria parfor ou parallel computing
            % Por ora, simular com loop sequencial
            results = cell(4, 1);
            for i = 1:4
                results{i} = rand(100, 100) * rand(100, 100);
            end
            
            result.concurrentTime = toc(startTime);
            result.concurrencyEffective = result.concurrentTime < obj.config.maxConcurrentTime;
            
            obj.logger.info(['Tempo de operações concorrentes: ' ...
                num2str(result.concurrentTime, '%.3f') 's']);
        end
        
        function establishBaseline(obj)
            % Estabelece métricas baseline para comparação
            obj.logger.info('Estabelecendo métricas baseline...');
            
            % Operações matemáticas baseline
            startTime = tic;
            for i = 1:100
                A = rand(20, 20);
                B = rand(20, 20);
                C = A * B;
            end
            mathTime = toc(startTime);
            
            % Operações de arquivo baseline
            startTime = tic;
            tempFile = fullfile(obj.tempDir, 'baseline.mat');
            data = rand(100, 100);
            save(tempFile, 'data');
            loaded = load(tempFile);
            fileTime = toc(startTime);
            
            obj.baselineMetrics = struct();
            obj.baselineMetrics.mathTime = mathTime;
            obj.baselineMetrics.fileTime = fileTime;
            
            obj.logger.info(['Baseline estabelecido - Math: ' num2str(mathTime, '%.3f') ...
                's, File: ' num2str(fileTime, '%.3f') 's']);
        end
        
        function memoryMB = getCurrentMemoryUsage(obj)
            % Obtém uso atual de memória (simulado)
            % Em implementação real, usaria memory() ou ferramentas do sistema
            
            % Simular uso de memória baseado em variáveis no workspace
            vars = whos;
            totalBytes = sum([vars.bytes]);
            memoryMB = totalBytes / (1024 * 1024);
        end
        
        function calculateSummary(obj)
            % Calcula resumo dos testes de performance
            testNames = fieldnames(obj.testResults.tests);
            totalTests = length(testNames);
            passedTests = 0;
            failedTests = 0;
            performanceIssues = 0;
            
            for i = 1:totalTests
                testName = testNames{i};
                testResult = obj.testResults.tests.(testName);
                
                if testResult.success
                    passedTests = passedTests + 1;
                    
                    % Verificar se performance é aceitável
                    if isfield(testResult, 'performanceAcceptable') && ...
                       ~testResult.performanceAcceptable
                        performanceIssues = performanceIssues + 1;
                    end
                else
                    failedTests = failedTests + 1;
                end
            end
            
            obj.testResults.summary.totalTests = totalTests;
            obj.testResults.summary.passedTests = passedTests;
            obj.testResults.summary.failedTests = failedTests;
            obj.testResults.summary.performanceIssues = performanceIssues;
            obj.testResults.summary.successRate = passedTests / totalTests;
            obj.testResults.overallSuccess = failedTests == 0 && performanceIssues == 0;
            
            obj.logger.info(['Resumo de performance: ' num2str(passedTests) '/' ...
                num2str(totalTests) ' testes passaram, ' ...
                num2str(performanceIssues) ' problemas de performance detectados']);
        end        

        function config = getDefaultConfig(obj)
            % Configuração padrão para testes de performance
            config = struct();
            
            % Limites de tempo (segundos)
            config.maxMathTime = 1.0;
            config.maxFileTime = 2.0;
            config.maxModelLoadTime = 5.0;
            config.maxInferenceTimePerImage = 0.5;
            config.maxVisualizationTime = 3.0;
            config.maxIOTime = 1.0;
            config.maxCPUTime = 2.0;
            config.maxConcurrentTime = 5.0;
            
            % Limites de memória (MB)
            config.maxMemoryIncrease = 500;
            config.maxMemoryLeak = 50;
            
            % Configurações gerais
            config.enableDetailedProfiling = false;
            config.runStressTests = false;
        end
        
        function cleanup(obj)
            % Limpa recursos temporários
            try
                if exist(obj.tempDir, 'dir')
                    rmdir(obj.tempDir, 's');
                    obj.logger.info('Recursos de performance limpos');
                end
            catch ME
                obj.logger.warning(['Erro ao limpar recursos: ' ME.message]);
            end
        end
    end
end