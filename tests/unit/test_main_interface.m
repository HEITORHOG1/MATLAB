function test_main_interface()
    % ========================================================================
    % TESTES UNITÁRIOS - MAIN INTERFACE
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 2.0
    %
    % DESCRIÇÃO:
    %   Testes unitários abrangentes para a classe MainInterface
    %
    % TUTORIAL MATLAB:
    %   https://www.mathworks.com/support/learn-with-matlab-tutorials.html
    %   - User Interface Development
    %   - Input Validation
    % ========================================================================
    
    fprintf('=== INICIANDO TESTES UNITÁRIOS - MAIN INTERFACE ===\n\n');
    
    % Adicionar caminho para as classes
    addpath(genpath('src'));
    
    % Executar todos os testes
    try
        test_constructor();
        test_menu_system();
        test_input_validation();
        test_help_system();
        test_progress_feedback();
        test_error_handling();
        test_configuration_interface();
        test_workflow_integration();
        test_accessibility();
        
        fprintf('\n=== TODOS OS TESTES PASSARAM! ===\n');
        
    catch ME
        fprintf('\n=== ERRO NOS TESTES ===\n');
        fprintf('Erro: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('Arquivo: %s\n', ME.stack(1).file);
            fprintf('Linha: %d\n', ME.stack(1).line);
        end
        rethrow(ME);
    end
end

function test_constructor()
    fprintf('Testando construtor...\n');
    
    % Teste construtor padrão
    interface1 = MainInterface();
    assert(isa(interface1, 'MainInterface'), 'Construtor padrão falhou');
    
    % Teste construtor com parâmetros
    interface2 = MainInterface('verbose', true, 'colorOutput', false);
    assert(isa(interface2, 'MainInterface'), 'Construtor com parâmetros falhou');
    
    % Teste construtor com configuração personalizada
    config = struct();
    config.title = 'Teste Interface';
    config.maxMenuWidth = 80;
    config.enableColors = true;
    
    interface3 = MainInterface('config', config);
    assert(isa(interface3, 'MainInterface'), 'Construtor com configuração falhou');
    
    fprintf('✓ Construtor OK\n');
end

function test_menu_system()
    fprintf('Testando sistema de menu...\n');
    
    interface = MainInterface('verbose', false);
    
    % Testar criação de menu principal
    mainMenu = interface.createMainMenu();
    assert(isstruct(mainMenu), 'Menu principal não é struct');
    assert(isfield(mainMenu, 'title'), 'Campo title não encontrado');
    assert(isfield(mainMenu, 'options'), 'Campo options não encontrado');
    assert(isfield(mainMenu, 'descriptions'), 'Campo descriptions não encontrado');
    
    assert(iscell(mainMenu.options), 'Opções devem ser cell array');
    assert(iscell(mainMenu.descriptions), 'Descrições devem ser cell array');
    assert(length(mainMenu.options) == length(mainMenu.descriptions), ...
        'Número de opções e descrições deve ser igual');
    
    % Testar renderização de menu
    menuText = interface.renderMenu(mainMenu);
    assert(ischar(menuText) || isstring(menuText), 'Menu renderizado deve ser texto');
    assert(contains(menuText, mainMenu.title), 'Menu deve conter título');
    
    % Verificar se todas as opções estão presentes
    for i = 1:length(mainMenu.options)
        assert(contains(menuText, mainMenu.options{i}), ...
            sprintf('Opção %s não encontrada no menu', mainMenu.options{i}));
    end
    
    % Testar menu de configuração
    configMenu = interface.createConfigurationMenu();
    assert(isstruct(configMenu), 'Menu de configuração não é struct');
    assert(isfield(configMenu, 'options'), 'Campo options não encontrado no menu de configuração');
    
    % Testar menu de ajuda
    helpMenu = interface.createHelpMenu();
    assert(isstruct(helpMenu), 'Menu de ajuda não é struct');
    assert(isfield(helpMenu, 'topics'), 'Campo topics não encontrado no menu de ajuda');
    
    fprintf('✓ Sistema de menu OK\n');
end

function test_input_validation()
    fprintf('Testando validação de entrada...\n');
    
    interface = MainInterface('verbose', false);
    
    % Testar validação de opção de menu
    validOptions = {'1', '2', '3', '4', '5', '0'};
    
    % Entradas válidas
    for i = 1:length(validOptions)
        isValid = interface.validateMenuInput(validOptions{i}, validOptions);
        assert(isValid, sprintf('Entrada válida %s rejeitada', validOptions{i}));
    end
    
    % Entradas inválidas
    invalidInputs = {'6', 'a', '', ' ', '1.5', '-1'};
    for i = 1:length(invalidInputs)
        isValid = interface.validateMenuInput(invalidInputs{i}, validOptions);
        assert(~isValid, sprintf('Entrada inválida %s aceita', invalidInputs{i}));
    end
    
    % Testar validação de caminho de arquivo
    validPaths = {pwd, fullfile(pwd, 'src'), '.'};
    for i = 1:length(validPaths)
        if exist(validPaths{i}, 'dir')
            isValid = interface.validatePath(validPaths{i}, 'directory');
            assert(isValid, sprintf('Caminho válido %s rejeitado', validPaths{i}));
        end
    end
    
    % Caminhos inválidos
    invalidPaths = {'/diretorio/inexistente', '', 'arquivo_inexistente.txt'};
    for i = 1:length(invalidPaths)
        isValid = interface.validatePath(invalidPaths{i}, 'directory');
        assert(~isValid, sprintf('Caminho inválido %s aceito', invalidPaths{i}));
    end
    
    % Testar validação de parâmetros numéricos
    validNumbers = {'1', '10', '0.5', '1e-3'};
    for i = 1:length(validNumbers)
        [isValid, value] = interface.validateNumericInput(validNumbers{i}, 0, Inf);
        assert(isValid, sprintf('Número válido %s rejeitado', validNumbers{i}));
        assert(isnumeric(value), 'Valor convertido deve ser numérico');
        assert(value >= 0, 'Valor deve estar no intervalo especificado');
    end
    
    % Números inválidos
    invalidNumbers = {'abc', '', '-1', '1e10'};
    for i = 1:length(invalidNumbers)
        [isValid, ~] = interface.validateNumericInput(invalidNumbers{i}, 0, 100);
        assert(~isValid, sprintf('Número inválido %s aceito', invalidNumbers{i}));
    end
    
    fprintf('✓ Validação de entrada OK\n');
end

function test_help_system()
    fprintf('Testando sistema de ajuda...\n');
    
    interface = MainInterface('verbose', false);
    
    % Testar ajuda geral
    generalHelp = interface.getGeneralHelp();
    assert(ischar(generalHelp) || isstring(generalHelp), 'Ajuda geral deve ser texto');
    assert(~isempty(generalHelp), 'Ajuda geral não pode estar vazia');
    
    % Testar ajuda contextual
    contextualHelp = interface.getContextualHelp('quick_comparison');
    assert(ischar(contextualHelp) || isstring(contextualHelp), 'Ajuda contextual deve ser texto');
    assert(~isempty(contextualHelp), 'Ajuda contextual não pode estar vazia');
    
    % Testar tópicos de ajuda disponíveis
    helpTopics = interface.getAvailableHelpTopics();
    assert(iscell(helpTopics), 'Tópicos de ajuda devem ser cell array');
    assert(~isempty(helpTopics), 'Deve haver pelo menos um tópico de ajuda');
    
    % Verificar se tópicos essenciais estão presentes
    essentialTopics = {'getting_started', 'configuration', 'troubleshooting'};
    for i = 1:length(essentialTopics)
        assert(any(contains(helpTopics, essentialTopics{i})), ...
            sprintf('Tópico essencial %s não encontrado', essentialTopics{i}));
    end
    
    % Testar busca na ajuda
    searchResults = interface.searchHelp('configuration');
    assert(iscell(searchResults), 'Resultados de busca devem ser cell array');
    
    % Testar FAQ
    faq = interface.getFAQ();
    assert(isstruct(faq), 'FAQ não é struct');
    assert(isfield(faq, 'questions'), 'Campo questions não encontrado');
    assert(isfield(faq, 'answers'), 'Campo answers não encontrado');
    assert(length(faq.questions) == length(faq.answers), ...
        'Número de perguntas e respostas deve ser igual');
    
    fprintf('✓ Sistema de ajuda OK\n');
end

function test_progress_feedback()
    fprintf('Testando feedback de progresso...\n');
    
    interface = MainInterface('verbose', false);
    
    % Testar barra de progresso
    progressBar = interface.createProgressBar('Test Task', 100);
    assert(isstruct(progressBar), 'Barra de progresso não é struct');
    assert(isfield(progressBar, 'taskName'), 'Campo taskName não encontrado');
    assert(isfield(progressBar, 'total'), 'Campo total não encontrado');
    assert(isfield(progressBar, 'current'), 'Campo current não encontrado');
    
    % Testar atualização de progresso
    for i = 10:10:100
        interface.updateProgressBar(progressBar, i);
        assert(progressBar.current == i, 'Progresso não foi atualizado corretamente');
    end
    
    % Testar estimativa de tempo
    interface.startTimeEstimation('test_task');
    pause(0.1); % Pequeno delay
    
    % Simular progresso
    for i = 1:5
        interface.updateTimeEstimation('test_task', i, 10);
        estimate = interface.getTimeEstimate('test_task');
        
        if i > 1 % Após algumas atualizações
            assert(isstruct(estimate), 'Estimativa deve ser struct');
            assert(isfield(estimate, 'remaining'), 'Campo remaining não encontrado');
            assert(isfield(estimate, 'eta'), 'Campo eta não encontrado');
        end
    end
    
    interface.finishTimeEstimation('test_task');
    
    % Testar mensagens de status
    interface.showStatusMessage('Processando dados...', 'info');
    interface.showStatusMessage('Aviso: Configuração não encontrada', 'warning');
    interface.showStatusMessage('Erro: Falha na validação', 'error');
    interface.showStatusMessage('Sucesso: Operação concluída', 'success');
    
    % Testar spinner de carregamento
    spinner = interface.createSpinner('Carregando...');
    assert(isstruct(spinner), 'Spinner não é struct');
    assert(isfield(spinner, 'message'), 'Campo message não encontrado');
    assert(isfield(spinner, 'active'), 'Campo active não encontrado');
    
    interface.startSpinner(spinner);
    pause(0.1);
    interface.stopSpinner(spinner);
    
    fprintf('✓ Feedback de progresso OK\n');
end

function test_error_handling()
    fprintf('Testando tratamento de erros...\n');
    
    interface = MainInterface('verbose', false);
    
    % Testar exibição de erro
    testError = MException('TestError:Generic', 'Erro de teste');
    interface.displayError(testError);
    
    % Testar erro com stack trace
    try
        error('Erro simulado com stack');
    catch ME
        interface.displayError(ME, 'showStack', true);
    end
    
    % Testar diferentes tipos de erro
    errorTypes = {'validation', 'configuration', 'data', 'model', 'system'};
    for i = 1:length(errorTypes)
        testMsg = sprintf('Erro de %s', errorTypes{i});
        interface.displayErrorMessage(testMsg, errorTypes{i});
    end
    
    % Testar recuperação de erro
    recoveryOptions = interface.getErrorRecoveryOptions('data_not_found');
    assert(iscell(recoveryOptions), 'Opções de recuperação devem ser cell array');
    assert(~isempty(recoveryOptions), 'Deve haver pelo menos uma opção de recuperação');
    
    % Testar log de erros
    interface.logError('Test error message', 'test_component');
    errorLog = interface.getErrorLog();
    assert(iscell(errorLog), 'Log de erros deve ser cell array');
    assert(~isempty(errorLog), 'Log deve conter pelo menos um erro');
    
    % Testar limpeza do log
    interface.clearErrorLog();
    clearedLog = interface.getErrorLog();
    assert(isempty(clearedLog), 'Log não foi limpo corretamente');
    
    % Testar modo de debug
    interface.enableDebugMode();
    debugStatus = interface.getDebugStatus();
    assert(debugStatus, 'Modo debug não foi habilitado');
    
    interface.disableDebugMode();
    debugStatus = interface.getDebugStatus();
    assert(~debugStatus, 'Modo debug não foi desabilitado');
    
    fprintf('✓ Tratamento de erros OK\n');
end

function test_configuration_interface()
    fprintf('Testando interface de configuração...\n');
    
    interface = MainInterface('verbose', false);
    
    % Testar wizard de configuração
    configWizard = interface.createConfigurationWizard();
    assert(isstruct(configWizard), 'Wizard de configuração não é struct');
    assert(isfield(configWizard, 'steps'), 'Campo steps não encontrado');
    assert(isfield(configWizard, 'currentStep'), 'Campo currentStep não encontrado');
    
    % Testar passos do wizard
    steps = configWizard.steps;
    assert(iscell(steps), 'Passos devem ser cell array');
    assert(~isempty(steps), 'Deve haver pelo menos um passo');
    
    % Verificar passos essenciais
    essentialSteps = {'data_paths', 'model_parameters', 'training_options'};
    stepNames = cellfun(@(x) x.name, steps, 'UniformOutput', false);
    for i = 1:length(essentialSteps)
        assert(any(contains(stepNames, essentialSteps{i})), ...
            sprintf('Passo essencial %s não encontrado', essentialSteps{i}));
    end
    
    % Testar validação de configuração interativa
    testConfig = struct();
    testConfig.paths = struct('imageDir', pwd, 'maskDir', pwd);
    testConfig.model = struct('inputSize', [256, 256, 3], 'numClasses', 2);
    
    validationResult = interface.validateConfigurationInteractive(testConfig);
    assert(isstruct(validationResult), 'Resultado de validação não é struct');
    assert(isfield(validationResult, 'isValid'), 'Campo isValid não encontrado');
    assert(isfield(validationResult, 'issues'), 'Campo issues não encontrado');
    
    % Testar detecção automática de configuração
    autoConfig = interface.autoDetectConfiguration();
    assert(isstruct(autoConfig), 'Configuração automática não é struct');
    assert(isfield(autoConfig, 'detected'), 'Campo detected não encontrado');
    assert(isfield(autoConfig, 'confidence'), 'Campo confidence não encontrado');
    
    % Testar salvamento e carregamento de configuração
    testConfigFile = 'test_interface_config.mat';
    success = interface.saveConfiguration(testConfig, testConfigFile);
    assert(success, 'Falha ao salvar configuração');
    assert(exist(testConfigFile, 'file') == 2, 'Arquivo de configuração não foi criado');
    
    loadedConfig = interface.loadConfiguration(testConfigFile);
    assert(isstruct(loadedConfig), 'Configuração carregada não é struct');
    assert(isequal(loadedConfig.model.inputSize, [256, 256, 3]), ...
        'Configuração não foi carregada corretamente');
    
    % Limpar arquivo de teste
    delete(testConfigFile);
    
    fprintf('✓ Interface de configuração OK\n');
end

function test_workflow_integration()
    fprintf('Testando integração com workflow...\n');
    
    interface = MainInterface('verbose', false);
    
    % Testar inicialização de workflow
    workflow = interface.initializeWorkflow();
    assert(isstruct(workflow), 'Workflow não é struct');
    assert(isfield(workflow, 'steps'), 'Campo steps não encontrado');
    assert(isfield(workflow, 'currentStep'), 'Campo currentStep não encontrado');
    
    % Testar exibição de status do workflow
    statusDisplay = interface.displayWorkflowStatus(workflow);
    assert(ischar(statusDisplay) || isstring(statusDisplay), ...
        'Exibição de status deve ser texto');
    
    % Testar navegação no workflow
    canAdvance = interface.canAdvanceWorkflow(workflow);
    assert(islogical(canAdvance), 'Resultado deve ser lógico');
    
    if canAdvance
        newWorkflow = interface.advanceWorkflow(workflow);
        assert(isstruct(newWorkflow), 'Workflow avançado não é struct');
        assert(newWorkflow.currentStep > workflow.currentStep, ...
            'Passo atual não avançou');
    end
    
    % Testar pausa e retomada do workflow
    pausedWorkflow = interface.pauseWorkflow(workflow);
    assert(isfield(pausedWorkflow, 'paused'), 'Campo paused não encontrado');
    assert(pausedWorkflow.paused, 'Workflow não foi pausado');
    
    resumedWorkflow = interface.resumeWorkflow(pausedWorkflow);
    assert(~resumedWorkflow.paused, 'Workflow não foi retomado');
    
    % Testar cancelamento do workflow
    cancelledWorkflow = interface.cancelWorkflow(workflow);
    assert(isfield(cancelledWorkflow, 'cancelled'), 'Campo cancelled não encontrado');
    assert(cancelledWorkflow.cancelled, 'Workflow não foi cancelado');
    
    fprintf('✓ Integração com workflow OK\n');
end

function test_accessibility()
    fprintf('Testando recursos de acessibilidade...\n');
    
    interface = MainInterface('verbose', false);
    
    % Testar modo de alto contraste
    interface.enableHighContrastMode();
    contrastStatus = interface.getHighContrastStatus();
    assert(contrastStatus, 'Modo de alto contraste não foi habilitado');
    
    interface.disableHighContrastMode();
    contrastStatus = interface.getHighContrastStatus();
    assert(~contrastStatus, 'Modo de alto contraste não foi desabilitado');
    
    % Testar ajuste de tamanho de fonte
    originalSize = interface.getFontSize();
    assert(isnumeric(originalSize), 'Tamanho de fonte deve ser numérico');
    
    interface.increaseFontSize();
    newSize = interface.getFontSize();
    assert(newSize > originalSize, 'Tamanho de fonte não aumentou');
    
    interface.decreaseFontSize();
    resetSize = interface.getFontSize();
    assert(resetSize == originalSize, 'Tamanho de fonte não foi restaurado');
    
    % Testar modo de leitura de tela
    interface.enableScreenReaderMode();
    screenReaderStatus = interface.getScreenReaderStatus();
    assert(screenReaderStatus, 'Modo de leitura de tela não foi habilitado');
    
    % Testar descrições alternativas
    altText = interface.getAlternativeText('progress_bar');
    assert(ischar(altText) || isstring(altText), 'Texto alternativo deve ser string');
    assert(~isempty(altText), 'Texto alternativo não pode estar vazio');
    
    % Testar navegação por teclado
    keyboardNav = interface.getKeyboardNavigationHelp();
    assert(isstruct(keyboardNav), 'Ajuda de navegação não é struct');
    assert(isfield(keyboardNav, 'shortcuts'), 'Campo shortcuts não encontrado');
    assert(isfield(keyboardNav, 'descriptions'), 'Campo descriptions não encontrado');
    
    % Testar atalhos de teclado
    shortcuts = interface.getAvailableShortcuts();
    assert(isstruct(shortcuts), 'Atalhos não são struct');
    
    % Verificar atalhos essenciais
    essentialShortcuts = {'help', 'quit', 'back', 'next'};
    shortcutNames = fieldnames(shortcuts);
    for i = 1:length(essentialShortcuts)
        assert(any(contains(shortcutNames, essentialShortcuts{i})), ...
            sprintf('Atalho essencial %s não encontrado', essentialShortcuts{i}));
    end
    
    interface.disableScreenReaderMode();
    
    fprintf('✓ Recursos de acessibilidade OK\n');
end