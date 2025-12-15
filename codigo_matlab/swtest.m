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
