function executar_comparacao_corrigida()
    % SCRIPT PRINCIPAL CORRIGIDO - COMPARAÇÃO U-NET vs ATTENTION U-NET
    % 
    % Versão corrigida e completa do projeto de comparação entre
    % U-Net clássica e Attention U-Net para segmentação de imagens.
    % 
    % MELHORIAS IMPLEMENTADAS:
    % - Configuração portável de caminhos
    % - Attention U-Net corrigida e funcional
    % - Métricas avançadas de segmentação
    % - Data augmentation
    % - Validação cruzada k-fold
    % - Early stopping
    % - Otimização de hiperparâmetros
    % - Relatórios detalhados
    
    clc;
    fprintf('\n================================================\n');
    fprintf('   COMPARAÇÃO U-NET vs ATTENTION U-NET (CORRIGIDA)\n');
    fprintf('        Script Principal - Versão 2.0           \n');
    fprintf('================================================\n\n');
    
    % Verificar dependências
    verificar_dependencias();
    
    % Menu principal
    while true
        fprintf('\n=== MENU PRINCIPAL ===\n');
        fprintf('1. Configuração inicial e teste de dados\n');
        fprintf('2. Teste rápido (validação do pipeline)\n');
        fprintf('3. Comparação básica (treinamento único)\n');
        fprintf('4. Comparação avançada (validação cruzada)\n');
        fprintf('5. Otimização de hiperparâmetros\n');
        fprintf('6. Análise completa (todos os passos)\n');
        fprintf('7. Visualizar resultados salvos\n');
        fprintf('0. Sair\n');
        
        opcao = input('\nEscolha uma opção: ');
        
        try
            switch opcao
                case 1
                    executar_configuracao_inicial();
                    
                case 2
                    executar_teste_rapido();
                    
                case 3
                    executar_comparacao_basica();
                    
                case 4
                    executar_comparacao_avancada();
                    
                case 5
                    executar_otimizacao_hiperparametros();
                    
                case 6
                    executar_analise_completa();
                    
                case 7
                    visualizar_resultados_salvos();
                    
                case 0
                    fprintf('\nEncerrando programa...\n');
                    break;
                    
                otherwise
                    fprintf('\nOpção inválida! Tente novamente.\n');
            end
            
        catch ME
            fprintf('\n!!! ERRO !!!\n');
            fprintf('Mensagem: %s\n', ME.message);
            fprintf('Arquivo: %s\n', ME.stack(1).name);
            fprintf('Linha: %d\n', ME.stack(1).line);
            
            resp = input('\nDeseja continuar? (s/n): ', 's');
            if lower(resp) ~= 's'
                break;
            end
        end
        
        fprintf('\nPressione Enter para continuar...');
        input('');
    end
end

function verificar_dependencias()
    % Verificar se todas as dependências estão disponíveis
    
    fprintf('Verificando dependências...\n');
    
    % Verificar Deep Learning Toolbox
    if ~license('test', 'Neural_Network_Toolbox')
        error('Deep Learning Toolbox é necessário para este projeto');
    end
    
    % Verificar Computer Vision Toolbox
    if ~license('test', 'Video_and_Image_Blockset')
        warning('Computer Vision Toolbox recomendado para melhor performance');
    end
    
    % Verificar se GPU está disponível
    try
        gpuDevice;
        fprintf('GPU detectada e disponível\n');
    catch
        fprintf('GPU não disponível - usando CPU\n');
    end
    
    fprintf('Verificação concluída!\n\n');
end

function executar_configuracao_inicial()
    % Configuração inicial e teste dos dados
    
    fprintf('\n=== CONFIGURAÇÃO INICIAL ===\n');
    
    % Carregar ou criar configuração
    config = config_projeto();
    
    % Testar dados
    fprintf('\nTestando formato dos dados...\n');
    testar_dados_segmentacao_corrigido(config);
    
    % Perguntar sobre conversão de máscaras
    resp = input('\nDeseja converter máscaras para formato padrão? (s/n): ', 's');
    if lower(resp) == 's'
        converter_mascaras_corrigido(config);
    end
    
    fprintf('\nConfiguração inicial concluída!\n');
end

function executar_teste_rapido()
    % Teste rápido para validar o pipeline
    
    fprintf('\n=== TESTE RÁPIDO ===\n');
    
    % Carregar configuração
    config = config_projeto();
    
    % Configurar para teste rápido
    config.numEpochs = config.quickTest.numEpochs;
    config.miniBatchSize = config.quickTest.miniBatchSize;
    config.inputSize = config.quickTest.inputSize;
    
    fprintf('Configuração de teste rápido:\n');
    fprintf('  Épocas: %d\n', config.numEpochs);
    fprintf('  Batch size: %d\n', config.miniBatchSize);
    fprintf('  Tamanho de entrada: %dx%dx%d\n', config.inputSize);
    
    % Criar datastore limitado
    ds = criar_datastore_com_augmentation(config.imageDir, config.maskDir, config);
    
    % Usar apenas primeiras amostras
    numSamples = min(config.quickTest.numSamples, length(ds.UnderlyingDatastores{1}.Files));
    ds = subset(ds, 1:numSamples);
    
    % Dividir dados
    [dsTrain, dsVal] = dividir_dados(ds, config.validationSplit);
    
    % Testar U-Net clássica
    fprintf('\nTestando U-Net clássica...\n');
    lgraphUNet = unetLayers(config.inputSize, config.numClasses, 'EncoderDepth', 3);
    [netUNet, ~] = treinar_modelo_rapido(dsTrain, dsVal, lgraphUNet, config);
    
    % Testar Attention U-Net
    fprintf('\nTestando Attention U-Net...\n');
    lgraphAttention = create_attention_unet_corrigida(config.inputSize, config.numClasses);
    [netAttention, ~] = treinar_modelo_rapido(dsTrain, dsVal, lgraphAttention, config);
    
    % Teste de predição
    fprintf('\nTestando predições...\n');
    testar_predicoes(netUNet, netAttention, dsVal);
    
    fprintf('\nTeste rápido concluído com sucesso!\n');
end

function executar_comparacao_basica()
    % Comparação básica com treinamento único
    
    fprintf('\n=== COMPARAÇÃO BÁSICA ===\n');
    
    % Carregar configuração
    config = config_projeto();
    
    % Criar datastore
    ds = criar_datastore_com_augmentation(config.imageDir, config.maskDir, config);
    
    % Dividir dados
    [dsTrain, dsVal] = dividir_dados(ds, config.validationSplit);
    
    fprintf('Iniciando comparação básica...\n');
    fprintf('Dados de treinamento: %d amostras\n', length(dsTrain.UnderlyingDatastores{1}.Files));
    fprintf('Dados de validação: %d amostras\n', length(dsVal.UnderlyingDatastores{1}.Files));
    
    % Treinar U-Net clássica
    fprintf('\n--- TREINANDO U-NET CLÁSSICA ---\n');
    startTime1 = datetime('now');
    [netUNet, infoUNet] = treinar_unet_classica(dsTrain, dsVal, config);
    endTime1 = datetime('now');
    tempoUNet = endTime1 - startTime1;
    
    % Treinar Attention U-Net
    fprintf('\n--- TREINANDO ATTENTION U-NET ---\n');
    startTime2 = datetime('now');
    [netAttention, infoAttention] = treinar_attention_unet(dsTrain, dsVal, config);
    endTime2 = datetime('now');
    tempoAttention = endTime2 - startTime2;
    
    % Avaliar modelos
    fprintf('\n--- AVALIANDO MODELOS ---\n');
    metricsUNet = calcular_metricas_completas(netUNet, dsVal, config);
    metricsAttention = calcular_metricas_completas(netAttention, dsVal, config);
    
    % Salvar modelos
    salvar_modelos(netUNet, netAttention, infoUNet, infoAttention, config);
    
    % Gerar relatório
    gerar_relatorio_comparacao(metricsUNet, metricsAttention, tempoUNet, tempoAttention, config);
    
    % Visualizar resultados
    visualizar_comparacao(netUNet, netAttention, dsVal, config);
    
    fprintf('\nComparação básica concluída!\n');
end

function executar_comparacao_avancada()
    % Comparação avançada com validação cruzada
    
    fprintf('\n=== COMPARAÇÃO AVANÇADA (VALIDAÇÃO CRUZADA) ===\n');
    
    % Carregar configuração
    config = config_projeto();
    
    % Configurar validação cruzada
    k = input('Número de folds para validação cruzada (recomendado: 5): ');
    if isempty(k) || k < 2
        k = 5;
    end
    
    fprintf('Executando validação cruzada %d-fold...\n', k);
    fprintf('ATENÇÃO: Este processo pode levar várias horas!\n');
    
    resp = input('Deseja continuar? (s/n): ', 's');
    if lower(resp) ~= 's'
        return;
    end
    
    % Executar validação cruzada
    resultados = validacao_cruzada_k_fold(config.imageDir, config.maskDir, config, k);
    
    % Gerar relatório avançado
    gerar_relatorio_validacao_cruzada(resultados, config);
    
    % Análise estatística
    realizar_analise_estatistica(resultados, config);
    
    fprintf('\nComparação avançada concluída!\n');
end

function executar_otimizacao_hiperparametros()
    % Otimização automática de hiperparâmetros
    
    fprintf('\n=== OTIMIZAÇÃO DE HIPERPARÂMETROS ===\n');
    
    % Carregar configuração
    config = config_projeto();
    
    fprintf('ATENÇÃO: A otimização de hiperparâmetros pode levar muito tempo!\n');
    fprintf('Recomenda-se executar em um subconjunto dos dados.\n');
    
    resp = input('Deseja continuar? (s/n): ', 's');
    if lower(resp) ~= 's'
        return;
    end
    
    % Executar otimização
    otimizar_hiperparametros(config.imageDir, config.maskDir, config);
    
    fprintf('\nOtimização de hiperparâmetros concluída!\n');
end

function executar_analise_completa()
    % Análise completa com todos os passos
    
    fprintf('\n=== ANÁLISE COMPLETA ===\n');
    
    fprintf('Esta opção executará:\n');
    fprintf('1. Configuração e teste de dados\n');
    fprintf('2. Teste rápido\n');
    fprintf('3. Comparação básica\n');
    fprintf('4. Validação cruzada 5-fold\n');
    fprintf('5. Relatórios detalhados\n');
    fprintf('\nTempo estimado: 4-8 horas (dependendo do hardware)\n');
    
    resp = input('\nDeseja continuar com a análise completa? (s/n): ', 's');
    if lower(resp) ~= 's'
        return;
    end
    
    % Executar todos os passos
    try
        fprintf('\n[1/5] Configuração inicial...\n');
        executar_configuracao_inicial();
        
        fprintf('\n[2/5] Teste rápido...\n');
        executar_teste_rapido();
        
        fprintf('\n[3/5] Comparação básica...\n');
        executar_comparacao_basica();
        
        fprintf('\n[4/5] Validação cruzada...\n');
        config = config_projeto();
        resultados = validacao_cruzada_k_fold(config.imageDir, config.maskDir, config, 5);
        
        fprintf('\n[5/5] Gerando relatório final...\n');
        gerar_relatorio_final_completo(resultados, config);
        
        fprintf('\n=== ANÁLISE COMPLETA FINALIZADA ===\n');
        fprintf('Todos os resultados foram salvos em: %s\n', config.outputDir);
        
    catch ME
        fprintf('\nErro durante análise completa: %s\n', ME.message);
        fprintf('Resultados parciais foram salvos.\n');
    end
end

function visualizar_resultados_salvos()
    % Visualizar resultados de execuções anteriores
    
    fprintf('\n=== VISUALIZAR RESULTADOS SALVOS ===\n');
    
    % Procurar arquivos de resultados
    resultFiles = dir('resultados_*.mat');
    
    if isempty(resultFiles)
        fprintf('Nenhum arquivo de resultados encontrado.\n');
        return;
    end
    
    fprintf('Arquivos de resultados encontrados:\n');
    for i = 1:length(resultFiles)
        fprintf('%d. %s\n', i, resultFiles(i).name);
    end
    
    escolha = input('\nEscolha um arquivo para visualizar: ');
    
    if escolha >= 1 && escolha <= length(resultFiles)
        filename = resultFiles(escolha).name;
        fprintf('Carregando %s...\n', filename);
        
        try
            data = load(filename);
            visualizar_dados_carregados(data);
        catch ME
            fprintf('Erro ao carregar arquivo: %s\n', ME.message);
        end
    else
        fprintf('Escolha inválida.\n');
    end
end

function [dsTrain, dsVal] = dividir_dados(ds, validationSplit)
    % Dividir dados em treinamento e validação
    
    numSamples = length(ds.UnderlyingDatastores{1}.Files);
    numTrain = round((1 - validationSplit) * numSamples);
    
    indices = randperm(numSamples);
    trainIndices = indices(1:numTrain);
    valIndices = indices(numTrain+1:end);
    
    dsTrain = subset(ds, trainIndices);
    dsVal = subset(ds, valIndices);
end

function [net, info] = treinar_modelo_rapido(dsTrain, dsVal, lgraph, config)
    % Treinamento rápido para testes
    
    options = trainingOptions('adam', ...
        'InitialLearnRate', config.initialLearningRate, ...
        'MaxEpochs', config.numEpochs, ...
        'MiniBatchSize', config.miniBatchSize, ...
        'ValidationData', dsVal, ...
        'ValidationFrequency', 5, ...
        'Plots', 'training-progress', ...
        'Verbose', true, ...
        'ExecutionEnvironment', 'auto');
    
    [net, info] = trainNetwork(dsTrain, lgraph, options);
end

function testar_predicoes(netUNet, netAttention, dsVal)
    % Testar predições dos modelos
    
    % Ler uma amostra
    reset(dsVal);
    data = read(dsVal);
    img = data{1};
    gt = data{2};
    
    % Fazer predições
    predUNet = semanticseg(img, netUNet);
    predAttention = semanticseg(img, netAttention);
    
    % Visualizar
    figure('Name', 'Teste de Predições', 'Position', [100 100 1400 400]);
    
    subplot(1,4,1);
    imshow(img);
    title('Imagem Original');
    
    subplot(1,4,2);
    imshow(gt, []);
    title('Ground Truth');
    
    subplot(1,4,3);
    imshow(labeloverlay(img, predUNet));
    title('Predição U-Net');
    
    subplot(1,4,4);
    imshow(labeloverlay(img, predAttention));
    title('Predição Attention U-Net');
    
    fprintf('Visualização de predições criada.\n');
end

function salvar_modelos(netUNet, netAttention, infoUNet, infoAttention, config)
    % Salvar modelos treinados
    
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    
    % Salvar U-Net
    filename_unet = fullfile(config.modelDir, sprintf('unet_classica_%s.mat', timestamp));
    save(filename_unet, 'netUNet', 'infoUNet');
    
    % Salvar Attention U-Net
    filename_attention = fullfile(config.modelDir, sprintf('attention_unet_%s.mat', timestamp));
    save(filename_attention, 'netAttention', 'infoAttention');
    
    fprintf('Modelos salvos:\n');
    fprintf('  U-Net: %s\n', filename_unet);
    fprintf('  Attention U-Net: %s\n', filename_attention);
end

function gerar_relatorio_comparacao(metricsUNet, metricsAttention, tempoUNet, tempoAttention, config)
    % Gerar relatório de comparação
    
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    filename = fullfile(config.outputDir, sprintf('relatorio_comparacao_%s.txt', timestamp));
    
    fid = fopen(filename, 'w');
    
    fprintf(fid, 'RELATÓRIO DE COMPARAÇÃO U-NET vs ATTENTION U-NET\n');
    fprintf(fid, '================================================\n\n');
    fprintf(fid, 'Data: %s\n\n', datestr(now));
    
    fprintf(fid, 'CONFIGURAÇÃO:\n');
    fprintf(fid, '  Tamanho de entrada: %dx%dx%d\n', config.inputSize);
    fprintf(fid, '  Épocas: %d\n', config.numEpochs);
    fprintf(fid, '  Batch size: %d\n', config.miniBatchSize);
    fprintf(fid, '  Data augmentation: %s\n\n', config.useDataAugmentation ? 'Sim' : 'Não');
    
    fprintf(fid, 'RESULTADOS U-NET CLÁSSICA:\n');
    fprintf(fid, '  Tempo de treinamento: %s\n', duration2str(tempoUNet));
    fprintf(fid, '  Acurácia: %.4f\n', metricsUNet.basic.accuracy);
    fprintf(fid, '  IoU médio: %.4f ± %.4f\n', metricsUNet.segmentation.meanIoU, metricsUNet.segmentation.stdIoU);
    fprintf(fid, '  Dice médio: %.4f ± %.4f\n\n', metricsUNet.segmentation.meanDice, metricsUNet.segmentation.stdDice);
    
    fprintf(fid, 'RESULTADOS ATTENTION U-NET:\n');
    fprintf(fid, '  Tempo de treinamento: %s\n', duration2str(tempoAttention));
    fprintf(fid, '  Acurácia: %.4f\n', metricsAttention.basic.accuracy);
    fprintf(fid, '  IoU médio: %.4f ± %.4f\n', metricsAttention.segmentation.meanIoU, metricsAttention.segmentation.stdIoU);
    fprintf(fid, '  Dice médio: %.4f ± %.4f\n\n', metricsAttention.segmentation.meanDice, metricsAttention.segmentation.stdDice);
    
    % Comparação
    melhorIoU = metricsAttention.segmentation.meanIoU > metricsUNet.segmentation.meanIoU;
    melhorDice = metricsAttention.segmentation.meanDice > metricsUNet.segmentation.meanDice;
    
    fprintf(fid, 'COMPARAÇÃO:\n');
    fprintf(fid, '  Melhor IoU: %s\n', melhorIoU ? 'Attention U-Net' : 'U-Net Clássica');
    fprintf(fid, '  Melhor Dice: %s\n', melhorDice ? 'Attention U-Net' : 'U-Net Clássica');
    
    fclose(fid);
    
    fprintf('Relatório salvo em: %s\n', filename);
end

function visualizar_comparacao(netUNet, netAttention, dsVal, config)
    % Visualizar comparação entre modelos
    
    % Criar figura de comparação
    figure('Name', 'Comparação de Modelos', 'Position', [100 100 1600 800]);
    
    % Testar em algumas amostras
    reset(dsVal);
    for i = 1:min(3, length(dsVal.UnderlyingDatastores{1}.Files))
        data = read(dsVal);
        img = data{1};
        gt = data{2};
        
        predUNet = semanticseg(img, netUNet);
        predAttention = semanticseg(img, netAttention);
        
        % Subplot para esta amostra
        subplot(3, 4, (i-1)*4 + 1);
        imshow(img);
        title(sprintf('Amostra %d - Original', i));
        
        subplot(3, 4, (i-1)*4 + 2);
        imshow(gt, []);
        title('Ground Truth');
        
        subplot(3, 4, (i-1)*4 + 3);
        imshow(labeloverlay(img, predUNet));
        title('U-Net Clássica');
        
        subplot(3, 4, (i-1)*4 + 4);
        imshow(labeloverlay(img, predAttention));
        title('Attention U-Net');
    end
    
    % Salvar figura
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    filename = fullfile(config.plotDir, sprintf('comparacao_visual_%s.png', timestamp));
    saveas(gcf, filename);
    
    fprintf('Comparação visual salva em: %s\n', filename);
end

function str = duration2str(dur)
    % Converter duration para string legível
    h = hours(dur);
    m = minutes(dur) - h*60;
    s = seconds(dur) - h*3600 - m*60;
    str = sprintf('%02d:%02d:%02.0f', floor(h), floor(m), s);
end

function gerar_relatorio_validacao_cruzada(resultados, config)
    % Gerar relatório da validação cruzada
    
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    filename = fullfile(config.outputDir, sprintf('relatorio_validacao_cruzada_%s.txt', timestamp));
    
    fid = fopen(filename, 'w');
    
    fprintf(fid, 'RELATÓRIO DE VALIDAÇÃO CRUZADA\n');
    fprintf(fid, '==============================\n\n');
    fprintf(fid, 'Data: %s\n', datestr(now));
    fprintf(fid, 'Número de folds: %d\n\n', length(resultados.folds));
    
    fprintf(fid, 'RESULTADOS POR FOLD:\n');
    for i = 1:length(resultados.folds)
        fprintf(fid, 'Fold %d:\n', i);
        fprintf(fid, '  U-Net IoU: %.4f\n', resultados.folds{i}.unet.segmentation.meanIoU);
        fprintf(fid, '  Attention IoU: %.4f\n\n', resultados.folds{i}.attention.segmentation.meanIoU);
    end
    
    fprintf(fid, 'RESULTADOS FINAIS:\n');
    fprintf(fid, 'U-Net Clássica - IoU: %.4f ± %.4f\n', resultados.unet_mean, resultados.unet_std);
    fprintf(fid, 'Attention U-Net - IoU: %.4f ± %.4f\n\n', resultados.attention_mean, resultados.attention_std);
    
    fprintf(fid, 'TESTE ESTATÍSTICO:\n');
    fprintf(fid, 'p-value: %.4f\n', resultados.statistical_test.p);
    fprintf(fid, 'Significativo (α=0.05): %s\n', resultados.statistical_test.h ? 'Sim' : 'Não');
    
    fclose(fid);
    
    fprintf('Relatório de validação cruzada salvo em: %s\n', filename);
end

function realizar_analise_estatistica(resultados, config)
    % Realizar análise estatística dos resultados
    
    % Criar boxplot
    figure('Name', 'Análise Estatística', 'Position', [100 100 800 600]);
    
    data = [resultados.unet_metrics, resultados.attention_metrics];
    groups = [ones(size(resultados.unet_metrics)); 2*ones(size(resultados.attention_metrics))];
    
    boxplot(data, groups, 'Labels', {'U-Net Clássica', 'Attention U-Net'});
    ylabel('IoU');
    title('Distribuição dos Resultados de IoU');
    grid on;
    
    % Salvar gráfico
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    filename = fullfile(config.plotDir, sprintf('analise_estatistica_%s.png', timestamp));
    saveas(gcf, filename);
    
    fprintf('Análise estatística salva em: %s\n', filename);
end

function gerar_relatorio_final_completo(resultados, config)
    % Gerar relatório final completo
    
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    filename = fullfile(config.outputDir, sprintf('relatorio_final_completo_%s.html', timestamp));
    
    fid = fopen(filename, 'w');
    
    fprintf(fid, '<html><head><title>Relatório Final - Comparação U-Net vs Attention U-Net</title></head><body>\n');
    fprintf(fid, '<h1>Relatório Final - Comparação U-Net vs Attention U-Net</h1>\n');
    fprintf(fid, '<p>Data: %s</p>\n', datestr(now));
    
    fprintf(fid, '<h2>Resumo Executivo</h2>\n');
    fprintf(fid, '<p>Este relatório apresenta os resultados da comparação entre U-Net clássica e Attention U-Net.</p>\n');
    
    fprintf(fid, '<h2>Resultados da Validação Cruzada</h2>\n');
    fprintf(fid, '<table border="1">\n');
    fprintf(fid, '<tr><th>Modelo</th><th>IoU Médio</th><th>Desvio Padrão</th></tr>\n');
    fprintf(fid, '<tr><td>U-Net Clássica</td><td>%.4f</td><td>%.4f</td></tr>\n', resultados.unet_mean, resultados.unet_std);
    fprintf(fid, '<tr><td>Attention U-Net</td><td>%.4f</td><td>%.4f</td></tr>\n', resultados.attention_mean, resultados.attention_std);
    fprintf(fid, '</table>\n');
    
    fprintf(fid, '<h2>Conclusões</h2>\n');
    if resultados.attention_mean > resultados.unet_mean
        fprintf(fid, '<p>A Attention U-Net apresentou melhor performance que a U-Net clássica.</p>\n');
    else
        fprintf(fid, '<p>A U-Net clássica apresentou melhor performance que a Attention U-Net.</p>\n');
    end
    
    fprintf(fid, '</body></html>\n');
    fclose(fid);
    
    fprintf('Relatório final completo salvo em: %s\n', filename);
end

function visualizar_dados_carregados(data)
    % Visualizar dados carregados de arquivo
    
    fields = fieldnames(data);
    fprintf('\nCampos disponíveis no arquivo:\n');
    for i = 1:length(fields)
        fprintf('  %s\n', fields{i});
    end
    
    % Tentar exibir informações relevantes
    if isfield(data, 'resultados')
        res = data.resultados;
        if isfield(res, 'unet_mean')
            fprintf('\nResultados da validação cruzada:\n');
            fprintf('U-Net: %.4f ± %.4f\n', res.unet_mean, res.unet_std);
            fprintf('Attention U-Net: %.4f ± %.4f\n', res.attention_mean, res.attention_std);
        end
    end
end

function testar_dados_segmentacao_corrigido(config)
    % Versão corrigida do teste de dados
    
    fprintf('Testando dados de segmentação...\n');
    
    % Verificar arquivos
    imageFiles = [dir(fullfile(config.imageDir, '*.png')); dir(fullfile(config.imageDir, '*.jpg')); dir(fullfile(config.imageDir, '*.jpeg'))];
    maskFiles = [dir(fullfile(config.maskDir, '*.png')); dir(fullfile(config.maskDir, '*.jpg')); dir(fullfile(config.maskDir, '*.jpeg'))];
    
    fprintf('Imagens encontradas: %d\n', length(imageFiles));
    fprintf('Máscaras encontradas: %d\n', length(maskFiles));
    
    if isempty(imageFiles) || isempty(maskFiles)
        error('Nenhuma imagem ou máscara encontrada!');
    end
    
    % Testar primeira imagem e máscara
    img = imread(fullfile(config.imageDir, imageFiles(1).name));
    mask = imread(fullfile(config.maskDir, maskFiles(1).name));
    
    fprintf('Primeira imagem: %dx%dx%d\n', size(img,1), size(img,2), size(img,3));
    fprintf('Primeira máscara: %dx%d\n', size(mask,1), size(mask,2));
    
    if size(mask,3) > 1
        mask = rgb2gray(mask);
    end
    
    uniqueVals = unique(mask(:));
    fprintf('Valores únicos na máscara: ');
    fprintf('%d ', uniqueVals);
    fprintf('\n');
    
    fprintf('Teste de dados concluído!\n');
end

function converter_mascaras_corrigido(config)
    % Versão corrigida do conversor de máscaras
    
    fprintf('Convertendo máscaras...\n');
    
    outputDir = fullfile(fileparts(config.maskDir), 'masks_converted');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    maskFiles = [dir(fullfile(config.maskDir, '*.png')); dir(fullfile(config.maskDir, '*.jpg')); dir(fullfile(config.maskDir, '*.jpeg'))];
    
    for i = 1:length(maskFiles)
        mask = imread(fullfile(config.maskDir, maskFiles(i).name));
        
        if size(mask, 3) > 1
            mask = rgb2gray(mask);
        end
        
        % Binarizar
        uniqueVals = unique(mask(:));
        if length(uniqueVals) > 2
            threshold = mean(double(uniqueVals));
            mask = mask > threshold;
        else
            mask = mask == max(uniqueVals);
        end
        
        % Converter para 0 e 255
        mask = uint8(mask) * 255;
        
        % Salvar
        outputPath = fullfile(outputDir, maskFiles(i).name);
        imwrite(mask, outputPath);
        
        if mod(i, 10) == 0
            fprintf('Convertidas: %d/%d\n', i, length(maskFiles));
        end
    end
    
    fprintf('Conversão concluída! Máscaras salvas em: %s\n', outputDir);
    
    % Atualizar configuração
    resp = input('Deseja usar as máscaras convertidas? (s/n): ', 's');
    if lower(resp) == 's'
        config.maskDir = outputDir;
        save('config_caminhos.mat', 'config');
        fprintf('Configuração atualizada.\n');
    end
end

