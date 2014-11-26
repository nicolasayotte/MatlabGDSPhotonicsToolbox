function [ex] = gds_file_exists(fname)
%
% checks if a file exists in the current directory
%
ex = ~isempty( dir(fname) );

return
