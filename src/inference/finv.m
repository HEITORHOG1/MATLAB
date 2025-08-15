function f = finv(p, df1, df2)
    % Quantil da distribuição F (aproximação simples)
    if p < 0.5
        f = 1;
    else
        f = 2 + (p - 0.5) * 4;
    end
end