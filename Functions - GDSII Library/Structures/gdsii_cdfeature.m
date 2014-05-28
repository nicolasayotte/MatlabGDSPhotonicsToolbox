function [cd] = gdsii_cdfeature(layer, mincd, uunit);
%function [cd] = gdsii_cdfeature(layer, mincd, uunit);
%  
% gdsii_cdfeature : create a structure 'CD_FEATURE' containing a
%                   critical dimension feature at a specified
%                   position. The CD feature consists dense and
%                   isolated angular lines with a label indicating
%                   the line width in micrometer. After the
%                   CD_FEATURE structure has been defined, one or
%                   more CD features can be positioned in a layout
%                   using gds_structure.add_ref (or gdsii_sref).
%
% layer : (Optional) Layer to which the feature will be
%         written. Default is to write to the default layer.
% mincd : (Optional) minimum CD feature that will be included in
%         the pattern. Default is to write all patterns down to 100
%         nm.
% uunit : (Optional) user unit in m. Default is 1e-6 m = 1 um.
% cd :    A cell array containing gds_structure objects.
%

% initial version:                Ulf Griesmann, NIST, May 2008
% extended to 100 nm:             Ulf Griesmann, NIST, Jan 2011
% based on structure references:  Ulf Griesmann, NIST, Feb 2011
% based on objects :              Ulf Griesmann, NIST, Jul 2011
% make it work with any user unit, Ulf Griesmann, Dec 2011
% removed argument 'gf', Ulf Griesmann, November 2012
% removed global gdsii_layer, U.G., Jan 2013

% set default arguments
if nargin < 3 
   uunit = 1e-6; 
   fprintf('\n>>> Warning :  uunit set to 1e-6 m for CD feature.<<<\n\n');
end
if nargin < 2, mincd = 0; end
if nargin < 1, layer = 1; end

% create 1 unit wide lines forming the angle pattern
P = {};
L1 = 30; % length of long leg
L2 = 20; % length of short leg
P{1} = [0,0; L1,0; L1,4; L2+1,4; L2+1,1; 1,1; 1,L1; 0,L1; 0,0];
P{2} = [2,2; L2,2; L2,3; 3,3; 3,L2; 2,L2; 2,2]; 
P{3} = [4,4; L2,4; L2,5; 5,5; 5,L1; 4,L1; 4,4];
P{4} = [6,6; L2,6; L2,7; 7,7; 7,L2; 6,L2; 6,6];
P{5} = [8,8; L2+1,8; L2+1,5; L1,5; L1,8; L1,9; 9,9; 9,L1; 8,L1; 8,8];

% Now the angle pattern must be scaled so that the lines of the
% pattern are always 1 um wide regardless of user unit
cf = 1e-6/uunit;          % conversion factor
P = cellfun(@(x)cf*x, P, 'UniformOutput',0);

% create structure with angle pattern
cdb = gds_element('boundary', 'xy',P, 'layer',layer);
cds = gds_structure('CD_FEATURE_PATTERN', cdb);

% create a structure containing the CD feature
cde = {};
if mincd <= 5,    cde = [cde, single_pattern([0,0],     5,    '5',    cf, layer)]; end
if mincd <= 3,    cde = [cde, single_pattern([180,0],   3,    '3',    cf, layer)]; end
if mincd <= 2.5,  cde = [cde, single_pattern([300,0],   2.5,  '2.5',  cf, layer)]; end
if mincd <= 2,    cde = [cde, single_pattern([0,190],   2,    '2',    cf, layer)]; end
if mincd <= 1.5,  cde = [cde, single_pattern([90,190],  1.5,  '1.5',  cf, layer)]; end
if mincd <= 1.2,  cde = [cde, single_pattern([170,190], 1.2,  '1.2',  cf, layer)]; end
if mincd <= 1.1,  cde = [cde, single_pattern([240,190], 1.1,  '1.1',  cf, layer)]; end
if mincd <= 1,    cde = [cde, single_pattern([300,190], 1,    '1',    cf, layer)]; end
if mincd <= 0.9,  cde = [cde, single_pattern([85,260],  0.9,  '0.9',  cf, layer)]; end
if mincd <= 0.8,  cde = [cde, single_pattern([130,260], 0.8,  '0.8',  cf, layer)]; end
if mincd <= 0.7,  cde = [cde, single_pattern([170,260], 0.7,  '0.7',  cf, layer)]; end
if mincd <= 0.6,  cde = [cde, single_pattern([210,260], 0.6,  '0.6',  cf, layer)]; end
if mincd <= 0.5,  cde = [cde, single_pattern([250,260], 0.5,  '0.5',  cf, layer)]; end
if mincd <= 0.4,  cde = [cde, single_pattern([280,260], 0.4,  '0.4',  cf, layer)]; end
if mincd <= 0.3,  cde = [cde, single_pattern([310,260], 0.3,  '0.3',  cf, layer)]; end
if mincd <= 0.2,  cde = [cde, single_pattern([335,260], 0.2,  '0.2',  cf, layer)]; end
if mincd <= 0.17, cde = [cde, single_pattern([280,290], 0.17, '0.17', cf, layer)]; end
if mincd <= 0.15, cde = [cde, single_pattern([295,290], 0.15, '0.15', cf, layer)]; end
if mincd <= 0.13, cde = [cde, single_pattern([310,290], 0.13, '0.13', cf, layer)]; end
if mincd <= 0.11, cde = [cde, single_pattern([325,290], 0.11, '0.11', cf, layer)]; end
if mincd <= 0.1,  cde = [cde, single_pattern([340,290], 0.1,  '0.1',  cf, layer)]; end
   
cdf = gds_structure('CD_FEATURE', [cde, {gdsii_nistlogo(cf*[180,115], cf*50, layer)}]);

% return structures
cd = {cds, cdf};

return
   

%-------------------------------------------------------------

function [cae] = single_pattern(pos, scale, label, cf, layer)
%
% writes a CD pattern at the specified position
% scaled to specified size with specified label
%
% pos   : pattern position in user units
% scale : scale factor
% label : pattern label
% cae   : cell array of elements
% 

% pattern element
strans.mag = scale;
pat = gds_element('sref', 'sname', 'CD_FEATURE_PATTERN', ...
                  'strans',strans, 'xy',cf*pos); 

% combine it with the size label
lpos = pos + scale * [13,14];
lhei = scale * 10;
txt = gdsii_ptext(label, cf*lpos, cf*lhei, layer);

% return the list of elements
cae = {pat, txt};

return


%-------------------------------------------------------------

function [logo] = gdsii_nistlogo(pos, height, layer);
%function [logo] = gdsii_nistlogo(pos, height, layer);
%
% draw the NIST logo using boundary elements
%
% pos:    a row vector with the position of the logo in user coordinates
% height: (Optional) by default, the logo has a height of 1 - 
%         use this factor to scale it up to the desired height in 
%         user units.
% layer : the layer
% logo  : (Optional) gds_element (boundary) of the NIST logo, scaled
%

% Ulf Griesmann, January, 2008
%

hnorm = 1/170; % scale factor for unit height 

lpart = {};    % boundary list

% first the 'N'
ndata = [1,1; 1,130.5; 3,139; 7,148; 13,156; 20,162; 25,165; ...
         30,167; 36,169; 43.5,170; 49.5,170; 56,169; 60,168; ...
         65,166; 70,163; 75,159; 182,42; 184,41; 185.5,40; ...
         187,40; 189,41; 190,42; 191,44; 191,170; 231,170; ...
         231,39; 230,34; 228,28; 225,22; 222,18; 218,14; ...
         214,10; 210,7; 206.5,5; 200,2; 196,1; 177,1; 170,3; ...
         164,6; 158,10; 156,12; 50,128; 48,130; 44,130; 42,128; ...
         41,126; 41,1; 1,1];
[nr,nc] = size(ndata);
lpart{1} = repmat(pos,nr,1) + height * (ndata - ones(nr,nc)) * hnorm;

% then the 'IST'
idata = [251,170; 291,170; 291,44.5; 292,42; 294,40; 467,40; 470,41; ...
         472,43; 474,45; 475,47; 476,49; 476,56; 475,59; 473,62; ...
         470,64; 467,65; 354,65; 342,68; 331,73; 323,79; 318,84; ...
         314,90; 310,98; 308,105; 307,108.5; 306,118; 307,127.5; ...
         309,134; 311,139; 314,145; 319,152; 324,157; 333,163; ...
         344,168; 355,170; 645,170; 645,130; 576,130; 576,1; 536,1; ...
         536,130; 354,130; 351,128; 348,125; 347,121; 346,118; ...
         347,114; 349,109; 351,107; 355,105; 467,105; 475,104; ...
         482,102; 490,98; 496,94; 503,87; 509,78; 513,71; 515,64; ...
         516,57; 516,48; 515,41; 512,33; 509,26; 503,18; 496,11; ...
         486,5; 477,2; 473,1; 288,1; 278,4; 269,9; 262,16; 257,23; ...
         253,31; 252,37; 251,42; 251,170];
[nr,nc] = size(idata);
lpart{2} = repmat(pos,nr,1) + height * (idata - ones(nr,nc)) * hnorm;

logo = gds_element('boundary', 'xy',lpart, 'layer',layer);

return
