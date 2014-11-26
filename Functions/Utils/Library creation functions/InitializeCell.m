function [log, cad, cellname, topcell, layerMap] = InitializeCell()
% INITIALIZECELL This function initializes the tools and objects needed to make a gds cell
%
%     log is a strucuture that write comments into the command windows or to a file.
%     cad is the project definition structure
%     cellname is initialized to the filename of the calling script file
%     topcell is the top cell gds_structure of the GDS you are creating
%     layerMap contains the layer/datatype information
%
%     See also SETUPLOG, PROJECTDEFINITION, READLAYERMAP, FINALIZECELL.


tic;
log = SetupLog('do', true);  % options 'do' and 'file'; functions 'write' and 'close'
log.write('\n%s\nFUNCTION %s\n\n', log.bar(), log.title());


cad = ProjectDefinition(log);
cellname = [cad.author '_' log.title() '_' cad.v];
log.write('\n\tOutput file name: %s\n ', ['Cells\' cellname '.gds']);
log.write('\tTop Cell name: %s\n ', cellname);


topcell = gds_structure(cellname);            % Top cell structure
layerMap = ReadLayerMap('general', log);     % Layer map load (fabname)