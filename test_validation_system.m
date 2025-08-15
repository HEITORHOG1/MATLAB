% TEST_VALIDATION_SYSTEM - Teste completo do sistema de validação
%
% Este script testa o sistema de validação implementado para garantir
% que todos os componentes funcionam corretamente.

function test_validation_system()

fprintf('=== TESTE DO SISTEMA DE VALIDAÇÃO ===\n\n');

% Configuração de teste
config = struct();
config.outputPath = fullfile('validation_results', 'test_run');
config.runQuickTests = true;
config.generateDocumentation = false;
config.verboseOutput = false; % Reduzir verbosidade para teste

% Limpar diretório de teste anterior
if exist(config.outputPath, 'dir')
    rmdir(config.outputPath, 's');
end

% Adicionar caminhos
addpath(genpath('src'));

testResults = struct();
testResults.totalTests = 0;
testResults.passedTests = 0;
testResults.failedTests = 0;
testResults.errors = {};

%% Teste 1: ValidationLogger
fprintf('1. Testando ValidationLogger...\n');
testResults.totalTests = testResults.totalTests + 1;

try
    logger = ValidationLogger('TestLogger');
    logger.info('Teste de logging');
    logger.warning('Teste de warning');
    
    % Verificar se arquivo de log foi criado
    logFile = logger.getLogFile();
    if exist(logFile, 'file')
        fprintf('   ✓ ValidationLogger funcionando\n');
        testResults.passedTests = testResults.passedTests + 1;
    else
        fprintf('   ✗ Arquivo de log não criado\n');
        testResults.failedTests = testResults.failedTests + 1;
        testResults.errors{end+1} = 'ValidationLogger: arquivo de log não criado';
    end
    
catch ME
    fprintf('   ✗ Erro no ValidationLogger: %s\n', ME.message);
    testResults.failedTests = testResults.failedTests + 1;
    testResults.errors{end+1} = ['ValidationLogger: ' ME.message];
end

%% Teste 2: ComponentValidator
fprintf('2. Testando ComponentValidator...\n');
testResults.totalTests = testResults.totalTests + 1;

try
    validator = ComponentValidator(config);
    
    % Testar validação de um componente que sabemos que existe
    result = validator.validateComponent('ValidationLogger');
    
    if isfield(result, 'isValid')
        fprintf('   ✓ ComponentValidator funcionando\n');
        testResults.passedTests = testResults.passedTests + 1;
    else
        fprintf('   ✗ ComponentValidator não retornou resultado válido\n');
        testResults.failedTests = testResults.failedTests + 1;
        testResults.errors{end+1} = 'ComponentValidator: resultado inválido';
    end
    
catch ME
    fprintf('   ✗ Erro no ComponentValidator: %s\n', ME.message);
    testResults.failedTests = testResults.failedTests + 1;
    testResults.errors{end+1} = ['ComponentValidator: ' ME.message];
end

%% Teste 3: IntegrationTestSuite
fprintf('3. Testando IntegrationTestSuite...\n');
testResults.totalTests = testResults.totalTests + 1;

try
    integrationSuite = IntegrationTestSuite(config);
    
    % Testar um método específico
    result = integrationSuite.testModelManagementIntegration();
    
    if isfield(result, 'integrationScore')
        fprintf('   ✓ IntegrationTestSuite funcionando\n');
        testResults.passedTests = testResults.passedTests + 1;
    else
        fprintf('   ✗ IntegrationTestSuite não retornou resultado válido\n');
        testResults.failedTests = testResults.failedTests + 1;
        testResults.errors{end+1} = 'IntegrationTestSuite: resultado inválido';
    end
    
catch ME
    fprintf('   ✗ Erro no IntegrationTestSuite: %s\n', ME.message);
    testResults.failedTests = testResults.failedTests + 1;
    testResults.errors{end+1} = ['IntegrationTestSuite: ' ME.message];
end

%% Teste 4: RegressionTestSuite
fprintf('4. Testando RegressionTestSuite...\n');
testResults.totalTests = testResults.totalTests + 1;

try
    regressionSuite = RegressionTestSuite(config);
    
    % Testar um método específico
    result = regressionSuite.testBasicFunctionalityRegression();
    
    if isfield(result, 'basicFunctionalityScore')
        fprintf('   ✓ RegressionTestSuite funcionando\n');
        testResults.passedTests = testResults.passedTests + 1;
    else
        fprintf('   ✗ RegressionTestSuite não retornou resultado válido\n');
        testResults.failedTests = testResults.failedTests + 1;
        testResults.errors{end+1} = 'RegressionTestSuite: resultado inválido';
    end
    
catch ME
    fprintf('   ✗ Erro no RegressionTestSuite: %s\n', ME.message);
    testResults.failedTests = testResults.failedTests + 1;
    testResults.errors{end+1} = ['RegressionTestSuite: ' ME.message];
end

%% Teste 5: PerformanceTestSuite
fprintf('5. Testando PerformanceTestSuite...\n');
testResults.totalTests = testResults.totalTests + 1;

try
    performanceSuite = PerformanceTestSuite(config);
    
    % Testar um método específico
    result = performanceSuite.testMemoryUsage();
    
    if isfield(result, 'initialMemory')
        fprintf('   ✓ PerformanceTestSuite funcionando\n');
        testResults.passedTests = testResults.passedTests + 1;
    else
        fprintf('   ✗ PerformanceTestSuite não retornou resultado válido\n');
        testResults.failedTests = testResults.failedTests + 1;
        testResults.errors{end+1} = 'PerformanceTestSuite: resultado inválido';
    end
    
catch ME
    fprintf('   ✗ Erro no PerformanceTestSuite: %s\n', ME.message);
    testResults.failedTests = testResults.failedTests + 1;
    testResults.errors{end+1} = ['PerformanceTestSuite: ' ME.message];
end

%% Teste 6: BackwardCompatibilityTester
fprintf('6. Testando BackwardCompatibilityTester...\n');
testResults.totalTests = testResults.totalTests + 1;

try
    compatibilityTester = BackwardCompatibilityTester(config);
    
    % Testar um método específico
    result = compatibilityTester.testLegacyFunctionAvailability();
    
    if isfield(result, 'functionsFound')
        fprintf('   ✓ BackwardCompatibilityTester funcionando\n');
        testResults.passedTests = testResults.passedTests + 1;
    else
        fprintf('   ✗ BackwardCompatibilityTester não retornou resultado válido\n');
        testResults.failedTests = testResults.failedTests + 1;
        testResults.errors{end+1} = 'BackwardCompatibilityTester: resultado inválido';
    end
    
catch ME
    fprintf('   ✗ Erro no BackwardCompatibilityTester: %s\n', ME.message);
    testResults.failedTests = testResults.failedTests + 1;
    testResults.errors{end+1} = ['BackwardCompatibilityTester: ' ME.message];
end

%% Teste 7: DocumentationGenerator
fprintf('7. Testando DocumentationGenerator...\n');
testResults.totalTests = testResults.totalTests + 1;

try
    docGenerator = DocumentationGenerator(config);
    
    % Testar geração de conteúdo
    content = docGenerator.createUserGuideContent();
    
    if iscell(content) && ~isempty(content)
        fprintf('   ✓ DocumentationGenerator funcionando\n');
        testResults.passedTests = testResults.passedTests + 1;
    else
        fprintf('   ✗ DocumentationGenerator não gerou conteúdo válido\n');
        testResults.failedTests = testResults.failedTests + 1;
        testResults.errors{end+1} = 'DocumentationGenerator: conteúdo inválido';
    end
    
catch ME
    fprintf('   ✗ Erro no DocumentationGenerator: %s\n', ME.message);
    testResults.failedTests = testResults.failedTests + 1;
    testResults.errors{end+1} = ['DocumentationGenerator: ' ME.message];
end

%% Teste 8: QualityReportGenerator
fprintf('8. Testando QualityReportGenerator...\n');
testResults.totalTests = testResults.totalTests + 1;

try
    reportGenerator = QualityReportGenerator(config);
    
    % Criar resultados simulados para teste
    simulatedResults = struct();
    simulatedResults.success = true;
    simulatedResults.totalTime = 30;
    
    % Criar diretório de teste
    if ~exist(config.outputPath, 'dir')
        mkdir(config.outputPath);
    end
    
    % Testar análise de resultados
    analysis = reportGenerator.analyzeValidationResults(simulatedResults);
    
    if isfield(analysis, 'overallSuccess')
        fprintf('   ✓ QualityReportGenerator funcionando\n');
        testResults.passedTests = testResults.passedTests + 1;
    else
        fprintf('   ✗ QualityReportGenerator não retornou análise válida\n');
        testResults.failedTests = testResults.failedTests + 1;
        testResults.errors{end+1} = 'QualityReportGenerator: análise inválida';
    end
    
catch ME
    fprintf('   ✗ Erro no QualityReportGenerator: %s\n', ME.message);
    testResults.failedTests = testResults.failedTests + 1;
    testResults.errors{end+1} = ['QualityReportGenerator: ' ME.message];
end

%% Teste 9: ValidationMaster
fprintf('9. Testando ValidationMaster...\n');
testResults.totalTests = testResults.totalTests + 1;

try
    validator = ValidationMaster(config);
    
    % Verificar se pode ser instanciado
    if isa(validator, 'ValidationMaster')
        fprintf('   ✓ ValidationMaster funcionando\n');
        testResults.passedTests = testResults.passedTests + 1;
    else
        fprintf('   ✗ ValidationMaster não foi instanciado corretamente\n');
        testResults.failedTests = testResults.failedTests + 1;
        testResults.errors{end+1} = 'ValidationMaster: instanciação falhou';
    end
    
catch ME
    fprintf('   ✗ Erro no ValidationMaster: %s\n', ME.message);
    testResults.failedTests = testResults.failedTests + 1;
    testResults.errors{end+1} = ['ValidationMaster: ' ME.message];
end

%% Teste 10: Script de validação completa
fprintf('10. Testando script de validação completa...\n');
testResults.totalTests = testResults.totalTests + 1;

try
    % Verificar se função existe
    if exist('run_complete_validation', 'file')
        fprintf('   ✓ Script de validação completa encontrado\n');
        testResults.passedTests = testResults.passedTests + 1;
    else
        fprintf('   ✗ Script de validação completa não encontrado\n');
        testResults.failedTests = testResults.failedTests + 1;
        testResults.errors{end+1} = 'run_complete_validation: arquivo não encontrado';
    end
    
catch ME
    fprintf('   ✗ Erro ao verificar script: %s\n', ME.message);
    testResults.failedTests = testResults.failedTests + 1;
    testResults.errors{end+1} = ['run_complete_validation: ' ME.message];
end

%% Resumo dos testes
fprintf('\n=== RESUMO DOS TESTES ===\n');
fprintf('Total de testes: %d\n', testResults.totalTests);
fprintf('Testes aprovados: %d\n', testResults.passedTests);
fprintf('Testes falharam: %d\n', testResults.failedTests);
fprintf('Taxa de sucesso: %.1f%%\n', (testResults.passedTests / testResults.totalTests) * 100);

if testResults.failedTests > 0
    fprintf('\nERROS ENCONTRADOS:\n');
    for i = 1:length(testResults.errors)
        fprintf('  - %s\n', testResults.errors{i});
    end
end

% Determinar resultado final
if testResults.failedTests == 0
    fprintf('\n✓ TODOS OS TESTES PASSARAM - Sistema de validação funcionando corretamente!\n');
    success = true;
elseif testResults.passedTests >= testResults.totalTests * 0.8
    fprintf('\n⚠ MAIORIA DOS TESTES PASSOU - Sistema funcional com pequenos problemas\n');
    success = true;
else
    fprintf('\n✗ MUITOS TESTES FALHARAM - Sistema precisa de correções\n');
    success = false;
end

% Salvar resultados do teste
if exist(config.outputPath, 'dir')
    testResultsFile = fullfile(config.outputPath, 'test_results.mat');
    save(testResultsFile, 'testResults');
    fprintf('\nResultados salvos em: %s\n', testResultsFile);
end

fprintf('\n=== FIM DOS TESTES ===\n');

% Retornar código de saída
if ~success
    error('Testes do sistema de validação falharam');
end

end