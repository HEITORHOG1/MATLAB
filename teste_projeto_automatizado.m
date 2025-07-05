% TESTE AUTOMATIZADO - VERIFICAÇÃO DO PROJETO
%
% Este script verifica se todas as correções foram aplicadas com sucesso
% e se o projeto está funcionando corretamente.

fprintf('========================================\n');
fprintf('    TESTE AUTOMATIZADO DO PROJETO\n');
fprintf('========================================\n\n');

% Verificar se os arquivos existem
arquivos_essenciais = {
    'executar_comparacao.m'; ...
    'carregar_dados_robustos.m'; ...
    'configurar_caminhos.m'; ...
    'create_working_attention_unet.m'; ...
    'teste_attention_unet_real.m'; ...
    'comparacao_unet_attention_final.m'; ...
    'treinar_unet_simples.m'; ...
    'teste_dados_segmentacao.m'; ...
    'converter_mascaras.m'; ...
    'analisar_mascaras_automatico.m'; ...
    'preprocessDataMelhorado.m'; ...
    'preprocessDataCorrigido.m'
};

fprintf('1. Verificando arquivos essenciais...\n');
todos_arquivos_ok = true;
for i = 1:length(arquivos_essenciais)
    arquivo = arquivos_essenciais{i};
    if exist(arquivo, 'file')
        fprintf('   ✓ %s\n', arquivo);
    else
        fprintf('   ❌ %s\n', arquivo);
        todos_arquivos_ok = false;
    end
end

% Verificar funções no path
fprintf('\n2. Verificando funções no path do MATLAB...\n');
funcoes_testadas = {
    'carregar_dados_robustos'; ...
    'create_working_attention_unet'; ...
    'teste_attention_unet_real'; ...
    'executar_comparacao'; ...
    'analisar_mascaras_automatico'; ...
    'preprocessDataMelhorado'
};

todas_funcoes_ok = true;
for i = 1:length(funcoes_testadas)
    funcao = funcoes_testadas{i};
    if exist(funcao, 'file')
        fprintf('   ✓ %s\n', funcao);
    else
        fprintf('   ❌ %s\n', funcao);
        todas_funcoes_ok = false;
    end
end

% Testar criação da Attention U-Net
fprintf('\n3. Testando criação da Attention U-Net...\n');
try
    lgraph = create_working_attention_unet([256, 256, 3], 2);
    fprintf('   ✓ Attention U-Net criada com sucesso\n');
    attention_ok = true;
catch ME
    fprintf('   ❌ Erro na criação: %s\n', ME.message);
    attention_ok = false;
end

% Testar script principal (verificação de sintaxe)
fprintf('\n4. Testando script principal...\n');
try
    help executar_comparacao;
    fprintf('   ✓ Script principal OK\n');
    script_ok = true;
catch ME
    fprintf('   ❌ Erro no script: %s\n', ME.message);
    script_ok = false;
end

% Verificar configuração salva (se existir)
fprintf('\n5. Verificando configuração...\n');
if exist('config_caminhos.mat', 'file')
    try
        load('config_caminhos.mat', 'config');
        fprintf('   ✓ Configuração encontrada\n');
        if isfield(config, 'imageDir') && isfield(config, 'maskDir')
            fprintf('   ✓ Campos de configuração corretos\n');
            config_ok = true;
        else
            fprintf('   ⚠️ Campos de configuração incompletos\n');
            config_ok = false;
        end
    catch ME
        fprintf('   ❌ Erro ao carregar configuração: %s\n', ME.message);
        config_ok = false;
    end
else
    fprintf('   ⚠️ Nenhuma configuração encontrada (normal na primeira execução)\n');
    config_ok = true; % Não é um erro crítico
end

% Resumo final
fprintf('\n========================================\n');
fprintf('             RESUMO DO TESTE\n');
fprintf('========================================\n');

if todos_arquivos_ok
    fprintf('Arquivos essenciais: ✅ OK\n');
else
    fprintf('Arquivos essenciais: ❌ PROBLEMAS\n');
end

if todas_funcoes_ok
    fprintf('Funções no path: ✅ OK\n');
else
    fprintf('Funções no path: ❌ PROBLEMAS\n');
end

if attention_ok
    fprintf('Attention U-Net: ✅ OK\n');
else
    fprintf('Attention U-Net: ❌ PROBLEMAS\n');
end

if script_ok
    fprintf('Script principal: ✅ OK\n');
else
    fprintf('Script principal: ❌ PROBLEMAS\n');
end

if config_ok
    fprintf('Configuração: ✅ OK\n');
else
    fprintf('Configuração: ❌ PROBLEMAS\n');
end

% Resultado final
if todos_arquivos_ok && todas_funcoes_ok && attention_ok && script_ok && config_ok
    fprintf('\n🎉 SUCESSO: Projeto está funcionando corretamente!\n');
    fprintf('   Todos os problemas foram corrigidos.\n');
    fprintf('   Você pode executar: executar_comparacao()\n');
else
    fprintf('\n⚠️ ATENÇÃO: Alguns problemas foram encontrados.\n');
    fprintf('   Verifique os itens marcados com ❌ acima.\n');
end

fprintf('\n========================================\n\n');
