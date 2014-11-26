function write_element(gelm, gf, uunit, dbunit, compound);
%
% Stores a GDS element object in a library file.
%
% gelm :      gds_element object to write to the file
% gf :        file handle for a gds II library file
% uunit :     user unit
% dbunit:     database unit
% compound :  flag that controls the creation of libraries with
%             compound elements.

% Ulf Griesmann, NIST, June 2011
% modified for new low-level I/O, Ulf Griesmann, January 2013

gds_write_element(gf, gelm.data, uunit/dbunit, compound); 

return
