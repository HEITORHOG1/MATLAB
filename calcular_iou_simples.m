function iou = calcular_iou_simples(pred, gt)
    % Calcular IoU (Intersection over Union) - Versão Final
    
    try
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
