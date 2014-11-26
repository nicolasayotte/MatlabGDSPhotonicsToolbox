function lengthOffset = CheckParallelAndAlign(info)
%CHECKPARALLELANDALIGN If the cursors are parallel returns the different lengths needed to
%make the cursors aligned on the line normal to their orientation


if(any(abs(info.ori - info.ori(1)) > 1e-10))
  error('The vectors are not parallel');
end

parVector = [cosd(info.ori), sind(info.ori)];
parallelPosition = sum(parVector .* info.pos, 2);

lengthOffset = max(parallelPosition) - parallelPosition;

end