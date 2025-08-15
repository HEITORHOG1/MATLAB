function [h, p] = ttest2(x, y)
    % Teste t de Student para duas amostras independentes (simplificado)
    
    x = x(~isnan(x));
    y = y(~isnan(y));
    
    if length(x) < 2 || length(y) < 2
        h = 0;
        p = 1;
        return;
    end
    
    % Teste t de Welch (variâncias desiguais)
    n1 = length(x);
    n2 = length(y);
    
    mean1 = mean(x);
    mean2 = mean(y);
    
    var1 = var(x);
    var2 = var(y);
    
    % Estatística t
    t = (mean1 - mean2) / sqrt(var1/n1 + var2/n2);
    
    % Graus de liberdade (aproximação de Welch)
    df = (var1/n1 + var2/n2)^2 / ((var1/n1)^2/(n1-1) + (var2/n2)^2/(n2-1));
    
    % P-value (aproximação usando distribuição normal para simplificar)
    p = 2 * (1 - normcdf(abs(t)));
    
    h = p < 0.05;
end