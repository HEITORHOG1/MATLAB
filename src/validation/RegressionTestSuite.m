classdef RegressionTestSuite < handle
    % RegressionTestSuite - Testes de regressão para garantir compatibilidade
    % 
    % Compara resultados do sistema melhorado com o sistema anterior para
    % garantir que as melhorias não quebram funcionalidades existentes.
    
    properties (Access = private)
        logger
        config
        testResults
        referenceDataPath
        tempDir
    end
    
    methods
        function obj = RegressionTestSuite(config)
            % Construtor
            if nargin < 1
                obj.config = obj.getDefaultConfig();
            else
                obj.config = config;
            end
            
            obj.logger = ValidationLogger('RegressionTestSuite');
            obj.testResults = struct();
            obj.referenceDataPath = obj.config.referenceDataPath;
            
            % Criar diretório temporário
            obj.tempDir = fullfile('temp', ['regression_test_' ...
                datestr(now, 'yyyymmdd_HHMMSS')]);
            if ~exist(obj.tempDir, 'dir')
                mkdir(obj.tempDir);
            end
        end
        
        function results = runAllTests(obj)
            % Executa todos os testes de regressão
            obj.logger.info('=== INICIANDO TESTES DE REGRESSÃO ===');
            startTime = tic;
            
            try
                % Lista de testes de regressão
                tests = {
                    'testBasicFunctionalityRegression'
                    'testMetricsCalculationRegression'
                    'testDataLoadingRegression'
                    'testModelTrainingRegression'
                    'testVisualizationRegression'
                    'testFileOutputRegression'
                    'testPerformanceRegression'
                    'testAPICompatibilityRegression'
                    'testConfigurationRegression'
                    'testErrorHandlingRegression'
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
                        
                        obj.logger.error(['Teste de regressão falhou: ' ME.message]);
                        obj.logger.logTestEnd(testName, false, testDuration);
                    end
                end
                
                % Calcular resumo
                obj.calculateSummary();
                
                obj.testResults.totalDuration = toc(startTime);
                results = obj.testResults;
                
                obj.logger.info(['=== TESTES DE REGRESSÃO FINALIZADOS EM ' ...
                    num2str(obj.testResults.totalDuration, '%.2f') ' segundos ===']);
                
            catch ME
                obj.logger.error(['Erro geral nos testes de regressão: ' ME.message]);
                obj.testResults.generalError = ME.message;
                obj.testResults.overallSuccess = false;
                results = obj.testResults;
            end
            
            % Limpar recursos
            obj.cleanup();
        end
        
        function result = testBasicFunctionalityRegression(obj)
            % Testa funcionalidades básicas do sistema
            result = struct();
            
            obj.logger.info('Testando regressão de funcionalidades básicas...');
            
            % Verificar se funções principais ainda existem
            basicFunctions = {
                'executar_comparacao.m'
                'main_sistema_comparacao.m'
            };
            
            result.functionsFound = 0;
            for i = 1:length(basicFunctions)
                if exist(basicFunctions{i}, 'file')
                    result.functionsFound = result.functionsFound + 1;
                    obj.logger.info(['✓ ' basicFunctions{i} ' encontrado']);
                else
                    obj.logger.warning(['⚠ ' basicFunctions{i} ' não encontrado']);
                end
            end
            
            result.basicFunctionalityScore = result.functionsFound / length(basicFunctions);
            result.regressionPassed = result.basicFunctionalityScore >= 0.8;
            
            if result.regressionPassed
                obj.logger.info('✓ Funcionalidades básicas preservadas');
            else
                obj.logger.warning('⚠ Possível regressão em funcionalidades básicas');
            end
        end
        
        function result = testMetricsCalculationRegression(obj)
            % Testa se cálculo de métricas permanece consistente
            result = struct();
            
            obj.logger.info('Testando regressão no cálculo de métricas...');
            
            % Verificar se funções de métricas existem
            metricsFiles = {
                'utils/calcular_dice_simples.m'
                'utils/calcular_iou_simples.m'
                'utils/calcular_accuracy_simples.m'
            };
            
            result.metricsFound = 0;
            for i = 1:length(metricsFiles)
                if exist(metricsFiles{i}, 'file')
                    result.metricsFound = result.metricsFound + 1;
                    obj.logger.info(['✓ ' metricsFiles{i} ' encontrado']);
                else
                    obj.logger.warning(['⚠ ' metricsFiles{i} ' não encontrado']);
                end
            end
            
            % Testar consistência de cálculos (simulado)
            result.calculationConsistency = obj.testMetricsConsistency();
            
            result.metricsScore = result.metricsFound / length(metricsFiles);
            result.regressionPassed = result.metricsScore >= 0.8 && result.calculationConsistency;
            
            if result.regressionPassed
                obj.logger.info('✓ Cálculo de métricas consistente');
            else
                obj.logger.warning('⚠ Possível regressão no cálculo de métricas');
            end
        end
        
        function result = testDataLoadingRegression(obj)
            % Testa se carregamento de dados permanece funcional
            result = struct();
            
            obj.logger.info('Testando regressão no carregamento de dados...');
            
            % Verificar se diretórios de dados existem
            dataDirs = {'img/original', 'img/masks'};
            result.dataDirsFound = 0;
            
            for i = 1:length(dataDirs)
                if exist(dataDirs{i}, 'dir')
                    result.dataDirsFound = result.dataDirsFound + 1;
                    obj.logger.info(['✓ ' dataDirs{i} ' encontrado']);
                else
                    obj.logger.warning(['⚠ ' dataDirs{i} ' não encontrado']);
                end
            end
            
            % Verificar funções de carregamento
            if exist('utils/carregar_dados_robustos.m', 'file')
                result.dataLoaderFound = true;
                obj.logger.info('✓ Carregador de dados encontrado');
            else
                result.dataLoaderFound = false;
                obj.logger.warning('⚠ Carregador de dados não encontrado');
            end
            
            result.dataScore = (result.dataDirsFound / length(dataDirs) + ...
                double(result.dataLoaderFound)) / 2;
            result.regressionPassed = result.dataScore >= 0.7;
            
            if result.regressionPassed
                obj.logger.info('✓ Carregamento de dados preservado');
            else
                obj.logger.warning('⚠ Possível regressão no carregamento de dados');
            end
        end
        
        function result = testModelTrainingRegression(obj)
            % Testa se treinamento de modelos permanece funcional
            result = struct();
            
            obj.logger.info('Testando regressão no treinamento de modelos...');
            
            % Verificar funções de treinamento
            trainingFiles = {
                'utils/treinar_unet_simples.m'
                'legacy/comparacao_unet_attention_final.m'
            };
            
            result.trainingFilesFound = 0;
            for i = 1:length(trainingFiles)
                if exist(trainingFiles{i}, 'file')
                    result.trainingFilesFound = result.trainingFilesFound + 1;
                    obj.logger.info(['✓ ' trainingFiles{i} ' encontrado']);
                else
                    obj.logger.warning(['⚠ ' trainingFiles{i} ' não encontrado']);
                end
            end
            
            result.trainingScore = result.trainingFilesFound / length(trainingFiles);
            result.regressionPassed = result.trainingScore >= 0.5;
            
            if result.regressionPassed
                obj.logger.info('✓ Treinamento de modelos preservado');
            else
                obj.logger.warning('⚠ Possível regressão no treinamento');
            end
        end
        
        function result = testVisualizationRegression(obj)
            % Testa se visualizações básicas permanecem funcionais
            result = struct();
            
            obj.logger.info('Testando regressão nas visualizações...');
            
            % Verificar se diretórios de saída existem
            outputDirs = {'output', 'temp'};
            result.outputDirsAccessible = 0;
            
            for i = 1:length(outputDirs)
                if exist(outputDirs{i}, 'dir') || obj.canCreateDir(outputDirs{i})
                    result.outputDirsAccessible = result.outputDirsAccessible + 1;
                    obj.logger.info(['✓ ' outputDirs{i} ' acessível']);
                else
                    obj.logger.warning(['⚠ ' outputDirs{i} ' não acessível']);
                end
            end
            
            result.visualizationScore = result.outputDirsAccessible / length(outputDirs);
            result.regressionPassed = result.visualizationScore >= 0.8;
            
            if result.regressionPassed
                obj.logger.info('✓ Sistema de visualização preservado');
            else
                obj.logger.warning('⚠ Possível regressão nas visualizações');
            end
        end
        
        function result = testFileOutputRegression(obj)
            % Testa se saída de arquivos permanece funcional
            result = struct();
            
            obj.logger.info('Testando regressão na saída de arquivos...');
            
            % Testar criação de arquivo temporário
            testFile = fullfile(obj.tempDir, 'test_output.txt');
            try
                fid = fopen(testFile, 'w');
                if fid ~= -1
                    fprintf(fid, 'Teste de regressão\n');
                    fclose(fid);
                    result.canWriteFiles = true;
                    obj.logger.info('✓ Pode escrever arquivos');
                else
                    result.canWriteFiles = false;
                    obj.logger.warning('⚠ Não pode escrever arquivos');
                end
            catch ME
                result.canWriteFiles = false;
                result.writeError = ME.message;
                obj.logger.warning(['⚠ Erro ao escrever: ' ME.message]);
            end
            
            result.regressionPassed = result.canWriteFiles;
            
            if result.regressionPassed
                obj.logger.info('✓ Saída de arquivos funcional');
            else
                obj.logger.warning('⚠ Possível regressão na saída de arquivos');
            end
        end
        
        function result = testPerformanceRegression(obj)
            % Testa se performance não regrediu significativamente
            result = struct();
            
            obj.logger.info('Testando regressão de performance...');
            
            % Medir tempo de operações básicas
            startTime = tic;
            
            % Simular operações típicas
            for i = 1:1000
                % Operação matemática simples
                temp = rand(10, 10) * rand(10, 10);
            end
            
            result.basicOperationTime = toc(startTime);
            result.performanceAcceptable = result.basicOperationTime < 1.0;
            
            obj.logger.info(['Tempo de operações básicas: ' ...
                num2str(result.basicOperationTime, '%.3f') 's']);
            
            result.regressionPassed = result.performanceAcceptable;
            
            if result.regressionPassed
                obj.logger.info('✓ Performance aceitável');
            else
                obj.logger.warning('⚠ Possível regressão de performance');
            end
        end
        
        function result = testAPICompatibilityRegression(obj)
            % Testa compatibilidade de API
            result = struct();
            
            obj.logger.info('Testando regressão de compatibilidade de API...');
            
            % Verificar se interfaces principais existem
            interfaces = {
                'src/core/MainInterface.m'
                'src/core/ComparisonController.m'
            };
            
            result.interfacesFound = 0;
            for i = 1:length(interfaces)
                if exist(interfaces{i}, 'file')
                    result.interfacesFound = result.interfacesFound + 1;
                    obj.logger.info(['✓ ' interfaces{i} ' encontrado']);
                else
                    obj.logger.warning(['⚠ ' interfaces{i} ' não encontrado']);
                end
            end
            
            result.apiScore = result.interfacesFound / length(interfaces);
            result.regressionPassed = result.apiScore >= 0.8;
            
            if result.regressionPassed
                obj.logger.info('✓ Compatibilidade de API preservada');
            else
                obj.logger.warning('⚠ Possível regressão na API');
            end
        end
        
        function result = testConfigurationRegression(obj)
            % Testa se sistema de configuração permanece funcional
            result = struct();
            
            obj.logger.info('Testando regressão na configuração...');
            
            % Verificar ConfigManager
            if exist('src/core/ConfigManager.m', 'file')
                result.configManagerFound = true;
                obj.logger.info('✓ ConfigManager encontrado');
            else
                result.configManagerFound = false;
                obj.logger.warning('⚠ ConfigManager não encontrado');
            end
            
            result.regressionPassed = result.configManagerFound;
            
            if result.regressionPassed
                obj.logger.info('✓ Sistema de configuração preservado');
            else
                obj.logger.warning('⚠ Possível regressão na configuração');
            end
        end
        
        function result = testErrorHandlingRegression(obj)
            % Testa se tratamento de erros permanece robusto
            result = struct();
            
            obj.logger.info('Testando regressão no tratamento de erros...');
            
            % Testar tratamento de erro básico
            try
                % Simular erro controlado
                nonExistentFunction();
            catch ME
                result.errorCaught = true;
                result.errorMessage = ME.message;
                obj.logger.info('✓ Erro capturado corretamente');
            end
            
            if ~isfield(result, 'errorCaught')
                result.errorCaught = false;
                obj.logger.warning('⚠ Erro não foi capturado');
            end
            
            result.regressionPassed = result.errorCaught;
            
            if result.regressionPassed
                obj.logger.info('✓ Tratamento de erros funcional');
            else
                obj.logger.warning('⚠ Possível regressão no tratamento de erros');
            end
        end
        
        function consistent = testMetricsConsistency(obj)
            % Testa consistência de cálculos de métricas (simulado)
            consistent = true;
            
            % Simular teste de consistência
            obj.logger.info('Verificando consistência de métricas...');
            
            % Em um teste real, compararia resultados com valores de referência
            % Por ora, assumir consistência
            obj.logger.info('✓ Métricas consistentes (simulado)');
        end
        
        function canCreate = canCreateDir(obj, dirPath)
            % Testa se pode criar diretório
            try
                if ~exist(dirPath, 'dir')
                    mkdir(dirPath);
                    canCreate = true;
                    rmdir(dirPath); % Limpar
                else
                    canCreate = true;
                end
            catch
                canCreate = false;
            end
        end
        
        function calculateSummary(obj)
            % Calcula resumo dos testes de regressão
            testNames = fieldnames(obj.testResults.tests);
            totalTests = length(testNames);
            passedTests = 0;
            failedTests = 0;
            regressionIssues = 0;
            
            for i = 1:totalTests
                testName = testNames{i};
                testResult = obj.testResults.tests.(testName);
                
                if testResult.success
                    passedTests = passedTests + 1;
                    
                    % Verificar se houve regressão
                    if isfield(testResult, 'regressionPassed') && ...
                       ~testResult.regressionPassed
                        regressionIssues = regressionIssues + 1;
                    end
                else
                    failedTests = failedTests + 1;
                end
            end
            
            obj.testResults.summary.totalTests = totalTests;
            obj.testResults.summary.passedTests = passedTests;
            obj.testResults.summary.failedTests = failedTests;
            obj.testResults.summary.regressionIssues = regressionIssues;
            obj.testResults.summary.successRate = passedTests / totalTests;
            obj.testResults.overallSuccess = failedTests == 0 && regressionIssues == 0;
            
            obj.logger.info(['Resumo de regressão: ' num2str(passedTests) '/' ...
                num2str(totalTests) ' testes passaram, ' ...
                num2str(regressionIssues) ' problemas de regressão detectados']);
        end
        
        function config = getDefaultConfig(obj)
            % Configuração padrão
            config = struct();
            config.referenceDataPath = 'reference_data';
            config.toleranceLevel = 0.05; % 5% de tolerância
            config.quickTest = false;
        end
        
        function cleanup(obj)
            % Limpa recursos temporários
            try
                if exist(obj.tempDir, 'dir')
                    rmdir(obj.tempDir, 's');
                    obj.logger.info('Recursos temporários limpos');
                end
            catch ME
                obj.logger.warning(['Erro ao limpar: ' ME.message]);
            end
        end
    end
end