classdef ValidationLogger < handle
    % ValidationLogger - Sistema de logging detalhado para validação
    % 
    % Implementa logging estruturado com diferentes níveis de severidade,
    % timestamps e saída para arquivo e console.
    
    properties (Access = private)
        logFile
        logLevel
        componentName
        startTime
        enableConsoleOutput
        enableFileOutput
    end
    
    properties (Constant)
        LEVEL_DEBUG = 1;
        LEVEL_INFO = 2;
        LEVEL_WARNING = 3;
        LEVEL_ERROR = 4;
        LEVEL_CRITICAL = 5;
    end
    
    methods
        function obj = ValidationLogger(componentName, logFile)
            % Construtor do ValidationLogger
            if nargin < 1
                obj.componentName = 'System';
            else
                obj.componentName = componentName;
            end
            
            if nargin < 2
                % Criar arquivo de log padrão
                logDir = fullfile('validation_results', 'logs');
                if ~exist(logDir, 'dir')
                    mkdir(logDir);
                end
                obj.logFile = fullfile(logDir, ...
                    ['validation_' datestr(now, 'yyyymmdd_HHMMSS') '.log']);
            else
                obj.logFile = logFile;
            end
            
            obj.logLevel = obj.LEVEL_INFO;
            obj.startTime = now;
            obj.enableConsoleOutput = true;
            obj.enableFileOutput = true;
            
            % Inicializar arquivo de log
            obj.initializeLogFile();
        end
        
        function debug(obj, message)
            % Log de debug
            obj.log(obj.LEVEL_DEBUG, message);
        end
        
        function info(obj, message)
            % Log de informação
            obj.log(obj.LEVEL_INFO, message);
        end
        
        function warning(obj, message)
            % Log de warning
            obj.log(obj.LEVEL_WARNING, message);
        end
        
        function error(obj, message)
            % Log de erro
            obj.log(obj.LEVEL_ERROR, message);
        end
        
        function critical(obj, message)
            % Log crítico
            obj.log(obj.LEVEL_CRITICAL, message);
        end
        
        function logTestStart(obj, testName)
            % Log início de teste
            obj.info(['=== INICIANDO TESTE: ' testName ' ===']);
        end
        
        function logTestEnd(obj, testName, success, duration)
            % Log fim de teste
            status = 'SUCESSO';
            if ~success
                status = 'FALHA';
            end
            obj.info(['=== TESTE FINALIZADO: ' testName ' - ' status ...
                ' (' num2str(duration, '%.2f') 's) ===']);
        end
        
        function logProgress(obj, current, total, operation)
            % Log de progresso
            percentage = (current / total) * 100;
            obj.info(['Progresso ' operation ': ' num2str(current) '/' ...
                num2str(total) ' (' num2str(percentage, '%.1f') '%)']);
        end
        
        function logMetrics(obj, metrics)
            % Log de métricas
            obj.info('=== MÉTRICAS ===');
            fields = fieldnames(metrics);
            for i = 1:length(fields)
                field = fields{i};
                value = metrics.(field);
                if isnumeric(value)
                    obj.info([field ': ' num2str(value)]);
                else
                    obj.info([field ': ' char(value)]);
                end
            end
            obj.info('===============');
        end
        
        function setLogLevel(obj, level)
            % Define nível de log
            obj.logLevel = level;
        end
        
        function setConsoleOutput(obj, enabled)
            % Habilita/desabilita saída no console
            obj.enableConsoleOutput = enabled;
        end
        
        function setFileOutput(obj, enabled)
            % Habilita/desabilita saída em arquivo
            obj.enableFileOutput = enabled;
        end
        
        function logFile = getLogFile(obj)
            % Retorna caminho do arquivo de log
            logFile = obj.logFile;
        end
    end
    
    methods (Access = private)
        function log(obj, level, message)
            % Método principal de logging
            if level < obj.logLevel
                return;
            end
            
            % Criar entrada de log
            timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
            levelStr = obj.getLevelString(level);
            logEntry = sprintf('[%s] [%s] [%s] %s', ...
                timestamp, levelStr, obj.componentName, message);
            
            % Saída no console
            if obj.enableConsoleOutput
                fprintf('%s\n', logEntry);
            end
            
            % Saída em arquivo
            if obj.enableFileOutput
                obj.writeToFile(logEntry);
            end
        end
        
        function levelStr = getLevelString(obj, level)
            % Converte nível numérico em string
            switch level
                case obj.LEVEL_DEBUG
                    levelStr = 'DEBUG';
                case obj.LEVEL_INFO
                    levelStr = 'INFO';
                case obj.LEVEL_WARNING
                    levelStr = 'WARN';
                case obj.LEVEL_ERROR
                    levelStr = 'ERROR';
                case obj.LEVEL_CRITICAL
                    levelStr = 'CRIT';
                otherwise
                    levelStr = 'UNKNOWN';
            end
        end
        
        function initializeLogFile(obj)
            % Inicializa arquivo de log
            try
                % Criar diretório se não existir
                logDir = fileparts(obj.logFile);
                if ~exist(logDir, 'dir')
                    mkdir(logDir);
                end
                
                % Escrever cabeçalho
                header = sprintf(['=== VALIDATION LOG STARTED ===\n' ...
                    'Component: %s\n' ...
                    'Start Time: %s\n' ...
                    'Log File: %s\n' ...
                    '================================\n'], ...
                    obj.componentName, datestr(obj.startTime), obj.logFile);
                
                fid = fopen(obj.logFile, 'w');
                if fid ~= -1
                    fprintf(fid, '%s', header);
                    fclose(fid);
                end
            catch ME
                warning('Não foi possível inicializar arquivo de log: %s', ME.message);
                obj.enableFileOutput = false;
            end
        end
        
        function writeToFile(obj, logEntry)
            % Escreve entrada no arquivo de log
            try
                fid = fopen(obj.logFile, 'a');
                if fid ~= -1
                    fprintf(fid, '%s\n', logEntry);
                    fclose(fid);
                end
            catch ME
                % Silenciosamente desabilitar log em arquivo se houver erro
                obj.enableFileOutput = false;
            end
        end
    end
end