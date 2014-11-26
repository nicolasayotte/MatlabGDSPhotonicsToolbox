function write_gds_library(glib, fname, varargin);
%function write_gds_library(glib, fname, varargin);
% 
% write_gds_library :
%     writes a GDS library object to a file
%
% glib  :     a gds_library object
% fname :     GDS file name. When the file name has the extension .cgds 
%             a compound GDS file is created instead of a standard GDS file.
% varargin :  optional argument/value pairs 
%
%             verbose : when == 1, print out information about the
%                 library. When > 1 also displays the top level structures
%                 (can be very slow). Default is 1 (medium verbose).
%
%             compound : when == 1, a library with file extension
%                 .cgds containing compound elements is created. Compound
%                 elements are stored with multiple XY records per
%                 element. They are not compatible with other software for
%                 processing GDS II layout files.  Default is 0.
%

% Ulf Griesmann, NIST, November 2011

% check argument number
if nargin < 3, varargin = []; end
if nargin < 2 
   error('missing file name argument.');
end

% defaults
verbose = 1;
compound = 0;

% process varargin
if ~isempty(varargin)
   for idx = 1:2:length(varargin)
      prop = varargin{idx};
      valu = varargin{idx+1};
      switch prop        
         case 'verbose'
            verbose = valu;
         case 'compound'
            compound = valu;
         otherwise
            error(sprintf('unknown property --> %s\n', prop));
      end
   end
end

% extension selects compound flag
if strcmp(fname(end-4:end),'.cgds')
   compound = 1;
end

% check if all structure names are unique
N = cellfun(@(x)sname(x), glib.st, 'UniformOutput',0); % structure names
if length(N) ~= length(unique(N))
   error('write_gds_library :  structure names are not unique.');
end

if verbose == 1
   fprintf('\nLibrary name  : %s\n', glib.lname);
   fprintf('User unit     : %g m\n', glib.uunit);
   fprintf('Database unit : %g m\n', glib.dbunit);
   fprintf('Structures    : %d\n\n', glib.numst);
end

% top level structures
if verbose > 1
   fprintf('Top level: ');
   tls = topstruct(glib);
   if iscell(tls)
      for k=1:length(tls)
         fprintf('%s  ', tls{k});
      end
   else
      fprintf('%s', tls);
   end
   fprintf('\n\n');
end

% start time
t_start = now();

% initialize the library file
gf = gds_initialize(fname, glib.uunit, glib.dbunit, ...
                    glib.lname, glib.reflibs, glib.fonts);

% write all structures in library to file
cellfun(@(x)write_structure(x,gf,glib.uunit,glib.dbunit,compound), glib.st);

% close file
gds_endlib(gf);
gds_close(gf);

% end time
if verbose == 1
   t_el = now() - t_start;  % elapsed time in days
   fprintf('Write time: %s\n\n', datestr(t_el, 'HH:MM:SS.FFF'));
end

return
