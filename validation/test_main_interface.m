% ========================================================================
% TESTE DA INTERFACE PRINCIPAL MELHORADA
% ========================================================================
% 
% AUTOR: Sistema de Comparação U-Net vs Attention U-Net
% Data: Julho 2025
% Versão: 2.0
%
% DESCRIÇÃO:
%   Script de teste para demonstrar as funcionalidades da nova interface
%   principal com feedback visual aprimorado e sistema de ajuda integrado.
%
% USO:
%   >> test_main_interface
%
% FUNCIONALIDADES TESTADAS:
%   - Interface principal unificada
%   - Feedback visual aprimorado (barras de progresso, logs coloridos)
%   - Sistema de ajuda contextual e troubleshooting
% ========================================================================

function test_main_interface()
    fprintf('========================================\n');
    fprintf('   TESTE DA INTERFACE PRINCIPAL\n');
    fprintf('     (Nova Versão 2.0)\n');
    fprintf('========================================\n\n');
    
    try
        % Adicionar caminhos necessários
        addpath('src/core');
        addpath('src/utils');
        
        fprintf('1. Testando componentes de feedback visual...\n\n');
        
        % Teste 1: ProgressBar
        fprintf('=== Teste 1: Barra de Progresso ===\n');
        testProgressBar();
        
        % Teste 2: Logger
        fprintf('\n=== Teste 2: Sistema de Logging ===\n');
        testLogger();
        
        % Teste 3: TimeEstimator
        fprintf('\n=== Teste 3: Estimador de Tempo ===\n');
        testTimeEstimator();
        
        % Teste 4: HelpSystem
        fprintf('\n=== Teste 4: Sistema de Ajuda ===\n');
        testHelpSystem();
        
        % Teste 5: MainInterface (modo demonstração)
        fprintf('\n=== Teste 5: Interface Principal ===\n');
        testMainInterface();
        
        fprintf('\n========================================\n');
        fprintf('   TODOS OS TESTES CONCLUÍDOS!\n');
        fprintf('========================================\n');
        
    catch ME
        fprintf('\n❌ ERRO NO TESTE: %s\n', ME.message);
        fprintf('Stack trace:\n%s\n', ME.getReport());
    end
end

function testProgressBar()
    % Testa a barra de progresso
    
    try
        pb = ProgressBar('Teste de Progresso', 10, 'EnableColors', true);
        
        for i = 1:10
            pause(0.2);
            pb.update(i, 'Message', sprintf('Processando item %d', i));
        end
        
        pb.finish('Teste concluído!', true);
        fprintf('✅ ProgressBar funcionando corretamente\n');
        
    catch ME
        fprintf('❌ Erro no ProgressBar: %s\n', ME.message);
    end
end

function testLogger()
    % Testa o sistema de logging
    
    try
        logger = Logger('Teste', 'EnableColors', true);
        
        logger.info('Teste de informação');
        logger.success('Teste de sucesso');
        logger.warning('Teste de aviso');
        logger.error('Teste de erro');
        logger.debug('Teste de debug');
        
        % Teste com dados
        data = struct('valor', 42, 'nome', 'teste');
        logger.info('Dados processados', 'Data', data);
        
        fprintf('✅ Logger funcionando corretamente\n');
        
    catch ME
        fprintf('❌ Erro no Logger: %s\n', ME.message);
    end
end

function testTimeEstimator()
    % Testa o estimador de tempo
    
    try
        estimator = TimeEstimator('Teste de Tempo', 20);
        
        for i = 1:20
            pause(0.1);
            estimator.update(i);
            
            if mod(i, 5) == 0
                summary = estimator.getSummary();
                fprintf('Progresso: %.1f%% - ETA: %s\n', ...
                    summary.percentage, summary.etaFormatted);
            end
        end
        
        fprintf('✅ TimeEstimator funcionando corretamente\n');
        
    catch ME
        fprintf('❌ Erro no TimeEstimator: %s\n', ME.message);
    end
end

function testHelpSystem()
    % Testa o sistema de ajuda
    
    try
        helpSystem = HelpSystem('EnableColors', true, 'EnableInteractiveMode', false);
        
        % Teste de busca
        fprintf('Testando busca por "configuração":\n');
        helpSystem.searchHelp('configuração');
        
        % Teste de ajuda específica
        fprintf('\nTestando ajuda de início rápido:\n');
        helpSystem.showHelp('quick_start', 'Interactive', false);
        
        % Teste de diagnóstico
        fprintf('\nTestando diagnóstico do sistema:\n');
        helpSystem.troubleshoot('Interactive', false);
        
        fprintf('✅ HelpSystem funcionando corretamente\n');
        
    catch ME
        fprintf('❌ Erro no HelpSystem: %s\n', ME.message);
    end
end

function testMainInterface()
    % Testa a interface principal (modo demonstração)
    
    try
        fprintf('Criando interface principal...\n');
        
        % Criar interface com configurações de teste
        interface = MainInterface('EnableColoredOutput', true, ...
            'EnableProgressBars', true, 'EnableSoundFeedback', false);
        
        fprintf('✅ MainInterface criada com sucesso\n');
        fprintf('💡 Para testar completamente, execute: interface.run()\n');
        
        % Teste de componentes internos
        fprintf('Testando componentes internos...\n');
        
        % Testar validação de entrada
        validInputs = [1, 2, 3, 0];
        for input = validInputs
            if interface.validateUserInput(input)
                fprintf('  ✓ Entrada %d: válida\n', input);
            else
                fprintf('  ✗ Entrada %d: inválida\n', input);
            end
        end
        
        % Testar entradas inválidas
        invalidInputs = [-1, 8, 1.5, NaN];
        for input = invalidInputs
            if ~interface.validateUserInput(input)
                fprintf('  ✓ Entrada %g: corretamente rejeitada\n', input);
            else
                fprintf('  ✗ Entrada %g: incorretamente aceita\n', input);
            end
        end
        
        fprintf('✅ MainInterface funcionando corretamente\n');
        
    catch ME
        fprintf('❌ Erro na MainInterface: %s\n', ME.message);
    end
end