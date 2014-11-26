function gdscat(inpfil, outfil, inptop, outtop, libnam, uunit, dbunit)
%function gdscat(inpfil, outfil, inptop, outtop, libnam, uunit, dbunit))
%
% gdscat :  merges two or more files in GDS II format. This
%           function does not read entire layout files into memory,
%           but copies files structure by structure. In this way
%           it is possible to combine very large layout files that 
%           cannot be held in memory. Database unit and user unit
%           must be the same for all files.
% 
%            NOTE: this function assumes that the user knows what 
%            s/he is doing.
%
% inpfil :  structure array with input file names
%               inpfil(k).name is the name of the k-th input file
% outfil :  output file name
% inptop :  structure array with the names of the top level structure
%           in each input file and the position in the new top
%           level structure.
%               inptop(k).name : name of top level structure in
%                                k-th file
%               inptop(k).spos : position at which the structure is
%                                referenced by the new top level structure
% outtop :  name of the new top level structure in the output file
% libnam :  name of the new library
% uunit :   (Optional) user unit in m. Default is 1e-6.
% dbunit :  (Optional) data base unit in m. Default is 1e-9.

% Initial version, Ulf Griesmann, June 2013

% check arguments
if nargin < 7, dbunit = []; end
if nargin < 6, uunit = []; end
if nargin < 5
   error('four input arguments required.');
end
if isempty(dbunit), dbunit = 1e-9; end
if isempty(uunit), uunit = 1e-6; end
if length(inpfil) ~= length(inptop)
   error('arguments > inpfil < and > inptop < must have the same length.');
end

% open the output file
of = gds_open(outfil, 'wb');   % the 'b' is for Windows

% write new library header
gds_beginlib(of, uunit, dbunit, libnam, [], []);

% create new top level structure
T = gds_structure(outtop);

% create references to top levels in files
for k = 1:length(inptop)
   T = add_ref(T, inptop(k).name, 'xy',inptop(k).spos);
end

% write new top level structure
write_structure(T, of, uunit, dbunit);


% loop through all input files
for k = 1:length(inpfil)

    % open input file
    fi = gds_open(inpfil(k).name, 'rb');
    
    % read library header
    ldata = gds_libdata(fi);
    if ldata.uunit ~= uunit
        errmsg = sprintf('incompatible user unit in library %s\n', inpfil(k).name);
        error(errmsg);
    end
    if ldata.dbunit ~= dbunit
        errmsg = sprintf('incompatible database unit in library %s\n', inpfil(k).name);
        error(errmsg);
    end

    % read all structures and copy to output file
    fprintf('... processing file -->  %s\n', inpfil(k).name);
    
    while 1

        [rlen, rtype] = gds_record_info(fi);

        switch rtype

        case 1024 % ENDLIB
           break

        case 1282 % BGNSTR - beginning of structure
           S = gds_read_struct(fi, uunit, dbunit);
           write_structure(S, of, uunit, dbunit);

        otherwise
           gds_close(fi); % something is wrong - get out
           gds_close(of);
           error('invalid GDS file - ENDLIB or BGNSTR expected.');
 
        end % switch

    end % while

    % close input file
    gds_close(fi);

end

% close the output file
gds_endlib(of);
gds_close(of);
fprintf('... all files are merged.');

return
