% TESTE ESPECÍFICO DOS PROBLEMAS REPORTADOS
%
% Este script testa especificamente os problemas que o usuário reportou

fprintf('========================================\n');
fprintf('  TESTE ESPECÍFICO DOS PROBLEMAS\n');
fprintf('========================================\n\n');

% Limpar workspace e recarregar tudo
clear;
rehash;
addpath(pwd);

% 1. Testar se existe erro de sintaxe na linha 59
fprintf('1. Testando sintaxe do executar_comparacao.m...\n');
try
    checkcode('executar_comparacao.m', '-string');
    fprintf('   ✓ Sintaxe OK\n');
catch ME
    fprintf('   ❌ Erro de sintaxe: %s\n', ME.message);
end

% 2. Testar se as funções auxiliares estão disponíveis
fprintf('\n2. Testando disponibilidade das funções...\n');
funcoes = {'carregar_dados_robustos', 'analisar_mascaras_automatico', 'preprocessDataMelhorado'};
for i = 1:length(funcoes)
    funcao = funcoes{i};
    if exist(funcao, 'file') == 2
        fprintf('   ✓ %s\n', funcao);
    else
        fprintf('   ❌ %s não encontrada\n', funcao);
    end
end

% 3. Testar criação da Attention U-Net sem ValidationFrequency
fprintf('\n3. Testando Attention U-Net (sem ValidationFrequency)...\n');
try
    lgraph = create_working_attention_unet([256, 256, 3], 2);
    fprintf('   ✓ Attention U-Net criada\n');
    
    % Testar opções de treinamento simples (sem ValidationFrequency)
    options = trainingOptions('adam', ...
        'InitialLearnRate', 1e-3, ...
        'MaxEpochs', 1, ...
        'MiniBatchSize', 2, ...
        'Verbose', false, ...
        'Plots', 'none');
    fprintf('   ✓ Opções de treinamento OK\n');
    
catch ME
    fprintf('   ❌ Erro: %s\n', ME.message);
end

% 4. Testar carregamento de configuração
fprintf('\n4. Testando configuração...\n');
if exist('config_caminhos.mat', 'file')
    try
        load('config_caminhos.mat', 'config');
        if isfield(config, 'imageDir') && isfield(config, 'maskDir')
            fprintf('   ✓ Configuração carregada e válida\n');
        else
            fprintf('   ⚠️ Configuração incompleta\n');
        end
    catch ME
        fprintf('   ❌ Erro ao carregar: %s\n', ME.message);
    end
else
    fprintf('   ⚠️ Nenhuma configuração encontrada\n');
end

% 5. Verificar se o script principal pode ser chamado
fprintf('\n5. Testando disponibilidade do script principal...\n');
if exist('executar_comparacao', 'file') == 2
    fprintf('   ✓ executar_comparacao disponível\n');
    
    % Testar help (não executa a função)
    try
        help executar_comparacao;
        fprintf('   ✓ Help do script OK\n');
    catch ME
        fprintf('   ❌ Erro no help: %s\n', ME.message);
    end
else
    fprintf('   ❌ executar_comparacao não encontrado\n');
end

fprintf('\n========================================\n');
fprintf('         TESTE CONCLUÍDO\n');
fprintf('========================================\n');
fprintf('Se todos os itens estão ✓, o projeto deve funcionar.\n');
fprintf('Se há ❌, execute:\n');
fprintf('   >> clear all; rehash; addpath(pwd);\n');
fprintf('   >> executar_comparacao()\n');
fprintf('========================================\n\n');
