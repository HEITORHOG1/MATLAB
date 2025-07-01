function metricas_avancadas()
    % MÉTRICAS AVANÇADAS PARA SEGMENTAÇÃO DE IMAGENS
    % 
    % Este arquivo contém funções para calcular métricas específicas
    % de segmentação que vão além da acurácia básica.
end

function metrics = calcular_metricas_completas(net, datastore, config)
    % Calcular conjunto completo de métricas para segmentação
    
    fprintf('\n=== CALCULANDO MÉTRICAS AVANÇADAS ===\n');
    
    % Inicializar estrutura de métricas
    metrics = struct();
    metrics.timestamp = datetime('now');
    
    % Coletar predições e ground truth
    fprintf('Coletando predições...\n');
    [predictions, groundTruth, images] = collect_predictions(net, datastore, config);
    
    % Calcular métricas básicas
    fprintf('Calculando métricas básicas...\n');
    metrics.basic = calcular_metricas_basicas(predictions, groundTruth);
    
    % Calcular métricas específicas de segmentação
    fprintf('Calculando métricas de segmentação...\n');
    metrics.segmentation = calcular_metricas_segmentacao(predictions, groundTruth);
    
    % Calcular métricas por classe
    fprintf('Calculando métricas por classe...\n');
    metrics.perClass = calcular_metricas_por_classe(predictions, groundTruth);
    
    % Análise de distribuição de erros
    fprintf('Analisando distribuição de erros...\n');
    metrics.errorAnalysis = analisar_distribuicao_erros(predictions, groundTruth, images);
    
    % Métricas de confiança
    fprintf('Calculando métricas de confiança...\n');
    metrics.confidence = calcular_metricas_confianca(net, datastore, config);
    
    fprintf('Métricas calculadas com sucesso!\n');
    
    % Exibir resumo
    exibir_resumo_metricas(metrics);
end

function [predictions, groundTruth, images] = collect_predictions(net, datastore, config)
    % Coletar todas as predições e ground truth
    
    predictions = {};
    groundTruth = {};
    images = {};
    
    % Reset datastore
    reset(datastore);
    
    i = 1;
    while hasdata(datastore)
        data = read(datastore);
        img = data{1};
        gt = data{2};
        
        % Fazer predição
        pred = semanticseg(img, net);
        
        % Armazenar
        predictions{i} = pred;
        groundTruth{i} = gt;
        images{i} = img;
        
        if mod(i, 10) == 0
            fprintf('  Processadas: %d amostras\n', i);
        end
        
        i = i + 1;
    end
    
    fprintf('Total de amostras processadas: %d\n', length(predictions));
end

function metrics = calcular_metricas_basicas(predictions, groundTruth)
    % Calcular métricas básicas (acurácia, precisão, recall, F1)
    
    metrics = struct();
    
    % Converter para arrays se necessário
    allPred = [];
    allGT = [];
    
    for i = 1:length(predictions)
        pred = predictions{i};
        gt = groundTruth{i};
        
        % Converter categorical para numeric se necessário
        if iscategorical(pred)
            pred = double(pred) - 1;  % Assumindo classes 0 e 1
        end
        if iscategorical(gt)
            gt = double(gt) - 1;
        end
        
        allPred = [allPred; pred(:)];
        allGT = [allGT; gt(:)];
    end
    
    % Calcular matriz de confusão
    try
        metrics.confusionMatrix = confusionmat(allGT, allPred);
        
        % Extrair TP, TN, FP, FN para classe positiva (assumindo classe 1)
        if size(metrics.confusionMatrix, 1) >= 2
            TP = metrics.confusionMatrix(2, 2);
            TN = metrics.confusionMatrix(1, 1);
            FP = metrics.confusionMatrix(1, 2);
            FN = metrics.confusionMatrix(2, 1);
            
            % Calcular métricas
            metrics.accuracy = (TP + TN) / (TP + TN + FP + FN);
            metrics.precision = TP / (TP + FP + eps);
            metrics.recall = TP / (TP + FN + eps);
            metrics.specificity = TN / (TN + FP + eps);
            metrics.f1Score = 2 * (metrics.precision * metrics.recall) / ...
                             (metrics.precision + metrics.recall + eps);
            
            % Balanced accuracy
            metrics.balancedAccuracy = (metrics.recall + metrics.specificity) / 2;
        else
            metrics.accuracy = sum(allPred == allGT) / length(allGT);
            metrics.precision = NaN;
            metrics.recall = NaN;
            metrics.specificity = NaN;
            metrics.f1Score = NaN;
            metrics.balancedAccuracy = NaN;
        end
    catch
        % Fallback para acurácia simples
        metrics.accuracy = sum(allPred == allGT) / length(allGT);
        metrics.confusionMatrix = [];
        metrics.precision = NaN;
        metrics.recall = NaN;
        metrics.specificity = NaN;
        metrics.f1Score = NaN;
        metrics.balancedAccuracy = NaN;
    end
end

function metrics = calcular_metricas_segmentacao(predictions, groundTruth)
    % Calcular métricas específicas de segmentação (IoU, Dice, etc.)
    
    metrics = struct();
    
    ious = [];
    dices = [];
    hausdorffDistances = [];
    
    for i = 1:length(predictions)
        pred = predictions{i};
        gt = groundTruth{i};
        
        % Converter para lógico se necessário
        if iscategorical(pred)
            predBinary = double(pred) > 1;  % Assumindo background=1, foreground=2
        else
            predBinary = pred > 0;
        end
        
        if iscategorical(gt)
            gtBinary = double(gt) > 1;
        else
            gtBinary = gt > 0;
        end
        
        % Calcular IoU (Jaccard Index)
        intersection = sum(predBinary(:) & gtBinary(:));
        union = sum(predBinary(:) | gtBinary(:));
        iou = intersection / (union + eps);
        ious = [ious; iou];
        
        % Calcular Dice Coefficient
        dice = 2 * intersection / (sum(predBinary(:)) + sum(gtBinary(:)) + eps);
        dices = [dices; dice];
        
        % Calcular Hausdorff Distance (simplificado)
        try
            hd = calcular_hausdorff_distance(predBinary, gtBinary);
            hausdorffDistances = [hausdorffDistances; hd];
        catch
            hausdorffDistances = [hausdorffDistances; NaN];
        end
    end
    
    % Estatísticas das métricas
    metrics.meanIoU = mean(ious);
    metrics.stdIoU = std(ious);
    metrics.medianIoU = median(ious);
    
    metrics.meanDice = mean(dices);
    metrics.stdDice = std(dices);
    metrics.medianDice = median(dices);
    
    metrics.meanHausdorff = mean(hausdorffDistances, 'omitnan');
    metrics.stdHausdorff = std(hausdorffDistances, 'omitnan');
    
    % Armazenar valores individuais para análise posterior
    metrics.allIoUs = ious;
    metrics.allDices = dices;
    metrics.allHausdorff = hausdorffDistances;
end

function hd = calcular_hausdorff_distance(pred, gt)
    % Calcular distância de Hausdorff simplificada
    
    % Encontrar bordas
    predEdge = edge(pred, 'canny');
    gtEdge = edge(gt, 'canny');
    
    % Encontrar coordenadas dos pixels de borda
    [predY, predX] = find(predEdge);
    [gtY, gtX] = find(gtEdge);
    
    if isempty(predY) || isempty(gtY)
        hd = Inf;
        return;
    end
    
    % Calcular distâncias
    predCoords = [predX, predY];
    gtCoords = [gtX, gtY];
    
    % Distância de cada ponto de pred para o mais próximo em gt
    dist1 = min(pdist2(predCoords, gtCoords), [], 2);
    
    % Distância de cada ponto de gt para o mais próximo em pred
    dist2 = min(pdist2(gtCoords, predCoords), [], 2);
    
    % Hausdorff distance é o máximo das distâncias máximas
    hd = max([max(dist1), max(dist2)]);
end

function metrics = calcular_metricas_por_classe(predictions, groundTruth)
    % Calcular métricas separadamente para cada classe
    
    metrics = struct();
    
    % Determinar número de classes
    allClasses = [];
    for i = 1:length(groundTruth)
        gt = groundTruth{i};
        if iscategorical(gt)
            classes = double(gt(:));
        else
            classes = gt(:);
        end
        allClasses = [allClasses; classes];
    end
    
    uniqueClasses = unique(allClasses);
    numClasses = length(uniqueClasses);
    
    metrics.classes = uniqueClasses;
    metrics.numClasses = numClasses;
    
    % Calcular métricas para cada classe
    for c = 1:numClasses
        className = sprintf('class_%d', uniqueClasses(c));
        
        classIoUs = [];
        classDices = [];
        
        for i = 1:length(predictions)
            pred = predictions{i};
            gt = groundTruth{i};
            
            % Converter para binário para esta classe
            if iscategorical(pred)
                predClass = double(pred) == uniqueClasses(c);
            else
                predClass = pred == uniqueClasses(c);
            end
            
            if iscategorical(gt)
                gtClass = double(gt) == uniqueClasses(c);
            else
                gtClass = gt == uniqueClasses(c);
            end
            
            % Calcular IoU para esta classe
            intersection = sum(predClass(:) & gtClass(:));
            union = sum(predClass(:) | gtClass(:));
            iou = intersection / (union + eps);
            classIoUs = [classIoUs; iou];
            
            % Calcular Dice para esta classe
            dice = 2 * intersection / (sum(predClass(:)) + sum(gtClass(:)) + eps);
            classDices = [classDices; dice];
        end
        
        metrics.(className).meanIoU = mean(classIoUs);
        metrics.(className).meanDice = mean(classDices);
        metrics.(className).stdIoU = std(classIoUs);
        metrics.(className).stdDice = std(classDices);
    end
end

function metrics = analisar_distribuicao_erros(predictions, groundTruth, images)
    % Analisar distribuição espacial e características dos erros
    
    metrics = struct();
    
    falsePositives = [];
    falseNegatives = [];
    errorSizes = [];
    
    for i = 1:length(predictions)
        pred = predictions{i};
        gt = groundTruth{i};
        
        % Converter para binário
        if iscategorical(pred)
            predBinary = double(pred) > 1;
        else
            predBinary = pred > 0;
        end
        
        if iscategorical(gt)
            gtBinary = double(gt) > 1;
        else
            gtBinary = gt > 0;
        end
        
        % Identificar erros
        fp = predBinary & ~gtBinary;  % False positives
        fn = ~predBinary & gtBinary;  % False negatives
        
        falsePositives = [falsePositives; sum(fp(:))];
        falseNegatives = [falseNegatives; sum(fn(:))];
        
        % Tamanho dos erros (componentes conectados)
        fpComponents = bwconncomp(fp);
        fnComponents = bwconncomp(fn);
        
        fpSizes = cellfun(@length, fpComponents.PixelIdxList);
        fnSizes = cellfun(@length, fnComponents.PixelIdxList);
        
        errorSizes = [errorSizes; fpSizes(:); fnSizes(:)];
    end
    
    metrics.meanFalsePositives = mean(falsePositives);
    metrics.meanFalseNegatives = mean(falseNegatives);
    metrics.stdFalsePositives = std(falsePositives);
    metrics.stdFalseNegatives = std(falseNegatives);
    
    metrics.meanErrorSize = mean(errorSizes);
    metrics.medianErrorSize = median(errorSizes);
    metrics.maxErrorSize = max(errorSizes);
    
    % Distribuição de tamanhos de erro
    metrics.errorSizeDistribution = errorSizes;
end

function metrics = calcular_metricas_confianca(net, datastore, config)
    % Calcular métricas relacionadas à confiança das predições
    
    metrics = struct();
    
    % Esta é uma implementação simplificada
    % Em uma implementação completa, seria necessário modificar a rede
    % para retornar probabilidades em vez de classes
    
    confidenceScores = [];
    uncertainties = [];
    
    reset(datastore);
    i = 1;
    
    while hasdata(datastore) && i <= 20  % Limitar para não demorar muito
        data = read(datastore);
        img = data{1};
        
        try
            % Tentar obter scores de confiança
            % Nota: Isso requer modificação da rede para retornar probabilidades
            pred = semanticseg(img, net);
            
            % Calcular uma medida de confiança simplificada
            % baseada na consistência espacial
            confidence = calcular_confianca_espacial(pred);
            confidenceScores = [confidenceScores; confidence];
            
        catch
            % Se não conseguir calcular confiança, pular
            continue;
        end
        
        i = i + 1;
    end
    
    if ~isempty(confidenceScores)
        metrics.meanConfidence = mean(confidenceScores);
        metrics.stdConfidence = std(confidenceScores);
        metrics.minConfidence = min(confidenceScores);
        metrics.maxConfidence = max(confidenceScores);
    else
        metrics.meanConfidence = NaN;
        metrics.stdConfidence = NaN;
        metrics.minConfidence = NaN;
        metrics.maxConfidence = NaN;
    end
end

function confidence = calcular_confianca_espacial(pred)
    % Calcular confiança baseada na consistência espacial
    
    if iscategorical(pred)
        predNumeric = double(pred);
    else
        predNumeric = pred;
    end
    
    % Calcular gradiente para medir consistência
    [Gx, Gy] = gradient(double(predNumeric));
    gradientMagnitude = sqrt(Gx.^2 + Gy.^2);
    
    % Confiança inversamente proporcional ao gradiente médio
    confidence = 1 / (1 + mean(gradientMagnitude(:)));
end

function exibir_resumo_metricas(metrics)
    % Exibir resumo das métricas calculadas
    
    fprintf('\n=== RESUMO DAS MÉTRICAS ===\n');
    
    % Métricas básicas
    if isfield(metrics, 'basic')
        fprintf('\nMétricas Básicas:\n');
        fprintf('  Acurácia: %.4f\n', metrics.basic.accuracy);
        if ~isnan(metrics.basic.precision)
            fprintf('  Precisão: %.4f\n', metrics.basic.precision);
            fprintf('  Recall: %.4f\n', metrics.basic.recall);
            fprintf('  F1-Score: %.4f\n', metrics.basic.f1Score);
            fprintf('  Acurácia Balanceada: %.4f\n', metrics.basic.balancedAccuracy);
        end
    end
    
    % Métricas de segmentação
    if isfield(metrics, 'segmentation')
        fprintf('\nMétricas de Segmentação:\n');
        fprintf('  IoU Médio: %.4f ± %.4f\n', metrics.segmentation.meanIoU, metrics.segmentation.stdIoU);
        fprintf('  Dice Médio: %.4f ± %.4f\n', metrics.segmentation.meanDice, metrics.segmentation.stdDice);
        if ~isnan(metrics.segmentation.meanHausdorff)
            fprintf('  Hausdorff Médio: %.2f ± %.2f\n', metrics.segmentation.meanHausdorff, metrics.segmentation.stdHausdorff);
        end
    end
    
    % Análise de erros
    if isfield(metrics, 'errorAnalysis')
        fprintf('\nAnálise de Erros:\n');
        fprintf('  Falsos Positivos Médios: %.1f ± %.1f\n', ...
                metrics.errorAnalysis.meanFalsePositives, metrics.errorAnalysis.stdFalsePositives);
        fprintf('  Falsos Negativos Médios: %.1f ± %.1f\n', ...
                metrics.errorAnalysis.meanFalseNegatives, metrics.errorAnalysis.stdFalseNegatives);
        fprintf('  Tamanho Médio de Erro: %.1f pixels\n', metrics.errorAnalysis.meanErrorSize);
    end
    
    % Métricas de confiança
    if isfield(metrics, 'confidence') && ~isnan(metrics.confidence.meanConfidence)
        fprintf('\nMétricas de Confiança:\n');
        fprintf('  Confiança Média: %.4f ± %.4f\n', ...
                metrics.confidence.meanConfidence, metrics.confidence.stdConfidence);
    end
    
    fprintf('\n========================\n');
end

