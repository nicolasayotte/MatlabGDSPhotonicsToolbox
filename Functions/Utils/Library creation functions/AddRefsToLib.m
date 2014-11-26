function gdslib = AddRefsToLib(gdslib, refs, log)
%ADDREFSOLIB inserts GDS reference cells into a gds library object
%Author: Nicolas Ayotte                                     Creation date: 14/04/2014
%
%     This function receives a gds_library object 'gdslib' a structure array
%     containing the references information 'ref' and a log object.
%
%     The 'ref' structure must have at least the fields 'filename', and 'cellname'.

log.write('\n\t%s  -  %s\n\n', log.title(), log.time());

for ii = 1 : length(refs)      % Loop on GDS files
  
  if(ii > 1)
    if(~strcmpi(refs(ii).filename, refs(ii - 1).filename))
      log.write('\n');
      data = load([refs(ii).filename(1:end-4) '_gds']);
      lib = data.gdslib;
      log.write('\t\tRead gds: %s\n', refs(ii).filename);
    end
  else
    data = load([refs(ii).filename(1:end-4) '_gds']);
    lib = data.gdslib;
    log.write('\t\tRead gds: %s\n', refs(ii).filename);
  end
  
  
  
  for jj = 1 : numst(lib)    % Loop on new structures
    exis = false;
    stname = sname(lib(jj));
    if(strcmp(stname, refs(ii).cellname))
      for kk = 1 : numst(gdslib)   % Loop on existing structures
        if(strcmp(stname, sname(gdslib(kk))))
          exis = true;
        end
      end
      subrefs = find_ref(lib(jj));
      
      % If no reference with the same name was found, import it.
      if(exis)
        log.write('\t\t\tDuplicate cellname: %s\n', stname);
      else
        gdslib = add_struct(gdslib, lib(jj));
        log.write('\t\t\tAdding cell: %s\n', stname);
      end
    end
  end
  
  for jj = 1 : numst(lib)    % Loop on new structures
    exis = false;
    stname = sname(lib(jj));
    if(strcmp(stname, subrefs))
      for kk = 1 : numst(gdslib)   % Loop on existing structures
        if(strcmp(stname, sname(gdslib(kk))))
          exis = true;
        end
      end
      
      % If no reference with the same name was found, import it.
      if(exis)
        log.write('\t\t\tDuplicate cellname: %s\n', stname);
      else
        gdslib = add_struct(gdslib, lib(jj));
        log.write('\t\t\tAdding cell: %s\n', stname);
      end
    end
  end
  log.write('\n');
end


if isempty(refs)
  log.write('\t\tNo references to load.\n');
  log.write('\n');
end

return