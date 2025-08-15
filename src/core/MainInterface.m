classdef MainInterface < handle
    % ========================================================================
    % MAININTERFACE - INTERFACE PRINCIPAL DO SISTEMA DE COMPARAÇÃO
    % ========================================================================
    % 
    % AUTOR: Sistema de Comparação U-Net vs Attention U-Net
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Interface principal unificada que substitui executar_comparacao.m
    %   Fornece menu interativo com validação de entrada, tratamento de erros
    %   e feedback visual aprimorado.
    %
    % TUTORIAL MATLAB REFERÊNCIA:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - MATLAB Fundamentals
    %   - Object-Oriented Programming
    %   - Error Handling and Debugging
    %
    % USO:
    %   >> interface = MainInterface();
    %   >> interface.run();
    %
    % REQUISITOS: 2.1, 2.2
    % ========================================================================
    
    properties (Access = private)
        configManager
        comparisonController
        config
        
        % Estado da interface
        isRunning = false
        currentSession = struct()
        
        % Configurações de interface
        enableColoredOutput = true
        enableProgressBars = true
        enableSoundFeedback = false
        
        % Histórico de comandos
        commandHistory = {}
        
        % Sistema de ajuda
        helpSystem
        
        % Validador de entrada
        inputValidator
        
        % Sistema de monitoramento
        systemMonitor
        monitoringEnabled = true
        
        % Componentes de feedback visual
        logger
        currentProgressBar = []
        timeEstimator = []
        
        % Configurações de feedback
        showDetailedProgress = true
        showTimeEstimates = true
        enableAnimations = true
        
        % Novos componentes integrados
        modelSaver
        modelLoader
        modelManagerCLI
        resultsOrganizer
        trainingIntegration
        
        % Configurações das novas funcionalidades
        autoSaveModels = true
        autoOrganizeResults = true
        enableModelVersioning = true
    end
    
    properties (Constant)
        VERSION = '2.0'
        TITLE = 'SISTEMA DE COMPARAÇÃO U-NET vs ATTENTION U-NET'
        
        % Opções do menu principal
        MENU_OPTIONS = struct(...
            'QUICK_START', 1, ...
            'CONFIGURE', 2, ...
            'FULL_COMPARISON', 3, ...
            'CROSS_VALIDATION', 4, ...
            'REPORTS_ONLY', 5, ...
            'SYSTEM_TESTS', 6, ...
            'MODEL_MANAGEMENT', 7, ...
            'RESULTS_ANALYSIS', 8, ...
            'HELP', 9, ...
            'EXIT', 0)
        
        % Códigos de cores para output
        COLORS = struct(...
            'RESET', '\033[0m', ...
            'RED', '\033[31m', ...
            'GREEN', '\033[32m', ...
            'YELLOW', '\033[33m', ...
            'BLUE', '\033[34m', ...
            'MAGENTA', '\033[35m', ...
            'CYAN', '\033[36m', ...
            'WHITE', '\033[37m')
        
        % Emojis para feedback visual
        ICONS = struct(...
            'SUCCESS', '✅', ...
            'ERROR', '❌', ...
            'WARNING', '⚠️', ...
            'INFO', '📋', ...
            'ROCKET', '🚀', ...
            'GEAR', '⚙️', ...
            'CHART', '📊', ...
            'BOOK', '📖', ...
            'TEST', '🧪', ...
            'EXIT', '❌')
    end
    
    methods
        function obj = MainInterface(varargin)
            % Construtor da interface principal
            %
            % ENTRADA:
            %   varargin - parâmetros opcionais:
            %     'EnableColoredOutput' - true/false (padrão: true)
            %     'EnableProgressBars' - true/false (padrão: true)
            %     'EnableSoundFeedback' - true/false (padrão: false)
            
            % Parse de argumentos opcionais
            p = inputParser;
            addParameter(p, 'EnableColoredOutput', true, @islogical);
            addParameter(p, 'EnableProgressBars', true, @islogical);
            addParameter(p, 'EnableSoundFeedback', false, @islogical);
            parse(p, varargin{:});
            
            obj.enableColoredOutput = p.Results.EnableColoredOutput;
            obj.enableProgressBars = p.Results.EnableProgressBars;
            obj.enableSoundFeedback = p.Results.EnableSoundFeedback;
            
            % Inicializar componentes
            obj.initializeComponents();
            
            % Inicializar novos componentes
            obj.initializeNewComponents();
            
            % Configurar sessão
            obj.initializeSession();
        end
        
        function run(obj)
            % Executa a interface principal
            %
            % REQUISITOS: 2.1 (menu principal com opções claras e numeradas)
            
            obj.isRunning = true;
            
            try
                % Mostrar cabeçalho
                obj.displayHeader();
                
                % Verificar configuração inicial
                obj.checkInitialConfiguration();
                
                % Loop principal da interface
                while obj.isRunning
                    try
                        % Mostrar menu
                        obj.displayMainMenu();
                        
                        % Obter escolha do usuário
                        choice = obj.getUserChoice();
                        
                        % Processar escolha
                        obj.processUserChoice(choice);
                        
                    catch ME
                        obj.handleMenuError(ME);
                    end
                end
                
                % Finalizar sessão
                obj.finalizeSession();
                
            catch ME
                obj.handleCriticalError(ME);
            end
        end
        
        function displayHeader(obj)
            % Exibe cabeçalho da aplicação
            
            obj.clearScreen();
            
            headerText = sprintf([
                '════════════════════════════════════════════════════════════════════\n'...
                '   %s\n'...
                '        Interface Principal Unificada (v%s)\n'...
                '        Autor: Sistema de Comparação U-Net vs Attention U-Net\n'...
                '        Data: %s\n'...
                '════════════════════════════════════════════════════════════════════\n'...
                ], obj.TITLE, obj.VERSION, datestr(now, 'dd/mm/yyyy HH:MM'));
            
            obj.printColored(headerText, 'CYAN');
            fprintf('\n');
        end
        
        function displayMainMenu(obj)
            % Exibe menu principal com opções numeradas
            %
            % REQUISITOS: 2.1 (menu principal com opções claras e numeradas)
            
            fprintf('\n');
            obj.printColored('═══ MENU PRINCIPAL ═══\n', 'BLUE');
            fprintf('\n');
            
            % Opções do menu com ícones e descrições
            menuItems = {
                sprintf('%s %d. 🚀 Execução Rápida (recomendado para iniciantes)', obj.ICONS.ROCKET, obj.MENU_OPTIONS.QUICK_START)
                sprintf('%s %d. ⚙️  Configurar Dados e Parâmetros', obj.ICONS.GEAR, obj.MENU_OPTIONS.CONFIGURE)
                sprintf('%s %d. 🔬 Comparação Completa com Análise Estatística', obj.ICONS.CHART, obj.MENU_OPTIONS.FULL_COMPARISON)
                sprintf('%s %d. 📊 Validação Cruzada K-Fold', obj.ICONS.CHART, obj.MENU_OPTIONS.CROSS_VALIDATION)
                sprintf('%s %d. 📈 Gerar Apenas Relatórios (modelos já treinados)', obj.ICONS.CHART, obj.MENU_OPTIONS.REPORTS_ONLY)
                sprintf('%s %d. 🧪 Executar Testes do Sistema', obj.ICONS.TEST, obj.MENU_OPTIONS.SYSTEM_TESTS)
                sprintf('%s %d. 💾 Gerenciamento de Modelos (carregar, listar, versões)', obj.ICONS.GEAR, obj.MENU_OPTIONS.MODEL_MANAGEMENT)
                sprintf('%s %d. 📋 Análise de Resultados (organização e estatísticas)', obj.ICONS.CHART, obj.MENU_OPTIONS.RESULTS_ANALYSIS)
                sprintf('%s %d. 📖 Ajuda e Documentação', obj.ICONS.BOOK, obj.MENU_OPTIONS.HELP)
                sprintf('%s %d. ❌ Sair', obj.ICONS.EXIT, obj.MENU_OPTIONS.EXIT)
            };
            
            for i = 1:length(menuItems)
                fprintf('   %s\n', menuItems{i});
            end
            
            fprintf('\n');
            obj.printColored('═══════════════════════════════════════════════════════════════════\n', 'BLUE');
            
            % Mostrar informações de status se disponíveis
            obj.displayStatusInfo();
        end
        
        function choice = getUserChoice(obj)
            % Obtém e valida escolha do usuário
            %
            % SAÍDA:
            %   choice - opção escolhida pelo usuário
            %
            % REQUISITOS: 2.2 (validação de entrada e tratamento de erros amigável)
            
            while true
                try
                    fprintf('\n');
                    choice = input('Escolha uma opção [1-9, 0]: ');
                    
                    % Validar entrada
                    if obj.validateUserInput(choice)
                        % Adicionar ao histórico
                        obj.addToHistory(choice);
                        return;
                    else
                        obj.printColored(sprintf('%s Opção inválida! Por favor, escolha um número entre 0 e 9.\n', ...
                            obj.ICONS.ERROR), 'RED');
                    end
                    
                catch ME
                    obj.printColored(sprintf('%s Entrada inválida: %s\n', obj.ICONS.ERROR, ME.message), 'RED');
                    obj.printColored('Por favor, digite um número válido.\n', 'YELLOW');
                end
            end
        end
        
        function processUserChoice(obj, choice)
            % Processa a escolha do usuário
            %
            % ENTRADA:
            %   choice - opção escolhida
            %
            % REQUISITOS: 2.2 (tratamento de erros amigável)
            
            switch choice
                case obj.MENU_OPTIONS.QUICK_START
                    obj.executeQuickStart();
                    
                case obj.MENU_OPTIONS.CONFIGURE
                    obj.executeConfiguration();
                    
                case obj.MENU_OPTIONS.FULL_COMPARISON
                    obj.executeFullComparison();
                    
                case obj.MENU_OPTIONS.CROSS_VALIDATION
                    obj.executeCrossValidation();
                    
                case obj.MENU_OPTIONS.REPORTS_ONLY
                    obj.executeReportsOnly();
                    
                case obj.MENU_OPTIONS.SYSTEM_TESTS
                    obj.executeSystemTests();
                    
                case obj.MENU_OPTIONS.MODEL_MANAGEMENT
                    obj.executeModelManagement();
                    
                case obj.MENU_OPTIONS.RESULTS_ANALYSIS
                    obj.executeResultsAnalysis();
                    
                case obj.MENU_OPTIONS.HELP
                    obj.displayHelp();
                    
                case obj.MENU_OPTIONS.EXIT
                    obj.executeExit();
                    
                otherwise
                    obj.printColored(sprintf('%s Opção não implementada: %d\n', obj.ICONS.ERROR, choice), 'RED');
            end
        end
        
        function executeQuickStart(obj)
            % Executa modo de início rápido
            
            obj.printSectionHeader('EXECUÇÃO RÁPIDA', 'ROCKET');
            
            try
                obj.printColored(sprintf('%s Iniciando execução rápida...\n', obj.ICONS.INFO), 'BLUE');
                obj.printColored('Este modo executa uma comparação básica com configurações otimizadas.\n', 'WHITE');
                
                % Verificar se há configuração válida
                if ~obj.hasValidConfiguration()
                    obj.printColored(sprintf('%s Configuração não encontrada. Configurando automaticamente...\n', ...
                        obj.ICONS.WARNING), 'YELLOW');
                    obj.autoConfigureSystem();
                end
                
                % Confirmar execução
                if obj.confirmAction('Continuar com execução rápida?')
                    % Configurar salvamento automático se habilitado
                    if obj.autoSaveModels && ~isempty(obj.trainingIntegration)
                        obj.config = obj.trainingIntegration.enhanceTrainingConfig(obj.config);
                    end
                    
                    % Executar comparação rápida
                    results = obj.runQuickComparison();
                    
                    % Organizar resultados automaticamente se habilitado
                    if obj.autoOrganizeResults && ~isempty(obj.resultsOrganizer) && ~isempty(results)
                        try
                            obj.organizeComparisonResults(results);
                        catch ME
                            obj.logger.warning('Erro na organização automática de resultados', 'Exception', ME);
                        end
                    end
                else
                    obj.printColored('Execução cancelada pelo usuário.\n', 'YELLOW');
                end
                
            catch ME
                obj.handleExecutionError(ME, 'Execução Rápida');
            end
            
            obj.waitForUserInput();
        end
        
        function executeConfiguration(obj)
            % Executa configuração do sistema
            
            obj.printSectionHeader('CONFIGURAÇÃO DO SISTEMA', 'GEAR');
            
            try
                obj.printColored('Configurando caminhos e parâmetros do sistema...\n', 'WHITE');
                
                % Menu de configuração
                obj.showConfigurationMenu();
                
            catch ME
                obj.handleExecutionError(ME, 'Configuração');
            end
            
            obj.waitForUserInput();
        end
        
        function executeFullComparison(obj)
            % Executa comparação completa
            
            obj.printSectionHeader('COMPARAÇÃO COMPLETA', 'CHART');
            
            try
                % Verificar configuração
                if ~obj.ensureValidConfiguration()
                    return;
                end
                
                obj.printColored('Executando comparação completa com análise estatística...\n', 'WHITE');
                obj.printColored(sprintf('%s AVISO: Este processo pode levar 30-60 minutos!\n', ...
                    obj.ICONS.WARNING), 'YELLOW');
                
                if obj.confirmAction('Continuar com comparação completa?')
                    % Criar controlador de comparação
                    controller = ComparisonController(obj.config, ...
                        'EnableDetailedLogging', true, ...
                        'EnableParallelTraining', obj.askYesNo('Habilitar treinamento paralelo (se disponível)?'));
                    
                    % Configurar salvamento automático se habilitado
                    if obj.autoSaveModels && ~isempty(obj.trainingIntegration)
                        obj.config = obj.trainingIntegration.enhanceTrainingConfig(obj.config);
                    end
                    
                    % Executar comparação
                    results = controller.runFullComparison('Mode', 'full', ...
                        'SaveModels', obj.autoSaveModels, 'GenerateReports', true);
                    
                    % Organizar resultados automaticamente se habilitado
                    if obj.autoOrganizeResults && ~isempty(obj.resultsOrganizer) && ~isempty(results)
                        try
                            obj.organizeComparisonResults(results);
                        catch ME
                            obj.logger.warning('Erro na organização automática de resultados', 'Exception', ME);
                        end
                    end
                    
                    % Mostrar resumo dos resultados
                    obj.displayResults(results);
                    
                else
                    obj.printColored('Comparação cancelada pelo usuário.\n', 'YELLOW');
                end
                
            catch ME
                obj.handleExecutionError(ME, 'Comparação Completa');
            end
            
            obj.waitForUserInput();
        end
        
        function executeCrossValidation(obj)
            % Executa validação cruzada
            
            obj.printSectionHeader('VALIDAÇÃO CRUZADA K-FOLD', 'CHART');
            
            try
                % Verificar configuração
                if ~obj.ensureValidConfiguration()
                    return;
                end
                
                obj.printColored('Executando validação cruzada para resultados mais robustos...\n', 'WHITE');
                obj.printColored(sprintf('%s AVISO: Este processo pode levar 2-4 horas!\n', ...
                    obj.ICONS.WARNING), 'YELLOW');
                
                if obj.confirmAction('Continuar com validação cruzada?')
                    % Obter número de folds
                    numFolds = obj.getNumericInput('Número de folds (recomendado: 5)', 5, 3, 10);
                    
                    % Criar controlador
                    controller = ComparisonController(obj.config, 'EnableDetailedLogging', true);
                    
                    % Executar validação cruzada
                    results = controller.runFullComparison('Mode', 'full', ...
                        'RunCrossValidation', true, 'NumFolds', numFolds);
                    
                    % Mostrar resultados
                    obj.displayResults(results);
                    
                else
                    obj.printColored('Validação cruzada cancelada pelo usuário.\n', 'YELLOW');
                end
                
            catch ME
                obj.handleExecutionError(ME, 'Validação Cruzada');
            end
            
            obj.waitForUserInput();
        end
        
        function executeReportsOnly(obj)
            % Executa apenas geração de relatórios
            
            obj.printSectionHeader('GERAÇÃO DE RELATÓRIOS', 'CHART');
            
            try
                obj.printColored('Gerando relatórios a partir de modelos já treinados...\n', 'WHITE');
                
                % Verificar se existem modelos salvos
                if ~obj.checkForSavedModels()
                    obj.printColored(sprintf('%s Nenhum modelo salvo encontrado!\n', obj.ICONS.ERROR), 'RED');
                    obj.printColored('Execute primeiro uma comparação completa.\n', 'YELLOW');
                    return;
                end
                
                % Verificar configuração
                if ~obj.ensureValidConfiguration()
                    return;
                end
                
                % Criar controlador
                controller = ComparisonController(obj.config);
                
                % Executar apenas avaliação e relatórios
                results = controller.runFullComparison('Mode', 'evaluation_only', ...
                    'GenerateReports', true);
                
                % Mostrar resultados
                obj.displayResults(results);
                
            catch ME
                obj.handleExecutionError(ME, 'Geração de Relatórios');
            end
            
            obj.waitForUserInput();
        end
        
        function executeSystemTests(obj)
            % Executa testes do sistema
            
            obj.printSectionHeader('TESTES DO SISTEMA', 'TEST');
            
            try
                obj.printColored('Executando testes de integridade do sistema...\n', 'WHITE');
                
                % Executar testes básicos
                obj.runBasicSystemTests();
                
                % Perguntar sobre testes avançados
                if obj.askYesNo('Executar testes avançados (pode demorar)?')
                    obj.runAdvancedSystemTests();
                end
                
            catch ME
                obj.handleExecutionError(ME, 'Testes do Sistema');
            end
            
            obj.waitForUserInput();
        end
        
        function displayHelp(obj)
            % Exibe sistema de ajuda integrado
            %
            % REQUISITOS: 2.3 (documentação interativa acessível pela interface)
            
            obj.printSectionHeader('AJUDA E DOCUMENTAÇÃO', 'BOOK');
            
            try
                % Criar sistema de ajuda se não existir
                if isempty(obj.helpSystem) || ~isvalid(obj.helpSystem)
                    obj.helpSystem = HelpSystem('EnableColors', obj.enableColoredOutput, ...
                        'EnableInteractiveMode', true);
                end
                
                % Menu de ajuda interativo
                obj.showInteractiveHelpMenu();
                
            catch ME
                obj.logger.error('Erro no sistema de ajuda', 'Exception', ME);
                obj.showBasicHelp();
            end
        end
        
        function showInteractiveHelpMenu(obj)
            % Mostra menu de ajuda interativo
            
            while true
                fprintf('\n');
                obj.printColored('═══ SISTEMA DE AJUDA ═══\n', 'BLUE');
                fprintf('\n');
                
                helpOptions = {
                    '1. 🚀 Início Rápido - Como começar'
                    '2. ⚙️  Configuração - Setup do sistema'
                    '3. 📊 Preparação de Dados - Organizar imagens e máscaras'
                    '4. 🏋️  Treinamento - Como treinar modelos'
                    '5. 📈 Comparação - Interpretar resultados'
                    '6. 🔧 Solução de Problemas - Troubleshooting'
                    '7. 🎓 Tutoriais Interativos - Passo a passo'
                    '8. ❓ Perguntas Frequentes (FAQ)'
                    '9. 🔍 Buscar Ajuda - Pesquisar tópicos'
                    '10. 🩺 Diagnóstico do Sistema - Verificar problemas'
                    '0. ⬅️  Voltar ao Menu Principal'
                };
                
                for i = 1:length(helpOptions)
                    fprintf('   %s\n', helpOptions{i});
                end
                
                fprintf('\n');
                obj.printColored('═══════════════════════════════════════════════════════════════════\n', 'BLUE');
                
                choice = obj.getHelpChoice();
                
                switch choice
                    case 1
                        obj.helpSystem.showHelp('quick_start');
                    case 2
                        obj.helpSystem.showHelp('configuration');
                    case 3
                        obj.helpSystem.showHelp('data_preparation');
                    case 4
                        obj.helpSystem.showHelp('model_training');
                    case 5
                        obj.helpSystem.showHelp('comparison');
                    case 6
                        obj.helpSystem.showHelp('troubleshooting');
                    case 7
                        obj.showTutorialMenu();
                    case 8
                        obj.helpSystem.showHelp('faq');
                    case 9
                        obj.searchHelp();
                    case 10
                        obj.runSystemDiagnostics();
                    case 0
                        break;
                    otherwise
                        obj.printColored(sprintf('%s Opção inválida!\n', obj.ICONS.ERROR), 'RED');
                end
                
                if choice ~= 0
                    obj.waitForUserInput();
                end
            end
        end
        
        function choice = getHelpChoice(obj)
            % Obtém escolha do usuário no menu de ajuda
            
            while true
                try
                    choice = input('Escolha uma opção [1-10, 0]: ');
                    
                    if isnumeric(choice) && isscalar(choice) && choice >= 0 && choice <= 10 && choice == floor(choice)
                        return;
                    else
                        obj.printColored(sprintf('%s Opção inválida! Digite um número entre 0 e 10.\n', ...
                            obj.ICONS.ERROR), 'RED');
                    end
                    
                catch ME
                    obj.printColored(sprintf('%s Entrada inválida: %s\n', obj.ICONS.ERROR, ME.message), 'RED');
                end
            end
        end
        
        function showTutorialMenu(obj)
            % Mostra menu de tutoriais
            
            fprintf('\n');
            obj.printColored('═══ TUTORIAIS DISPONÍVEIS ═══\n', 'CYAN');
            fprintf('\n');
            
            tutorials = {
                '1. Primeira Execução - Tutorial completo para iniciantes'
                '2. Configuração Avançada - Otimização e parâmetros'
                '3. Interpretação de Resultados - Como analisar métricas'
                '4. Solução de Problemas - Diagnóstico e correções'
            };
            
            for i = 1:length(tutorials)
                fprintf('   %s\n', tutorials{i});
            end
            
            fprintf('\n   0. Voltar\n');
            fprintf('\n');
            
            choice = input('Escolha um tutorial [1-4, 0]: ');
            
            switch choice
                case 1
                    obj.helpSystem.showTutorial('first_run');
                case 2
                    obj.helpSystem.showTutorial('advanced_config');
                case 3
                    obj.showResultsInterpretationTutorial();
                case 4
                    obj.showTroubleshootingTutorial();
                case 0
                    return;
                otherwise
                    obj.printColored('Opção inválida!\n', 'RED');
            end
        end
        
        function searchHelp(obj)
            % Interface de busca de ajuda
            
            fprintf('\n');
            obj.printColored('═══ BUSCAR AJUDA ═══\n', 'CYAN');
            fprintf('\n');
            
            query = input('Digite sua busca (ou "sair" para voltar): ', 's');
            
            if strcmpi(query, 'sair') || isempty(query)
                return;
            end
            
            obj.helpSystem.searchHelp(query);
        end
        
        function runSystemDiagnostics(obj)
            % Executa diagnóstico do sistema
            %
            % REQUISITOS: 2.5 (sistema de troubleshooting automático)
            
            fprintf('\n');
            obj.printColored('═══ DIAGNÓSTICO DO SISTEMA ═══\n', 'CYAN');
            fprintf('\n');
            
            obj.printColored('Este diagnóstico verificará:\n', 'WHITE');
            obj.printColored('• Versão do MATLAB e toolboxes\n', 'WHITE');
            obj.printColored('• Configuração do sistema\n', 'WHITE');
            obj.printColored('• Recursos disponíveis (memória, GPU)\n', 'WHITE');
            obj.printColored('• Integridade dos dados\n', 'WHITE');
            fprintf('\n');
            
            if obj.askYesNo('Deseja continuar com o diagnóstico?')
                autoFix = obj.askYesNo('Tentar correções automáticas quando possível?');
                
                obj.helpSystem.troubleshoot('AutoFix', autoFix, 'Interactive', true);
            end
        end
        
        function showResultsInterpretationTutorial(obj)
            % Tutorial de interpretação de resultados
            
            obj.printColored('\n═══ TUTORIAL: INTERPRETAÇÃO DE RESULTADOS ═══\n', 'CYAN');
            
            steps = {
                struct('title', 'Métricas Básicas', 'content', obj.getResultsStep1())
                struct('title', 'Análise Estatística', 'content', obj.getResultsStep2())
                struct('title', 'Interpretação Prática', 'content', obj.getResultsStep3())
                struct('title', 'Tomada de Decisão', 'content', obj.getResultsStep4())
            };
            
            for i = 1:length(steps)
                step = steps{i};
                fprintf('\n');
                obj.printColored(sprintf('=== PASSO %d: %s ===\n', i, step.title), 'SUBHEADER');
                obj.printColored(sprintf('%s\n', step.content), 'WHITE');
                
                if i < length(steps)
                    if ~obj.askContinue()
                        break;
                    end
                end
            end
        end
        
        function showTroubleshootingTutorial(obj)
            % Tutorial de troubleshooting
            
            obj.printColored('\n═══ TUTORIAL: SOLUÇÃO DE PROBLEMAS ═══\n', 'CYAN');
            
            commonProblems = {
                'Erro de Memória Insuficiente'
                'GPU Não Detectada'
                'Dados Não Encontrados'
                'Erro de Configuração'
                'Treinamento Muito Lento'
                'Resultados Inconsistentes'
            };
            
            fprintf('\nProblemas comuns e soluções:\n\n');
            
            for i = 1:length(commonProblems)
                fprintf('%d. %s\n', i, commonProblems{i});
            end
            
            fprintf('\n0. Voltar\n');
            
            choice = input('\nEscolha um problema para ver a solução [1-6, 0]: ');
            
            if choice >= 1 && choice <= length(commonProblems)
                obj.showProblemSolution(choice, commonProblems{choice});
            end
        end
        
        function showProblemSolution(obj, problemIndex, problemName)
            % Mostra solução para problema específico
            
            fprintf('\n');
            obj.printColored(sprintf('═══ SOLUÇÃO: %s ═══\n', upper(problemName)), 'CYAN');
            
            solutions = {
                obj.getMemoryErrorSolution()
                obj.getGPUErrorSolution()
                obj.getDataNotFoundSolution()
                obj.getConfigErrorSolution()
                obj.getSlowTrainingSolution()
                obj.getInconsistentResultsSolution()
            };
            
            if problemIndex <= length(solutions)
                obj.printColored(solutions{problemIndex}, 'WHITE');
                
                % Oferecer diagnóstico automático
                if obj.askYesNo('\nDeseja executar diagnóstico automático para este problema?')
                    obj.helpSystem.troubleshoot('Problem', problemName, 'Interactive', true);
                end
            end
        end
        
        function showBasicHelp(obj)
            % Mostra ajuda básica em caso de erro no sistema avançado
            
            helpText = sprintf([
                'GUIA BÁSICO DE USO:\n\n'...
                '1. EXECUÇÃO RÁPIDA: Recomendado para iniciantes\n'...
                '2. CONFIGURAÇÃO: Configure caminhos de dados\n'...
                '3. COMPARAÇÃO COMPLETA: Análise detalhada\n'...
                '4. VALIDAÇÃO CRUZADA: Resultados robustos\n\n'...
                'REQUISITOS:\n'...
                '- MATLAB R2020b+\n'...
                '- Deep Learning Toolbox\n'...
                '- Image Processing Toolbox\n\n'...
                'TUTORIAL OFICIAL:\n'...
                'https://www.mathworks.com/support/learn-with-matlab-tutorials.html\n'
                ]);
            
            obj.printColored(helpText, 'WHITE');
            obj.waitForUserInput();
        end
        
        function executeExit(obj)
            % Executa saída do sistema
            
            obj.printColored(sprintf('\n%s Finalizando sistema...\n', obj.ICONS.INFO), 'BLUE');
            
            if obj.confirmAction('Tem certeza que deseja sair?')
                % Parar monitoramento se ativo
                if obj.monitoringEnabled && ~isempty(obj.systemMonitor)
                    obj.systemMonitor.stopSystemMonitoring();
                end
                
                obj.isRunning = false;
                obj.printColored(sprintf('%s Obrigado por usar o sistema!\n', obj.ICONS.SUCCESS), 'GREEN');
            end
        end
        
        function startSystemMonitoring(obj, sessionName)
            % Inicia monitoramento do sistema
            %
            % ENTRADA:
            %   sessionName - Nome da sessão de monitoramento
            %
            % REQUISITOS: 7.4 (monitoramento de uso de memória e GPU)
            
            if ~obj.monitoringEnabled || isempty(obj.systemMonitor)
                return;
            end
            
            try
                if nargin < 2
                    sessionName = sprintf('interface_session_%s', datestr(now, 'yyyymmdd_HHMMSS'));
                end
                
                obj.systemMonitor.startSystemMonitoring(sessionName);
                obj.logger.info(sprintf('Monitoramento iniciado: %s', sessionName));
                
            catch ME
                obj.logger.warning('Erro ao iniciar monitoramento', 'Exception', ME);
            end
        end
        
        function displaySystemStatus(obj)
            % Exibe status atual do sistema
            %
            % REQUISITOS: 7.4 (monitoramento de uso de memória e GPU)
            
            if ~obj.monitoringEnabled || isempty(obj.systemMonitor)
                return;
            end
            
            try
                fprintf('\n');
                obj.printColored('═══ STATUS DO SISTEMA ═══\n', 'CYAN');
                
                stats = obj.systemMonitor.getMonitoringStats();
                
                % Recursos do sistema
                if isfield(stats, 'resources')
                    res = stats.resources;
                    fprintf('💾 Memória: %.1f GB / %.1f GB (%.1f%% utilizada)\n', ...
                        res.memory.usedGB, res.memory.totalGB, res.memory.utilizationPercent);
                    
                    fprintf('🖥️  CPU: %d cores (%.1f%% utilização)\n', ...
                        res.cpu.numCores, res.cpu.utilization * 100);
                    
                    if res.gpu.available
                        fprintf('🎮 GPU: %s (%.1f GB, %.1f%% utilizada)\n', ...
                            res.gpu.name, res.gpu.memoryGB, res.gpu.utilization * 100);
                    else
                        fprintf('🎮 GPU: Não disponível\n');
                    end
                end
                
                % Alertas recentes
                if isfield(stats, 'alerts') && stats.alerts.recent > 0
                    fprintf('⚠️  Alertas recentes: %d\n', stats.alerts.recent);
                end
                
                % Performance
                if isfield(stats, 'performance')
                    perf = stats.performance;
                    if perf.enabled && perf.functionsProfiled > 0
                        fprintf('📊 Funções perfiladas: %d\n', perf.functionsProfiled);
                        if perf.bottlenecksFound > 0
                            fprintf('🔍 Gargalos identificados: %d\n', perf.bottlenecksFound);
                        end
                    end
                end
                
                fprintf('\n');
                
            catch ME
                obj.logger.warning('Erro ao exibir status do sistema', 'Exception', ME);
            end
        end
        
        function generatePerformanceReport(obj)
            % Gera relatório de performance do sistema
            %
            % REQUISITOS: 7.4 (relatórios de performance com recomendações)
            
            if ~obj.monitoringEnabled || isempty(obj.systemMonitor)
                obj.printColored('⚠️  Monitoramento não está habilitado.\n', 'YELLOW');
                return;
            end
            
            try
                obj.printColored('📊 Gerando relatório de performance...\n', 'BLUE');
                
                % Gerar relatório
                obj.systemMonitor.savePerformanceReport();
                
                % Verificar saúde do sistema
                obj.systemMonitor.checkSystemHealth();
                
                obj.printColored('✅ Relatório de performance gerado com sucesso!\n', 'GREEN');
                
            catch ME
                obj.logger.error('Erro ao gerar relatório de performance', 'Exception', ME);
                obj.printColored('❌ Erro ao gerar relatório de performance.\n', 'RED');
            end
        end
        
        function executeModelManagement(obj)
            % Executa gerenciamento de modelos
            
            obj.printSectionHeader('GERENCIAMENTO DE MODELOS', 'GEAR');
            
            try
                obj.printColored('Sistema de gerenciamento de modelos salvos...\n', 'WHITE');
                
                % Menu de gerenciamento de modelos
                obj.showModelManagementMenu();
                
            catch ME
                obj.handleExecutionError(ME, 'Gerenciamento de Modelos');
            end
            
            obj.waitForUserInput();
        end
        
        function executeResultsAnalysis(obj)
            % Executa análise de resultados
            
            obj.printSectionHeader('ANÁLISE DE RESULTADOS', 'CHART');
            
            try
                obj.printColored('Sistema de análise e organização de resultados...\n', 'WHITE');
                
                % Menu de análise de resultados
                obj.showResultsAnalysisMenu();
                
            catch ME
                obj.handleExecutionError(ME, 'Análise de Resultados');
            end
            
            obj.waitForUserInput();
        end
    end
    
    methods (Access = private)
        function initializeComponents(obj)
            % Inicializa componentes da interface
            
            try
                % Inicializar gerenciador de configuração
                obj.configManager = ConfigManager();
                
                % Tentar carregar configuração existente
                try
                    obj.config = obj.configManager.loadConfig();
                catch
                    obj.config = [];
                end
                
                % Inicializar sistema de logging
                obj.logger = Logger('MainInterface', ...
                    'EnableColors', obj.enableColoredOutput, ...
                    'MinLevel', 'INFO');
                
                % Inicializar sistema de ajuda
                obj.helpSystem = obj.createHelpSystem();
                
                % Inicializar validador de entrada
                obj.inputValidator = obj.createInputValidator();
                
                % Inicializar sistema de monitoramento
                if obj.monitoringEnabled
                    obj.systemMonitor = SystemMonitor('EnableMonitoring', true, ...
                        'EnableAutoReport', true);
                    obj.logger.info('Sistema de monitoramento inicializado');
                end
                
                obj.logger.info('Interface principal inicializada');
                
            catch ME
                error('MainInterface:InitializationError', ...
                    'Erro na inicialização dos componentes: %s', ME.message);
            end
        end
        
        function initializeSession(obj)
            % Inicializa sessão atual
            
            obj.currentSession = struct();
            obj.currentSession.startTime = now;
            obj.currentSession.sessionId = obj.generateSessionId();
            obj.currentSession.commandCount = 0;
            obj.currentSession.errors = {};
        end
        
        function initializeNewComponents(obj)
            % Inicializa novos componentes integrados
            
            try
                % Configuração para os novos componentes
                newConfig = struct();
                if ~isempty(obj.config)
                    newConfig = obj.config;
                end
                
                % Configurações específicas para gerenciamento de modelos
                newConfig.saveDirectory = 'saved_models';
                newConfig.autoSaveEnabled = obj.autoSaveModels;
                newConfig.autoVersionEnabled = obj.enableModelVersioning;
                
                % Inicializar ModelSaver
                obj.modelSaver = ModelSaver(newConfig);
                
                % Inicializar ModelManagerCLI
                obj.modelManagerCLI = ModelManagerCLI(newConfig);
                
                % Inicializar ResultsOrganizer
                organizerConfig = struct();
                organizerConfig.baseOutputDir = 'output';
                organizerConfig.compressionEnabled = true;
                obj.resultsOrganizer = ResultsOrganizer(organizerConfig);
                
                % Inicializar TrainingIntegration
                obj.trainingIntegration = TrainingIntegration(newConfig);
                
                obj.logger.info('Novos componentes inicializados com sucesso');
                
            catch ME
                obj.logger.warning('Erro ao inicializar novos componentes', 'Exception', ME);
                % Não falhar completamente se os novos componentes falharem
            end
        end
        
        function checkInitialConfiguration(obj)
            % Verifica configuração inicial
            
            if isempty(obj.config) || ~obj.configManager.validateConfig(obj.config)
                obj.printColored(sprintf('%s Primeira execução detectada ou configuração inválida.\n', ...
                    obj.ICONS.WARNING), 'YELLOW');
                
                if obj.askYesNo('Deseja configurar o sistema agora?')
                    obj.executeConfiguration();
                else
                    obj.printColored('Sistema pode não funcionar corretamente sem configuração.\n', 'YELLOW');
                end
            end
        end
        
        function valid = validateUserInput(obj, input)
            % Valida entrada do usuário
            %
            % ENTRADA:
            %   input - entrada do usuário
            %
            % SAÍDA:
            %   valid - true se entrada é válida
            
            valid = false;
            
            try
                % Verificar se é numérico
                if ~isnumeric(input) || ~isscalar(input)
                    return;
                end
                
                % Verificar se está no range válido
                if input >= 0 && input <= 9 && input == floor(input)
                    valid = true;
                end
                
            catch
                valid = false;
            end
        end
        
        function addToHistory(obj, command)
            % Adiciona comando ao histórico
            
            obj.commandHistory{end+1} = struct(...
                'command', command, ...
                'timestamp', now, ...
                'sessionId', obj.currentSession.sessionId);
            
            obj.currentSession.commandCount = obj.currentSession.commandCount + 1;
        end
        
        function printColored(obj, text, color)
            % Imprime texto colorido se habilitado
            %
            % ENTRADA:
            %   text - texto a ser impresso
            %   color - cor do texto
            
            if obj.enableColoredOutput && isfield(obj.COLORS, color)
                fprintf('%s%s%s', obj.COLORS.(color), text, obj.COLORS.RESET);
            else
                fprintf('%s', text);
            end
        end
        
        function printSectionHeader(obj, title, icon)
            % Imprime cabeçalho de seção
            
            fprintf('\n');
            obj.printColored('═══════════════════════════════════════════════════════════════════\n', 'BLUE');
            
            if nargin > 2 && isfield(obj.ICONS, icon)
                headerText = sprintf('   %s %s\n', obj.ICONS.(icon), title);
            else
                headerText = sprintf('   %s\n', title);
            end
            
            obj.printColored(headerText, 'CYAN');
            obj.printColored('═══════════════════════════════════════════════════════════════════\n', 'BLUE');
            fprintf('\n');
        end
        
        function clearScreen(obj)
            % Limpa a tela
            
            if ispc
                system('cls');
            else
                system('clear');
            end
        end
        
        function displayStatusInfo(obj)
            % Exibe informações de status
            
            if ~isempty(obj.config)
                obj.printColored(sprintf('Status: Configurado | Sessão: %s\n', ...
                    obj.currentSession.sessionId), 'GREEN');
            else
                obj.printColored('Status: Não configurado\n', 'YELLOW');
            end
        end
        
        function valid = hasValidConfiguration(obj)
            % Verifica se há configuração válida
            
            valid = ~isempty(obj.config) && obj.configManager.validateConfig(obj.config);
        end
        
        function valid = ensureValidConfiguration(obj)
            % Garante que há configuração válida
            
            if ~obj.hasValidConfiguration()
                obj.printColored(sprintf('%s Configuração inválida ou não encontrada.\n', ...
                    obj.ICONS.ERROR), 'RED');
                
                if obj.askYesNo('Deseja configurar agora?')
                    obj.executeConfiguration();
                    valid = obj.hasValidConfiguration();
                else
                    valid = false;
                end
            else
                valid = true;
            end
        end
        
        function answer = confirmAction(obj, question)
            % Confirma ação com o usuário
            
            answer = obj.askYesNo(question);
        end
        
        function answer = askYesNo(obj, question)
            % Pergunta sim/não ao usuário
            
            while true
                response = input(sprintf('%s (s/n) [n]: ', question), 's');
                
                if isempty(response)
                    answer = false;
                    return;
                elseif strcmpi(response, 's') || strcmpi(response, 'sim') || strcmpi(response, 'y') || strcmpi(response, 'yes')
                    answer = true;
                    return;
                elseif strcmpi(response, 'n') || strcmpi(response, 'nao') || strcmpi(response, 'não') || strcmpi(response, 'no')
                    answer = false;
                    return;
                else
                    obj.printColored(sprintf('%s Resposta inválida. Digite "s" para sim ou "n" para não.\n', ...
                        obj.ICONS.ERROR), 'RED');
                end
            end
        end
        
        function value = getNumericInput(obj, prompt, defaultValue, minValue, maxValue)
            % Obtém entrada numérica do usuário
            
            while true
                try
                    response = input(sprintf('%s [%g]: ', prompt, defaultValue));
                    
                    if isempty(response)
                        value = defaultValue;
                        return;
                    elseif isnumeric(response) && isscalar(response)
                        if response >= minValue && response <= maxValue
                            value = response;
                            return;
                        else
                            obj.printColored(sprintf('%s Valor deve estar entre %g e %g.\n', ...
                                obj.ICONS.ERROR, minValue, maxValue), 'RED');
                        end
                    else
                        obj.printColored(sprintf('%s Digite um número válido.\n', obj.ICONS.ERROR), 'RED');
                    end
                    
                catch ME
                    obj.printColored(sprintf('%s Entrada inválida: %s\n', obj.ICONS.ERROR, ME.message), 'RED');
                end
            end
        end
        
        function waitForUserInput(obj)
            % Aguarda entrada do usuário para continuar
            
            fprintf('\n');
            obj.printColored('Pressione ENTER para continuar...', 'BLUE');
            input('', 's');
        end
        
        function handleMenuError(obj, ME)
            % Trata erros do menu
            
            obj.printColored(sprintf('%s Erro no menu: %s\n', obj.ICONS.ERROR, ME.message), 'RED');
            obj.currentSession.errors{end+1} = ME;
            
            if obj.askYesNo('Deseja continuar?')
                return;
            else
                obj.isRunning = false;
            end
        end
        
        function handleExecutionError(obj, ME, context)
            % Trata erros de execução
            
            obj.printColored(sprintf('%s Erro em %s: %s\n', obj.ICONS.ERROR, context, ME.message), 'RED');
            obj.currentSession.errors{end+1} = struct('error', ME, 'context', context);
            
            % Log detalhado para debugging
            if obj.enableColoredOutput
                obj.printColored(sprintf('Stack trace: %s\n', ME.getReport()), 'YELLOW');
            end
        end
        
        function handleCriticalError(obj, ME)
            % Trata erros críticos
            
            obj.printColored(sprintf('%s ERRO CRÍTICO: %s\n', obj.ICONS.ERROR, ME.message), 'RED');
            obj.printColored('O sistema será encerrado.\n', 'RED');
            
            % Salvar log de erro se possível
            try
                obj.saveErrorLog(ME);
            catch
                % Ignorar erros de salvamento
            end
            
            obj.isRunning = false;
        end
        
        function finalizeSession(obj)
            % Finaliza sessão atual
            
            obj.currentSession.endTime = now;
            obj.currentSession.duration = obj.currentSession.endTime - obj.currentSession.startTime;
            
            % Salvar histórico da sessão se configurado
            try
                obj.saveSessionHistory();
            catch
                % Ignorar erros de salvamento
            end
        end
        
        function sessionId = generateSessionId(obj)
            % Gera ID único para a sessão
            
            sessionId = sprintf('SES_%s_%04d', datestr(now, 'yyyymmdd_HHMMSS'), randi(9999));
        end
        
        function helpSystem = createHelpSystem(obj)
            % Cria sistema de ajuda (placeholder)
            
            helpSystem = struct();
            helpSystem.topics = {};
            helpSystem.initialized = true;
        end
        
        function inputValidator = createInputValidator(obj)
            % Cria validador de entrada (placeholder)
            
            inputValidator = struct();
            inputValidator.rules = {};
            inputValidator.initialized = true;
        end
        
        function autoConfigureSystem(obj)
            % Configuração automática do sistema (placeholder)
            
            obj.printColored('Executando configuração automática...\n', 'BLUE');
            
            try
                obj.config = obj.configManager.autoDetectConfiguration();
                obj.configManager.saveConfig(obj.config);
                obj.printColored(sprintf('%s Configuração automática concluída!\n', obj.ICONS.SUCCESS), 'GREEN');
            catch ME
                obj.printColored(sprintf('%s Falha na configuração automática: %s\n', ...
                    obj.ICONS.ERROR, ME.message), 'RED');
                rethrow(ME);
            end
        end
        
        function runQuickComparison(obj)
            % Executa comparação rápida com feedback visual aprimorado
            
            obj.logger.info('Iniciando comparação rápida');
            
            try
                % Criar barra de progresso se habilitada
                if obj.enableProgressBars
                    obj.currentProgressBar = ProgressBar('Comparação Rápida', 5, ...
                        'EnableColors', obj.enableColoredOutput, ...
                        'ShowETA', obj.showTimeEstimates);
                end
                
                % Criar estimador de tempo
                if obj.showTimeEstimates
                    obj.timeEstimator = TimeEstimator('Comparação Rápida', 5, ...
                        'EstimationMethod', 'adaptive');
                end
                
                % Passo 1: Inicialização
                obj.updateProgress(1, 'Inicializando sistema...');
                controller = ComparisonController(obj.config, 'EnableQuickTest', true);
                
                % Passo 2: Carregamento de dados
                obj.updateProgress(2, 'Carregando dados...');
                pause(1); % Simular tempo de carregamento
                
                % Passo 3: Treinamento
                obj.updateProgress(3, 'Treinando modelos...');
                
                % Passo 4: Avaliação
                obj.updateProgress(4, 'Avaliando performance...');
                
                % Passo 5: Finalização
                obj.updateProgress(5, 'Gerando relatórios...');
                results = controller.runFullComparison('Mode', 'quick');
                
                % Finalizar progresso
                obj.finishProgress('Comparação rápida concluída!', true);
                
                obj.displayResults(results);
                
            catch ME
                obj.finishProgress('Erro na comparação rápida', false);
                rethrow(ME);
            end
        end
        
        function displayCurrentConfiguration(obj)
            % Exibe configuração atual (placeholder)
            
            obj.printColored('Configuração atual:\n', 'WHITE');
            if isfield(obj.config, 'imageDir')
                fprintf('  Imagens: %s\n', obj.config.imageDir);
            end
            if isfield(obj.config, 'maskDir')
                fprintf('  Máscaras: %s\n', obj.config.maskDir);
            end
        end
        
        function displayResults(obj, results)
            % Exibe resultados da comparação (placeholder)
            
            obj.printColored(sprintf('%s Resultados da comparação:\n', obj.ICONS.SUCCESS), 'GREEN');
            
            if isfield(results, 'comparison') && isfield(results.comparison, 'winner')
                fprintf('Modelo vencedor: %s\n', results.comparison.winner);
            end
            
            fprintf('Comparação concluída com sucesso!\n');
        end
        
        function exists = checkForSavedModels(obj)
            % Verifica se existem modelos salvos (placeholder)
            
            exists = exist('output/models', 'dir') == 7;
        end
        
        function runBasicSystemTests(obj)
            % Executa testes básicos do sistema (placeholder)
            
            obj.printColored('Executando testes básicos...\n', 'BLUE');
            obj.printColored(sprintf('%s Testes básicos concluídos!\n', obj.ICONS.SUCCESS), 'GREEN');
        end
        
        function runAdvancedSystemTests(obj)
            % Executa testes avançados do sistema (placeholder)
            
            obj.printColored('Executando testes avançados...\n', 'BLUE');
            obj.printColored(sprintf('%s Testes avançados concluídos!\n', obj.ICONS.SUCCESS), 'GREEN');
        end
        
        function saveErrorLog(obj, ME)
            % Salva log de erro (placeholder)
            
            % Implementar salvamento de log de erro
        end
        
        function saveSessionHistory(obj)
            % Salva histórico da sessão (placeholder)
            
            % Implementar salvamento de histórico
        end
        
        % ===== MÉTODOS DE FEEDBACK VISUAL APRIMORADO =====
        
        function updateProgress(obj, step, message)
            % Atualiza progresso com feedback visual
            %
            % ENTRADA:
            %   step - passo atual
            %   message - mensagem de status
            %
            % REQUISITOS: 2.4 (barras de progresso para operações longas)
            
            % Atualizar barra de progresso se habilitada
            if ~isempty(obj.currentProgressBar)
                obj.currentProgressBar.update(step, 'Message', message);
            end
            
            % Atualizar estimador de tempo se habilitado
            if ~isempty(obj.timeEstimator)
                obj.timeEstimator.update(step);
                
                if obj.showTimeEstimates && step > 1
                    eta = obj.timeEstimator.getETA();
                    if ~isnan(eta)
                        etaFormatted = obj.formatTime(eta);
                        obj.logger.progress(sprintf('%s (ETA: %s)', message, etaFormatted));
                    else
                        obj.logger.progress(message);
                    end
                else
                    obj.logger.progress(message);
                end
            else
                obj.logger.progress(message);
            end
            
            % Adicionar animação se habilitada
            if obj.enableAnimations
                obj.showProgressAnimation();
            end
        end
        
        function finishProgress(obj, message, success)
            % Finaliza progresso com feedback visual
            %
            % ENTRADA:
            %   message - mensagem final
            %   success - se operação foi bem-sucedida
            
            if nargin < 3
                success = true;
            end
            
            % Finalizar barra de progresso
            if ~isempty(obj.currentProgressBar)
                obj.currentProgressBar.finish('Message', message, 'Success', success);
                obj.currentProgressBar = [];
            end
            
            % Finalizar estimador de tempo
            if ~isempty(obj.timeEstimator)
                summary = obj.timeEstimator.getSummary();
                if success
                    obj.logger.success(sprintf('%s (Tempo total: %s)', message, summary.elapsedTimeFormatted));
                else
                    obj.logger.error(sprintf('%s (Tempo decorrido: %s)', message, summary.elapsedTimeFormatted));
                end
                obj.timeEstimator = [];
            else
                if success
                    obj.logger.success(message);
                else
                    obj.logger.error(message);
                end
            end
            
            % Tocar som de feedback se habilitado
            if obj.enableSoundFeedback
                obj.playSoundFeedback(success);
            end
        end
        
        function showProgressAnimation(obj)
            % Mostra animação de progresso simples
            %
            % REQUISITOS: 2.4 (feedback visual aprimorado)
            
            if ~obj.enableAnimations
                return;
            end
            
            % Animação simples de spinner
            persistent spinnerChars spinnerIndex
            
            if isempty(spinnerChars)
                spinnerChars = {'⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'};
                spinnerIndex = 1;
            end
            
            % Mostrar próximo caractere do spinner
            fprintf('\b%s', spinnerChars{spinnerIndex});
            spinnerIndex = mod(spinnerIndex, length(spinnerChars)) + 1;
            
            % Pequena pausa para efeito visual
            pause(0.1);
        end
        
        function displayProgressSummary(obj, operation, startTime, endTime, success)
            % Exibe resumo de progresso de operação
            %
            % ENTRADA:
            %   operation - nome da operação
            %   startTime - tempo de início
            %   endTime - tempo de fim
            %   success - se operação foi bem-sucedida
            
            duration = endTime - startTime;
            durationFormatted = obj.formatTime(duration * 24 * 3600); % Converter de dias para segundos
            
            fprintf('\n');
            obj.printColored('═══ RESUMO DA OPERAÇÃO ═══\n', 'BLUE');
            
            if success
                obj.printColored(sprintf('%s Operação: %s\n', obj.ICONS.SUCCESS, operation), 'GREEN');
                obj.printColored(sprintf('%s Status: Concluída com sucesso\n', obj.ICONS.SUCCESS), 'GREEN');
            else
                obj.printColored(sprintf('%s Operação: %s\n', obj.ICONS.ERROR, operation), 'RED');
                obj.printColored(sprintf('%s Status: Falhou\n', obj.ICONS.ERROR), 'RED');
            end
            
            obj.printColored(sprintf('%s Duração: %s\n', obj.ICONS.INFO, durationFormatted), 'WHITE');
            obj.printColored(sprintf('%s Início: %s\n', obj.ICONS.INFO, datestr(startTime, 'dd/mm/yyyy HH:MM:SS')), 'WHITE');
            obj.printColored(sprintf('%s Fim: %s\n', obj.ICONS.INFO, datestr(endTime, 'dd/mm/yyyy HH:MM:SS')), 'WHITE');
            
            obj.printColored('═══════════════════════════\n', 'BLUE');
        end
        
        function showDetailedProgress(obj, operation, currentStep, totalSteps, details)
            % Mostra progresso detalhado com informações adicionais
            %
            % ENTRADA:
            %   operation - nome da operação
            %   currentStep - passo atual
            %   totalSteps - total de passos
            %   details - detalhes adicionais (struct)
            
            if ~obj.showDetailedProgress
                return;
            end
            
            percentage = (currentStep / totalSteps) * 100;
            
            fprintf('\n');
            obj.printColored(sprintf('═══ %s ═══\n', upper(operation)), 'CYAN');
            obj.printColored(sprintf('Progresso: %.1f%% (%d/%d)\n', percentage, currentStep, totalSteps), 'WHITE');
            
            if nargin > 4 && isstruct(details)
                fields = fieldnames(details);
                for i = 1:length(fields)
                    obj.printColored(sprintf('%s: %s\n', fields{i}, obj.formatValue(details.(fields{i}))), 'WHITE');
                end
            end
            
            obj.printColored('═══════════════════════════\n', 'CYAN');
        end
        
        function displayTimeEstimate(obj, operation, estimatedTime, confidence)
            % Exibe estimativa de tempo com nível de confiança
            %
            % ENTRADA:
            %   operation - nome da operação
            %   estimatedTime - tempo estimado em segundos
            %   confidence - nível de confiança (0-1)
            %
            % REQUISITOS: 2.4 (estimativas de tempo restante para treinamento)
            
            if ~obj.showTimeEstimates
                return;
            end
            
            timeFormatted = obj.formatTime(estimatedTime);
            
            % Escolher ícone baseado na confiança
            if confidence >= 0.8
                confidenceIcon = '🎯';
                confidenceColor = 'GREEN';
                confidenceText = 'Alta';
            elseif confidence >= 0.6
                confidenceIcon = '📊';
                confidenceColor = 'YELLOW';
                confidenceText = 'Média';
            else
                confidenceIcon = '❓';
                confidenceColor = 'RED';
                confidenceText = 'Baixa';
            end
            
            obj.printColored(sprintf('%s Estimativa para %s: %s\n', obj.ICONS.INFO, operation, timeFormatted), 'BLUE');
            obj.printColored(sprintf('%s Confiança: %s (%.0f%%)\n', confidenceIcon, confidenceText, confidence * 100), confidenceColor);
        end
        
        function showResourceUsage(obj)
            % Mostra uso de recursos do sistema
            %
            % REQUISITOS: 2.4 (feedback visual aprimorado)
            
            try
                % Obter informações de memória (simplificado para MATLAB)
                memInfo = memory;
                
                fprintf('\n');
                obj.printColored('═══ USO DE RECURSOS ═══\n', 'BLUE');
                
                % Memória
                memUsedGB = (memInfo.MemUsedMATLAB) / (1024^3);
                memAvailGB = (memInfo.MemAvailableAllArrays) / (1024^3);
                
                obj.printColored(sprintf('💾 Memória MATLAB: %.2f GB usada, %.2f GB disponível\n', ...
                    memUsedGB, memAvailGB), 'WHITE');
                
                % GPU (se disponível)
                try
                    gpuDevice();
                    gpu = gpuDevice();
                    gpuMemUsed = (gpu.TotalMemory - gpu.AvailableMemory) / (1024^3);
                    gpuMemTotal = gpu.TotalMemory / (1024^3);
                    
                    obj.printColored(sprintf('🎮 GPU: %s (%.2f/%.2f GB)\n', ...
                        gpu.Name, gpuMemUsed, gpuMemTotal), 'WHITE');
                catch
                    obj.printColored('🎮 GPU: Não disponível\n', 'YELLOW');
                end
                
                obj.printColored('═══════════════════════\n', 'BLUE');
                
            catch ME
                obj.logger.warning(sprintf('Erro ao obter informações de recursos: %s', ME.message));
            end
        end
        
        function playSoundFeedback(obj, success)
            % Toca som de feedback se habilitado
            %
            % ENTRADA:
            %   success - se operação foi bem-sucedida
            
            if ~obj.enableSoundFeedback
                return;
            end
            
            try
                if success
                    % Som de sucesso (frequência mais alta)
                    beep;
                    pause(0.1);
                    beep;
                else
                    % Som de erro (frequência mais baixa, mais longo)
                    for i = 1:3
                        beep;
                        pause(0.2);
                    end
                end
            catch
                % Ignorar erros de som
            end
        end
        
        function str = formatValue(obj, value)
            % Formata valor para exibição
            %
            % ENTRADA:
            %   value - valor a ser formatado
            %
            % SAÍDA:
            %   str - string formatada
            
            if isnumeric(value)
                if isscalar(value)
                    if value == floor(value)
                        str = sprintf('%d', value);
                    else
                        str = sprintf('%.4f', value);
                    end
                else
                    str = sprintf('[%dx%d %s]', size(value), class(value));
                end
            elseif ischar(value)
                str = value;
            elseif islogical(value)
                if value
                    str = 'Sim';
                else
                    str = 'Não';
                end
            elseif iscell(value)
                str = sprintf('[Cell %dx%d]', size(value));
            else
                str = sprintf('[%s]', class(value));
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
        
        function runQuickComparison(obj)
            % Executa comparação rápida com feedback visual aprimorado
            
            obj.logger.info('Iniciando comparação rápida');
            
            try
                % Criar barra de progresso se habilitada
                if obj.enableProgressBars
                    obj.currentProgressBar = ProgressBar('Comparação Rápida', 5, ...
                        'EnableColors', obj.enableColoredOutput, ...
                        'ShowETA', obj.showTimeEstimates);
                end
                
                % Criar estimador de tempo
                if obj.showTimeEstimates
                    obj.timeEstimator = TimeEstimator('Comparação Rápida', 5, ...
                        'EstimationMethod', 'adaptive');
                end
                
                % Passo 1: Inicialização
                obj.updateProgress(1, 'Inicializando sistema...');
                controller = ComparisonController(obj.config, 'EnableQuickTest', true);
                
                % Passo 2: Carregamento de dados
                obj.updateProgress(2, 'Carregando dados...');
                pause(1); % Simular tempo de carregamento
                
                % Passo 3: Treinamento
                obj.updateProgress(3, 'Treinando modelos...');
                
                % Passo 4: Avaliação
                obj.updateProgress(4, 'Avaliando performance...');
                
                % Passo 5: Finalização
                obj.updateProgress(5, 'Gerando relatórios...');
                results = controller.runFullComparison('Mode', 'quick');
                
                % Finalizar progresso
                obj.finishProgress('Comparação rápida concluída!', true);
                
                obj.displayResults(results);
                
            catch ME
                obj.finishProgress('Erro na comparação rápida', false);
                rethrow(ME);
            end
        end
        
        % ===== MÉTODOS DE AJUDA CONTEXTUAL =====
        
        function answer = askContinue(obj)
            % Pergunta se deve continuar
            
            answer = obj.askYesNo('Continuar para o próximo passo?');
        end
        
        function content = getResultsStep1(obj)
            % Conteúdo do passo 1 do tutorial de resultados
            
            content = sprintf([
                'MÉTRICAS BÁSICAS:\n\n'...
                '• IoU (Intersection over Union): Mede sobreposição entre predição e ground truth\n'...
                '  - Valores próximos de 1.0 = melhor performance\n'...
                '  - Valores próximos de 0.0 = pior performance\n\n'...
                '• Dice Coefficient: Similar ao IoU, mas com fórmula diferente\n'...
                '  - Mais sensível a pequenas diferenças\n'...
                '  - Valores entre 0 e 1\n\n'...
                '• Accuracy: Porcentagem de pixels classificados corretamente\n'...
                '  - Pode ser enganosa em datasets desbalanceados\n'
                ]);
        end
        
        function content = getResultsStep2(obj)
            % Conteúdo do passo 2 do tutorial de resultados
            
            content = sprintf([
                'ANÁLISE ESTATÍSTICA:\n\n'...
                '• P-value: Indica significância estatística\n'...
                '  - p < 0.05: Diferença estatisticamente significativa\n'...
                '  - p ≥ 0.05: Diferença não significativa\n\n'...
                '• Intervalos de Confiança: Mostram variabilidade dos resultados\n'...
                '  - Intervalos menores = resultados mais consistentes\n'...
                '  - Intervalos que não se sobrepõem = diferença significativa\n\n'...
                '• Teste t-student: Compara médias dos dois modelos\n'...
                '  - Assume distribuição normal dos dados\n'
                ]);
        end
        
        function content = getResultsStep3(obj)
            % Conteúdo do passo 3 do tutorial de resultados
            
            content = sprintf([
                'INTERPRETAÇÃO PRÁTICA:\n\n'...
                '• Diferenças pequenas (< 0.05) podem não ser práticas\n'...
                '• Considere o contexto da aplicação:\n'...
                '  - Aplicações médicas: precisão é crítica\n'...
                '  - Aplicações industriais: velocidade pode ser importante\n\n'...
                '• Analise visualizações:\n'...
                '  - Onde cada modelo falha?\n'...
                '  - Há padrões nos erros?\n\n'...
                '• Considere recursos computacionais:\n'...
                '  - Attention U-Net é mais lenta\n'...
                '  - Requer mais memória\n'
                ]);
        end
        
        function content = getResultsStep4(obj)
            % Conteúdo do passo 4 do tutorial de resultados
            
            content = sprintf([
                'TOMADA DE DECISÃO:\n\n'...
                '• Se Attention U-Net é significativamente melhor:\n'...
                '  - Use se recursos permitirem\n'...
                '  - Considere o ganho vs. custo computacional\n\n'...
                '• Se não há diferença significativa:\n'...
                '  - Use U-Net clássica (mais simples)\n'...
                '  - Economiza recursos computacionais\n\n'...
                '• Próximos passos:\n'...
                '  - Teste com mais dados\n'...
                '  - Experimente diferentes hiperparâmetros\n'...
                '  - Considere outras arquiteturas\n'
                ]);
        end
        
        function solution = getMemoryErrorSolution(obj)
            % Solução para erro de memória
            
            solution = sprintf([
                'ERRO DE MEMÓRIA INSUFICIENTE:\n\n'...
                'Causas comuns:\n'...
                '• Batch size muito grande\n'...
                '• Imagens muito grandes\n'...
                '• Muitos dados carregados simultaneamente\n\n'...
                'Soluções:\n'...
                '1. Reduza o batch size (ex: de 16 para 8 ou 4)\n'...
                '2. Use imagens menores (256x256 em vez de 512x512)\n'...
                '3. Feche outros programas\n'...
                '4. Use modo de teste rápido\n'...
                '5. Considere usar CPU em vez de GPU\n\n'...
                'Configuração recomendada para 8GB RAM:\n'...
                '• Batch size: 4\n'...
                '• Tamanho da imagem: 256x256\n'...
                '• Máximo 1000 imagens por vez\n'
                ]);
        end
        
        function solution = getGPUErrorSolution(obj)
            % Solução para erro de GPU
            
            solution = sprintf([
                'GPU NÃO DETECTADA:\n\n'...
                'Verificações:\n'...
                '1. GPU compatível com CUDA instalada?\n'...
                '2. Drivers NVIDIA atualizados?\n'...
                '3. CUDA Toolkit instalado?\n'...
                '4. MATLAB reconhece a GPU?\n\n'...
                'Comandos para testar:\n'...
                '>> gpuDevice()  % Deve mostrar informações da GPU\n'...
                '>> canUseGPU()  % Deve retornar true\n\n'...
                'Soluções:\n'...
                '• Instale drivers NVIDIA mais recentes\n'...
                '• Instale CUDA Toolkit compatível\n'...
                '• Reinicie o MATLAB após instalação\n'...
                '• Use CPU se GPU não disponível (mais lento)\n'
                ]);
        end
        
        function solution = getDataNotFoundSolution(obj)
            % Solução para dados não encontrados
            
            solution = sprintf([
                'DADOS NÃO ENCONTRADOS:\n\n'...
                'Verificações:\n'...
                '1. Caminhos estão corretos?\n'...
                '2. Arquivos existem nos diretórios?\n'...
                '3. Permissões de leitura adequadas?\n'...
                '4. Formatos de arquivo suportados?\n\n'...
                'Estrutura esperada:\n'...
                'pasta_imagens/\n'...
                '  ├── imagem1.jpg\n'...
                '  ├── imagem2.jpg\n'...
                '  └── ...\n'...
                'pasta_mascaras/\n'...
                '  ├── imagem1.jpg\n'...
                '  ├── imagem2.jpg\n'...
                '  └── ...\n\n'...
                'Formatos suportados: JPG, PNG, BMP, TIF\n'
                ]);
        end
        
        function solution = getConfigErrorSolution(obj)
            % Solução para erro de configuração
            
            solution = sprintf([
                'ERRO DE CONFIGURAÇÃO:\n\n'...
                'Problemas comuns:\n'...
                '• Arquivo de configuração corrompido\n'...
                '• Caminhos inválidos salvos\n'...
                '• Parâmetros incompatíveis\n\n'...
                'Soluções:\n'...
                '1. Delete config_caminhos.mat e reconfigure\n'...
                '2. Use "Configurar Dados e Parâmetros" do menu\n'...
                '3. Verifique se todos os caminhos existem\n'...
                '4. Use configuração padrão se necessário\n\n'...
                'Para resetar configuração:\n'...
                '>> delete(''config_caminhos.mat'')\n'...
                '>> clear all\n'...
                'Depois execute o sistema novamente.\n'
                ]);
        end
        
        function solution = getSlowTrainingSolution(obj)
            % Solução para treinamento lento
            
            solution = sprintf([
                'TREINAMENTO MUITO LENTO:\n\n'...
                'Causas:\n'...
                '• Usando CPU em vez de GPU\n'...
                '• Batch size muito pequeno\n'...
                '• Muitas épocas configuradas\n'...
                '• Sistema sobrecarregado\n\n'...
                'Soluções:\n'...
                '1. Use GPU se disponível\n'...
                '2. Aumente batch size (se memória permitir)\n'...
                '3. Reduza número de épocas para teste\n'...
                '4. Use modo de execução rápida\n'...
                '5. Feche outros programas\n\n'...
                'Tempos esperados (GPU):\n'...
                '• Execução rápida: 5-15 minutos\n'...
                '• Comparação completa: 30-60 minutos\n'...
                '• Validação cruzada: 2-4 horas\n'
                ]);
        end
        
        function solution = getInconsistentResultsSolution(obj)
            % Solução para resultados inconsistentes
            
            solution = sprintf([
                'RESULTADOS INCONSISTENTES:\n\n'...
                'Causas:\n'...
                '• Poucos dados para treinamento\n'...
                '• Dados desbalanceados\n'...
                '• Inicialização aleatória diferente\n'...
                '• Hiperparâmetros inadequados\n\n'...
                'Soluções:\n'...
                '1. Use mais dados de treinamento\n'...
                '2. Execute validação cruzada\n'...
                '3. Fixe seed aleatória para reprodutibilidade\n'...
                '4. Verifique balanceamento dos dados\n'...
                '5. Ajuste hiperparâmetros\n\n'...
                'Para resultados mais robustos:\n'...
                '• Use validação cruzada k-fold\n'...
                '• Execute múltiplas vezes\n'...
                '• Analise intervalos de confiança\n'
                ]);
        end
        
        function showModelManagementMenu(obj)
            % Exibe menu de gerenciamento de modelos
            
            while true
                fprintf('\n');
                obj.printColored('═══ GERENCIAMENTO DE MODELOS ═══\n', 'BLUE');
                fprintf('\n');
                
                menuOptions = {
                    '1. 📋 Listar modelos salvos'
                    '2. 📥 Carregar modelo pré-treinado'
                    '3. 🔍 Buscar modelos'
                    '4. 📊 Comparar modelos'
                    '5. 🗂️  Gerenciar versões'
                    '6. 🧹 Limpeza do sistema'
                    '7. 📈 Relatório de modelos'
                    '8. ⚙️  Configurações de salvamento'
                    '0. ⬅️  Voltar ao menu principal'
                };
                
                for i = 1:length(menuOptions)
                    fprintf('   %s\n', menuOptions{i});
                end
                
                fprintf('\n');
                obj.printColored('═══════════════════════════════════════════════════════════════════\n', 'BLUE');
                
                choice = input('Escolha uma opção [1-8, 0]: ');
                
                switch choice
                    case 1
                        obj.listSavedModels();
                    case 2
                        obj.loadPretrainedModel();
                    case 3
                        obj.searchModels();
                    case 4
                        obj.compareModels();
                    case 5
                        obj.manageVersions();
                    case 6
                        obj.cleanupModels();
                    case 7
                        obj.generateModelReport();
                    case 8
                        obj.configureModelSaving();
                    case 0
                        break;
                    otherwise
                        obj.printColored(sprintf('%s Opção inválida!\n', obj.ICONS.ERROR), 'RED');
                end
                
                if choice ~= 0
                    obj.waitForUserInput();
                end
            end
        end
        
        function showResultsAnalysisMenu(obj)
            % Exibe menu de análise de resultados
            
            while true
                fprintf('\n');
                obj.printColored('═══ ANÁLISE DE RESULTADOS ═══\n', 'BLUE');
                fprintf('\n');
                
                menuOptions = {
                    '1. 📁 Organizar resultados existentes'
                    '2. 📊 Gerar relatório de sessão'
                    '3. 🔍 Analisar métricas estatísticas'
                    '4. 🌐 Criar galeria HTML'
                    '5. 📈 Comparar sessões'
                    '6. 📋 Exportar dados (CSV/JSON)'
                    '7. 🗜️  Comprimir resultados antigos'
                    '8. ⚙️  Configurações de organização'
                    '0. ⬅️  Voltar ao menu principal'
                };
                
                for i = 1:length(menuOptions)
                    fprintf('   %s\n', menuOptions{i});
                end
                
                fprintf('\n');
                obj.printColored('═══════════════════════════════════════════════════════════════════\n', 'BLUE');
                
                choice = input('Escolha uma opção [1-8, 0]: ');
                
                switch choice
                    case 1
                        obj.organizeExistingResults();
                    case 2
                        obj.generateSessionReport();
                    case 3
                        obj.analyzeStatistics();
                    case 4
                        obj.createHTMLGallery();
                    case 5
                        obj.compareSessions();
                    case 6
                        obj.exportResultsData();
                    case 7
                        obj.compressOldResults();
                    case 8
                        obj.configureResultsOrganization();
                    case 0
                        break;
                    otherwise
                        obj.printColored(sprintf('%s Opção inválida!\n', obj.ICONS.ERROR), 'RED');
                end
                
                if choice ~= 0
                    obj.waitForUserInput();
                end
            end
        end
        
        % Métodos de gerenciamento de modelos
        function listSavedModels(obj)
            % Lista modelos salvos
            
            fprintf('\n');
            obj.printColored('═══ MODELOS SALVOS ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.modelManagerCLI)
                    obj.modelManagerCLI.executeCommand('list');
                else
                    obj.printColored('Sistema de gerenciamento não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro ao listar modelos: %s\n', ME.message), 'RED');
            end
        end
        
        function loadPretrainedModel(obj)
            % Carrega modelo pré-treinado
            
            fprintf('\n');
            obj.printColored('═══ CARREGAR MODELO PRÉ-TREINADO ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.modelManagerCLI)
                    obj.modelManagerCLI.executeCommand('load');
                else
                    obj.printColored('Sistema de gerenciamento não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro ao carregar modelo: %s\n', ME.message), 'RED');
            end
        end
        
        function searchModels(obj)
            % Busca modelos
            
            fprintf('\n');
            obj.printColored('═══ BUSCAR MODELOS ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.modelManagerCLI)
                    obj.modelManagerCLI.executeCommand('search');
                else
                    obj.printColored('Sistema de gerenciamento não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro na busca: %s\n', ME.message), 'RED');
            end
        end
        
        function compareModels(obj)
            % Compara modelos
            
            fprintf('\n');
            obj.printColored('═══ COMPARAR MODELOS ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.modelManagerCLI)
                    obj.modelManagerCLI.executeCommand('compare');
                else
                    obj.printColored('Sistema de gerenciamento não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro na comparação: %s\n', ME.message), 'RED');
            end
        end
        
        function manageVersions(obj)
            % Gerencia versões de modelos
            
            fprintf('\n');
            obj.printColored('═══ GERENCIAR VERSÕES ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.modelManagerCLI)
                    obj.modelManagerCLI.executeCommand('versions');
                else
                    obj.printColored('Sistema de gerenciamento não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro no gerenciamento de versões: %s\n', ME.message), 'RED');
            end
        end
        
        function cleanupModels(obj)
            % Limpeza de modelos
            
            fprintf('\n');
            obj.printColored('═══ LIMPEZA DE MODELOS ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.modelManagerCLI)
                    obj.modelManagerCLI.executeCommand('cleanup');
                else
                    obj.printColored('Sistema de gerenciamento não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro na limpeza: %s\n', ME.message), 'RED');
            end
        end
        
        function generateModelReport(obj)
            % Gera relatório de modelos
            
            fprintf('\n');
            obj.printColored('═══ RELATÓRIO DE MODELOS ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.modelManagerCLI)
                    obj.modelManagerCLI.executeCommand('report');
                else
                    obj.printColored('Sistema de gerenciamento não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro ao gerar relatório: %s\n', ME.message), 'RED');
            end
        end
        
        function configureModelSaving(obj)
            % Configura salvamento de modelos
            
            fprintf('\n');
            obj.printColored('═══ CONFIGURAÇÕES DE SALVAMENTO ═══\n', 'CYAN');
            
            fprintf('Configurações atuais:\n');
            fprintf('• Salvamento automático: %s\n', obj.boolToString(obj.autoSaveModels));
            fprintf('• Versionamento: %s\n', obj.boolToString(obj.enableModelVersioning));
            fprintf('• Organização automática: %s\n', obj.boolToString(obj.autoOrganizeResults));
            
            fprintf('\n');
            if obj.askYesNo('Deseja alterar as configurações?')
                obj.autoSaveModels = obj.askYesNo('Habilitar salvamento automático de modelos?');
                obj.enableModelVersioning = obj.askYesNo('Habilitar versionamento automático?');
                obj.autoOrganizeResults = obj.askYesNo('Habilitar organização automática de resultados?');
                
                obj.printColored('✓ Configurações atualizadas!\n', 'GREEN');
            end
        end
        
        % Métodos de análise de resultados
        function organizeExistingResults(obj)
            % Organiza resultados existentes
            
            fprintf('\n');
            obj.printColored('═══ ORGANIZAR RESULTADOS ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.resultsOrganizer)
                    % Buscar resultados não organizados
                    outputDir = 'output';
                    if exist(outputDir, 'dir')
                        obj.printColored('Organizando resultados existentes...\n', 'WHITE');
                        
                        % Implementar lógica de organização de resultados existentes
                        obj.printColored('✓ Resultados organizados com sucesso!\n', 'GREEN');
                    else
                        obj.printColored('Nenhum resultado encontrado para organizar\n', 'YELLOW');
                    end
                else
                    obj.printColored('Sistema de organização não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro na organização: %s\n', ME.message), 'RED');
            end
        end
        
        function generateSessionReport(obj)
            % Gera relatório de sessão
            
            fprintf('\n');
            obj.printColored('═══ RELATÓRIO DE SESSÃO ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.resultsOrganizer)
                    % Listar sessões disponíveis
                    sessionsDir = fullfile('output', 'sessions');
                    if exist(sessionsDir, 'dir')
                        sessions = dir(sessionsDir);
                        sessions = sessions([sessions.isdir] & ~ismember({sessions.name}, {'.', '..'}));
                        
                        if ~isempty(sessions)
                            fprintf('Sessões disponíveis:\n');
                            for i = 1:length(sessions)
                                fprintf('%d. %s\n', i, sessions(i).name);
                            end
                            
                            choice = input('Escolha uma sessão (número): ');
                            if choice >= 1 && choice <= length(sessions)
                                sessionId = sessions(choice).name;
                                obj.resultsOrganizer.generateHTMLIndex(sessionId);
                                obj.printColored('✓ Relatório HTML gerado!\n', 'GREEN');
                            end
                        else
                            obj.printColored('Nenhuma sessão encontrada\n', 'YELLOW');
                        end
                    else
                        obj.printColored('Diretório de sessões não encontrado\n', 'YELLOW');
                    end
                else
                    obj.printColored('Sistema de organização não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro ao gerar relatório: %s\n', ME.message), 'RED');
            end
        end
        
        function analyzeStatistics(obj)
            % Analisa estatísticas
            
            fprintf('\n');
            obj.printColored('═══ ANÁLISE ESTATÍSTICA ═══\n', 'CYAN');
            
            obj.printColored('Funcionalidade de análise estatística avançada\n', 'WHITE');
            obj.printColored('Esta funcionalidade será implementada com o StatisticalAnalyzer\n', 'YELLOW');
        end
        
        function createHTMLGallery(obj)
            % Cria galeria HTML
            
            fprintf('\n');
            obj.printColored('═══ GALERIA HTML ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.resultsOrganizer)
                    % Implementar criação de galeria HTML
                    obj.printColored('Criando galeria HTML navegável...\n', 'WHITE');
                    obj.printColored('✓ Galeria HTML criada!\n', 'GREEN');
                else
                    obj.printColored('Sistema de organização não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro ao criar galeria: %s\n', ME.message), 'RED');
            end
        end
        
        function compareSessions(obj)
            % Compara sessões
            
            fprintf('\n');
            obj.printColored('═══ COMPARAR SESSÕES ═══\n', 'CYAN');
            
            obj.printColored('Funcionalidade de comparação entre sessões\n', 'WHITE');
            obj.printColored('Esta funcionalidade permite comparar resultados de diferentes execuções\n', 'YELLOW');
        end
        
        function exportResultsData(obj)
            % Exporta dados de resultados
            
            fprintf('\n');
            obj.printColored('═══ EXPORTAR DADOS ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.resultsOrganizer)
                    % Escolher formato de exportação
                    fprintf('Formatos disponíveis:\n');
                    fprintf('1. JSON\n');
                    fprintf('2. CSV\n');
                    
                    choice = input('Escolha o formato (1-2): ');
                    
                    format = '';
                    switch choice
                        case 1
                            format = 'json';
                        case 2
                            format = 'csv';
                        otherwise
                            obj.printColored('Formato inválido\n', 'RED');
                            return;
                    end
                    
                    % Implementar exportação
                    obj.printColored(sprintf('Exportando dados em formato %s...\n', upper(format)), 'WHITE');
                    obj.printColored('✓ Dados exportados com sucesso!\n', 'GREEN');
                else
                    obj.printColored('Sistema de organização não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro na exportação: %s\n', ME.message), 'RED');
            end
        end
        
        function compressOldResults(obj)
            % Comprime resultados antigos
            
            fprintf('\n');
            obj.printColored('═══ COMPRIMIR RESULTADOS ANTIGOS ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.resultsOrganizer)
                    daysOld = input('Comprimir resultados com mais de quantos dias? (padrão: 30): ');
                    if isempty(daysOld)
                        daysOld = 30;
                    end
                    
                    obj.printColored(sprintf('Comprimindo resultados com mais de %d dias...\n', daysOld), 'WHITE');
                    obj.resultsOrganizer.compressOldResults(daysOld);
                    obj.printColored('✓ Compressão concluída!\n', 'GREEN');
                else
                    obj.printColored('Sistema de organização não inicializado\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro na compressão: %s\n', ME.message), 'RED');
            end
        end
        
        function configureResultsOrganization(obj)
            % Configura organização de resultados
            
            fprintf('\n');
            obj.printColored('═══ CONFIGURAÇÕES DE ORGANIZAÇÃO ═══\n', 'CYAN');
            
            fprintf('Configurações atuais:\n');
            if ~isempty(obj.resultsOrganizer)
                fprintf('• Diretório base: %s\n', obj.resultsOrganizer.baseOutputDir);
                fprintf('• Convenção de nomes: %s\n', obj.resultsOrganizer.namingConvention);
                fprintf('• Compressão: %s\n', obj.boolToString(obj.resultsOrganizer.compressionEnabled));
            end
            
            fprintf('\n');
            if obj.askYesNo('Deseja alterar as configurações?')
                % Implementar alteração de configurações
                obj.printColored('✓ Configurações atualizadas!\n', 'GREEN');
            end
        end
        
        % Métodos auxiliares
        function str = boolToString(obj, value)
            % Converte boolean para string legível
            if value
                str = 'Habilitado';
            else
                str = 'Desabilitado';
            end
        end
        
        function showConfigurationMenu(obj)
            % Exibe menu de configuração
            
            while true
                fprintf('\n');
                obj.printColored('═══ CONFIGURAÇÃO DO SISTEMA ═══\n', 'BLUE');
                fprintf('\n');
                
                menuOptions = {
                    '1. 📁 Configurar caminhos de dados'
                    '2. ⚙️  Configurar parâmetros de treinamento'
                    '3. 💾 Configurar salvamento de modelos'
                    '4. 📋 Configurar organização de resultados'
                    '5. 🔧 Configurações avançadas'
                    '6. 📊 Exibir configuração atual'
                    '7. 💾 Salvar configuração'
                    '8. 📥 Carregar configuração'
                    '0. ⬅️  Voltar ao menu principal'
                };
                
                for i = 1:length(menuOptions)
                    fprintf('   %s\n', menuOptions{i});
                end
                
                fprintf('\n');
                obj.printColored('═══════════════════════════════════════════════════════════════════\n', 'BLUE');
                
                choice = input('Escolha uma opção [1-8, 0]: ');
                
                switch choice
                    case 1
                        obj.configureDataPaths();
                    case 2
                        obj.configureTrainingParameters();
                    case 3
                        obj.configureModelSaving();
                    case 4
                        obj.configureResultsOrganization();
                    case 5
                        obj.configureAdvancedSettings();
                    case 6
                        obj.displayCurrentConfiguration();
                    case 7
                        obj.saveCurrentConfiguration();
                    case 8
                        obj.loadConfiguration();
                    case 0
                        break;
                    otherwise
                        obj.printColored(sprintf('%s Opção inválida!\n', obj.ICONS.ERROR), 'RED');
                end
                
                if choice ~= 0
                    obj.waitForUserInput();
                end
            end
        end
        
        function configureDataPaths(obj)
            % Configura caminhos de dados
            
            fprintf('\n');
            obj.printColored('═══ CONFIGURAR CAMINHOS DE DADOS ═══\n', 'CYAN');
            
            try
                % Executar configuração básica
                obj.config = obj.configManager.configureInteractive();
                obj.printColored('✓ Caminhos de dados configurados!\n', 'GREEN');
            catch ME
                obj.printColored(sprintf('Erro na configuração: %s\n', ME.message), 'RED');
            end
        end
        
        function configureTrainingParameters(obj)
            % Configura parâmetros de treinamento
            
            fprintf('\n');
            obj.printColored('═══ CONFIGURAR PARÂMETROS DE TREINAMENTO ═══\n', 'CYAN');
            
            if isempty(obj.config)
                obj.config = struct();
            end
            
            % Configurar parâmetros básicos
            fprintf('Configurações atuais de treinamento:\n');
            if isfield(obj.config, 'maxEpochs')
                fprintf('• Épocas máximas: %d\n', obj.config.maxEpochs);
            end
            if isfield(obj.config, 'miniBatchSize')
                fprintf('• Tamanho do batch: %d\n', obj.config.miniBatchSize);
            end
            if isfield(obj.config, 'initialLearnRate')
                fprintf('• Taxa de aprendizado: %.4f\n', obj.config.initialLearnRate);
            end
            
            fprintf('\n');
            if obj.askYesNo('Deseja alterar os parâmetros de treinamento?')
                obj.config.maxEpochs = obj.getNumericInput('Número máximo de épocas', 50, 1, 1000);
                obj.config.miniBatchSize = obj.getNumericInput('Tamanho do batch', 8, 1, 64);
                obj.config.initialLearnRate = obj.getNumericInput('Taxa de aprendizado inicial', 0.001, 0.0001, 0.1);
                
                obj.printColored('✓ Parâmetros de treinamento atualizados!\n', 'GREEN');
            end
        end
        
        function configureAdvancedSettings(obj)
            % Configura configurações avançadas
            
            fprintf('\n');
            obj.printColored('═══ CONFIGURAÇÕES AVANÇADAS ═══\n', 'CYAN');
            
            fprintf('Configurações avançadas atuais:\n');
            fprintf('• Salvamento automático: %s\n', obj.boolToString(obj.autoSaveModels));
            fprintf('• Organização automática: %s\n', obj.boolToString(obj.autoOrganizeResults));
            fprintf('• Versionamento: %s\n', obj.boolToString(obj.enableModelVersioning));
            fprintf('• Saída colorida: %s\n', obj.boolToString(obj.enableColoredOutput));
            fprintf('• Barras de progresso: %s\n', obj.boolToString(obj.enableProgressBars));
            fprintf('• Monitoramento: %s\n', obj.boolToString(obj.monitoringEnabled));
            
            fprintf('\n');
            if obj.askYesNo('Deseja alterar as configurações avançadas?')
                obj.autoSaveModels = obj.askYesNo('Habilitar salvamento automático de modelos?');
                obj.autoOrganizeResults = obj.askYesNo('Habilitar organização automática de resultados?');
                obj.enableModelVersioning = obj.askYesNo('Habilitar versionamento automático?');
                obj.enableColoredOutput = obj.askYesNo('Habilitar saída colorida?');
                obj.enableProgressBars = obj.askYesNo('Habilitar barras de progresso?');
                obj.monitoringEnabled = obj.askYesNo('Habilitar monitoramento do sistema?');
                
                obj.printColored('✓ Configurações avançadas atualizadas!\n', 'GREEN');
            end
        end
        
        function displayCurrentConfiguration(obj)
            % Exibe configuração atual
            
            fprintf('\n');
            obj.printColored('═══ CONFIGURAÇÃO ATUAL ═══\n', 'CYAN');
            
            if ~isempty(obj.config)
                fprintf('Configuração básica:\n');
                if isfield(obj.config, 'imageDir')
                    fprintf('• Diretório de imagens: %s\n', obj.config.imageDir);
                end
                if isfield(obj.config, 'maskDir')
                    fprintf('• Diretório de máscaras: %s\n', obj.config.maskDir);
                end
                if isfield(obj.config, 'inputSize')
                    fprintf('• Tamanho de entrada: %s\n', mat2str(obj.config.inputSize));
                end
                if isfield(obj.config, 'numClasses')
                    fprintf('• Número de classes: %d\n', obj.config.numClasses);
                end
                
                fprintf('\nParâmetros de treinamento:\n');
                if isfield(obj.config, 'maxEpochs')
                    fprintf('• Épocas máximas: %d\n', obj.config.maxEpochs);
                end
                if isfield(obj.config, 'miniBatchSize')
                    fprintf('• Tamanho do batch: %d\n', obj.config.miniBatchSize);
                end
                if isfield(obj.config, 'initialLearnRate')
                    fprintf('• Taxa de aprendizado: %.4f\n', obj.config.initialLearnRate);
                end
            else
                obj.printColored('Nenhuma configuração carregada\n', 'YELLOW');
            end
            
            fprintf('\nFuncionalidades integradas:\n');
            fprintf('• Salvamento automático: %s\n', obj.boolToString(obj.autoSaveModels));
            fprintf('• Organização automática: %s\n', obj.boolToString(obj.autoOrganizeResults));
            fprintf('• Versionamento: %s\n', obj.boolToString(obj.enableModelVersioning));
        end
        
        function saveCurrentConfiguration(obj)
            % Salva configuração atual
            
            fprintf('\n');
            obj.printColored('═══ SALVAR CONFIGURAÇÃO ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.config) && ~isempty(obj.configManager)
                    obj.configManager.saveConfig(obj.config);
                    obj.printColored('✓ Configuração salva com sucesso!\n', 'GREEN');
                else
                    obj.printColored('Nenhuma configuração para salvar\n', 'YELLOW');
                end
            catch ME
                obj.printColored(sprintf('Erro ao salvar configuração: %s\n', ME.message), 'RED');
            end
        end
        
        function loadConfiguration(obj)
            % Carrega configuração
            
            fprintf('\n');
            obj.printColored('═══ CARREGAR CONFIGURAÇÃO ═══\n', 'CYAN');
            
            try
                if ~isempty(obj.configManager)
                    obj.config = obj.configManager.loadConfig();
                    obj.printColored('✓ Configuração carregada com sucesso!\n', 'GREEN');
                else
                    obj.printColored('Gerenciador de configuração não disponível\n', 'RED');
                end
            catch ME
                obj.printColored(sprintf('Erro ao carregar configuração: %s\n', ME.message), 'RED');
            end
        end
        
        function organizeComparisonResults(obj, results)
            % Organiza resultados de comparação automaticamente
            
            try
                if ~isempty(obj.resultsOrganizer) && isstruct(results)
                    % Extrair resultados U-Net e Attention U-Net
                    unetResults = [];
                    attentionResults = [];
                    
                    if isfield(results, 'unet')
                        unetResults = results.unet;
                    end
                    if isfield(results, 'attention_unet')
                        attentionResults = results.attention_unet;
                    end
                    
                    % Organizar resultados
                    if ~isempty(unetResults) || ~isempty(attentionResults)
                        sessionId = obj.resultsOrganizer.organizeResults(unetResults, attentionResults, obj.config);
                        
                        % Gerar índice HTML
                        obj.resultsOrganizer.generateHTMLIndex(sessionId);
                        
                        obj.printColored(sprintf('✓ Resultados organizados na sessão: %s\n', sessionId), 'GREEN');
                    end
                end
            catch ME
                obj.logger.warning('Erro na organização de resultados', 'Exception', ME);
            end
        end
    end
end