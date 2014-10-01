function cellInfo = GetCellInfo(cad)
%GETCELLINFO Read all the .mat files associated with the children cells and GDS
% of the current project.
% 
%     See also GETSTRUCTURESIZE


files = dir(['Cells/*' cad.v '.mat']);
for file = 1 : length(files)
  filename = files(file).name(1:end-4);
  ind = find(filename == '_');
  cellInfo.(filename((ind(1)+1):(ind(end) - 1))) = load(filename);  % Load all files data
end
