classdef ComponentValidator < handle
    % ComponentValidator - Validação individual de componentes
    % 
    % Valida cada componente do sistema individualmente para garantir
    % que funcionam corretamente de forma isolada.
    
    properties (Access = private)
        logger
        config
        testResults
    end
    
    methods
        function obj = ComponentValidator(config)
            % Construtor
            if nargin < 1
                obj.config = obj.getDefaultConfig();
            else
                obj.config = config;
            end
            
            obj.logger = ValidationLogger('ComponentValidator');
            obj.testResults = struct();
        end
        
        function results = validateAllComponents(obj)
            % Valida todos os componentes do sistema
            obj.logger.info('=== INICIANDO VALIDAÇÃO DE COMPONENTES ===');
            startTime = tic;
            
            try
                % Lista de componentes para validar
                components = {
                    'ModelSaver'
                    'ModelLoader'
                    'GradientMonitor'
                    'OptimizationAnalyzer'
                    'InferenceEngine'
                    'ResultsAnalyzer'
                    'ResultsOrganizer'
                    'ComparisonVisualizer'
                    'DataExporter'
                    'ConfigManager'
                    'MainInterface'
                };
                
                obj.testResults.components = struct();
                obj.testResults.summary = struct();
                
                % Validar cada componente
                for i = 1:length(components)
                    componentName = components{i};
                    obj.logger.info(['Validando ' componentName '...']);
                    
                    try
                        componentResult = obj.validateComponent(componentName);
                        obj.testResults.components.(componentName) = componentResult;
                        
                        if componentResult.isValid
                            obj.logger.info(['✓ ' componentName ' válido']);
                        else
                            obj.logger.warning(['⚠ ' componentName ' com problemas']);
                        end
                        
                    catch ME
                        obj.testResults.components.(componentName) = struct();
                        obj.testResults.components.(componentName).isValid = false;
                        obj.testResults.components.(componentName).error = ME.message;
                        obj.logger.error(['✗ Erro em ' componentName ': ' ME.message]);
                    end
                end
                
                % Calcular resumo
                obj.calculateSummary();
                
                obj.testResults.totalDuration = toc(startTime);
                results = obj.testResults;
                
                obj.logger.info(['=== VALIDAÇÃO DE COMPONENTES FINALIZADA EM ' ...
                    num2str(obj.testResults.totalDuration, '%.2f') ' segundos ===']);
                
            catch ME
                obj.logger.error(['Erro geral na validação: ' ME.message]);
                obj.testResults.generalError = ME.message;
                obj.testResults.overallSuccess = false;
                results = obj.testResults;
            end
        end
        
        function result = validateComponent(obj, componentName)
            % Valida um componente específico
            result = struct();
            result.componentName = componentName;
            result.isValid = false;
            result.tests = struct();
            
            % Encontrar arquivo do componente
            componentFile = obj.findComponentFile(componentName);
            
            if isempty(componentFile)
                result.error = 'Arquivo do componente não encontrado';
                return;
            end
            
            result.filePath = componentFile;
            
            % Testes básicos
            result.tests.fileExists = exist(componentFile, 'file') == 2;
            result.tests.canParse = obj.testSyntax(componentFile);
            result.tests.canInstantiate = obj.testInstantiation(componentName, componentFile);
            result.tests.hasRequiredMethods = obj.testRequiredMethods(componentName, componentFile);
            result.tests.hasDocumentation = obj.testDocumentation(componentFile);
            
            % Testes específicos por tipo de componente
            result.tests.specificTests = obj.runSpecificTests(componentName, componentFile);
            
            % Determinar se componente é válido
            result.isValid = result.tests.fileExists && ...
                result.tests.canParse && ...
                result.tests.canInstantiate;
            
            % Calcular score de qualidade
            result.qualityScore = obj.calculateComponentQuality(result.tests);
        end
        
        function componentFile = findComponentFile(obj, componentName)
            % Encontra arquivo do componente
            searchPaths = {
                fullfile('src', 'model_management', [componentName '.m'])
                fullfile('src', 'optimization', [componentName '.m'])
                fullfile('src', 'inference', [componentName '.m'])
                fullfile('src', 'organization', [componentName '.m'])
                fullfile('src', 'visualization', [componentName '.m'])
                fullfile('src', 'export', [componentName '.m'])
                fullfile('src', 'core', [componentName '.m'])
                fullfile('src', 'utils', [componentName '.m'])
                fullfile('src', 'evaluation', [componentName '.m'])
            };
            
            componentFile = '';
            for i = 1:length(searchPaths)
                if exist(searchPaths{i}, 'file')
                    componentFile = searchPaths{i};
                    break;
                end
            end
        end
        
        function canParse = testSyntax(obj, componentFile)
            % Testa se arquivo tem sintaxe válida
            try
                % Tentar ler e verificar sintaxe básica
                fid = fopen(componentFile, 'r');
                if fid == -1
                    canParse = false;
                    return;
                end
                
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificações básicas de sintaxe
                canParse = contains(content, 'classdef') || contains(content, 'function');
                
            catch
                canParse = false;
            end
        end
        
        function canInstantiate = testInstantiation(obj, componentName, componentFile)
            % Testa se componente pode ser instanciado
            try
                % Adicionar caminho temporariamente
                [filePath, ~, ~] = fileparts(componentFile);
                addpath(filePath);
                
                % Tentar instanciar
                if exist(componentName, 'class')
                    % É uma classe - tentar instanciar
                    try
                        instance = eval([componentName '()']);
                        canInstantiate = true;
                        clear instance;
                    catch
                        % Tentar com parâmetros padrão
                        try
                            instance = eval([componentName '(struct())']);
                            canInstantiate = true;
                            clear instance;
                        catch
                            canInstantiate = false;
                        end
                    end
                else
                    % É uma função - verificar se existe
                    canInstantiate = exist(componentName, 'file') == 2;
                end
                
            catch
                canInstantiate = false;
            end
        end
        
        function hasRequired = testRequiredMethods(obj, componentName, componentFile)
            % Testa se componente tem métodos obrigatórios
            try
                fid = fopen(componentFile, 'r');
                if fid == -1
                    hasRequired = false;
                    return;
                end
                
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificar se é classe
                if contains(content, 'classdef')
                    % Para classes, verificar construtor
                    hasRequired = contains(content, ['function obj = ' componentName]);
                else
                    % Para funções, assumir que está OK se arquivo existe
                    hasRequired = true;
                end
                
            catch
                hasRequired = false;
            end
        end
        
        function hasDoc = testDocumentation(obj, componentFile)
            % Testa se componente tem documentação
            try
                fid = fopen(componentFile, 'r');
                if fid == -1
                    hasDoc = false;
                    return;
                end
                
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificar se tem comentários de documentação
                hasDoc = contains(content, '%') && ...
                    (contains(content, 'classdef') || contains(content, 'function'));
                
            catch
                hasDoc = false;
            end
        end      
  
        function specificResults = runSpecificTests(obj, componentName, componentFile)
            % Executa testes específicos por tipo de componente
            specificResults = struct();
            
            switch componentName
                case 'ModelSaver'
                    specificResults = obj.testModelSaver(componentFile);
                case 'ModelLoader'
                    specificResults = obj.testModelLoader(componentFile);
                case 'GradientMonitor'
                    specificResults = obj.testGradientMonitor(componentFile);
                case 'InferenceEngine'
                    specificResults = obj.testInferenceEngine(componentFile);
                case 'ResultsOrganizer'
                    specificResults = obj.testResultsOrganizer(componentFile);
                case 'ComparisonVisualizer'
                    specificResults = obj.testComparisonVisualizer(componentFile);
                case 'DataExporter'
                    specificResults = obj.testDataExporter(componentFile);
                case 'ConfigManager'
                    specificResults = obj.testConfigManager(componentFile);
                otherwise
                    specificResults.tested = false;
                    specificResults.reason = 'Testes específicos não implementados';
            end
        end
        
        function result = testModelSaver(obj, componentFile)
            % Testa ModelSaver especificamente
            result = struct();
            
            try
                fid = fopen(componentFile, 'r');
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificar métodos essenciais
                result.hasSaveModel = contains(content, 'saveModel');
                result.hasCleanup = contains(content, 'cleanup') || contains(content, 'cleanupOldModels');
                result.hasMetadata = contains(content, 'metadata') || contains(content, 'Metadata');
                
                result.score = (result.hasSaveModel + result.hasCleanup + result.hasMetadata) / 3;
                result.tested = true;
                
            catch ME
                result.tested = false;
                result.error = ME.message;
                result.score = 0;
            end
        end
        
        function result = testModelLoader(obj, componentFile)
            % Testa ModelLoader especificamente
            result = struct();
            
            try
                fid = fopen(componentFile, 'r');
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificar métodos essenciais
                result.hasLoadModel = contains(content, 'loadModel');
                result.hasListModels = contains(content, 'listAvailableModels') || contains(content, 'list');
                result.hasValidation = contains(content, 'validate') || contains(content, 'Validation');
                
                result.score = (result.hasLoadModel + result.hasListModels + result.hasValidation) / 3;
                result.tested = true;
                
            catch ME
                result.tested = false;
                result.error = ME.message;
                result.score = 0;
            end
        end
        
        function result = testGradientMonitor(obj, componentFile)
            % Testa GradientMonitor especificamente
            result = struct();
            
            try
                fid = fopen(componentFile, 'r');
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificar funcionalidades essenciais
                result.hasRecordGradients = contains(content, 'recordGradients') || contains(content, 'record');
                result.hasDetectProblems = contains(content, 'detect') || contains(content, 'Problems');
                result.hasVisualization = contains(content, 'plot') || contains(content, 'visualiz');
                
                result.score = (result.hasRecordGradients + result.hasDetectProblems + result.hasVisualization) / 3;
                result.tested = true;
                
            catch ME
                result.tested = false;
                result.error = ME.message;
                result.score = 0;
            end
        end
        
        function result = testInferenceEngine(obj, componentFile)
            % Testa InferenceEngine especificamente
            result = struct();
            
            try
                fid = fopen(componentFile, 'r');
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificar funcionalidades essenciais
                result.hasSegmentImages = contains(content, 'segmentImages') || contains(content, 'segment');
                result.hasCalculateMetrics = contains(content, 'calculateMetrics') || contains(content, 'metrics');
                result.hasBatchProcessing = contains(content, 'batch') || contains(content, 'Batch');
                
                result.score = (result.hasSegmentImages + result.hasCalculateMetrics + result.hasBatchProcessing) / 3;
                result.tested = true;
                
            catch ME
                result.tested = false;
                result.error = ME.message;
                result.score = 0;
            end
        end
        
        function result = testResultsOrganizer(obj, componentFile)
            % Testa ResultsOrganizer especificamente
            result = struct();
            
            try
                fid = fopen(componentFile, 'r');
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificar funcionalidades essenciais
                result.hasOrganizeResults = contains(content, 'organizeResults') || contains(content, 'organize');
                result.hasCreateDirectories = contains(content, 'createDirectory') || contains(content, 'mkdir');
                result.hasHTMLGeneration = contains(content, 'HTML') || contains(content, 'generateIndex');
                
                result.score = (result.hasOrganizeResults + result.hasCreateDirectories + result.hasHTMLGeneration) / 3;
                result.tested = true;
                
            catch ME
                result.tested = false;
                result.error = ME.message;
                result.score = 0;
            end
        end
        
        function result = testComparisonVisualizer(obj, componentFile)
            % Testa ComparisonVisualizer especificamente
            result = struct();
            
            try
                fid = fopen(componentFile, 'r');
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificar funcionalidades essenciais
                result.hasSideBySide = contains(content, 'sideBySide') || contains(content, 'comparison');
                result.hasDifferenceMap = contains(content, 'difference') || contains(content, 'diff');
                result.hasGallery = contains(content, 'gallery') || contains(content, 'Gallery');
                
                result.score = (result.hasSideBySide + result.hasDifferenceMap + result.hasGallery) / 3;
                result.tested = true;
                
            catch ME
                result.tested = false;
                result.error = ME.message;
                result.score = 0;
            end
        end
        
        function result = testDataExporter(obj, componentFile)
            % Testa DataExporter especificamente
            result = struct();
            
            try
                fid = fopen(componentFile, 'r');
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificar funcionalidades essenciais
                result.hasCSVExport = contains(content, 'CSV') || contains(content, 'csv');
                result.hasExcelExport = contains(content, 'Excel') || contains(content, 'xlsx');
                result.hasLaTeXExport = contains(content, 'LaTeX') || contains(content, 'latex');
                
                result.score = (result.hasCSVExport + result.hasExcelExport + result.hasLaTeXExport) / 3;
                result.tested = true;
                
            catch ME
                result.tested = false;
                result.error = ME.message;
                result.score = 0;
            end
        end
        
        function result = testConfigManager(obj, componentFile)
            % Testa ConfigManager especificamente
            result = struct();
            
            try
                fid = fopen(componentFile, 'r');
                content = fread(fid, '*char')';
                fclose(fid);
                
                % Verificar funcionalidades essenciais
                result.hasSetParameter = contains(content, 'setParameter') || contains(content, 'set');
                result.hasGetParameter = contains(content, 'getParameter') || contains(content, 'get');
                result.hasSaveConfig = contains(content, 'save') || contains(content, 'Save');
                
                result.score = (result.hasSetParameter + result.hasGetParameter + result.hasSaveConfig) / 3;
                result.tested = true;
                
            catch ME
                result.tested = false;
                result.error = ME.message;
                result.score = 0;
            end
        end
        
        function quality = calculateComponentQuality(obj, tests)
            % Calcula score de qualidade do componente
            weights = struct();
            weights.fileExists = 0.2;
            weights.canParse = 0.2;
            weights.canInstantiate = 0.3;
            weights.hasRequiredMethods = 0.2;
            weights.hasDocumentation = 0.1;
            
            quality = 0;
            
            if tests.fileExists
                quality = quality + 100 * weights.fileExists;
            end
            
            if tests.canParse
                quality = quality + 100 * weights.canParse;
            end
            
            if tests.canInstantiate
                quality = quality + 100 * weights.canInstantiate;
            end
            
            if tests.hasRequiredMethods
                quality = quality + 100 * weights.hasRequiredMethods;
            end
            
            if tests.hasDocumentation
                quality = quality + 100 * weights.hasDocumentation;
            end
            
            % Adicionar score de testes específicos se disponível
            if isfield(tests, 'specificTests') && isfield(tests.specificTests, 'score')
                quality = quality * 0.8 + tests.specificTests.score * 100 * 0.2;
            end
        end
        
        function calculateSummary(obj)
            % Calcula resumo da validação de componentes
            componentNames = fieldnames(obj.testResults.components);
            totalComponents = length(componentNames);
            validComponents = 0;
            totalQuality = 0;
            
            for i = 1:totalComponents
                componentName = componentNames{i};
                component = obj.testResults.components.(componentName);
                
                if isfield(component, 'isValid') && component.isValid
                    validComponents = validComponents + 1;
                end
                
                if isfield(component, 'qualityScore')
                    totalQuality = totalQuality + component.qualityScore;
                end
            end
            
            obj.testResults.summary.totalComponents = totalComponents;
            obj.testResults.summary.validComponents = validComponents;
            obj.testResults.summary.invalidComponents = totalComponents - validComponents;
            obj.testResults.summary.validationRate = validComponents / totalComponents;
            obj.testResults.summary.averageQuality = totalQuality / totalComponents;
            obj.testResults.overallSuccess = validComponents == totalComponents;
            
            obj.logger.info(['Resumo: ' num2str(validComponents) '/' ...
                num2str(totalComponents) ' componentes válidos (' ...
                num2str(obj.testResults.summary.validationRate * 100, '%.1f') '%)']);
            obj.logger.info(['Qualidade média: ' ...
                num2str(obj.testResults.summary.averageQuality, '%.1f') '/100']);
        end
        
        function config = getDefaultConfig(obj)
            % Configuração padrão
            config = struct();
            config.strictValidation = false;
            config.testInstantiation = true;
            config.testDocumentation = true;
            config.runSpecificTests = true;
        end
    end
end