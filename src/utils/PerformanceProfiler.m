classdef PerformanceProfiler < handle
    % ========================================================================
    % PERFORMANCEPROFILER - SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 3.0 - Performance Optimization
    %
    % DESCRIÇÃO:
    %   Classe para profiling automático de performance e identificação de
    %   gargalos no sistema de comparação de modelos.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Performance and Memory
    %   - Profiling and Optimization
    %   - Code Analysis
    %
    % REQUISITOS: 7.4 (profiler automático para identificar gargalos)
    % ========================================================================
    
    properties (Access = private)
        resourceMonitor
        profilingEnabled = true
        
        % Dados de profiling
        functionTimes = containers.Map()
        memorySnapshots = []
        bottlenecks = {}
        
        % Configurações
        minExecutionTime = 0.1  % segundos - só perfilar funções que demoram mais que isso
        maxBottlenecks = 10
        
        % Estado atual
        currentProfile = ''
        profilingStack = {}
    end
    
    properties (Constant)
        BOTTLENECK_THRESHOLD = 0.1  % 10% do tempo total
        MEMORY_LEAK_THRESHOLD = 0.05  % 5% de crescimento por iteração
    end
    
    methods
        function obj = PerformanceProfiler(varargin)
            % Construtor da classe PerformanceProfiler
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'EnableProfiling' - true/false (padrão: true)
            %     'MinExecutionTime' - tempo mínimo para profiling (padrão: 0.1s)
            %     'ResourceMonitor' - instância de ResourceMonitor (opcional)
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'EnableProfiling', true, @islogical);
            addParameter(p, 'MinExecutionTime', 0.1, @isnumeric);
            addParameter(p, 'ResourceMonitor', [], @(x) isa(x, 'ResourceMonitor') || isempty(x));
            parse(p, varargin{:});
            
            obj.profilingEnabled = p.Results.EnableProfiling;
            obj.minExecutionTime = p.Results.MinExecutionTime;
            
            % Inicializar ResourceMonitor se não fornecido
            if isempty(p.Results.ResourceMonitor)
                obj.resourceMonitor = ResourceMonitor();
            else
                obj.resourceMonitor = p.Results.ResourceMonitor;
            end
            
            % Inicializar estruturas
            obj.initializeProfiler();
            
            if obj.profilingEnabled
                fprintf('🔍 PerformanceProfiler inicializado\n');
            end
        end
        
        function startFunctionProfiling(obj, functionName)
            % Inicia profiling de uma função específica
            %
            % ENTRADA:
            %   functionName - Nome da função sendo perfilada
            %
            % REQUISITOS: 7.4 (profiler automático para identificar gargalos)
            
            if ~obj.profilingEnabled
                return;
            end
            
            try
                % Criar entrada de profiling
                profileEntry = struct();
                profileEntry.functionName = functionName;
                profileEntry.startTime = tic;
                profileEntry.startMemory = obj.resourceMonitor.getResourceInfo();
                profileEntry.level = length(obj.profilingStack) + 1;
                
                % Adicionar à pilha
                obj.profilingStack{end+1} = profileEntry;
                
            catch ME
                warning('PerformanceProfiler:StartFunction', ...
                    'Erro ao iniciar profiling de função: %s', ME.message);
            end
        end
        
        function endFunctionProfiling(obj, functionName)
            % Finaliza profiling de uma função específica
            %
            % ENTRADA:
            %   functionName - Nome da função sendo perfilada
            
            if ~obj.profilingEnabled || isempty(obj.profilingStack)
                return;
            end
            
            try
                % Pegar última entrada da pilha
                profileEntry = obj.profilingStack{end};
                obj.profilingStack(end) = [];
                
                % Verificar se é a função correta
                if ~strcmp(profileEntry.functionName, functionName)
                    warning('PerformanceProfiler:MismatchedFunction', ...
                        'Função esperada: %s, encontrada: %s', functionName, profileEntry.functionName);
                end
                
                % Calcular métricas
                executionTime = toc(profileEntry.startTime);
                endMemory = obj.resourceMonitor.getResourceInfo();
                
                % Só armazenar se tempo de execução for significativo
                if executionTime >= obj.minExecutionTime
                    obj.storeFunctionProfile(profileEntry, executionTime, endMemory);
                end
                
            catch ME
                warning('PerformanceProfiler:EndFunction', ...
                    'Erro ao finalizar profiling de função: %s', ME.message);
            end
        end
        
        function bottlenecks = identifyBottlenecks(obj)
            % Identifica gargalos de performance baseado nos dados coletados
            %
            % SAÍDA:
            %   bottlenecks - Cell array com gargalos identificados
            %
            % REQUISITOS: 7.4 (profiler automático para identificar gargalos)
            
            bottlenecks = {};
            
            try
                if obj.functionTimes.Count == 0
                    return;
                end
                
                % Calcular tempo total
                functionNames = obj.functionTimes.keys;
                totalTime = 0;
                functionData = [];
                
                for i = 1:length(functionNames)
                    funcName = functionNames{i};
                    funcData = obj.functionTimes(funcName);
                    
                    totalExecutionTime = sum([funcData.executionTimes]);
                    totalTime = totalTime + totalExecutionTime;
                    
                    functionData(i) = struct(...
                        'name', funcName, ...
                        'totalTime', totalExecutionTime, ...
                        'callCount', length(funcData.executionTimes), ...
                        'avgTime', mean(funcData.executionTimes), ...
                        'maxTime', max(funcData.executionTimes), ...
                        'minTime', min(funcData.executionTimes));
                end
                
                % Identificar funções que consomem mais tempo
                for i = 1:length(functionData)
                    func = functionData(i);
                    timePercentage = func.totalTime / totalTime;
                    
                    if timePercentage > obj.BOTTLENECK_THRESHOLD
                        bottleneck = struct();
                        bottleneck.type = 'time_bottleneck';
                        bottleneck.function = func.name;
                        bottleneck.timePercentage = timePercentage * 100;
                        bottleneck.totalTime = func.totalTime;
                        bottleneck.callCount = func.callCount;
                        bottleneck.avgTime = func.avgTime;
                        bottleneck.severity = obj.calculateSeverity(timePercentage);
                        bottleneck.recommendation = obj.generateTimeRecommendation(func);
                        
                        bottlenecks{end+1} = bottleneck;
                    end
                end
                
                % Identificar vazamentos de memória
                memoryBottlenecks = obj.identifyMemoryLeaks();
                bottlenecks = [bottlenecks, memoryBottlenecks];
                
                % Ordenar por severidade
                if ~isempty(bottlenecks)
                    severities = cellfun(@(x) x.severity, bottlenecks);
                    [~, sortIdx] = sort(severities, 'descend');
                    bottlenecks = bottlenecks(sortIdx);
                    
                    % Limitar número de gargalos reportados
                    if length(bottlenecks) > obj.maxBottlenecks
                        bottlenecks = bottlenecks(1:obj.maxBottlenecks);
                    end
                end
                
                obj.bottlenecks = bottlenecks;
                
            catch ME
                warning('PerformanceProfiler:IdentifyBottlenecks', ...
                    'Erro ao identificar gargalos: %s', ME.message);
            end
        end
        
        function report = generateBottleneckReport(obj)
            % Gera relatório detalhado de gargalos
            %
            % SAÍDA:
            %   report - String com relatório formatado
            %
            % REQUISITOS: 7.4 (relatórios de performance com recomendações)
            
            report = '';
            
            try
                % Identificar gargalos se ainda não foi feito
                if isempty(obj.bottlenecks)
                    obj.identifyBottlenecks();
                end
                
                if isempty(obj.bottlenecks)
                    report = '✅ Nenhum gargalo significativo identificado.\n';
                    return;
                end
                
                report = sprintf('🔍 RELATÓRIO DE GARGALOS DE PERFORMANCE\n');
                report = [report sprintf('==========================================\n\n')];
                
                for i = 1:length(obj.bottlenecks)
                    bottleneck = obj.bottlenecks{i};
                    
                    report = [report sprintf('%d. %s\n', i, upper(bottleneck.type))];
                    report = [report sprintf('   Função: %s\n', bottleneck.function)];
                    
                    if strcmp(bottleneck.type, 'time_bottleneck')
                        report = [report sprintf('   Tempo total: %.2f segundos (%.1f%% do total)\n', ...
                            bottleneck.totalTime, bottleneck.timePercentage)];
                        report = [report sprintf('   Chamadas: %d (média: %.3f s/chamada)\n', ...
                            bottleneck.callCount, bottleneck.avgTime)];
                    elseif strcmp(bottleneck.type, 'memory_leak')
                        report = [report sprintf('   Crescimento de memória: %.1f MB por iteração\n', ...
                            bottleneck.memoryGrowthMB)];
                        report = [report sprintf('   Iterações analisadas: %d\n', bottleneck.iterations)];
                    end
                    
                    report = [report sprintf('   Severidade: %s\n', obj.getSeverityText(bottleneck.severity))];
                    report = [report sprintf('   Recomendação: %s\n\n', bottleneck.recommendation)];
                end
                
                % Adicionar recomendações gerais
                generalRecs = obj.generateGeneralRecommendations();
                if ~isempty(generalRecs)
                    report = [report sprintf('RECOMENDAÇÕES GERAIS\n')];
                    report = [report sprintf('===================\n')];
                    for i = 1:length(generalRecs)
                        report = [report sprintf('• %s\n', generalRecs{i})];
                    end
                end
                
            catch ME
                report = sprintf('Erro ao gerar relatório: %s\n', ME.message);
            end
        end
        
        function saveBottleneckReport(obj, filename)
            % Salva relatório de gargalos em arquivo
            %
            % ENTRADA:
            %   filename - Nome do arquivo (opcional)
            
            if nargin < 2
                timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                filename = sprintf('output/reports/bottleneck_report_%s.txt', timestamp);
            end
            
            try
                % Criar diretório se não existir
                [filepath, ~, ~] = fileparts(filename);
                if ~exist(filepath, 'dir')
                    mkdir(filepath);
                end
                
                % Gerar e salvar relatório
                report = obj.generateBottleneckReport();
                
                fid = fopen(filename, 'w');
                if fid == -1
                    error('Não foi possível criar arquivo: %s', filename);
                end
                
                fprintf(fid, '%s', report);
                fclose(fid);
                
                fprintf('📊 Relatório de gargalos salvo: %s\n', filename);
                
            catch ME
                error('PerformanceProfiler:SaveReport', ...
                    'Erro ao salvar relatório: %s', ME.message);
            end
        end
        
        function stats = getProfilingStats(obj)
            % Retorna estatísticas de profiling
            %
            % SAÍDA:
            %   stats - Estrutura com estatísticas
            
            stats = struct();
            
            try
                stats.enabled = obj.profilingEnabled;
                stats.functionsProfiled = obj.functionTimes.Count;
                stats.bottlenecksFound = length(obj.bottlenecks);
                stats.memorySnapshots = length(obj.memorySnapshots);
                
                if obj.functionTimes.Count > 0
                    functionNames = obj.functionTimes.keys;
                    totalCalls = 0;
                    totalTime = 0;
                    
                    for i = 1:length(functionNames)
                        funcData = obj.functionTimes(functionNames{i});
                        totalCalls = totalCalls + length(funcData.executionTimes);
                        totalTime = totalTime + sum(funcData.executionTimes);
                    end
                    
                    stats.totalFunctionCalls = totalCalls;
                    stats.totalExecutionTime = totalTime;
                    stats.avgExecutionTime = totalTime / totalCalls;
                else
                    stats.totalFunctionCalls = 0;
                    stats.totalExecutionTime = 0;
                    stats.avgExecutionTime = 0;
                end
                
            catch ME
                warning('PerformanceProfiler:GetStats', ...
                    'Erro ao obter estatísticas: %s', ME.message);
                stats = struct('enabled', false);
            end
        end
        
        function cleanup(obj)
            % Limpa dados de profiling
            
            try
                obj.functionTimes = containers.Map();
                obj.memorySnapshots = [];
                obj.bottlenecks = {};
                obj.profilingStack = {};
                
                fprintf('🧹 PerformanceProfiler limpo\n');
                
            catch ME
                warning('PerformanceProfiler:Cleanup', ...
                    'Erro na limpeza: %s', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function initializeProfiler(obj)
            % Inicializa estruturas do profiler
            obj.functionTimes = containers.Map();
            obj.memorySnapshots = [];
            obj.bottlenecks = {};
            obj.profilingStack = {};
        end
        
        function storeFunctionProfile(obj, profileEntry, executionTime, endMemory)
            % Armazena dados de profiling de uma função
            
            try
                funcName = profileEntry.functionName;
                
                % Criar entrada se não existir
                if ~obj.functionTimes.isKey(funcName)
                    obj.functionTimes(funcName) = struct(...
                        'executionTimes', [], ...
                        'memorySamples', [], ...
                        'callCount', 0);
                end
                
                % Obter dados existentes
                funcData = obj.functionTimes(funcName);
                
                % Adicionar nova medição
                funcData.executionTimes(end+1) = executionTime;
                funcData.callCount = funcData.callCount + 1;
                
                % Calcular diferença de memória
                memoryDiff = endMemory.memory.usedGB - profileEntry.startMemory.memory.usedGB;
                funcData.memorySamples(end+1) = memoryDiff;
                
                % Atualizar dados
                obj.functionTimes(funcName) = funcData;
                
                % Adicionar snapshot de memória
                memorySnapshot = struct();
                memorySnapshot.timestamp = now;
                memorySnapshot.function = funcName;
                memorySnapshot.memoryUsage = endMemory.memory.usedGB;
                memorySnapshot.executionTime = executionTime;
                
                obj.memorySnapshots(end+1) = memorySnapshot;
                
            catch ME
                warning('PerformanceProfiler:StoreProfile', ...
                    'Erro ao armazenar perfil: %s', ME.message);
            end
        end
        
        function memoryBottlenecks = identifyMemoryLeaks(obj)
            % Identifica possíveis vazamentos de memória
            
            memoryBottlenecks = {};
            
            try
                if length(obj.memorySnapshots) < 10
                    return;  % Dados insuficientes
                end
                
                % Agrupar por função
                functions = unique({obj.memorySnapshots.function});
                
                for i = 1:length(functions)
                    funcName = functions{i};
                    
                    % Obter snapshots desta função
                    funcSnapshots = obj.memorySnapshots(strcmp({obj.memorySnapshots.function}, funcName));
                    
                    if length(funcSnapshots) < 5
                        continue;  % Dados insuficientes
                    end
                    
                    % Calcular tendência de crescimento de memória
                    memoryUsages = [funcSnapshots.memoryUsage];
                    trend = obj.calculateMemoryTrend(memoryUsages);
                    
                    if trend > obj.MEMORY_LEAK_THRESHOLD
                        bottleneck = struct();
                        bottleneck.type = 'memory_leak';
                        bottleneck.function = funcName;
                        bottleneck.memoryGrowthMB = trend * 1024;  % Converter para MB
                        bottleneck.iterations = length(funcSnapshots);
                        bottleneck.severity = obj.calculateMemoryLeakSeverity(trend);
                        bottleneck.recommendation = obj.generateMemoryRecommendation(funcName, trend);
                        
                        memoryBottlenecks{end+1} = bottleneck;
                    end
                end
                
            catch ME
                warning('PerformanceProfiler:IdentifyMemoryLeaks', ...
                    'Erro ao identificar vazamentos de memória: %s', ME.message);
            end
        end
        
        function trend = calculateMemoryTrend(obj, memoryData)
            % Calcula tendência de crescimento de memória
            
            if length(memoryData) < 2
                trend = 0;
                return;
            end
            
            try
                x = 1:length(memoryData);
                p = polyfit(x, memoryData, 1);
                trend = p(1);  % Coeficiente angular (crescimento por iteração)
            catch
                trend = 0;
            end
        end
        
        function severity = calculateSeverity(obj, timePercentage)
            % Calcula severidade baseada na porcentagem de tempo
            
            if timePercentage > 0.5  % > 50%
                severity = 5;  % Crítico
            elseif timePercentage > 0.3  % > 30%
                severity = 4;  % Alto
            elseif timePercentage > 0.2  % > 20%
                severity = 3;  % Médio
            elseif timePercentage > 0.1  % > 10%
                severity = 2;  % Baixo
            else
                severity = 1;  % Muito baixo
            end
        end
        
        function severity = calculateMemoryLeakSeverity(obj, trend)
            % Calcula severidade de vazamento de memória
            
            if trend > 0.2  % > 200MB por iteração
                severity = 5;  % Crítico
            elseif trend > 0.1  % > 100MB por iteração
                severity = 4;  % Alto
            elseif trend > 0.05  % > 50MB por iteração
                severity = 3;  % Médio
            else
                severity = 2;  % Baixo
            end
        end
        
        function text = getSeverityText(obj, severity)
            % Converte severidade numérica para texto
            
            switch severity
                case 5
                    text = 'CRÍTICO';
                case 4
                    text = 'ALTO';
                case 3
                    text = 'MÉDIO';
                case 2
                    text = 'BAIXO';
                case 1
                    text = 'MUITO BAIXO';
                otherwise
                    text = 'DESCONHECIDO';
            end
        end
        
        function recommendation = generateTimeRecommendation(obj, funcData)
            % Gera recomendação para gargalo de tempo
            
            if funcData.callCount > 100 && funcData.avgTime > 0.1
                recommendation = 'Considere otimizar esta função ou reduzir número de chamadas. Verifique loops desnecessários.';
            elseif funcData.maxTime > funcData.avgTime * 10
                recommendation = 'Função tem variação alta no tempo de execução. Verifique condições especiais ou dados de entrada.';
            elseif funcData.avgTime > 1.0
                recommendation = 'Função lenta. Considere paralelização, cache ou otimização de algoritmo.';
            else
                recommendation = 'Otimize algoritmo ou considere implementação mais eficiente.';
            end
        end
        
        function recommendation = generateMemoryRecommendation(obj, funcName, trend)
            % Gera recomendação para vazamento de memória
            
            if trend > 0.1
                recommendation = sprintf('Possível vazamento de memória em %s. Verifique limpeza de variáveis e liberação de recursos.', funcName);
            else
                recommendation = sprintf('Crescimento gradual de memória em %s. Considere otimização de uso de memória.', funcName);
            end
        end
        
        function recommendations = generateGeneralRecommendations(obj)
            % Gera recomendações gerais baseadas nos gargalos
            
            recommendations = {};
            
            try
                if isempty(obj.bottlenecks)
                    return;
                end
                
                % Contar tipos de gargalos
                timeBottlenecks = sum(cellfun(@(x) strcmp(x.type, 'time_bottleneck'), obj.bottlenecks));
                memoryBottlenecks = sum(cellfun(@(x) strcmp(x.type, 'memory_leak'), obj.bottlenecks));
                
                if timeBottlenecks > 3
                    recommendations{end+1} = 'Múltiplos gargalos de tempo detectados. Considere refatoração geral do código.';
                end
                
                if memoryBottlenecks > 1
                    recommendations{end+1} = 'Múltiplos vazamentos de memória detectados. Implemente limpeza automática de variáveis.';
                end
                
                % Verificar se há gargalos críticos
                criticalBottlenecks = sum(cellfun(@(x) x.severity >= 4, obj.bottlenecks));
                if criticalBottlenecks > 0
                    recommendations{end+1} = 'Gargalos críticos detectados. Priorize otimização das funções mais problemáticas.';
                end
                
                % Recomendações baseadas no sistema
                resourceInfo = obj.resourceMonitor.getResourceInfo();
                if resourceInfo.memory.utilizationPercent > 80
                    recommendations{end+1} = 'Alto uso de memória do sistema. Considere processamento em lotes menores.';
                end
                
                if resourceInfo.gpu.available && resourceInfo.gpu.utilization < 0.3
                    recommendations{end+1} = 'GPU subutilizada. Considere otimizar uso de GPU para acelerar processamento.';
                end
                
            catch ME
                warning('PerformanceProfiler:GeneralRecommendations', ...
                    'Erro ao gerar recomendações gerais: %s', ME.message);
            end
        end
    end
end