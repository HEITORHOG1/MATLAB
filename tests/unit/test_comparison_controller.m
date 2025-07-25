function test_comparison_controller()
    % ========================================================================
    % TESTES UNITÁRIOS - COMPARISON CONTROLLER
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Testes unitários abrangentes para a classe ComparisonController
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Deep Learning Toolbox
    %   - Model Comparison
    % ========================================================================
    
    fprintf('=== INICIANDO TESTES UNITÁRIOS - COMPARISON CONTROLLER ===\n\n');
    
    % Adicionar caminho para as classes
    addpath(genpath('src'));
    
    % Executar todos os testes
    try
        test_constructor();
        test_configuration_management();
        test_data_preparation();
        test_model_training_coordination();
        test_evaluation_coordination();
        test_comparison_analysis();
        test_report_generation();
        test_workflow_management();
        test_error_handling();
        
        fprintf('\n=== TODOS OS TESTES PASSARAM! ===\n');
        
    catch ME
        fprintf('\n=== ERRO NOS TESTES ===\n');
        fprintf('Erro: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('Arquivo: %s\n', ME.stack(1).file);
            fprintf('Linha: %d\n', ME.stack(1).line);
        end
        rethrow(ME);
    end
end

function test_constructor()
    fprintf('Testando construtor...\n');
    
    % Teste construtor padrão
    controller1 = ComparisonController();
    assert(isa(controller1, 'ComparisonController'), 'Construtor padrão falhou');
    
    % Teste construtor com configuração
    config = struct();
    config.verbose = true;
    config.enableLogging = true;
    config.outputDir = 'test_output';
    
    controller2 = ComparisonController(config);
    assert(isa(controller2, 'ComparisonController'), 'Construtor com configuração falhou');
    
    % Teste construtor com componentes personalizados
    mockLogger = struct('log', @(level, msg) fprintf('[%s] %s\n', level, msg));
    
    controller3 = ComparisonController('logger', mockLogger, 'verbose', false);
    assert(isa(controller3, 'ComparisonController'), 'Construtor com componentes falhou');
    
    fprintf('✓ Construtor OK\n');
end

function test_configuration_management()
    fprintf('Testando gerenciamento de configuração...\n');
    
    controller = ComparisonController('verbose', false);
    
    % Testar configuração padrão
    defaultConfig = controller.getDefaultConfig();
    assert(isstruct(defaultConfig), 'Configuração padrão não é struct');
    assert(isfield(defaultConfig, 'models'), 'Campo models não encontrado');
    assert(isfield(defaultConfig, 'training'), 'Campo training não encontrado');
    assert(isfield(defaultConfig, 'evaluation'), 'Campo evaluation não encontrado');
    assert(isfield(defaultConfig, 'comparison'), 'Campo comparison não encontrado');
    
    % Testar validação de configuração
    validConfig = defaultConfig;
    validConfig.models.inputSize = [256, 256, 3];
    validConfig.models.numClasses = 2;
    validConfig.training.maxEpochs = 10;
    validConfig.training.miniBatchSize = 4;
    
    [isValid, errors] = controller.validateConfig(validConfig);
    assert(isValid, sprintf('Configuração válida rejeitada: %s', strjoin(errors, '; ')));
    assert(isempty(errors), 'Erros reportados para configuração válida');
    
    % Testar configuração inválida
    invalidConfig = validConfig;
    invalidConfig.models.inputSize = [256, 256]; % Dimensão incorreta
    invalidConfig.training.maxEpochs = -1; % Valor inválido
    
    [isValid2, errors2] = controller.validateConfig(invalidConfig);
    assert(~isValid2, 'Configuração inválida aceita');
    assert(~isempty(errors2), 'Nenhum erro reportado para configuração inválida');
    
    % Testar aplicação de configuração
    success = controller.setConfig(validConfig);
    assert(success, 'Falha ao aplicar configuração válida');
    
    retrievedConfig = controller.getConfig();
    assert(isstruct(retrievedConfig), 'Configuração recuperada não é struct');
    assert(isequal(retrievedConfig.models.inputSize, [256, 256, 3]), 'Configuração não foi aplicada corretamente');
    
    fprintf('✓ Gerenciamento de configuração OK\n');
end

function test_data_preparation()
    fprintf('Testando preparação de dados...\n');
    
    controller = ComparisonController('verbose', false);
    
    % Configurar dados de teste
    config = controller.getDefaultConfig();
    config.data = struct();
    config.data.imageDir = createTestImageDir();
    config.data.maskDir = createTestMaskDir();
    config.data.inputSize = [128, 128, 3];
    config.data.numClasses = 2;
    
    controller.setConfig(config);
    
    % Testar preparação de dados
    dataInfo = controller.prepareData();
    assert(isstruct(dataInfo), 'Informações de dados não são struct');
    assert(isfield(dataInfo, 'numSamples'), 'Campo numSamples não encontrado');
    assert(isfield(dataInfo, 'trainSplit'), 'Campo trainSplit não encontrado');
    assert(isfield(dataInfo, 'valSplit'), 'Campo valSplit não encontrado');
    assert(isfield(dataInfo, 'testSplit'), 'Campo testSplit não encontrado');
    
    assert(dataInfo.numSamples > 0, 'Nenhuma amostra encontrada');
    assert(dataInfo.trainSplit.size > 0, 'Conjunto de treino vazio');
    assert(dataInfo.valSplit.size > 0, 'Conjunto de validação vazio');
    
    % Testar validação de dados
    validationResult = controller.validateData();
    assert(isstruct(validationResult), 'Resultado de validação não é struct');
    assert(isfield(validationResult, 'isValid'), 'Campo isValid não encontrado');
    assert(isfield(validationResult, 'issues'), 'Campo issues não encontrado');
    assert(isfield(validationResult, 'recommendations'), 'Campo recommendations não encontrado');
    
    % Testar estatísticas de dados
    dataStats = controller.getDataStatistics();
    assert(isstruct(dataStats), 'Estatísticas não são struct');
    assert(isfield(dataStats, 'imageStats'), 'Campo imageStats não encontrado');
    assert(isfield(dataStats, 'maskStats'), 'Campo maskStats não encontrado');
    assert(isfield(dataStats, 'classDistribution'), 'Campo classDistribution não encontrado');
    
    % Limpar dados de teste
    cleanupTestDirs(config.data.imageDir, config.data.maskDir);
    
    fprintf('✓ Preparação de dados OK\n');
end

function test_model_training_coordination()
    fprintf('Testando coordenação de treinamento...\n');
    
    controller = ComparisonController('verbose', false);
    
    % Configurar para teste rápido
    config = controller.getDefaultConfig();
    config.training.maxEpochs = 1;
    config.training.miniBatchSize = 2;
    config.training.quickTest = true;
    config.models.inputSize = [64, 64, 3];
    config.models.numClasses = 2;
    
    controller.setConfig(config);
    
    % Testar preparação de modelos
    modelInfo = controller.prepareModels();
    assert(isstruct(modelInfo), 'Informações de modelos não são struct');
    assert(isfield(modelInfo, 'unet'), 'Campo unet não encontrado');
    assert(isfield(modelInfo, 'attentionUnet'), 'Campo attentionUnet não encontrado');
    
    % Testar estimativa de tempo de treinamento
    timeEstimate = controller.estimateTrainingTime();
    assert(isstruct(timeEstimate), 'Estimativa de tempo não é struct');
    assert(isfield(timeEstimate, 'unet'), 'Campo unet não encontrado na estimativa');
    assert(isfield(timeEstimate, 'attentionUnet'), 'Campo attentionUnet não encontrado na estimativa');
    assert(isfield(timeEstimate, 'total'), 'Campo total não encontrado na estimativa');
    
    assert(timeEstimate.unet > 0, 'Estimativa para U-Net deve ser positiva');
    assert(timeEstimate.attentionUnet > 0, 'Estimativa para Attention U-Net deve ser positiva');
    assert(timeEstimate.total > 0, 'Estimativa total deve ser positiva');
    
    % Testar configuração de treinamento
    trainingConfig = controller.getTrainingConfig();
    assert(isstruct(trainingConfig), 'Configuração de treinamento não é struct');
    assert(isfield(trainingConfig, 'options'), 'Campo options não encontrado');
    assert(isfield(trainingConfig, 'callbacks'), 'Campo callbacks não encontrado');
    
    % Testar monitoramento de treinamento (simulado)
    controller.startTrainingMonitoring();
    
    % Simular progresso de treinamento
    controller.updateTrainingProgress('unet', 0.5, struct('loss', 0.8, 'accuracy', 0.6));
    controller.updateTrainingProgress('attentionUnet', 0.3, struct('loss', 0.9, 'accuracy', 0.5));
    
    trainingStatus = controller.getTrainingStatus();
    assert(isstruct(trainingStatus), 'Status de treinamento não é struct');
    assert(isfield(trainingStatus, 'unet'), 'Campo unet não encontrado no status');
    assert(isfield(trainingStatus, 'attentionUnet'), 'Campo attentionUnet não encontrado no status');
    
    assert(trainingStatus.unet.progress == 0.5, 'Progresso U-Net incorreto');
    assert(trainingStatus.attentionUnet.progress == 0.3, 'Progresso Attention U-Net incorreto');
    
    controller.stopTrainingMonitoring();
    
    fprintf('✓ Coordenação de treinamento OK\n');
end

function test_evaluation_coordination()
    fprintf('Testando coordenação de avaliação...\n');
    
    controller = ComparisonController('verbose', false);
    
    % Configurar avaliação
    config = controller.getDefaultConfig();
    config.evaluation.metrics = {'iou', 'dice', 'accuracy'};
    config.evaluation.crossValidation = false; % Desabilitar para teste rápido
    config.evaluation.statisticalTests = true;
    
    controller.setConfig(config);
    
    % Simular resultados de modelos
    mockResults = struct();
    mockResults.unet = struct();
    mockResults.unet.predictions = {rand(64, 64) > 0.5, rand(64, 64) > 0.5, rand(64, 64) > 0.5};
    mockResults.unet.groundTruth = {rand(64, 64) > 0.5, rand(64, 64) > 0.5, rand(64, 64) > 0.5};
    
    mockResults.attentionUnet = struct();
    mockResults.attentionUnet.predictions = {rand(64, 64) > 0.5, rand(64, 64) > 0.5, rand(64, 64) > 0.5};
    mockResults.attentionUnet.groundTruth = mockResults.unet.groundTruth; % Mesma ground truth
    
    % Testar coordenação de avaliação
    evaluationPlan = controller.createEvaluationPlan(mockResults);
    assert(isstruct(evaluationPlan), 'Plano de avaliação não é struct');
    assert(isfield(evaluationPlan, 'metrics'), 'Campo metrics não encontrado');
    assert(isfield(evaluationPlan, 'comparisons'), 'Campo comparisons não encontrado');
    assert(isfield(evaluationPlan, 'statisticalTests'), 'Campo statisticalTests não encontrado');
    
    % Testar execução de avaliação
    evaluationResults = controller.executeEvaluation(mockResults);
    assert(isstruct(evaluationResults), 'Resultados de avaliação não são struct');
    assert(isfield(evaluationResults, 'unet'), 'Campo unet não encontrado nos resultados');
    assert(isfield(evaluationResults, 'attentionUnet'), 'Campo attentionUnet não encontrado nos resultados');
    assert(isfield(evaluationResults, 'comparison'), 'Campo comparison não encontrado nos resultados');
    
    % Verificar métricas individuais
    assert(isfield(evaluationResults.unet, 'iou'), 'Métrica IoU não encontrada para U-Net');
    assert(isfield(evaluationResults.unet, 'dice'), 'Métrica Dice não encontrada para U-Net');
    assert(isfield(evaluationResults.unet, 'accuracy'), 'Métrica Accuracy não encontrada para U-Net');
    
    assert(isfield(evaluationResults.attentionUnet, 'iou'), 'Métrica IoU não encontrada para Attention U-Net');
    assert(isfield(evaluationResults.attentionUnet, 'dice'), 'Métrica Dice não encontrada para Attention U-Net');
    assert(isfield(evaluationResults.attentionUnet, 'accuracy'), 'Métrica Accuracy não encontrada para Attention U-Net');
    
    % Verificar comparação
    assert(isfield(evaluationResults.comparison, 'winner'), 'Campo winner não encontrado');
    assert(isfield(evaluationResults.comparison, 'significance'), 'Campo significance não encontrado');
    assert(isfield(evaluationResults.comparison, 'differences'), 'Campo differences não encontrado');
    
    fprintf('✓ Coordenação de avaliação OK\n');
end

function test_comparison_analysis()
    fprintf('Testando análise de comparação...\n');
    
    controller = ComparisonController('verbose', false);
    
    % Criar dados de teste para comparação
    unetMetrics = struct();
    unetMetrics.iou = [0.75, 0.78, 0.72, 0.80, 0.76];
    unetMetrics.dice = [0.85, 0.87, 0.82, 0.89, 0.84];
    unetMetrics.accuracy = [0.92, 0.94, 0.90, 0.95, 0.91];
    
    attentionMetrics = struct();
    attentionMetrics.iou = [0.78, 0.81, 0.75, 0.83, 0.79];
    attentionMetrics.dice = [0.87, 0.89, 0.84, 0.91, 0.86];
    attentionMetrics.accuracy = [0.94, 0.96, 0.92, 0.97, 0.93];
    
    % Testar análise estatística
    statisticalAnalysis = controller.performStatisticalAnalysis(unetMetrics, attentionMetrics);
    assert(isstruct(statisticalAnalysis), 'Análise estatística não é struct');
    assert(isfield(statisticalAnalysis, 'tTest'), 'Campo tTest não encontrado');
    assert(isfield(statisticalAnalysis, 'confidenceIntervals'), 'Campo confidenceIntervals não encontrado');
    assert(isfield(statisticalAnalysis, 'effectSize'), 'Campo effectSize não encontrado');
    
    % Verificar t-test
    assert(isfield(statisticalAnalysis.tTest, 'iou'), 'T-test IoU não encontrado');
    assert(isfield(statisticalAnalysis.tTest, 'dice'), 'T-test Dice não encontrado');
    assert(isfield(statisticalAnalysis.tTest, 'accuracy'), 'T-test Accuracy não encontrado');
    
    % Testar determinação do vencedor
    winner = controller.determineWinner(unetMetrics, attentionMetrics);
    assert(isstruct(winner), 'Resultado do vencedor não é struct');
    assert(isfield(winner, 'model'), 'Campo model não encontrado');
    assert(isfield(winner, 'confidence'), 'Campo confidence não encontrado');
    assert(isfield(winner, 'reasons'), 'Campo reasons não encontrado');
    
    assert(ismember(winner.model, {'unet', 'attentionUnet', 'tie'}), 'Modelo vencedor inválido');
    assert(winner.confidence >= 0 && winner.confidence <= 1, 'Confiança fora do intervalo válido');
    
    % Testar análise de diferenças
    differences = controller.analyzeDifferences(unetMetrics, attentionMetrics);
    assert(isstruct(differences), 'Análise de diferenças não é struct');
    assert(isfield(differences, 'absolute'), 'Campo absolute não encontrado');
    assert(isfield(differences, 'relative'), 'Campo relative não encontrado');
    assert(isfield(differences, 'significance'), 'Campo significance não encontrado');
    
    % Testar interpretação de resultados
    interpretation = controller.interpretResults(statisticalAnalysis, winner, differences);
    assert(isstruct(interpretation), 'Interpretação não é struct');
    assert(isfield(interpretation, 'summary'), 'Campo summary não encontrado');
    assert(isfield(interpretation, 'recommendations'), 'Campo recommendations não encontrado');
    assert(isfield(interpretation, 'limitations'), 'Campo limitations não encontrado');
    
    assert(ischar(interpretation.summary) || isstring(interpretation.summary), 'Resumo deve ser texto');
    assert(iscell(interpretation.recommendations), 'Recomendações devem ser cell array');
    
    fprintf('✓ Análise de comparação OK\n');
end

function test_report_generation()
    fprintf('Testando geração de relatórios...\n');
    
    controller = ComparisonController('verbose', false);
    
    % Criar dados de teste para relatório
    comparisonResults = struct();
    comparisonResults.unet = struct('iou', 0.75, 'dice', 0.85, 'accuracy', 0.92);
    comparisonResults.attentionUnet = struct('iou', 0.78, 'dice', 0.87, 'accuracy', 0.94);
    comparisonResults.winner = struct('model', 'attentionUnet', 'confidence', 0.85);
    comparisonResults.statistics = struct('significant', true, 'pValue', 0.03);
    
    % Testar geração de relatório de texto
    textReport = controller.generateTextReport(comparisonResults);
    assert(ischar(textReport) || isstring(textReport), 'Relatório de texto deve ser string');
    assert(contains(textReport, 'U-Net'), 'Relatório deve mencionar U-Net');
    assert(contains(textReport, 'Attention'), 'Relatório deve mencionar Attention U-Net');
    
    % Testar geração de relatório estruturado
    structuredReport = controller.generateStructuredReport(comparisonResults);
    assert(isstruct(structuredReport), 'Relatório estruturado não é struct');
    assert(isfield(structuredReport, 'executive_summary'), 'Campo executive_summary não encontrado');
    assert(isfield(structuredReport, 'detailed_results'), 'Campo detailed_results não encontrado');
    assert(isfield(structuredReport, 'recommendations'), 'Campo recommendations não encontrado');
    assert(isfield(structuredReport, 'appendices'), 'Campo appendices não encontrado');
    
    % Testar salvamento de relatório
    outputDir = 'test_reports';
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    reportFile = controller.saveReport(comparisonResults, outputDir, 'test_comparison');
    assert(~isempty(reportFile), 'Arquivo de relatório não foi criado');
    assert(exist(reportFile, 'file') == 2, 'Arquivo de relatório não existe');
    
    % Testar geração de resumo executivo
    executiveSummary = controller.generateExecutiveSummary(comparisonResults);
    assert(isstruct(executiveSummary), 'Resumo executivo não é struct');
    assert(isfield(executiveSummary, 'conclusion'), 'Campo conclusion não encontrado');
    assert(isfield(executiveSummary, 'key_findings'), 'Campo key_findings não encontrado');
    assert(isfield(executiveSummary, 'next_steps'), 'Campo next_steps não encontrado');
    
    % Limpar arquivos de teste
    if exist(outputDir, 'dir')
        rmdir(outputDir, 's');
    end
    
    fprintf('✓ Geração de relatórios OK\n');
end

function test_workflow_management()
    fprintf('Testando gerenciamento de workflow...\n');
    
    controller = ComparisonController('verbose', false);
    
    % Testar definição de workflow
    workflow = controller.defineWorkflow();
    assert(isstruct(workflow), 'Workflow não é struct');
    assert(isfield(workflow, 'steps'), 'Campo steps não encontrado');
    assert(isfield(workflow, 'dependencies'), 'Campo dependencies não encontrado');
    assert(isfield(workflow, 'estimated_time'), 'Campo estimated_time não encontrado');
    
    assert(iscell(workflow.steps), 'Steps deve ser cell array');
    assert(~isempty(workflow.steps), 'Workflow deve ter pelo menos um passo');
    
    % Testar execução de workflow
    controller.initializeWorkflow();
    
    workflowStatus = controller.getWorkflowStatus();
    assert(isstruct(workflowStatus), 'Status do workflow não é struct');
    assert(isfield(workflowStatus, 'current_step'), 'Campo current_step não encontrado');
    assert(isfield(workflowStatus, 'completed_steps'), 'Campo completed_steps não encontrado');
    assert(isfield(workflowStatus, 'remaining_steps'), 'Campo remaining_steps não encontrado');
    assert(isfield(workflowStatus, 'progress'), 'Campo progress não encontrado');
    
    % Testar avanço de passos
    initialStep = workflowStatus.current_step;
    controller.advanceWorkflowStep();
    
    newStatus = controller.getWorkflowStatus();
    if length(workflow.steps) > 1
        assert(newStatus.current_step ~= initialStep, 'Passo do workflow não avançou');
    end
    
    % Testar pausa e retomada
    controller.pauseWorkflow();
    pausedStatus = controller.getWorkflowStatus();
    assert(isfield(pausedStatus, 'paused'), 'Campo paused não encontrado');
    assert(pausedStatus.paused, 'Workflow deveria estar pausado');
    
    controller.resumeWorkflow();
    resumedStatus = controller.getWorkflowStatus();
    assert(~resumedStatus.paused, 'Workflow deveria estar retomado');
    
    % Testar reset de workflow
    controller.resetWorkflow();
    resetStatus = controller.getWorkflowStatus();
    assert(resetStatus.current_step == 1, 'Workflow não foi resetado corretamente');
    assert(isempty(resetStatus.completed_steps), 'Passos completados não foram limpos');
    
    fprintf('✓ Gerenciamento de workflow OK\n');
end

function test_error_handling()
    fprintf('Testando tratamento de erros...\n');
    
    controller = ComparisonController('verbose', false);
    
    % Testar configuração inválida
    invalidConfig = struct();
    invalidConfig.invalid_field = 'invalid_value';
    
    success = controller.setConfig(invalidConfig);
    assert(~success, 'Configuração inválida foi aceita');
    
    % Testar dados inexistentes
    config = controller.getDefaultConfig();
    config.data.imageDir = '/diretorio/inexistente';
    config.data.maskDir = '/outro/diretorio/inexistente';
    
    controller.setConfig(config);
    
    try
        dataInfo = controller.prepareData();
        % Se chegou aqui, deve ter tratado o erro graciosamente
        assert(isstruct(dataInfo), 'Resultado deve ser struct mesmo com erro');
        assert(isfield(dataInfo, 'error'), 'Campo error deve estar presente');
    catch ME
        % Erro esperado, mas deve ser tratado graciosamente
        assert(contains(ME.message, 'diretório') || contains(ME.message, 'directory'), ...
            'Mensagem de erro deve mencionar diretório');
    end
    
    % Testar recuperação de erro
    errorLog = controller.getErrorLog();
    assert(iscell(errorLog), 'Log de erros deve ser cell array');
    
    % Testar limpeza de erros
    controller.clearErrorLog();
    clearedLog = controller.getErrorLog();
    assert(isempty(clearedLog), 'Log de erros não foi limpo');
    
    % Testar modo de recuperação
    controller.enableRecoveryMode();
    recoveryStatus = controller.getRecoveryStatus();
    assert(isstruct(recoveryStatus), 'Status de recuperação não é struct');
    assert(isfield(recoveryStatus, 'enabled'), 'Campo enabled não encontrado');
    assert(recoveryStatus.enabled, 'Modo de recuperação não foi habilitado');
    
    controller.disableRecoveryMode();
    disabledStatus = controller.getRecoveryStatus();
    assert(~disabledStatus.enabled, 'Modo de recuperação não foi desabilitado');
    
    fprintf('✓ Tratamento de erros OK\n');
end

% Funções auxiliares para testes
function imageDir = createTestImageDir()
    imageDir = 'test_images_temp';
    if ~exist(imageDir, 'dir')
        mkdir(imageDir);
    end
    
    % Criar algumas imagens de teste
    for i = 1:3
        img = uint8(rand(64, 64, 3) * 255);
        imwrite(img, fullfile(imageDir, sprintf('test_%d.png', i)));
    end
end

function maskDir = createTestMaskDir()
    maskDir = 'test_masks_temp';
    if ~exist(maskDir, 'dir')
        mkdir(maskDir);
    end
    
    % Criar algumas máscaras de teste
    for i = 1:3
        mask = uint8((rand(64, 64) > 0.5) * 255);
        imwrite(mask, fullfile(maskDir, sprintf('test_%d.png', i)));
    end
end

function cleanupTestDirs(imageDir, maskDir)
    if exist(imageDir, 'dir')
        rmdir(imageDir, 's');
    end
    if exist(maskDir, 'dir')
        rmdir(maskDir, 's');
    end
end