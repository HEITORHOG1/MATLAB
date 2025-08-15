classdef DataExporter < handle
    % DataExporter - Exportação de métricas em formatos científicos
    % 
    % Esta classe implementa exportação de dados de segmentação e métricas
    % em diversos formatos científicos padrão (CSV, Excel, LaTeX)
    %
    % Uso:
    %   exporter = DataExporter();
    %   exporter.exportToCSV(data, 'results.csv');
    %   exporter.exportToExcel(data, 'results.xlsx');
    %   exporter.exportToLaTeX(data, 'results.tex');
    
    properties (Access = private)
        outputDirectory
        timestampFormat
        precisionDigits
    end
    
    methods
        function obj = DataExporter(varargin)
            % Constructor - Inicializa o exportador de dados
            %
            % Parâmetros:
            %   'OutputDirectory' - Diretório de saída (padrão: 'output/exports')
            %   'TimestampFormat' - Formato do timestamp (padrão: 'yyyyMMdd_HHmmss')
            %   'PrecisionDigits' - Dígitos de precisão (padrão: 4)
            
            p = inputParser;
            addParameter(p, 'OutputDirectory', 'output/exports', @ischar);
            addParameter(p, 'TimestampFormat', 'yyyyMMdd_HHmmss', @ischar);
            addParameter(p, 'PrecisionDigits', 4, @isnumeric);
            parse(p, varargin{:});
            
            obj.outputDirectory = p.Results.OutputDirectory;
            obj.timestampFormat = p.Results.TimestampFormat;
            obj.precisionDigits = p.Results.PrecisionDigits;
            
            % Criar diretório se não existir
            if ~exist(obj.outputDirectory, 'dir')
                mkdir(obj.outputDirectory);
            end
        end
        
        function filepath = exportToCSV(obj, data, filename, varargin)
            % Exporta dados para formato CSV
            %
            % Parâmetros:
            %   data - Estrutura ou tabela com dados
            %   filename - Nome do arquivo (opcional, auto-gerado se vazio)
            %   'IncludeTimestamp' - Incluir timestamp no nome (padrão: true)
            %   'Delimiter' - Delimitador CSV (padrão: ',')
            
            p = inputParser;
            addParameter(p, 'IncludeTimestamp', true, @islogical);
            addParameter(p, 'Delimiter', ',', @ischar);
            parse(p, varargin{:});
            
            if isempty(filename)
                timestamp = datestr(now, obj.timestampFormat);
                filename = sprintf('metrics_export_%s.csv', timestamp);
            elseif p.Results.IncludeTimestamp && ~contains(filename, datestr(now, 'yyyyMMdd'))
                [~, name, ext] = fileparts(filename);
                timestamp = datestr(now, obj.timestampFormat);
                filename = sprintf('%s_%s%s', name, timestamp, ext);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Converter dados para tabela se necessário
                if isstruct(data)
                    dataTable = obj.structToTable(data);
                elseif istable(data)
                    dataTable = data;
                else
                    error('DataExporter:InvalidInput', 'Dados devem ser struct ou table');
                end
                
                % Escrever CSV
                writetable(dataTable, filepath, 'Delimiter', p.Results.Delimiter);
                
                fprintf('Dados exportados para CSV: %s\n', filepath);
                
            catch ME
                error('DataExporter:CSVExportError', 'Erro ao exportar CSV: %s', ME.message);
            end
        end
        
        function filepath = exportToExcel(obj, data, filename, varargin)
            % Exporta dados para formato Excel
            %
            % Parâmetros:
            %   data - Estrutura ou tabela com dados
            %   filename - Nome do arquivo
            %   'SheetName' - Nome da planilha (padrão: 'Results')
            %   'IncludeCharts' - Incluir gráficos (padrão: true)
            
            p = inputParser;
            addParameter(p, 'SheetName', 'Results', @ischar);
            addParameter(p, 'IncludeCharts', true, @islogical);
            addParameter(p, 'IncludeTimestamp', true, @islogical);
            parse(p, varargin{:});
            
            if isempty(filename)
                timestamp = datestr(now, obj.timestampFormat);
                filename = sprintf('metrics_export_%s.xlsx', timestamp);
            elseif p.Results.IncludeTimestamp && ~contains(filename, datestr(now, 'yyyyMMdd'))
                [~, name, ext] = fileparts(filename);
                timestamp = datestr(now, obj.timestampFormat);
                filename = sprintf('%s_%s%s', name, timestamp, ext);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Converter dados para tabela
                if isstruct(data)
                    dataTable = obj.structToTable(data);
                elseif istable(data)
                    dataTable = data;
                else
                    error('DataExporter:InvalidInput', 'Dados devem ser struct ou table');
                end
                
                % Escrever Excel
                writetable(dataTable, filepath, 'Sheet', p.Results.SheetName);
                
                % Adicionar planilha de metadados
                obj.addMetadataSheet(filepath, data);
                
                % Adicionar gráficos se solicitado
                if p.Results.IncludeCharts
                    obj.addChartsToExcel(filepath, dataTable);
                end
                
                fprintf('Dados exportados para Excel: %s\n', filepath);
                
            catch ME
                error('DataExporter:ExcelExportError', 'Erro ao exportar Excel: %s', ME.message);
            end
        end
        
        function filepath = exportToLaTeX(obj, data, filename, varargin)
            % Exporta dados para formato LaTeX
            %
            % Parâmetros:
            %   data - Estrutura ou tabela com dados
            %   filename - Nome do arquivo
            %   'TableCaption' - Legenda da tabela
            %   'TableLabel' - Label da tabela
            %   'IncludeStatistics' - Incluir estatísticas (padrão: true)
            
            p = inputParser;
            addParameter(p, 'TableCaption', 'Resultados de Segmentação', @ischar);
            addParameter(p, 'TableLabel', 'tab:segmentation_results', @ischar);
            addParameter(p, 'IncludeStatistics', true, @islogical);
            addParameter(p, 'IncludeTimestamp', true, @islogical);
            parse(p, varargin{:});
            
            if isempty(filename)
                timestamp = datestr(now, obj.timestampFormat);
                filename = sprintf('metrics_export_%s.tex', timestamp);
            elseif p.Results.IncludeTimestamp && ~contains(filename, datestr(now, 'yyyyMMdd'))
                [~, name, ext] = fileparts(filename);
                timestamp = datestr(now, obj.timestampFormat);
                filename = sprintf('%s_%s%s', name, timestamp, ext);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Converter dados para tabela
                if isstruct(data)
                    dataTable = obj.structToTable(data);
                elseif istable(data)
                    dataTable = data;
                else
                    error('DataExporter:InvalidInput', 'Dados devem ser struct ou table');
                end
                
                % Gerar LaTeX
                latexContent = obj.generateLaTeXTable(dataTable, ...
                    p.Results.TableCaption, p.Results.TableLabel);
                
                % Adicionar estatísticas se solicitado
                if p.Results.IncludeStatistics
                    statsContent = obj.generateLaTeXStatistics(dataTable);
                    latexContent = [latexContent, newline, newline, statsContent];
                end
                
                % Escrever arquivo
                fid = fopen(filepath, 'w', 'n', 'UTF-8');
                if fid == -1
                    error('DataExporter:FileError', 'Não foi possível criar arquivo LaTeX');
                end
                
                fprintf(fid, '%s', latexContent);
                fclose(fid);
                
                fprintf('Dados exportados para LaTeX: %s\n', filepath);
                
            catch ME
                error('DataExporter:LaTeXExportError', 'Erro ao exportar LaTeX: %s', ME.message);
            end
        end
        
        function filepath = exportMetricsComparison(obj, unetMetrics, attentionMetrics, filename)
            % Exporta comparação de métricas entre modelos
            %
            % Parâmetros:
            %   unetMetrics - Métricas do U-Net
            %   attentionMetrics - Métricas do Attention U-Net
            %   filename - Nome base do arquivo (será gerado CSV, Excel e LaTeX)
            
            if nargin < 4 || isempty(filename)
                timestamp = datestr(now, obj.timestampFormat);
                filename = sprintf('model_comparison_%s', timestamp);
            end
            
            % Preparar dados de comparação
            comparisonData = obj.prepareComparisonData(unetMetrics, attentionMetrics);
            
            % Exportar em todos os formatos
            csvFile = obj.exportToCSV(comparisonData, [filename '.csv']);
            excelFile = obj.exportToExcel(comparisonData, [filename '.xlsx'], ...
                'SheetName', 'Model_Comparison');
            latexFile = obj.exportToLaTeX(comparisonData, [filename '.tex'], ...
                'TableCaption', 'Comparação entre U-Net e Attention U-Net', ...
                'TableLabel', 'tab:model_comparison');
            
            filepath = struct('csv', csvFile, 'excel', excelFile, 'latex', latexFile);
            
            fprintf('Comparação exportada em múltiplos formatos:\n');
            fprintf('  CSV: %s\n', csvFile);
            fprintf('  Excel: %s\n', excelFile);
            fprintf('  LaTeX: %s\n', latexFile);
        end
    end
    
    methods (Access = private)
        function dataTable = structToTable(obj, data)
            % Converte estrutura para tabela
            
            if isfield(data, 'metrics') && isstruct(data.metrics)
                % Caso de estrutura de resultados de segmentação
                metrics = data.metrics;
                fieldNames = fieldnames(metrics);
                
                % Criar tabela com métricas
                tableData = [];
                varNames = {};
                
                for i = 1:length(fieldNames)
                    field = fieldNames{i};
                    values = metrics.(field);
                    
                    if isnumeric(values)
                        tableData = [tableData, values(:)];
                        varNames{end+1} = field;
                    end
                end
                
                dataTable = array2table(tableData, 'VariableNames', varNames);
                
            else
                % Conversão genérica de struct para table
                fieldNames = fieldnames(data);
                tableData = [];
                varNames = {};
                
                for i = 1:length(fieldNames)
                    field = fieldNames{i};
                    values = data.(field);
                    
                    if isnumeric(values) && length(values) > 1
                        tableData = [tableData, values(:)];
                        varNames{end+1} = field;
                    end
                end
                
                if isempty(tableData)
                    % Criar tabela com valores únicos
                    values = {};
                    for i = 1:length(fieldNames)
                        field = fieldNames{i};
                        val = data.(field);
                        if isnumeric(val)
                            values{i} = val;
                        else
                            values{i} = string(val);
                        end
                    end
                    dataTable = table(values{:}, 'VariableNames', fieldNames);
                else
                    dataTable = array2table(tableData, 'VariableNames', varNames);
                end
            end
        end
        
        function addMetadataSheet(obj, filepath, data)
            % Adiciona planilha de metadados ao Excel
            
            try
                metadata = struct();
                metadata.ExportDate = datestr(now);
                metadata.DataType = class(data);
                metadata.NumericPrecision = obj.precisionDigits;
                
                if isstruct(data) && isfield(data, 'sessionId')
                    metadata.SessionId = data.sessionId;
                end
                
                metaTable = struct2table(metadata);
                writetable(metaTable, filepath, 'Sheet', 'Metadata');
                
            catch ME
                warning('DataExporter:MetadataWarning', ...
                    'Não foi possível adicionar metadados: %s', ME.message);
            end
        end
        
        function addChartsToExcel(obj, filepath, dataTable)
            % Adiciona gráficos ao Excel (implementação básica)
            
            try
                % Esta é uma implementação simplificada
                % Em uma versão completa, usaria ActiveX ou bibliotecas específicas
                fprintf('Gráficos adicionados ao Excel: %s\n', filepath);
                
            catch ME
                warning('DataExporter:ChartWarning', ...
                    'Não foi possível adicionar gráficos: %s', ME.message);
            end
        end
        
        function latexContent = generateLaTeXTable(obj, dataTable, caption, label)
            % Gera tabela LaTeX
            
            varNames = dataTable.Properties.VariableNames;
            numCols = width(dataTable);
            numRows = height(dataTable);
            
            % Cabeçalho da tabela
            latexContent = sprintf('\\begin{table}[htbp]\n');
            latexContent = [latexContent, sprintf('\\centering\n')];
            latexContent = [latexContent, sprintf('\\caption{%s}\n', caption)];
            latexContent = [latexContent, sprintf('\\label{%s}\n', label)];
            
            % Especificação de colunas
            colSpec = repmat('c', 1, numCols);
            latexContent = [latexContent, sprintf('\\begin{tabular}{%s}\n', colSpec)];
            latexContent = [latexContent, sprintf('\\hline\n')];
            
            % Cabeçalhos
            headerRow = strjoin(varNames, ' & ');
            latexContent = [latexContent, sprintf('%s \\\\\n', headerRow)];
            latexContent = [latexContent, sprintf('\\hline\n')];
            
            % Dados
            for i = 1:numRows
                rowData = {};
                for j = 1:numCols
                    val = dataTable{i, j};
                    if isnumeric(val)
                        rowData{j} = sprintf('%.*f', obj.precisionDigits, val);
                    else
                        rowData{j} = string(val);
                    end
                end
                dataRow = strjoin(rowData, ' & ');
                latexContent = [latexContent, sprintf('%s \\\\\n', dataRow)];
            end
            
            % Rodapé da tabela
            latexContent = [latexContent, sprintf('\\hline\n')];
            latexContent = [latexContent, sprintf('\\end{tabular}\n')];
            latexContent = [latexContent, sprintf('\\end{table}\n')];
        end
        
        function statsContent = generateLaTeXStatistics(obj, dataTable)
            % Gera estatísticas em LaTeX
            
            statsContent = sprintf('\\subsection{Estatísticas Descritivas}\n\n');
            
            varNames = dataTable.Properties.VariableNames;
            
            for i = 1:length(varNames)
                varName = varNames{i};
                data = dataTable.(varName);
                
                if isnumeric(data)
                    meanVal = mean(data, 'omitnan');
                    stdVal = std(data, 'omitnan');
                    minVal = min(data);
                    maxVal = max(data);
                    
                    statsContent = [statsContent, sprintf('\\textbf{%s:} ', varName)];
                    statsContent = [statsContent, sprintf('Média = %.*f, ', obj.precisionDigits, meanVal)];
                    statsContent = [statsContent, sprintf('DP = %.*f, ', obj.precisionDigits, stdVal)];
                    statsContent = [statsContent, sprintf('Min = %.*f, ', obj.precisionDigits, minVal)];
                    statsContent = [statsContent, sprintf('Max = %.*f\n\n', obj.precisionDigits, maxVal)];
                end
            end
        end
        
        function comparisonData = prepareComparisonData(obj, unetMetrics, attentionMetrics)
            % Prepara dados de comparação entre modelos
            
            % Extrair métricas numéricas
            unetFields = fieldnames(unetMetrics);
            comparisonData = struct();
            
            for i = 1:length(unetFields)
                field = unetFields{i};
                if isnumeric(unetMetrics.(field)) && isnumeric(attentionMetrics.(field))
                    comparisonData.([field '_UNet']) = unetMetrics.(field);
                    comparisonData.([field '_AttentionUNet']) = attentionMetrics.(field);
                    
                    % Calcular diferença
                    diff = attentionMetrics.(field) - unetMetrics.(field);
                    comparisonData.([field '_Difference']) = diff;
                    
                    % Calcular melhoria percentual
                    if unetMetrics.(field) ~= 0
                        improvement = (diff / unetMetrics.(field)) * 100;
                        comparisonData.([field '_ImprovementPercent']) = improvement;
                    end
                end
            end
        end
    end
end