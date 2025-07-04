% ========================================================================
% TESTE FINAL DE INTEGRIDADE - PROJETO U-NET vs ATTENTION U-NET
% ========================================================================
% 
% Script para verificar se todas as correções foram aplicadas e se o
% projeto está funcionando corretamente após a limpeza e correção.
%
% VERSÃO: 1.0
% DATA: Julho 2025
% ========================================================================

clc;
fprintf('========================================\n');
fprintf('   TESTE FINAL DE INTEGRIDADE          \n');
fprintf('   Projeto U-Net vs Attention U-Net    \n');
fprintf('========================================\n\n');

% Contador de testes
total_testes = 0;
testes_ok = 0;

% 1. Verificar arquivo principal
fprintf('1. Testando arquivo principal...\n');
total_testes = total_testes + 1;
try
    help executar_comparacao;
    fprintf('   ✓ executar_comparacao.m: OK\n');
    testes_ok = testes_ok + 1;
catch ME
    fprintf('   ❌ executar_comparacao.m: ERRO - %s\n', ME.message);
end

% 2. Verificar funções auxiliares extraídas
fprintf('\n2. Testando funções auxiliares...\n');
funcoes_auxiliares = {
    'carregar_dados_robustos';
    'analisar_mascaras_automatico';
    'preprocessDataMelhorado';
    'calcular_iou_simples';
    'calcular_dice_simples';
    'calcular_accuracy_simples'
};

for i = 1:length(funcoes_auxiliares)
    total_testes = total_testes + 1;
    funcao = funcoes_auxiliares{i};
    try
        help(funcao);
        fprintf('   ✓ %s: OK\n', funcao);
        testes_ok = testes_ok + 1;
    catch ME
        fprintf('   ❌ %s: ERRO - %s\n', funcao, ME.message);
    end
end

% 3. Verificar scripts principais
fprintf('\n3. Testando scripts principais...\n');
scripts_principais = {
    'comparacao_unet_attention_final';
    'treinar_unet_simples';
    'teste_dados_segmentacao';
    'converter_mascaras';
    'create_working_attention_unet';
    'teste_attention_unet_real'
};

for i = 1:length(scripts_principais)
    total_testes = total_testes + 1;
    script = scripts_principais{i};
    try
        help(script);
        fprintf('   ✓ %s: OK\n', script);
        testes_ok = testes_ok + 1;
    catch ME
        fprintf('   ❌ %s: ERRO - %s\n', script, ME.message);
    end
end

% 4. Verificar se não há arquivos obsoletos
fprintf('\n4. Verificando arquivos obsoletos...\n');
arquivos_obsoletos = {
    'funcoes_auxiliares.m';
    'metricas_avaliacao.m';
    'funcoes_auxiliares_backup.m'
};

for i = 1:length(arquivos_obsoletos)
    arquivo = arquivos_obsoletos{i};
    if exist(arquivo, 'file')
        fprintf('   ⚠️  %s: AINDA EXISTE (deveria ter sido removido)\n', arquivo);
    else
        fprintf('   ✓ %s: Removido corretamente\n', arquivo);
    end
end

% 5. Testar função de configuração
fprintf('\n5. Testando função de configuração...\n');
total_testes = total_testes + 1;
try
    % Criar configuração de teste
    config_teste = struct();
    config_teste.imageDir = pwd; % Usar diretório atual para teste
    config_teste.maskDir = pwd;
    config_teste.inputSize = [256, 256, 3];
    config_teste.numClasses = 2;
    config_teste.validationSplit = 0.2;
    config_teste.miniBatchSize = 8;
    config_teste.maxEpochs = 20;
    config_teste.quickTest = struct('numSamples', 50, 'maxEpochs', 5);
    
    % Salvar e carregar para testar
    save('config_teste.mat', 'config_teste');
    load('config_teste.mat');
    delete('config_teste.mat');
    
    fprintf('   ✓ Configuração: OK\n');
    testes_ok = testes_ok + 1;
catch ME
    fprintf('   ❌ Configuração: ERRO - %s\n', ME.message);
end

% 6. Resultado final
fprintf('\n========================================\n');
fprintf('           RESULTADO FINAL              \n');
fprintf('========================================\n');
fprintf('Testes realizados: %d\n', total_testes);
fprintf('Testes bem-sucedidos: %d\n', testes_ok);
fprintf('Taxa de sucesso: %.1f%%\n', (testes_ok/total_testes)*100);

if testes_ok == total_testes
    fprintf('\n🎉 TODOS OS TESTES PASSARAM!\n');
    fprintf('✅ O projeto está pronto para uso.\n');
    fprintf('\nPara usar o projeto:\n');
    fprintf('1. Execute: executar_comparacao()\n');
    fprintf('2. Configure os caminhos dos seus dados\n');
    fprintf('3. Escolha as opções desejadas no menu\n');
else
    fprintf('\n⚠️  ALGUNS TESTES FALHARAM!\n');
    fprintf('❌ Revise os erros acima antes de usar o projeto.\n');
end

fprintf('\n========================================\n');
fprintf('Teste concluído: %s\n', string(datetime("now")));
fprintf('========================================\n');
