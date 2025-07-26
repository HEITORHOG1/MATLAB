classdef TimeEstimator < handle
    % ========================================================================
    % TIMEESTIMATOR - ESTIMADOR DE TEMPO PARA OPERAÇÕES LONGAS
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe para estimar tempo restante em operações longas como
    %   treinamento de modelos, baseado em histórico de performance.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - MATLAB Fundamentals
    %   - Statistics and Machine Learning Toolbox
    %
    % USO:
    %   >> estimator = TimeEstimator('Treinamento', 100);
    %   >> estimator.update(10); % 10% completo
    %   >> eta = estimator.getETA();
    %
    % REQUISITOS: 2.4 (estimativas de tempo restante para treinamento)
    % ========================================================================
    
    properties (Access = private)
        operationName
        totalSteps
        currentStep = 0
        startTime
        
        % Histórico de progresso
        progressHistory = []
        timeHistory = []
        
        % Configurações de estimativa
        windowSize = 10 % Número de amostras para média móvel
        minSamplesForEstimate = 3
        
        % Métodos de estimativa
        estimationMethod = 'adaptive' % 'linear', 'exponential', 'adaptive'
        
        % Pesos para média ponderada
        recentWeight = 0.7
        historicalWeight = 0.3
        
        % Cache de estimativas
        lastEstimate = 0
        lastEstimateTime = 0
        estimateValidityPeriod = 5 % segundos
        
        % Estatísticas
        stats = struct()
    end
    
    properties (Constant)
        ESTIMATION_METHODS = {'linear', 'exponential', 'adaptive', 'polynomial'}
    end
    
    methods
        function obj = TimeEstimator(operationName, totalSteps, varargin)
            % Construtor do estimador de tempo
            %
            % ENTRADA:
            %   operationName - nome da operação
            %   totalSteps - número total de passos
            %   varargin - parâmetros opcionais:
            %     'EstimationMethod' - método de estimativa (padrão: 'adaptive')
            %     'WindowSize' - tamanho da janela para média móvel (padrão: 10)
            %     'MinSamplesForEstimate' - mínimo de amostras para estimar (padrão: 3)
            
            if nargin < 2
                error('TimeEstimator:InvalidInput', 'Nome da operação e total de passos são obrigatórios');
            end
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'EstimationMethod', 'adaptive', @(x) ismember(x, obj.ESTIMATION_METHODS));
            addParameter(p, 'WindowSize', 10, @isnumeric);
            addParameter(p, 'MinSamplesForEstimate', 3, @isnumeric);
            parse(p, varargin{:});
            
            obj.operationName = operationName;
            obj.totalSteps = totalSteps;
            obj.estimationMethod = p.Results.EstimationMethod;
            obj.windowSize = p.Results.WindowSize;
            obj.minSamplesForEstimate = p.Results.MinSamplesForEstimate;
            
            obj.startTime = tic;
            
            % Inicializar estatísticas
            obj.initializeStats();
        end
        
        function update(obj, step, varargin)
            % Atualiza o progresso atual
            %
            % ENTRADA:
            %   step - passo atual (ou incremento se 'Increment' = true)
            %   varargin - parâmetros opcionais:
            %     'Increment' - se true, step é incremento (padrão: false)
            %     'Force' - forçar atualização mesmo se muito recente (padrão: false)
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Increment', false, @islogical);
            addParameter(p, 'Force', false, @islogical);
            parse(p, varargin{:});
            
            % Atualizar passo atual
            if p.Results.Increment
                obj.currentStep = obj.currentStep + step;
            else
                obj.currentStep = step;
            end
            
            % Limitar ao máximo
            obj.currentStep = min(obj.currentStep, obj.totalSteps);
            
            % Registrar progresso
            currentTime = toc(obj.startTime);
            
            % Verificar se deve registrar (evitar spam de atualizações)
            if ~p.Results.Force && ~isempty(obj.timeHistory)
                if (currentTime - obj.timeHistory(end)) < 1 % Mínimo 1 segundo entre registros
                    return;
                end
            end
            
            obj.progressHistory(end+1) = obj.currentStep;
            obj.timeHistory(end+1) = currentTime;
            
            % Limitar tamanho do histórico
            if length(obj.progressHistory) > obj.windowSize * 2
                keepIndices = (end - obj.windowSize + 1):end;
                obj.progressHistory = obj.progressHistory(keepIndices);
                obj.timeHistory = obj.timeHistory(keepIndices);
            end
            
            % Atualizar estatísticas
            obj.updateStats();
        end
        
        function eta = getETA(obj, varargin)
            % Obtém estimativa de tempo restante
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'Method' - método específico para esta estimativa
            %     'UseCache' - usar cache se disponível (padrão: true)
            %
            % SAÍDA:
            %   eta - tempo estimado restante em segundos
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Method', obj.estimationMethod, @(x) ismember(x, obj.ESTIMATION_METHODS));
            addParameter(p, 'UseCache', true, @islogical);
            parse(p, varargin{:});
            
            % Verificar cache
            currentTime = toc(obj.startTime);
            if p.Results.UseCache && (currentTime - obj.lastEstimateTime) < obj.estimateValidityPeriod
                eta = obj.lastEstimate;
                return;
            end
            
            % Verificar se há dados suficientes
            if length(obj.progressHistory) < obj.minSamplesForEstimate
                eta = NaN;
                return;
            end
            
            % Calcular estimativa baseada no método
            switch p.Results.Method
                case 'linear'
                    eta = obj.estimateLinear();
                case 'exponential'
                    eta = obj.estimateExponential();
                case 'adaptive'
                    eta = obj.estimateAdaptive();
                case 'polynomial'
                    eta = obj.estimatePolynomial();
                otherwise
                    eta = obj.estimateLinear();
            end
            
            % Atualizar cache
            obj.lastEstimate = eta;
            obj.lastEstimateTime = currentTime;
            
            % Atualizar estatísticas
            obj.stats.lastETA = eta;
            obj.stats.estimationCount = obj.stats.estimationCount + 1;
        end
        
        function speed = getCurrentSpeed(obj)
            % Obtém velocidade atual (passos por segundo)
            %
            % SAÍDA:
            %   speed - velocidade atual em passos/segundo
            
            if length(obj.progressHistory) < 2
                speed = 0;
                return;
            end
            
            % Usar últimas amostras para calcular velocidade
            windowStart = max(1, length(obj.progressHistory) - min(5, obj.windowSize) + 1);
            
            recentProgress = obj.progressHistory(windowStart:end);
            recentTime = obj.timeHistory(windowStart:end);
            
            if length(recentProgress) < 2
                speed = 0;
                return;
            end
            
            % Calcular velocidade média das amostras recentes
            progressDiff = recentProgress(end) - recentProgress(1);
            timeDiff = recentTime(end) - recentTime(1);
            
            if timeDiff > 0
                speed = progressDiff / timeDiff;
            else
                speed = 0;
            end
        end
        
        function avgSpeed = getAverageSpeed(obj)
            % Obtém velocidade média desde o início
            %
            % SAÍDA:
            %   avgSpeed - velocidade média em passos/segundo
            
            if isempty(obj.progressHistory)
                avgSpeed = 0;
                return;
            end
            
            totalTime = toc(obj.startTime);
            if totalTime > 0
                avgSpeed = obj.currentStep / totalTime;
            else
                avgSpeed = 0;
            end
        end
        
        function percentage = getPercentage(obj)
            % Obtém porcentagem de conclusão
            %
            % SAÍDA:
            %   percentage - porcentagem completa (0-100)
            
            percentage = (obj.currentStep / obj.totalSteps) * 100;
        end
        
        function elapsed = getElapsedTime(obj)
            % Obtém tempo decorrido
            %
            % SAÍDA:
            %   elapsed - tempo decorrido em segundos
            
            elapsed = toc(obj.startTime);
        end
        
        function total = getEstimatedTotalTime(obj)
            % Obtém estimativa de tempo total
            %
            % SAÍDA:
            %   total - tempo total estimado em segundos
            
            eta = obj.getETA();
            if ~isnan(eta)
                total = obj.getElapsedTime() + eta;
            else
                total = NaN;
            end
        end
        
        function summary = getSummary(obj)
            % Obtém resumo completo do progresso
            %
            % SAÍDA:
            %   summary - estrutura com informações de progresso
            
            summary = struct();
            summary.operationName = obj.operationName;
            summary.currentStep = obj.currentStep;
            summary.totalSteps = obj.totalSteps;
            summary.percentage = obj.getPercentage();
            summary.elapsedTime = obj.getElapsedTime();
            summary.eta = obj.getETA();
            summary.estimatedTotalTime = obj.getEstimatedTotalTime();
            summary.currentSpeed = obj.getCurrentSpeed();
            summary.averageSpeed = obj.getAverageSpeed();
            summary.isComplete = obj.currentStep >= obj.totalSteps;
            
            % Formatação amigável
            summary.elapsedTimeFormatted = obj.formatTime(summary.elapsedTime);
            summary.etaFormatted = obj.formatTime(summary.eta);
            summary.estimatedTotalTimeFormatted = obj.formatTime(summary.estimatedTotalTime);
        end
        
        function str = getFormattedSummary(obj)
            % Obtém resumo formatado como string
            %
            % SAÍDA:
            %   str - string formatada com resumo
            
            summary = obj.getSummary();
            
            str = sprintf(['%s: %.1f%% (%d/%d)\n' ...
                          'Tempo decorrido: %s\n' ...
                          'ETA: %s\n' ...
                          'Velocidade: %.2f/s (média: %.2f/s)'], ...
                          summary.operationName, summary.percentage, ...
                          summary.currentStep, summary.totalSteps, ...
                          summary.elapsedTimeFormatted, ...
                          summary.etaFormatted, ...
                          summary.currentSpeed, summary.averageSpeed);
        end
        
        function reset(obj)
            % Reinicia o estimador
            
            obj.currentStep = 0;
            obj.progressHistory = [];
            obj.timeHistory = [];
            obj.startTime = tic;
            obj.lastEstimate = 0;
            obj.lastEstimateTime = 0;
            obj.initializeStats();
        end
        
        function setEstimationMethod(obj, method)
            % Define método de estimativa
            %
            % ENTRADA:
            %   method - método de estimativa
            
            if ismember(method, obj.ESTIMATION_METHODS)
                obj.estimationMethod = method;
            else
                warning('TimeEstimator:InvalidMethod', 'Método inválido: %s', method);
            end
        end
    end
    
    methods (Access = private)
        function initializeStats(obj)
            % Inicializa estatísticas
            
            obj.stats = struct();
            obj.stats.startTime = now;
            obj.stats.estimationCount = 0;
            obj.stats.lastETA = NaN;
            obj.stats.method = obj.estimationMethod;
        end
        
        function updateStats(obj)
            % Atualiza estatísticas
            
            obj.stats.lastUpdate = now;
            obj.stats.currentStep = obj.currentStep;
            obj.stats.percentage = obj.getPercentage();
            obj.stats.elapsedTime = obj.getElapsedTime();
            obj.stats.currentSpeed = obj.getCurrentSpeed();
            obj.stats.averageSpeed = obj.getAverageSpeed();
        end
        
        function eta = estimateLinear(obj)
            % Estimativa linear baseada na velocidade média
            
            avgSpeed = obj.getAverageSpeed();
            if avgSpeed > 0
                remainingSteps = obj.totalSteps - obj.currentStep;
                eta = remainingSteps / avgSpeed;
            else
                eta = NaN;
            end
        end
        
        function eta = estimateExponential(obj)
            % Estimativa exponencial dando mais peso às amostras recentes
            
            if length(obj.progressHistory) < 2
                eta = NaN;
                return;
            end
            
            % Calcular velocidades com pesos exponenciais
            weights = exp(-(length(obj.progressHistory)-1:-1:0) / 3); % Decay factor = 3
            weights = weights / sum(weights);
            
            speeds = [];
            for i = 2:length(obj.progressHistory)
                progressDiff = obj.progressHistory(i) - obj.progressHistory(i-1);
                timeDiff = obj.timeHistory(i) - obj.timeHistory(i-1);
                if timeDiff > 0
                    speeds(end+1) = progressDiff / timeDiff;
                end
            end
            
            if ~isempty(speeds)
                % Aplicar pesos às velocidades
                if length(speeds) == length(weights) - 1
                    weightedSpeed = sum(speeds .* weights(2:end));
                else
                    weightedSpeed = mean(speeds);
                end
                
                if weightedSpeed > 0
                    remainingSteps = obj.totalSteps - obj.currentStep;
                    eta = remainingSteps / weightedSpeed;
                else
                    eta = NaN;
                end
            else
                eta = NaN;
            end
        end
        
        function eta = estimateAdaptive(obj)
            % Estimativa adaptiva combinando múltodos métodos
            
            % Obter estimativas de diferentes métodos
            etaLinear = obj.estimateLinear();
            etaExponential = obj.estimateExponential();
            
            % Combinar estimativas com pesos adaptativos
            if ~isnan(etaLinear) && ~isnan(etaExponential)
                % Dar mais peso ao método exponencial se há variação na velocidade
                speedVariation = obj.calculateSpeedVariation();
                
                if speedVariation > 0.2 % Alta variação
                    eta = obj.recentWeight * etaExponential + obj.historicalWeight * etaLinear;
                else % Baixa variação
                    eta = obj.historicalWeight * etaExponential + obj.recentWeight * etaLinear;
                end
            elseif ~isnan(etaLinear)
                eta = etaLinear;
            elseif ~isnan(etaExponential)
                eta = etaExponential;
            else
                eta = NaN;
            end
        end
        
        function eta = estimatePolynomial(obj)
            % Estimativa polinomial (quadrática) para capturar aceleração/desaceleração
            
            if length(obj.progressHistory) < 4
                eta = obj.estimateLinear();
                return;
            end
            
            try
                % Ajustar polinômio de grau 2 aos dados
                x = obj.timeHistory(:);
                y = obj.progressHistory(:);
                
                % Usar apenas amostras recentes para melhor precisão
                windowStart = max(1, length(x) - obj.windowSize + 1);
                x = x(windowStart:end);
                y = y(windowStart:end);
                
                if length(x) >= 3
                    % Ajustar polinômio
                    p = polyfit(x, y, min(2, length(x)-1));
                    
                    % Predizer progresso futuro
                    currentTime = obj.timeHistory(end);
                    
                    % Encontrar tempo quando progresso = totalSteps
                    % Resolver: p(1)*t^2 + p(2)*t + p(3) = totalSteps
                    if length(p) == 3 % Quadrático
                        a = p(1);
                        b = p(2);
                        c = p(3) - obj.totalSteps;
                        
                        discriminant = b^2 - 4*a*c;
                        if discriminant >= 0 && a ~= 0
                            t1 = (-b + sqrt(discriminant)) / (2*a);
                            t2 = (-b - sqrt(discriminant)) / (2*a);
                            
                            % Escolher solução positiva e maior que tempo atual
                            solutions = [t1, t2];
                            validSolutions = solutions(solutions > currentTime);
                            
                            if ~isempty(validSolutions)
                                eta = min(validSolutions) - currentTime;
                            else
                                eta = obj.estimateLinear();
                            end
                        else
                            eta = obj.estimateLinear();
                        end
                    else % Linear
                        if p(1) ~= 0
                            targetTime = (obj.totalSteps - p(2)) / p(1);
                            eta = max(0, targetTime - currentTime);
                        else
                            eta = obj.estimateLinear();
                        end
                    end
                else
                    eta = obj.estimateLinear();
                end
                
            catch
                % Fallback para estimativa linear em caso de erro
                eta = obj.estimateLinear();
            end
        end
        
        function variation = calculateSpeedVariation(obj)
            % Calcula variação na velocidade para estimativa adaptiva
            
            if length(obj.progressHistory) < 3
                variation = 0;
                return;
            end
            
            speeds = [];
            for i = 2:length(obj.progressHistory)
                progressDiff = obj.progressHistory(i) - obj.progressHistory(i-1);
                timeDiff = obj.timeHistory(i) - obj.timeHistory(i-1);
                if timeDiff > 0
                    speeds(end+1) = progressDiff / timeDiff;
                end
            end
            
            if length(speeds) > 1
                variation = std(speeds) / mean(speeds);
            else
                variation = 0;
            end
        end
        
        function timeStr = formatTime(obj, seconds)
            % Formata tempo em string legível
            %
            % ENTRADA:
            %   seconds - tempo em segundos
            %
            % SAÍDA:
            %   timeStr - string formatada
            
            if isnan(seconds) || seconds < 0
                timeStr = 'N/A';
                return;
            end
            
            if seconds < 60
                timeStr = sprintf('%.0fs', seconds);
            elseif seconds < 3600
                minutes = floor(seconds / 60);
                secs = mod(seconds, 60);
                timeStr = sprintf('%dm%.0fs', minutes, secs);
            elseif seconds < 86400 % 24 horas
                hours = floor(seconds / 3600);
                minutes = floor(mod(seconds, 3600) / 60);
                secs = mod(seconds, 60);
                timeStr = sprintf('%dh%dm%.0fs', hours, minutes, secs);
            else
                days = floor(seconds / 86400);
                hours = floor(mod(seconds, 86400) / 3600);
                timeStr = sprintf('%dd%dh', days, hours);
            end
        end
    end
    
    methods (Static)
        function demo()
            % Demonstração do estimador de tempo
            
            fprintf('Demonstração do TimeEstimator:\n\n');
            
            % Simular operação com velocidade variável
            estimator = TimeEstimator('Simulação', 100, 'EstimationMethod', 'adaptive');
            
            for i = 1:100
                % Simular velocidade variável
                if i < 20
                    delay = 0.1; % Início lento
                elseif i < 80
                    delay = 0.05; % Meio rápido
                else
                    delay = 0.08; % Final médio
                end
                
                pause(delay);
                estimator.update(i);
                
                % Mostrar progresso a cada 10 passos
                if mod(i, 10) == 0
                    summary = estimator.getSummary();
                    fprintf('Passo %d: %.1f%% - ETA: %s - Velocidade: %.2f/s\n', ...
                        i, summary.percentage, summary.etaFormatted, summary.currentSpeed);
                end
            end
            
            % Resumo final
            fprintf('\n%s\n', estimator.getFormattedSummary());
            fprintf('\nDemonstração concluída!\n');
        end
    end
end