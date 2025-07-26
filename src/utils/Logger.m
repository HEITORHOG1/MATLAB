classdef Logger < handle
    % ========================================================================
    % LOGGER - SISTEMA DE LOGGING COLORIDO COM NÍVEIS
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Sistema de logging avançado com diferentes níveis de mensagem,
    %   cores, timestamps e salvamento em arquivo.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - MATLAB Fundamentals
    %   - File I/O
    %   - Object-Oriented Programming
    %
    % USO:
    %   >> logger = Logger('MyApp');
    %   >> logger.info('Informação importante');
    %   >> logger.error('Algo deu errado');
    %
    % REQUISITOS: 2.4 (sistema de logs coloridos com diferentes níveis)
    % ========================================================================
    
    properties (Access = private)
        name
        logFile
        enableColors = true
        enableTimestamp = true
        enableFileLogging = false
        minLevel = 1 % 1=DEBUG, 2=INFO, 3=WARNING, 4=ERROR, 5=CRITICAL
        
        % Configurações de formato
        timestampFormat = 'yyyy-mm-dd HH:MM:SS'
        messageFormat = '[%s] %s %s: %s\n'
        
        % Histórico de logs
        logHistory = {}
        maxHistorySize = 1000
        
        % Estatísticas
        stats = struct(...
            'debug', 0, ...
            'info', 0, ...
            'warning', 0, ...
            'error', 0, ...
            'critical', 0, ...
            'total', 0)
    end
    
    properties (Constant)
        % Níveis de log
        LEVELS = struct(...
            'DEBUG', 1, ...
            'INFO', 2, ...
            'WARNING', 3, ...
            'ERROR', 4, ...
            'CRITICAL', 5)
        
        % Configurações visuais por nível
        LEVEL_CONFIG = struct(...
            'DEBUG', struct('icon', '🔍', 'color', '\033[37m', 'name', 'DEBUG'), ...
            'INFO', struct('icon', '📋', 'color', '\033[34m', 'name', 'INFO'), ...
            'WARNING', struct('icon', '⚠️', 'color', '\033[33m', 'name', 'WARNING'), ...
            'ERROR', struct('icon', '❌', 'color', '\033[31m', 'name', 'ERROR'), ...
            'CRITICAL', struct('icon', '💥', 'color', '\033[35m', 'name', 'CRITICAL'))
        
        % Cores
        COLORS = struct(...
            'RESET', '\033[0m', ...
            'BOLD', '\033[1m', ...
            'DIM', '\033[2m')
    end
    
    methods
        function obj = Logger(name, varargin)
            % Construtor do logger
            %
            % ENTRADA:
            %   name - nome do logger
            %   varargin - parâmetros opcionais:
            %     'LogFile' - arquivo de log (opcional)
            %     'EnableColors' - habilitar cores (padrão: true)
            %     'EnableTimestamp' - habilitar timestamp (padrão: true)
            %     'MinLevel' - nível mínimo de log (padrão: 'INFO')
            %     'MaxHistorySize' - tamanho máximo do histórico (padrão: 1000)
            
            if nargin < 1
                name = 'MATLAB';
            end
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'LogFile', '', @ischar);
            addParameter(p, 'EnableColors', true, @islogical);
            addParameter(p, 'EnableTimestamp', true, @islogical);
            addParameter(p, 'MinLevel', 'INFO', @(x) ischar(x) || isnumeric(x));
            addParameter(p, 'MaxHistorySize', 1000, @isnumeric);
            parse(p, varargin{:});
            
            obj.name = name;
            obj.logFile = p.Results.LogFile;
            obj.enableColors = p.Results.EnableColors;
            obj.enableTimestamp = p.Results.EnableTimestamp;
            obj.maxHistorySize = p.Results.MaxHistorySize;
            
            % Configurar nível mínimo
            if ischar(p.Results.MinLevel)
                if isfield(obj.LEVELS, upper(p.Results.MinLevel))
                    obj.minLevel = obj.LEVELS.(upper(p.Results.MinLevel));
                else
                    obj.minLevel = obj.LEVELS.INFO;
                end
            else
                obj.minLevel = p.Results.MinLevel;
            end
            
            % Configurar logging em arquivo
            if ~isempty(obj.logFile)
                obj.enableFileLogging = true;
                obj.initializeLogFile();
            end
            
            % Log inicial
            obj.info(sprintf('Logger inicializado: %s', obj.name));
        end
        
        function debug(obj, message, varargin)
            % Log de debug
            obj.log('DEBUG', message, varargin{:});
        end
        
        function info(obj, message, varargin)
            % Log de informação
            obj.log('INFO', message, varargin{:});
        end
        
        function warning(obj, message, varargin)
            % Log de aviso
            obj.log('WARNING', message, varargin{:});
        end
        
        function error(obj, message, varargin)
            % Log de erro
            obj.log('ERROR', message, varargin{:});
        end
        
        function critical(obj, message, varargin)
            % Log crítico
            obj.log('CRITICAL', message, varargin{:});
        end
        
        function success(obj, message, varargin)
            % Log de sucesso (usando nível INFO com ícone especial)
            obj.logWithIcon('INFO', '✅', message, varargin{:});
        end
        
        function progress(obj, message, varargin)
            % Log de progresso (usando nível INFO com ícone especial)
            obj.logWithIcon('INFO', '🔄', message, varargin{:});
        end
        
        function step(obj, stepNumber, totalSteps, message, varargin)
            % Log de passo em processo
            stepMsg = sprintf('[%d/%d] %s', stepNumber, totalSteps, message);
            obj.logWithIcon('INFO', '📍', stepMsg, varargin{:});
        end
        
        function log(obj, level, message, varargin)
            % Log genérico
            %
            % ENTRADA:
            %   level - nível do log
            %   message - mensagem
            %   varargin - parâmetros opcionais:
            %     'Exception' - objeto MException para incluir stack trace
            %     'Data' - dados adicionais para incluir
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Exception', [], @(x) isa(x, 'MException'));
            addParameter(p, 'Data', [], @(x) true);
            parse(p, varargin{:});
            
            % Verificar nível mínimo
            levelNum = obj.getLevelNumber(level);
            if levelNum < obj.minLevel
                return;
            end
            
            % Obter configuração do nível
            config = obj.LEVEL_CONFIG.(upper(level));
            
            % Criar entrada de log
            logEntry = obj.createLogEntry(level, config, message, p.Results.Exception, p.Results.Data);
            
            % Exibir no console
            obj.displayLogEntry(logEntry, config);
            
            % Salvar em arquivo se habilitado
            if obj.enableFileLogging
                obj.writeToFile(logEntry);
            end
            
            % Adicionar ao histórico
            obj.addToHistory(logEntry);
            
            % Atualizar estatísticas
            obj.updateStats(level);
        end
        
        function logWithIcon(obj, level, icon, message, varargin)
            % Log com ícone personalizado
            
            % Obter configuração do nível
            config = obj.LEVEL_CONFIG.(upper(level));
            config.icon = icon; % Substituir ícone
            
            % Verificar nível mínimo
            levelNum = obj.getLevelNumber(level);
            if levelNum < obj.minLevel
                return;
            end
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Exception', [], @(x) isa(x, 'MException'));
            addParameter(p, 'Data', [], @(x) true);
            parse(p, varargin{:});
            
            % Criar entrada de log
            logEntry = obj.createLogEntry(level, config, message, p.Results.Exception, p.Results.Data);
            
            % Exibir no console
            obj.displayLogEntry(logEntry, config);
            
            % Salvar em arquivo se habilitado
            if obj.enableFileLogging
                obj.writeToFile(logEntry);
            end
            
            % Adicionar ao histórico
            obj.addToHistory(logEntry);
            
            % Atualizar estatísticas
            obj.updateStats(level);
        end
        
        function setLevel(obj, level)
            % Define nível mínimo de log
            
            if ischar(level)
                if isfield(obj.LEVELS, upper(level))
                    obj.minLevel = obj.LEVELS.(upper(level));
                    obj.info(sprintf('Nível de log alterado para: %s', upper(level)));
                else
                    obj.warning(sprintf('Nível de log inválido: %s', level));
                end
            else
                obj.minLevel = level;
                obj.info(sprintf('Nível de log alterado para: %d', level));
            end
        end
        
        function enableFileLogging(obj, filename)
            % Habilita logging em arquivo
            
            obj.logFile = filename;
            obj.enableFileLogging = true;
            obj.initializeLogFile();
            obj.info(sprintf('Logging em arquivo habilitado: %s', filename));
        end
        
        function disableFileLogging(obj)
            % Desabilita logging em arquivo
            
            obj.enableFileLogging = false;
            obj.info('Logging em arquivo desabilitado');
        end
        
        function history = getHistory(obj, varargin)
            % Retorna histórico de logs
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'Level' - filtrar por nível
            %     'Count' - número máximo de entradas
            %
            % SAÍDA:
            %   history - cell array com entradas de log
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Level', '', @ischar);
            addParameter(p, 'Count', length(obj.logHistory), @isnumeric);
            parse(p, varargin{:});
            
            history = obj.logHistory;
            
            % Filtrar por nível se especificado
            if ~isempty(p.Results.Level)
                levelFilter = strcmpi({history.level}, p.Results.Level);
                history = history(levelFilter);
            end
            
            % Limitar número de entradas
            if p.Results.Count < length(history)
                history = history(end-p.Results.Count+1:end);
            end
        end
        
        function stats = getStats(obj)
            % Retorna estatísticas de logging
            
            stats = obj.stats;
            stats.startTime = obj.logHistory(1).timestamp;
            stats.lastTime = obj.logHistory(end).timestamp;
            stats.duration = stats.lastTime - stats.startTime;
        end
        
        function clearHistory(obj)
            % Limpa histórico de logs
            
            obj.logHistory = {};
            obj.info('Histórico de logs limpo');
        end
        
        function exportHistory(obj, filename, varargin)
            % Exporta histórico para arquivo
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Format', 'txt', @(x) ismember(x, {'txt', 'csv', 'json'}));
            parse(p, varargin{:});
            
            try
                switch p.Results.Format
                    case 'txt'
                        obj.exportToText(filename);
                    case 'csv'
                        obj.exportToCSV(filename);
                    case 'json'
                        obj.exportToJSON(filename);
                end
                
                obj.info(sprintf('Histórico exportado para: %s', filename));
                
            catch ME
                obj.error(sprintf('Erro ao exportar histórico: %s', ME.message));
            end
        end
    end
    
    methods (Access = private)
        function levelNum = getLevelNumber(obj, level)
            % Converte nível para número
            
            if ischar(level)
                if isfield(obj.LEVELS, upper(level))
                    levelNum = obj.LEVELS.(upper(level));
                else
                    levelNum = obj.LEVELS.INFO;
                end
            else
                levelNum = level;
            end
        end
        
        function logEntry = createLogEntry(obj, level, config, message, exception, data)
            % Cria entrada de log
            
            logEntry = struct();
            logEntry.timestamp = now;
            logEntry.level = upper(level);
            logEntry.logger = obj.name;
            logEntry.message = message;
            logEntry.icon = config.icon;
            logEntry.color = config.color;
            
            % Adicionar exceção se fornecida
            if ~isempty(exception)
                logEntry.exception = struct();
                logEntry.exception.message = exception.message;
                logEntry.exception.identifier = exception.identifier;
                logEntry.exception.stack = exception.stack;
            end
            
            % Adicionar dados se fornecidos
            if ~isempty(data)
                logEntry.data = data;
            end
        end
        
        function displayLogEntry(obj, logEntry, config)
            % Exibe entrada de log no console
            
            % Construir timestamp
            if obj.enableTimestamp
                timestampStr = datestr(logEntry.timestamp, obj.timestampFormat);
            else
                timestampStr = '';
            end
            
            % Construir mensagem formatada
            if obj.enableColors
                formattedMessage = sprintf('%s%s%s %s%s%s: %s%s', ...
                    config.color, obj.COLORS.BOLD, timestampStr, ...
                    logEntry.icon, config.name, obj.COLORS.RESET, ...
                    logEntry.message, obj.COLORS.RESET);
            else
                formattedMessage = sprintf('%s %s %s: %s', ...
                    timestampStr, logEntry.icon, config.name, logEntry.message);
            end
            
            % Exibir mensagem
            fprintf('%s\n', formattedMessage);
            
            % Exibir exceção se presente
            if isfield(logEntry, 'exception')
                obj.displayException(logEntry.exception);
            end
            
            % Exibir dados se presentes
            if isfield(logEntry, 'data')
                obj.displayData(logEntry.data);
            end
        end
        
        function displayException(obj, exception)
            % Exibe informações de exceção
            
            if obj.enableColors
                fprintf('%s%sExceção: %s (%s)%s\n', ...
                    obj.COLORS.DIM, obj.LEVEL_CONFIG.ERROR.color, ...
                    exception.message, exception.identifier, obj.COLORS.RESET);
            else
                fprintf('Exceção: %s (%s)\n', exception.message, exception.identifier);
            end
            
            % Exibir stack trace se disponível
            if ~isempty(exception.stack)
                fprintf('Stack trace:\n');
                for i = 1:min(3, length(exception.stack)) % Limitar a 3 níveis
                    fprintf('  %s (linha %d)\n', exception.stack(i).name, exception.stack(i).line);
                end
            end
        end
        
        function displayData(obj, data)
            % Exibe dados adicionais
            
            if isstruct(data)
                fields = fieldnames(data);
                for i = 1:length(fields)
                    fprintf('  %s: %s\n', fields{i}, obj.formatValue(data.(fields{i})));
                end
            else
                fprintf('  Dados: %s\n', obj.formatValue(data));
            end
        end
        
        function str = formatValue(obj, value)
            % Formata valor para exibição
            
            if isnumeric(value)
                if isscalar(value)
                    str = num2str(value);
                else
                    str = sprintf('[%dx%d %s]', size(value), class(value));
                end
            elseif ischar(value)
                str = value;
            elseif islogical(value)
                if value
                    str = 'true';
                else
                    str = 'false';
                end
            else
                str = sprintf('[%s]', class(value));
            end
        end
        
        function writeToFile(obj, logEntry)
            % Escreve entrada no arquivo de log
            
            try
                fid = fopen(obj.logFile, 'a');
                if fid ~= -1
                    timestampStr = datestr(logEntry.timestamp, obj.timestampFormat);
                    fprintf(fid, '[%s] %s %s: %s\n', ...
                        timestampStr, logEntry.level, obj.name, logEntry.message);
                    
                    % Adicionar exceção se presente
                    if isfield(logEntry, 'exception')
                        fprintf(fid, '  Exceção: %s (%s)\n', ...
                            logEntry.exception.message, logEntry.exception.identifier);
                    end
                    
                    fclose(fid);
                end
            catch
                % Ignorar erros de escrita em arquivo
            end
        end
        
        function addToHistory(obj, logEntry)
            % Adiciona entrada ao histórico
            
            obj.logHistory{end+1} = logEntry;
            
            % Limitar tamanho do histórico
            if length(obj.logHistory) > obj.maxHistorySize
                obj.logHistory = obj.logHistory(end-obj.maxHistorySize+1:end);
            end
        end
        
        function updateStats(obj, level)
            % Atualiza estatísticas
            
            levelLower = lower(level);
            if isfield(obj.stats, levelLower)
                obj.stats.(levelLower) = obj.stats.(levelLower) + 1;
            end
            obj.stats.total = obj.stats.total + 1;
        end
        
        function initializeLogFile(obj)
            % Inicializa arquivo de log
            
            try
                % Criar diretório se não existir
                [logDir, ~, ~] = fileparts(obj.logFile);
                if ~isempty(logDir) && ~exist(logDir, 'dir')
                    mkdir(logDir);
                end
                
                % Escrever cabeçalho
                fid = fopen(obj.logFile, 'a');
                if fid ~= -1
                    fprintf(fid, '\n=== LOG INICIADO EM %s ===\n', ...
                        datestr(now, 'yyyy-mm-dd HH:MM:SS'));
                    fclose(fid);
                end
            catch
                % Ignorar erros de inicialização
            end
        end
        
        function exportToText(obj, filename)
            % Exporta histórico para arquivo texto
            
            fid = fopen(filename, 'w');
            if fid == -1
                error('Não foi possível criar arquivo: %s', filename);
            end
            
            try
                for i = 1:length(obj.logHistory)
                    entry = obj.logHistory{i};
                    timestampStr = datestr(entry.timestamp, obj.timestampFormat);
                    fprintf(fid, '[%s] %s %s: %s\n', ...
                        timestampStr, entry.level, obj.name, entry.message);
                end
                fclose(fid);
            catch ME
                fclose(fid);
                rethrow(ME);
            end
        end
        
        function exportToCSV(obj, filename)
            % Exporta histórico para arquivo CSV
            
            fid = fopen(filename, 'w');
            if fid == -1
                error('Não foi possível criar arquivo: %s', filename);
            end
            
            try
                % Cabeçalho
                fprintf(fid, 'Timestamp,Level,Logger,Message\n');
                
                % Dados
                for i = 1:length(obj.logHistory)
                    entry = obj.logHistory{i};
                    timestampStr = datestr(entry.timestamp, obj.timestampFormat);
                    fprintf(fid, '"%s","%s","%s","%s"\n', ...
                        timestampStr, entry.level, obj.name, entry.message);
                end
                fclose(fid);
            catch ME
                fclose(fid);
                rethrow(ME);
            end
        end
        
        function exportToJSON(obj, filename)
            % Exporta histórico para arquivo JSON (simplificado)
            
            fid = fopen(filename, 'w');
            if fid == -1
                error('Não foi possível criar arquivo: %s', filename);
            end
            
            try
                fprintf(fid, '{\n  "logger": "%s",\n  "entries": [\n', obj.name);
                
                for i = 1:length(obj.logHistory)
                    entry = obj.logHistory{i};
                    timestampStr = datestr(entry.timestamp, obj.timestampFormat);
                    
                    fprintf(fid, '    {\n');
                    fprintf(fid, '      "timestamp": "%s",\n', timestampStr);
                    fprintf(fid, '      "level": "%s",\n', entry.level);
                    fprintf(fid, '      "message": "%s"\n', entry.message);
                    
                    if i < length(obj.logHistory)
                        fprintf(fid, '    },\n');
                    else
                        fprintf(fid, '    }\n');
                    end
                end
                
                fprintf(fid, '  ]\n}\n');
                fclose(fid);
            catch ME
                fclose(fid);
                rethrow(ME);
            end
        end
    end
    
    methods (Static)
        function demo()
            % Demonstração do sistema de logging
            
            fprintf('Demonstração do Logger:\n\n');
            
            % Criar logger
            logger = Logger('Demo', 'EnableColors', true);
            
            % Diferentes tipos de log
            logger.debug('Esta é uma mensagem de debug');
            logger.info('Informação importante');
            logger.warning('Aviso sobre algo');
            logger.error('Erro ocorreu');
            logger.critical('Erro crítico!');
            
            % Logs especiais
            logger.success('Operação bem-sucedida');
            logger.progress('Processando dados...');
            logger.step(3, 10, 'Executando passo 3 de 10');
            
            % Log com exceção
            try
                error('Erro simulado');
            catch ME
                logger.error('Erro capturado', 'Exception', ME);
            end
            
            % Log com dados
            data = struct('valor', 42, 'nome', 'teste');
            logger.info('Dados processados', 'Data', data);
            
            % Mostrar estatísticas
            stats = logger.getStats();
            fprintf('\nEstatísticas:\n');
            fprintf('Total: %d, Info: %d, Warning: %d, Error: %d\n', ...
                stats.total, stats.info, stats.warning, stats.error);
            
            fprintf('\nDemonstração concluída!\n');
        end
    end
end