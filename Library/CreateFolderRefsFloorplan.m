function CreateFolderRefsFloorplan(varargin)
%CREATEFOLDERREFSFLOORPLAN Create the floorplan info for all .gds in the current folder.
% Author : Nicolas Ayotte                                   Creation date: 27/04/2014

tp = cd; cd ..; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library

options.forceUpdate = false;
if(nargin > 0)
  options = ReadOptions(options, varargin{:});
end

files = dir('*.gds');
for file = 1 : length(files)
  CreateRefsFloorplan(files(file).name, options.forceUpdate);
end

end