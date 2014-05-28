function [gs] = gdsii_grating(name, pos, pitch, duty, width, height, ang, layer);
%function [gs] = gdsii_grating(name, pos, pitch, duty, width, height, ang, layer);
%
% gdsii_grating :  returns a named structure with a grating pattern.
%                  A function that is useful for generating test patterns. 
%
% name   : (Optional) name of the structure. Default is 'GRATING' 
% pos    : position of the lower left corner of the grating before
%          any rotation is applied.
% pitch  : grating pitch (grating constant) in user units.
% duty   : (Optional) Duty cycle - ratio of line width to grating period.
%          Default is 0.5  
% width  : (Optional) width of the grating in user units. Default is 10000.
% height : (Optional) height of the grating in user units. Default
%          is 10000.
% ang    : (Optional) rotation angle in radians. Default is 0.
% layer  : (Optional) layer to which the structure is
%          written. Default is 1.
% gs     : a cell array of gds_structure objects. 

% Initial version: Ulf Griesmann, NIST, February 2011
% Removed option to write to file; U.G. NIST, November 2012

% global variables
global gdsii_uunit;
global gdsii_dbunit;

% check arguments
if nargin < 8, layer = []; end;
if nargin < 7, ang = []; end;
if nargin < 6, height = []; end;
if nargin < 5, width = []; end;
if nargin < 4, duty = []; end; 
if nargin < 3, error('gdsii_grating :  too few arguments.'); end;

if isempty(layer), layer = 1; end;
if isempty(duty), duty = 0.5; end;
if isempty(width), width = 10000; end;
if isempty(height), height = 10000; end;
if isempty(ang), ang = 0; end;
if isempty(name), name = 'GRATING'; end;
if isempty(pos), pos = [0,0]; end;

% create a structure containing a boundary element describing a grating line
xy = [0,0; ...
      duty*pitch,0; ...
      duty*pitch,height; ...
      0,height; ...
      0,0];
lins = gds_structure([name,'_LINE'], gds_element('boundary', 'xy',xy, 'layer',layer));

% replicate the structure to make a grating
arc = [0,0; ...
       width,0; ...
       0,height];
adim.row = 1;
adim.col = floor(width/pitch);
repe = gds_element('aref', 'sname',[name,'_LINE'], 'xy',arc, 'adim',adim);
reps = gds_structure(['REP_',name,'_LINE'], repe);

% move the grating to its final location
strans.angle = 180 * ang / pi;
srel = gds_element('sref', 'sname',['REP_',name,'_LINE'], 'xy',pos, 'strans',strans);
srst = gds_structure(name, srel);

% return structures
gs = {lins, reps, srst};

return
