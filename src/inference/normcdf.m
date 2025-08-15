function p = normcdf(x)
    % CDF da distribuição normal padrão (simplificada)
    p = 0.5 * (1 + erf(x / sqrt(2)));
end