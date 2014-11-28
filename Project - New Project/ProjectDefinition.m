function cad = ProjectDefinition(log)
%PROJECT DEFINITION Contains the information for the current project
% Author : Nicolas Ayotte                                  Creation date : 01/04/2014
% The entire programs is in microns.


%% Project information
cad = struct('author', 'Nick', ...       % project lead author or company
  'fab', 'fabName', ...                  % fabrication facility
  'process', 'processName', ...          % fabrication process
  'run', 'runName', ...                  % run name
  'name', 'projectName', ...             % project name
  'layermap', 'UoW', ...           % layer map name
  'uunit', 1e-6, ...                     % CAD scale (1e-6 - > microns)
  'dbunit', 1e-11, ...                   % CAD database unit (1e-11 - > nm)
  'size', [6000, 2000], ...             % Floorplan dimensions
  'margin', struct('left', 100, 'right', 0, 'top', 0, 'bottom', 50), ...   % safety margin
  'v', 'v1');                           % version number

log.write('\n\t%s  -  %s\n\n', log.title(), log.time());
log.write('\t\tAuthor : %s\n\t\tFabrication Facility : %s\n', cad.author, cad.fab);
log.write('\t\tProcess : %s\n\t\tRun : %s\n', cad.process, cad.run);
log.write('\t\tDesign name : %s\n\t\tVersion : %s\n', cad.name, cad.v);


%% Output GDS parameters
% outfil is the name of the merged GDS
% outtop is the name of the topcell of the merged GDS
% libname is the GDS library name (mostly never seen)
cad.outfil = [cad.author '_' cad.fab '_' cad.name '_' cad.v '.gds'];
cad.outtop = ['TOPCELL_' cad.author '_' cad.name];
cad.libnam = [cad.author '_' cad.fab '_' cad.process '.DB'];

end