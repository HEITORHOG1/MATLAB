function metricas = calcular_precision_recall_f1(pred, gt)
    % ========================================================================
    % CÁLCULO DE PRECISION, RECALL E F1-SCORE - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Agosto 2025
    % Versão: 1.0
    %
    % DESCRIÇÃO:
    %   Calcula precision, recall e F1-score para segmentação binária
    %
    % ENTRADA:
    %   pred - Predição do modelo (matriz ou categorical)
    %   gt   - Ground truth (matriz ou categorical)
    %
    % SAÍDA:
    %   metricas - Struct com precision, recall e f1_score
    % ========================================================================
    
    try
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
        
        % Calcular True Positives, False Positives, False Negatives
        TP = sum(predBinary(:) & gtBinary(:));
        FP = sum(predBinary(:) & ~gtBinary(:));
        FN = sum(~predBinary(:) & gtBinary(:));
        
        % Calcular Precision
        if (TP + FP) == 0
            precision = 0; % Nenhuma predição positiva
        else
            precision = TP / (TP + FP);
        end
        
        % Calcular Recall
        if (TP + FN) == 0
            recall = 1; % Nenhum positivo real (caso especial)
        else
            recall = TP / (TP + FN);
        end
        
        % Calcular F1-Score
        if (precision + recall) == 0
            f1_score = 0;
        else
            f1_score = 2 * (precision * recall) / (precision + recall);
        end
        
        % Retornar métricas
        metricas = struct();
        metricas.precision = precision;
        metricas.recall = recall;
        metricas.f1_score = f1_score;
        metricas.true_positives = TP;
        metricas.false_positives = FP;
        metricas.false_negatives = FN;
        
    catch ME
        % Em caso de erro, retornar zeros
        metricas = struct();
        metricas.precision = 0;
        metricas.recall = 0;
        metricas.f1_score = 0;
        metricas.true_positives = 0;
        metricas.false_positives = 0;
        metricas.false_negatives = 0;
        metricas.erro = ME.message;
    end
end