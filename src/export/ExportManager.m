classdef ExportManager < handle
    % ExportManager - Gerenciador central do sistema de exportação
    % 
    % Esta classe coordena todos os componentes de exportação e integração
    % externa, fornecendo uma interface unificada para todas as funcionalidades
    %
    % Uso:
    %   manager = ExportManager();
    %   manager.exportCompleteResults(results, 'session_001');
    %   manager.setupGitLFS();
    
    properties (Access = private)
        dataExporter
        modelExporter
        reportGenerator
        backupManager
        visualizationExporter
        dicomExporter
        outputDirectory
        sessionId
    end
    
    methods
        function obj = ExportManager(varargin)
            % Constructor - Inicializa o gerenciador de exportação
            %
            % Parâmetros:
            %   'OutputDirectory' - Diretório base de saída (padrão: 'output')
            %   'SessionId' - ID da sessão atual
            %   'EnableGitLFS' - Habilitar Git LFS (padrão: false)
            %   'EnableDICOM' - Habilitar exportação DICOM (padrão: false)
            
            p = inputParser;
            addParameter(p, 'OutputDirectory', 'output', @ischar);
            addParameter(p, 'SessionId', datestr(now, 'yyyyMMdd_HHmmss'), @ischar);
            addParameter(p, 'EnableGitLFS', false, @islogical);
            addParameter(p, 'EnableDICOM', false, @islogical);
            parse(p, varargin{:});
            
            obj.outputDirectory = p.Results.OutputDirectory;
            obj.sessionId = p.Results.SessionId;
            
            % Criar diretório base se não existir
            if ~exist(obj.outputDirectory, 'dir')
                mkdir(obj.outputDirectory);
            end
            
            % Inicializar componentes de exportação
            obj.initializeExporters(p.Results.EnableGitLFS, p.Results.EnableDICOM);
            
            fprintf('ExportManager inicializado para sessão: %s\n', obj.sessionId);
        end
        
        function results = exportCompleteResults(obj, segmentationResults, sessionName, varargin)
            % Exporta resultados completos em todos os formatos
            %
            % Parâmetros:
            %   segmentationResults - Estrutura com resultados de segmentação
            %   sessionName - Nome da sessão
            %   'IncludeModels' - Incluir modelos treinados (padrão: true)
            %   'IncludeVisualizations' - Incluir visualizações (padrão: true)
            %   'IncludeReports' - Incluir relatórios (padrão: true)
            %   'CreateBackup' - Criar backup (padrão: true)
            
            p = inputParser;
            addParameter(p, 'IncludeModels', true, @islogical);
            addParameter(p, 'IncludeVisualizations', true, @islogical);
            addParameter(p, 'IncludeReports', true, @islogical);
            addParameter(p, 'CreateBackup', true, @islogical);
            parse(p, varargin{:});
            
            results = struct();
            results.session_id = sessionName;
            results.export_date = datestr(now);
            results.exported_files = {};
            
            try
                fprintf('Iniciando exportação completa para sessão: %s\n', sessionName);
                
                % 1. Exportar dados em formatos científicos
                fprintf('Exportando dados científicos...\n');
                dataFiles = obj.exportScientificData(segmentationResults, sessionName);
                results.data_files = dataFiles;
                results.exported_files = [results.exported_files, struct2cell(dataFiles)'];
                
                % 2. Exportar modelos se disponíveis e solicitado
                if p.Results.IncludeModels && isfield(segmentationResults, 'models')
                    fprintf('Exportando modelos...\n');
                    modelFiles = obj.exportModels(segmentationResults.models, sessionName);
                    results.model_files = modelFiles;
                    results.exported_files = [results.exported_files, struct2cell(modelFiles)'];
                end
                
                % 3. Gerar visualizações
                if p.Results.IncludeVisualizations
                    fprintf('Gerando visualizações...\n');
                    visualFiles = obj.generateVisualizations(segmentationResults, sessionName);
                    results.visualization_files = visualFiles;
                    results.exported_files = [results.exported_files, visualFiles];
                end
                
                % 4. Gerar relatórios
                if p.Results.IncludeReports
                    fprintf('Gerando relatórios...\n');
                    reportFiles = obj.generateReports(segmentationResults, sessionName);
                    results.report_files = reportFiles;
                    results.exported_files = [results.exported_files, struct2cell(reportFiles)'];
                end
                
                % 5. Criar backup se solicitado
                if p.Results.CreateBackup
                    fprintf('Criando backup...\n');
                    backupFile = obj.createSessionBackup(sessionName);
                    results.backup_file = backupFile;
                    results.exported_files{end+1} = backupFile;
                end
                
                % 6. Gerar índice da sessão
                indexFile = obj.generateSessionIndex(results, sessionName);
                results.index_file = indexFile;
                results.exported_files{end+1} = indexFile;
                
                fprintf('Exportação completa finalizada. %d arquivos gerados.\n', length(results.exported_files));
                
            catch ME
                error('ExportManager:CompleteExportError', ...
                    'Erro na exportação completa: %s', ME.message);
            end
        end
        
        function modelFiles = exportModelsToStandardFormats(obj, models, sessionName)
            % Exporta modelos para formatos padrão da indústria
            %
            % Parâmetros:
            %   models - Estrutura com modelos treinados
            %   sessionName - Nome da sessão
            
            modelFiles = struct();
            
            try
                modelDir = fullfile(obj.outputDirectory, 'models', sessionName);
                if ~exist(modelDir, 'dir')
                    mkdir(modelDir);
                end
                
                % Configurar exportador de modelos para este diretório
                obj.modelExporter.outputDirectory = modelDir;
                
                modelNames = fieldnames(models);
                for i = 1:length(modelNames)
                    modelName = modelNames{i};
                    model = models.(modelName);
                    
                    fprintf('Exportando modelo %s...\n', modelName);
                    
                    % Exportar para ONNX
                    try
                        onnxFile = obj.modelExporter.exportToONNX(model, ...
                            sprintf('%s.onnx', modelName), 'InputSize', [256, 256, 1]);
                        modelFiles.([modelName '_onnx']) = onnxFile;
                    catch ME
                        warning('ExportManager:ONNXExportWarning', ...
                            'Erro ao exportar %s para ONNX: %s', modelName, ME.message);
                    end
                    
                    % Exportar metadados
                    try
                        metadataFile = obj.modelExporter.exportModelMetadata(model, ...
                            sprintf('%s_metadata.json', modelName));
                        modelFiles.([modelName '_metadata']) = metadataFile;
                    catch ME
                        warning('ExportManager:MetadataWarning', ...
                            'Erro ao exportar metadados de %s: %s', modelName, ME.message);
                    end
                    
                    % Exportar para TensorFlow
                    try
                        tfFile = obj.modelExporter.exportForTensorFlow(model, ...
                            sprintf('%s_tensorflow', modelName));
                        modelFiles.([modelName '_tensorflow']) = tfFile;
                    catch ME
                        warning('ExportManager:TensorFlowWarning', ...
                            'Erro ao exportar %s para TensorFlow: %s', modelName, ME.message);
                    end
                    
                    % Exportar para PyTorch
                    try
                        pytorchFile = obj.modelExporter.exportForPyTorch(model, ...
                            sprintf('%s_pytorch', modelName));
                        modelFiles.([modelName '_pytorch']) = pytorchFile;
                    catch ME
                        warning('ExportManager:PyTorchWarning', ...
                            'Erro ao exportar %s para PyTorch: %s', modelName, ME.message);
                    end
                end
                
                fprintf('Modelos exportados para: %s\n', modelDir);
                
            catch ME
                error('ExportManager:ModelExportError', ...
                    'Erro na exportação de modelos: %s', ME.message);
            end
        end
        
        function reportFiles = generateComprehensiveReports(obj, results, sessionName)
            % Gera relatórios científicos abrangentes
            %
            % Parâmetros:
            %   results - Resultados da análise
            %   sessionName - Nome da sessão
            
            reportFiles = struct();
            
            try
                reportDir = fullfile(obj.outputDirectory, 'reports', sessionName);
                if ~exist(reportDir, 'dir')
                    mkdir(reportDir);
                end
                
                % Configurar gerador de relatórios
                obj.reportGenerator.outputDirectory = reportDir;
                
                % Relatório completo em HTML
                htmlReport = obj.reportGenerator.generateFullReport(results, ...
                    sprintf('%s_complete_report.html', sessionName), ...
                    'Title', sprintf('Relatório Completo - %s', sessionName));
                reportFiles.html_report = htmlReport;
                
                % Relatório em LaTeX
                latexReport = obj.reportGenerator.generateLaTeXReport(results, ...
                    sprintf('%s_scientific_report.tex', sessionName), ...
                    'Title', sprintf('Análise Científica - %s', sessionName));
                reportFiles.latex_report = latexReport;
                
                % Tentar compilar LaTeX para PDF
                if obj.reportGenerator.compileLatexReport(latexReport)
                    [pathStr, name, ~] = fileparts(latexReport);
                    pdfFile = fullfile(pathStr, [name '.pdf']);
                    if exist(pdfFile, 'file')
                        reportFiles.pdf_report = pdfFile;
                    end
                end
                
                % Sumário executivo
                summaryReport = obj.reportGenerator.generateExecutiveSummary(results, ...
                    sprintf('%s_executive_summary.html', sessionName));
                reportFiles.executive_summary = summaryReport;
                
                % Relatório de metodologia
                if isfield(results, 'config')
                    methodologyReport = obj.reportGenerator.generateMethodologyReport(results.config, ...
                        sprintf('%s_methodology.tex', sessionName));
                    reportFiles.methodology_report = methodologyReport;
                end
                
                % Relatório de comparação específico
                if isfield(results, 'unet_metrics') && isfield(results, 'attention_metrics')
                    comparisonReport = obj.reportGenerator.generateComparisonReport(...
                        results.unet_metrics, results.attention_metrics, ...
                        sprintf('%s_model_comparison.html', sessionName));
                    reportFiles.comparison_report = comparisonReport;
                end
                
                fprintf('Relatórios gerados em: %s\n', reportDir);
                
            catch ME
                error('ExportManager:ReportGenerationError', ...
                    'Erro na geração de relatórios: %s', ME.message);
            end
        end
        
        function success = setupGitLFS(obj)
            % Configura Git LFS para o projeto
            
            success = false;
            
            try
                % Inicializar Git LFS no diretório de backup
                success = obj.backupManager.initializeGitLFS();
                
                if success
                    % Criar .gitattributes no diretório raiz se não existir
                    gitattributesFile = '.gitattributes';
                    if ~exist(gitattributesFile, 'file')
                        obj.createGitAttributesFile(gitattributesFile);
                    end
                    
                    fprintf('Git LFS configurado com sucesso\n');
                else
                    warning('ExportManager:GitLFSWarning', 'Falha ao configurar Git LFS');
                end
                
            catch ME
                warning('ExportManager:GitLFSError', 'Erro ao configurar Git LFS: %s', ME.message);
            end
        end
        
        function validationResults = validateExports(obj, exportResults)
            % Valida integridade dos arquivos exportados
            %
            % Parâmetros:
            %   exportResults - Estrutura com resultados da exportação
            
            validationResults = struct();
            validationResults.total_files = 0;
            validationResults.valid_files = 0;
            validationResults.invalid_files = {};
            validationResults.validation_date = datestr(now);
            
            try
                if isfield(exportResults, 'exported_files')
                    files = exportResults.exported_files;
                    validationResults.total_files = length(files);
                    
                    for i = 1:length(files)
                        filepath = files{i};
                        
                        if exist(filepath, 'file') || exist(filepath, 'dir')
                            validationResults.valid_files = validationResults.valid_files + 1;
                        else
                            validationResults.invalid_files{end+1} = filepath;
                        end
                    end
                end
                
                % Validar modelos ONNX se existirem
                if isfield(exportResults, 'model_files')
                    obj.validateModelExports(exportResults.model_files, validationResults);
                end
                
                % Gerar relatório de validação
                obj.generateValidationReport(validationResults);
                
                fprintf('Validação concluída: %d/%d arquivos válidos\n', ...
                    validationResults.valid_files, validationResults.total_files);
                
            catch ME
                error('ExportManager:ValidationError', ...
                    'Erro na validação: %s', ME.message);
            end
        end
        
        function cleanupOldExports(obj, daysOld)
            % Remove exportações antigas
            %
            % Parâmetros:
            %   daysOld - Idade em dias para considerar "antigo" (padrão: 30)
            
            if nargin < 2
                daysOld = 30;
            end
            
            try
                cutoffDate = now - daysOld;
                
                % Limpar backups antigos
                obj.backupManager.cleanupOldBackups();
                
                % Limpar diretórios de sessão antigos
                sessionsDir = fullfile(obj.outputDirectory, 'sessions');
                if exist(sessionsDir, 'dir')
                    sessions = dir(sessionsDir);
                    sessions = sessions([sessions.isdir] & ~ismember({sessions.name}, {'.', '..'}));
                    
                    for i = 1:length(sessions)
                        sessionDir = fullfile(sessionsDir, sessions(i).name);
                        if sessions(i).datenum < cutoffDate
                            fprintf('Removendo sessão antiga: %s\n', sessions(i).name);
                            rmdir(sessionDir, 's');
                        end
                    end
                end
                
                fprintf('Limpeza de exportações antigas concluída\n');
                
            catch ME
                warning('ExportManager:CleanupError', 'Erro na limpeza: %s', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function initializeExporters(obj, enableGitLFS, enableDICOM)
            % Inicializa todos os componentes de exportação
            
            % DataExporter
            obj.dataExporter = DataExporter('OutputDirectory', ...
                fullfile(obj.outputDirectory, 'data'));
            
            % ModelExporter
            obj.modelExporter = ModelExporter('OutputDirectory', ...
                fullfile(obj.outputDirectory, 'models'));
            
            % ReportGenerator
            obj.reportGenerator = ReportGenerator('OutputDirectory', ...
                fullfile(obj.outputDirectory, 'reports'));
            
            % BackupManager
            obj.backupManager = BackupManager('BackupDirectory', ...
                fullfile(obj.outputDirectory, 'backups'), 'GitLFSEnabled', enableGitLFS);
            
            % VisualizationExporter
            obj.visualizationExporter = VisualizationExporter('OutputDirectory', ...
                fullfile(obj.outputDirectory, 'figures'));
            
            % DICOMExporter (se habilitado)
            if enableDICOM
                obj.dicomExporter = DICOMExporter('OutputDirectory', ...
                    fullfile(obj.outputDirectory, 'dicom'));
            end
        end
        
        function dataFiles = exportScientificData(obj, results, sessionName)
            % Exporta dados em formatos científicos
            
            dataFiles = struct();
            
            % Exportar comparação de métricas
            if isfield(results, 'unet_metrics') && isfield(results, 'attention_metrics')
                comparisonFiles = obj.dataExporter.exportMetricsComparison(...
                    results.unet_metrics, results.attention_metrics, ...
                    sprintf('%s_metrics_comparison', sessionName));
                dataFiles.metrics_comparison = comparisonFiles;
            end
            
            % Exportar dados individuais
            if isfield(results, 'unet_metrics')
                unetFile = obj.dataExporter.exportToCSV(results.unet_metrics, ...
                    sprintf('%s_unet_metrics.csv', sessionName));
                dataFiles.unet_csv = unetFile;
            end
            
            if isfield(results, 'attention_metrics')
                attentionFile = obj.dataExporter.exportToCSV(results.attention_metrics, ...
                    sprintf('%s_attention_metrics.csv', sessionName));
                dataFiles.attention_csv = attentionFile;
            end
        end
        
        function modelFiles = exportModels(obj, models, sessionName)
            % Exporta modelos treinados
            
            modelFiles = obj.exportModelsToStandardFormats(models, sessionName);
        end
        
        function visualFiles = generateVisualizations(obj, results, sessionName)
            % Gera visualizações
            
            visualFiles = {};
            
            % Gráfico de métricas
            if isfield(results, 'unet_metrics') || isfield(results, 'attention_metrics')
                metricsPlot = obj.visualizationExporter.exportMetricsPlot(results, ...
                    sprintf('%s_metrics_plot.png', sessionName), 'CompareModels', true);
                visualFiles{end+1} = metricsPlot;
            end
            
            % Grade de comparação se houver imagens
            if isfield(results, 'sample_images')
                comparisonGrid = obj.visualizationExporter.exportComparisonGrid(...
                    results.sample_images, sprintf('%s_comparison_grid.png', sessionName));
                visualFiles{end+1} = comparisonGrid;
            end
            
            % Curvas de treinamento se disponíveis
            if isfield(results, 'training_history')
                trainingCurves = obj.visualizationExporter.exportTrainingCurves(...
                    results.training_history, sprintf('%s_training_curves.png', sessionName));
                visualFiles{end+1} = trainingCurves;
            end
        end
        
        function reportFiles = generateReports(obj, results, sessionName)
            % Gera relatórios
            
            reportFiles = obj.generateComprehensiveReports(results, sessionName);
        end
        
        function backupFile = createSessionBackup(obj, sessionName)
            % Cria backup da sessão
            
            sessionDir = fullfile(obj.outputDirectory, 'sessions', sessionName);
            if exist(sessionDir, 'dir')
                backupFile = obj.backupManager.createBackup(sessionDir, ...
                    sprintf('session_%s_backup', sessionName));
            else
                backupFile = '';
            end
        end
        
        function indexFile = generateSessionIndex(obj, results, sessionName)
            % Gera índice HTML da sessão
            
            indexFile = fullfile(obj.outputDirectory, sprintf('%s_index.html', sessionName));
            
            try
                html = sprintf('<!DOCTYPE html>\n<html>\n<head>\n');
                html = [html, sprintf('<meta charset="UTF-8">\n')];
                html = [html, sprintf('<title>Índice da Sessão %s</title>\n', sessionName)];
                html = [html, obj.getIndexCSS()];
                html = [html, sprintf('</head>\n<body>\n')];
                
                html = [html, sprintf('<h1>Índice da Sessão: %s</h1>\n', sessionName)];
                html = [html, sprintf('<p>Gerado em: %s</p>\n', results.export_date)];
                
                % Lista de arquivos exportados
                html = [html, sprintf('<h2>Arquivos Exportados</h2>\n')];
                html = [html, sprintf('<ul>\n')];
                
                for i = 1:length(results.exported_files)
                    file = results.exported_files{i};
                    [~, name, ext] = fileparts(file);
                    html = [html, sprintf('<li><a href="%s">%s%s</a></li>\n', file, name, ext)];
                end
                
                html = [html, sprintf('</ul>\n')];
                html = [html, sprintf('</body>\n</html>\n')];
                
                fid = fopen(indexFile, 'w', 'n', 'UTF-8');
                fprintf(fid, '%s', html);
                fclose(fid);
                
            catch ME
                warning('ExportManager:IndexError', 'Erro ao gerar índice: %s', ME.message);
                indexFile = '';
            end
        end
        
        function createGitAttributesFile(obj, filename)
            % Cria arquivo .gitattributes para Git LFS
            
            try
                content = sprintf('# Git LFS tracking\n');
                content = [content, sprintf('*.mat filter=lfs diff=lfs merge=lfs -text\n')];
                content = [content, sprintf('*.h5 filter=lfs diff=lfs merge=lfs -text\n')];
                content = [content, sprintf('*.onnx filter=lfs diff=lfs merge=lfs -text\n')];
                content = [content, sprintf('*.zip filter=lfs diff=lfs merge=lfs -text\n')];
                content = [content, sprintf('*.png filter=lfs diff=lfs merge=lfs -text\n')];
                content = [content, sprintf('*.jpg filter=lfs diff=lfs merge=lfs -text\n')];
                content = [content, sprintf('*.tiff filter=lfs diff=lfs merge=lfs -text\n')];
                
                fid = fopen(filename, 'w');
                fprintf(fid, '%s', content);
                fclose(fid);
                
            catch ME
                warning('ExportManager:GitAttributesError', ...
                    'Erro ao criar .gitattributes: %s', ME.message);
            end
        end
        
        function validateModelExports(obj, modelFiles, validationResults)
            % Valida exportações de modelos
            
            fields = fieldnames(modelFiles);
            for i = 1:length(fields)
                field = fields{i};
                filepath = modelFiles.(field);
                
                if contains(field, 'onnx')
                    % Validar ONNX
                    isValid = obj.modelExporter.validateExportedModel([], filepath, 'onnx');
                    if ~isValid
                        validationResults.invalid_files{end+1} = filepath;
                    end
                end
            end
        end
        
        function generateValidationReport(obj, validationResults)
            % Gera relatório de validação
            
            reportFile = fullfile(obj.outputDirectory, 'validation_report.html');
            
            try
                html = sprintf('<!DOCTYPE html>\n<html>\n<head>\n');
                html = [html, sprintf('<title>Relatório de Validação</title>\n')];
                html = [html, sprintf('</head>\n<body>\n')];
                html = [html, sprintf('<h1>Relatório de Validação</h1>\n')];
                html = [html, sprintf('<p>Data: %s</p>\n', validationResults.validation_date)];
                html = [html, sprintf('<p>Arquivos válidos: %d/%d</p>\n', ...
                    validationResults.valid_files, validationResults.total_files)];
                
                if ~isempty(validationResults.invalid_files)
                    html = [html, sprintf('<h2>Arquivos Inválidos</h2>\n<ul>\n')];
                    for i = 1:length(validationResults.invalid_files)
                        html = [html, sprintf('<li>%s</li>\n', validationResults.invalid_files{i})];
                    end
                    html = [html, sprintf('</ul>\n')];
                end
                
                html = [html, sprintf('</body>\n</html>\n')];
                
                fid = fopen(reportFile, 'w', 'n', 'UTF-8');
                fprintf(fid, '%s', html);
                fclose(fid);
                
            catch ME
                warning('ExportManager:ValidationReportError', ...
                    'Erro ao gerar relatório de validação: %s', ME.message);
            end
        end
        
        function css = getIndexCSS(obj)
            % CSS para índice HTML
            
            css = sprintf('<style>\n');
            css = [css, sprintf('body { font-family: Arial, sans-serif; margin: 40px; }\n')];
            css = [css, sprintf('h1, h2 { color: #333; }\n')];
            css = [css, sprintf('ul { list-style-type: disc; margin-left: 20px; }\n')];
            css = [css, sprintf('a { color: #0066cc; text-decoration: none; }\n')];
            css = [css, sprintf('a:hover { text-decoration: underline; }\n')];
            css = [css, sprintf('</style>\n')];
        end
    end
end