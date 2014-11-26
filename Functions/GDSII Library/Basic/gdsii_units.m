function gdsii_units(uunit, dbunit);
% function gdsii_units(uunit, dbunit);
%  
% gdsii_units :  define the user and database units for a layout.
%
% uunit :  user unit in m; default is 1e-6 or one micrometer.
% dbunit:  database unit in m; default is 1e-9 or one nanometer. 
%

% Ulf Griesmann, NIST, August 2012

% units are stored in global variables
global gdsii_uunit;
global gdsii_dbunit;

% check arguments
if nargin < 2, dbunit = []; end
if nargin < 1, uunit = []; end

if isempty(uunit), uunit = 1e-6; end
if isempty(dbunit), dbunit = 1e-9; end
  
% Internally, the global variable gdsii_uunit is the conversion
% factor from user to database units !

% store units
gdsii_uunit = uunit/dbunit;
gdsii_dbunit = dbunit;

return
