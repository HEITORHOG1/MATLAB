function test_execution_manager()
    % ========================================================================
    % TESTES UNITÁRIOS - EXECUTION MANAGER
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Testes unitários abrangentes para a classe ExecutionManager
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Parallel Computing
    %   - Performance Monitoring
    % ========================================================================
    
    fprintf('=== INICIANDO TESTES UNITÁRIOS - EXECUTION MANAGER ===\n\n');
    
    % Adicionar caminho para as classes
    addpath(genpath('src'));
    
    % Executar todos os testes
    try
        test_constructor();
        test_resource_monitoring();
        test_progress_tracking();
        test_time_estimation();
        test_parallel_execution();
        test_memory_management();
        test_error_recovery();
        test_performance_profiling();
        
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
    exec1 = ExecutionManager();
    assert(isa(exec1, 'ExecutionManager'), 'Construtor padrão falhou');
    
    % Teste construtor com parâmetros
    exec2 = ExecutionManager('verbose', true, 'enableProfiling', true);
    assert(isa(exec2, 'ExecutionManager'), 'Construtor com parâmetros falhou');
    
    % Teste construtor com configuração personalizada
    config = struct();
    config.maxWorkers = 4;
    config.memoryLimit = 8; % GB
    config.enableGPU = true;
    
    exec3 = ExecutionManager('config', config);
    assert(isa(exec3, 'ExecutionManager'), 'Construtor com configuração falhou');
    
    fprintf('✓ Construtor OK\n');
end

function test_resource_monitoring()
    fprintf('Testando monitoramento de recursos...\n');
    
    exec = ExecutionManager('verbose', false);
    
    % Testar monitoramento de memória
    memInfo = exec.getMemoryInfo();
    assert(isstruct(memInfo), 'Informações de memória não são struct');
    assert(isfield(memInfo, 'available'), 'Campo available não encontrado');
    assert(isfield(memInfo, 'used'), 'Campo used não encontrado');
    assert(isfield(memInfo, 'total'), 'Campo total não encontrado');
    assert(isfield(memInfo, 'percentage'), 'Campo percentage não encontrado');
    
    % Verificar tipos de dados
    assert(isnumeric(memInfo.available), 'available deve ser numérico');
    assert(isnumeric(memInfo.used), 'used deve ser numérico');
    assert(isnumeric(memInfo.total), 'total deve ser numérico');
    assert(isnumeric(memInfo.percentage), 'percentage deve ser numérico');
    
    % Verificar valores lógicos
    assert(memInfo.available >= 0, 'Memória disponível não pode ser negativa');
    assert(memInfo.used >= 0, 'Memória usada não pode ser negativa');
    assert(memInfo.total > 0, 'Memória total deve ser positiva');
    assert(memInfo.percentage >= 0 && memInfo.percentage <= 100, 'Porcentagem inválida');
    
    % Testar monitoramento de CPU
    cpuInfo = exec.getCPUInfo();
    assert(isstruct(cpuInfo), 'Informações de CPU não são struct');
    assert(isfield(cpuInfo, 'usage'), 'Campo usage não encontrado');
    assert(isfield(cpuInfo, 'cores'), 'Campo cores não encontrado');
    assert(isfield(cpuInfo, 'threads'), 'Campo threads não encontrado');
    
    % Testar monitoramento de GPU (se disponível)
    gpuInfo = exec.getGPUInfo();
    assert(isstruct(gpuInfo), 'Informações de GPU não são struct');
    assert(isfield(gpuInfo, 'available'), 'Campo available não encontrado');
    
    if gpuInfo.available
        assert(isfield(gpuInfo, 'memory'), 'Campo memory não encontrado para GPU disponível');
        assert(isfield(gpuInfo, 'utilization'), 'Campo utilization não encontrado para GPU disponível');
        fprintf('  ✓ GPU detectada e monitorada\n');
    else
        fprintf('  ⚠ GPU não disponível (normal em alguns sistemas)\n');
    end
    
    fprintf('✓ Monitoramento de recursos OK\n');
end

function test_progress_tracking()
    fprintf('Testando rastreamento de progresso...\n');
    
    exec = ExecutionManager('verbose', false);
    
    % Iniciar rastreamento de progresso
    taskName = 'test_task';
    totalSteps = 100;
    
    exec.startProgress(taskName, totalSteps);
    
    % Verificar estado inicial
    progress = exec.getProgress(taskName);
    assert(isstruct(progress), 'Progresso não é struct');
    assert(isfield(progress, 'current'), 'Campo current não encontrado');
    assert(isfield(progress, 'total'), 'Campo total não encontrado');
    assert(isfield(progress, 'percentage'), 'Campo percentage não encontrado');
    assert(isfield(progress, 'startTime'), 'Campo startTime não encontrado');
    
    assert(progress.current == 0, 'Progresso inicial deve ser 0');
    assert(progress.total == totalSteps, 'Total incorreto');
    assert(progress.percentage == 0, 'Porcentagem inicial deve ser 0');
    
    % Atualizar progresso
    for i = 1:10:totalSteps
        exec.updateProgress(taskName, i);
        currentProgress = exec.getProgress(taskName);
        assert(currentProgress.current == i, 'Progresso atual incorreto');
        assert(abs(currentProgress.percentage - (i/totalSteps*100)) < 0.1, 'Porcentagem incorreta');
    end
    
    % Finalizar progresso
    exec.finishProgress(taskName);
    finalProgress = exec.getProgress(taskName);
    assert(finalProgress.current == totalSteps, 'Progresso final deve ser 100%');
    assert(finalProgress.percentage == 100, 'Porcentagem final deve ser 100');
    assert(isfield(finalProgress, 'endTime'), 'Campo endTime não encontrado');
    assert(isfield(finalProgress, 'duration'), 'Campo duration não encontrado');
    
    fprintf('✓ Rastreamento de progresso OK\n');
end

function test_time_estimation()
    fprintf('Testando estimativa de tempo...\n');
    
    exec = ExecutionManager('verbose', false);
    
    % Simular tarefa com estimativa de tempo
    taskName = 'estimation_test';
    totalSteps = 50;
    
    exec.startProgress(taskName, totalSteps);
    
    % Simular progresso com pequenos delays
    for i = 1:5:25
        pause(0.01); % Pequeno delay para simular trabalho
        exec.updateProgress(taskName, i);
        
        estimate = exec.getTimeEstimate(taskName);
        assert(isstruct(estimate), 'Estimativa não é struct');
        assert(isfield(estimate, 'remaining'), 'Campo remaining não encontrado');
        assert(isfield(estimate, 'eta'), 'Campo eta não encontrado');
        assert(isfield(estimate, 'speed'), 'Campo speed não encontrado');
        
        if i > 5 % Após alguns passos, deve ter estimativa
            assert(estimate.remaining >= 0, 'Tempo restante não pode ser negativo');
            assert(estimate.speed > 0, 'Velocidade deve ser positiva');
        end
    end
    
    exec.finishProgress(taskName);
    
    % Testar estimativa para múltiplas tarefas
    exec.startProgress('task1', 100);
    exec.startProgress('task2', 200);
    
    exec.updateProgress('task1', 25);
    exec.updateProgress('task2', 50);
    
    estimate1 = exec.getTimeEstimate('task1');
    estimate2 = exec.getTimeEstimate('task2');
    
    assert(~isempty(estimate1), 'Estimativa para task1 vazia');
    assert(~isempty(estimate2), 'Estimativa para task2 vazia');
    
    exec.finishProgress('task1');
    exec.finishProgress('task2');
    
    fprintf('✓ Estimativa de tempo OK\n');
end

function test_parallel_execution()
    fprintf('Testando execução paralela...\n');
    
    exec = ExecutionManager('verbose', false);
    
    % Verificar capacidade de paralelização
    parallelInfo = exec.getParallelInfo();
    assert(isstruct(parallelInfo), 'Informações de paralelização não são struct');
    assert(isfield(parallelInfo, 'available'), 'Campo available não encontrado');
    assert(isfield(parallelInfo, 'workers'), 'Campo workers não encontrado');
    assert(isfield(parallelInfo, 'maxWorkers'), 'Campo maxWorkers não encontrado');
    
    if parallelInfo.available
        fprintf('  ✓ Parallel Computing Toolbox disponível\n');
        fprintf('  ✓ Workers: %d/%d\n', parallelInfo.workers, parallelInfo.maxWorkers);
        
        % Testar execução de tarefa paralela simples
        testData = 1:100;
        
        % Função de teste simples
        testFunc = @(x) x.^2;
        
        % Executar em paralelo
        tic;
        results = exec.executeParallel(testFunc, testData);
        parallelTime = toc;
        
        % Verificar resultados
        assert(length(results) == length(testData), 'Número de resultados incorreto');
        assert(all(results == testData.^2), 'Resultados incorretos');
        
        % Comparar com execução sequencial
        tic;
        sequentialResults = arrayfun(testFunc, testData);
        sequentialTime = toc;
        
        assert(isequal(results, sequentialResults), 'Resultados paralelos diferem dos sequenciais');
        
        fprintf('  ✓ Execução paralela: %.3fs vs sequencial: %.3fs\n', parallelTime, sequentialTime);
        
    else
        fprintf('  ⚠ Parallel Computing Toolbox não disponível\n');
        
        % Testar fallback para execução sequencial
        testData = 1:10;
        testFunc = @(x) x.^2;
        
        results = exec.executeParallel(testFunc, testData);
        assert(length(results) == length(testData), 'Fallback sequencial falhou');
        assert(all(results == testData.^2), 'Resultados do fallback incorretos');
    end
    
    fprintf('✓ Execução paralela OK\n');
end

function test_memory_management()
    fprintf('Testando gerenciamento de memória...\n');
    
    exec = ExecutionManager('verbose', false);
    
    % Testar monitoramento de uso de memória
    initialMem = exec.getMemoryInfo();
    
    % Alocar memória para teste
    testData = rand(1000, 1000); % ~8MB
    
    afterAllocMem = exec.getMemoryInfo();
    assert(afterAllocMem.used >= initialMem.used, 'Uso de memória não aumentou após alocação');
    
    % Testar limpeza de memória
    clear testData;
    exec.cleanupMemory();
    
    afterCleanupMem = exec.getMemoryInfo();
    % Nota: A limpeza pode não ser imediata no MATLAB
    
    % Testar verificação de limite de memória
    memLimit = 1; % 1GB
    exec.setMemoryLimit(memLimit);
    
    isWithinLimit = exec.checkMemoryLimit();
    assert(islogical(isWithinLimit), 'Resultado da verificação deve ser lógico');
    
    % Testar estimativa de memória necessária
    dataSize = [1000, 1000, 3]; % Tamanho dos dados
    estimatedMem = exec.estimateMemoryUsage(dataSize, 'single');
    assert(isnumeric(estimatedMem), 'Estimativa de memória deve ser numérica');
    assert(estimatedMem > 0, 'Estimativa de memória deve ser positiva');
    
    % Verificar se estimativa é razoável (1000*1000*3*4 bytes ≈ 12MB)
    expectedMem = prod(dataSize) * 4 / (1024^2); % MB
    assert(abs(estimatedMem - expectedMem) < expectedMem * 0.1, 'Estimativa de memória muito imprecisa');
    
    fprintf('✓ Gerenciamento de memória OK\n');
end

function test_error_recovery()
    fprintf('Testando recuperação de erros...\n');
    
    exec = ExecutionManager('verbose', false);
    
    % Testar execução com erro
    errorFunc = @(x) error('Erro simulado');
    testData = {1, 2, 3};
    
    % Executar com tratamento de erro
    [results, errors] = exec.executeWithErrorHandling(errorFunc, testData);
    
    assert(iscell(results), 'Resultados devem ser cell array');
    assert(iscell(errors), 'Erros devem ser cell array');
    assert(length(results) == length(testData), 'Número de resultados incorreto');
    assert(length(errors) == length(testData), 'Número de erros incorreto');
    
    % Todos devem ter falhado
    assert(all(cellfun(@isempty, results)), 'Alguns resultados não estão vazios');
    assert(all(~cellfun(@isempty, errors)), 'Alguns erros estão vazios');
    
    % Testar execução mista (algumas falham, outras não)
    mixedFunc = @(x) if x > 2; error('Erro para x > 2'); else; x^2; end;
    
    [mixedResults, mixedErrors] = exec.executeWithErrorHandling(mixedFunc, testData);
    
    % Primeiros dois devem ter sucesso, último deve falhar
    assert(~isempty(mixedResults{1}), 'Primeiro resultado deve existir');
    assert(~isempty(mixedResults{2}), 'Segundo resultado deve existir');
    assert(isempty(mixedResults{3}), 'Terceiro resultado deve estar vazio');
    
    assert(isempty(mixedErrors{1}), 'Primeiro erro deve estar vazio');
    assert(isempty(mixedErrors{2}), 'Segundo erro deve estar vazio');
    assert(~isempty(mixedErrors{3}), 'Terceiro erro deve existir');
    
    % Testar retry automático
    retryCount = 0;
    retryFunc = @(x) (retryCount = retryCount + 1, if retryCount < 3; error('Falha temporária'); else; x * 2; end);
    
    result = exec.executeWithRetry(retryFunc, 5, 'maxRetries', 3);
    assert(~isempty(result), 'Resultado com retry deve existir');
    assert(result == 10, 'Resultado com retry incorreto');
    assert(retryCount == 3, 'Número de tentativas incorreto');
    
    fprintf('✓ Recuperação de erros OK\n');
end

function test_performance_profiling()
    fprintf('Testando profiling de performance...\n');
    
    exec = ExecutionManager('enableProfiling', true, 'verbose', false);
    
    % Iniciar profiling
    exec.startProfiling('test_profile');
    
    % Simular algum trabalho
    testWork = @() sum(rand(1000, 1000));
    result = testWork();
    
    % Parar profiling
    profileData = exec.stopProfiling('test_profile');
    
    assert(isstruct(profileData), 'Dados de profiling não são struct');
    assert(isfield(profileData, 'duration'), 'Campo duration não encontrado');
    assert(isfield(profileData, 'memoryUsed'), 'Campo memoryUsed não encontrado');
    assert(isfield(profileData, 'peakMemory'), 'Campo peakMemory não encontrado');
    
    assert(profileData.duration > 0, 'Duração deve ser positiva');
    assert(isnumeric(profileData.memoryUsed), 'Memória usada deve ser numérica');
    assert(isnumeric(profileData.peakMemory), 'Pico de memória deve ser numérico');
    
    % Testar profiling de função específica
    profiledResult = exec.profileFunction(testWork);
    assert(~isempty(profiledResult), 'Resultado do profiling vazio');
    assert(isfield(profiledResult, 'result'), 'Campo result não encontrado');
    assert(isfield(profiledResult, 'profile'), 'Campo profile não encontrado');
    
    % Testar relatório de performance
    report = exec.generatePerformanceReport();
    assert(isstruct(report), 'Relatório não é struct');
    assert(isfield(report, 'profiles'), 'Campo profiles não encontrado');
    assert(isfield(report, 'summary'), 'Campo summary não encontrado');
    
    % Testar benchmark
    benchmarkFunc = @() sort(rand(10000, 1));
    benchmark = exec.benchmark(benchmarkFunc, 'iterations', 5);
    
    assert(isstruct(benchmark), 'Benchmark não é struct');
    assert(isfield(benchmark, 'meanTime'), 'Campo meanTime não encontrado');
    assert(isfield(benchmark, 'stdTime'), 'Campo stdTime não encontrado');
    assert(isfield(benchmark, 'minTime'), 'Campo minTime não encontrado');
    assert(isfield(benchmark, 'maxTime'), 'Campo maxTime não encontrado');
    
    assert(benchmark.meanTime > 0, 'Tempo médio deve ser positivo');
    assert(benchmark.stdTime >= 0, 'Desvio padrão deve ser não-negativo');
    assert(benchmark.minTime <= benchmark.meanTime, 'Tempo mínimo deve ser <= média');
    assert(benchmark.maxTime >= benchmark.meanTime, 'Tempo máximo deve ser >= média');
    
    fprintf('✓ Profiling de performance OK\n');
end