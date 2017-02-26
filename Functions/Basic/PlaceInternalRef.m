function [struct, infoOut,info] = PlaceInternalRef(struct, info, refname, relinfo, reflect)
%PlaceInternalRef places an internal reference
%Author : Alexandre D. Simard                                   Creation date : 28/11/2016

%% Default value for valid options
if ~exist('reflect')
    reflect = false;
end

rows = size(info.pos, 1);
reflect = NumberOfRows(rows, reflect);

% Adjust the output info
cc=0;
for ii = 1:length(relinfo.ori)
    for row = 1 : rows
        if reflect(row)
            infoOutloc= CloneInfo(SplitInfo(info,row), 2, relinfo.pos(ii,1), -relinfo.pos(ii,2), relinfo.ori(ii));           
        else
            infoOutloc= CloneInfo(SplitInfo(info,row), 2, relinfo.pos(ii,1), relinfo.pos(ii,2), relinfo.ori(ii));           
        end        
            infoOutloc = SplitInfo(infoOutloc,2);
            cc = cc+1;
            infoOut{cc} = infoOutloc;            
    end
end
infoOut = MergeInfo(infoOut{:});
            
%%%%%%%%%%%%%%%%%%%%%%%%

for row = 1 : rows
   strans.angle = info.ori(row);
   if reflect(row) == 1
      strans.reflect = 1;
   end
   struct = add_ref(struct, refname, 'xy', info.pos(row,:), 'strans', strans);
   info.ori(row) = ConstrainAngle(info.ori(row) + 180);
   clear strans
end

end