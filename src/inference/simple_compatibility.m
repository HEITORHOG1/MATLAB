function simple_compatibility()
    % Compatibilidade simples com Octave
    
    if exist('OCTAVE_VERSION', 'builtin')
        fprintf('Octave detectado - usando funções simplificadas.\n');
    end
end

% Funcao datetime simplificada
function dt = datetime(varargin)
    dt = datestr(now);
end

% Funcao skewness simplificada
function s = skewness(x)
    x = x(:);
    n = length(x);
    if n < 3
        s = NaN;
        return;
    end
    xbar = mean(x);
    sigma = std(x);
    if sigma == 0
        s = 0;
    else
        s = mean(((x - xbar) / sigma).^3);
    end
end

% Funcao kurtosis simplificada
function k = kurtosis(x)
    x = x(:);
    n = length(x);
    if n < 4
        k = NaN;
        return;
    end
    xbar = mean(x);
    sigma = std(x);
    if sigma == 0
        k = 3;
    else
        k = mean(((x - xbar) / sigma).^4) - 3;
    end
end

% Funcao prctile simplificada
function y = prctile(x, p)
    x = x(:);
    x = sort(x(~isnan(x)));
    n = length(x);
    if n == 0
        y = NaN;
        return;
    end
    if p == 0
        y = x(1);
    elseif p == 100
        y = x(end);
    else
        idx = p/100 * (n-1) + 1;
        if idx == floor(idx)
            y = x(idx);
        else
            lower = x(floor(idx));
            upper = x(ceil(idx));
            y = lower + (upper - lower) * (idx - floor(idx));
        end
    end
end

% Funcao swtest simplificada
function [h, p] = swtest(x)
    x = x(:);
    n = length(x);
    if n < 3 || n > 5000
        h = 0;
        p = 0.5;
        return;
    end
    try
        [h, p] = kstest((x - mean(x)) / std(x));
    catch
        h = 0;
        p = 0.5;
    end
end

% Funcao entropyfilt simplificada
function J = entropyfilt(I, nhood)
    if nargin < 2
        nhood = ones(3);
    end
    I = double(I);
    [m, n] = size(I);
    J = zeros(m, n);
    for i = 2:m-1
        for j = 2:n-1
            patch = I(i-1:i+1, j-1:j+1);
            patch = patch(:);
            patch = patch(patch > 0);
            if ~isempty(patch)
                p = patch / sum(patch);
                p = p(p > 0);
                J(i,j) = -sum(p .* log2(p + eps));
            end
        end
    end
end

% Funcao stdfilt simplificada
function J = stdfilt(I, nhood)
    if nargin < 2
        nhood = ones(3);
    end
    I = double(I);
    [m, n] = size(I);
    J = zeros(m, n);
    for i = 2:m-1
        for j = 2:n-1
            patch = I(i-1:i+1, j-1:j+1);
            J(i,j) = std(patch(:));
        end
    end
end
% Funcao ttest2 simplificada
function [h, p] = ttest2(x, y)
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

% Funcao ranksum simplificada (Mann-Whitney U test)
function p = ranksum(x, y)
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

% Funcao kstest simplificada
function [h, p] = kstest(x)
    x = x(~isnan(x));
    n = length(x);
    
    if n < 3
        h = 0;
        p = 1;
        return;
    end
    
    % Teste KS contra distribuição normal padrão
    x_sorted = sort(x);
    
    % CDF empírica
    empirical_cdf = (1:n)' / n;
    
    % CDF teórica (normal padrão)
    theoretical_cdf = normcdf(x_sorted);
    
    % Estatística KS
    D = max(abs(empirical_cdf - theoretical_cdf));
    
    % P-value aproximado
    p = 2 * exp(-2 * n * D^2);
    p = min(p, 1);
    
    h = p < 0.05;
end

% Funcao finv simplificada
function f = finv(p, df1, df2)
    % Aproximação simples para quantis F
    if p < 0.5
        f = 1;
    else
        f = 2 + (p - 0.5) * 4;
    end
end

% Funcao tinv simplificada
function t = tinv(p, df)
    % Aproximação usando quantis normais
    z = norminv(p);
    
    % Correção para distribuição t
    if df > 30
        t = z;
    else
        t = z * (1 + (z^2 + 1)/(4*df));
    end
end

% Funcao norminv simplificada
function x = norminv(p)
    % Aproximação de Beasley-Springer-Moro para quantis normais
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

% Funcao normcdf simplificada
function p = normcdf(x)
    % Aproximação da CDF normal padrão
    p = 0.5 * (1 + erf(x / sqrt(2)));
end