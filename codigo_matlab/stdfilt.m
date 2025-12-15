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
