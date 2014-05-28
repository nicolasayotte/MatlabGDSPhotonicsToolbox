function tx = funSolve(fun, xmin, xmax, varargin)
% This function returns the first zero of the fun entered in it
% 'tolerance' is the relative precision threshold  (1e-12 : default)

solution.tolerance = 1e-12;
solution = ReadOptions(solution, varargin{:});

nx = 100;
x = linspace(xmin, xmax, nx);
tx = 1; 
tx0 = 0;

while(abs((tx - tx0)/tx) > solution.tolerance)
  tx0 = tx;
  y = fun(x);
  tm = find (([0, y] < 0 & [y, 0] >= 0) | (([0, y] >= 0 & [y, 0] < 0)), 1, 'first');
  tx = (abs(y(tm - 1)) * x(tm) + abs(y(tm)) *  x(tm-1)) / (abs(y(tm)) + abs(y(tm - 1)));
  x = tx + 0.5 * (x(2) - x(1)) * linspace(-1, 1, nx);
  if(isempty(tm))
    error('The domain under study has no zeros');
  end
end

return