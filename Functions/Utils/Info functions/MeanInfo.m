function oinfo = MeanInfo(info1,info2)
%MeanInfo provide the mean info between two info input.
% 
%     See also CURSORINFO, INVERTINFO, MERGEINFO, STRANSINFO, WIDTHINFO.

row1 = size(info1.pos, 1);
row2 = size(info2.pos, 1);

%% Argument validation
if (row1 ~=row2)
    error('The length of each cursor must be equal')
end

oinfo.pos = info1.pos/2 + info2.pos/2;
oinfo.ori = info1.ori/2 + info2.ori/2;
oinfo.length = info1.length/2 + info2.length/2;
oinfo.neff = info1.neff/2 + info2.neff/2;

end