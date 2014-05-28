function [infoSorted, maskOriginalOrder] = CheckParallelAndNormal(info)
%CHECKPARALLELANDNORMAL Return an info structure with the positions sorted according
% to inscreasing distance in the normal direction to their orientation IF the
% vectors are parallel and aligned. If they are not it throws an error.
%
% It also sends the inverted sort mask to put the elements back into the original
% order.


rows = size(info.pos, 1);
if(any(abs(info.ori - info.ori(1)) > 1e-10))
  error('The vectors are not parallel');
end
vectorFromPrevious = diff(info.pos, 1);
vectorFromFirst = [0,0; cumsum(vectorFromPrevious, 1)];
parVector = [cosd(info.ori), sind(info.ori)];
if(any(abs(sum(vectorFromFirst .* parVector, 2)) > 1e-10))
  error('The positions are not on a line perpendicular to their orientation');
end

normalVector = [cosd(info.ori + 90), sind(info.ori + 90)];
[~, maskOrdered] = sort(sum(normalVector .* info.pos, 2));
infoSorted = SplitInfo(info, maskOrdered);

maskOriginalOrder = arrayfun(@(x)find(maskOrdered == x), 1:rows)';
end