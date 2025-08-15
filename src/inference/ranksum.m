function p = ranksum(x, y)
    % Teste de Mann-Whitney U (Wilcoxon rank-sum) simplificado
    
    x = x(~isnan(x));
    y = y(~isnan(y));
    
    if length(x) < 1 || length(y) < 1
        p = 1;
        return;
    end
    
    % Combinar e ranquear
    combined = [x(:); y(:)];
    [~, ranks] = sort(combined);
    ranks(ranks) = 1:length(combined);
    
    % Soma dos ranks do primeiro grupo
    R1 = sum(ranks(1:length(x)));
    
    % Estatística U
    n1 = length(x);
    n2 = length(y);
    
    U1 = R1 - n1*(n1+1)/2;
    U2 = n1*n2 - U1;
    
    U = min(U1, U2);
    
    % Aproximação normal para p-value
    mu = n1*n2/2;
    sigma = sqrt(n1*n2*(n1+n2+1)/12);
    
    if sigma > 0
        z = (U - mu) / sigma;
        p = 2 * (1 - normcdf(abs(z)));
    else
        p = 1;
    end
end