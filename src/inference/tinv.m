function t = tinv(p, df)
    % Quantil da distribuição t de Student (aproximação)
    z = norminv(p);
    
    % Correção para distribuição t
    if df > 30
        t = z;
    else
        t = z * (1 + (z^2 + 1)/(4*df));
    end
end