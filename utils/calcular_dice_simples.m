function dice = calcular_dice_simples(pred, gt)
    % ========================================================================
    % CÁLCULO DE DICE - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 1.2 Final
    %
    % DESCRIÇÃO:
    %   Calcular coeficiente Dice - Versão Final
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
        
        % Calcular Dice
        intersection = sum(predBinary(:) & gtBinary(:));
        total = sum(predBinary(:)) + sum(gtBinary(:));
        
        if total == 0
            dice = 1; % Ambos são vazios
        else
            dice = 2 * intersection / total;
        end
    catch
        dice = 0; % Erro no cálculo
    end
end
