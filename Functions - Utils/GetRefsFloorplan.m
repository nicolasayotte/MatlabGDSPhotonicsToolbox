function outrefs = GetRefsFloorplan(refs)
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

outrefs(1:length(refs)) = struct('filename', '', 'cellname', '', 'floorplan', []);

for ref = 1 : length(refs)
  outrefs(ref).filename = refs(ref).filename;
  outrefs(ref).cellname = refs(ref).cellname;
  load(refs(ref).filename(1:end-4));
  outrefs(ref).floorplan = cells.(refs(ref).cellname).floorplan;
end

end