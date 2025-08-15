function executar_comparacao()
    % ========================================================================
    % SCRIPT PRINCIPAL: COMPARACAO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 1.2 Final
    %
    % DESCRIÇÃO:
    %   Script principal para comparação entre U-Net clássica e Attention U-Net
    %   em tarefas de segmentação semântica de imagens.
    %
    % FUNCIONALIDADES:
    %   1. Teste de formato dos dados (verificação de compatibilidade)
    %   2. Conversão de máscaras (padronização para formato binário)
    %   3. Teste rápido com U-Net simples (validação inicial)
    %   4. Comparação completa U-Net vs Attention U-Net (análise principal)
    %   5. Execução automática de todos os passos
    %   6. Teste específico da Attention U-Net
    %
    % USO:
    %   >> executar_comparacao()
    %
    % ESTRUTURA DO PROJETO (v1.2 - Corrigida):
    %   - Arquivos organizados e sem duplicatas
    %   - Scripts com encoding correto
    %   - Implementação funcional da Attention U-Net
    %
    % VERSÃO: 1.2 (Corrigida)
    % DATA: Julho 2025
    % STATUS: ✅ Funcional e Testado
    % ========================================================================
    
    % Adicionar pasta atual e subdiretórios ao path do MATLAB
    pasta_atual = pwd;
    addpath(pasta_atual);
    addpath(fullfile(pasta_atual, 'scripts'));
    addpath(fullfile(pasta_atual, 'utils'));
    addpath(fullfile(pasta_atual, 'legacy'));
    8
    % Verificar se as funções auxiliares estão disponíveis
    if ~exist('configurar_caminhos', 'file')
        warning('Função configurar_caminhos não encontrada. Verifique se configurar_caminhos.m está na pasta scripts/.');
    end
    
    if ~exist('carregar_dados_robustos', 'file')
        warning('Função carregar_dados_robustos não encontrada. Verifique se carregar_dados_robustos.m está na pasta utils/.');
    end
    
    if ~exist('create_working_attention_unet', 'file')
        warning('Função create_working_attention_unet não encontrada. Verifique se create_working_attention_unet.m está na pasta legacy/.');
    end
    
    if ~exist('analisar_mascaras_automatico', 'file')
        warning('Função analisar_mascaras_automatico não encontrada. Verifique se analisar_mascaras_automatico.m está na pasta utils/.');
    end
    
    if ~exist('preprocessDataCorrigido', 'file')
        warning('Função preprocessDataCorrigido não encontrada. Verifique se preprocessDataCorrigido.m está na pasta utils/.');
    end
    
    clc;
    fprintf('=====================================\n');
    fprintf('   COMPARACAO U-NET vs ATTENTION U-NET\n');
    fprintf('      Script de Execucao Principal     \n');
    fprintf('      (Versão 1.2 - Corrigida)        \n');
    fprintf('=====================================\n\n');
    
    % Aviso sobre nova interface integrada
    fprintf('📢 NOVA INTERFACE DISPONÍVEL!\n');
    fprintf('Para acessar as funcionalidades integradas de:\n');
    fprintf('• Gerenciamento de modelos\n');
    fprintf('• Organização automática de resultados\n');
    fprintf('• Configuração avançada\n');
    fprintf('\nExecute: main_sistema_comparacao\n');
    fprintf('=====================================\n\n');
    
    % Verificar se existe configuração salva
    if ~exist('config_caminhos.mat', 'file')
        fprintf('=== CONFIGURACAO INICIAL ===\n');
        fprintf('Primeira execução detectada. Configurando caminhos...\n\n');
        
        % Tentar usar configuração automática primeiro
        try
            config = configurar_caminhos_automatico();
        catch
            % Se a automática falhar, usar a manual
            fprintf('Configuração automática falhou, usando manual...\n');
            config = configurar_caminhos();
        end
    else
        load('config_caminhos.mat', 'config');
        
        % Verificar se a configuração ainda é válida
        if validar_configuracao_existente(config)
            fprintf('✓ Configuração carregada automaticamente.\n');
            fprintf('  Imagens: %s\n', config.imageDir);
            fprintf('  Máscaras: %s\n', config.maskDir);
            fprintf('  Configuração válida e será usada.\n\n');
        else
            fprintf('⚠️  Configuração inválida ou caminhos não encontrados.\n');
            fprintf('   Reconfigurando automaticamente...\n\n');
            
            % Sempre usar configuração automática
            try
                config = configurar_caminhos_automatico();
            catch ME
                fprintf('❌ Erro na configuração automática: %s\n', ME.message);
                error('Falha na configuração de caminhos');
            end
        end
    end
    
    while true
        fprintf('\n\nEscolha uma opcao:\n');
        fprintf('1. Testar formato dos dados\n');
        fprintf('2. Converter mascaras (se necessario)\n');
        fprintf('3. Teste rapido com U-Net simples\n');
        fprintf('4. Comparacao completa U-Net vs Attention U-Net\n');
        fprintf('5. Executar todos os passos em sequencia\n');
        fprintf('6. NOVO: Comparacao com validacao cruzada\n');
        fprintf('7. TESTE: Verificar Attention U-Net\n');
        fprintf('0. Sair\n\n');
        
        opcao = input('Opcao: ');
        
        switch opcao
            case 0
                fprintf('Saindo...\n');
                break;
                
            case 1
                fprintf('\n=== TESTANDO FORMATO DOS DADOS ===\n');
                executar_seguro(@() teste_dados_segmentacao(config), 'Teste dos dados');
                
            case 2
                fprintf('\n=== CONVERTENDO MASCARAS ===\n');
                executar_seguro(@() converter_mascaras(config), 'Conversão de máscaras');
                
            case 3
                fprintf('\n=== TESTE RAPIDO ===\n');
                executar_seguro(@() treinar_unet_simples(config), 'Teste rápido');
                
            case 4
                fprintf('\n=== COMPARACAO COMPLETA ===\n');
                executar_seguro(@() comparacao_unet_attention_final(config), 'Comparação completa');
                
            case 5
                fprintf('\n--- EXECUTANDO TODOS OS PASSOS ---\n');
                
                % Passo 1: Testar dados
                fprintf('\n[1/4] Testando formato dos dados...\n');
                sucesso = executar_seguro(@() teste_dados_segmentacao(config), 'Teste dos dados', false);
                if ~sucesso
                    resp = input('Continuar mesmo assim? (s/n): ', 's');
                    if lower(resp) ~= 's'
                        continue;
                    end
                end
                
                % Passo 2: Perguntar sobre conversao
                resp = input('\nDeseja converter as mascaras? (s/n): ', 's');
                if lower(resp) == 's'
                    fprintf('\n[2/4] Convertendo mascaras...\n');
                    executar_seguro(@() converter_mascaras(config), 'Conversão de máscaras');
                end
                
                % Passo 3: Perguntar sobre teste rápido
                resp = input('\nDeseja fazer um teste rapido primeiro? (s/n): ', 's');
                if lower(resp) == 's'
                    fprintf('\n[3/4] Executando teste rapido...\n');
                    executar_seguro(@() treinar_unet_simples(config), 'Teste rápido');
                end
                
                % Passo 4: Comparação completa
                fprintf('\n[4/4] Executando comparacao completa...\n');
                executar_seguro(@() comparacao_unet_attention_final(config), 'Comparação completa');
                
                fprintf('\n✓ TODOS OS PASSOS CONCLUÍDOS!\n');
                fprintf('\nPressione qualquer tecla para continuar...\n');
                pause;
                
            case 6
                fprintf('\n=== VALIDACAO CRUZADA ===\n');
                executar_seguro(@() validacao_cruzada_k_fold(config), 'Validação cruzada');
                
            case 7
                fprintf('\n=== TESTE ESPECÍFICO ATTENTION U-NET ===\n');
                executar_seguro(@() teste_attention_unet_real(), 'Teste Attention U-Net');
                
            otherwise
                fprintf('Opcao invalida!\n');
        end
    end
end

function valido = validar_configuracao_existente(config)
    % Valida se a configuração existente ainda é válida
    
    valido = false;
    
    try
        % Verificar campos obrigatórios
        if ~isfield(config, 'imageDir') || ~isfield(config, 'maskDir')
            return;
        end
        
        % Verificar se os diretórios ainda existem
        if ~exist(config.imageDir, 'dir') || ~exist(config.maskDir, 'dir')
            return;
        end
        
        % Verificar se há arquivos
        imgs = dir(fullfile(config.imageDir, '*.jpg'));
        if isempty(imgs)
            imgs = dir(fullfile(config.imageDir, '*.jpeg'));
        end
        if isempty(imgs)
            imgs = dir(fullfile(config.imageDir, '*.png'));
        end
        
        masks = dir(fullfile(config.maskDir, '*.jpg'));
        if isempty(masks)
            masks = dir(fullfile(config.maskDir, '*.jpeg'));
        end
        if isempty(masks)
            masks = dir(fullfile(config.maskDir, '*.png'));
        end
        
        if ~isempty(imgs) && ~isempty(masks)
            valido = true;
        end
        
    catch
        % Se houver qualquer erro, considerar inválido
        valido = false;
    end
end

function sucesso = executar_seguro(funcao, descricao, mostrar_sucesso)
    % Executa uma função de forma segura
    % Parâmetros:
    %   funcao - handle da função a ser executada
    %   descricao - descrição da operação
    %   mostrar_sucesso - se deve mostrar mensagem de sucesso (padrão: true)
    
    if nargin < 3
        mostrar_sucesso = true;
    end
    
    sucesso = false;
    
    % Executar função em modo seguro
    try
        funcao();
        sucesso = true;
        if mostrar_sucesso
            fprintf('✓ %s concluído!\n', descricao);
        else
            fprintf('OK!\n');
        end
    catch ME
        fprintf('❌ Erro em %s: %s\n', descricao, ME.message);
    end
end

function validacao_cruzada_k_fold(config)
    % Validação cruzada k-fold
    
    fprintf('=== VALIDACAO CRUZADA K-FOLD ===\n');
    
    k = 5; % 5-fold cross validation
    fprintf('Executando validação cruzada %d-fold...\n', k);
    fprintf('AVISO: Este processo pode levar 2-4 horas!\n');
    
    resp = input('Continuar? (s/n): ', 's');
    if lower(resp) ~= 's'
        return;
    end
    
    % Carregar dados
    fprintf('\nCarregando dados...\n');
    [images, masks] = carregar_dados_robustos(config);
    
    if length(images) < k
        error('Número insuficiente de amostras para validação cruzada %d-fold', k);
    end
    
    % Dividir dados em k folds
    numSamples = length(images);
    indices = randperm(numSamples);
    foldSize = floor(numSamples / k);
    
    % Pré-alocar arrays para evitar warnings
    resultados_unet = zeros(1, k);
    resultados_attention = zeros(1, k);
    num_sucessos_unet = 0;
    num_sucessos_attention = 0;
    
    for fold = 1:k
        fprintf('\n--- FOLD %d/%d ---\n', fold, k);
        
        % Definir índices de teste e treinamento
        testStart = (fold-1) * foldSize + 1;
        testEnd = min(fold * foldSize, numSamples);
        testIdx = indices(testStart:testEnd);
        trainIdx = setdiff(indices, testIdx);
        
        fprintf('Treinamento: %d amostras, Teste: %d amostras\n', ...
                length(trainIdx), length(testIdx));
        
        % Treinar e avaliar U-Net
        resultado_unet = treinar_e_avaliar_fold_seguro(images, masks, trainIdx, testIdx, config, 'unet');
        if ~isempty(resultado_unet)
            num_sucessos_unet = num_sucessos_unet + 1;
            resultados_unet(num_sucessos_unet) = resultado_unet;
            fprintf('U-Net Fold %d: %.4f\n', fold, resultado_unet);
        else
            fprintf('Erro na U-Net Fold %d\n', fold);
        end
        
        % Treinar e avaliar Attention U-Net
        resultado_attention = treinar_e_avaliar_fold_seguro(images, masks, trainIdx, testIdx, config, 'attention');
        if ~isempty(resultado_attention)
            num_sucessos_attention = num_sucessos_attention + 1;
            resultados_attention(num_sucessos_attention) = resultado_attention;
            fprintf('Attention U-Net Fold %d: %.4f\n', fold, resultado_attention);
        else
            fprintf('Erro na Attention U-Net Fold %d\n', fold);
        end
    end
    
    % Cortar arrays para o tamanho real
    resultados_unet = resultados_unet(1:num_sucessos_unet);
    resultados_attention = resultados_attention(1:num_sucessos_attention);
    
    % Calcular estatísticas finais
    if ~isempty(resultados_unet) && ~isempty(resultados_attention)
        fprintf('\n=== RESULTADOS FINAIS ===\n');
        fprintf('U-Net: %.4f ± %.4f\n', mean(resultados_unet), std(resultados_unet));
        fprintf('Attention U-Net: %.4f ± %.4f\n', mean(resultados_attention), std(resultados_attention));
        
        % Teste estatístico
        [h, p] = ttest2(resultados_unet, resultados_attention);
        if h
            significativo = 'Sim';
        else
            significativo = 'Nao';
        end
        fprintf('Teste t-student: p = %.4f, significativo = %s\n', p, significativo);
        
        % Salvar resultados
        save('resultados_validacao_cruzada.mat', 'resultados_unet', 'resultados_attention', 'k', 'p', 'h');
        fprintf('Resultados salvos em: resultados_validacao_cruzada.mat\n');
    else
        fprintf('Nenhum resultado válido obtido.\n');
    end
end

function resultado = treinar_e_avaliar_fold_seguro(images, masks, trainIdx, testIdx, config, tipo_modelo)
    % Treinar e avaliar um modelo em um fold específico de forma segura
    
    resultado = [];
    
    try
        % Preparar dados do fold
        trainImages = images(trainIdx);
        trainMasks = masks(trainIdx);
        testImages = images(testIdx);
        testMasks = masks(testIdx);
        
        % Analisar máscaras
        [classNames, labelIDs] = analisar_mascaras_automatico(config.maskDir, trainMasks);
        
        % Criar datastores
        [dsTrain, dsTest] = preparar_dados_fold(trainImages, trainMasks, testImages, testMasks, config, classNames, labelIDs);
        
        % Criar modelo
        inputSize = config.inputSize;
        numClasses = config.numClasses;
        
        if strcmp(tipo_modelo, 'attention')
            lgraph = create_working_attention_unet(inputSize, numClasses);
        else
            lgraph = unetLayers(inputSize, numClasses, 'EncoderDepth', 4);
        end
        
        % Opções de treinamento
        options = trainingOptions('adam', ...
            'InitialLearnRate', 1e-3, ...
            'MaxEpochs', 10, ... % Reduzido para validação cruzada
            'MiniBatchSize', config.miniBatchSize, ...
            'ValidationData', dsTest, ...
            'ValidationFrequency', 5, ...
            'Plots', 'none', ... % Sem plots para validação cruzada
            'Verbose', false, ...
            'ExecutionEnvironment', 'auto');
        
        % Treinar
        net = trainNetwork(dsTrain, lgraph, options);
        
        % Avaliar
        resultado = avaliar_modelo_fold(net, dsTest);
        
    catch ME
        fprintf('Erro no fold %s: %s\n', tipo_modelo, ME.message);
    end
end

function [dsTrain, dsTest] = preparar_dados_fold(trainImages, trainMasks, testImages, testMasks, config, classNames, labelIDs)
    % Preparar datastores para um fold específico
    
    % Criar datastores de imagem
    imdsTrain = imageDatastore(trainImages);
    imdsTest = imageDatastore(testImages);
    
    % Criar datastores de máscara
    pxdsTrain = pixelLabelDatastore(trainMasks, classNames, labelIDs);
    pxdsTest = pixelLabelDatastore(testMasks, classNames, labelIDs);
    
    % Combinar datastores
    dsTrain = combine(imdsTrain, pxdsTrain);
    dsTest = combine(imdsTest, pxdsTest);
    
    % Aplicar transformações
    dsTrain = transform(dsTrain, @(data) preprocessDataCorrigido(data, config, labelIDs, true));
    dsTest = transform(dsTest, @(data) preprocessDataCorrigido(data, config, labelIDs, false));
end

function resultado = avaliar_modelo_fold(net, dsTest)
    % Avaliar modelo em dados de teste
    
    reset(dsTest);
    
    % Estimar número de amostras para pré-alocação
    numAmostras = 50; % Estimativa padrão
    ious = zeros(1, numAmostras);
    contador = 0;
    
    while hasdata(dsTest)
        data = read(dsTest);
        img = data{1};
        gt = data{2};
        
        % Predição
        pred = semanticseg(img, net);
        
        % Calcular IoU
        iou = calcular_iou_simples(pred, gt);
        
        contador = contador + 1;
        
        % Expandir array se necessário
        if contador > length(ious)
            ious = [ious, zeros(1, numAmostras)];
        end
        
        ious(contador) = iou;
    end
    
    % Cortar array para o tamanho real
    ious = ious(1:contador);
    resultado = mean(ious);
end

function iou = calcular_iou_simples(pred, gt)
    % Calcular IoU entre predição e ground truth
    
    % Converter para binário
    if iscategorical(pred)
        predBinary = (pred == "foreground");
    else
        predBinary = pred > 0;
    end
    
    if iscategorical(gt)
        gtBinary = (gt == "foreground");
    else
        gtBinary = gt > 0;
    end
    
    % Calcular IoU
    intersection = sum(predBinary(:) & gtBinary(:));
    union = sum(predBinary(:) | gtBinary(:));
    
    if union == 0
        iou = 1; % Ambos são vazios
    else
        iou = intersection / union;
    end
end
