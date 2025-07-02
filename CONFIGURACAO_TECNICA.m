% ========================================================================
% CONFIGURAÇÃO TÉCNICA DO PROJETO MATLAB
% ========================================================================
% 
% Este arquivo contém configurações técnicas específicas para o AI Assistant
% ler e entender o contexto do projeto antes de qualquer modificação.
%
% USO: Sempre ler este arquivo antes de modificar código MATLAB
% ========================================================================

%% CONFIGURAÇÕES CRÍTICAS DO PROJETO

% NOME DO PROJETO
projeto.nome = 'Comparacao U-Net vs Attention U-Net';
projeto.versao = '1.1';
projeto.status = 'FUNCIONAL_E_TESTADO';

% ARQUIVO PRINCIPAL (SEMPRE USAR ESTE)
projeto.arquivo_principal = 'executar_comparacao.m';

% IMPLEMENTAÇÃO DA ATTENTION U-NET (ÚNICA VERSÃO FUNCIONAL)
projeto.attention_unet_funcional = 'create_working_attention_unet.m';

%% ARQUIVOS ESSENCIAIS (NÃO DELETAR)

arquivos_essenciais = {
    'executar_comparacao.m',              % Script principal
    'comparacao_unet_attention_final.m',  % Comparação completa
    'converter_mascaras.m',               % Conversão máscaras
    'teste_dados_segmentacao.m',          % Teste dados
    'treinar_unet_simples.m',             % Teste rápido
    'create_working_attention_unet.m',    % Attention U-Net ÚNICA
    'teste_attention_unet_real.m',        % Teste Attention U-Net
    'funcoes_auxiliares.m',               % Funções auxiliares
    'analise_metricas_detalhada.m',       % Análise métricas
    'README.md',                          % Documentação
    'CONFIG_PROJETO.md',                  % Manual instruções
    'CONFIGURACAO_TECNICA.m',             % Este arquivo
    '.gitignore',                         % Git
    'config_caminhos.mat',                % Config automática
    % Arquivos gerados automaticamente:
    'modelo_unet.mat',                    % Modelo treinado
    'resultados_comparacao.mat'           % Resultados
};

%% REGRAS DE DESENVOLVIMENTO

regras.NUNCA_FAZER = {
    'Criar novos arquivos de Attention U-Net',
    'Duplicar funções existentes',
    'Modificar create_working_attention_unet.m sem extrema necessidade',
    'Deletar arquivos sem verificar dependências',
    'Criar versões alternativas dos scripts principais'
};

regras.SEMPRE_FAZER = {
    'Ler CONFIG_PROJETO.md antes de modificar',
    'Usar arquivos existentes como base',
    'Verificar dependências com grep_search antes de deletar',
    'Testar funcionalidade após modificações',
    'Documentar mudanças significativas'
};

%% DEPENDÊNCIAS CRÍTICAS

% Funções que DEVEM existir em funcoes_auxiliares.m
funcoes_criticas = {
    'carregar_dados_robustos',      % Carregamento dados
    'analisar_mascaras_automatico', % Análise máscaras  
    'configurar_projeto_inicial',   % Configuração inicial
    'preprocessDataMelhorado',      % Preprocessamento
    'calcular_iou_simples',         % Cálculo IoU
    'calcular_dice_simples',        % Cálculo Dice
    'calcular_accuracy_simples'     % Cálculo acurácia
};

% Scripts que dependem de outros
dependencias = containers.Map();
dependencias('executar_comparacao.m') = {
    'teste_dados_segmentacao.m',
    'converter_mascaras.m', 
    'treinar_unet_simples.m',
    'comparacao_unet_attention_final.m',
    'teste_attention_unet_real.m',
    'funcoes_auxiliares.m'
};

dependencias('comparacao_unet_attention_final.m') = {
    'create_working_attention_unet.m',
    'funcoes_auxiliares.m'
};

%% CONFIGURAÇÕES PADRÃO

config_padrao.inputSize = [256, 256, 3];
config_padrao.numClasses = 2;
config_padrao.validationSplit = 0.2;
config_padrao.miniBatchSize = 8;
config_padrao.maxEpochs = 20;

% Configuração para teste rápido
config_teste.numSamples = 50;
config_teste.maxEpochs = 5;
config_teste.miniBatchSize = 4;

%% PROBLEMAS CONHECIDOS E SOLUÇÕES

problemas = struct();

% Problema 1: Attention U-Net não funciona
problemas.attention_unet_erro.descricao = 'Erro na implementação attention gates';
problemas.attention_unet_erro.solucao = 'Usar create_working_attention_unet.m';
problemas.attention_unet_erro.nao_fazer = 'Criar nova implementação';

% Problema 2: Function not found
problemas.function_not_found.descricao = 'Referência a arquivo deletado';
problemas.function_not_found.solucao = 'Verificar se arquivo existe';
problemas.function_not_found.verificar = 'funcoes_auxiliares.m tem todas funções';

% Problema 3: Máscaras incompatíveis
problemas.mascaras_incompativeis.descricao = 'Formato incorreto máscaras';
problemas.mascaras_incompativeis.solucao = 'Usar opção 2 menu (converter_mascaras)';
problemas.mascaras_incompativeis.formato = 'Valores 0 e 255';

% Problema 4: Erro de memória
problemas.memoria_erro.descricao = 'Batch size muito grande';
problemas.memoria_erro.solucao = 'Reduzir miniBatchSize para 4 ou 2';
problemas.memoria_erro.nao_fazer = 'Aumentar amostras sem verificar RAM';

%% MÉTRICAS ESPERADAS

metricas.IoU.min = 0.85;
metricas.IoU.max = 0.92;
metricas.Dice.min = 0.92;
metricas.Dice.max = 0.96;
metricas.Accuracy.min = 0.85;
metricas.Accuracy.max = 0.95;

% Tempos esperados (CPU)
tempos.unet_minutos = 20;
tempos.attention_minutos = 25;
tempos.comparacao_total = 50;

% Diferença esperada
diferenca.attention_melhor_que_unet = 0.02; % 2% mínimo

%% CHECKLIST DE VALIDAÇÃO

function status = validar_projeto()
    % Validar se projeto está íntegro
    
    status = struct();
    status.arquivos_ok = true;
    status.dependencias_ok = true;
    status.configuracao_ok = true;
    
    % Verificar arquivos essenciais
    for i = 1:length(arquivos_essenciais)
        arquivo = arquivos_essenciais{i};
        if ~exist(arquivo, 'file')
            fprintf('❌ Arquivo essencial não encontrado: %s\n', arquivo);
            status.arquivos_ok = false;
        end
    end
    
    % Verificar função principal
    if exist('executar_comparacao.m', 'file')
        fprintf('✅ Script principal encontrado\n');
    else
        fprintf('❌ Script principal não encontrado!\n');
        status.arquivos_ok = false;
    end
    
    % Verificar Attention U-Net
    if exist('create_working_attention_unet.m', 'file')
        fprintf('✅ Attention U-Net funcional encontrada\n');
    else
        fprintf('❌ Attention U-Net funcional não encontrada!\n');
        status.dependencias_ok = false;
    end
    
    % Verificar configuração
    if exist('config_caminhos.mat', 'file')
        fprintf('✅ Configuração encontrada\n');
    else
        fprintf('⚠️ Configuração não encontrada (será criada na primeira execução)\n');
    end
    
    % Status final
    if status.arquivos_ok && status.dependencias_ok && status.configuracao_ok
        fprintf('✅ PROJETO ÍNTEGRO E FUNCIONAL\n');
        status.geral = true;
    else
        fprintf('❌ PROJETO COM PROBLEMAS - NECESSITA CORREÇÃO\n');
        status.geral = false;
    end
end

%% INSTRUÇÕES PARA AI ASSISTANT

instrucoes_ai = {
    '1. SEMPRE ler CONFIG_PROJETO.md antes de qualquer modificação',
    '2. SEMPRE ler este arquivo (CONFIGURACAO_TECNICA.m) para contexto técnico',
    '3. NUNCA criar novos arquivos sem verificar se funcionalidade já existe',
    '4. SEMPRE usar grep_search para verificar dependências antes de deletar',
    '5. SEMPRE testar funcionalidade após modificações',
    '6. USAR arquivos existentes como base para modificações',
    '7. DOCUMENTAR mudanças significativas no README.md',
    '8. MANTER o projeto enxuto - evitar duplicação de código',
    '9. PRIORIZAR funcionalidade sobre complexidade',
    '10. EM CASO DE DÚVIDA, usar implementações mais simples'
};

%% COMANDOS ÚTEIS PARA DEBUG

comandos_debug = {
    'executar_comparacao()           % Menu principal',
    'validar_projeto()               % Verificar integridade',
    'load(''config_caminhos.mat'')     % Carregar configuração', 
    'dir(''*.m'')                      % Listar arquivos MATLAB',
    'which create_working_attention_unet % Verificar função',
    'help executar_comparacao        % Ajuda do script principal'
};

fprintf('📋 CONFIGURAÇÃO TÉCNICA CARREGADA\n');
fprintf('📁 Projeto: %s v%s\n', projeto.nome, projeto.versao);
fprintf('✅ Status: %s\n', projeto.status);
fprintf('🎯 Para validar projeto: validar_projeto()\n');
fprintf('🚀 Para executar: %s\n', projeto.arquivo_principal);

% ========================================================================
% FIM DA CONFIGURAÇÃO TÉCNICA
% ========================================================================
