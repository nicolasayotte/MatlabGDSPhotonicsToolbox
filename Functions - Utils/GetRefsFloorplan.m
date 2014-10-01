function refs = GetRefsFloorplan(refs)
%GETREFSFLOORPLAN Look into the .mat files associated to the library .gds files to
% gather the referenced cells floorplan information.
%
%     It is expected that when looking for the cell 'cellname' in the file refFile.gds
%     there should be a refFile.mat file saved in the same folder. Once loaded into a
%     structure as in :
%         data = load('refFile');
%
%     then the program expects the floorplan information of a cell to be at:
%         data.('cellname').floorplan
%
%     This .mat file should be created automatically using the CreateReferenceFloorplan
%     function
%
%     See also CREATEREFSFLOORPLAN, GETSTRUCTURESIZE


for ref = 1 : length(refs)
  load(refs(ref).filename(1:end-4));
  refs(ref).floorplan = cells.(refs(ref).cellname).floorplan;
end

end