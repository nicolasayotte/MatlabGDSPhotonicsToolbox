function [gf] = gds_initialize(fname, uunit, dbunit, lname, reflibs, fonts);
%function [gf] = gds_initialize(fname, uunit, dbunit, lname, reflibs, fonts);
%
% gds_initialize : this function creates a new file in GDSII stream
%                  format and writes the header section of the file.
%                  The function does NOT start a top level structure.
%
% fname   : name of .gds file to be created. If a file with the 
%           name already exists, the existing file will be renamed,
%           unless the file name begins with a '!'. If the file
%           name begins with '!' an existing file will be overwritten.
% uunit   : (Optional) user unit in meters. Default is 1^-6 (1 um)
% dbunit  : (Optional) database unit in meters. Default is 10^-9 (1 nm)
% lname   : (Optional) library name which is stored in the file header. By
%           default, the file name is used as the library name.
% reflibs : (Optional) cell array of strings with names of 
%           referenced libraries. Strings must have <= 44
% fonts :  (Optional) cell array of strings with font names (up to 4).
%

% Initial version: Ulf Griesmann, NIST, January 2008
% Changed GDS II version number from 3 to 7. Ulf Griesmann, Feb. 2011
% changed user unit to "real" unit in m. Ulf Griesmann, Oct. 2011
% accept library name as an additional argument. U. Griesmann,
% Jan. 2012
% renamed 'gdsii_initialize.m --> gds_initialize.m'. The function
% is now an entry point for the rewritten low-level I/O. 
% U. Griesmann, Jan. 2013
%
% This software is in the Public Domain. 
%

% global variables
global gdsii_uunit;
global gdsii_dbunit;

% check parameters
if isempty(uunit), uunit = 1.0e-6; end
if isempty(dbunit), dbunit = 1.0e-9; end

% store units for all other functions
gdsii_dbunit = dbunit;
gdsii_uunit  = uunit / dbunit; % store the uunit/dbunit ratio

if fname(1) ~= '!'  % back up existing file
  
   % check if the file already exists
   if gds_file_exists(fname)
  
      % find a backup file name
      bakver = 1;
      while 1
         bak_fname = sprintf('%s.%d', fname, bakver);
         if ~gds_file_exists(bak_fname)
            break
         else
            bakver = bakver + 1;
         end
      end
   
      % rename the existing file
      if isunix || ismac
         system(sprintf('mv %s %s', fname, bak_fname));
      elseif ispc
         system(sprintf('ren %s %s', fname, bak_fname));
      else
         error('gdsii_initialize :  could not rename existing file.');
      end
      
   end % if exist ...
   
else  % overwrite file if it exists
   fname = fname(2:end);
end

% set default library name
if isempty(lname)
   lname = fname;
end

% open the library file
gf = gds_open(fname, 'wb'); % the 'b' is for Windows

% write the HEADER record (format version 7 permits 8192 polygon vertices)
gds_beginlib(gf, uunit, dbunit, lname, reflibs, fonts);

return
