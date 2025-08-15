function x = norminv(p)
    % Quantil da distribuição normal padrão (aproximação)
    if p <= 0
        x = -Inf;
    elseif p >= 1
        x = Inf;
    elseif p == 0.5
        x = 0;
    else
        if p < 0.5
            sign = -1;
            p = 1 - p;
        else
            sign = 1;
        end
        
        t = sqrt(-2 * log(1 - p));
        x = t - (2.30753 + 0.27061*t) / (1 + 0.99229*t + 0.04481*t^2);
        x = x * sign;
    end
end