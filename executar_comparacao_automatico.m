function executar_comparacao_automatico(opcao)
    % Versão automatizada do executar_comparacao para execução em batch
    % 
    % Input:
    %   opcao - (opcional) opção a executar (1-7), default: 5 (todos os passos)
    
    if nargin < 1
        opcao = 5; % Executar todos os passos por padrão
    end
    
    fprintf('\n=====================================\n');
    fprintf('   COMPARACAO U-NET vs ATTENTION U-NET\n');
    fprintf('      Script de Execucao Automatico\n');
    fprintf('      (Versão 1.2 - Batch Mode)\n');
    fprintf('=====================================\n\n');
    
    % Carregar configuração automaticamente
    try
        config = carregar_configuracao_automatica();
        fprintf('✅ Configuração carregada automaticamente.\n');
        fprintf('  Imagens: %s\n', config.imagePath);
        fprintf('  Máscaras: %s\n', config.maskPath);
        fprintf('  Configuração válida e será usada.\n\n');
    catch ME
        fprintf('❌ Erro ao carregar configuração: %s\n', ME.message);
        fprintf('Criando configuração padrão...\n');
        config = criar_configuracao_padrao();
    end
    
    fprintf('Executando opção %d automaticamente...\n\n', opcao);
    
    try
        switch opcao
            case 1
                fprintf('\n=== TESTANDO FORMATO DOS DADOS ===\n');
                executar_seguro(@() teste_dados_segmentacao(config), 'Teste dos dados');
                
            case 2
                fprintf('\n=== CONVERTENDO MASCARAS ===\n');
                executar_seguro(@() converter_mascaras_segmentacao(config), 'Conversão de máscaras');
                
            case 3
                fprintf('\n=== TESTE RAPIDO COM U-NET SIMPLES ===\n');
                executar_seguro(@() teste_unet_rapido(config), 'Teste rápido U-Net');
                
            case 4
                fprintf('\n=== COMPARACAO COMPLETA U-NET vs ATTENTION U-NET ===\n');
                executar_seguro(@() comparacao_unet_attention_final(config), 'Comparação completa');
                
            case 5
                fprintf('\n=== EXECUTANDO TODOS OS PASSOS EM SEQUENCIA ===\n');
                executar_todos_passos_automatico(config);
                
            case 6
                fprintf('\n=== COMPARACAO COM VALIDACAO CRUZADA ===\n');
                executar_seguro(@() comparacao_validacao_cruzada(config), 'Validação cruzada');
                
            case 7
                fprintf('\n=== TESTE: VERIFICAR ATTENTION U-NET ===\n');
                executar_seguro(@() testar_attention_unet(config), 'Teste Attention U-Net');
                
            otherwise
                fprintf('❌ Opção inválida: %d\n', opcao);
                fprintf('Opções válidas: 1-7\n');
                return;
        end
        
        fprintf('\n✅ Execução automatizada concluída com sucesso!\n');
        
    catch ME
        fprintf('\n❌ Erro durante execução automatizada:\n');
        fprintf('  Erro: %s\n', ME.message);
        fprintf('  Identificador: %s\n', ME.identifier);
        if ~isempty(ME.stack)
            fprintf('  Local: %s (linha %d)\n', ME.stack(1).name, ME.stack(1).line);
        end
    end
end

function config = carregar_configuracao_automatica()
    % Carrega configuração automaticamente sem interação do usuário
    
    % Tentar carregar configuração existente
    if exist('config_comparacao.mat', 'file')
        load('config_comparacao.mat', 'config');
        return;
    end
    
    % Criar configuração padrão
    config = criar_configuracao_padrao();
    
    % Salvar para uso futuro
    save('config_comparacao.mat', 'config');
end

function config = criar_configuracao_padrao()
    % Cria configuração padrão para execução automatizada
    
    config = struct();
    
    % Configurações de treinamento
    config.maxEpochs = 10; % Reduzido para execução mais rápida
    config.miniBatchSize = 4;
    config.learningRate = 0.001;
    config.validationFrequency = 5;
    
    % Configurações de dados
    config.inputSize = [256, 256, 3];
    config.numClasses = 2;
    
    % Paths padrão (ajustar conforme necessário)
    config.imagePath = fullfile(pwd, 'data', 'images');
    config.maskPath = fullfile(pwd, 'data', 'masks');
    
    % Criar diretórios se não existirem
    if ~exist(config.imagePath, 'dir')
        mkdir(config.imagePath);
        fprintf('📁 Diretório criado: %s\n', config.imagePath);
    end
    
    if ~exist(config.maskPath, 'dir')
        mkdir(config.maskPath);
        fprintf('📁 Diretório criado: %s\n', config.maskPath);
    end
    
    % Configurações de saída
    config.outputPath = fullfile(pwd, 'results');
    if ~exist(config.outputPath, 'dir')
        mkdir(config.outputPath);
    end
    
    % Configurações específicas para modo automatizado
    config.batchMode = true;
    config.verbose = true;
    config.saveResults = true;
    
    fprintf('⚙️ Configuração padrão criada\n');
end

function executar_todos_passos_automatico(config)
    % Executa todos os passos em sequência automaticamente
    
    passos = {
        {1, 'Teste dos dados', @() teste_dados_segmentacao(config)},
        {2, 'Conversão de máscaras', @() converter_mascaras_segmentacao(config)},
        {3, 'Teste rápido U-Net', @() teste_unet_rapido(config)},
        {4, 'Comparação completa', @() comparacao_unet_attention_final(config)}
    };
    
    fprintf('Executando %d passos em sequência...\n\n', length(passos));
    
    for i = 1:length(passos)
        passo = passos{i};
        num = passo{1};
        nome = passo{2};
        funcao = passo{3};
        
        fprintf('--- PASSO %d: %s ---\n', num, nome);
        
        try
            executar_seguro(funcao, nome);
            fprintf('✅ Passo %d concluído com sucesso\n\n', num);
        catch ME
            fprintf('❌ Passo %d falhou: %s\n', num, ME.message);
            fprintf('Continuando para próximo passo...\n\n');
        end
    end
    
    fprintf('🎉 Todos os passos foram executados!\n');
end

function executar_seguro(funcao, nome_operacao)
    % Executa função com tratamento de erro seguro
    
    try
        fprintf('🔄 Iniciando: %s\n', nome_operacao);
        funcao();
        fprintf('✅ Concluído: %s\n', nome_operacao);
        
    catch ME
        fprintf('❌ Erro em %s:\n', nome_operacao);
        fprintf('  Mensagem: %s\n', ME.message);
        fprintf('  Identificador: %s\n', ME.identifier);
        
        if ~isempty(ME.stack)
            fprintf('  Stack trace:\n');
            for i = 1:min(3, length(ME.stack)) % Mostrar apenas os 3 primeiros
                fprintf('    %s (linha %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
        end
        
        % Re-throw para permitir tratamento upstream se necessário
        rethrow(ME);
    end
end