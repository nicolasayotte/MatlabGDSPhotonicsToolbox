function CastLayerMap(filename, mapName, mapType, log)
%CASTLAYERMAP Read a .gds and export its layers to another layermap in a new .gds.
%
%     ARGUMENT NAME     SIZE        DESCRIPTION
%     filename          string      .gds file name
%     mapName           string      name of the target layer map
%     mapType           string      'input' to import to 'ulaval' layer map
%                                   'output' to export from 'ulaval' layer map
%     log               1           log object
%
%     See also READLAYERMAP, CASTDEFINEMAP, CASTPREPROCESSING, CASTSTRUCTURELAYER.

log.write('\n\t%s  -  %s\n\n', log.title(), log.time());

switch mapType
   case 'input'
      log.write('\t\tCasting %s layer map %s to ulaval\n', filename, mapName);
   case'output'
      log.write('\t\tCasting %s layer map ulaval to %s\n', filename, mapName);
end


%% Reading the input GDS library
log.write('\t\tReading gds: %s\n', filename);
load(['Cells/' filename(1:end-4) '_gds']);
gdsii_units(get(gdslib, 'uunit'), get(gdslib, 'dbunit'));


%% Creating output info
libname = lname(gdslib);
if(strcmpi(mapType, 'output'))
   author = libname(1 : find(libname == '_', 1, 'first') - 1);
   outlibname = [author '_' mapName '.DB'];
   outfile = [filename(1:end-4) '_' mapName '.gds'];
elseif(strcmpi(mapType, 'input'))
   outlibname = libname;
   outfile = [filename(1 : end - 4) '_ulaval.gds'];
else
   error('Use ''output'' or ''input'' as mapType');
end


%% Casting the layers
outlib = gdslib;
outlib = set(outlib, 'lname', outlibname);

log.write('\t\tDefining the layers bijective map\n');
[mapLayer, mapDatatype] = CastDefineMap(mapName, mapType);

log.write('\t\tPre-processing structures\n');
structs = libraryfun(outlib, @(st) CastPreProcessing(st, mapName, mapType, log));
outlib = set(outlib, 'st', structs);

log.write('\t\tExploring structures for non-reference elements\n');
structs = libraryfun(outlib, @(st) CastStructureLayer(st, mapLayer, mapDatatype, log));
outlib = set(outlib, 'st', structs);


%% New Library output
log.write('\t\tWriting gds: %s\n', outfile);
gdslib = outlib;
save(['Cells/' outfile(1:end-4) '_gds'], 'gdslib');
write_gds_library(outlib, ['!Cells/' outfile], 'verbose', 0);