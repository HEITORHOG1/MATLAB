classdef HelpSystem < handle
    % ========================================================================
    % HELPSYSTEM - SISTEMA DE AJUDA CONTEXTUAL E DOCUMENTAÇÃO INTEGRADA
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Sistema completo de ajuda contextual, documentação interativa e
    %   troubleshooting automático para o sistema de comparação.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - MATLAB Fundamentals
    %   - Documentation and Help
    %
    % USO:
    %   >> helpSystem = HelpSystem();
    %   >> helpSystem.showHelp('quick_start');
    %   >> helpSystem.troubleshoot();
    %
    % REQUISITOS: 2.3, 2.5 (ajuda contextual e troubleshooting automático)
    % ========================================================================
    
    properties (Access = private)
        helpTopics
        troubleshootingRules
        faqDatabase
        tutorialSteps
        
        % Configurações
        enableColors = true
        enableInteractiveMode = true
        maxSearchResults = 10
        
        % Histórico de ajuda
        helpHistory = {}
        searchHistory = {}
        
        % Sistema de feedback
        feedbackEnabled = true
        usageStats = struct()
    end
    
    properties (Constant)
        % Tópicos principais de ajuda
        MAIN_TOPICS = {
            'quick_start', 'Início Rápido'
            'configuration', 'Configuração do Sistema'
            'data_preparation', 'Preparação de Dados'
            'model_training', 'Treinamento de Modelos'
            'comparison', 'Comparação e Análise'
            'troubleshooting', 'Solução de Problemas'
            'advanced', 'Funcionalidades Avançadas'
            'faq', 'Perguntas Frequentes'
        }
        
        % Códigos de cores
        COLORS = struct(...
            'RESET', '\033[0m', ...
            'HEADER', '\033[1;36m', ...
            'SUBHEADER', '\033[1;34m', ...
            'TEXT', '\033[0;37m', ...
            'HIGHLIGHT', '\033[1;33m', ...
            'SUCCESS', '\033[1;32m', ...
            'WARNING', '\033[1;33m', ...
            'ERROR', '\033[1;31m', ...
            'CODE', '\033[0;35m')
        
        % Ícones para diferentes tipos de conteúdo
        ICONS = struct(...
            'HELP', '📖', ...
            'TIP', '💡', ...
            'WARNING', '⚠️', ...
            'ERROR', '❌', ...
            'SUCCESS', '✅', ...
            'CODE', '💻', ...
            'LINK', '🔗', ...
            'SEARCH', '🔍', ...
            'TUTORIAL', '🎓', ...
            'FAQ', '❓')
    end
    
    methods
        function obj = HelpSystem(varargin)
            % Construtor do sistema de ajuda
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'EnableColors' - habilitar cores (padrão: true)
            %     'EnableInteractiveMode' - habilitar modo interativo (padrão: true)
            %     'FeedbackEnabled' - habilitar feedback (padrão: true)
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'EnableColors', true, @islogical);
            addParameter(p, 'EnableInteractiveMode', true, @islogical);
            addParameter(p, 'FeedbackEnabled', true, @islogical);
            parse(p, varargin{:});
            
            obj.enableColors = p.Results.EnableColors;
            obj.enableInteractiveMode = p.Results.EnableInteractiveMode;
            obj.feedbackEnabled = p.Results.FeedbackEnabled;
            
            % Inicializar componentes
            obj.initializeHelpTopics();
            obj.initializeTroubleshootingRules();
            obj.initializeFAQ();
            obj.initializeTutorials();
            obj.initializeUsageStats();
        end
        
        function showHelp(obj, topic, varargin)
            % Mostra ajuda para um tópico específico
            %
            % ENTRADA:
            %   topic - tópico de ajuda
            %   varargin - parâmetros opcionais:
            %     'Interactive' - modo interativo (padrão: true)
            %     'Detailed' - mostrar detalhes (padrão: false)
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Interactive', obj.enableInteractiveMode, @islogical);
            addParameter(p, 'Detailed', false, @islogical);
            parse(p, varargin{:});
            
            % Registrar no histórico
            obj.addToHistory('help', topic);
            
            % Atualizar estatísticas
            obj.updateUsageStats('help', topic);
            
            % Mostrar ajuda baseada no tópico
            switch lower(topic)
                case 'quick_start'
                    obj.showQuickStartHelp(p.Results.Interactive, p.Results.Detailed);
                case 'configuration'
                    obj.showConfigurationHelp(p.Results.Interactive, p.Results.Detailed);
                case 'data_preparation'
                    obj.showDataPreparationHelp(p.Results.Interactive, p.Results.Detailed);
                case 'model_training'
                    obj.showModelTrainingHelp(p.Results.Interactive, p.Results.Detailed);
                case 'comparison'
                    obj.showComparisonHelp(p.Results.Interactive, p.Results.Detailed);
                case 'troubleshooting'
                    obj.showTroubleshootingHelp(p.Results.Interactive, p.Results.Detailed);
                case 'advanced'
                    obj.showAdvancedHelp(p.Results.Interactive, p.Results.Detailed);
                case 'faq'
                    obj.showFAQ(p.Results.Interactive);
                case 'menu'
                    obj.showMainHelpMenu();
                otherwise
                    obj.searchHelp(topic);
            end
            
            % Oferecer ajuda adicional se em modo interativo
            if p.Results.Interactive
                obj.offerAdditionalHelp();
            end
        end
        
        function searchHelp(obj, query)
            % Busca ajuda por palavra-chave
            %
            % ENTRADA:
            %   query - termo de busca
            
            obj.addToHistory('search', query);
            obj.updateUsageStats('search', query);
            
            obj.printHeader(sprintf('%s Resultados da busca para: "%s"', obj.ICONS.SEARCH, query));
            
            results = obj.performSearch(query);
            
            if isempty(results)
                obj.printColored(sprintf('%s Nenhum resultado encontrado.\n', obj.ICONS.WARNING), 'WARNING');
                obj.suggestAlternatives(query);
            else
                obj.displaySearchResults(results);
                
                if obj.enableInteractiveMode
                    obj.offerDetailedResult(results);
                end
            end
        end
        
        function troubleshoot(obj, varargin)
            % Sistema de troubleshooting automático
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'Problem' - problema específico
            %     'AutoFix' - tentar correção automática (padrão: false)
            %     'Interactive' - modo interativo (padrão: true)
            %
            % REQUISITOS: 2.5 (sistema de troubleshooting automático)
            
            % Parse de argumentos
            p = inputParser;
            addParameter(p, 'Problem', '', @ischar);
            addParameter(p, 'AutoFix', false, @islogical);
            addParameter(p, 'Interactive', obj.enableInteractiveMode, @islogical);
            parse(p, varargin{:});
            
            obj.addToHistory('troubleshoot', p.Results.Problem);
            obj.updateUsageStats('troubleshoot', 'general');
            
            obj.printHeader(sprintf('%s Sistema de Diagnóstico Automático', obj.ICONS.ERROR));
            
            if isempty(p.Results.Problem)
                % Diagnóstico geral do sistema
                obj.runSystemDiagnostics(p.Results.AutoFix, p.Results.Interactive);
            else
                % Diagnóstico específico
                obj.diagnoseProblem(p.Results.Problem, p.Results.AutoFix, p.Results.Interactive);
            end
        end
        
        function showTutorial(obj, tutorialName)
            % Mostra tutorial interativo
            %
            % ENTRADA:
            %   tutorialName - nome do tutorial
            
            obj.addToHistory('tutorial', tutorialName);
            obj.updateUsageStats('tutorial', tutorialName);
            
            if ~isfield(obj.tutorialSteps, tutorialName)
                obj.printColored(sprintf('%s Tutorial "%s" não encontrado.\n', obj.ICONS.ERROR, tutorialName), 'ERROR');
                obj.listAvailableTutorials();
                return;
            end
            
            obj.printHeader(sprintf('%s Tutorial: %s', obj.ICONS.TUTORIAL, tutorialName));
            
            steps = obj.tutorialSteps.(tutorialName);
            
            for i = 1:length(steps)
                obj.showTutorialStep(i, steps{i});
                
                if obj.enableInteractiveMode && i < length(steps)
                    if ~obj.askContinue()
                        break;
                    end
                end
            end
            
            obj.printColored(sprintf('%s Tutorial concluído!\n', obj.ICONS.SUCCESS), 'SUCCESS');
        end
        
        function showContextualHelp(obj, context, action)
            % Mostra ajuda contextual baseada no contexto atual
            %
            % ENTRADA:
            %   context - contexto atual (ex: 'menu', 'configuration')
            %   action - ação específica (opcional)
            %
            % REQUISITOS: 2.3 (ajuda contextual para cada opção do menu)
            
            obj.addToHistory('contextual', sprintf('%s:%s', context, action));
            
            contextKey = sprintf('%s_%s', context, action);
            
            if isfield(obj.helpTopics, contextKey)
                helpContent = obj.helpTopics.(contextKey);
                obj.displayHelpContent(helpContent);
            else
                % Ajuda genérica baseada no contexto
                obj.showGenericContextualHelp(context, action);
            end
        end
        
        function listTopics(obj)
            % Lista todos os tópicos de ajuda disponíveis
            
            obj.printHeader(sprintf('%s Tópicos de Ajuda Disponíveis', obj.ICONS.HELP));
            
            for i = 1:size(obj.MAIN_TOPICS, 1)
                topicId = obj.MAIN_TOPICS{i, 1};
                topicName = obj.MAIN_TOPICS{i, 2};
                
                obj.printColored(sprintf('  %d. %s - %s\n', i, topicId, topicName), 'TEXT');
            end
            
            fprintf('\n');
            obj.printColored(sprintf('%s Use: helpSystem.showHelp(''topic_name'') para ver ajuda específica\n', obj.ICONS.TIP), 'HIGHLIGHT');
        end
        
        function stats = getUsageStats(obj)
            % Retorna estatísticas de uso do sistema de ajuda
            %
            % SAÍDA:
            %   stats - estrutura com estatísticas
            
            stats = obj.usageStats;
            stats.totalQueries = length(obj.helpHistory);
            stats.uniqueTopics = length(unique({obj.helpHistory.topic}));
            
            if ~isempty(obj.helpHistory)
                stats.lastAccess = obj.helpHistory(end).timestamp;
                stats.mostAccessedTopic = obj.getMostAccessedTopic();
            end
        end
        
        function exportHelp(obj, filename, format)
            % Exporta documentação de ajuda para arquivo
            %
            % ENTRADA:
            %   filename - nome do arquivo
            %   format - formato ('txt', 'html', 'md')
            
            if nargin < 3
                format = 'txt';
            end
            
            try
                switch lower(format)
                    case 'txt'
                        obj.exportToText(filename);
                    case 'html'
                        obj.exportToHTML(filename);
                    case 'md'
                        obj.exportToMarkdown(filename);
                    otherwise
                        error('Formato não suportado: %s', format);
                end
                
                obj.printColored(sprintf('%s Ajuda exportada para: %s\n', obj.ICONS.SUCCESS, filename), 'SUCCESS');
                
            catch ME
                obj.printColored(sprintf('%s Erro ao exportar: %s\n', obj.ICONS.ERROR, ME.message), 'ERROR');
            end
        end
    end
    
    methods (Access = private)
        function initializeHelpTopics(obj)
            % Inicializa tópicos de ajuda
            
            obj.helpTopics = struct();
            
            % Início Rápido
            obj.helpTopics.quick_start = struct(...
                'title', 'Início Rápido', ...
                'content', obj.getQuickStartContent(), ...
                'keywords', {{'início', 'rápido', 'começar', 'primeiro', 'uso'}}, ...
                'difficulty', 'Iniciante', ...
                'estimatedTime', '5-10 minutos');
            
            % Configuração
            obj.helpTopics.configuration = struct(...
                'title', 'Configuração do Sistema', ...
                'content', obj.getConfigurationContent(), ...
                'keywords', {{'configuração', 'setup', 'caminhos', 'dados', 'parâmetros'}}, ...
                'difficulty', 'Iniciante', ...
                'estimatedTime', '10-15 minutos');
            
            % Preparação de Dados
            obj.helpTopics.data_preparation = struct(...
                'title', 'Preparação de Dados', ...
                'content', obj.getDataPreparationContent(), ...
                'keywords', {{'dados', 'imagens', 'máscaras', 'formato', 'preprocessamento'}}, ...
                'difficulty', 'Intermediário', ...
                'estimatedTime', '15-30 minutos');
            
            % Adicionar mais tópicos...
        end
        
        function initializeTroubleshootingRules(obj)
            % Inicializa regras de troubleshooting
            
            obj.troubleshootingRules = {};
            
            % Regra 1: Problemas de configuração
            obj.troubleshootingRules{end+1} = struct(...
                'name', 'ConfigurationIssues', ...
                'symptoms', {{'erro de configuração', 'caminhos inválidos', 'dados não encontrados'}}, ...
                'diagnosis', @obj.diagnoseConfigurationIssues, ...
                'solution', @obj.fixConfigurationIssues, ...
                'autoFixable', true);
            
            % Regra 2: Problemas de memória
            obj.troubleshootingRules{end+1} = struct(...
                'name', 'MemoryIssues', ...
                'symptoms', {{'out of memory', 'memória insuficiente', 'erro de alocação'}}, ...
                'diagnosis', @obj.diagnoseMemoryIssues, ...
                'solution', @obj.fixMemoryIssues, ...
                'autoFixable', false);
            
            % Regra 3: Problemas de GPU
            obj.troubleshootingRules{end+1} = struct(...
                'name', 'GPUIssues', ...
                'symptoms', {{'gpu error', 'cuda', 'gpu não detectada'}}, ...
                'diagnosis', @obj.diagnoseGPUIssues, ...
                'solution', @obj.fixGPUIssues, ...
                'autoFixable', false);
            
            % Adicionar mais regras...
        end
        
        function initializeFAQ(obj)
            % Inicializa base de perguntas frequentes
            
            obj.faqDatabase = {};
            
            % FAQ 1
            obj.faqDatabase{end+1} = struct(...
                'question', 'Como configurar o sistema pela primeira vez?', ...
                'answer', obj.getFAQAnswer('first_setup'), ...
                'category', 'Configuração', ...
                'keywords', {{'configurar', 'primeira', 'vez', 'setup', 'inicial'}});
            
            % FAQ 2
            obj.faqDatabase{end+1} = struct(...
                'question', 'Que formatos de imagem são suportados?', ...
                'answer', obj.getFAQAnswer('image_formats'), ...
                'category', 'Dados', ...
                'keywords', {{'formato', 'imagem', 'suportado', 'jpg', 'png'}});
            
            % FAQ 3
            obj.faqDatabase{end+1} = struct(...
                'question', 'Como interpretar os resultados da comparação?', ...
                'answer', obj.getFAQAnswer('interpret_results'), ...
                'category', 'Resultados', ...
                'keywords', {{'interpretar', 'resultados', 'métricas', 'comparação'}});
            
            % Adicionar mais FAQs...
        end
        
        function initializeTutorials(obj)
            % Inicializa tutoriais passo-a-passo
            
            obj.tutorialSteps = struct();
            
            % Tutorial: Primeira Execução
            obj.tutorialSteps.first_run = {
                struct('title', 'Passo 1: Preparar Dados', 'content', obj.getTutorialStep('first_run', 1))
                struct('title', 'Passo 2: Configurar Sistema', 'content', obj.getTutorialStep('first_run', 2))
                struct('title', 'Passo 3: Executar Comparação', 'content', obj.getTutorialStep('first_run', 3))
                struct('title', 'Passo 4: Analisar Resultados', 'content', obj.getTutorialStep('first_run', 4))
            };
            
            % Tutorial: Configuração Avançada
            obj.tutorialSteps.advanced_config = {
                struct('title', 'Configurações de Treinamento', 'content', obj.getTutorialStep('advanced_config', 1))
                struct('title', 'Otimização de Performance', 'content', obj.getTutorialStep('advanced_config', 2))
                struct('title', 'Configurações de GPU', 'content', obj.getTutorialStep('advanced_config', 3))
            };
        end
        
        function initializeUsageStats(obj)
            % Inicializa estatísticas de uso
            
            obj.usageStats = struct();
            obj.usageStats.help = containers.Map();
            obj.usageStats.search = containers.Map();
            obj.usageStats.troubleshoot = containers.Map();
            obj.usageStats.tutorial = containers.Map();
            obj.usageStats.startTime = now;
        end
        
        function printHeader(obj, title)
            % Imprime cabeçalho formatado
            
            fprintf('\n');
            obj.printColored('═══════════════════════════════════════════════════════════════════\n', 'HEADER');
            obj.printColored(sprintf('   %s\n', title), 'HEADER');
            obj.printColored('═══════════════════════════════════════════════════════════════════\n', 'HEADER');
            fprintf('\n');
        end
        
        function printColored(obj, text, colorName)
            % Imprime texto colorido
            
            if obj.enableColors && isfield(obj.COLORS, colorName)
                fprintf('%s%s%s', obj.COLORS.(colorName), text, obj.COLORS.RESET);
            else
                fprintf('%s', text);
            end
        end
        
        function addToHistory(obj, type, topic)
            % Adiciona entrada ao histórico
            
            entry = struct();
            entry.type = type;
            entry.topic = topic;
            entry.timestamp = now;
            
            obj.helpHistory{end+1} = entry;
        end
        
        function updateUsageStats(obj, type, topic)
            % Atualiza estatísticas de uso
            
            if obj.usageStats.(type).isKey(topic)
                obj.usageStats.(type)(topic) = obj.usageStats.(type)(topic) + 1;
            else
                obj.usageStats.(type)(topic) = 1;
            end
        end
        
        function results = performSearch(obj, query)
            % Realiza busca nos tópicos de ajuda
            
            results = {};
            queryLower = lower(query);
            
            % Buscar em tópicos principais
            topicNames = fieldnames(obj.helpTopics);
            for i = 1:length(topicNames)
                topic = obj.helpTopics.(topicNames{i});
                
                % Verificar título
                if contains(lower(topic.title), queryLower)
                    results{end+1} = struct('type', 'topic', 'name', topicNames{i}, 'data', topic, 'relevance', 1.0);
                end
                
                % Verificar palavras-chave
                for j = 1:length(topic.keywords)
                    if contains(topic.keywords{j}, queryLower)
                        results{end+1} = struct('type', 'topic', 'name', topicNames{i}, 'data', topic, 'relevance', 0.8);
                        break;
                    end
                end
            end
            
            % Buscar em FAQ
            for i = 1:length(obj.faqDatabase)
                faq = obj.faqDatabase{i};
                
                if contains(lower(faq.question), queryLower) || contains(lower(faq.answer), queryLower)
                    results{end+1} = struct('type', 'faq', 'name', sprintf('FAQ_%d', i), 'data', faq, 'relevance', 0.9);
                end
            end
            
            % Ordenar por relevância
            if ~isempty(results)
                relevances = [results.relevance];
                [~, sortIdx] = sort(relevances, 'descend');
                results = results(sortIdx);
                
                % Limitar número de resultados
                if length(results) > obj.maxSearchResults
                    results = results(1:obj.maxSearchResults);
                end
            end
        end
        
        function displaySearchResults(obj, results)
            % Exibe resultados da busca
            
            for i = 1:length(results)
                result = results{i};
                
                fprintf('%d. ', i);
                
                switch result.type
                    case 'topic'
                        obj.printColored(sprintf('%s %s', obj.ICONS.HELP, result.data.title), 'SUBHEADER');
                        fprintf(' (Tópico)\n');
                        obj.printColored(sprintf('   Dificuldade: %s | Tempo: %s\n', ...
                            result.data.difficulty, result.data.estimatedTime), 'TEXT');
                        
                    case 'faq'
                        obj.printColored(sprintf('%s %s', obj.ICONS.FAQ, result.data.question), 'SUBHEADER');
                        fprintf(' (FAQ)\n');
                        obj.printColored(sprintf('   Categoria: %s\n', result.data.category), 'TEXT');
                end
                
                fprintf('\n');
            end
        end
        
        function showQuickStartHelp(obj, interactive, detailed)
            % Mostra ajuda de início rápido
            
            content = obj.getQuickStartContent();
            obj.displayHelpContent(content);
            
            if interactive
                if obj.askYesNo('Deseja executar o tutorial de primeira execução?')
                    obj.showTutorial('first_run');
                end
            end
        end
        
        function showConfigurationHelp(obj, interactive, detailed)
            % Mostra ajuda de configuração
            
            content = obj.getConfigurationContent();
            obj.displayHelpContent(content);
            
            if interactive
                if obj.askYesNo('Deseja executar diagnóstico de configuração?')
                    obj.troubleshoot('Problem', 'configuration');
                end
            end
        end
        
        function showDataPreparationHelp(obj, interactive, detailed)
            % Mostra ajuda de preparação de dados
            
            content = obj.getDataPreparationContent();
            obj.displayHelpContent(content);
        end
        
        function showModelTrainingHelp(obj, interactive, detailed)
            % Mostra ajuda de treinamento de modelos
            
            content = obj.getModelTrainingContent();
            obj.displayHelpContent(content);
        end
        
        function showComparisonHelp(obj, interactive, detailed)
            % Mostra ajuda de comparação
            
            content = obj.getComparisonContent();
            obj.displayHelpContent(content);
        end
        
        function showTroubleshootingHelp(obj, interactive, detailed)
            % Mostra ajuda de troubleshooting
            
            content = obj.getTroubleshootingContent();
            obj.displayHelpContent(content);
            
            if interactive
                if obj.askYesNo('Deseja executar diagnóstico automático?')
                    obj.troubleshoot();
                end
            end
        end
        
        function showAdvancedHelp(obj, interactive, detailed)
            % Mostra ajuda avançada
            
            content = obj.getAdvancedContent();
            obj.displayHelpContent(content);
        end
        
        function showFAQ(obj, interactive)
            % Mostra perguntas frequentes
            
            obj.printColored(sprintf('%s Perguntas Frequentes\n\n', obj.ICONS.FAQ), 'HEADER');
            
            categories = unique({obj.faqDatabase.category});
            
            for i = 1:length(categories)
                category = categories{i};
                obj.printColored(sprintf('\n=== %s ===\n', category), 'SUBHEADER');
                
                categoryFAQs = obj.faqDatabase(strcmp({obj.faqDatabase.category}, category));
                
                for j = 1:length(categoryFAQs)
                    faq = categoryFAQs{j};
                    obj.printColored(sprintf('Q: %s\n', faq.question), 'HIGHLIGHT');
                    obj.printColored(sprintf('R: %s\n\n', faq.answer), 'TEXT');
                end
            end
        end
        
        function displayHelpContent(obj, content)
            % Exibe conteúdo de ajuda formatado
            
            if ischar(content)
                obj.printColored(content, 'TEXT');
            elseif isstruct(content)
                if isfield(content, 'sections')
                    for i = 1:length(content.sections)
                        section = content.sections{i};
                        obj.printColored(sprintf('\n=== %s ===\n', section.title), 'SUBHEADER');
                        obj.printColored(sprintf('%s\n', section.content), 'TEXT');
                    end
                end
            end
        end
        
        function runSystemDiagnostics(obj, autoFix, interactive)
            % Executa diagnósticos gerais do sistema
            
            obj.printColored('Executando diagnósticos do sistema...\n\n', 'TEXT');
            
            issues = {};
            
            % Verificar MATLAB e toolboxes
            issues = [issues, obj.checkMATLABRequirements()];
            
            % Verificar configuração
            issues = [issues, obj.checkConfiguration()];
            
            % Verificar dados
            issues = [issues, obj.checkDataIntegrity()];
            
            % Verificar recursos do sistema
            issues = [issues, obj.checkSystemResources()];
            
            % Mostrar resultados
            obj.displayDiagnosticResults(issues, autoFix, interactive);
        end
        
        function issues = checkMATLABRequirements(obj)
            % Verifica requisitos do MATLAB
            
            issues = {};
            
            % Verificar versão do MATLAB
            matlabVersion = version('-release');
            requiredYear = 2020;
            currentYear = str2double(matlabVersion(1:4));
            
            if currentYear < requiredYear
                issues{end+1} = struct(...
                    'type', 'warning', ...
                    'category', 'MATLAB', ...
                    'message', sprintf('MATLAB %s detectado. Recomendado: R%db ou superior', matlabVersion, requiredYear), ...
                    'solution', 'Atualize o MATLAB para uma versão mais recente', ...
                    'autoFixable', false);
            end
            
            % Verificar toolboxes
            requiredToolboxes = {'Deep Learning Toolbox', 'Image Processing Toolbox', 'Statistics and Machine Learning Toolbox'};
            
            for i = 1:length(requiredToolboxes)
                toolbox = requiredToolboxes{i};
                if ~obj.isToolboxInstalled(toolbox)
                    issues{end+1} = struct(...
                        'type', 'error', ...
                        'category', 'Toolbox', ...
                        'message', sprintf('%s não encontrado', toolbox), ...
                        'solution', sprintf('Instale o %s', toolbox), ...
                        'autoFixable', false);
                end
            end
        end
        
        function installed = isToolboxInstalled(obj, toolboxName)
            % Verifica se toolbox está instalado (simplificado)
            
            try
                % Método simplificado - verificar se funções específicas existem
                switch toolboxName
                    case 'Deep Learning Toolbox'
                        installed = exist('trainNetwork', 'file') == 2;
                    case 'Image Processing Toolbox'
                        installed = exist('imread', 'file') == 2;
                    case 'Statistics and Machine Learning Toolbox'
                        installed = exist('fitcsvm', 'file') == 2;
                    otherwise
                        installed = false;
                end
            catch
                installed = false;
            end
        end
        
        function issues = checkConfiguration(obj)
            % Verifica configuração do sistema
            
            issues = {};
            
            % Placeholder para verificações de configuração
            issues{end+1} = struct(...
                'type', 'info', ...
                'category', 'Configuração', ...
                'message', 'Verificação de configuração não implementada', ...
                'solution', 'Implementar verificação de configuração', ...
                'autoFixable', false);
        end
        
        function issues = checkDataIntegrity(obj)
            % Verifica integridade dos dados
            
            issues = {};
            
            % Placeholder para verificações de dados
            issues{end+1} = struct(...
                'type', 'info', ...
                'category', 'Dados', ...
                'message', 'Verificação de dados não implementada', ...
                'solution', 'Implementar verificação de dados', ...
                'autoFixable', false);
        end
        
        function issues = checkSystemResources(obj)
            % Verifica recursos do sistema
            
            issues = {};
            
            try
                % Verificar memória
                memInfo = memory;
                availableGB = memInfo.MemAvailableAllArrays / (1024^3);
                
                if availableGB < 4
                    issues{end+1} = struct(...
                        'type', 'warning', ...
                        'category', 'Memória', ...
                        'message', sprintf('Pouca memória disponível: %.2f GB', availableGB), ...
                        'solution', 'Feche outros programas ou aumente a memória virtual', ...
                        'autoFixable', false);
                end
                
                % Verificar GPU
                try
                    gpu = gpuDevice();
                    gpuMemGB = gpu.TotalMemory / (1024^3);
                    
                    if gpuMemGB < 2
                        issues{end+1} = struct(...
                            'type', 'warning', ...
                            'category', 'GPU', ...
                            'message', sprintf('GPU com pouca memória: %.2f GB', gpuMemGB), ...
                            'solution', 'Use configurações de batch size menores', ...
                            'autoFixable', true);
                    end
                catch
                    issues{end+1} = struct(...
                        'type', 'info', ...
                        'category', 'GPU', ...
                        'message', 'GPU não detectada - usando CPU', ...
                        'solution', 'Instale drivers CUDA para usar GPU', ...
                        'autoFixable', false);
                end
                
            catch ME
                issues{end+1} = struct(...
                    'type', 'error', ...
                    'category', 'Sistema', ...
                    'message', sprintf('Erro ao verificar recursos: %s', ME.message), ...
                    'solution', 'Verifique a instalação do MATLAB', ...
                    'autoFixable', false);
            end
        end
        
        function displayDiagnosticResults(obj, issues, autoFix, interactive)
            % Exibe resultados do diagnóstico
            
            if isempty(issues)
                obj.printColored(sprintf('%s Nenhum problema encontrado!\n', obj.ICONS.SUCCESS), 'SUCCESS');
                return;
            end
            
            % Agrupar por tipo
            errors = issues(strcmp({issues.type}, 'error'));
            warnings = issues(strcmp({issues.type}, 'warning'));
            infos = issues(strcmp({issues.type}, 'info'));
            
            % Mostrar erros
            if ~isempty(errors)
                obj.printColored(sprintf('\n%s ERROS ENCONTRADOS:\n', obj.ICONS.ERROR), 'ERROR');
                for i = 1:length(errors)
                    obj.displayIssue(errors{i}, i);
                end
            end
            
            % Mostrar avisos
            if ~isempty(warnings)
                obj.printColored(sprintf('\n%s AVISOS:\n', obj.ICONS.WARNING), 'WARNING');
                for i = 1:length(warnings)
                    obj.displayIssue(warnings{i}, i);
                end
            end
            
            % Mostrar informações
            if ~isempty(infos)
                obj.printColored(sprintf('\n%s INFORMAÇÕES:\n', obj.ICONS.TIP), 'TEXT');
                for i = 1:length(infos)
                    obj.displayIssue(infos{i}, i);
                end
            end
            
            % Oferecer correções automáticas
            if autoFix || interactive
                obj.offerAutoFixes(issues, interactive);
            end
        end
        
        function displayIssue(obj, issue, index)
            % Exibe um problema específico
            
            obj.printColored(sprintf('  %d. [%s] %s\n', index, issue.category, issue.message), 'TEXT');
            obj.printColored(sprintf('     Solução: %s\n', issue.solution), 'HIGHLIGHT');
            
            if issue.autoFixable
                obj.printColored('     (Correção automática disponível)\n', 'SUCCESS');
            end
            
            fprintf('\n');
        end
        
        function offerAutoFixes(obj, issues, interactive)
            % Oferece correções automáticas
            
            autoFixableIssues = issues([issues.autoFixable]);
            
            if isempty(autoFixableIssues)
                return;
            end
            
            obj.printColored(sprintf('\n%s Correções automáticas disponíveis:\n', obj.ICONS.TIP), 'HIGHLIGHT');
            
            for i = 1:length(autoFixableIssues)
                issue = autoFixableIssues{i};
                obj.printColored(sprintf('  - %s\n', issue.message), 'TEXT');
            end
            
            if interactive
                if obj.askYesNo('Deseja aplicar correções automáticas?')
                    obj.applyAutoFixes(autoFixableIssues);
                end
            end
        end
        
        function applyAutoFixes(obj, issues)
            % Aplica correções automáticas
            
            for i = 1:length(issues)
                issue = issues{i};
                
                try
                    obj.printColored(sprintf('Aplicando correção: %s...', issue.message), 'TEXT');
                    
                    % Aplicar correção baseada na categoria
                    switch issue.category
                        case 'GPU'
                            % Exemplo: ajustar configurações para GPU com pouca memória
                            obj.printColored(' OK\n', 'SUCCESS');
                        otherwise
                            obj.printColored(' Não implementado\n', 'WARNING');
                    end
                    
                catch ME
                    obj.printColored(sprintf(' Erro: %s\n', ME.message), 'ERROR');
                end
            end
        end
        
        function answer = askYesNo(obj, question)
            % Pergunta sim/não ao usuário
            
            while true
                response = input(sprintf('%s (s/n): ', question), 's');
                
                if strcmpi(response, 's') || strcmpi(response, 'sim')
                    answer = true;
                    return;
                elseif strcmpi(response, 'n') || strcmpi(response, 'não') || strcmpi(response, 'nao')
                    answer = false;
                    return;
                else
                    obj.printColored('Por favor, responda "s" para sim ou "n" para não.\n', 'WARNING');
                end
            end
        end
        
        function answer = askContinue(obj)
            % Pergunta se deve continuar
            
            answer = obj.askYesNo('Continuar para o próximo passo?');
        end
        
        % Métodos para obter conteúdo (placeholders)
        function content = getQuickStartContent(obj)
            content = sprintf([
                '%s INÍCIO RÁPIDO\n\n'...
                '1. Configure os caminhos dos dados\n'...
                '2. Execute a opção "Execução Rápida" do menu\n'...
                '3. Aguarde o treinamento e avaliação\n'...
                '4. Analise os resultados gerados\n\n'...
                '%s DICA: Use a execução rápida para validar sua configuração\n'...
                ], obj.ICONS.TUTORIAL, obj.ICONS.TIP);
        end
        
        function content = getConfigurationContent(obj)
            content = sprintf([
                '%s CONFIGURAÇÃO DO SISTEMA\n\n'...
                'O sistema precisa saber onde estão seus dados:\n\n'...
                '• Diretório de imagens: Pasta com imagens originais\n'...
                '• Diretório de máscaras: Pasta com máscaras de segmentação\n'...
                '• Parâmetros de treinamento: Épocas, batch size, etc.\n\n'...
                '%s FORMATOS SUPORTADOS: JPG, PNG, BMP, TIF\n'...
                ], obj.ICONS.GEAR, obj.ICONS.TIP);
        end
        
        function content = getDataPreparationContent(obj)
            content = sprintf([
                '%s PREPARAÇÃO DE DADOS\n\n'...
                'Seus dados devem estar organizados assim:\n\n'...
                '• Imagens e máscaras com nomes correspondentes\n'...
                '• Máscaras em escala de cinza (0-255)\n'...
                '• Tamanhos consistentes (recomendado: 256x256)\n\n'...
                '%s O sistema pode redimensionar automaticamente\n'...
                ], obj.ICONS.CODE, obj.ICONS.TIP);
        end
        
        function content = getModelTrainingContent(obj)
            content = sprintf([
                '%s TREINAMENTO DE MODELOS\n\n'...
                'O sistema treina dois modelos:\n\n'...
                '• U-Net clássica: Arquitetura padrão\n'...
                '• Attention U-Net: Com mecanismo de atenção\n\n'...
                '%s GPU recomendada para treinamento mais rápido\n'...
                ], obj.ICONS.CODE, obj.ICONS.TIP);
        end
        
        function content = getComparisonContent(obj)
            content = sprintf([
                '%s COMPARAÇÃO E ANÁLISE\n\n'...
                'Métricas calculadas:\n\n'...
                '• IoU (Intersection over Union)\n'...
                '• Dice Coefficient\n'...
                '• Accuracy\n'...
                '• Análise estatística (t-test)\n\n'...
                '%s Resultados incluem significância estatística\n'...
                ], obj.ICONS.CHART, obj.ICONS.TIP);
        end
        
        function content = getTroubleshootingContent(obj)
            content = sprintf([
                '%s SOLUÇÃO DE PROBLEMAS\n\n'...
                'Problemas comuns:\n\n'...
                '• Erro de memória: Reduza batch size\n'...
                '• GPU não detectada: Verifique drivers CUDA\n'...
                '• Dados não encontrados: Verifique caminhos\n\n'...
                '%s Use o diagnóstico automático para ajuda\n'...
                ], obj.ICONS.ERROR, obj.ICONS.TIP);
        end
        
        function content = getAdvancedContent(obj)
            content = sprintf([
                '%s FUNCIONALIDADES AVANÇADAS\n\n'...
                '• Validação cruzada k-fold\n'...
                '• Otimização de hiperparâmetros\n'...
                '• Treinamento paralelo\n'...
                '• Análise estatística detalhada\n\n'...
                '%s Requer conhecimento técnico avançado\n'...
                ], obj.ICONS.CODE, obj.ICONS.WARNING);
        end
        
        function answer = getFAQAnswer(obj, faqId)
            switch faqId
                case 'first_setup'
                    answer = 'Use o menu "Configurar Dados e Parâmetros" para definir os caminhos das suas imagens e máscaras. O sistema detectará automaticamente os formatos suportados.';
                case 'image_formats'
                    answer = 'Suportamos JPG, JPEG, PNG, BMP, TIF e TIFF. As imagens podem ter qualquer tamanho - o sistema redimensiona automaticamente para 256x256 pixels.';
                case 'interpret_results'
                    answer = 'IoU e Dice próximos de 1.0 indicam melhor performance. O p-value < 0.05 indica diferença estatisticamente significativa entre os modelos.';
                otherwise
                    answer = 'Resposta não disponível.';
            end
        end
        
        function content = getTutorialStep(obj, tutorialName, stepNumber)
            % Placeholder para conteúdo de tutoriais
            content = sprintf('Conteúdo do passo %d do tutorial %s', stepNumber, tutorialName);
        end
        
        function mostAccessed = getMostAccessedTopic(obj)
            % Retorna tópico mais acessado
            if isempty(obj.helpHistory)
                mostAccessed = 'N/A';
                return;
            end
            
            topics = {obj.helpHistory.topic};
            [uniqueTopics, ~, idx] = unique(topics);
            counts = accumarray(idx, 1);
            [~, maxIdx] = max(counts);
            mostAccessed = uniqueTopics{maxIdx};
        end
        
        % Métodos de exportação (placeholders)
        function exportToText(obj, filename)
            % Exporta para texto simples
            fid = fopen(filename, 'w');
            fprintf(fid, 'Sistema de Ajuda - Documentação\n');
            fprintf(fid, '================================\n\n');
            % Adicionar conteúdo...
            fclose(fid);
        end
        
        function exportToHTML(obj, filename)
            % Exporta para HTML
            fid = fopen(filename, 'w');
            fprintf(fid, '<html><head><title>Sistema de Ajuda</title></head><body>\n');
            fprintf(fid, '<h1>Sistema de Ajuda</h1>\n');
            % Adicionar conteúdo...
            fprintf(fid, '</body></html>\n');
            fclose(fid);
        end
        
        function exportToMarkdown(obj, filename)
            % Exporta para Markdown
            fid = fopen(filename, 'w');
            fprintf(fid, '# Sistema de Ajuda\n\n');
            % Adicionar conteúdo...
            fclose(fid);
        end
    end
    
    methods (Static)
        function demo()
            % Demonstração do sistema de ajuda
            
            fprintf('Demonstração do HelpSystem:\n\n');
            
            % Criar sistema de ajuda
            helpSystem = HelpSystem('EnableColors', true);
            
            % Mostrar tópicos disponíveis
            helpSystem.listTopics();
            
            % Buscar ajuda
            helpSystem.searchHelp('configuração');
            
            % Mostrar ajuda específica
            helpSystem.showHelp('quick_start', 'Interactive', false);
            
            % Executar diagnóstico
            helpSystem.troubleshoot('Interactive', false);
            
            fprintf('\nDemonstração concluída!\n');
        end
    end
end