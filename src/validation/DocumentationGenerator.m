classdef DocumentationGenerator < handle
    % DocumentationGenerator - Geração automática de documentação completa
    % 
    % Gera documentação abrangente do sistema incluindo guias de uso,
    % referência de API, exemplos práticos e guia de migração.
    
    properties (Access = private)
        logger
        config
        outputDir
        templateDir
    end
    
    methods
        function obj = DocumentationGenerator(config)
            % Construtor
            if nargin < 1
                obj.config = obj.getDefaultConfig();
            else
                obj.config = config;
            end
            
            obj.logger = ValidationLogger('DocumentationGenerator');
            obj.templateDir = fullfile('src', 'validation', 'templates');
        end
        
        function results = generateCompleteDocumentation(obj, outputDir)
            % Gera documentação completa do sistema
            if nargin < 2
                outputDir = fullfile('validation_results', 'documentation');
            end
            
            obj.outputDir = outputDir;
            
            obj.logger.info('=== INICIANDO GERAÇÃO DE DOCUMENTAÇÃO ===');
            startTime = tic;
            
            try
                % Criar estrutura de diretórios
                obj.createDocumentationStructure();
                
                % Gerar diferentes tipos de documentação
                results = struct();
                results.userGuide = obj.generateUserGuide();
                results.apiReference = obj.generateAPIReference();
                results.migrationGuide = obj.generateMigrationGuide();
                results.examples = obj.generateExamples();
                results.troubleshooting = obj.generateTroubleshootingGuide();
                results.changelog = obj.generateChangelog();
                results.installation = obj.generateInstallationGuide();
                results.performance = obj.generatePerformanceGuide();
                
                % Gerar índice principal
                results.mainIndex = obj.generateMainIndex();
                
                results.totalTime = toc(startTime);
                results.success = true;
                
                obj.logger.info(['=== DOCUMENTAÇÃO GERADA EM ' ...
                    num2str(results.totalTime, '%.2f') ' segundos ===']);
                
            catch ME
                obj.logger.error(['Erro na geração de documentação: ' ME.message]);
                results = struct();
                results.error = ME.message;
                results.success = false;
            end
        end
        
        function createDocumentationStructure(obj)
            % Cria estrutura de diretórios para documentação
            dirs = {
                obj.outputDir
                fullfile(obj.outputDir, 'user_guide')
                fullfile(obj.outputDir, 'api_reference')
                fullfile(obj.outputDir, 'examples')
                fullfile(obj.outputDir, 'migration')
                fullfile(obj.outputDir, 'troubleshooting')
                fullfile(obj.outputDir, 'assets')
                fullfile(obj.outputDir, 'assets', 'images')
                fullfile(obj.outputDir, 'assets', 'css')
            };
            
            for i = 1:length(dirs)
                if ~exist(dirs{i}, 'dir')
                    mkdir(dirs{i});
                end
            end
            
            obj.logger.info('Estrutura de documentação criada');
        end
        
        function result = generateUserGuide(obj)
            % Gera guia do usuário
            obj.logger.info('Gerando guia do usuário...');
            
            userGuideContent = obj.createUserGuideContent();
            
            % Salvar como HTML
            htmlFile = fullfile(obj.outputDir, 'user_guide', 'index.html');
            obj.writeHTMLFile(htmlFile, 'Guia do Usuário', userGuideContent);
            
            % Salvar como Markdown
            mdFile = fullfile(obj.outputDir, 'user_guide', 'user_guide.md');
            obj.writeMarkdownFile(mdFile, userGuideContent);
            
            result = struct();
            result.htmlFile = htmlFile;
            result.markdownFile = mdFile;
            result.success = true;
            
            obj.logger.info('✓ Guia do usuário gerado');
        end
        
        function result = generateAPIReference(obj)
            % Gera referência da API
            obj.logger.info('Gerando referência da API...');
            
            apiContent = obj.createAPIReferenceContent();
            
            % Salvar documentação da API
            htmlFile = fullfile(obj.outputDir, 'api_reference', 'index.html');
            obj.writeHTMLFile(htmlFile, 'Referência da API', apiContent);
            
            result = struct();
            result.htmlFile = htmlFile;
            result.success = true;
            
            obj.logger.info('✓ Referência da API gerada');
        end
        
        function result = generateMigrationGuide(obj)
            % Gera guia de migração
            obj.logger.info('Gerando guia de migração...');
            
            migrationContent = obj.createMigrationGuideContent();
            
            htmlFile = fullfile(obj.outputDir, 'migration', 'index.html');
            obj.writeHTMLFile(htmlFile, 'Guia de Migração', migrationContent);
            
            mdFile = fullfile(obj.outputDir, 'migration', 'migration_guide.md');
            obj.writeMarkdownFile(mdFile, migrationContent);
            
            result = struct();
            result.htmlFile = htmlFile;
            result.markdownFile = mdFile;
            result.success = true;
            
            obj.logger.info('✓ Guia de migração gerado');
        end  
      
        function result = generateExamples(obj)
            % Gera exemplos práticos
            obj.logger.info('Gerando exemplos práticos...');
            
            examplesContent = obj.createExamplesContent();
            
            htmlFile = fullfile(obj.outputDir, 'examples', 'index.html');
            obj.writeHTMLFile(htmlFile, 'Exemplos Práticos', examplesContent);
            
            % Gerar arquivos de exemplo MATLAB
            obj.generateMATLABExamples();
            
            result = struct();
            result.htmlFile = htmlFile;
            result.success = true;
            
            obj.logger.info('✓ Exemplos práticos gerados');
        end
        
        function result = generateTroubleshootingGuide(obj)
            % Gera guia de solução de problemas
            obj.logger.info('Gerando guia de troubleshooting...');
            
            troubleshootingContent = obj.createTroubleshootingContent();
            
            htmlFile = fullfile(obj.outputDir, 'troubleshooting', 'index.html');
            obj.writeHTMLFile(htmlFile, 'Solução de Problemas', troubleshootingContent);
            
            result = struct();
            result.htmlFile = htmlFile;
            result.success = true;
            
            obj.logger.info('✓ Guia de troubleshooting gerado');
        end
        
        function result = generateChangelog(obj)
            % Gera changelog
            obj.logger.info('Gerando changelog...');
            
            changelogContent = obj.createChangelogContent();
            
            htmlFile = fullfile(obj.outputDir, 'CHANGELOG.html');
            obj.writeHTMLFile(htmlFile, 'Changelog', changelogContent);
            
            mdFile = fullfile(obj.outputDir, 'CHANGELOG.md');
            obj.writeMarkdownFile(mdFile, changelogContent);
            
            result = struct();
            result.htmlFile = htmlFile;
            result.markdownFile = mdFile;
            result.success = true;
            
            obj.logger.info('✓ Changelog gerado');
        end
        
        function result = generateInstallationGuide(obj)
            % Gera guia de instalação
            obj.logger.info('Gerando guia de instalação...');
            
            installationContent = obj.createInstallationContent();
            
            htmlFile = fullfile(obj.outputDir, 'INSTALLATION.html');
            obj.writeHTMLFile(htmlFile, 'Guia de Instalação', installationContent);
            
            result = struct();
            result.htmlFile = htmlFile;
            result.success = true;
            
            obj.logger.info('✓ Guia de instalação gerado');
        end
        
        function result = generatePerformanceGuide(obj)
            % Gera guia de performance
            obj.logger.info('Gerando guia de performance...');
            
            performanceContent = obj.createPerformanceContent();
            
            htmlFile = fullfile(obj.outputDir, 'performance_guide.html');
            obj.writeHTMLFile(htmlFile, 'Guia de Performance', performanceContent);
            
            result = struct();
            result.htmlFile = htmlFile;
            result.success = true;
            
            obj.logger.info('✓ Guia de performance gerado');
        end
        
        function result = generateMainIndex(obj)
            % Gera índice principal da documentação
            obj.logger.info('Gerando índice principal...');
            
            indexContent = obj.createMainIndexContent();
            
            htmlFile = fullfile(obj.outputDir, 'index.html');
            obj.writeHTMLFile(htmlFile, 'Documentação do Sistema de Segmentação', indexContent);
            
            result = struct();
            result.htmlFile = htmlFile;
            result.success = true;
            
            obj.logger.info('✓ Índice principal gerado');
        end
        
        function content = createUserGuideContent(obj)
            % Cria conteúdo do guia do usuário
            content = {
                '# Guia do Usuário - Sistema de Segmentação Melhorado'
                ''
                '## Introdução'
                ''
                'Este sistema implementa melhorias significativas no pipeline de comparação'
                'entre U-Net e Attention U-Net para segmentação de imagens, incluindo:'
                ''
                '- Salvamento e carregamento automático de modelos'
                '- Monitoramento avançado de gradientes'
                '- Sistema de inferência robusto'
                '- Organização automática de resultados'
                '- Visualizações avançadas'
                '- Exportação para formatos científicos'
                ''
                '## Início Rápido'
                ''
                '### 1. Executar Comparação Básica'
                ''
                '```matlab'
                '% Executar sistema principal'
                'executar_comparacao;'
                '```'
                ''
                '### 2. Usar Sistema Melhorado'
                ''
                '```matlab'
                '% Carregar interface principal'
                'addpath(''src/core'');'
                'interface = MainInterface();'
                'interface.runComparison();'
                '```'
                ''
                '## Funcionalidades Principais'
                ''
                '### Gerenciamento de Modelos'
                ''
                'O sistema agora salva automaticamente todos os modelos treinados:'
                ''
                '```matlab'
                '% Carregar modelo salvo'
                'addpath(''src/model_management'');'
                'loader = ModelLoader();'
                'model = loader.loadBestModel(''models'', ''dice'');'
                '```'
                ''
                '### Monitoramento de Treinamento'
                ''
                'Monitore gradientes durante o treinamento:'
                ''
                '```matlab'
                '% Configurar monitoramento'
                'addpath(''src/optimization'');'
                'monitor = GradientMonitor(network);'
                'monitor.recordGradients(network, epoch);'
                '```'
                ''
                '### Sistema de Inferência'
                ''
                'Execute inferência em novas imagens:'
                ''
                '```matlab'
                '% Executar inferência'
                'addpath(''src/inference'');'
                'engine = InferenceEngine();'
                'results = engine.segmentImages(model, imagePaths);'
                '```'
                ''
                '### Organização de Resultados'
                ''
                'Organize automaticamente os resultados:'
                ''
                '```matlab'
                '% Organizar resultados'
                'addpath(''src/organization'');'
                'organizer = ResultsOrganizer();'
                'organizer.organizeResults(unetResults, attentionResults, sessionId);'
                '```'
                ''
                '## Configuração'
                ''
                'O sistema pode ser configurado através do ConfigManager:'
                ''
                '```matlab'
                'addpath(''src/core'');'
                'config = ConfigManager();'
                'config.setParameter(''outputPath'', ''meus_resultados'');'
                'config.setParameter(''enableGradientMonitoring'', true);'
                '```'
                ''
                '## Solução de Problemas'
                ''
                'Para problemas comuns, consulte o guia de troubleshooting ou:'
                ''
                '1. Verifique se todos os caminhos estão corretos'
                '2. Confirme que as dependências estão instaladas'
                '3. Consulte os logs em validation_results/logs/'
                ''
                '## Suporte'
                ''
                'Para suporte adicional, consulte:'
                '- Referência da API'
                '- Exemplos práticos'
                '- Guia de migração'
            };
        end     
   
        function content = createAPIReferenceContent(obj)
            % Cria conteúdo da referência da API
            content = {
                '# Referência da API'
                ''
                '## Módulos Principais'
                ''
                '### src/model_management/'
                ''
                '#### ModelSaver'
                '- `saveModel(model, modelType, metrics, config)` - Salva modelo treinado'
                '- `saveModelWithGradients(model, gradientHistory)` - Salva com histórico'
                '- `cleanupOldModels(maxModels)` - Remove modelos antigos'
                ''
                '#### ModelLoader'
                '- `loadModel(modelPath)` - Carrega modelo específico'
                '- `listAvailableModels(directory)` - Lista modelos disponíveis'
                '- `loadBestModel(directory, metric)` - Carrega melhor modelo'
                ''
                '### src/optimization/'
                ''
                '#### GradientMonitor'
                '- `recordGradients(network, epoch)` - Registra gradientes'
                '- `detectGradientProblems()` - Detecta problemas'
                '- `plotGradientEvolution()` - Visualiza evolução'
                ''
                '#### OptimizationAnalyzer'
                '- `suggestOptimizations()` - Sugere melhorias'
                '- `analyzeConvergence()` - Analisa convergência'
                ''
                '### src/inference/'
                ''
                '#### InferenceEngine'
                '- `segmentImages(model, imagePaths)` - Segmenta imagens'
                '- `segmentWithConfidence(model, imagePaths)` - Com confiança'
                '- `calculateBatchMetrics(results, groundTruth)` - Calcula métricas'
                ''
                '#### ResultsAnalyzer'
                '- `generateStatistics(allResults)` - Gera estatísticas'
                '- `detectOutliers(metrics)` - Detecta outliers'
                ''
                '### src/organization/'
                ''
                '#### ResultsOrganizer'
                '- `organizeResults(unetResults, attentionResults, session)` - Organiza'
                '- `createDirectoryStructure(sessionId)` - Cria estrutura'
                '- `generateHTMLIndex(sessionId)` - Gera índice HTML'
                ''
                '### src/visualization/'
                ''
                '#### ComparisonVisualizer'
                '- `createSideBySideComparison()` - Comparação lado a lado'
                '- `createDifferenceMap()` - Mapa de diferenças'
                '- `generateComparisonGallery()` - Galeria de comparações'
                ''
                '### src/export/'
                ''
                '#### DataExporter'
                '- `exportToCSV(data, filename)` - Exporta para CSV'
                '- `exportToExcel(data, filename)` - Exporta para Excel'
                '- `exportToLaTeX(data, filename)` - Exporta para LaTeX'
                ''
                '#### ModelExporter'
                '- `exportToONNX(model, filename)` - Exporta para ONNX'
                '- `exportMetadata(model, filename)` - Exporta metadados'
                ''
                '## Estruturas de Dados'
                ''
                '### ModelMetadata'
                '```matlab'
                'struct ModelMetadata'
                '    modelType           % ''unet'' | ''attention_unet'''
                '    timestamp          % datetime de criação'
                '    trainingConfig     % configurações de treinamento'
                '    performance        % métricas de performance'
                '    trainingHistory    % histórico de treinamento'
                'end'
                '```'
                ''
                '### SegmentationResult'
                '```matlab'
                'struct SegmentationResult'
                '    imagePath         % caminho da imagem'
                '    segmentationPath  % caminho da segmentação'
                '    modelUsed        % modelo utilizado'
                '    metrics          % métricas calculadas'
                '    processingTime   % tempo de processamento'
                'end'
                '```'
                ''
                '## Configuração'
                ''
                'O sistema usa estruturas de configuração padronizadas:'
                ''
                '```matlab'
                'config = struct();'
                'config.outputPath = ''output'';'
                'config.enableGradientMonitoring = true;'
                'config.maxModelsToKeep = 10;'
                'config.compressionLevel = 6;'
                '```'
            };
        end
        
        function content = createMigrationGuideContent(obj)
            % Cria conteúdo do guia de migração
            content = {
                '# Guia de Migração'
                ''
                '## Migração do Sistema Anterior'
                ''
                'Este guia ajuda na migração do sistema anterior para o sistema melhorado.'
                ''
                '## Compatibilidade'
                ''
                'O sistema melhorado mantém **compatibilidade total** com o sistema anterior:'
                ''
                '- Todas as funções existentes continuam funcionando'
                '- Estrutura de dados permanece a mesma'
                '- Scripts existentes não precisam ser modificados'
                ''
                '## Novas Funcionalidades'
                ''
                '### 1. Salvamento Automático de Modelos'
                ''
                '**Antes:**'
                '```matlab'
                '% Salvamento manual necessário'
                'save(''meu_modelo.mat'', ''trainedNet'');'
                '```'
                ''
                '**Agora:**'
                '```matlab'
                '% Salvamento automático durante treinamento'
                '% Nenhuma ação necessária - modelos são salvos automaticamente'
                '```'
                ''
                '### 2. Carregamento de Modelos'
                ''
                '**Antes:**'
                '```matlab'
                '% Carregamento manual'
                'load(''meu_modelo.mat'');'
                '```'
                ''
                '**Agora:**'
                '```matlab'
                '% Carregamento inteligente'
                'addpath(''src/model_management'');'
                'loader = ModelLoader();'
                'model = loader.loadBestModel(''models'', ''dice'');'
                '```'
                ''
                '### 3. Organização de Resultados'
                ''
                '**Antes:**'
                '```matlab'
                '% Organização manual de arquivos'
                'mkdir(''resultados'');'
                'imwrite(segmentedImage, ''resultados/img1.png'');'
                '```'
                ''
                '**Agora:**'
                '```matlab'
                '% Organização automática'
                'addpath(''src/organization'');'
                'organizer = ResultsOrganizer();'
                'organizer.organizeResults(unetResults, attentionResults, sessionId);'
                '```'
                ''
                '## Migração Passo a Passo'
                ''
                '### Passo 1: Backup'
                ''
                '1. Faça backup de seus dados e scripts existentes'
                '2. Copie modelos treinados para pasta segura'
                ''
                '### Passo 2: Atualização Gradual'
                ''
                '1. Continue usando funções existentes'
                '2. Adicione gradualmente novas funcionalidades'
                '3. Teste cada nova funcionalidade separadamente'
                ''
                '### Passo 3: Configuração'
                ''
                '```matlab'
                '% Configurar caminhos para seus dados existentes'
                'addpath(''src/core'');'
                'config = ConfigManager();'
                'config.setParameter(''dataPath'', ''seus_dados'');'
                'config.setParameter(''outputPath'', ''seus_resultados'');'
                '```'
                ''
                '### Passo 4: Migração de Modelos'
                ''
                '```matlab'
                '% Migrar modelos existentes para novo formato'
                'addpath(''src/utils'');'
                'migrator = MigrationManager();'
                'migrator.migrateExistingModels(''pasta_modelos_antigos'');'
                '```'
                ''
                '## Resolução de Problemas na Migração'
                ''
                '### Problema: Caminhos não encontrados'
                '**Solução:** Verifique se adicionou os caminhos corretos:'
                '```matlab'
                'addpath(genpath(''src''));'
                '```'
                ''
                '### Problema: Modelos antigos não carregam'
                '**Solução:** Use o migrador de modelos:'
                '```matlab'
                'migrator = MigrationManager();'
                'migrator.convertOldModel(''modelo_antigo.mat'');'
                '```'
                ''
                '### Problema: Resultados em local diferente'
                '**Solução:** Configure o caminho de saída:'
                '```matlab'
                'config = ConfigManager();'
                'config.setParameter(''outputPath'', ''seu_caminho'');'
                '```'
                ''
                '## Benefícios da Migração'
                ''
                '- **Salvamento automático:** Nunca perca modelos treinados'
                '- **Organização:** Resultados organizados automaticamente'
                '- **Monitoramento:** Acompanhe o treinamento em tempo real'
                '- **Análises:** Estatísticas avançadas automáticas'
                '- **Exportação:** Formatos científicos padrão'
                ''
                '## Suporte'
                ''
                'Para ajuda na migração:'
                '1. Consulte os exemplos práticos'
                '2. Execute os testes de validação'
                '3. Verifique os logs de erro'
            };
        end     
   
        function content = createExamplesContent(obj)
            % Cria conteúdo dos exemplos
            content = {
                '# Exemplos Práticos'
                ''
                '## Exemplo 1: Treinamento Completo com Salvamento'
                ''
                '```matlab'
                '% Configurar sistema'
                'addpath(genpath(''src''));'
                ''
                '% Carregar dados'
                'dataLoader = DataLoader();'
                'data = dataLoader.loadTrainingData(''img'');'
                ''
                '% Configurar monitoramento'
                'monitor = GradientMonitor();'
                ''
                '% Treinar modelo com salvamento automático'
                'trainer = ModelTrainer();'
                'trainer.setGradientMonitor(monitor);'
                '[unetModel, attentionModel] = trainer.trainBothModels(data);'
                ''
                '% Modelos são salvos automaticamente'
                'fprintf(''Modelos salvos automaticamente\\n'');'
                '```'
                ''
                '## Exemplo 2: Carregamento e Inferência'
                ''
                '```matlab'
                '% Carregar melhor modelo salvo'
                'loader = ModelLoader();'
                'bestModel = loader.loadBestModel(''models'', ''dice'');'
                ''
                '% Executar inferência em novas imagens'
                'engine = InferenceEngine();'
                'imagePaths = {''nova_imagem1.jpg'', ''nova_imagem2.jpg''};'
                'results = engine.segmentImages(bestModel, imagePaths);'
                ''
                '% Analisar resultados'
                'analyzer = ResultsAnalyzer();'
                'statistics = analyzer.generateStatistics(results);'
                'fprintf(''Dice médio: %.3f\\n'', statistics.dice.mean);'
                '```'
                ''
                '## Exemplo 3: Comparação Completa com Organização'
                ''
                '```matlab'
                '% Executar comparação completa'
                'controller = ComparisonController();'
                'results = controller.runFullComparison();'
                ''
                '% Organizar resultados automaticamente'
                'organizer = ResultsOrganizer();'
                'sessionId = [''session_'' datestr(now, ''yyyymmdd_HHMMSS'')];'
                'organizer.organizeResults(results.unet, results.attention, sessionId);'
                ''
                '% Gerar visualizações'
                'visualizer = ComparisonVisualizer();'
                'visualizer.generateComparisonGallery(results, sessionId);'
                '```'
                ''
                '## Exemplo 4: Análise Estatística Avançada'
                ''
                '```matlab'
                '% Carregar resultados de múltiplas execuções'
                'unetMetrics = loadMetrics(''unet_results.mat'');'
                'attentionMetrics = loadMetrics(''attention_results.mat'');'
                ''
                '% Executar análise estatística completa'
                'analyzer = StatisticalAnalyzer();'
                'analysis = analyzer.performComprehensiveAnalysis(unetMetrics, attentionMetrics);'
                ''
                '% Gerar relatório científico'
                'report = analyzer.generateScientificReport(analysis);'
                'fprintf(''P-value: %.4f\\n'', analysis.pValue);'
                'fprintf(''Effect size: %.3f\\n'', analysis.effectSize);'
                '```'
                ''
                '## Exemplo 5: Exportação para Publicação'
                ''
                '```matlab'
                '% Exportar dados para CSV'
                'exporter = DataExporter();'
                'exporter.exportToCSV(results.metrics, ''resultados_publicacao.csv'');'
                ''
                '% Exportar visualizações em alta resolução'
                'vizExporter = VisualizationExporter();'
                'vizExporter.exportHighResolution(''comparisons'', ''publication_figures'');'
                ''
                '% Gerar relatório LaTeX'
                'reportGen = ReportGenerator();'
                'reportGen.generateLaTeXReport(analysis, ''paper_results.tex'');'
                '```'
                ''
                '## Exemplo 6: Monitoramento de Performance'
                ''
                '```matlab'
                '% Configurar monitoramento de recursos'
                'monitor = ResourceMonitor();'
                'monitor.startMonitoring();'
                ''
                '% Executar operação intensiva'
                'results = runIntensiveOperation();'
                ''
                '% Obter relatório de performance'
                'perfReport = monitor.getPerformanceReport();'
                'fprintf(''Tempo total: %.2f segundos\\n'', perfReport.totalTime);'
                'fprintf(''Memória pico: %.1f MB\\n'', perfReport.peakMemory);'
                '```'
                ''
                '## Exemplo 7: Configuração Personalizada'
                ''
                '```matlab'
                '% Criar configuração personalizada'
                'config = ConfigManager();'
                'config.setParameter(''outputPath'', ''meus_resultados'');'
                'config.setParameter(''enableGradientMonitoring'', true);'
                'config.setParameter(''maxModelsToKeep'', 5);'
                'config.setParameter(''compressionLevel'', 9);'
                ''
                '% Usar configuração em componentes'
                'organizer = ResultsOrganizer(config);'
                'saver = ModelSaver(config);'
                '```'
            };
        end
        
        function content = createTroubleshootingContent(obj)
            % Cria conteúdo do troubleshooting
            content = {
                '# Guia de Solução de Problemas'
                ''
                '## Problemas Comuns'
                ''
                '### 1. Erro: "Função não encontrada"'
                ''
                '**Sintomas:**'
                '- Mensagem "Undefined function or variable"'
                '- Componentes não carregam'
                ''
                '**Soluções:**'
                '```matlab'
                '% Adicionar todos os caminhos'
                'addpath(genpath(''src''));'
                ''
                '% Verificar se arquivo existe'
                'which ModelSaver'
                '```'
                ''
                '### 2. Erro: "Permissão negada"'
                ''
                '**Sintomas:**'
                '- Não consegue salvar arquivos'
                '- Erro ao criar diretórios'
                ''
                '**Soluções:**'
                '- Verificar permissões de escrita'
                '- Executar MATLAB como administrador'
                '- Alterar diretório de saída'
                ''
                '### 3. Erro: "Memória insuficiente"'
                ''
                '**Sintomas:**'
                '- "Out of memory" durante treinamento'
                '- MATLAB trava ou fica lento'
                ''
                '**Soluções:**'
                '```matlab'
                '% Reduzir batch size'
                'config.batchSize = 8; % ao invés de 32'
                ''
                '% Limpar variáveis desnecessárias'
                'clear variavel_grande;'
                ''
                '% Usar processamento em lotes menores'
                'engine.setBatchSize(4);'
                '```'
                ''
                '### 4. Modelos não carregam'
                ''
                '**Sintomas:**'
                '- Erro ao carregar modelo salvo'
                '- Incompatibilidade de versão'
                ''
                '**Soluções:**'
                '```matlab'
                '% Verificar compatibilidade'
                'loader = ModelLoader();'
                'isValid = loader.validateModelCompatibility(''modelo.mat'');'
                ''
                '% Migrar modelo antigo'
                'migrator = MigrationManager();'
                'migrator.convertOldModel(''modelo_antigo.mat'');'
                '```'
                ''
                '### 5. Performance lenta'
                ''
                '**Sintomas:**'
                '- Treinamento muito lento'
                '- Inferência demorada'
                ''
                '**Soluções:**'
                '```matlab'
                '% Habilitar GPU se disponível'
                'config.useGPU = true;'
                ''
                '% Otimizar configurações'
                'config.enableOptimizations = true;'
                ''
                '% Reduzir resolução de imagens'
                'config.imageSize = [128, 128]; % ao invés de [256, 256]'
                '```'
                ''
                '## Diagnóstico'
                ''
                '### Verificar Sistema'
                ''
                '```matlab'
                '% Executar diagnóstico completo'
                'validator = ValidationMaster();'
                'results = validator.runCompleteValidation();'
                ''
                '% Verificar componentes específicos'
                'validator.validateComponents();'
                '```'
                ''
                '### Verificar Logs'
                ''
                '```matlab'
                '% Localizar logs'
                'logDir = fullfile(''validation_results'', ''logs'');'
                'dir(logDir)'
                ''
                '% Ler log mais recente'
                'logger = ValidationLogger();'
                'logFile = logger.getLogFile();'
                'type(logFile)'
                '```'
                ''
                '## Contato para Suporte'
                ''
                'Se os problemas persistirem:'
                ''
                '1. Execute o diagnóstico completo'
                '2. Colete os logs de erro'
                '3. Documente os passos para reproduzir o problema'
                '4. Inclua informações do sistema (versão MATLAB, OS)'
            };
        end       
 
        function content = createChangelogContent(obj)
            % Cria conteúdo do changelog
            content = {
                '# Changelog'
                ''
                '## [2.0.0] - Sistema Melhorado'
                ''
                '### Adicionado'
                '- Sistema completo de gerenciamento de modelos'
                '  - Salvamento automático com metadados'
                '  - Carregamento inteligente de modelos'
                '  - Versionamento automático'
                '- Monitoramento avançado de otimização'
                '  - Captura de gradientes em tempo real'
                '  - Detecção automática de problemas'
                '  - Sugestões de otimização'
                '- Sistema de inferência robusto'
                '  - Processamento em lote'
                '  - Cálculo de confiança'
                '  - Análise estatística automática'
                '- Organização automática de resultados'
                '  - Estrutura hierárquica de diretórios'
                '  - Nomenclatura consistente'
                '  - Índices HTML navegáveis'
                '- Visualizações avançadas'
                '  - Comparações lado a lado'
                '  - Mapas de diferença'
                '  - Galerias interativas'
                '- Sistema de exportação completo'
                '  - Formatos científicos (CSV, Excel, LaTeX)'
                '  - Exportação de modelos (ONNX)'
                '  - Relatórios automáticos'
                '- Sistema de validação abrangente'
                '  - Testes de integração'
                '  - Testes de regressão'
                '  - Testes de performance'
                '- Documentação completa'
                '  - Guia do usuário'
                '  - Referência da API'
                '  - Guia de migração'
                ''
                '### Melhorado'
                '- Performance geral do sistema'
                '- Tratamento de erros mais robusto'
                '- Interface de usuário mais intuitiva'
                '- Logging detalhado para debugging'
                ''
                '### Mantido'
                '- Compatibilidade total com sistema anterior'
                '- Todas as funcionalidades existentes'
                '- Estrutura de dados original'
                ''
                '## [1.0.0] - Sistema Original'
                ''
                '### Funcionalidades Base'
                '- Comparação básica U-Net vs Attention U-Net'
                '- Cálculo de métricas (IoU, Dice, Accuracy)'
                '- Visualizações simples'
                '- Salvamento manual de resultados'
            };
        end
        
        function content = createInstallationContent(obj)
            % Cria conteúdo da instalação
            content = {
                '# Guia de Instalação'
                ''
                '## Requisitos do Sistema'
                ''
                '### Software Necessário'
                '- MATLAB R2019b ou superior'
                '- Deep Learning Toolbox'
                '- Image Processing Toolbox'
                '- Statistics and Machine Learning Toolbox (recomendado)'
                ''
                '### Hardware Recomendado'
                '- RAM: 8GB mínimo, 16GB recomendado'
                '- GPU: NVIDIA com suporte CUDA (opcional, mas recomendado)'
                '- Espaço em disco: 5GB para sistema + dados'
                ''
                '## Instalação'
                ''
                '### Passo 1: Download'
                '1. Faça download do sistema completo'
                '2. Extraia para diretório de sua escolha'
                ''
                '### Passo 2: Configuração de Caminhos'
                '```matlab'
                '% Adicionar caminhos do sistema'
                'addpath(genpath(''caminho/para/sistema''));'
                ''
                '% Salvar caminhos permanentemente'
                'savepath;'
                '```'
                ''
                '### Passo 3: Verificação da Instalação'
                '```matlab'
                '% Executar teste de instalação'
                'addpath(''src/validation'');'
                'validator = ValidationMaster();'
                'results = validator.runCompleteValidation();'
                ''
                'if results.success'
                '    fprintf(''Instalação bem-sucedida!\\n'');'
                'else'
                '    fprintf(''Problemas na instalação detectados.\\n'');'
                'end'
                '```'
                ''
                '### Passo 4: Configuração Inicial'
                '```matlab'
                '% Configurar diretórios de dados'
                'config = ConfigManager();'
                'config.setParameter(''dataPath'', ''caminho/para/seus/dados'');'
                'config.setParameter(''outputPath'', ''caminho/para/resultados'');'
                'config.saveConfiguration();'
                '```'
                ''
                '## Configuração Avançada'
                ''
                '### GPU (Opcional)'
                '```matlab'
                '% Verificar disponibilidade de GPU'
                'gpuDevice();'
                ''
                '% Habilitar uso de GPU'
                'config.setParameter(''useGPU'', true);'
                '```'
                ''
                '### Parallel Computing (Opcional)'
                '```matlab'
                '% Configurar pool de workers'
                'parpool(4); % 4 workers'
                'config.setParameter(''useParallel'', true);'
                '```'
                ''
                '## Solução de Problemas na Instalação'
                ''
                '### Toolboxes em Falta'
                '```matlab'
                '% Verificar toolboxes instalados'
                'ver'
                ''
                '% Instalar toolboxes necessários via Add-On Explorer'
                '```'
                ''
                '### Problemas de Caminho'
                '```matlab'
                '% Verificar caminhos'
                'path'
                ''
                '% Resetar caminhos se necessário'
                'restoredefaultpath;'
                'addpath(genpath(''sistema''));'
                'savepath;'
                '```'
                ''
                '## Desinstalação'
                ''
                '```matlab'
                '% Remover caminhos'
                'rmpath(genpath(''caminho/para/sistema''));'
                'savepath;'
                ''
                '% Remover arquivos (manual)'
                '% Delete a pasta do sistema'
                '```'
            };
        end
        
        function content = createPerformanceContent(obj)
            % Cria conteúdo do guia de performance
            content = {
                '# Guia de Performance'
                ''
                '## Otimizações Implementadas'
                ''
                '### 1. Gerenciamento de Memória'
                '- Cache inteligente de modelos'
                '- Limpeza automática de variáveis temporárias'
                '- Processamento em lotes otimizado'
                ''
                '### 2. Processamento Paralelo'
                '- Inferência em lote paralela'
                '- Processamento concorrente de visualizações'
                '- Operações de I/O assíncronas'
                ''
                '### 3. Otimizações de Algoritmo'
                '- Cálculos vetorizados'
                '- Reutilização de computações'
                '- Algoritmos otimizados para métricas'
                ''
                '## Configurações de Performance'
                ''
                '### Para Sistemas com GPU'
                '```matlab'
                'config = ConfigManager();'
                'config.setParameter(''useGPU'', true);'
                'config.setParameter(''gpuBatchSize'', 32);'
                'config.setParameter(''enableMixedPrecision'', true);'
                '```'
                ''
                '### Para Sistemas com CPU Múltiplos'
                '```matlab'
                'config.setParameter(''useParallel'', true);'
                'config.setParameter(''numWorkers'', 4);'
                'config.setParameter(''enableVectorization'', true);'
                '```'
                ''
                '### Para Sistemas com Memória Limitada'
                '```matlab'
                'config.setParameter(''batchSize'', 8);'
                'config.setParameter(''enableMemoryOptimization'', true);'
                'config.setParameter(''compressionLevel'', 9);'
                '```'
                ''
                '## Benchmarks'
                ''
                '### Tempos Típicos (Sistema de Referência)'
                '- Treinamento U-Net: ~30 minutos'
                '- Treinamento Attention U-Net: ~45 minutos'
                '- Inferência por imagem: ~0.1 segundos'
                '- Organização de resultados: ~5 segundos'
                ''
                '### Uso de Memória'
                '- Treinamento: ~4GB RAM'
                '- Inferência: ~1GB RAM'
                '- Visualizações: ~500MB RAM'
                ''
                '## Monitoramento de Performance'
                ''
                '```matlab'
                '% Habilitar monitoramento'
                'monitor = ResourceMonitor();'
                'monitor.startMonitoring();'
                ''
                '% Executar operações'
                'results = runOperation();'
                ''
                '% Obter relatório'
                'report = monitor.getReport();'
                'monitor.displayReport();'
                '```'
                ''
                '## Dicas de Otimização'
                ''
                '1. **Use GPU quando disponível**'
                '2. **Processe em lotes maiores se memória permitir**'
                '3. **Habilite compressão para economizar espaço**'
                '4. **Use processamento paralelo para múltiplas imagens**'
                '5. **Monitore uso de recursos regularmente**'
            };
        end      
  
        function content = createMainIndexContent(obj)
            % Cria conteúdo do índice principal
            content = {
                '# Documentação do Sistema de Segmentação Melhorado'
                ''
                '## Bem-vindo'
                ''
                'Esta é a documentação completa do sistema melhorado de comparação'
                'U-Net vs Attention U-Net para segmentação de imagens.'
                ''
                '## Documentação Disponível'
                ''
                '### 📚 [Guia do Usuário](user_guide/index.html)'
                'Aprenda a usar todas as funcionalidades do sistema'
                ''
                '### 🔧 [Referência da API](api_reference/index.html)'
                'Documentação técnica completa de todas as funções'
                ''
                '### 🚀 [Guia de Migração](migration/index.html)'
                'Como migrar do sistema anterior para o novo'
                ''
                '### 💡 [Exemplos Práticos](examples/index.html)'
                'Exemplos de código para casos de uso comuns'
                ''
                '### 🔍 [Solução de Problemas](troubleshooting/index.html)'
                'Guia para resolver problemas comuns'
                ''
                '### 📋 [Changelog](CHANGELOG.html)'
                'Histórico de mudanças e melhorias'
                ''
                '### ⚡ [Guia de Performance](performance_guide.html)'
                'Otimizações e configurações de performance'
                ''
                '### 🛠️ [Guia de Instalação](INSTALLATION.html)'
                'Instruções completas de instalação e configuração'
                ''
                '## Início Rápido'
                ''
                '```matlab'
                '% Executar sistema básico'
                'executar_comparacao;'
                ''
                '% Ou usar interface melhorada'
                'addpath(''src/core'');'
                'interface = MainInterface();'
                'interface.runComparison();'
                '```'
                ''
                '## Principais Melhorias'
                ''
                '✅ **Salvamento automático de modelos**'
                '✅ **Monitoramento de gradientes em tempo real**'
                '✅ **Sistema de inferência robusto**'
                '✅ **Organização automática de resultados**'
                '✅ **Visualizações avançadas**'
                '✅ **Exportação para formatos científicos**'
                '✅ **Compatibilidade total com sistema anterior**'
                ''
                '## Suporte'
                ''
                'Para suporte e dúvidas:'
                '1. Consulte a documentação relevante'
                '2. Verifique os exemplos práticos'
                '3. Execute os testes de validação'
                '4. Consulte o guia de troubleshooting'
                ''
                '---'
                ''
                '*Documentação gerada automaticamente em ' + string(datetime()) + '*'
            };
        end
        
        function generateMATLABExamples(obj)
            % Gera arquivos de exemplo MATLAB
            examplesDir = fullfile(obj.outputDir, 'examples', 'matlab_files');
            if ~exist(examplesDir, 'dir')
                mkdir(examplesDir);
            end
            
            % Exemplo 1: Treinamento básico
            example1 = {
                '% Exemplo 1: Treinamento Completo com Salvamento Automático'
                '% Este exemplo mostra como treinar modelos com todas as melhorias'
                ''
                '% Configurar sistema'
                'addpath(genpath(''src''));'
                ''
                '% Configurar parâmetros'
                'config = ConfigManager();'
                'config.setParameter(''dataPath'', ''img'');'
                'config.setParameter(''outputPath'', ''resultados_exemplo1'');'
                'config.setParameter(''enableGradientMonitoring'', true);'
                ''
                '% Carregar dados'
                'fprintf(''Carregando dados...\\n'');'
                'dataLoader = DataLoader();'
                'data = dataLoader.loadTrainingData(config.getParameter(''dataPath''));'
                ''
                '% Configurar monitoramento de gradientes'
                'monitor = GradientMonitor();'
                ''
                '% Treinar modelos'
                'fprintf(''Iniciando treinamento...\\n'');'
                'trainer = ModelTrainer();'
                'trainer.setGradientMonitor(monitor);'
                '[unetModel, attentionModel] = trainer.trainBothModels(data);'
                ''
                '% Modelos são salvos automaticamente'
                'fprintf(''Treinamento concluído. Modelos salvos automaticamente.\\n'');'
                ''
                '% Verificar modelos salvos'
                'loader = ModelLoader();'
                'models = loader.listAvailableModels(''models'');'
                'fprintf(''Modelos disponíveis: %d\\n'', length(models));'
            };
            
            obj.writeTextFile(fullfile(examplesDir, 'exemplo1_treinamento.m'), example1);
            
            % Exemplo 2: Inferência
            example2 = {
                '% Exemplo 2: Carregamento e Inferência'
                '% Este exemplo mostra como usar modelos salvos para inferência'
                ''
                'addpath(genpath(''src''));'
                ''
                '% Carregar melhor modelo baseado em métrica Dice'
                'fprintf(''Carregando melhor modelo...\\n'');'
                'loader = ModelLoader();'
                'bestModel = loader.loadBestModel(''models'', ''dice'');'
                ''
                '% Preparar imagens para inferência'
                'imagePaths = {''img/original/imagem1.jpg'', ''img/original/imagem2.jpg''};'
                ''
                '% Executar inferência'
                'fprintf(''Executando inferência...\\n'');'
                'engine = InferenceEngine();'
                'results = engine.segmentImages(bestModel, imagePaths);'
                ''
                '% Analisar resultados'
                'analyzer = ResultsAnalyzer();'
                'statistics = analyzer.generateStatistics(results);'
                ''
                '% Exibir estatísticas'
                'fprintf(''Resultados da inferência:\\n'');'
                'fprintf(''Dice médio: %.3f ± %.3f\\n'', statistics.dice.mean, statistics.dice.std);'
                'fprintf(''IoU médio: %.3f ± %.3f\\n'', statistics.iou.mean, statistics.iou.std);'
                'fprintf(''Accuracy média: %.3f ± %.3f\\n'', statistics.accuracy.mean, statistics.accuracy.std);'
            };
            
            obj.writeTextFile(fullfile(examplesDir, 'exemplo2_inferencia.m'), example2);
            
            obj.logger.info('Exemplos MATLAB gerados');
        end
        
        function writeHTMLFile(obj, filename, title, content)
            % Escreve arquivo HTML
            html = {
                '<!DOCTYPE html>'
                '<html lang="pt-BR">'
                '<head>'
                '    <meta charset="UTF-8">'
                '    <meta name="viewport" content="width=device-width, initial-scale=1.0">'
                ['    <title>' title '</title>']
                '    <style>'
                '        body { font-family: Arial, sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; }'
                '        h1, h2, h3 { color: #333; }'
                '        code { background-color: #f4f4f4; padding: 2px 4px; border-radius: 3px; }'
                '        pre { background-color: #f4f4f4; padding: 10px; border-radius: 5px; overflow-x: auto; }'
                '        .toc { background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin-bottom: 20px; }'
                '    </style>'
                '</head>'
                '<body>'
            };
            
            % Converter markdown para HTML básico
            htmlContent = obj.markdownToHTML(content);
            html = [html; htmlContent; {'</body>'; '</html>'}];
            
            obj.writeTextFile(filename, html);
        end
        
        function writeMarkdownFile(obj, filename, content)
            % Escreve arquivo Markdown
            obj.writeTextFile(filename, content);
        end
        
        function writeTextFile(obj, filename, content)
            % Escreve arquivo de texto
            fid = fopen(filename, 'w', 'n', 'UTF-8');
            if fid ~= -1
                for i = 1:length(content)
                    fprintf(fid, '%s\n', content{i});
                end
                fclose(fid);
            end
        end
        
        function htmlContent = markdownToHTML(obj, mdContent)
            % Conversão básica de Markdown para HTML
            htmlContent = {};
            
            for i = 1:length(mdContent)
                line = mdContent{i};
                
                if isempty(line)
                    htmlContent{end+1} = '<br>';
                elseif startsWith(line, '# ')
                    htmlContent{end+1} = ['<h1>' line(3:end) '</h1>'];
                elseif startsWith(line, '## ')
                    htmlContent{end+1} = ['<h2>' line(4:end) '</h2>'];
                elseif startsWith(line, '### ')
                    htmlContent{end+1} = ['<h3>' line(5:end) '</h3>'];
                elseif startsWith(line, '```')
                    if contains(line, 'matlab')
                        htmlContent{end+1} = '<pre><code class="matlab">';
                    else
                        htmlContent{end+1} = '<pre><code>';
                    end
                elseif strcmp(line, '```')
                    htmlContent{end+1} = '</code></pre>';
                else
                    htmlContent{end+1} = ['<p>' line '</p>'];
                end
            end
        end
        
        function config = getDefaultConfig(obj)
            % Configuração padrão
            config = struct();
            config.generateHTML = true;
            config.generateMarkdown = true;
            config.generateExamples = true;
            config.includeAPI = true;
            config.includeMigration = true;
        end
    end
end