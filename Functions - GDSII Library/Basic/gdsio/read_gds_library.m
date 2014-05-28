function [glib] = read_gds_library(gdsname, verbose, hdronly);
%function [glib] = read_gds_library(gdsname, verbose, hdronly);
%
% read_gds_library :
%        Reads a GDS II file and returns its structures
%        and elements as a gds_library object. Can also be
%        used to read and display the header portion of a
%        GDS II file.
%
% gdsname :  name of a GDS II file to read (with or without .gds extension).
% verbose :  when > 0, print out information about the file and
%            structure names during reading. Default is 0 (quiet).
% hdronly :  when > 0, only the header information will be displayed and
%            the header structure will be returned. Implies verbose = 1.
%            Default is 0.
% glib :     library object with GDS elements and structures
%

% Initial version, Ulf Griesmann, NIST, November 2011

% check arguments
if nargin < 3, hdronly = []; end
if nargin < 2, verbose = []; end
if nargin < 1
  error('missing file name');
end
if ~nargout & ~hdronly
  error('missing output argument');
end

% set defaults
if isempty(hdronly), hdronly = 0; end
if hdronly, verbose = 1; end
if isempty(verbose), verbose = 0; end

% open file for reading
if ~gds_file_exists(gdsname)
  if gds_file_exists([gdsname,'.gds'])
    gdsname = [gdsname, '.gds'];
  elseif gds_file_exists([gdsname,'.cgds'])
    gdsname = [gdsname, '.cgds'];
  else
    error('input file does not exist.');
  end
end

[gf,fsize] = gds_open(gdsname, 'rb'); % use 'b' for Windows

% start time
t_start = now();

% read the library information records
ldata = gds_libdata(gf);
if verbose
  fprintf('\nLibrary name  : %s\n', ldata.lname);
  fprintf('Creation date : %d-%d-%d, %02d:%02d:%02d\n', ldata.cdate);
  fprintf('User unit     : %g m\n', ldata.uunit);
  fprintf('Database unit : %g m\n', ldata.dbunit);
end

% return if only header display
if hdronly
  return
end

% create the library object
glib = gds_library(ldata.lname, ...
  'uunit',ldata.uunit, 'dbunit',ldata.dbunit, ...
  'cdate',ldata.cdate, 'mdate',ldata.mdate);
if ~isempty(ldata.reflibs)
  glib = set(glib, 'reflibs',ldata.reflibs);
end
if ~isempty(ldata.fonts)
  glib = set(glib, 'fonts',ldata.fonts);
end

% read all structures
if verbose
  fprintf('Structures    :\n');
end

% element and structure counters
tnel = 0;
nstr = 0;

while 1
  
  rtype = gds_record_info(gf);
  
  switch rtype
    
    case 1024 % ENDLIB
      break
      
    case 1282 % BGNSTR - beginning of structure
      nstr = nstr + 1;
      S = gds_read_struct(gf, ldata.uunit, ldata.dbunit);
      glib(nstr) = S;
      tnel = tnel + numel(S);
      if verbose  % print structure information and progress info
        fpos = gds_ftell(gf);
        fprintf('%d ... %3.1f%% ... %s (%d)\n', ...
          nstr, 100*fpos/fsize, sname(S), numel(S));
      end
      
    otherwise
      fclose(gf); % something is wrong - get out
      error('invalid GDS file - ENDLIB or BGNSTR expected.');
  end
  
end

% close the GDS file
gds_close(gf);

% end time
t_el = now() - t_start;  % elapsed time in days

% print statistical information
if verbose
  fprintf('\nRead time  : %s\n', datestr(t_el, 'HH:MM:SS.FFF'));
  fprintf('Structures : %d\n', numst(glib));
  fprintf('Elements   : %d\n\n', tnel);
end

return
