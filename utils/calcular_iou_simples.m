function iou = calcular_iou_simples(pred, gt)
    % ========================================================================
    % CÁLCULO DE IoU - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 1.2 Final
    %
    % DESCRIÇÃO:
    %   Calcular IoU (Intersection over Union) - Versão Final
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
        
        % Calcular IoU
        intersection = sum(predBinary(:) & gtBinary(:));
        union = sum(predBinary(:) | gtBinary(:));
        
        if union == 0
            iou = 1; % Ambos são vazios
        else
            iou = intersection / union;
        end
    catch
        iou = 0; % Erro no cálculo
    end
end
