% DEMO_VALIDATION_SYSTEM - Demonstração do sistema de validação
%
% Este script demonstra como usar o sistema de validação completo
% do sistema melhorado de segmentação.

%% Limpeza inicial
clear;
clc;
fprintf('=== DEMO DO SISTEMA DE VALIDAÇÃO ===\n\n');

%% Configuração
fprintf('1. Configurando ambiente...\n');

% Adicionar caminhos
addpath(genpath('src'));

% Configuração para demo (testes rápidos)
config = struct();
config.outputPath = fullfile('validation_results', 'demo_validation');
config.runQuickTests = true;
config.generateDocumentation = false; % Desabilitar para demo rápido
config.verboseOutput = true;

fprintf('   ✓ Caminhos configurados\n');
fprintf('   ✓ Configuração criada\n');
fprintf('   ✓ Diretório de saída: %s\n', config.outputPath);

%% Demonstração 1: Validação de Componentes Individuais
fprintf('\n2. Demonstrando validação de componentes...\n');

try
    componentValidator = ComponentValidator(config);
    
    % Validar alguns componentes específicos
    fprintf('   Validando ModelSaver...\n');
    modelSaverResult = componentValidator.validateComponent('ModelSaver');
    
    if modelSaverResult.isValid
        fprintf('   ✓ ModelSaver válido (score: %.1f/100)\n', modelSaverResult.qualityScore);
    else
        fprintf('   ⚠ ModelSaver com problemas\n');
    end
    
    fprintf('   Validando InferenceEngine...\n');
    inferenceResult = componentValidator.validateComponent('InferenceEngine');
    
    if inferenceResult.isValid
        fprintf('   ✓ InferenceEngine válido (score: %.1f/100)\n', inferenceResult.qualityScore);
    else
        fprintf('   ⚠ InferenceEngine com problemas\n');
    end
    
catch ME
    fprintf('   ✗ Erro na validação de componentes: %s\n', ME.message);
end

%% Demonstração 2: Testes de Integração Rápidos
fprintf('\n3. Demonstrando testes de integração...\n');

try
    integrationSuite = IntegrationTestSuite(config);
    
    % Executar apenas alguns testes para demo
    fprintf('   Testando integração do sistema de modelos...\n');
    modelIntegrationResult = integrationSuite.testModelManagementIntegration();
    
    if modelIntegrationResult.integrationScore >= 0.5
        fprintf('   ✓ Integração de modelos OK (score: %.1f)\n', modelIntegrationResult.integrationScore);
    else
        fprintf('   ⚠ Problemas na integração de modelos\n');
    end
    
    fprintf('   Testando integração do sistema de inferência...\n');
    inferenceIntegrationResult = integrationSuite.testInferenceSystemIntegration();
    
    if inferenceIntegrationResult.inferenceEngineFound
        fprintf('   ✓ Sistema de inferência encontrado\n');
    else
        fprintf('   ⚠ Sistema de inferência não encontrado\n');
    end
    
catch ME
    fprintf('   ✗ Erro nos testes de integração: %s\n', ME.message);
end

%% Demonstração 3: Testes de Compatibilidade
fprintf('\n4. Demonstrando testes de compatibilidade...\n');

try
    compatibilityTester = BackwardCompatibilityTester(config);
    
    fprintf('   Testando disponibilidade de funções legadas...\n');
    legacyResult = compatibilityTester.testLegacyFunctionAvailability();
    
    fprintf('   ✓ Funções encontradas: %d/%d (%.1f%%)\n', ...
        legacyResult.functionsFound, legacyResult.totalFunctions, ...
        legacyResult.availabilityRate * 100);
    
    fprintf('   Testando compatibilidade de API...\n');
    apiResult = compatibilityTester.testAPICompatibility();
    
    fprintf('   ✓ Interfaces compatíveis: %d/%d (%.1f%%)\n', ...
        apiResult.interfacesCompatible, apiResult.totalInterfaces, ...
        apiResult.apiCompatibilityRate * 100);
    
catch ME
    fprintf('   ✗ Erro nos testes de compatibilidade: %s\n', ME.message);
end

%% Demonstração 4: Testes de Performance Básicos
fprintf('\n5. Demonstrando testes de performance...\n');

try
    performanceSuite = PerformanceTestSuite(config);
    
    fprintf('   Testando uso de memória...\n');
    memoryResult = performanceSuite.testMemoryUsage();
    
    fprintf('   ✓ Memória inicial: %.1f MB\n', memoryResult.initialMemory);
    fprintf('   ✓ Memória pico: %.1f MB\n', memoryResult.peakMemory);
    
    if memoryResult.performanceAcceptable
        fprintf('   ✓ Uso de memória aceitável\n');
    else
        fprintf('   ⚠ Uso de memória elevado\n');
    end
    
    fprintf('   Testando velocidade de processamento...\n');
    speedResult = performanceSuite.testProcessingSpeed();
    
    fprintf('   ✓ Operações matemáticas: %.3f segundos\n', speedResult.mathOperationsTime);
    fprintf('   ✓ Operações de arquivo: %.3f segundos\n', speedResult.fileOperationsTime);
    
catch ME
    fprintf('   ✗ Erro nos testes de performance: %s\n', ME.message);
end

%% Demonstração 5: Geração de Relatório Simples
fprintf('\n6. Demonstrando geração de relatório...\n');

try
    % Simular resultados de validação para o relatório
    simulatedResults = struct();
    simulatedResults.success = true;
    simulatedResults.totalTime = 45.2;
    simulatedResults.integration = struct('overallSuccess', true, 'summary', ...
        struct('totalTests', 8, 'passedTests', 7, 'failedTests', 1, 'successRate', 0.875));
    simulatedResults.regression = struct('overallSuccess', true, 'summary', ...
        struct('totalTests', 6, 'passedTests', 6, 'failedTests', 0, 'successRate', 1.0, 'regressionIssues', 0));
    simulatedResults.performance = struct('overallSuccess', true, 'summary', ...
        struct('totalTests', 5, 'passedTests', 4, 'failedTests', 1, 'successRate', 0.8, 'performanceIssues', 1));
    
    reportGenerator = QualityReportGenerator(config);
    
    % Criar diretório de saída se não existir
    if ~exist(config.outputPath, 'dir')
        mkdir(config.outputPath);
    end
    
    fprintf('   Gerando relatório de qualidade...\n');
    qualityReport = reportGenerator.generateFinalReport(simulatedResults, config.outputPath);
    
    if qualityReport.success
        fprintf('   ✓ Relatório gerado com sucesso\n');
        fprintf('   ✓ Arquivo HTML: %s\n', qualityReport.htmlReport);
        fprintf('   ✓ Arquivo texto: %s\n', qualityReport.textReport);
    else
        fprintf('   ⚠ Problemas na geração do relatório\n');
    end
    
catch ME
    fprintf('   ✗ Erro na geração de relatório: %s\n', ME.message);
end

%% Demonstração 6: Sistema de Logging
fprintf('\n7. Demonstrando sistema de logging...\n');

try
    logger = ValidationLogger('DemoSystem');
    
    logger.info('Iniciando demonstração de logging');
    logger.debug('Mensagem de debug (pode não aparecer dependendo do nível)');
    logger.warning('Exemplo de warning');
    logger.error('Exemplo de erro (não é um erro real)');
    
    fprintf('   ✓ Sistema de logging funcionando\n');
    fprintf('   ✓ Log salvo em: %s\n', logger.getLogFile());
    
catch ME
    fprintf('   ✗ Erro no sistema de logging: %s\n', ME.message);
end

%% Resumo Final
fprintf('\n=== RESUMO DA DEMONSTRAÇÃO ===\n');
fprintf('✓ Validação de componentes individuais\n');
fprintf('✓ Testes de integração entre componentes\n');
fprintf('✓ Testes de compatibilidade com sistema anterior\n');
fprintf('✓ Testes básicos de performance\n');
fprintf('✓ Geração de relatórios de qualidade\n');
fprintf('✓ Sistema de logging detalhado\n');

fprintf('\nPara executar validação completa, use:\n');
fprintf('   results = run_complete_validation();\n');

fprintf('\nPara validação completa com documentação:\n');
fprintf('   config.generateDocumentation = true;\n');
fprintf('   results = run_complete_validation(config);\n');

fprintf('\n=== FIM DA DEMONSTRAÇÃO ===\n');

%% Limpeza
fprintf('\nLimpando variáveis temporárias...\n');
clear config simulatedResults;
fprintf('Demo concluído!\n');