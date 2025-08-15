%% Test Suite: Sistema de Monitoramento de Otimização
% Este script testa todas as funcionalidades do sistema de monitoramento
% de gradientes e análise de otimização.

function test_optimization_system()
    fprintf('=== TESTE DO SISTEMA DE MONITORAMENTO DE OTIMIZAÇÃO ===\n\n');
    
    % Configurar ambiente de teste
    testDir = 'output/test_optimization';
    if exist(testDir, 'dir')
        rmdir(testDir, 's');
    end
    mkdir(testDir);
    
    % Executar todos os testes
    testResults = struct();
    
    try
        testResults.gradient_monitor = test_gradient_monitor(testDir);
        testResults.optimization_analyzer = test_optimization_analyzer(testDir);
        testResults.training_integration = test_training_integration(testDir);
        testResults.integration_patches = test_integration_patches(testDir);
        
        % Resumo dos testes
        print_test_summary(testResults);
        
    catch ME
        fprintf('ERRO CRÍTICO nos testes: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
    
    fprintf('\n=== TESTES CONCLUÍDOS ===\n');
end

%% Teste do GradientMonitor
function result = test_gradient_monitor(testDir)
    fprintf('1. Testando GradientMonitor...\n');
    result = struct('passed', 0, 'total', 0, 'errors', {});
    
    try
        % Criar rede simulada
        network = create_test_network();
        
        % Teste 1: Criação do monitor
        result.total = result.total + 1;
        try
            monitor = GradientMonitor(network, 'SaveDirectory', fullfile(testDir, 'gradients'));
            result.passed = result.passed + 1;
            fprintf('  ✓ Criação do GradientMonitor\n');
        catch ME
            result.errors{end+1} = sprintf('Criação do monitor: %s', ME.message);
            fprintf('  ✗ Criação do GradientMonitor: %s\n', ME.message);
        end
        
        % Teste 2: Registro de gradientes
        result.total = result.total + 1;
        try
            for epoch = 1:5
                monitor.recordGradients(network, epoch);
            end
            result.passed = result.passed + 1;
            fprintf('  ✓ Registro de gradientes\n');
        catch ME
            result.errors{end+1} = sprintf('Registro de gradientes: %s', ME.message);
            fprintf('  ✗ Registro de gradientes: %s\n', ME.message);
        end
        
        % Teste 3: Detecção de problemas
        result.total = result.total + 1;
        try
            problems = monitor.detectGradientProblems();
            if isstruct(problems) && isfield(problems, 'recommendations')
                result.passed = result.passed + 1;
                fprintf('  ✓ Detecção de problemas\n');
            else
                result.errors{end+1} = 'Detecção de problemas: formato inválido';
                fprintf('  ✗ Detecção de problemas: formato inválido\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Detecção de problemas: %s', ME.message);
            fprintf('  ✗ Detecção de problemas: %s\n', ME.message);
        end
        
        % Teste 4: Geração de gráficos
        result.total = result.total + 1;
        try
            monitor.plotGradientEvolution('SavePlots', true, 'ShowPlots', false);
            result.passed = result.passed + 1;
            fprintf('  ✓ Geração de gráficos\n');
        catch ME
            result.errors{end+1} = sprintf('Geração de gráficos: %s', ME.message);
            fprintf('  ✗ Geração de gráficos: %s\n', ME.message);
        end
        
        % Teste 5: Salvamento de histórico
        result.total = result.total + 1;
        try
            historyFile = fullfile(testDir, 'test_gradient_history.mat');
            monitor.saveGradientHistory(historyFile);
            if exist(historyFile, 'file')
                result.passed = result.passed + 1;
                fprintf('  ✓ Salvamento de histórico\n');
            else
                result.errors{end+1} = 'Salvamento de histórico: arquivo não criado';
                fprintf('  ✗ Salvamento de histórico: arquivo não criado\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Salvamento de histórico: %s', ME.message);
            fprintf('  ✗ Salvamento de histórico: %s\n', ME.message);
        end
        
        % Teste 6: Carregamento de histórico
        result.total = result.total + 1;
        try
            newMonitor = GradientMonitor(network);
            newMonitor.loadGradientHistory(historyFile);
            result.passed = result.passed + 1;
            fprintf('  ✓ Carregamento de histórico\n');
        catch ME
            result.errors{end+1} = sprintf('Carregamento de histórico: %s', ME.message);
            fprintf('  ✗ Carregamento de histórico: %s\n', ME.message);
        end
        
        % Teste 7: Resumo de gradientes
        result.total = result.total + 1;
        try
            summary = monitor.getGradientSummary();
            if isstruct(summary)
                result.passed = result.passed + 1;
                fprintf('  ✓ Resumo de gradientes\n');
            else
                result.errors{end+1} = 'Resumo de gradientes: formato inválido';
                fprintf('  ✗ Resumo de gradientes: formato inválido\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Resumo de gradientes: %s', ME.message);
            fprintf('  ✗ Resumo de gradientes: %s\n', ME.message);
        end
        
    catch ME
        result.errors{end+1} = sprintf('Erro geral no GradientMonitor: %s', ME.message);
        fprintf('  ✗ Erro geral no GradientMonitor: %s\n', ME.message);
    end
    
    fprintf('  GradientMonitor: %d/%d testes passaram\n\n', result.passed, result.total);
end

%% Teste do OptimizationAnalyzer
function result = test_optimization_analyzer(testDir)
    fprintf('2. Testando OptimizationAnalyzer...\n');
    result = struct('passed', 0, 'total', 0, 'errors', {});
    
    try
        % Criar monitor e analyzer
        network = create_test_network();
        monitor = GradientMonitor(network);
        
        % Simular alguns dados de gradiente
        for epoch = 1:10
            monitor.recordGradients(network, epoch);
        end
        
        % Teste 1: Criação do analyzer
        result.total = result.total + 1;
        try
            analyzer = OptimizationAnalyzer(monitor, 'SaveDirectory', fullfile(testDir, 'optimization'));
            result.passed = result.passed + 1;
            fprintf('  ✓ Criação do OptimizationAnalyzer\n');
        catch ME
            result.errors{end+1} = sprintf('Criação do analyzer: %s', ME.message);
            fprintf('  ✗ Criação do OptimizationAnalyzer: %s\n', ME.message);
        end
        
        % Teste 2: Sugestões de otimização
        result.total = result.total + 1;
        try
            config = struct('learning_rate', 0.001, 'batch_size', 32);
            metrics = struct('loss', [1.0, 0.8, 0.6, 0.5, 0.4]);
            suggestions = analyzer.suggestOptimizations('CurrentConfig', config, 'TrainingMetrics', metrics);
            
            if isstruct(suggestions) && isfield(suggestions, 'learning_rate')
                result.passed = result.passed + 1;
                fprintf('  ✓ Sugestões de otimização\n');
            else
                result.errors{end+1} = 'Sugestões de otimização: formato inválido';
                fprintf('  ✗ Sugestões de otimização: formato inválido\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Sugestões de otimização: %s', ME.message);
            fprintf('  ✗ Sugestões de otimização: %s\n', ME.message);
        end
        
        % Teste 3: Alertas em tempo real
        result.total = result.total + 1;
        try
            testMetrics = struct('loss', 0.5, 'accuracy', 0.8);
            alerts = analyzer.checkRealTimeAlerts(5, testMetrics);
            
            if isstruct(alerts) && isfield(alerts, 'critical')
                result.passed = result.passed + 1;
                fprintf('  ✓ Alertas em tempo real\n');
            else
                result.errors{end+1} = 'Alertas em tempo real: formato inválido';
                fprintf('  ✗ Alertas em tempo real: formato inválido\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Alertas em tempo real: %s', ME.message);
            fprintf('  ✗ Alertas em tempo real: %s\n', ME.message);
        end
        
        % Teste 4: Relatório de otimização
        result.total = result.total + 1;
        try
            report = analyzer.generateOptimizationReport('SaveReport', true);
            
            if isstruct(report) && isfield(report, 'summary')
                result.passed = result.passed + 1;
                fprintf('  ✓ Relatório de otimização\n');
            else
                result.errors{end+1} = 'Relatório de otimização: formato inválido';
                fprintf('  ✗ Relatório de otimização: formato inválido\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Relatório de otimização: %s', ME.message);
            fprintf('  ✗ Relatório de otimização: %s\n', ME.message);
        end
        
        % Teste 5: Análise de convergência
        result.total = result.total + 1;
        try
            trainingMetrics = struct('loss', [1.0, 0.8, 0.6, 0.5, 0.4, 0.35, 0.32, 0.30]);
            convergence = analyzer.analyzeConvergence(trainingMetrics);
            
            if isstruct(convergence) && isfield(convergence, 'is_converging')
                result.passed = result.passed + 1;
                fprintf('  ✓ Análise de convergência\n');
            else
                result.errors{end+1} = 'Análise de convergência: formato inválido';
                fprintf('  ✗ Análise de convergência: formato inválido\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Análise de convergência: %s', ME.message);
            fprintf('  ✗ Análise de convergência: %s\n', ME.message);
        end
        
        % Teste 6: Sugestões de hiperparâmetros
        result.total = result.total + 1;
        try
            config = struct('learning_rate', 0.001, 'batch_size', 32);
            perfMetrics = struct('validation_loss', [0.9, 0.7, 0.6], 'training_loss', [0.8, 0.5, 0.3]);
            hyperparams = analyzer.suggestHyperparameters(config, perfMetrics);
            
            if isstruct(hyperparams)
                result.passed = result.passed + 1;
                fprintf('  ✓ Sugestões de hiperparâmetros\n');
            else
                result.errors{end+1} = 'Sugestões de hiperparâmetros: formato inválido';
                fprintf('  ✗ Sugestões de hiperparâmetros: formato inválido\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Sugestões de hiperparâmetros: %s', ME.message);
            fprintf('  ✗ Sugestões de hiperparâmetros: %s\n', ME.message);
        end
        
    catch ME
        result.errors{end+1} = sprintf('Erro geral no OptimizationAnalyzer: %s', ME.message);
        fprintf('  ✗ Erro geral no OptimizationAnalyzer: %s\n', ME.message);
    end
    
    fprintf('  OptimizationAnalyzer: %d/%d testes passaram\n\n', result.passed, result.total);
end

%% Teste do TrainingIntegration
function result = test_training_integration(testDir)
    fprintf('3. Testando TrainingIntegration...\n');
    result = struct('passed', 0, 'total', 0, 'errors', {});
    
    try
        % Teste 1: Criação da integração
        result.total = result.total + 1;
        try
            integration = TrainingIntegration('SaveDirectory', fullfile(testDir, 'integration'));
            result.passed = result.passed + 1;
            fprintf('  ✓ Criação da TrainingIntegration\n');
        catch ME
            result.errors{end+1} = sprintf('Criação da integração: %s', ME.message);
            fprintf('  ✗ Criação da TrainingIntegration: %s\n', ME.message);
        end
        
        % Teste 2: Setup do monitoramento
        result.total = result.total + 1;
        try
            network = create_test_network();
            config = struct('learning_rate', 0.001, 'batch_size', 32, 'optimizer', 'adam');
            integration.setupMonitoring(network, config);
            result.passed = result.passed + 1;
            fprintf('  ✓ Setup do monitoramento\n');
        catch ME
            result.errors{end+1} = sprintf('Setup do monitoramento: %s', ME.message);
            fprintf('  ✗ Setup do monitoramento: %s\n', ME.message);
        end
        
        % Teste 3: Registro de épocas
        result.total = result.total + 1;
        try
            for epoch = 1:5
                metrics = struct('loss', 1.0 * exp(-epoch/10), 'accuracy', 0.5 + 0.4 * (1 - exp(-epoch/5)));
                integration.recordEpoch(network, epoch, metrics);
            end
            result.passed = result.passed + 1;
            fprintf('  ✓ Registro de épocas\n');
        catch ME
            result.errors{end+1} = sprintf('Registro de épocas: %s', ME.message);
            fprintf('  ✗ Registro de épocas: %s\n', ME.message);
        end
        
        % Teste 4: Obtenção de sugestões
        result.total = result.total + 1;
        try
            suggestions = integration.getSuggestions();
            if isstruct(suggestions)
                result.passed = result.passed + 1;
                fprintf('  ✓ Obtenção de sugestões\n');
            else
                result.errors{end+1} = 'Obtenção de sugestões: formato inválido';
                fprintf('  ✗ Obtenção de sugestões: formato inválido\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Obtenção de sugestões: %s', ME.message);
            fprintf('  ✗ Obtenção de sugestões: %s\n', ME.message);
        end
        
        % Teste 5: Geração de relatório
        result.total = result.total + 1;
        try
            report = integration.generateReport();
            if isstruct(report)
                result.passed = result.passed + 1;
                fprintf('  ✓ Geração de relatório\n');
            else
                result.errors{end+1} = 'Geração de relatório: formato inválido';
                fprintf('  ✗ Geração de relatório: formato inválido\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Geração de relatório: %s', ME.message);
            fprintf('  ✗ Geração de relatório: %s\n', ME.message);
        end
        
        % Teste 6: Gráficos de progresso
        result.total = result.total + 1;
        try
            integration.plotTrainingProgress('SavePlots', true, 'ShowPlots', false);
            result.passed = result.passed + 1;
            fprintf('  ✓ Gráficos de progresso\n');
        catch ME
            result.errors{end+1} = sprintf('Gráficos de progresso: %s', ME.message);
            fprintf('  ✗ Gráficos de progresso: %s\n', ME.message);
        end
        
        % Teste 7: Salvamento de progresso
        result.total = result.total + 1;
        try
            progressFile = fullfile(testDir, 'test_progress.mat');
            integration.saveProgress(progressFile);
            if exist(progressFile, 'file')
                result.passed = result.passed + 1;
                fprintf('  ✓ Salvamento de progresso\n');
            else
                result.errors{end+1} = 'Salvamento de progresso: arquivo não criado';
                fprintf('  ✗ Salvamento de progresso: arquivo não criado\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Salvamento de progresso: %s', ME.message);
            fprintf('  ✗ Salvamento de progresso: %s\n', ME.message);
        end
        
        % Teste 8: Carregamento de progresso
        result.total = result.total + 1;
        try
            newIntegration = TrainingIntegration();
            newIntegration.loadProgress(progressFile);
            result.passed = result.passed + 1;
            fprintf('  ✓ Carregamento de progresso\n');
        catch ME
            result.errors{end+1} = sprintf('Carregamento de progresso: %s', ME.message);
            fprintf('  ✗ Carregamento de progresso: %s\n', ME.message);
        end
        
        % Teste 9: Resumo de treinamento
        result.total = result.total + 1;
        try
            summary = integration.getTrainingSummary();
            if isstruct(summary)
                result.passed = result.passed + 1;
                fprintf('  ✓ Resumo de treinamento\n');
            else
                result.errors{end+1} = 'Resumo de treinamento: formato inválido';
                fprintf('  ✗ Resumo de treinamento: formato inválido\n');
            end
        catch ME
            result.errors{end+1} = sprintf('Resumo de treinamento: %s', ME.message);
            fprintf('  ✗ Resumo de treinamento: %s\n', ME.message);
        end
        
    catch ME
        result.errors{end+1} = sprintf('Erro geral na TrainingIntegration: %s', ME.message);
        fprintf('  ✗ Erro geral na TrainingIntegration: %s\n', ME.message);
    end
    
    fprintf('  TrainingIntegration: %d/%d testes passaram\n\n', result.passed, result.total);
end

%% Teste dos patches de integração
function result = test_integration_patches(testDir)
    fprintf('4. Testando patches de integração...\n');
    result = struct('passed', 0, 'total', 0, 'errors', {});
    
    try
        % Teste 1: Verificar se arquivo de patches existe
        result.total = result.total + 1;
        patchFile = 'src/optimization/integration_patches.m';
        if exist(patchFile, 'file')
            result.passed = result.passed + 1;
            fprintf('  ✓ Arquivo de patches existe\n');
        else
            result.errors{end+1} = 'Arquivo de patches não encontrado';
            fprintf('  ✗ Arquivo de patches não encontrado\n');
        end
        
        % Teste 2: Executar função de patches (sem aplicar)
        result.total = result.total + 1;
        try
            % Definir variável para evitar execução automática
            caller_function = true;
            run(patchFile);
            result.passed = result.passed + 1;
            fprintf('  ✓ Execução de patches\n');
        catch ME
            result.errors{end+1} = sprintf('Execução de patches: %s', ME.message);
            fprintf('  ✗ Execução de patches: %s\n', ME.message);
        end
        
        % Teste 3: Verificar estrutura de arquivos
        result.total = result.total + 1;
        requiredFiles = {
            'src/optimization/GradientMonitor.m',
            'src/optimization/OptimizationAnalyzer.m',
            'src/optimization/TrainingIntegration.m',
            'src/optimization/demo_optimization_monitoring.m'
        };
        
        allExist = true;
        for i = 1:length(requiredFiles)
            if ~exist(requiredFiles{i}, 'file')
                allExist = false;
                break;
            end
        end
        
        if allExist
            result.passed = result.passed + 1;
            fprintf('  ✓ Estrutura de arquivos\n');
        else
            result.errors{end+1} = 'Arquivos necessários não encontrados';
            fprintf('  ✗ Estrutura de arquivos: arquivos faltando\n');
        end
        
    catch ME
        result.errors{end+1} = sprintf('Erro geral nos patches: %s', ME.message);
        fprintf('  ✗ Erro geral nos patches: %s\n', ME.message);
    end
    
    fprintf('  Patches de integração: %d/%d testes passaram\n\n', result.passed, result.total);
end

%% Função auxiliar para criar rede de teste
function network = create_test_network()
    % Criar uma rede simulada para testes
    network = struct();
    network.type = 'test_network';
    network.layers = {'input', 'conv1', 'relu1', 'conv2', 'relu2', 'output'};
    network.parameters = rand(100, 1); % Parâmetros simulados
end

%% Função para imprimir resumo dos testes
function print_test_summary(testResults)
    fprintf('\n=== RESUMO DOS TESTES ===\n');
    
    totalPassed = 0;
    totalTests = 0;
    
    components = fieldnames(testResults);
    for i = 1:length(components)
        component = components{i};
        result = testResults.(component);
        
        fprintf('%s: %d/%d testes passaram', component, result.passed, result.total);
        if result.passed == result.total
            fprintf(' ✓\n');
        else
            fprintf(' ✗\n');
            if ~isempty(result.errors)
                fprintf('  Erros:\n');
                for j = 1:length(result.errors)
                    fprintf('    - %s\n', result.errors{j});
                end
            end
        end
        
        totalPassed = totalPassed + result.passed;
        totalTests = totalTests + result.total;
    end
    
    fprintf('\nTOTAL: %d/%d testes passaram (%.1f%%)\n', ...
        totalPassed, totalTests, (totalPassed/totalTests)*100);
    
    if totalPassed == totalTests
        fprintf('🎉 TODOS OS TESTES PASSARAM! Sistema pronto para uso.\n');
    else
        fprintf('⚠️  Alguns testes falharam. Verifique os erros acima.\n');
    end
end

%% Executar testes se chamado diretamente
if ~exist('caller_function', 'var')
    test_optimization_system();
end