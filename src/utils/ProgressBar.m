classdef ProgressBar < handle
    % ========================================================================
    % PROGRESSBAR - BARRA DE PROGRESSO VISUAL PARA MATLAB
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Classe para exibir barras de progresso visuais com estimativas de
    %   tempo restante e feedback colorido.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - MATLAB Fundamentals
    %   - Object-Oriented Programming
    %
    % USO:
    %   >> pb = ProgressBar('Treinando modelo', 100);
    %   >> pb.update(50); % 50% completo
    %   >> pb.finish();
    %
    % REQUISITOS: 2.4 (feedback visual aprimorado)
    % ========================================================================
    
    properties (Access = private)
        title
        totalSteps
        currentStep = 0
        startTime
        lastUpdateTime
        
        % Configurações visuais
        barWidth = 50
        enableColors = true
        enableTimeEstimate = true
        enablePercentage = true
        
        % Caracteres da barra
        filledChar = '█'
        emptyChar = '░'
        
        % Cores
        colors = struct(...
            'RESET', '\033[0m', ...
            'GREEN', '\033[32m', ...
            'YELLOW', '\033[33m', ...
            'BLUE', '\033[34m', ...
            'RED', '\033[31m', ...
            'CYAN', '\033[36m')
        
        % Estado
        isFinished = false
        isCancelled = false
        
        % Histórico de performance
        updateHistory = []
        
        % Configurações de display
        showETA = true
        showSpeed = true
        showElapsed = true
        refreshRate = 0.1 % segundos
    end
    
    methods
        function obj = ProgressBar(title, totalSteps, varargin)
            % Construtor da barra de progresso
            %
            % ENTRADA:
            %   title - título da operação
            %   totalSteps - número total de passos
            %   varargin - parâmetros opcionais:
            %     'BarWidth' - largura da barra (padrão: 50)
            %     'EnableColors' - habilitar cores (padrão: true)
            %     'EnableTimeEstimate' - habilitar estimativa de tempo (padrão: true)
            %     'ShowETA' - mostrar tempo estimado (padrão: true)
            %     'ShowSpeed' - mostrar velocidade (padrão: true)
            
            if nargin < 2
                error('ProgressBar:InvalidInput', 'Título e número total de passos são obrigatórios');
            end
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'BarWidth', 50, @isnumeric);
            addParameter(p, 'EnableColors', true, @islogical);
            addParameter(p, 'EnableTimeEstimate', true, @islogical);
            addParameter(p, 'ShowETA', true, @islogical);
            addParameter(p, 'ShowSpeed', true, @islogical);
            parse(p, varargin{:});
            
            obj.title = title;
            obj.totalSteps = totalSteps;
            obj.barWidth = p.Results.BarWidth;
            obj.enableColors = p.Results.EnableColors;
            obj.enableTimeEstimate = p.Results.EnableTimeEstimate;
            obj.showETA = p.Results.ShowETA;
            obj.showSpeed = p.Results.ShowSpeed;
            
            obj.startTime = tic;
            obj.lastUpdateTime = obj.startTime;
            
            % Inicializar display
            obj.initializeDisplay();
        end
        
        function update(obj, step, varargin)
            % Atualiza a barra de progresso
            %
            % ENTRADA:
            %   step - passo atual (ou incremento se 'Increment' = true)
            %   varargin - parâmetros opcionais:
            %     'Increment' - se true, step é incremento (padrão: false)
            %     'Message' - mensagem adicional
            %     'Force' - forçar atualização mesmo se muito recente (padrão: false)
            
            if obj.isFinished || obj.isCancelled
                return;
            end
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Increment', false, @islogical);
            addParameter(p, 'Message', '', @ischar);
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
            
            % Verificar se deve atualizar (rate limiting)
            currentTime = toc(obj.startTime);
            if ~p.Results.Force && (currentTime - toc(obj.lastUpdateTime)) < obj.refreshRate
                return;
            end
            
            % Registrar histórico
            obj.updateHistory(end+1) = struct(...
                'step', obj.currentStep, ...
                'time', currentTime, ...
                'message', p.Results.Message);
            
            % Atualizar display
            obj.updateDisplay(p.Results.Message);
            
            obj.lastUpdateTime = tic;
        end
        
        function increment(obj, varargin)
            % Incrementa a barra de progresso em 1
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais (mesmo que update)
            
            obj.update(1, 'Increment', true, varargin{:});
        end
        
        function finish(obj, varargin)
            % Finaliza a barra de progresso
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'Message' - mensagem final
            %     'Success' - se operação foi bem-sucedida (padrão: true)
            
            if obj.isFinished
                return;
            end
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Message', 'Concluído', @ischar);
            addParameter(p, 'Success', true, @islogical);
            parse(p, varargin{:});
            
            obj.currentStep = obj.totalSteps;
            obj.isFinished = true;
            
            % Display final
            obj.updateDisplay(p.Results.Message, p.Results.Success);
            fprintf('\n');
        end
        
        function cancel(obj, message)
            % Cancela a operação
            %
            % ENTRADA:
            %   message - mensagem de cancelamento (opcional)
            
            if nargin < 2
                message = 'Cancelado';
            end
            
            obj.isCancelled = true;
            obj.updateDisplay(message, false);
            fprintf('\n');
        end
        
        function setTitle(obj, newTitle)
            % Altera o título da barra
            
            obj.title = newTitle;
            obj.updateDisplay('', true, true); % Force refresh
        end
        
        function stats = getStats(obj)
            % Retorna estatísticas da operação
            %
            % SAÍDA:
            %   stats - estrutura com estatísticas
            
            elapsedTime = toc(obj.startTime);
            
            stats = struct();
            stats.currentStep = obj.currentStep;
            stats.totalSteps = obj.totalSteps;
            stats.percentage = (obj.currentStep / obj.totalSteps) * 100;
            stats.elapsedTime = elapsedTime;
            stats.isFinished = obj.isFinished;
            stats.isCancelled = obj.isCancelled;
            
            if obj.currentStep > 0
                stats.avgTimePerStep = elapsedTime / obj.currentStep;
                stats.estimatedTotalTime = stats.avgTimePerStep * obj.totalSteps;
                stats.estimatedTimeRemaining = max(0, stats.estimatedTotalTime - elapsedTime);
                stats.speed = obj.currentStep / elapsedTime; % steps per second
            else
                stats.avgTimePerStep = 0;
                stats.estimatedTotalTime = 0;
                stats.estimatedTimeRemaining = 0;
                stats.speed = 0;
            end
        end
    end
    
    methods (Access = private)
        function initializeDisplay(obj)
            % Inicializa o display da barra
            
            fprintf('\n');
            obj.printColored(sprintf('🚀 %s\n', obj.title), 'CYAN');
            obj.updateDisplay('Iniciando...');
        end
        
        function updateDisplay(obj, message, success, forceRefresh)
            % Atualiza o display da barra
            %
            % ENTRADA:
            %   message - mensagem adicional
            %   success - se operação foi bem-sucedida
            %   forceRefresh - forçar refresh completo
            
            if nargin < 3
                success = true;
            end
            if nargin < 4
                forceRefresh = false;
            end
            
            % Calcular estatísticas
            stats = obj.getStats();
            
            % Construir barra visual
            barString = obj.buildProgressBar(stats.percentage);
            
            % Construir string de status
            statusString = obj.buildStatusString(stats, message, success);
            
            % Limpar linha anterior (se não for refresh completo)
            if ~forceRefresh
                fprintf('\r');
            end
            
            % Imprimir barra e status
            fprintf('%s %s', barString, statusString);
            
            % Flush output
            drawnow;
        end
        
        function barString = buildProgressBar(obj, percentage)
            % Constrói a string da barra de progresso
            %
            % ENTRADA:
            %   percentage - porcentagem completa
            %
            % SAÍDA:
            %   barString - string da barra formatada
            
            % Calcular número de caracteres preenchidos
            filledWidth = round((percentage / 100) * obj.barWidth);
            emptyWidth = obj.barWidth - filledWidth;
            
            % Construir barra
            filledPart = repmat(obj.filledChar, 1, filledWidth);
            emptyPart = repmat(obj.emptyChar, 1, emptyWidth);
            
            % Escolher cor baseada na porcentagem
            if percentage >= 100
                color = 'GREEN';
            elseif percentage >= 75
                color = 'CYAN';
            elseif percentage >= 50
                color = 'YELLOW';
            else
                color = 'BLUE';
            end
            
            % Formatear com cor
            if obj.enableColors
                barString = sprintf('%s[%s%s]%s', ...
                    obj.colors.(color), filledPart, emptyPart, obj.colors.RESET);
            else
                barString = sprintf('[%s%s]', filledPart, emptyPart);
            end
        end
        
        function statusString = buildStatusString(obj, stats, message, success)
            % Constrói string de status
            %
            % ENTRADA:
            %   stats - estatísticas atuais
            %   message - mensagem adicional
            %   success - se operação foi bem-sucedida
            %
            % SAÍDA:
            %   statusString - string de status formatada
            
            parts = {};
            
            % Porcentagem
            if obj.enablePercentage
                parts{end+1} = sprintf('%6.1f%%', stats.percentage);
            end
            
            % Progresso numérico
            parts{end+1} = sprintf('(%d/%d)', stats.currentStep, stats.totalSteps);
            
            % Tempo decorrido
            if obj.showElapsed
                parts{end+1} = sprintf('Tempo: %s', obj.formatTime(stats.elapsedTime));
            end
            
            % ETA
            if obj.showETA && obj.enableTimeEstimate && stats.estimatedTimeRemaining > 0 && ~obj.isFinished
                parts{end+1} = sprintf('ETA: %s', obj.formatTime(stats.estimatedTimeRemaining));
            end
            
            % Velocidade
            if obj.showSpeed && stats.speed > 0
                if stats.speed >= 1
                    parts{end+1} = sprintf('%.1f/s', stats.speed);
                else
                    parts{end+1} = sprintf('%.1fs/item', 1/stats.speed);
                end
            end
            
            % Mensagem
            if ~isempty(message)
                if obj.isFinished
                    if success
                        icon = '✅';
                        color = 'GREEN';
                    else
                        icon = '❌';
                        color = 'RED';
                    end
                    messageStr = sprintf('%s %s', icon, message);
                else
                    messageStr = message;
                    color = 'WHITE';
                end
                
                if obj.enableColors
                    parts{end+1} = sprintf('%s%s%s', obj.colors.(color), messageStr, obj.colors.RESET);
                else
                    parts{end+1} = messageStr;
                end
            end
            
            % Juntar todas as partes
            statusString = strjoin(parts, ' | ');
        end
        
        function timeStr = formatTime(obj, seconds)
            % Formata tempo em string legível
            %
            % ENTRADA:
            %   seconds - tempo em segundos
            %
            % SAÍDA:
            %   timeStr - string formatada
            
            if seconds < 60
                timeStr = sprintf('%.0fs', seconds);
            elseif seconds < 3600
                minutes = floor(seconds / 60);
                secs = mod(seconds, 60);
                timeStr = sprintf('%dm%.0fs', minutes, secs);
            else
                hours = floor(seconds / 3600);
                minutes = floor(mod(seconds, 3600) / 60);
                secs = mod(seconds, 60);
                timeStr = sprintf('%dh%dm%.0fs', hours, minutes, secs);
            end
        end
        
        function printColored(obj, text, color)
            % Imprime texto colorido
            %
            % ENTRADA:
            %   text - texto a ser impresso
            %   color - cor do texto
            
            if obj.enableColors && isfield(obj.colors, color)
                fprintf('%s%s%s', obj.colors.(color), text, obj.colors.RESET);
            else
                fprintf('%s', text);
            end
        end
    end
    
    methods (Static)
        function demo()
            % Demonstração da barra de progresso
            
            fprintf('Demonstração da ProgressBar:\n\n');
            
            % Exemplo 1: Operação simples
            pb1 = ProgressBar('Processando dados', 100);
            for i = 1:100
                pause(0.05);
                pb1.update(i, 'Message', sprintf('Item %d', i));
            end
            pb1.finish('Processamento concluído');
            
            pause(1);
            
            % Exemplo 2: Operação com incrementos
            pb2 = ProgressBar('Treinando modelo', 50, 'ShowSpeed', true);
            for i = 1:50
                pause(0.1);
                pb2.increment('Message', sprintf('Época %d', i));
            end
            pb2.finish('Treinamento concluído');
            
            pause(1);
            
            % Exemplo 3: Operação cancelada
            pb3 = ProgressBar('Operação longa', 200);
            for i = 1:100
                pause(0.02);
                pb3.update(i);
                if i == 50
                    pb3.cancel('Operação cancelada pelo usuário');
                    break;
                end
            end
            
            fprintf('\nDemonstração concluída!\n');
        end
    end
end