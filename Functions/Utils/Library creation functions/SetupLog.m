function log = SetupLog(varargin)
%SETUPLOG Define a log object that is helpful in writing execution comments to the
% command window or to a file.
%
%     Options:
%       'do'      [bool]   only writes a log when set to true (default).
%       'file'    0 to write to command window or 'filename.txt' to write to a file
%
%     log.handle contains the file handle if there is one
%     log.write() works like fprintf but requires no file handle
%     log.title() returns back the name of the current script file
%     log.bar() returns a string for a long horizontal bar
%     log.time() returns a string of the current toc() in HH:MM:SS.SS format
%     log.close() closes the file if one is open
%
%     See also FPRINTF, READOPTIONS

% Default option values and read options
log.do = true;
log.file = 0;
log = ReadOptions(log, varargin{:});


if(log.do)
  if(ischar(log.file))
    h = fopen(log.file,'w+');
    fclose(h);
    log.handle = fopen(log.file,'a');
    log.write = @(txt, varargin)fprintf(log.handle, txt, varargin{:});
    log.close = @()fclose(log.handle);
  else
    log.handle = [];
    log.write = @(txt, varargin)fprintf(txt, varargin{:});
    log.close = @()0;
  end
  log.title = @()sprintf('%s', GenerateTitle());
  log.bar = @()sprintf('__________________________________________________________');
  log.time = @()sprintf('%0u:%02u:%05.2f', ConvertToTime(toc()));
else
  log.handle = [];
  log.write = @(varargin)0;
  log.close = @()0;    % This is a fast void function
  log.bar = @()0;
  log.title = @()0;
  log.time = @()0;
end

end



function title = GenerateTitle()
%GENERATETITLE Look through the stack to find the executing script file name and 
% return it in a string. Should work even with local execution of functions as 
% through the F9 functionality.
%
%     See also DBSTACK.

ST = dbstack();
n = 3;
if(strcmp(ST(3).name, 'InitializeCell')); n = n + 1; end

if(length(ST) > 3)
  title = ST(n).name;
else
  title = mfilename('class');
end
end