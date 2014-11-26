function [] = MergeGDS(cad, log)
%MERGEGDS runs through the Cells folder and puts all the .gds files together in a
% master .gds file according to the floorplan information contained in the *_put.mat
% files associated with the .gds.
%
%     Both function inputs are generated and should not be created manually.
%
%     See also PUTCELL, PROJECTDEFINITION, SETUPLOG, INITIALIZECELL.

log.write('\n\t%s  -  %s\n\n', log.title(), log.time());
log.write('\t\tCad name: %s\n\n', cad.outfil);

tic;
topCell = gds_structure(cad.outtop);
mergedLibrary = gds_library(cad.libnam, 'uunit',cad.uunit, 'dbunit',cad.dbunit);

files = dir(['Cells/*' cad.v '_put.mat']);


for inputFile = 1 : length(files)
   putData = load(['Cells/' files(inputFile).name(1:end-4)]);
   cellname = [cad.author '_' putData.cellname '_' cad.v];
   load([putData.filename '_gds']);
   log.write('\t\tRead gds: %s\n', putData.filename);
   
   for inputStructure = 1 : length(gdslib)
      
      % Check if a structure of the same name already exists
      stname = sname(gdslib(inputStructure));
      structureIsDuplicate = false;
      for libStructure = 1 : length(mergedLibrary)
         if(strcmp(stname,sname(mergedLibrary(libStructure))))
            structureIsDuplicate = true;
         end
      end
      
      % If it already exists skip it, else import it
      if(structureIsDuplicate)
         log.write('\t\t\tSkipping duplicate cell: %s\n', stname);
      else
         mergedLibrary = add_struct(mergedLibrary, gdslib(inputStructure));
         log.write('\t\t\tAdding cell: %s\n', stname);
      end
   end
   
   for place = 1 : size(putData.spos, 1)
      % Add the input cell in the merged library top cell
      log.write('\t\t\t\tPlacing topcell %s at [%1.3f, %1.3f]\n', cellname, putData.spos(place, :));
      topCell = add_ref(topCell, cellname, 'xy', putData.spos(place, :), 'strans', putData.strans(place));
      if(putData.strans(place).reflect); log.write('\t\t\t\t\tReflection: %u\n', putData.strans(place).reflect); end
      if(putData.strans(place).angle); log.write('\t\t\t\t\tRotation: %01.0f degress\n', putData.strans(place).angle); end
   end
   log.write('\n');
end

MergeGDSRoutingMat(cad.outfil(1:end-4));
mergedLibrary = add_struct(mergedLibrary, topCell);
gdslib = mergedLibrary;

save(['Cells/' cad.outfil(1:end-4) '_gds'], 'gdslib');
write_gds_library(mergedLibrary, ['!Cells/' cad.outfil], 'verbose', 0);

end



function MergeGDSRoutingMat(inname)

routingFiles = dir('Cells/*outing*.mat');
routingFile = '';
for rFile = 1 : length(routingFiles)
   tFile = routingFiles(rFile).name;
   if(~(strcmp(tFile(end-7:end-4), '_put') || strcmp(tFile(end-7:end-4), '_gds')))
      routingFile = tFile;
      break;
   end
end
if(isempty(routingFile))
   warning('No routing waveguide information');
else
   load(['Cells/' routingFile(1:end-4)]);
   cellname = inname;
   filename = ['Cells/' inname];
   save(filename, 'cellname', 'filename', 'floorplan', 'infoIn', 'infoOut');
end

end