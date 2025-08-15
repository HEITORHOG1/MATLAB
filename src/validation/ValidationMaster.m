classdef ValidationMaster < handle
    % ValidationMaster - Coordenador principal da validação completa do sistema
    % 
    % Esta classe orquestra todos os testes de validação, incluindo integração,
    % regressão, performance e geração de documentação final.
    
    properties (Access = private)
        logger
        config
        startTime
        results
        outputDir
    end
    
    methods
        function obj = ValidationMaster(config)
            % Construtor do ValidationMaster
            if nargin < 1
                obj.config = obj.getDefaultConfig();
            else
                obj.config = config;
            end
            
            obj.logger = ValidationLogger('ValidationMaster');
            obj.outputDir = fullfile('validation_results', ...
                ['validation_' datestr(now, 'yyyymmdd_HHMMSS')]);
            
            % Criar diretório de saída
            if ~exist(obj.outputDir, 'dir')
                mkdir(obj.outputDir);
            end
            
            obj.logger.info('ValidationMaster inicializado');
            obj.logger.info(['Diretório de saída: ' obj.outputDir]);
        end
        
        function results = runCompleteValidation(obj)
            % Executa validação completa do sistema
            obj.startTime = tic;
            obj.logger.info('=== INICIANDO VALIDAÇÃO COMPLETA DO SISTEMA ===');
            
            try
                % Inicializar estrutura de resultados
                obj.results = struct();
                
                % 1. Testes de Integração
                obj.logger.info('Executando testes de integração...');
                obj.results.integration = obj.runIntegrationTests();
                
                % 2. Testes de Regressão
                obj.logger.info('Executando testes de regressão...');
                obj.results.regression = obj.runRegressionTests();
                
                % 3. Testes de Performance
                obj.logger.info('Executando testes de performance...');
                obj.results.performance = obj.runPerformanceTests();
                
                % 4. Validação de Componentes
                obj.logger.info('Validando componentes individuais...');
                obj.results.components = obj.validateComponents();
                
                % 5. Testes de Compatibilidade
                obj.logger.info('Testando compatibilidade...');
                obj.results.compatibility = obj.testCompatibility();
                
                % 6. Geração de Documentação
                obj.logger.info('Gerando documentação...');
                obj.results.documentation = obj.generateDocumentation();
                
                % 7. Relatório Final
                obj.logger.info('Gerando relatório final...');
                obj.results.finalReport = obj.generateFinalReport();
                
                % Calcular tempo total
                obj.results.totalTime = toc(obj.startTime);
                obj.results.success = obj.evaluateOverallSuccess();
                
                obj.logger.info(['=== VALIDAÇÃO COMPLETA FINALIZADA EM ' ...
                    num2str(obj.results.totalTime, '%.2f') ' segundos ===']);
                
                if obj.results.success
                    obj.logger.info('✓ VALIDAÇÃO BEM-SUCEDIDA - Sistema aprovado');
                else
                    obj.logger.warning('⚠ VALIDAÇÃO COM PROBLEMAS - Revisar relatório');
                end
                
                results = obj.results;
                
            catch ME
                obj.logger.error(['Erro durante validação: ' ME.message]);
                obj.results.error = ME;
                obj.results.success = false;
                results = obj.results;
                rethrow(ME);
            end
        end
        
        function results = runIntegrationTests(obj)
            % Executa testes de integração completos
            integrationSuite = IntegrationTestSuite(obj.config);
            results = integrationSuite.runAllTests();
            
            % Salvar resultados
            resultsFile = fullfile(obj.outputDir, 'integration_results.mat');
            save(resultsFile, 'results');
            obj.logger.info(['Resultados de integração salvos em: ' resultsFile]);
        end
        
        function results = runRegressionTests(obj)
            % Executa testes de regressão
            regressionSuite = RegressionTestSuite(obj.config);
            results = regressionSuite.runAllTests();
            
            % Salvar resultados
            resultsFile = fullfile(obj.outputDir, 'regression_results.mat');
            save(resultsFile, 'results');
            obj.logger.info(['Resultados de regressão salvos em: ' resultsFile]);
        end
        
        function results = runPerformanceTests(obj)
            % Executa testes de performance
            performanceSuite = PerformanceTestSuite(obj.config);
            results = performanceSuite.runAllTests();
            
            % Salvar resultados
            resultsFile = fullfile(obj.outputDir, 'performance_results.mat');
            save(resultsFile, 'results');
            obj.logger.info(['Resultados de performance salvos em: ' resultsFile]);
        end
        
        function results = validateComponents(obj)
            % Valida componentes individuais
            validator = ComponentValidator(obj.config);
            results = validator.validateAllComponents();
            
            % Salvar resultados
            resultsFile = fullfile(obj.outputDir, 'component_validation.mat');
            save(resultsFile, 'results');
            obj.logger.info(['Validação de componentes salva em: ' resultsFile]);
        end
        
        function results = testCompatibility(obj)
            % Testa compatibilidade com sistema anterior
            compatibilityTester = BackwardCompatibilityTester(obj.config);
            results = compatibilityTester.runAllTests();
            
            % Salvar resultados
            resultsFile = fullfile(obj.outputDir, 'compatibility_results.mat');
            save(resultsFile, 'results');
            obj.logger.info(['Resultados de compatibilidade salvos em: ' resultsFile]);
        end
        
        function results = generateDocumentation(obj)
            % Gera documentação completa
            docGenerator = DocumentationGenerator(obj.config);
            results = docGenerator.generateCompleteDocumentation(obj.outputDir);
            
            obj.logger.info('Documentação completa gerada');
        end
        
        function results = generateFinalReport(obj)
            % Gera relatório final de qualidade
            reportGenerator = QualityReportGenerator(obj.config);
            results = reportGenerator.generateFinalReport(obj.results, obj.outputDir);
            
            obj.logger.info('Relatório final de qualidade gerado');
        end
        
        function success = evaluateOverallSuccess(obj)
            % Avalia sucesso geral da validação
            success = true;
            
            % Verificar cada categoria de teste
            if isfield(obj.results, 'integration') && ...
               isfield(obj.results.integration, 'overallSuccess')
                success = success && obj.results.integration.overallSuccess;
            end
            
            if isfield(obj.results, 'regression') && ...
               isfield(obj.results.regression, 'overallSuccess')
                success = success && obj.results.regression.overallSuccess;
            end
            
            if isfield(obj.results, 'performance') && ...
               isfield(obj.results.performance, 'overallSuccess')
                success = success && obj.results.performance.overallSuccess;
            end
            
            if isfield(obj.results, 'components') && ...
               isfield(obj.results.components, 'overallSuccess')
                success = success && obj.results.components.overallSuccess;
            end
            
            if isfield(obj.results, 'compatibility') && ...
               isfield(obj.results.compatibility, 'overallSuccess')
                success = success && obj.results.compatibility.overallSuccess;
            end
        end
        
        function config = getDefaultConfig(obj)
            % Configuração padrão para validação
            config = struct();
            config.testDataPath = 'img';
            config.outputPath = 'validation_results';
            config.enablePerformanceTests = true;
            config.enableRegressionTests = true;
            config.enableIntegrationTests = true;
            config.enableDocumentationGeneration = true;
            config.verboseLogging = true;
            config.generateDetailedReports = true;
            config.runQuickTests = false; % false para testes completos
            config.maxTestTime = 3600; % 1 hora máximo por categoria
        end
        
        function printSummary(obj)
            % Imprime resumo dos resultados
            if isempty(obj.results)
                fprintf('Nenhuma validação executada ainda.\n');
                return;
            end
            
            fprintf('\n=== RESUMO DA VALIDAÇÃO ===\n');
            fprintf('Tempo total: %.2f segundos\n', obj.results.totalTime);
            fprintf('Status geral: %s\n', obj.getStatusString(obj.results.success));
            
            if isfield(obj.results, 'integration')
                fprintf('Testes de integração: %s\n', ...
                    obj.getStatusString(obj.results.integration.overallSuccess));
            end
            
            if isfield(obj.results, 'regression')
                fprintf('Testes de regressão: %s\n', ...
                    obj.getStatusString(obj.results.regression.overallSuccess));
            end
            
            if isfield(obj.results, 'performance')
                fprintf('Testes de performance: %s\n', ...
                    obj.getStatusString(obj.results.performance.overallSuccess));
            end
            
            fprintf('Relatórios salvos em: %s\n', obj.outputDir);
            fprintf('========================\n\n');
        end
        
        function statusStr = getStatusString(obj, success)
            % Converte status booleano em string
            if success
                statusStr = '✓ SUCESSO';
            else
                statusStr = '✗ FALHA';
            end
        end
    end
end