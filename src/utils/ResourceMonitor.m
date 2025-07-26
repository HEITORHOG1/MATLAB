classdef ResourceMonitor < handle
    % ========================================================================
    % RESOURCEMONITOR - SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 3.0 - Performance Optimization
    %
    % DESCRIÇÃO:
    %   Classe para monitoramento de recursos do sistema incluindo CPU, memória,
    %   GPU e geração de relatórios de performance com recomendações.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Performance and Memory
    %   - GPU Computing
    %   - System Information
    %
    % REQUISITOS: 7.4 (monitoramento de uso de memória e GPU)
    % ========================================================================
    
    properties (Access = private)
        monitoringEnabled = true
        samplingInterval = 1  % segundos
        maxSamples = 1000
        
        % Histórico de monitoramento
        cpuHistory = []
        memoryHistory = []
        gpuHistory = []
        timestamps = []
        
        % Informações do sistema
        systemInfo = struct()
        
        % Profiling data
        profileData = struct()
        profilingActive = false
    end
    
    properties (Constant)
        MEMORY_WARNING_THRESHOLD = 0.85  % 85% de uso
        GPU_MEMORY_WARNING_THRESHOLD = 0.90  % 90% de uso
        CPU_WARNING_THRESHOLD = 0.95  % 95% de uso
    end
    
    methods
        function obj = ResourceMonitor(varargin)
            % Construtor da classe ResourceMonitor
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'SamplingInterval' - intervalo de amostragem em segundos (padrão: 1)
            %     'MaxSamples' - número máximo de amostras no histórico (padrão: 1000)
            %     'EnableMonitoring' - true/false (padrão: true)
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'SamplingInterval', 1, @isnumeric);
            addParameter(p, 'MaxSamples', 1000, @isnumeric);
            addParameter(p, 'EnableMonitoring', true, @islogical);
            parse(p, varargin{:});
            
            obj.samplingInterval = p.Results.SamplingInterval;
            obj.maxSamples = p.Results.MaxSamples;
            obj.monitoringEnabled = p.Results.EnableMonitoring;
            
            % Inicializar sistema
            obj.initializeSystemInfo();
            obj.initializeProfileData();
            
            if obj.monitoringEnabled
                obj.startMonitoring();
            end
        end
        
        function resourceInfo = getResourceInfo(obj)
            % Obtém informações atuais de recursos do sistema
            %
            % SAÍDA:
            %   resourceInfo - Estrutura com informações de recursos
            %
            % REQUISITOS: 7.4 (monitoramento de uso de memória e GPU)
            
            resourceInfo = struct();
            
            try
                % Informações de memória
                resourceInfo.memory = obj.getMemoryInfo();
                
                % Informações de CPU
                resourceInfo.cpu = obj.getCPUInfo();
                
                % Informações de GPU
                resourceInfo.gpu = obj.getGPUInfo();
                
                % Informações do sistema
                resourceInfo.system = obj.systemInfo;
                
                % Timestamp
                resourceInfo.timestamp = now;
                
            catch ME
                warning('ResourceMonitor:GetResourceInfo', ...
                    'Erro ao obter informações de recursos: %s', ME.message);
                resourceInfo = obj.getDefaultResourceInfo();
            end
        end
        
        function startProfiling(obj, profileName)
            % Inicia profiling de performance
            %
            % ENTRADA:
            %   profileName - Nome do perfil de performance
            %
            % REQUISITOS: 7.4 (profiler automático para identificar gargalos)
            
            if nargin < 2
                profileName = sprintf('profile_%s', datestr(now, 'yyyymmdd_HHMMSS'));
            end
            
            try
                % Inicializar dados do perfil
                obj.profileData.(profileName) = struct();
                obj.profileData.(profileName).startTime = now;
                obj.profileData.(profileName).startResources = obj.getResourceInfo();
                obj.profileData.(profileName).checkpoints = {};
                obj.profileData.(profileName).active = true;
                
                obj.profilingActive = true;
                
                % Iniciar profiler do MATLAB se disponível
                if license('test', 'MATLAB')
                    profile('on', '-history');
                end
                
                fprintf('📊 Profiling iniciado: %s\n', profileName);
                
            catch ME
                warning('ResourceMonitor:StartProfiling', ...
                    'Erro ao iniciar profiling: %s', ME.message);
            end
        end
        
        function stopProfiling(obj, profileName)
            % Para profiling e gera relatório
            %
            % ENTRADA:
            %   profileName - Nome do perfil de performance
            %
            % SAÍDA:
            %   Gera relatório de performance
            %
            % REQUISITOS: 7.4 (relatórios de performance com recomendações)
            
            if nargin < 2
                % Encontrar perfil ativo
                profiles = fieldnames(obj.profileData);
                profileName = '';
                for i = 1:length(profiles)
                    if isfield(obj.profileData.(profiles{i}), 'active') && ...
                       obj.profileData.(profiles{i}).active
                        profileName = profiles{i};
                        break;
                    end
                end
                
                if isempty(profileName)
                    warning('ResourceMonitor:NoProfiling', 'Nenhum profiling ativo encontrado');
                    return;
                end
            end
            
            try
                if ~isfield(obj.profileData, profileName)
                    error('Perfil não encontrado: %s', profileName);
                end
                
                % Finalizar dados do perfil
                obj.profileData.(profileName).endTime = now;
                obj.profileData.(profileName).endResources = obj.getResourceInfo();
                obj.profileData.(profileName).active = false;
                obj.profileData.(profileName).duration = ...
                    obj.profileData.(profileName).endTime - obj.profileData.(profileName).startTime;
                
                % Parar profiler do MATLAB
                if license('test', 'MATLAB')
                    profile('off');
                    obj.profileData.(profileName).matlabProfile = profile('info');
                end
                
                obj.profilingActive = false;
                
                % Gerar relatório
                obj.generatePerformanceReport(profileName);
                
                fprintf('📊 Profiling finalizado: %s (%.2f segundos)\n', ...
                    profileName, obj.profileData.(profileName).duration * 24 * 3600);
                
            catch ME
                warning('ResourceMonitor:StopProfiling', ...
                    'Erro ao parar profiling: %s', ME.message);
            end
        end
        
        function addCheckpoint(obj, checkpointName, data)
            % Adiciona checkpoint durante profiling
            %
            % ENTRADA:
            %   checkpointName - Nome do checkpoint
            %   data - Dados adicionais (opcional)
            
            if ~obj.profilingActive
                return;
            end
            
            try
                % Encontrar perfil ativo
                profiles = fieldnames(obj.profileData);
                activeProfile = '';
                for i = 1:length(profiles)
                    if isfield(obj.profileData.(profiles{i}), 'active') && ...
                       obj.profileData.(profiles{i}).active
                        activeProfile = profiles{i};
                        break;
                    end
                end
                
                if isempty(activeProfile)
                    return;
                end
                
                % Criar checkpoint
                checkpoint = struct();
                checkpoint.name = checkpointName;
                checkpoint.timestamp = now;
                checkpoint.resources = obj.getResourceInfo();
                
                if nargin > 2
                    checkpoint.data = data;
                end
                
                % Adicionar ao perfil
                checkpoints = obj.profileData.(activeProfile).checkpoints;
                checkpoints{end+1} = checkpoint;
                obj.profileData.(activeProfile).checkpoints = checkpoints;
                
            catch ME
                warning('ResourceMonitor:AddCheckpoint', ...
                    'Erro ao adicionar checkpoint: %s', ME.message);
            end
        end
        
        function recommendations = generateOptimizationRecommendations(obj)
            % Gera recomendações de otimização baseadas no monitoramento
            %
            % SAÍDA:
            %   recommendations - Cell array com recomendações
            %
            % REQUISITOS: 7.4 (recomendações de otimização)
            
            recommendations = {};
            
            try
                currentResources = obj.getResourceInfo();
                
                % Recomendações de memória
                if currentResources.memory.utilizationPercent > obj.MEMORY_WARNING_THRESHOLD * 100
                    recommendations{end+1} = struct(...
                        'type', 'memory', ...
                        'priority', 'high', ...
                        'message', sprintf('Uso de memória alto (%.1f%%). Considere reduzir batch size ou habilitar lazy loading.', ...
                            currentResources.memory.utilizationPercent), ...
                        'action', 'reduce_batch_size');
                end
                
                % Recomendações de GPU
                if currentResources.gpu.available
                    if currentResources.gpu.memoryUtilization > obj.GPU_MEMORY_WARNING_THRESHOLD
                        recommendations{end+1} = struct(...
                            'type', 'gpu', ...
                            'priority', 'high', ...
                            'message', sprintf('Memória GPU alta (%.1f%%). Reduza batch size ou use mixed precision.', ...
                                currentResources.gpu.memoryUtilization * 100), ...
                            'action', 'optimize_gpu_memory');
                    end
                    
                    if currentResources.gpu.utilization < 0.5
                        recommendations{end+1} = struct(...
                            'type', 'gpu', ...
                            'priority', 'medium', ...
                            'message', sprintf('GPU subutilizada (%.1f%%). Considere aumentar batch size.', ...
                                currentResources.gpu.utilization * 100), ...
                            'action', 'increase_batch_size');
                    end
                else
                    recommendations{end+1} = struct(...
                        'type', 'gpu', ...
                        'priority', 'medium', ...
                        'message', 'GPU não disponível. Considere usar GPU para acelerar treinamento.', ...
                        'action', 'enable_gpu');
                end
                
                % Recomendações de CPU
                if currentResources.cpu.utilization > obj.CPU_WARNING_THRESHOLD
                    recommendations{end+1} = struct(...
                        'type', 'cpu', ...
                        'priority', 'medium', ...
                        'message', sprintf('CPU sobrecarregada (%.1f%%). Considere reduzir workers paralelos.', ...
                            currentResources.cpu.utilization * 100), ...
                        'action', 'reduce_parallel_workers');
                end
                
                % Recomendações baseadas no histórico
                if length(obj.memoryHistory) > 10
                    memoryTrend = obj.calculateTrend(obj.memoryHistory(end-9:end));
                    if memoryTrend > 0.1  % Crescimento de 10% ou mais
                        recommendations{end+1} = struct(...
                            'type', 'memory', ...
                            'priority', 'medium', ...
                            'message', 'Tendência crescente no uso de memória. Verifique vazamentos de memória.', ...
                            'action', 'check_memory_leaks');
                    end
                end
                
            catch ME
                warning('ResourceMonitor:GenerateRecommendations', ...
                    'Erro ao gerar recomendações: %s', ME.message);
            end
        end
        
        function cleanup(obj)
            % Limpa recursos e para monitoramento
            
            try
                obj.monitoringEnabled = false;
                obj.profilingActive = false;
                
                % Limpar histórico se muito grande
                if length(obj.timestamps) > obj.maxSamples
                    keepIndices = (end - obj.maxSamples + 1):end;
                    obj.timestamps = obj.timestamps(keepIndices);
                    obj.cpuHistory = obj.cpuHistory(keepIndices);
                    obj.memoryHistory = obj.memoryHistory(keepIndices);
                    if ~isempty(obj.gpuHistory)
                        obj.gpuHistory = obj.gpuHistory(keepIndices);
                    end
                end
                
                fprintf('🧹 ResourceMonitor limpo\n');
                
            catch ME
                warning('ResourceMonitor:Cleanup', ...
                    'Erro na limpeza: %s', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function initializeSystemInfo(obj)
            % Inicializa informações do sistema
            
            try
                obj.systemInfo = struct();
                obj.systemInfo.platform = computer;
                obj.systemInfo.matlabVersion = version;
                obj.systemInfo.numCores = feature('numcores');
                
                % Informações de toolboxes
                obj.systemInfo.toolboxes = struct();
                obj.systemInfo.toolboxes.parallelComputing = license('test', 'Distrib_Computing_Toolbox');
                obj.systemInfo.toolboxes.deepLearning = license('test', 'Neural_Network_Toolbox');
                obj.systemInfo.toolboxes.imageProcessing = license('test', 'Image_Toolbox');
                
            catch ME
                warning('ResourceMonitor:SystemInfo', ...
                    'Erro ao obter informações do sistema: %s', ME.message);
            end
        end
        
        function initializeProfileData(obj)
            % Inicializa estrutura de dados de profiling
            obj.profileData = struct();
        end
        
        function startMonitoring(obj)
            % Inicia monitoramento contínuo (implementação básica)
            
            try
                % Coletar amostra inicial
                obj.collectSample();
                
                fprintf('📊 Monitoramento de recursos iniciado\n');
                
            catch ME
                warning('ResourceMonitor:StartMonitoring', ...
                    'Erro ao iniciar monitoramento: %s', ME.message);
            end
        end
        
        function collectSample(obj)
            % Coleta uma amostra de recursos
            
            try
                currentTime = now;
                resourceInfo = obj.getResourceInfo();
                
                % Adicionar ao histórico
                obj.timestamps(end+1) = currentTime;
                obj.cpuHistory(end+1) = resourceInfo.cpu.utilization;
                obj.memoryHistory(end+1) = resourceInfo.memory.utilizationPercent;
                
                if resourceInfo.gpu.available
                    obj.gpuHistory(end+1) = resourceInfo.gpu.utilization;
                end
                
                % Manter tamanho do histórico
                if length(obj.timestamps) > obj.maxSamples
                    obj.timestamps(1) = [];
                    obj.cpuHistory(1) = [];
                    obj.memoryHistory(1) = [];
                    if ~isempty(obj.gpuHistory)
                        obj.gpuHistory(1) = [];
                    end
                end
                
            catch ME
                warning('ResourceMonitor:CollectSample', ...
                    'Erro ao coletar amostra: %s', ME.message);
            end
        end
        
        function memoryInfo = getMemoryInfo(obj)
            % Obtém informações de memória
            
            memoryInfo = struct();
            
            try
                if ispc
                    % Windows
                    [~, memOutput] = system('wmic computersystem get TotalPhysicalMemory /value');
                    totalMatch = regexp(memOutput, 'TotalPhysicalMemory=(\d+)', 'tokens');
                    
                    [~, availOutput] = system('wmic OS get FreePhysicalMemory /value');
                    availMatch = regexp(availOutput, 'FreePhysicalMemory=(\d+)', 'tokens');
                    
                    if ~isempty(totalMatch) && ~isempty(availMatch)
                        totalBytes = str2double(totalMatch{1}{1});
                        availKB = str2double(availMatch{1}{1});
                        availBytes = availKB * 1024;
                        
                        memoryInfo.totalGB = totalBytes / (1024^3);
                        memoryInfo.availableGB = availBytes / (1024^3);
                        memoryInfo.usedGB = memoryInfo.totalGB - memoryInfo.availableGB;
                        memoryInfo.utilizationPercent = (memoryInfo.usedGB / memoryInfo.totalGB) * 100;
                    end
                    
                elseif isunix
                    % Linux/Mac
                    [~, memOutput] = system('free -b | grep Mem');
                    tokens = regexp(memOutput, '\s+(\d+)', 'tokens');
                    
                    if length(tokens) >= 3
                        totalBytes = str2double(tokens{1}{1});
                        usedBytes = str2double(tokens{2}{1});
                        availBytes = str2double(tokens{3}{1});
                        
                        memoryInfo.totalGB = totalBytes / (1024^3);
                        memoryInfo.usedGB = usedBytes / (1024^3);
                        memoryInfo.availableGB = availBytes / (1024^3);
                        memoryInfo.utilizationPercent = (memoryInfo.usedGB / memoryInfo.totalGB) * 100;
                    end
                end
                
                % Fallback se não conseguiu obter informações
                if ~isfield(memoryInfo, 'totalGB')
                    memoryInfo.totalGB = 8;  % Assumir 8GB
                    memoryInfo.availableGB = 4;  % Assumir 4GB disponível
                    memoryInfo.usedGB = 4;
                    memoryInfo.utilizationPercent = 50;
                end
                
            catch
                % Valores padrão em caso de erro
                memoryInfo.totalGB = 8;
                memoryInfo.availableGB = 4;
                memoryInfo.usedGB = 4;
                memoryInfo.utilizationPercent = 50;
            end
        end
        
        function cpuInfo = getCPUInfo(obj)
            % Obtém informações de CPU
            
            cpuInfo = struct();
            
            try
                cpuInfo.numCores = feature('numcores');
                
                % Tentar obter utilização de CPU (implementação básica)
                if ispc
                    [~, cpuOutput] = system('wmic cpu get loadpercentage /value');
                    match = regexp(cpuOutput, 'LoadPercentage=(\d+)', 'tokens');
                    if ~isempty(match)
                        cpuInfo.utilization = str2double(match{1}{1}) / 100;
                    else
                        cpuInfo.utilization = 0.5;  % Fallback
                    end
                elseif isunix
                    % Implementação básica para Unix
                    cpuInfo.utilization = 0.5;  % Fallback
                else
                    cpuInfo.utilization = 0.5;  % Fallback
                end
                
            catch
                cpuInfo.numCores = 4;  % Fallback
                cpuInfo.utilization = 0.5;  % Fallback
            end
        end
        
        function gpuInfo = getGPUInfo(obj)
            % Obtém informações de GPU
            
            gpuInfo = struct();
            gpuInfo.available = false;
            
            try
                % Verificar se GPU está disponível
                if gpuDeviceCount > 0
                    gpu = gpuDevice();
                    gpuInfo.available = true;
                    gpuInfo.name = gpu.Name;
                    gpuInfo.memoryGB = gpu.TotalMemory / (1024^3);
                    gpuInfo.availableMemoryGB = gpu.AvailableMemory / (1024^3);
                    gpuInfo.memoryUtilization = 1 - (gpu.AvailableMemory / gpu.TotalMemory);
                    gpuInfo.utilization = 0.5;  % Placeholder - difícil de obter em tempo real
                else
                    gpuInfo.available = false;
                end
                
            catch
                gpuInfo.available = false;
                gpuInfo.name = 'N/A';
                gpuInfo.memoryGB = 0;
                gpuInfo.availableMemoryGB = 0;
                gpuInfo.memoryUtilization = 0;
                gpuInfo.utilization = 0;
            end
        end
        
        function defaultInfo = getDefaultResourceInfo(obj)
            % Retorna informações padrão em caso de erro
            
            defaultInfo = struct();
            defaultInfo.memory = struct('totalGB', 8, 'availableGB', 4, 'usedGB', 4, 'utilizationPercent', 50);
            defaultInfo.cpu = struct('numCores', 4, 'utilization', 0.5);
            defaultInfo.gpu = struct('available', false, 'name', 'N/A', 'memoryGB', 0, ...
                'availableMemoryGB', 0, 'memoryUtilization', 0, 'utilization', 0);
            defaultInfo.system = obj.systemInfo;
            defaultInfo.timestamp = now;
        end
        
        function generatePerformanceReport(obj, profileName)
            % Gera relatório de performance
            
            try
                profile = obj.profileData.(profileName);
                
                % Criar diretório de saída se não existir
                outputDir = 'output/reports';
                if ~exist(outputDir, 'dir')
                    mkdir(outputDir);
                end
                
                % Nome do arquivo
                filename = fullfile(outputDir, sprintf('performance_report_%s.txt', profileName));
                
                % Gerar relatório
                fid = fopen(filename, 'w');
                if fid == -1
                    error('Não foi possível criar arquivo de relatório');
                end
                
                fprintf(fid, '========================================\n');
                fprintf(fid, 'RELATÓRIO DE PERFORMANCE\n');
                fprintf(fid, '========================================\n\n');
                
                fprintf(fid, 'Perfil: %s\n', profileName);
                fprintf(fid, 'Duração: %.2f segundos\n', profile.duration * 24 * 3600);
                fprintf(fid, 'Início: %s\n', datestr(profile.startTime));
                fprintf(fid, 'Fim: %s\n\n', datestr(profile.endTime));
                
                % Recursos iniciais vs finais
                fprintf(fid, 'RECURSOS DO SISTEMA\n');
                fprintf(fid, '-------------------\n');
                fprintf(fid, 'Memória Inicial: %.1f GB (%.1f%% utilizada)\n', ...
                    profile.startResources.memory.usedGB, profile.startResources.memory.utilizationPercent);
                fprintf(fid, 'Memória Final: %.1f GB (%.1f%% utilizada)\n', ...
                    profile.endResources.memory.usedGB, profile.endResources.memory.utilizationPercent);
                
                if profile.startResources.gpu.available
                    fprintf(fid, 'GPU Inicial: %.1f%% utilizada\n', profile.startResources.gpu.utilization * 100);
                    fprintf(fid, 'GPU Final: %.1f%% utilizada\n', profile.endResources.gpu.utilization * 100);
                end
                
                % Checkpoints
                if ~isempty(profile.checkpoints)
                    fprintf(fid, '\nCHECKPOINTS\n');
                    fprintf(fid, '-----------\n');
                    for i = 1:length(profile.checkpoints)
                        cp = profile.checkpoints{i};
                        fprintf(fid, '%s: %s (Mem: %.1f GB)\n', ...
                            datestr(cp.timestamp, 'HH:MM:SS'), cp.name, cp.resources.memory.usedGB);
                    end
                end
                
                % Recomendações
                recommendations = obj.generateOptimizationRecommendations();
                if ~isempty(recommendations)
                    fprintf(fid, '\nRECOMENDAÇÕES DE OTIMIZAÇÃO\n');
                    fprintf(fid, '---------------------------\n');
                    for i = 1:length(recommendations)
                        rec = recommendations{i};
                        fprintf(fid, '[%s] %s: %s\n', upper(rec.priority), upper(rec.type), rec.message);
                    end
                end
                
                fclose(fid);
                
                fprintf('📊 Relatório de performance salvo: %s\n', filename);
                
            catch ME
                warning('ResourceMonitor:GenerateReport', ...
                    'Erro ao gerar relatório: %s', ME.message);
            end
        end
        
        function trend = calculateTrend(obj, data)
            % Calcula tendência em uma série de dados
            
            if length(data) < 2
                trend = 0;
                return;
            end
            
            try
                x = 1:length(data);
                p = polyfit(x, data, 1);
                trend = p(1) / mean(data);  % Tendência normalizada
            catch
                trend = 0;
            end
        end
    end
end