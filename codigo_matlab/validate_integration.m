function success = validate_integration()
    % ========================================================================
    % VALIDATE_INTEGRATION - Validação da Integração das Novas Funcionalidades
    % ========================================================================
    % 
    % DESCRIÇÃO:
    %   Script para validar se a integração das novas funcionalidades
    %   foi implementada corretamente
    %
    % RETORNA:
    %   success - true se todas as validações passaram
    % ========================================================================
    
    fprintf('\n🔍 VALIDANDO INTEGRAÇÃO DAS NOVAS FUNCIONALIDADES\n');
    fprintf('==================================================\n\n');
    
    success = true;
    totalTests = 0;
    passedTests = 0;
    
    try
        % Teste 1: Verificar se os novos componentes existem
        fprintf('1. Verificando existência dos novos componentes...\n');
        [passed, total] = testComponentExistence();
        passedTests = passedTests + passed;
        totalTests = totalTests + total;
        
        % Teste 2: Verificar se a MainInterface foi atualizada
        fprintf('\n2. Verificando atualização da MainInterface...\n');
        [passed, total] = testMainInterfaceUpdates();
        passedTests = passedTests + passed;
        totalTests = totalTests + total;
        
        % Teste 3: Verificar se os novos menus estão funcionais
        fprintf('\n3. Verificando funcionalidade dos novos menus...\n');
        [passed, total] = testMenuFunctionality();
        passedTests = passedTests + passed;
        totalTests = totalTests + total;
        
        % Teste 4: Verificar integração com sistema existente
        fprintf('\n4. Verificando integração com sistema existente...\n');
        [passed, total] = testExistingSystemIntegration();
        passedTests = passedTests + passed;
        totalTests = totalTests + total;
        
        % Teste 5: Verificar configurações
        fprintf('\n5. Verificando sistema de configuração...\n');
        [passed, total] = testConfigurationSystem();
        passedTests = passedTests + passed;
        totalTests = totalTests + total;
        
        % Resultado final
        fprintf('\n==================================================\n');
        fprintf('RESULTADO DA VALIDAÇÃO:\n');
        fprintf('Testes executados: %d\n', totalTests);
        fprintf('Testes aprovados: %d\n', passedTests);
        fprintf('Taxa de sucesso: %.1f%%\n', (passedTests/totalTests)*100);
        
        if passedTests == totalTests
            fprintf('✅ INTEGRAÇÃO VALIDADA COM SUCESSO!\n');
            success = true;
        else
            fprintf('⚠️  ALGUNS TESTES FALHARAM - VERIFICAR IMPLEMENTAÇÃO\n');
            success = false;
        end
        
    catch ME
        fprintf('❌ ERRO DURANTE VALIDAÇÃO: %s\n', ME.message);
        success = false;
    end
    
    fprintf('==================================================\n\n');
end

function [passed, total] = testComponentExistence()
    % Testa se os novos componentes existem
    
    passed = 0;
    total = 0;
    
    components = {
        'src/model_management/ModelSaver.m'
        'src/model_management/ModelLoader.m'
        'src/model_management/ModelManagerCLI.m'
        'src/model_management/TrainingIntegration.m'
        'src/organization/ResultsOrganizer.m'
    };
    
    for i = 1:length(components)
        total = total + 1;
        component = components{i};
        
        if exist(component, 'file')
            fprintf('   ✓ %s existe\n', component);
            passed = passed + 1;
        else
            fprintf('   ❌ %s NÃO ENCONTRADO\n', component);
        end
    end
end

function [passed, total] = testMainInterfaceUpdates()
    % Testa se a MainInterface foi atualizada corretamente
    
    passed = 0;
    total = 0;
    
    interfaceFile = 'src/core/MainInterface.m';
    
    if ~exist(interfaceFile, 'file')
        fprintf('   ❌ MainInterface.m não encontrado\n');
        return;
    end
    
    % Ler conteúdo do arquivo
    content = fileread(interfaceFile);
    
    % Verificar se as novas opções de menu foram adicionadas
    tests = {
        'MODEL_MANAGEMENT', 'Opção de gerenciamento de modelos'
        'RESULTS_ANALYSIS', 'Opção de análise de resultados'
        'executeModelManagement', 'Método de gerenciamento de modelos'
        'executeResultsAnalysis', 'Método de análise de resultados'
        'modelSaver', 'Propriedade modelSaver'
        'resultsOrganizer', 'Propriedade resultsOrganizer'
        'initializeNewComponents', 'Método de inicialização dos novos componentes'
    };
    
    for i = 1:size(tests, 1)
        total = total + 1;
        searchTerm = tests{i, 1};
        description = tests{i, 2};
        
        if contains(content, searchTerm)
            fprintf('   ✓ %s encontrado\n', description);
            passed = passed + 1;
        else
            fprintf('   ❌ %s NÃO ENCONTRADO\n', description);
        end
    end
end

function [passed, total] = testMenuFunctionality()
    % Testa se os novos menus podem ser instanciados
    
    passed = 0;
    total = 0;
    
    try
        % Testar criação da MainInterface
        total = total + 1;
        interface = MainInterface('EnableColoredOutput', false, ...
                                'EnableProgressBars', false, ...
                                'EnableSoundFeedback', false);
        
        if ~isempty(interface)
            fprintf('   ✓ MainInterface pode ser instanciada\n');
            passed = passed + 1;
        else
            fprintf('   ❌ Erro ao instanciar MainInterface\n');
        end
        
        % Testar se as novas propriedades existem
        properties = {'modelSaver', 'resultsOrganizer', 'trainingIntegration'};
        
        for i = 1:length(properties)
            total = total + 1;
            prop = properties{i};
            
            if isprop(interface, prop)
                fprintf('   ✓ Propriedade %s existe\n', prop);
                passed = passed + 1;
            else
                fprintf('   ❌ Propriedade %s NÃO EXISTE\n', prop);
            end
        end
        
    catch ME
        fprintf('   ❌ Erro ao testar funcionalidade dos menus: %s\n', ME.message);
    end
end

function [passed, total] = testExistingSystemIntegration()
    % Testa se a integração não quebrou o sistema existente
    
    passed = 0;
    total = 0;
    
    % Verificar se arquivos principais ainda existem
    existingFiles = {
        'executar_comparacao.m'
        'main_sistema_comparacao.m'
        'src/core/ConfigManager.m'
        'src/core/ComparisonController.m'
    };
    
    for i = 1:length(existingFiles)
        total = total + 1;
        file = existingFiles{i};
        
        if exist(file, 'file')
            fprintf('   ✓ %s ainda existe\n', file);
            passed = passed + 1;
        else
            fprintf('   ❌ %s FOI REMOVIDO\n', file);
        end
    end
    
    % Verificar se executar_comparacao ainda funciona
    total = total + 1;
    try
        % Verificar se a função pode ser chamada (sem executar)
        if exist('executar_comparacao', 'file')
            fprintf('   ✓ executar_comparacao ainda é acessível\n');
            passed = passed + 1;
        else
            fprintf('   ❌ executar_comparacao NÃO É ACESSÍVEL\n');
        end
    catch ME
        fprintf('   ❌ Erro ao verificar executar_comparacao: %s\n', ME.message);
    end
end

function [passed, total] = testConfigurationSystem()
    % Testa se o sistema de configuração está funcionando
    
    passed = 0;
    total = 0;
    
    try
        % Testar criação de componentes de configuração
        total = total + 1;
        config = struct();
        config.saveDirectory = 'test_models';
        config.autoSaveEnabled = true;
        
        modelSaver = ModelSaver(config);
        
        if ~isempty(modelSaver)
            fprintf('   ✓ ModelSaver pode ser configurado\n');
            passed = passed + 1;
        else
            fprintf('   ❌ Erro ao configurar ModelSaver\n');
        end
        
        % Testar ResultsOrganizer
        total = total + 1;
        organizerConfig = struct();
        organizerConfig.baseOutputDir = 'test_output';
        
        resultsOrganizer = ResultsOrganizer(organizerConfig);
        
        if ~isempty(resultsOrganizer)
            fprintf('   ✓ ResultsOrganizer pode ser configurado\n');
            passed = passed + 1;
        else
            fprintf('   ❌ Erro ao configurar ResultsOrganizer\n');
        end
        
        % Testar TrainingIntegration
        total = total + 1;
        trainingIntegration = TrainingIntegration(config);
        
        if ~isempty(trainingIntegration)
            fprintf('   ✓ TrainingIntegration pode ser configurado\n');
            passed = passed + 1;
        else
            fprintf('   ❌ Erro ao configurar TrainingIntegration\n');
        end
        
    catch ME
        fprintf('   ❌ Erro ao testar sistema de configuração: %s\n', ME.message);
    end
end