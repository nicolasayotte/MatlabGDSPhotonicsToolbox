function [cdate, mdate] = sdate(gstruc);
%function [cdate, mdate] = sdate(gstruc);
%
% Returns the structure creation and modification dates.
%
% gstruc :  an object of the gds_structure class
% cdate :   a vector [Y,M,D,h,m,s] of the creation date
% mdate :   a vector [Y,M,D,h,m,s] of the modification date
%

% Ulf Griesmann, NIST, November 2011

if nargout == 0
   fprintf('Creation date     : %d-%d-%d, %d:%d:%d\n', gstruc.cdate);
   fprintf('Modification date : %d-%d-%d, %d:%d:%d\n', gstruc.mdate);
else
   cdate = gstruc.cdate;
   mdate = gstruc.mdate;
end

return
