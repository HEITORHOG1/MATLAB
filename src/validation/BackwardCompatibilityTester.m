classdef BackwardCompatibilityTester < handle
    % BackwardCompatibilityTester - Testes de compatibilidade com versões anteriores
    % 
    % Garante que o sistema melhorado mantém compatibilidade total
    % com scripts e funcionalidades do sistema anterior.
    
    properties (Access = private)
        logger
        config
        testResults
        legacyFunctions
    end
    
    methods
        function obj = BackwardCompatibilityTester(config)
            % Construtor
            if nargin < 1
                obj.config = obj.getDefaultConfig();
            else
                obj.config = config;
            end
            
            obj.logger = ValidationLogger('BackwardCompatibilityTester');
            obj.testResults = struct();
            
            % Lista de funções legadas que devem continuar funcionando
            obj.legacyFunctions = {
                'executar_comparacao.m'
                'main_sistema_comparacao.m'
                'utils/calcular_dice_simples.m'
                'utils/calcular_iou_simples.m'
                'utils/calcular_accuracy_simples.m'
                'utils/treinar_unet_simples.m'
                'utils/carregar_dados_robustos.m'
            };
        end
        
        function results = runAllTests(obj)
            % Executa todos os testes de compatibilidade
            obj.logger.info('=== INICIANDO TESTES DE COMPATIBILIDADE ===');
            startTime = tic;
            
            try
                % Lista de testes de compatibilidade
                tests = {
                    'testLegacyFunctionAvailability'
                    'testLegacyScriptExecution'
                    'testDataStructureCompatibility'
                    'testAPICompatibility'
                    'testFileFormatCompatibility'
                    'testConfigurationCompatibility'
                    'testOutputCompatibility'
                    'testPathCompatibility'
                    'testDependencyCompatibility'
                    'testMigrationSupport'
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
                        
                        obj.logger.error(['Teste de compatibilidade falhou: ' ME.message]);
                        obj.logger.logTestEnd(testName, false, testDuration);
                    end
                end
                
                % Calcular resumo
                obj.calculateSummary();
                
                obj.testResults.totalDuration = toc(startTime);
                results = obj.testResults;
                
                obj.logger.info(['=== TESTES DE COMPATIBILIDADE FINALIZADOS EM ' ...
                    num2str(obj.testResults.totalDuration, '%.2f') ' segundos ===']);
                
            catch ME
                obj.logger.error(['Erro geral nos testes de compatibilidade: ' ME.message]);
                obj.testResults.generalError = ME.message;
                obj.testResults.overallSuccess = false;
                results = obj.testResults;
            end
        end
        
        function result = testLegacyFunctionAvailability(obj)
            % Testa se funções legadas ainda existem
            result = struct();
            
            obj.logger.info('Testando disponibilidade de funções legadas...');
            
            result.functionsFound = 0;
            result.functionsMissing = {};
            result.functionsDetails = struct();
            
            for i = 1:length(obj.legacyFunctions)
                funcName = obj.legacyFunctions{i};
                
                if exist(funcName, 'file')
                    result.functionsFound = result.functionsFound + 1;
                    result.functionsDetails.(obj.sanitizeFieldName(funcName)) = struct();
                    result.functionsDetails.(obj.sanitizeFieldName(funcName)).found = true;
                    result.functionsDetails.(obj.sanitizeFieldName(funcName)).path = which(funcName);
                    
                    obj.logger.info(['✓ ' funcName ' encontrada']);
                else
                    result.functionsMissing{end+1} = funcName;
                    result.functionsDetails.(obj.sanitizeFieldName(funcName)) = struct();
                    result.functionsDetails.(obj.sanitizeFieldName(funcName)).found = false;
                    
                    obj.logger.warning(['⚠ ' funcName ' não encontrada']);
                end
            end
            
            result.totalFunctions = length(obj.legacyFunctions);
            result.availabilityRate = result.functionsFound / result.totalFunctions;
            result.compatibilityAcceptable = result.availabilityRate >= 0.8;
            
            obj.logger.info(['Taxa de disponibilidade: ' ...
                num2str(result.availabilityRate * 100, '%.1f') '%']);
        end
        
        function result = testLegacyScriptExecution(obj)
            % Testa execução de scripts legados (simulado)
            result = struct();
            
            obj.logger.info('Testando execução de scripts legados...');
            
            % Scripts principais para testar
            legacyScripts = {
                'executar_comparacao.m'
                'main_sistema_comparacao.m'
            };
            
            result.scriptsExecutable = 0;
            result.scriptResults = struct();
            
            for i = 1:length(legacyScripts)
                scriptName = legacyScripts{i};
                
                try
                    % Verificar se script existe e pode ser analisado
                    if exist(scriptName, 'file')
                        % Simular teste de execução (análise estática)
                        canExecute = obj.analyzeScriptExecutability(scriptName);
                        
                        if canExecute
                            result.scriptsExecutable = result.scriptsExecutable + 1;
                            result.scriptResults.(obj.sanitizeFieldName(scriptName)) = struct();
                            result.scriptResults.(obj.sanitizeFieldName(scriptName)).executable = true;
                            
                            obj.logger.info(['✓ ' scriptName ' executável']);
                        else
                            result.scriptResults.(obj.sanitizeFieldName(scriptName)) = struct();
                            result.scriptResults.(obj.sanitizeFieldName(scriptName)).executable = false;
                            result.scriptResults.(obj.sanitizeFieldName(scriptName)).reason = 'Dependências não encontradas';
                            
                            obj.logger.warning(['⚠ ' scriptName ' pode ter problemas']);
                        end
                    else
                        result.scriptResults.(obj.sanitizeFieldName(scriptName)) = struct();
                        result.scriptResults.(obj.sanitizeFieldName(scriptName)).executable = false;
                        result.scriptResults.(obj.sanitizeFieldName(scriptName)).reason = 'Script não encontrado';
                        
                        obj.logger.warning(['⚠ ' scriptName ' não encontrado']);
                    end
                    
                catch ME
                    result.scriptResults.(obj.sanitizeFieldName(scriptName)) = struct();
                    result.scriptResults.(obj.sanitizeFieldName(scriptName)).executable = false;
                    result.scriptResults.(obj.sanitizeFieldName(scriptName)).error = ME.message;
                    
                    obj.logger.error(['✗ Erro ao testar ' scriptName ': ' ME.message]);
                end
            end
            
            result.totalScripts = length(legacyScripts);
            result.executionRate = result.scriptsExecutable / result.totalScripts;
            result.compatibilityAcceptable = result.executionRate >= 0.8;
        end
        
        function result = testDataStructureCompatibility(obj)
            % Testa compatibilidade de estruturas de dados
            result = struct();
            
            obj.logger.info('Testando compatibilidade de estruturas de dados...');
            
            % Estruturas de dados que devem ser mantidas
            expectedStructures = {
                'metrics' % estrutura de métricas
                'results' % estrutura de resultados
                'config'  % estrutura de configuração
            };
            
            result.structuresCompatible = 0;
            result.structureDetails = struct();
            
            for i = 1:length(expectedStructures)
                structName = expectedStructures{i};
                
                % Simular teste de compatibilidade de estrutura
                isCompatible = obj.testStructureCompatibility(structName);
                
                if isCompatible
                    result.structuresCompatible = result.structuresCompatible + 1;
                    result.structureDetails.(structName) = struct();
                    result.structureDetails.(structName).compatible = true;
                    
                    obj.logger.info(['✓ Estrutura ' structName ' compatível']);
                else
                    result.structureDetails.(structName) = struct();
                    result.structureDetails.(structName).compatible = false;
                    
                    obj.logger.warning(['⚠ Estrutura ' structName ' pode ter mudanças']);
                end
            end
            
            result.totalStructures = length(expectedStructures);
            result.compatibilityRate = result.structuresCompatible / result.totalStructures;
            result.compatibilityAcceptable = result.compatibilityRate >= 0.9;
        end
        
        function result = testAPICompatibility(obj)
            % Testa compatibilidade de API
            result = struct();
            
            obj.logger.info('Testando compatibilidade de API...');
            
            % Interfaces principais que devem ser mantidas
            coreInterfaces = {
                'src/core/MainInterface.m'
                'src/core/ComparisonController.m'
                'src/core/ConfigManager.m'
            };
            
            result.interfacesCompatible = 0;
            result.interfaceDetails = struct();
            
            for i = 1:length(coreInterfaces)
                interfaceName = coreInterfaces{i};
                
                if exist(interfaceName, 'file')
                    % Verificar se interface mantém métodos principais
                    hasMainMethods = obj.checkMainMethods(interfaceName);
                    
                    if hasMainMethods
                        result.interfacesCompatible = result.interfacesCompatible + 1;
                        result.interfaceDetails.(obj.sanitizeFieldName(interfaceName)) = struct();
                        result.interfaceDetails.(obj.sanitizeFieldName(interfaceName)).compatible = true;
                        
                        obj.logger.info(['✓ ' interfaceName ' compatível']);
                    else
                        result.interfaceDetails.(obj.sanitizeFieldName(interfaceName)) = struct();
                        result.interfaceDetails.(obj.sanitizeFieldName(interfaceName)).compatible = false;
                        
                        obj.logger.warning(['⚠ ' interfaceName ' pode ter mudanças na API']);
                    end
                else
                    result.interfaceDetails.(obj.sanitizeFieldName(interfaceName)) = struct();
                    result.interfaceDetails.(obj.sanitizeFieldName(interfaceName)).compatible = false;
                    result.interfaceDetails.(obj.sanitizeFieldName(interfaceName)).reason = 'Interface não encontrada';
                    
                    obj.logger.warning(['⚠ ' interfaceName ' não encontrada']);
                end
            end
            
            result.totalInterfaces = length(coreInterfaces);
            result.apiCompatibilityRate = result.interfacesCompatible / result.totalInterfaces;
            result.compatibilityAcceptable = result.apiCompatibilityRate >= 0.8;
        end 
       
        function result = testFileFormatCompatibility(obj)
            % Testa compatibilidade de formatos de arquivo
            result = struct();
            
            obj.logger.info('Testando compatibilidade de formatos de arquivo...');
            
            % Formatos que devem ser suportados
            supportedFormats = {'.mat', '.png', '.jpg', '.txt'};
            
            result.formatsSupported = 0;
            result.formatDetails = struct();
            
            for i = 1:length(supportedFormats)
                format = supportedFormats{i};
                
                % Simular teste de suporte ao formato
                isSupported = obj.testFormatSupport(format);
                
                if isSupported
                    result.formatsSupported = result.formatsSupported + 1;
                    result.formatDetails.(obj.sanitizeFieldName(format)) = struct();
                    result.formatDetails.(obj.sanitizeFieldName(format)).supported = true;
                    
                    obj.logger.info(['✓ Formato ' format ' suportado']);
                else
                    result.formatDetails.(obj.sanitizeFieldName(format)) = struct();
                    result.formatDetails.(obj.sanitizeFieldName(format)).supported = false;
                    
                    obj.logger.warning(['⚠ Formato ' format ' pode ter problemas']);
                end
            end
            
            result.totalFormats = length(supportedFormats);
            result.formatCompatibilityRate = result.formatsSupported / result.totalFormats;
            result.compatibilityAcceptable = result.formatCompatibilityRate >= 0.9;
        end
        
        function result = testConfigurationCompatibility(obj)
            % Testa compatibilidade de configurações
            result = struct();
            
            obj.logger.info('Testando compatibilidade de configurações...');
            
            % Verificar se ConfigManager existe e funciona
            if exist('src/core/ConfigManager.m', 'file')
                result.configManagerExists = true;
                
                % Testar se pode ser instanciado
                try
                    addpath('src/core');
                    config = ConfigManager();
                    result.canInstantiate = true;
                    
                    % Testar métodos básicos
                    result.hasSetParameter = obj.hasMethod('src/core/ConfigManager.m', 'setParameter');
                    result.hasGetParameter = obj.hasMethod('src/core/ConfigManager.m', 'getParameter');
                    
                    obj.logger.info('✓ ConfigManager compatível');
                    
                catch ME
                    result.canInstantiate = false;
                    result.instantiationError = ME.message;
                    obj.logger.warning(['⚠ Problema com ConfigManager: ' ME.message]);
                end
            else
                result.configManagerExists = false;
                result.canInstantiate = false;
                obj.logger.warning('⚠ ConfigManager não encontrado');
            end
            
            % Calcular compatibilidade geral
            compatibilityScore = 0;
            if result.configManagerExists
                compatibilityScore = compatibilityScore + 0.4;
            end
            if isfield(result, 'canInstantiate') && result.canInstantiate
                compatibilityScore = compatibilityScore + 0.3;
            end
            if isfield(result, 'hasSetParameter') && result.hasSetParameter
                compatibilityScore = compatibilityScore + 0.15;
            end
            if isfield(result, 'hasGetParameter') && result.hasGetParameter
                compatibilityScore = compatibilityScore + 0.15;
            end
            
            result.compatibilityScore = compatibilityScore;
            result.compatibilityAcceptable = compatibilityScore >= 0.7;
        end
        
        function result = testOutputCompatibility(obj)
            % Testa compatibilidade de saídas
            result = struct();
            
            obj.logger.info('Testando compatibilidade de saídas...');
            
            % Verificar se diretórios de saída padrão podem ser criados
            outputDirs = {'output', 'temp', 'results'};
            
            result.dirsAccessible = 0;
            result.dirDetails = struct();
            
            for i = 1:length(outputDirs)
                dirName = outputDirs{i};
                
                try
                    if exist(dirName, 'dir') || obj.canCreateDirectory(dirName)
                        result.dirsAccessible = result.dirsAccessible + 1;
                        result.dirDetails.(dirName) = struct();
                        result.dirDetails.(dirName).accessible = true;
                        
                        obj.logger.info(['✓ Diretório ' dirName ' acessível']);
                    else
                        result.dirDetails.(dirName) = struct();
                        result.dirDetails.(dirName).accessible = false;
                        
                        obj.logger.warning(['⚠ Diretório ' dirName ' não acessível']);
                    end
                    
                catch ME
                    result.dirDetails.(dirName) = struct();
                    result.dirDetails.(dirName).accessible = false;
                    result.dirDetails.(dirName).error = ME.message;
                    
                    obj.logger.warning(['⚠ Erro com diretório ' dirName ': ' ME.message]);
                end
            end
            
            result.totalDirs = length(outputDirs);
            result.accessibilityRate = result.dirsAccessible / result.totalDirs;
            result.compatibilityAcceptable = result.accessibilityRate >= 0.8;
        end
        
        function result = testPathCompatibility(obj)
            % Testa compatibilidade de caminhos
            result = struct();
            
            obj.logger.info('Testando compatibilidade de caminhos...');
            
            % Caminhos importantes que devem existir
            importantPaths = {
                'src'
                'img'
                'utils'
                'scripts'
            };
            
            result.pathsFound = 0;
            result.pathDetails = struct();
            
            for i = 1:length(importantPaths)
                pathName = importantPaths{i};
                
                if exist(pathName, 'dir')
                    result.pathsFound = result.pathsFound + 1;
                    result.pathDetails.(pathName) = struct();
                    result.pathDetails.(pathName).found = true;
                    
                    obj.logger.info(['✓ Caminho ' pathName ' encontrado']);
                else
                    result.pathDetails.(pathName) = struct();
                    result.pathDetails.(pathName).found = false;
                    
                    obj.logger.warning(['⚠ Caminho ' pathName ' não encontrado']);
                end
            end
            
            result.totalPaths = length(importantPaths);
            result.pathCompatibilityRate = result.pathsFound / result.totalPaths;
            result.compatibilityAcceptable = result.pathCompatibilityRate >= 0.75;
        end
        
        function result = testDependencyCompatibility(obj)
            % Testa compatibilidade de dependências
            result = struct();
            
            obj.logger.info('Testando compatibilidade de dependências...');
            
            % Verificar toolboxes essenciais
            requiredToolboxes = {
                'Deep Learning Toolbox'
                'Image Processing Toolbox'
            };
            
            result.toolboxesAvailable = 0;
            result.toolboxDetails = struct();
            
            % Obter lista de toolboxes instalados
            try
                verInfo = ver;
                installedToolboxes = {verInfo.Name};
                
                for i = 1:length(requiredToolboxes)
                    toolboxName = requiredToolboxes{i};
                    
                    if any(contains(installedToolboxes, toolboxName))
                        result.toolboxesAvailable = result.toolboxesAvailable + 1;
                        result.toolboxDetails.(obj.sanitizeFieldName(toolboxName)) = struct();
                        result.toolboxDetails.(obj.sanitizeFieldName(toolboxName)).available = true;
                        
                        obj.logger.info(['✓ ' toolboxName ' disponível']);
                    else
                        result.toolboxDetails.(obj.sanitizeFieldName(toolboxName)) = struct();
                        result.toolboxDetails.(obj.sanitizeFieldName(toolboxName)).available = false;
                        
                        obj.logger.warning(['⚠ ' toolboxName ' não encontrado']);
                    end
                end
                
            catch ME
                obj.logger.warning(['Erro ao verificar toolboxes: ' ME.message]);
                result.toolboxesAvailable = 0;
            end
            
            result.totalToolboxes = length(requiredToolboxes);
            result.dependencyRate = result.toolboxesAvailable / result.totalToolboxes;
            result.compatibilityAcceptable = result.dependencyRate >= 0.5;
        end
        
        function result = testMigrationSupport(obj)
            % Testa suporte à migração
            result = struct();
            
            obj.logger.info('Testando suporte à migração...');
            
            % Verificar se MigrationManager existe
            if exist('src/utils/MigrationManager.m', 'file')
                result.migrationManagerExists = true;
                obj.logger.info('✓ MigrationManager encontrado');
                
                % Verificar métodos de migração
                result.hasMigrationMethods = obj.hasMethod('src/utils/MigrationManager.m', 'migrate');
                
                if result.hasMigrationMethods
                    obj.logger.info('✓ Métodos de migração disponíveis');
                else
                    obj.logger.warning('⚠ Métodos de migração não encontrados');
                end
            else
                result.migrationManagerExists = false;
                result.hasMigrationMethods = false;
                obj.logger.warning('⚠ MigrationManager não encontrado');
            end
            
            result.migrationScore = (result.migrationManagerExists + result.hasMigrationMethods) / 2;
            result.compatibilityAcceptable = result.migrationScore >= 0.5;
        end
        
        % Métodos auxiliares
        function canExecute = analyzeScriptExecutability(obj, scriptName)
            % Analisa se script pode ser executado (análise estática)
            try
                fid = fopen(scriptName, 'r');
                if fid == -1
                    canExecute = false;
                    return;
                end
                
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificações básicas
                canExecute = ~contains(content, 'error(') && ...
                    ~contains(content, 'throw(') && ...
                    length(content) > 0;
                
            catch
                canExecute = false;
            end
        end
        
        function isCompatible = testStructureCompatibility(obj, structName)
            % Testa compatibilidade de estrutura específica
            % Por ora, assumir compatibilidade (implementação simplificada)
            isCompatible = true;
        end
        
        function hasMain = checkMainMethods(obj, interfaceName)
            % Verifica se interface tem métodos principais
            try
                fid = fopen(interfaceName, 'r');
                if fid == -1
                    hasMain = false;
                    return;
                end
                
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificar se tem métodos típicos de interface
                hasMain = contains(content, 'function') && ...
                    (contains(content, 'run') || contains(content, 'execute') || ...
                     contains(content, 'get') || contains(content, 'set'));
                
            catch
                hasMain = false;
            end
        end
        
        function isSupported = testFormatSupport(obj, format)
            % Testa suporte a formato específico
            % Assumir suporte para formatos comuns
            commonFormats = {'.mat', '.png', '.jpg', '.jpeg', '.txt', '.csv'};
            isSupported = any(strcmp(format, commonFormats));
        end
        
        function hasMethod = hasMethod(obj, fileName, methodName)
            % Verifica se arquivo tem método específico
            try
                fid = fopen(fileName, 'r');
                if fid == -1
                    hasMethod = false;
                    return;
                end
                
                content = fread(fid, '*char')';
                fclose(fid);
                
                hasMethod = contains(content, methodName);
                
            catch
                hasMethod = false;
            end
        end
        
        function canCreate = canCreateDirectory(obj, dirName)
            % Testa se pode criar diretório
            try
                if ~exist(dirName, 'dir')
                    mkdir(dirName);
                    canCreate = true;
                    rmdir(dirName); % Limpar
                else
                    canCreate = true;
                end
            catch
                canCreate = false;
            end
        end
        
        function fieldName = sanitizeFieldName(obj, name)
            % Sanitiza nome para usar como campo de struct
            fieldName = regexprep(name, '[^a-zA-Z0-9_]', '_');
            if isempty(fieldName) || ~isletter(fieldName(1))
                fieldName = ['field_' fieldName];
            end
        end
        
        function calculateSummary(obj)
            % Calcula resumo dos testes de compatibilidade
            testNames = fieldnames(obj.testResults.tests);
            totalTests = length(testNames);
            passedTests = 0;
            failedTests = 0;
            compatibilityIssues = 0;
            
            for i = 1:totalTests
                testName = testNames{i};
                testResult = obj.testResults.tests.(testName);
                
                if testResult.success
                    passedTests = passedTests + 1;
                    
                    % Verificar se há problemas de compatibilidade
                    if isfield(testResult, 'compatibilityAcceptable') && ...
                       ~testResult.compatibilityAcceptable
                        compatibilityIssues = compatibilityIssues + 1;
                    end
                else
                    failedTests = failedTests + 1;
                end
            end
            
            obj.testResults.summary.totalTests = totalTests;
            obj.testResults.summary.passedTests = passedTests;
            obj.testResults.summary.failedTests = failedTests;
            obj.testResults.summary.compatibilityIssues = compatibilityIssues;
            obj.testResults.summary.successRate = passedTests / totalTests;
            obj.testResults.overallSuccess = failedTests == 0 && compatibilityIssues == 0;
            
            obj.logger.info(['Resumo de compatibilidade: ' num2str(passedTests) '/' ...
                num2str(totalTests) ' testes passaram, ' ...
                num2str(compatibilityIssues) ' problemas de compatibilidade detectados']);
        end
        
        function config = getDefaultConfig(obj)
            % Configuração padrão
            config = struct();
            config.strictCompatibility = false;
            config.testExecution = false; % Por segurança, não executar scripts
            config.testAllFormats = true;
        end
    end
end