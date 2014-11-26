function [r, center] = FindCircle(x, y)

if(nargin < 2)
  x = [0, 5, 10];
  y = [0, 25, 0];
end
  
if((length(x) ~= 3)||(length(y) ~= 3))
  error('This solution works for exactly 3 points');
end


for ii = 1 : length(x) - 1
  A(ii) = x(ii + 1) - x(ii);
  B(ii) = y(ii + 1) - y(ii);
  p(ii, 1:2) = [x(ii) + x(ii + 1), y(ii) + y(ii + 1)]/2;
  C(ii) = -(A(ii) * p(ii, 1) + B(ii) * p(ii, 2));
end


cx = -(C(2)/B(2) - C(1)/B(1)) / (A(2) / B(2) - A(1) / B(1));
cy = -A(1) * cx / B(1) - C(1)/B(1);

center = [cx, cy];
r = sqrt((x(1)-cx)^2 + (y(1)-cy)^2);

end