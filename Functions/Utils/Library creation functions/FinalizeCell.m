function FinalizeCell(cad, cellname, cells, refs, infoIn, infoOut, log, varargin)
%FINALIZECELL Receive the mandatory elements to create a GDS and write it.
% Any extra argument pair sent into Finalize Cell will be added as a field in the
% floorplan struct
% 
%     See also GETSTRUCTURESIZE, ADDREFSTOLIB, INITIALIZECELL

if(iscell(cells))
   topcell = cells{1};
   internalRefs = cells(2:end);
else
   topcell = cells;
   internalRefs = [];
end


%% Input GDS cell information
filename = ['Cells\' cellname];   % name of GDS of the cell
[cellrect, cellcenter, cellsize] = GetStructureSize(topcell, refs, internalRefs);
floorplan = struct('rect', cellrect, 'center', cellcenter, 'size', cellsize);
floorplan = AddOptions(floorplan, varargin{:});


%% Write the GDS
CheckForDirectory(filename);
gdslib = gds_library([cellname '.DB'], 'uunit', cad.uunit, 'dbunit', cad.dbunit);   % GDS library object
gdslib = AddRefsToLib(gdslib, refs, log);
gdslib = add_struct(gdslib, cells);
save(['Cells\' cellname '_gds'], 'gdslib');
write_gds_library(gdslib, ['!Cells\' cellname '.gds'], 'verbose', 0);


%% Create the .mat information file
% This is .mat info file is used as a reference in the routing cell
save(filename, 'cellname', 'filename', 'floorplan', 'infoIn', 'infoOut');


%% Close the log
log.write('\nEND  -  %s\n\n', log.time());
log.close();
