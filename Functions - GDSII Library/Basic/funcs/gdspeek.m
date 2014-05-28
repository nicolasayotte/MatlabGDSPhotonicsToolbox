function gdspeek(gdsfil, bel)
%function gdspeek(gdsfil, bel)
%
% gdspeek :  peek at the contents of a GDS II library file without 
%            loading the file into memory. Displays structure
%            names and, if desired, element content of the file.
%
% gdsfil :  name of a GDS II library file
% bel :     (Optional) if ~= 0, statistical information regarding
%           the elements in structures is displayed. Default is 0.

% Initial version, Ulf Griesmann, June 2013

% check arguments
if nargin < 2, bel = []; end
if nargin < 1
   error('file name required.');
end
if isempty(bel), bel = 0; end


% open input file
gf = gds_open(gdsfil, 'rb'); % the 'b' is for Windows
    
% read library header
ldata = gds_libdata(gf);
fprintf('\nLibrary name  : %s\n', ldata.lname);
fprintf('Creation date : %d-%d-%d, %02d:%02d:%02d\n', ldata.cdate);
fprintf('User unit     : %g m\n', ldata.uunit);
fprintf('Database unit : %g m\n\n', ldata.dbunit);

% read all structures and copy to output file
nst = 0;
while 1

    [rlen, rtype] = gds_record_info(gf);

    switch rtype

    case 1024 % ENDLIB
       break

    case 1282 % BGNSTR - beginning of structure
       S = gds_read_struct(gf, ldata.uunit, ldata.dbunit);
       nst = nst + 1;
       fprintf('%d ... %s (%d) ', nst, sname(S), numel(S));
       if bel
           inspect_elements(S);
       else
           fprintf('\n');
       end

    otherwise
       gds_close(gf); % something is wrong - get out
       error('invalid GDS file - ENDLIB or BGNSTR expected.');
 
    end % switch

end % while

fprintf('\n');

% close input file
gds_close(gf);

return


function inspect_elements(gstruc)
%
% inspects all the elements in gds_structure S and prints 
% a statistical summary

% initialize variables for accounting
numl = 256; % max number of layers
for k=1:numl
   S(k) = struct('boundary',0, 'path',0, 'box',0, 'node',0, 'text',0);
end
L = zeros(1,numl);

% iterate over all elements in structure S
nref = 0;
for m = 1:numel(gstruc)
    if is_ref(gstruc(m))    % sref and aref have no layer information
        nref = nref + 1;
    else
        E = gstruc(m);
        numl = E.layer + 1;  % gds layer numbers start with 0
        L(numl) = L(numl) + 1; 
        S(numl).(etype(E)) = S(numl).(etype(E)) + 1;
    end
end

%display
for k = find(L>0)
    fprintf('|L%d> ', k-1); % layers start with 0
    if S(k).boundary
        fprintf('Bnd:%d ', S(k).boundary);
    end
    if S(k).path
        fprintf('Pth:%d ', S(k).path);
    end
    if S(k).box
        fprintf('Box:%d ', S(k).box);
    end
    if S(k).node
        fprintf('Nde:%d ', S(k).node);
    end
    if S(k).text
        fprintf('Txt:%d ', S(k).text);
    end 
end
fprintf('|%d Ref\n', nref);

return
