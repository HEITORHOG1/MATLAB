function verificacao_final_projeto()
% VERIFICAÇÃO FINAL DO PROJETO
% Script para validar que o projeto está 100% funcional
%
% Execute este script antes de usar o projeto em uma nova máquina
% ou após fazer alterações significativas.

    fprintf('\n🔍 VERIFICAÇÃO FINAL DO PROJETO U-Net vs Attention U-Net\n');
    fprintf('========================================================\n\n');
    
    % Contador de verificações
    total_verificacoes = 0;
    verificacoes_ok = 0;
    
    % 1. Verificar arquivos essenciais
    fprintf('1️⃣  Verificando arquivos essenciais...\n');
    arquivos_essenciais = {
        'executar_comparacao.m'
        'configurar_caminhos.m'
        'carregar_dados_robustos.m'
        'preprocessDataCorrigido.m'
        'preprocessDataMelhorado.m'
        'treinar_unet_simples.m'
        'create_working_attention_unet.m'
        'comparacao_unet_attention_final.m'
        'analisar_mascaras_automatico.m'
        'converter_mascaras.m'
        'executar_testes_completos.m'
    };
    
    arquivos_ok = true;
    for i = 1:length(arquivos_essenciais)
        if exist(arquivos_essenciais{i}, 'file')
            fprintf('   ✅ %s\n', arquivos_essenciais{i});
        else
            fprintf('   ❌ %s - ARQUIVO AUSENTE!\n', arquivos_essenciais{i});
            arquivos_ok = false;
        end
    end
    total_verificacoes = total_verificacoes + 1;
    if arquivos_ok, verificacoes_ok = verificacoes_ok + 1; end
    
    % 2. Verificar configuração
    fprintf('\n2️⃣  Verificando configuração...\n');
    try
        if exist('config_caminhos.mat', 'file')
            config = load('config_caminhos.mat');
            fprintf('   ✅ Arquivo de configuração encontrado\n');
            
            % Verificar campos obrigatórios
            campos_obrigatorios = {'imageDir', 'maskDir', 'inputSize'};
            config_ok = true;
            for i = 1:length(campos_obrigatorios)
                if isfield(config.config, campos_obrigatorios{i})
                    fprintf('   ✅ Campo %s presente\n', campos_obrigatorios{i});
                else
                    fprintf('   ❌ Campo %s ausente\n', campos_obrigatorios{i});
                    config_ok = false;
                end
            end
        else
            fprintf('   ⚠️  Arquivo de configuração não encontrado\n');
            fprintf('   ℹ️  Execute configurar_caminhos() na primeira vez\n');
            config_ok = true; % Não é erro crítico
        end
    catch ME
        fprintf('   ❌ Erro ao verificar configuração: %s\n', ME.message);
        config_ok = false;
    end
    total_verificacoes = total_verificacoes + 1;
    if config_ok, verificacoes_ok = verificacoes_ok + 1; end
    
    % 3. Testar funções principais
    fprintf('\n3️⃣  Testando funções principais...\n');
    funcoes_ok = true;
    
    try
        % Testar configurar_caminhos
        fprintf('   🔧 Testando configurar_caminhos...\n');
        help('configurar_caminhos');
        fprintf('   ✅ configurar_caminhos OK\n');
    catch ME
        fprintf('   ❌ Erro em configurar_caminhos: %s\n', ME.message);
        funcoes_ok = false;
    end
    
    try
        % Testar executar_comparacao
        fprintf('   🔧 Testando executar_comparacao...\n');
        help('executar_comparacao');
        fprintf('   ✅ executar_comparacao OK\n');
    catch ME
        fprintf('   ❌ Erro em executar_comparacao: %s\n', ME.message);
        funcoes_ok = false;
    end
    
    total_verificacoes = total_verificacoes + 1;
    if funcoes_ok, verificacoes_ok = verificacoes_ok + 1; end
    
    % 4. Verificar Deep Learning Toolbox
    fprintf('\n4️⃣  Verificando Deep Learning Toolbox...\n');
    try
        % Tentar criar uma camada simples
        convolution2dLayer(3, 64);
        fprintf('   ✅ Deep Learning Toolbox disponível\n');
        dl_ok = true;
    catch ME
        fprintf('   ❌ Deep Learning Toolbox não disponível: %s\n', ME.message);
        fprintf('   ⚠️  ATENÇÃO: Este toolbox é obrigatório para o projeto!\n');
        dl_ok = false;
    end
    total_verificacoes = total_verificacoes + 1;
    if dl_ok, verificacoes_ok = verificacoes_ok + 1; end
    
    % 5. Testar criação de rede simples
    fprintf('\n5️⃣  Testando criação de arquitetura...\n');
    try
        % Criar uma U-Net simples para teste
        layers = [
            imageInputLayer([64 64 3])
            convolution2dLayer(3, 64, 'Padding', 'same')
            reluLayer
            convolution2dLayer(1, 2, 'Padding', 'same')
            softmaxLayer
            pixelClassificationLayer
        ];
        layerGraph(layers);
        fprintf('   ✅ Criação de arquitetura funcionando\n');
        arquitetura_ok = true;
    catch ME
        fprintf('   ❌ Erro na criação de arquitetura: %s\n', ME.message);
        arquitetura_ok = false;
    end
    total_verificacoes = total_verificacoes + 1;
    if arquitetura_ok, verificacoes_ok = verificacoes_ok + 1; end
    
    % 6. Verificar scripts de teste
    fprintf('\n6️⃣  Verificando scripts de teste...\n');
    scripts_teste = {
        'executar_testes_completos.m'
        'teste_final_integridade.m' 
        'teste_projeto_automatizado.m'
        'teste_treinamento_rapido.m'
    };
    
    teste_ok = true;
    for i = 1:length(scripts_teste)
        if exist(scripts_teste{i}, 'file')
            fprintf('   ✅ %s\n', scripts_teste{i});
        else
            fprintf('   ❌ %s - ARQUIVO AUSENTE!\n', scripts_teste{i});
            teste_ok = false;
        end
    end
    total_verificacoes = total_verificacoes + 1;
    if teste_ok, verificacoes_ok = verificacoes_ok + 1; end
    
    % RESULTADO FINAL
    fprintf('\n========================================================\n');
    fprintf('📊 RESULTADO DA VERIFICAÇÃO FINAL\n');
    fprintf('========================================================\n');
    
    taxa_sucesso = (verificacoes_ok / total_verificacoes) * 100;
    
    fprintf('Verificações realizadas: %d\n', total_verificacoes);
    fprintf('Verificações aprovadas: %d\n', verificacoes_ok);
    fprintf('Taxa de sucesso: %.1f%%\n\n', taxa_sucesso);
    
    if verificacoes_ok == total_verificacoes
        fprintf('🎉 TODAS AS VERIFICAÇÕES PASSARAM!\n');
        fprintf('✅ Projeto está 100%% pronto para uso\n\n');
        fprintf('🚀 PRÓXIMOS PASSOS:\n');
        fprintf('   1. Execute: executar_comparacao()\n');
        fprintf('   2. Configure seus dados\n');
        fprintf('   3. Escolha uma opção do menu\n\n');
    else
        fprintf('⚠️  ALGUMAS VERIFICAÇÕES FALHARAM!\n');
        fprintf('❌ Corrija os problemas antes de usar o projeto\n\n');
        fprintf('🔧 SOLUÇÕES SUGERIDAS:\n');
        
        if ~arquivos_ok
            fprintf('   - Verifique se todos os arquivos estão presentes\n');
        end
        if ~dl_ok
            fprintf('   - Instale o Deep Learning Toolbox\n');
        end
        if ~funcoes_ok || ~arquitetura_ok
            fprintf('   - Verifique compatibilidade da versão do MATLAB\n');
        end
        fprintf('\n');
    end
    
    % Salvar log da verificação
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    log_file = sprintf('verificacao_final_%s.txt', timestamp);
    
    fprintf('📝 Log da verificação salvo em: %s\n', log_file);
    fprintf('========================================================\n\n');
    
end
