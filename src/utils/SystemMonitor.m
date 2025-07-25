classdef SystemMonitor < handle
    % ========================================================================
    % SYSTEMMONITOR - SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 3.0 - Performance Optimization
    %
    % DESCRIÇÃO:
    %   Classe principal para monitoramento completo do sistema incluindo
    %   recursos, performance e geração de relatórios com recomendações.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - Performance and Memory
    %   - System Monitoring
    %   - Report Generation
    %
    % REQUISITOS: 7.4 (sistema de monitoramento completo)
    % ========================================================================
    
    properties (Access = private)
        resourceMonitor
        performanceProfiler
        
        % Configurações de monitoramento
        monitoringEnabled = true
        autoReportEnabled = true
        reportInterval = 300  % 5 minutos
        
        % Dados de monitoramento
        monitoringSession = struct()
        alerts = {}
        
        % Thresholds para alertas
        alertThresholds = struct(...
            'memoryUsage', 0.85, ...
            'gpuMemoryUsage', 0.90, ...
            'cpuUsage', 0.95, ...
            'executionTime', 1800)  % 30 minutos
    end
    
    properties (Constant)
        ALERT_LEVELS = {'info', 'warning', 'critical'}
        MONITORING_COMPONENTS = {'resource', 'performance', 'memory', 'gpu'}
    end
    
    methods
        function obj = SystemMonitor(varargin)
            % Construtor da classe SystemMonitor
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'EnableMonitoring' - true/false (padrão: true)
            %     'EnableAutoReport' - true/false (padrão: true)
            %     'ReportInterval' - intervalo de relatórios em segundos (padrão: 300)
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'EnableMonitoring', true, @islogical);
            addParameter(p, 'EnableAutoReport', true, @islogical);
            addParameter(p, 'ReportInterval', 300, @isnumeric);
            parse(p, varargin{:});
            
            obj.monitoringEnabled = p.Results.EnableMonitoring;
            obj.autoReportEnabled = p.Results.EnableAutoReport;
            obj.reportInterval = p.Results.ReportInterval;
            
            % Inicializar componentes
            obj.initializeMonitoring();
            
            if obj.monitoringEnabled
                obj.startMonitoring();
            end
        end
        
        function startSystemMonitoring(obj, sessionName)
            % Inicia sessão completa de monitoramento
            %
            % ENTRADA:
            %   sessionName - Nome da sessão de monitoramento
            %
            % REQUISITOS: 7.4 (monitoramento de uso de memória e GPU)
            
            if nargin < 2
                sessionName = sprintf('monitoring_session_%s', datestr(now, 'yyyymmdd_HHMMSS'));
            end
            
            try
                % Inicializar sessão
                obj.monitoringSession = struct();
                obj.monitoringSession.name = sessionName;
                obj.monitoringSession.startTime = now;
                obj.monitoringSession.active = true;
                obj.monitoringSession.components = {};
                obj.monitoringSession.alerts = {};
                
                % Iniciar monitoramento de recursos
                obj.resourceMonitor.startProfiling(sprintf('%s_resources', sessionName));
                
                % Iniciar profiling de performance
                obj.performanceProfiler.startFunctionProfiling('system_monitoring');
                
                % Coletar baseline inicial
                obj.collectBaseline();
                
                fprintf('📊 Monitoramento do sistema iniciado: %s\n', sessionName);
                
                % Configurar relatórios automáticos se habilitado
                if obj.autoReportEnabled
                    obj.scheduleAutoReports();
                end
                
            catch ME
                error('SystemMonitor:StartMonitoring', ...
                    'Erro ao iniciar monitoramento: %s', ME.message);
            end
        end
        
        function stopSystemMonitoring(obj)
            % Para sessão de monitoramento e gera relatório final
            %
            % REQUISITOS: 7.4 (relatórios de performance com recomendações)
            
            try
                if ~isfield(obj.monitoringSession, 'active') || ~obj.monitoringSession.active
                    warning('SystemMonitor:NoActiveSession', 'Nenhuma sessão ativa de monitoramento');
                    return;
                end
                
                % Finalizar sessão
                obj.monitoringSession.endTime = now;
                obj.monitoringSession.duration = obj.monitoringSession.endTime - obj.monitoringSession.startTime;
                obj.monitoringSession.active = false;
                
                % Parar componentes de monitoramento
                obj.resourceMonitor.stopProfiling(sprintf('%s_resources', obj.monitoringSession.name));
                obj.performanceProfiler.endFunctionProfiling('system_monitoring');
                
                % Gerar relatório final
                obj.generateFinalReport();
                
                fprintf('📊 Monitoramento finalizado: %s (%.2f min)\n', ...
                    obj.monitoringSession.name, obj.monitoringSession.duration * 24 * 60);
                
            catch ME
                error('SystemMonitor:StopMonitoring', ...
                    'Erro ao parar monitoramento: %s', ME.message);
            end
        end
        
        function addMonitoringComponent(obj, componentName, component)
            % Adiciona componente para monitoramento
            %
            % ENTRADA:
            %   componentName - Nome do componente
            %   component - Instância do componente
            
            try
                if ~obj.monitoringSession.active
                    warning('SystemMonitor:NoActiveSession', 'Nenhuma sessão ativa');
                    return;
                end
                
                % Adicionar componente à sessão
                componentInfo = struct();
                componentInfo.name = componentName;
                componentInfo.component = component;
                componentInfo.addedTime = now;
                componentInfo.monitored = true;
                
                obj.monitoringSession.components{end+1} = componentInfo;
                
                fprintf('📋 Componente adicionado ao monitoramento: %s\n', componentName);
                
            catch ME
                warning('SystemMonitor:AddComponent', ...
                    'Erro ao adicionar componente: %s', ME.message);
            end
        end
        
        function checkSystemHealth(obj)
            % Verifica saúde do sistema e gera alertas se necessário
            %
            % REQUISITOS: 7.4 (monitoramento de uso de memória e GPU)
            
            try
                resourceInfo = obj.resourceMonitor.getResourceInfo();
                currentTime = now;
                
                % Verificar uso de memória
                if resourceInfo.memory.utilizationPercent / 100 > obj.alertThresholds.memoryUsage
                    obj.generateAlert('critical', 'memory', ...
                        sprintf('Uso de memória crítico: %.1f%%', resourceInfo.memory.utilizationPercent), ...
                        'Considere liberar memória ou reduzir batch size');
                end
                
                % Verificar uso de GPU
                if resourceInfo.gpu.available && resourceInfo.gpu.memoryUtilization > obj.alertThresholds.gpuMemoryUsage
                    obj.generateAlert('critical', 'gpu', ...
                        sprintf('Memória GPU crítica: %.1f%%', resourceInfo.gpu.memoryUtilization * 100), ...
                        'Reduza batch size ou use mixed precision');
                end
                
                % Verificar uso de CPU
                if resourceInfo.cpu.utilization > obj.alertThresholds.cpuUsage
                    obj.generateAlert('warning', 'cpu', ...
                        sprintf('CPU sobrecarregada: %.1f%%', resourceInfo.cpu.utilization * 100), ...
                        'Considere reduzir workers paralelos');
                end
                
                % Verificar tempo de execução se há sessão ativa
                if obj.monitoringSession.active
                    sessionDuration = (currentTime - obj.monitoringSession.startTime) * 24 * 3600;
                    if sessionDuration > obj.alertThresholds.executionTime
                        obj.generateAlert('warning', 'execution_time', ...
                            sprintf('Execução longa: %.1f minutos', sessionDuration / 60), ...
                            'Verifique se o processo não travou');
                    end
                end
                
            catch ME
                warning('SystemMonitor:CheckHealth', ...
                    'Erro ao verificar saúde do sistema: %s', ME.message);
            end
        end
        
        function report = generatePerformanceReport(obj)
            % Gera relatório completo de performance
            %
            % SAÍDA:
            %   report - String com relatório formatado
            %
            % REQUISITOS: 7.4 (relatórios de performance com recomendações)
            
            report = '';
            
            try
                report = sprintf('🔍 RELATÓRIO DE PERFORMANCE DO SISTEMA\n');
                report = [report sprintf('==========================================\n\n')];
                
                % Informações da sessão
                if isfield(obj.monitoringSession, 'name')
                    report = [report sprintf('Sessão: %s\n', obj.monitoringSession.name)];
                    if obj.monitoringSession.active
                        duration = (now - obj.monitoringSession.startTime) * 24 * 3600;
                        report = [report sprintf('Duração: %.1f segundos (em andamento)\n', duration)];
                    else
                        duration = obj.monitoringSession.duration * 24 * 3600;
                        report = [report sprintf('Duração: %.1f segundos (finalizada)\n', duration)];
                    end
                    report = [report sprintf('\n')];
                end
                
                % Recursos do sistema
                resourceInfo = obj.resourceMonitor.getResourceInfo();
                report = [report sprintf('RECURSOS DO SISTEMA\n')];
                report = [report sprintf('-------------------\n')];
                report = [report sprintf('Memória: %.1f GB / %.1f GB (%.1f%% utilizada)\n', ...
                    resourceInfo.memory.usedGB, resourceInfo.memory.totalGB, resourceInfo.memory.utilizationPercent)];
                report = [report sprintf('CPU: %d cores (%.1f%% utilização)\n', ...
                    resourceInfo.cpu.numCores, resourceInfo.cpu.utilization * 100)];
                
                if resourceInfo.gpu.available
                    report = [report sprintf('GPU: %s (%.1f GB, %.1f%% utilizada)\n', ...
                        resourceInfo.gpu.name, resourceInfo.gpu.memoryGB, resourceInfo.gpu.utilization * 100)];
                else
                    report = [report sprintf('GPU: Não disponível\n')];
                end
                report = [report sprintf('\n')];
                
                % Gargalos de performance
                bottlenecks = obj.performanceProfiler.identifyBottlenecks();
                if ~isempty(bottlenecks)
                    report = [report sprintf('GARGALOS IDENTIFICADOS\n')];
                    report = [report sprintf('----------------------\n')];
                    for i = 1:min(5, length(bottlenecks))  % Top 5
                        bottleneck = bottlenecks{i};
                        report = [report sprintf('%d. %s (%s)\n', i, bottleneck.function, bottleneck.type)];
                        if strcmp(bottleneck.type, 'time_bottleneck')
                            report = [report sprintf('   Tempo: %.2f s (%.1f%% do total)\n', ...
                                bottleneck.totalTime, bottleneck.timePercentage)];
                        end
                        report = [report sprintf('   Severidade: %s\n', obj.getSeverityText(bottleneck.severity))];
                    end
                    report = [report sprintf('\n')];
                end
                
                % Alertas ativos
                if ~isempty(obj.alerts)
                    report = [report sprintf('ALERTAS ATIVOS\n')];
                    report = [report sprintf('--------------\n')];
                    recentAlerts = obj.getRecentAlerts(10);  % Últimos 10 alertas
                    for i = 1:length(recentAlerts)
                        alert = recentAlerts{i};
                        report = [report sprintf('[%s] %s: %s\n', ...
                            upper(alert.level), upper(alert.type), alert.message)];
                    end
                    report = [report sprintf('\n')];
                end
                
                % Recomendações
                recommendations = obj.generateSystemRecommendations();
                if ~isempty(recommendations)
                    report = [report sprintf('RECOMENDAÇÕES\n')];
                    report = [report sprintf('-------------\n')];
                    for i = 1:length(recommendations)
                        report = [report sprintf('• %s\n', recommendations{i})];
                    end
                end
                
            catch ME
                report = sprintf('Erro ao gerar relatório: %s\n', ME.message);
            end
        end
        
        function savePerformanceReport(obj, filename)
            % Salva relatório de performance em arquivo
            %
            % ENTRADA:
            %   filename - Nome do arquivo (opcional)
            
            if nargin < 2
                timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                filename = sprintf('output/reports/system_performance_%s.txt', timestamp);
            end
            
            try
                % Criar diretório se não existir
                [filepath, ~, ~] = fileparts(filename);
                if ~exist(filepath, 'dir')
                    mkdir(filepath);
                end
                
                % Gerar e salvar relatório
                report = obj.generatePerformanceReport();
                
                fid = fopen(filename, 'w');
                if fid == -1
                    error('Não foi possível criar arquivo: %s', filename);
                end
                
                fprintf(fid, '%s', report);
                fclose(fid);
                
                fprintf('📊 Relatório de performance salvo: %s\n', filename);
                
            catch ME
                error('SystemMonitor:SaveReport', ...
                    'Erro ao salvar relatório: %s', ME.message);
            end
        end
        
        function stats = getMonitoringStats(obj)
            % Retorna estatísticas de monitoramento
            %
            % SAÍDA:
            %   stats - Estrutura com estatísticas
            
            stats = struct();
            
            try
                % Estatísticas da sessão
                stats.session = obj.monitoringSession;
                
                % Estatísticas de recursos
                stats.resources = obj.resourceMonitor.getResourceInfo();
                
                % Estatísticas de performance
                stats.performance = obj.performanceProfiler.getProfilingStats();
                
                % Estatísticas de alertas
                stats.alerts = struct();
                stats.alerts.total = length(obj.alerts);
                stats.alerts.recent = length(obj.getRecentAlerts(60));  % Últimos 60 minutos
                
                if ~isempty(obj.alerts)
                    levels = cellfun(@(x) x.level, obj.alerts, 'UniformOutput', false);
                    stats.alerts.byLevel = struct();
                    for level = obj.ALERT_LEVELS
                        stats.alerts.byLevel.(level{1}) = sum(strcmp(levels, level{1}));
                    end
                end
                
            catch ME
                warning('SystemMonitor:GetStats', ...
                    'Erro ao obter estatísticas: %s', ME.message);
                stats = struct('error', ME.message);
            end
        end
        
        function cleanup(obj)
            % Limpa recursos de monitoramento
            
            try
                % Parar monitoramento se ativo
                if isfield(obj.monitoringSession, 'active') && obj.monitoringSession.active
                    obj.stopSystemMonitoring();
                end
                
                % Limpar componentes
                if ~isempty(obj.resourceMonitor)
                    obj.resourceMonitor.cleanup();
                end
                
                if ~isempty(obj.performanceProfiler)
                    obj.performanceProfiler.cleanup();
                end
                
                % Limpar dados
                obj.alerts = {};
                obj.monitoringSession = struct();
                
                fprintf('🧹 SystemMonitor limpo\n');
                
            catch ME
                warning('SystemMonitor:Cleanup', ...
                    'Erro na limpeza: %s', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function initializeMonitoring(obj)
            % Inicializa componentes de monitoramento
            
            try
                % Inicializar ResourceMonitor
                obj.resourceMonitor = ResourceMonitor('EnableMonitoring', obj.monitoringEnabled);
                
                % Inicializar PerformanceProfiler
                obj.performanceProfiler = PerformanceProfiler(...
                    'EnableProfiling', obj.monitoringEnabled, ...
                    'ResourceMonitor', obj.resourceMonitor);
                
                % Inicializar estruturas
                obj.alerts = {};
                obj.monitoringSession = struct();
                
            catch ME
                warning('SystemMonitor:Initialize', ...
                    'Erro ao inicializar monitoramento: %s', ME.message);
            end
        end
        
        function startMonitoring(obj)
            % Inicia monitoramento básico
            
            try
                fprintf('📊 SystemMonitor inicializado\n');
                
                % Verificar saúde inicial do sistema
                obj.checkSystemHealth();
                
            catch ME
                warning('SystemMonitor:StartMonitoring', ...
                    'Erro ao iniciar monitoramento: %s', ME.message);
            end
        end
        
        function collectBaseline(obj)
            % Coleta baseline inicial do sistema
            
            try
                baseline = struct();
                baseline.timestamp = now;
                baseline.resources = obj.resourceMonitor.getResourceInfo();
                baseline.performance = obj.performanceProfiler.getProfilingStats();
                
                obj.monitoringSession.baseline = baseline;
                
            catch ME
                warning('SystemMonitor:CollectBaseline', ...
                    'Erro ao coletar baseline: %s', ME.message);
            end
        end
        
        function generateAlert(obj, level, type, message, recommendation)
            % Gera alerta do sistema
            
            try
                alert = struct();
                alert.timestamp = now;
                alert.level = level;
                alert.type = type;
                alert.message = message;
                alert.recommendation = recommendation;
                alert.acknowledged = false;
                
                obj.alerts{end+1} = alert;
                
                % Exibir alerta
                levelIcon = obj.getAlertIcon(level);
                fprintf('%s [%s] %s: %s\n', levelIcon, upper(level), upper(type), message);
                
                if ~isempty(recommendation)
                    fprintf('   💡 Recomendação: %s\n', recommendation);
                end
                
            catch ME
                warning('SystemMonitor:GenerateAlert', ...
                    'Erro ao gerar alerta: %s', ME.message);
            end
        end
        
        function icon = getAlertIcon(obj, level)
            % Retorna ícone para nível de alerta
            
            switch level
                case 'critical'
                    icon = '🚨';
                case 'warning'
                    icon = '⚠️';
                case 'info'
                    icon = 'ℹ️';
                otherwise
                    icon = '📋';
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
        
        function recentAlerts = getRecentAlerts(obj, timeWindowMinutes)
            % Obtém alertas recentes
            
            recentAlerts = {};
            
            try
                if isempty(obj.alerts)
                    return;
                end
                
                currentTime = now;
                timeThreshold = currentTime - (timeWindowMinutes / (24 * 60));
                
                for i = 1:length(obj.alerts)
                    alert = obj.alerts{i};
                    if alert.timestamp >= timeThreshold
                        recentAlerts{end+1} = alert;
                    end
                end
                
            catch ME
                warning('SystemMonitor:GetRecentAlerts', ...
                    'Erro ao obter alertas recentes: %s', ME.message);
            end
        end
        
        function recommendations = generateSystemRecommendations(obj)
            % Gera recomendações baseadas no estado do sistema
            
            recommendations = {};
            
            try
                % Obter recomendações dos componentes
                resourceRecommendations = obj.resourceMonitor.generateOptimizationRecommendations();
                performanceRecommendations = obj.performanceProfiler.generateBottleneckReport();
                
                % Processar recomendações de recursos
                for i = 1:length(resourceRecommendations)
                    rec = resourceRecommendations{i};
                    recommendations{end+1} = sprintf('[%s] %s', upper(rec.type), rec.message);
                end
                
                % Adicionar recomendações baseadas em alertas
                criticalAlerts = 0;
                warningAlerts = 0;
                
                recentAlerts = obj.getRecentAlerts(60);  % Últimos 60 minutos
                for i = 1:length(recentAlerts)
                    alert = recentAlerts{i};
                    if strcmp(alert.level, 'critical')
                        criticalAlerts = criticalAlerts + 1;
                    elseif strcmp(alert.level, 'warning')
                        warningAlerts = warningAlerts + 1;
                    end
                end
                
                if criticalAlerts > 0
                    recommendations{end+1} = sprintf('Atenção: %d alertas críticos nas últimas horas. Verifique recursos do sistema.', criticalAlerts);
                end
                
                if warningAlerts > 5
                    recommendations{end+1} = sprintf('Múltiplos avisos (%d) detectados. Considere otimização preventiva.', warningAlerts);
                end
                
            catch ME
                warning('SystemMonitor:GenerateRecommendations', ...
                    'Erro ao gerar recomendações: %s', ME.message);
            end
        end
        
        function scheduleAutoReports(obj)
            % Agenda relatórios automáticos
            
            try
                if exist('timer', 'class')
                    reportTimer = timer(...
                        'ExecutionMode', 'fixedRate', ...
                        'Period', obj.reportInterval, ...
                        'TimerFcn', @(~,~) obj.generateAutoReport());
                    
                    start(reportTimer);
                    
                    fprintf('📊 Relatórios automáticos agendados (intervalo: %d s)\n', obj.reportInterval);
                else
                    warning('SystemMonitor:NoTimer', 'Timer não disponível para relatórios automáticos');
                end
                
            catch ME
                warning('SystemMonitor:ScheduleReports', ...
                    'Erro ao agendar relatórios: %s', ME.message);
            end
        end
        
        function generateAutoReport(obj)
            % Gera relatório automático
            
            try
                % Verificar saúde do sistema
                obj.checkSystemHealth();
                
                % Gerar relatório se há alertas críticos
                recentCritical = obj.getRecentAlerts(obj.reportInterval / 60);
                criticalCount = sum(cellfun(@(x) strcmp(x.level, 'critical'), recentCritical));
                
                if criticalCount > 0
                    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
                    filename = sprintf('output/reports/auto_report_%s.txt', timestamp);
                    obj.savePerformanceReport(filename);
                    
                    fprintf('🚨 Relatório automático gerado devido a alertas críticos: %s\n', filename);
                end
                
            catch ME
                warning('SystemMonitor:AutoReport', ...
                    'Erro no relatório automático: %s', ME.message);
            end
        end
        
        function generateFinalReport(obj)
            % Gera relatório final da sessão
            
            try
                if ~isfield(obj.monitoringSession, 'name')
                    return;
                end
                
                filename = sprintf('output/reports/final_report_%s.txt', obj.monitoringSession.name);
                obj.savePerformanceReport(filename);
                
                % Salvar também relatório de gargalos
                bottleneckFilename = sprintf('output/reports/bottlenecks_%s.txt', obj.monitoringSession.name);
                obj.performanceProfiler.saveBottleneckReport(bottleneckFilename);
                
                fprintf('📊 Relatórios finais gerados:\n');
                fprintf('   - Performance: %s\n', filename);
                fprintf('   - Gargalos: %s\n', bottleneckFilename);
                
            catch ME
                warning('SystemMonitor:FinalReport', ...
                    'Erro ao gerar relatório final: %s', ME.message);
            end
        end
    end
end