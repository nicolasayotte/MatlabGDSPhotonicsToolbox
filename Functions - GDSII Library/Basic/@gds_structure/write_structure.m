function write_structure(gstruc, gf, uunit, dbunit, compound);
%function write_structure(gstruc, gf, uunit, dbunit, bcompound);
% 
% write_structure :
%     writes a gds_structure object to an open file
%
% gstruc :    a gds_structure object
% gf :        a file handle of a gds library file
% uunit :     user unit
% dbunit :    database unit
% compound :  flag that controls the creation of libraries with
%             compound elements.
%

% Ulf Griesmann, NIST, November 2011
% modified for new low-level I/O, Ulf Griesmann, January 2013

% write a structure header
gds_beginstruct(gf, gstruc.sname, gstruc.cdate);

% write all elements in the structure
cellfun(@(x)write_element(x,gf,uunit,dbunit,compound), gstruc.el);

% write an end structure record
gds_endstruct(gf);

return
