function [classNames, labelIDs] = analisar_mascaras_automatico(maskDir, masks)
    % ========================================================================
    % ANALISADOR AUTOMÁTICO DE MÁSCARAS - PROJETO U-NET vs ATTENTION U-NET
    % ========================================================================
    % 
    % AUTOR: Heitor Oliveira Gonçalves
    % LinkedIn: https://www.linkedin.com/in/heitorhog/
    % Data: Julho 2025
    % Versão: 1.2 Final
    %
    % DESCRIÇÃO:
    %   Analisar máscaras automaticamente para determinar formato e classes
    % ========================================================================
    
    fprintf('Analisando formato das máscaras...\n');
    
    % Analisar algumas máscaras para determinar formato
    numCheck = min(10, length(masks));
    allValues = [];
    
    for i = 1:numCheck
        if iscell(masks)
            maskPath = masks{i};
        else
            maskPath = fullfile(maskDir, masks(i).name);
        end
        
        mask = imread(maskPath);
        
        % Converter para escala de cinza se necessário
        if size(mask, 3) > 1
            mask = rgb2gray(mask);
        end
        
        vals = unique(mask(:));
        allValues = unique([allValues; vals]);
    end
    
    fprintf('Valores únicos encontrados: ');
    if length(allValues) <= 20
        fprintf('%d ', allValues);
    else
        fprintf('%d ', allValues(1:10));
        fprintf('... (%d total)', length(allValues));
    end
    fprintf('\n');
    
    % Determinar classes e labelIDs
    if length(allValues) == 2 && all(ismember(allValues, [0, 255]))
        % Já está binarizado corretamente
        labelIDs = [0, 255];
    elseif length(allValues) == 2
        % Binário mas com valores diferentes
        labelIDs = sort(allValues);
    else
        % Precisa binarização
        fprintf('Máscaras serão binarizadas (threshold: %.2f)\n', mean(double(allValues)));
        labelIDs = [0, 1];
    end
    
    classNames = ["background", "foreground"];
end
