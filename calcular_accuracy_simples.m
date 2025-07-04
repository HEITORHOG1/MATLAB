function acc = calcular_accuracy_simples(pred, gt)
    % Calcular acurácia pixel-wise - Versão Final
    
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
        
        % Calcular acurácia
        correct = sum(predBinary(:) == gtBinary(:));
        total = numel(predBinary);
        
        acc = correct / total;
    catch
        acc = 0; % Erro no cálculo
    end
end
