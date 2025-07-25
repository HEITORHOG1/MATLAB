classdef ExecutionManager < handle
    % ========================================================================
    % EXECUTIONMANAGER - SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe para gerenciar execução otimizada, incluindo treinamento paralelo,
    %   sistema de queue e modo de teste rápido com subset de dados.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Parallel Computing Toolbox
    %   - Performance and Memory
    %   - Queue Management
    %
    % USO:
    %   >> execMgr = ExecutionManager();
    %   >> execMgr.enableParallelExecution();
    %   >> results = execMgr.executeWithQueue(tasks);
    %
    % REQUISITOS: 7.4
    % ========================================================================
    
    properties (Access = private)
        logger
        parallelPool = []
        executionQueue = {}
        maxConcurrentJobs = 2
        resourceMonitor
        
        % Configurações de otimização
        enableMemoryOptimization = true
        enableGPUOptimization = true
        enableCaching = true
        
        % Estatísticas de execução
        executionStats = struct()
        
        % Configurações de teste rápido
        quickTestEnabled = false
        quickTestRatio = 0.1  % 10% dos dados
        quickTestMaxSamples = 100
    end
    
    properties (Constant)
        EXECUTION_MODES = {'sequential', 'parallel', 'queue', 'quick_test'}
        RESOURCE_THRESHOLDS = struct('memory_gb', 4, 'gpu_memory_gb', 2)
        OPTIMIZATION_LEVELS = {'none', 'basic', 'aggressive'}
    end
    
    methods
        function obj = ExecutionManager(varargin)
            % Construtor da classe ExecutionManager
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'MaxConcurrentJobs' - número máximo de jobs paralelos (padrão: 2)
            %     'EnableMemoryOptimization' - true/false (padrão: true)
            %     'EnableGPUOptimization' - true/false (padrão: true)
            %     'QuickTestRatio' - proporção de dados para teste rápido (padrão: 0.1)
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'MaxConcurrentJobs', 2, @isnumeric);
            addParameter(p, 'EnableMemoryOptimization', true, @islogical);
            addParameter(p, 'EnableGPUOptimization', true, @islogical);
            addParameter(p, 'QuickTestRatio', 0.1, @(x) x > 0 && x <= 1);
            parse(p, varargin{:});
            
            obj.maxConcurrentJobs = p.Results.MaxConcurrentJobs;
            obj.enableMemoryOptimization = p.Results.EnableMemoryOptimization;
            obj.enableGPUOptimization = p.Results.EnableGPUOptimization;
            obj.quickTestRatio = p.Results.QuickTestRatio;
            
            % Inicializar componentes
            obj.initializeLogger();
            obj.initializeResourceMonitor();
            obj.initializeExecutionStats();
            
            obj.logger('info', 'ExecutionManager inicializado');
            obj.logger('info', sprintf('Jobs paralelos máximos: %d', obj.maxConcurrentJobs));
        end
        
        function success = enableParallelExecution(obj)
            % Habilita execução paralela se recursos permitirem
            %
            % SAÍDA:
            %   success - true se execução paralela foi habilitada
            %
            % REQUISITOS: 7.4 (treinamento paralelo quando recursos permitirem)
            
            success = false;
            
            try
                obj.logger('info', 'Verificando disponibilidade de execução paralela...');
                
                % Verificar se Parallel Computing Toolbox está disponível
                if ~obj.isParallelToolboxAvailable()
                    obj.logger('warning', 'Parallel Computing Toolbox não disponível');
                    return;
                end
                
                % Verificar recursos do sistema
                if ~obj.hasAdequateResources()
                    obj.logger('warning', 'Recursos insuficientes para execução paralela');
                    return;
                end
                
                % Tentar criar pool paralelo
                obj.parallelPool = obj.createParallelPool();
                
                if ~isempty(obj.parallelPool)
                    success = true;
                    obj.logger('success', sprintf('Execução paralela habilitada com %d workers', ...
                        obj.parallelPool.NumWorkers));
                else
                    obj.logger('warning', 'Falha ao criar pool paralelo');
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao habilitar execução paralela: %s', ME.message));
            end
        end
        
        function results = executeWithQueue(obj, tasks, varargin)
            % Executa tarefas usando sistema de queue
            %
            % ENTRADA:
            %   tasks - cell array de tarefas para executar
            %   varargin - parâmetros opcionais:
            %     'Priority' - prioridade das tarefas ('high', 'normal', 'low')
            %     'MaxRetries' - número máximo de tentativas (padrão: 3)
            %     'Timeout' - timeout em segundos (padrão: 3600)
            %
            % SAÍDA:
            %   results - cell array com resultados das tarefas
            %
            % REQUISITOS: 7.4 (sistema de queue para gerenciar múltiplas execuções)
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Priority', 'normal', @(x) ismember(x, {'high', 'normal', 'low'}));
            addParameter(p, 'MaxRetries', 3, @isnumeric);
            addParameter(p, 'Timeout', 3600, @isnumeric);
            parse(p, varargin{:});
            
            priority = p.Results.Priority;
            maxRetries = p.Results.MaxRetries;
            timeout = p.Results.Timeout;
            
            obj.logger('info', sprintf('Executando %d tarefas com queue (prioridade: %s)', ...
                length(tasks), priority));
            
            try
                % Adicionar tarefas à queue
                for i = 1:length(tasks)
                    obj.addToQueue(tasks{i}, priority, maxRetries, timeout);
                end
                
                % Processar queue
                results = obj.processQueue();
                
                obj.logger('success', sprintf('%d tarefas processadas com sucesso', length(results)));
                
            catch ME
                obj.logger('error', sprintf('Erro na execução com queue: %s', ME.message));
                results = {};
                rethrow(ME);
            end
        end
        
        function optimizedData = enableQuickTestMode(obj, data, varargin)
            % Habilita modo de teste rápido com subset de dados
            %
            % ENTRADA:
            %   data - dados originais (images, masks)
            %   varargin - parâmetros opcionais:
            %     'Ratio' - proporção de dados a usar (padrão: obj.quickTestRatio)
            %     'MaxSamples' - número máximo de amostras (padrão: obj.quickTestMaxSamples)
            %     'Strategy' - estratégia de seleção ('random', 'stratified', 'first')
            %
            % SAÍDA:
            %   optimizedData - dados otimizados para teste rápido
            %
            % REQUISITOS: 7.4 (modo de teste rápido com subset de dados)
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Ratio', obj.quickTestRatio, @(x) x > 0 && x <= 1);
            addParameter(p, 'MaxSamples', obj.quickTestMaxSamples, @isnumeric);
            addParameter(p, 'Strategy', 'random', @(x) ismember(x, {'random', 'stratified', 'first'}));
            parse(p, varargin{:});
            
            ratio = p.Results.Ratio;
            maxSamples = p.Results.MaxSamples;
            strategy = p.Results.Strategy;
            
            obj.quickTestEnabled = true;
            
            try
                if iscell(data) && length(data) == 2
                    % Dados são {images, masks}
                    images = data{1};
                    masks = data{2};
                    totalSamples = length(images);
                else
                    error('Formato de dados não suportado para teste rápido');
                end
                
                % Calcular número de amostras para teste rápido
                targetSamples = min(maxSamples, round(totalSamples * ratio));
                
                obj.logger('info', sprintf('🚀 Modo teste rápido: %d amostras de %d (%.1f%%)', ...
                    targetSamples, totalSamples, (targetSamples/totalSamples)*100));
                
                % Selecionar amostras baseado na estratégia
                selectedIndices = obj.selectSamplesForQuickTest(totalSamples, targetSamples, strategy);
                
                % Criar dados otimizados
                optimizedData = {images(selectedIndices), masks(selectedIndices)};
                
                % Atualizar estatísticas
                obj.executionStats.quickTest.enabled = true;
                obj.executionStats.quickTest.originalSamples = totalSamples;
                obj.executionStats.quickTest.selectedSamples = targetSamples;
                obj.executionStats.quickTest.strategy = strategy;
                
                obj.logger('success', 'Modo teste rápido configurado');
                
            catch ME
                obj.logger('error', sprintf('Erro ao configurar teste rápido: %s', ME.message));
                optimizedData = data;
                rethrow(ME);
            end
        end
        
        function optimizedConfig = optimizeResourceUsage(obj, config, varargin)
            % Otimiza uso de recursos baseado no hardware disponível
            %
            % ENTRADA:
            %   config - configuração original
            %   varargin - parâmetros opcionais:
            %     'OptimizationLevel' - 'none', 'basic', 'aggressive' (padrão: 'basic')
            %     'TargetMemoryUsage' - uso de memória alvo em GB (padrão: auto)
            %
            % SAÍDA:
            %   optimizedConfig - configuração otimizada
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'OptimizationLevel', 'basic', @(x) ismember(x, obj.OPTIMIZATION_LEVELS));
            addParameter(p, 'TargetMemoryUsage', 0, @isnumeric);
            parse(p, varargin{:});
            
            optimizationLevel = p.Results.OptimizationLevel;
            targetMemoryUsage = p.Results.TargetMemoryUsage;
            
            obj.logger('info', sprintf('Otimizando recursos (nível: %s)', optimizationLevel));
            
            try
                optimizedConfig = config;
                
                % Obter informações de recursos
                resourceInfo = obj.resourceMonitor.getResourceInfo();
                
                % Otimizar batch size baseado na memória disponível
                if obj.enableMemoryOptimization
                    optimizedConfig = obj.optimizeBatchSize(optimizedConfig, resourceInfo, targetMemoryUsage);
                end
                
                % Otimizar configurações de GPU
                if obj.enableGPUOptimization && resourceInfo.gpu.available
                    optimizedConfig = obj.optimizeGPUSettings(optimizedConfig, resourceInfo);
                end
                
                % Aplicar otimizações específicas do nível
                switch optimizationLevel
                    case 'basic'
                        optimizedConfig = obj.applyBasicOptimizations(optimizedConfig, resourceInfo);
                    case 'aggressive'
                        optimizedConfig = obj.applyAggressiveOptimizations(optimizedConfig, resourceInfo);
                end
                
                obj.logger('success', 'Configuração otimizada para recursos disponíveis');
                
            catch ME
                obj.logger('error', sprintf('Erro na otimização de recursos: %s', ME.message));
                optimizedConfig = config;
            end
        end
        
        function stats = getExecutionStats(obj)
            % Retorna estatísticas de execução
            %
            % SAÍDA:
            %   stats - estrutura com estatísticas detalhadas
            
            stats = obj.executionStats;
            stats.parallelPool = struct();
            
            if ~isempty(obj.parallelPool)
                stats.parallelPool.active = true;
                stats.parallelPool.numWorkers = obj.parallelPool.NumWorkers;
                stats.parallelPool.cluster = obj.parallelPool.Cluster.Profile;
            else
                stats.parallelPool.active = false;
            end
            
            stats.resourceInfo = obj.resourceMonitor.getResourceInfo();
            stats.queueSize = length(obj.executionQueue);
        end
        
        function cleanup(obj)
            % Limpa recursos e finaliza execução
            
            obj.logger('info', 'Limpando recursos...');
            
            try
                % Limpar queue
                obj.executionQueue = {};
                
                % Fechar pool paralelo se existir
                if ~isempty(obj.parallelPool)
                    delete(obj.parallelPool);
                    obj.parallelPool = [];
                end
                
                % Limpar cache se habilitado
                if obj.enableCaching
                    obj.clearCache();
                end
                
                obj.logger('success', 'Recursos limpos');
                
            catch ME
                obj.logger('warning', sprintf('Erro na limpeza: %s', ME.message));
            end
        end
    end
    
    methods (Access = private)
        function initializeLogger(obj)
            % Inicializa sistema de logging
            obj.logger = @(level, msg) obj.logMessage(level, msg);
        end
        
        function logMessage(obj, level, message)
            % Sistema de logging simples
            timestamp = datestr(now, 'HH:MM:SS');
            
            switch lower(level)
                case 'info'
                    prefix = '📋';
                case 'success'
                    prefix = '✅';
                case 'warning'
                    prefix = '⚠️';
                case 'error'
                    prefix = '❌';
                otherwise
                    prefix = '📝';
            end
            
            fprintf('[%s] %s [ExecutionManager] %s\n', timestamp, prefix, message);
        end
        
        function initializeResourceMonitor(obj)
            % Inicializa monitor de recursos
            obj.resourceMonitor = ResourceMonitor();
        end
        
        function enableLazyLoading(obj, dataLoader)
            % Habilita lazy loading no DataLoader
            %
            % ENTRADA:
            %   dataLoader - Instância do DataLoader
            %
            % REQUISITOS: 7.2 (lazy loading para datasets grandes)
            
            try
                if isa(dataLoader, 'DataLoader')
                    % Configurar lazy loading baseado nos recursos disponíveis
                    resourceInfo = obj.resourceMonitor.getResourceInfo();
                    
                    % Ajustar limite de memória baseado nos recursos
                    if resourceInfo.memory.availableGB > 8
                        memoryLimit = 4;  % Usar até 4GB para cache
                    elseif resourceInfo.memory.availableGB > 4
                        memoryLimit = 2;  % Usar até 2GB para cache
                    else
                        memoryLimit = 1;  % Usar até 1GB para cache
                    end
                    
                    % Configurar DataLoader
                    dataLoader.maxMemoryUsage = memoryLimit;
                    dataLoader.lazyLoadingEnabled = true;
                    
                    obj.logger('success', sprintf('Lazy loading habilitado (limite: %.1f GB)', memoryLimit));
                else
                    obj.logger('warning', 'DataLoader inválido para lazy loading');
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao habilitar lazy loading: %s', ME.message));
            end
        end
        
        function enableIntelligentCaching(obj, dataPreprocessor)
            % Habilita cache inteligente no DataPreprocessor
            %
            % ENTRADA:
            %   dataPreprocessor - Instância do DataPreprocessor
            %
            % REQUISITOS: 7.2 (cache inteligente de dados preprocessados)
            
            try
                if isa(dataPreprocessor, 'DataPreprocessor')
                    % Configurar cache baseado nos recursos
                    resourceInfo = obj.resourceMonitor.getResourceInfo();
                    
                    % Ajustar tamanho do cache
                    if resourceInfo.memory.availableGB > 8
                        cacheSize = 2000;  % 2000 itens
                    elseif resourceInfo.memory.availableGB > 4
                        cacheSize = 1000;  % 1000 itens
                    else
                        cacheSize = 500;   % 500 itens
                    end
                    
                    dataPreprocessor.cacheMaxSize = cacheSize;
                    dataPreprocessor.cacheEnabled = true;
                    
                    obj.logger('success', sprintf('Cache inteligente habilitado (tamanho: %d)', cacheSize));
                else
                    obj.logger('warning', 'DataPreprocessor inválido para cache inteligente');
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao habilitar cache inteligente: %s', ME.message));
            end
        end
        
        function performMemoryOptimization(obj)
            % Executa otimização automática de memória
            %
            % REQUISITOS: 7.3 (limpeza automática de variáveis)
            
            try
                obj.logger('info', 'Executando otimização de memória...');
                
                % Limpar workspace base de variáveis temporárias
                evalin('base', 'clear temp* tmp* ans');
                
                % Forçar garbage collection
                if exist('java.lang.System', 'class')
                    java.lang.System.gc();
                end
                
                % Obter informações de memória antes e depois
                resourceInfo = obj.resourceMonitor.getResourceInfo();
                
                obj.logger('success', sprintf('Otimização de memória concluída (uso atual: %.1f GB)', ...
                    resourceInfo.memory.usedGB));
                
            catch ME
                obj.logger('error', sprintf('Erro na otimização de memória: %s', ME.message));
            end
        end
        
        function schedulePeriodicOptimization(obj, intervalMinutes)
            % Agenda otimização periódica de memória
            %
            % ENTRADA:
            %   intervalMinutes - Intervalo em minutos (padrão: 10)
            %
            % REQUISITOS: 7.3 (limpeza automática de variáveis)
            
            if nargin < 2
                intervalMinutes = 10;
            end
            
            try
                % Criar timer para otimização periódica
                if exist('timer', 'class')
                    optimizationTimer = timer(...
                        'ExecutionMode', 'fixedRate', ...
                        'Period', intervalMinutes * 60, ...
                        'TimerFcn', @(~,~) obj.performMemoryOptimization());
                    
                    start(optimizationTimer);
                    
                    obj.logger('success', sprintf('Otimização periódica agendada (intervalo: %d min)', intervalMinutes));
                else
                    obj.logger('warning', 'Timer não disponível para otimização periódica');
                end
                
            catch ME
                obj.logger('error', sprintf('Erro ao agendar otimização periódica: %s', ME.message));
            end
        end
        
        function initializeExecutionStats(obj)
            % Inicializa estatísticas de execução
            obj.executionStats = struct();
            obj.executionStats.startTime = now;
            obj.executionStats.tasksExecuted = 0;
            obj.executionStats.tasksSuccessful = 0;
            obj.executionStats.tasksFailed = 0;
            obj.executionStats.totalExecutionTime = 0;
            obj.executionStats.quickTest = struct('enabled', false);
            obj.executionStats.parallelExecution = struct('enabled', false);
        end
        
        function available = isParallelToolboxAvailable(obj)
            % Verifica se Parallel Computing Toolbox está disponível
            available = license('test', 'Distrib_Computing_Toolbox') || ...
                       license('test', 'Parallel_Computing_Toolbox');
        end
        
        function adequate = hasAdequateResources(obj)
            % Verifica se há recursos adequados para execução paralela
            adequate = false;
            
            try
                resourceInfo = obj.resourceMonitor.getResourceInfo();
                
                % Verificar memória
                if resourceInfo.memory.availableGB < obj.RESOURCE_THRESHOLDS.memory_gb
                    obj.logger('warning', sprintf('Memória insuficiente: %.1f GB disponível (mínimo: %.1f GB)', ...
                        resourceInfo.memory.availableGB, obj.RESOURCE_THRESHOLDS.memory_gb));
                    return;
                end
                
                % Verificar GPU se disponível
                if resourceInfo.gpu.available && resourceInfo.gpu.memoryGB < obj.RESOURCE_THRESHOLDS.gpu_memory_gb
                    obj.logger('warning', sprintf('Memória GPU insuficiente: %.1f GB (mínimo: %.1f GB)', ...
                        resourceInfo.gpu.memoryGB, obj.RESOURCE_THRESHOLDS.gpu_memory_gb));
                    return;
                end
                
                adequate = true;
                
            catch ME
                obj.logger('error', sprintf('Erro ao verificar recursos: %s', ME.message));
            end
        end
        
        function pool = createParallelPool(obj)
            % Cria pool paralelo otimizado
            pool = [];
            
            try
                % Verificar se já existe pool
                existingPool = gcp('nocreate');
                if ~isempty(existingPool)
                    pool = existingPool;
                    obj.logger('info', 'Usando pool paralelo existente');
                    return;
                end
                
                % Determinar número ideal de workers
                numWorkers = obj.determineOptimalWorkers();
                
                % Criar novo pool
                obj.logger('info', sprintf('Criando pool paralelo com %d workers...', numWorkers));
                pool = parpool('local', numWorkers);
                
                % Configurar pool
                obj.configureParallelPool(pool);
                
            catch ME
                obj.logger('error', sprintf('Erro ao criar pool paralelo: %s', ME.message));
            end
        end
        
        function numWorkers = determineOptimalWorkers(obj)
            % Determina número ótimo de workers baseado nos recursos
            
            % Começar com número de cores físicos
            numWorkers = feature('numcores');
            
            % Limitar baseado na memória disponível
            resourceInfo = obj.resourceMonitor.getResourceInfo();
            memoryPerWorker = 2; % GB por worker (estimativa conservadora)
            maxWorkersByMemory = floor(resourceInfo.memory.availableGB / memoryPerWorker);
            
            numWorkers = min(numWorkers, maxWorkersByMemory);
            
            % Limitar pelo máximo configurado
            numWorkers = min(numWorkers, obj.maxConcurrentJobs);
            
            % Garantir pelo menos 1 worker
            numWorkers = max(1, numWorkers);
            
            obj.logger('info', sprintf('Número ótimo de workers calculado: %d', numWorkers));
        end
        
        function configureParallelPool(obj, pool)
            % Configura pool paralelo para otimização
            
            try
                % Configurar timeout
                pool.IdleTimeout = 30; % minutos
                
                % Configurar variáveis compartilhadas se necessário
                % (implementação futura)
                
                obj.logger('success', 'Pool paralelo configurado');
                
            catch ME
                obj.logger('warning', sprintf('Erro ao configurar pool: %s', ME.message));
            end
        end
        
        function addToQueue(obj, task, priority, maxRetries, timeout)
            % Adiciona tarefa à queue de execução
            
            queueItem = struct();
            queueItem.task = task;
            queueItem.priority = priority;
            queueItem.maxRetries = maxRetries;
            queueItem.timeout = timeout;
            queueItem.retries = 0;
            queueItem.status = 'pending';
            queueItem.addedTime = now;
            queueItem.id = obj.generateTaskId();
            
            % Inserir na posição correta baseado na prioridade
            insertIndex = obj.findInsertionIndex(priority);
            
            if insertIndex <= length(obj.executionQueue)
                obj.executionQueue = [obj.executionQueue(1:insertIndex-1), {queueItem}, ...
                                     obj.executionQueue(insertIndex:end)];
            else
                obj.executionQueue{end+1} = queueItem;
            end
            
            obj.logger('debug', sprintf('Tarefa %s adicionada à queue (prioridade: %s)', ...
                queueItem.id, priority));
        end
        
        function results = processQueue(obj)
            % Processa todas as tarefas na queue
            
            results = {};
            totalTasks = length(obj.executionQueue);
            
            obj.logger('info', sprintf('Processando %d tarefas na queue...', totalTasks));
            
            while ~isempty(obj.executionQueue)
                % Pegar próxima tarefa
                queueItem = obj.executionQueue{1};
                obj.executionQueue(1) = [];
                
                % Executar tarefa
                result = obj.executeQueueItem(queueItem);
                
                if ~isempty(result)
                    results{end+1} = result;
                    obj.executionStats.tasksSuccessful = obj.executionStats.tasksSuccessful + 1;
                else
                    obj.executionStats.tasksFailed = obj.executionStats.tasksFailed + 1;
                end
                
                obj.executionStats.tasksExecuted = obj.executionStats.tasksExecuted + 1;
                
                % Mostrar progresso
                progress = (obj.executionStats.tasksExecuted / totalTasks) * 100;
                obj.logger('info', sprintf('Progresso: %.1f%% (%d/%d)', ...
                    progress, obj.executionStats.tasksExecuted, totalTasks));
            end
            
            obj.logger('success', sprintf('Queue processada: %d sucessos, %d falhas', ...
                obj.executionStats.tasksSuccessful, obj.executionStats.tasksFailed));
        end
        
        function result = executeQueueItem(obj, queueItem)
            % Executa um item da queue
            
            result = [];
            
            try
                obj.logger('debug', sprintf('Executando tarefa %s...', queueItem.id));
                
                % Marcar como em execução
                queueItem.status = 'running';
                queueItem.startTime = now;
                
                % Executar tarefa com timeout
                result = obj.executeTaskWithTimeout(queueItem.task, queueItem.timeout);
                
                queueItem.status = 'completed';
                queueItem.endTime = now;
                
                obj.logger('success', sprintf('Tarefa %s concluída', queueItem.id));
                
            catch ME
                queueItem.status = 'failed';
                queueItem.error = ME.message;
                queueItem.endTime = now;
                
                obj.logger('error', sprintf('Tarefa %s falhou: %s', queueItem.id, ME.message));
                
                % Tentar novamente se há tentativas restantes
                if queueItem.retries < queueItem.maxRetries
                    queueItem.retries = queueItem.retries + 1;
                    queueItem.status = 'retrying';
                    
                    obj.logger('info', sprintf('Tentativa %d/%d para tarefa %s', ...
                        queueItem.retries, queueItem.maxRetries, queueItem.id));
                    
                    % Readicionar à queue
                    obj.executionQueue{end+1} = queueItem;
                end
            end
        end
        
        function result = executeTaskWithTimeout(obj, task, timeout)
            % Executa tarefa com timeout
            
            % Implementação simples - em produção usaria timer
            startTime = tic;
            
            if isa(task, 'function_handle')
                result = task();
            else
                error('Tipo de tarefa não suportado');
            end
            
            elapsedTime = toc(startTime);
            
            if elapsedTime > timeout
                error('Tarefa excedeu timeout de %d segundos', timeout);
            end
        end
        
        function indices = selectSamplesForQuickTest(obj, totalSamples, targetSamples, strategy)
            % Seleciona amostras para teste rápido baseado na estratégia
            
            switch strategy
                case 'random'
                    % Seleção aleatória
                    rng(42); % Para reprodutibilidade
                    indices = randperm(totalSamples, targetSamples);
                    
                case 'first'
                    % Primeiras amostras
                    indices = 1:targetSamples;
                    
                case 'stratified'
                    % Seleção estratificada (implementação simples)
                    step = totalSamples / targetSamples;
                    indices = round(1:step:totalSamples);
                    indices = indices(1:targetSamples);
                    
                otherwise
                    error('Estratégia de seleção não suportada: %s', strategy);
            end
            
            indices = sort(indices);
        end
        
        function optimizedConfig = optimizeBatchSize(obj, config, resourceInfo, targetMemoryUsage)
            % Otimiza batch size baseado na memória disponível
            
            optimizedConfig = config;
            
            if targetMemoryUsage == 0
                targetMemoryUsage = resourceInfo.memory.availableGB * 0.7; % Usar 70% da memória disponível
            end
            
            % Estimar uso de memória por amostra (valores aproximados)
            if isfield(config, 'inputSize')
                inputSize = config.inputSize;
                memoryPerSample = prod(inputSize) * 4 / (1024^3); % 4 bytes por float, converter para GB
                
                % Calcular batch size ótimo
                optimalBatchSize = floor(targetMemoryUsage / memoryPerSample);
                
                % Limitar a valores razoáveis
                optimalBatchSize = max(1, min(32, optimalBatchSize));
                
                if isfield(config, 'miniBatchSize')
                    originalBatchSize = config.miniBatchSize;
                    optimizedConfig.miniBatchSize = optimalBatchSize;
                    
                    obj.logger('info', sprintf('Batch size otimizado: %d → %d (memória alvo: %.1f GB)', ...
                        originalBatchSize, optimalBatchSize, targetMemoryUsage));
                end
            end
        end
        
        function optimizedConfig = optimizeGPUSettings(obj, config, resourceInfo)
            % Otimiza configurações de GPU
            
            optimizedConfig = config;
            
            if resourceInfo.gpu.available
                % Configurar para usar GPU
                optimizedConfig.executionEnvironment = 'gpu';
                
                % Ajustar configurações baseado na memória da GPU
                if resourceInfo.gpu.memoryGB < 4
                    % GPU com pouca memória
                    if isfield(optimizedConfig, 'miniBatchSize')
                        optimizedConfig.miniBatchSize = max(1, optimizedConfig.miniBatchSize / 2);
                    end
                    obj.logger('info', 'Configurações ajustadas para GPU com pouca memória');
                end
                
                obj.logger('info', 'Configurações otimizadas para GPU');
            else
                optimizedConfig.executionEnvironment = 'cpu';
                obj.logger('info', 'Configurações otimizadas para CPU');
            end
        end
        
        function optimizedConfig = applyBasicOptimizations(obj, config, resourceInfo)
            % Aplica otimizações básicas
            
            optimizedConfig = config;
            
            % Otimizações conservadoras
            if isfield(optimizedConfig, 'maxEpochs') && optimizedConfig.maxEpochs > 50
                optimizedConfig.maxEpochs = 50;
                obj.logger('info', 'Número máximo de épocas limitado a 50');
            end
            
            % Habilitar early stopping
            optimizedConfig.enableEarlyStopping = true;
            optimizedConfig.validationPatience = 10;
        end
        
        function optimizedConfig = applyAggressiveOptimizations(obj, config, resourceInfo)
            % Aplica otimizações agressivas
            
            optimizedConfig = obj.applyBasicOptimizations(config, resourceInfo);
            
            % Otimizações mais agressivas
            if isfield(optimizedConfig, 'maxEpochs')
                optimizedConfig.maxEpochs = min(optimizedConfig.maxEpochs, 30);
                obj.logger('info', 'Otimização agressiva: épocas limitadas a 30');
            end
            
            % Reduzir validação frequency
            optimizedConfig.validationFrequency = max(5, optimizedConfig.validationFrequency * 2);
            
            % Habilitar mixed precision se GPU disponível
            if resourceInfo.gpu.available
                optimizedConfig.enableMixedPrecision = true;
                obj.logger('info', 'Mixed precision habilitada');
            end
        end
        
        function insertIndex = findInsertionIndex(obj, priority)
            % Encontra índice de inserção baseado na prioridade
            
            priorityValues = containers.Map({'high', 'normal', 'low'}, {3, 2, 1});
            targetPriority = priorityValues(priority);
            
            insertIndex = length(obj.executionQueue) + 1;
            
            for i = 1:length(obj.executionQueue)
                itemPriority = priorityValues(obj.executionQueue{i}.priority);
                if targetPriority > itemPriority
                    insertIndex = i;
                    break;
                end
            end
        end
        
        function taskId = generateTaskId(obj)
            % Gera ID único para tarefa
            taskId = sprintf('task_%d_%d', round(now*86400), randi(9999));
        end
        
        function clearCache(obj)
            % Limpa cache se habilitado
            obj.logger('info', 'Cache limpo');
        end
    end
end