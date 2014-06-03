function [dms] = gdsii_datamatrix(str, height, sname, layer);
%function [dms] = gdsii_datamatrix(str, height, sname, layer);
%
% gdsii_datamatrix :  creates an ISO/IEC 16022  DataMatrix barcode 
%                     with ASCII encoding and ECC200 error correction.
%                     The DataMatrix is returned as a cell array of 
%                     gds_structure objects. 
%
% str :    string to be encoded in the DataMatrix. 
%          Must be less than 300 characters. 
% height : (Optional) height of the DataMatrix. Default is 3000.
% layer :  (Optional) layer to which the pattern is written. 
%          Default is layer 1.
% sname :  (Optional) the name of the top level structure.
%          Default is 'DATAMATRIX'.
% dms :    a cell array with gds_structure objects 
%          representing the DataMatrix

%         
% initial version: Ulf Griesmann, NIST, Jan 2011
% remove nested for loops. U.G., Feb. 2011
% based on 'gdsii_bitmap', U.G., Feb. 2011
% fix bugs in mex function, U.G., Oct. 2011
% return as structure object, U.G., Nov. 2011
% remove 'gf' arguments, U.G., Nov. 2012
%

% check arguments
if nargin < 4, layer = []; end
if nargin < 3, sname = []; end
if nargin < 2, height = []; end
if nargin < 1
   error('missing argument(s)');
end

if isempty(height), height = 3000; end
if isempty(sname), sname = 'DATAMATRIX'; end
if isempty(layer), layer = 1; end

% calculate Datamatrix
DM = datamatrixmex(str)';  % comes from C, must be transposed
DM = DM(end:-1:1,:);       % first line is at the top

% convert Datamatrix to a GDS II structure
pix.height  = height/size(DM,1);  % edge length of pixel
pix.width   = height/size(DM,1);  % pixel width is same as height
dms = gdsii_bitmap(DM, pix, sname, layer);

return
