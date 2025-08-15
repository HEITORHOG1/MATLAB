function octave_compatibility()
    % Função para adicionar compatibilidade com Octave
    % Cria funções auxiliares que não existem no Octave
    
    % Verificar se estamos no Octave
    if exist('OCTAVE_VERSION', 'builtin')
        fprintf('Configurando compatibilidade com Octave...\n');
        
        % Criar arquivos de função separados para compatibilidade
        createDatetimeFunction();
        createSkewnessFunction();
        createKurtosisFunction();
        createSwtestFunction();
        createEntropyFiltFunction();
        createStdFiltFunction();
        createPrctileFunction();
        
        fprintf('Compatibilidade com Octave configurada.\n');
    end
end

function createDatetimeFunction()
    if ~exist('datetime', 'builtin') && ~exist('datetime', 'file')
        % Criar função datetime simples
        fid = fopen('datetime.m', 'w');
        fprintf(fid, 'function dt = datetime(varargin)\n');
        fprintf(fid, '  dt = datestr(now);\n');
        fprintf(fid, 'end\n');
        fclose(fid);
    end
end

function createSkewnessFunction()
    if ~exist('skewness', 'builtin') && ~exist('skewness', 'file')
        fid = fopen('skewness.m', 'w');
        fprintf(fid, 'function s = skewness(x)\n');
        fprintf(fid, '  x = x(:);\n');
        fprintf(fid, '  n = length(x);\n');
        fprintf(fid, '  if n < 3\n');
        fprintf(fid, '    s = NaN;\n');
        fprintf(fid, '    return;\n');
        fprintf(fid, '  end\n');
        fprintf(fid, '  xbar = mean(x);\n');
        fprintf(fid, '  sigma = std(x);\n');
        fprintf(fid, '  if sigma == 0\n');
        fprintf(fid, '    s = 0;\n');
        fprintf(fid, '  else\n');
        fprintf(fid, '    s = mean(((x - xbar) / sigma).^3);\n');
        fprintf(fid, '  end\n');
        fprintf(fid, 'end\n');
        fclose(fid);
    end
end

function createKurtosisFunction()
    if ~exist('kurtosis', 'builtin') && ~exist('kurtosis', 'file')
        fid = fopen('kurtosis.m', 'w');
        fprintf(fid, 'function k = kurtosis(x)\n');
        fprintf(fid, '  x = x(:);\n');
        fprintf(fid, '  n = length(x);\n');
        fprintf(fid, '  if n < 4\n');
        fprintf(fid, '    k = NaN;\n');
        fprintf(fid, '    return;\n');
        fprintf(fid, '  end\n');
        fprintf(fid, '  xbar = mean(x);\n');
        fprintf(fid, '  sigma = std(x);\n');
        fprintf(fid, '  if sigma == 0\n');
        fprintf(fid, '    k = 3;\n');
        fprintf(fid, '  else\n');
        fprintf(fid, '    k = mean(((x - xbar) / sigma).^4) - 3;\n');
        fprintf(fid, '  end\n');
        fprintf(fid, 'end\n');
        fclose(fid);
    end
end

function createSwtestFunction()
    if ~exist('swtest', 'builtin') && ~exist('swtest', 'file')
        fid = fopen('swtest.m', 'w');
        fprintf(fid, 'function [h, p] = swtest(x)\n');
        fprintf(fid, '  x = x(:);\n');
        fprintf(fid, '  n = length(x);\n');
        fprintf(fid, '  if n < 3 || n > 5000\n');
        fprintf(fid, '    h = 0;\n');
        fprintf(fid, '    p = 0.5;\n');
        fprintf(fid, '    return;\n');
        fprintf(fid, '  end\n');
        fprintf(fid, '  try\n');
        fprintf(fid, '    [h, p] = kstest((x - mean(x)) / std(x));\n');
        fprintf(fid, '  catch\n');
        fprintf(fid, '    h = 0;\n');
        fprintf(fid, '    p = 0.5;\n');
        fprintf(fid, '  end\n');
        fprintf(fid, 'end\n');
        fclose(fid);
    end
end

function createEntropyFiltFunction()
    if ~exist('entropyfilt', 'builtin') && ~exist('entropyfilt', 'file')
        fid = fopen('entropyfilt.m', 'w');
        fprintf(fid, 'function J = entropyfilt(I, nhood)\n');
        fprintf(fid, '  if nargin < 2\n');
        fprintf(fid, '    nhood = ones(3);\n');
        fprintf(fid, '  end\n');
        fprintf(fid, '  I = double(I);\n');
        fprintf(fid, '  [m, n] = size(I);\n');
        fprintf(fid, '  J = zeros(m, n);\n');
        fprintf(fid, '  for i = 2:m-1\n');
        fprintf(fid, '    for j = 2:n-1\n');
        fprintf(fid, '      patch = I(i-1:i+1, j-1:j+1);\n');
        fprintf(fid, '      patch = patch(:);\n');
        fprintf(fid, '      patch = patch(patch > 0);\n');
        fprintf(fid, '      if ~isempty(patch)\n');
        fprintf(fid, '        p = patch / sum(patch);\n');
        fprintf(fid, '        p = p(p > 0);\n');
        fprintf(fid, '        J(i,j) = -sum(p .* log2(p + eps));\n');
        fprintf(fid, '      end\n');
        fprintf(fid, '    end\n');
        fprintf(fid, '  end\n');
        fprintf(fid, 'end\n');
        fclose(fid);
    end
end

function createStdFiltFunction()
    if ~exist('stdfilt', 'builtin') && ~exist('stdfilt', 'file')
        fid = fopen('stdfilt.m', 'w');
        fprintf(fid, 'function J = stdfilt(I, nhood)\n');
        fprintf(fid, '  if nargin < 2\n');
        fprintf(fid, '    nhood = ones(3);\n');
        fprintf(fid, '  end\n');
        fprintf(fid, '  I = double(I);\n');
        fprintf(fid, '  [m, n] = size(I);\n');
        fprintf(fid, '  J = zeros(m, n);\n');
        fprintf(fid, '  for i = 2:m-1\n');
        fprintf(fid, '    for j = 2:n-1\n');
        fprintf(fid, '      patch = I(i-1:i+1, j-1:j+1);\n');
        fprintf(fid, '      J(i,j) = std(patch(:));\n');
        fprintf(fid, '    end\n');
        fprintf(fid, '  end\n');
        fprintf(fid, 'end\n');
        fclose(fid);
    end
end
functi
on createPrctileFunction()
    if ~exist('prctile', 'builtin') && ~exist('prctile', 'file')
        fid = fopen('prctile.m', 'w');
        fprintf(fid, 'function y = prctile(x, p)\n');
        fprintf(fid, '  x = x(:);\n');
        fprintf(fid, '  x = sort(x(~isnan(x)));\n');
        fprintf(fid, '  n = length(x);\n');
        fprintf(fid, '  if n == 0\n');
        fprintf(fid, '    y = NaN;\n');
        fprintf(fid, '    return;\n');
        fprintf(fid, '  end\n');
        fprintf(fid, '  if p == 0\n');
        fprintf(fid, '    y = x(1);\n');
        fprintf(fid, '  elseif p == 100\n');
        fprintf(fid, '    y = x(end);\n');
        fprintf(fid, '  else\n');
        fprintf(fid, '    idx = p/100 * (n-1) + 1;\n');
        fprintf(fid, '    if idx == floor(idx)\n');
        fprintf(fid, '      y = x(idx);\n');
        fprintf(fid, '    else\n');
        fprintf(fid, '      lower = x(floor(idx));\n');
        fprintf(fid, '      upper = x(ceil(idx));\n');
        fprintf(fid, '      y = lower + (upper - lower) * (idx - floor(idx));\n');
        fprintf(fid, '    end\n');
        fprintf(fid, '  end\n');
        fprintf(fid, 'end\n');
        fclose(fid);
    end
end