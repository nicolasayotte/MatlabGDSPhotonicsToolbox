function x = Bound(x, xMin, xMax)
x(x<xMin) = xMin;
x(x>xMax) = xMax;
end