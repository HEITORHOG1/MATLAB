function acc = calcular_accuracy_simples(pred, gt)
    % ========================================================================
    % CÁLCULO DE ACCURACY - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 1.2 Final
    %
    % DESCRIÇÃO:
    %   Calcular acurácia pixel-wise - Versão Final
    % ========================================================================
    
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
