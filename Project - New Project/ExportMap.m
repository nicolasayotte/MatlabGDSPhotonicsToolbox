%% RoutingWaveguides
% Author : Nicolas Ayotte
% Creation date : 01/04/2014

% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ..; addpath(genpath(cd)); cd(tp);   % adding path to every folder of the library

tic;
log = SetupLog('do', true);  % options 'do' and 'file'; functions 'write' and 'close'
log.write('\n%s\nCELL FUNCTION %s\n\n', log.bar(), log.title());

cad = ProjectDefinition(log);


%% Merge all the GDS cells
CastLayerMap(cad.outfil, 'TEST_fab', 'output', log);


%% Close the log file
log.write('\nEND  -  %s\n\n', log.time());
log.close();
