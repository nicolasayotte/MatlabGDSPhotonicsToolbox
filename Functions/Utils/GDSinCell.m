% GDSinCell

% Put the gds element in the workspace in a cell name cells (put topcell
% first)

allname = whos;
clear indTC ind cc
cc = 1;
for ii = 1:length(allname)
  switch allname(ii).class
    case 'gds_structure'
      switch allname(ii).name
        case 'topcell'
          indTC = ii;
        otherwise
          ind(cc) = ii;
          cc=cc+1;
      end
  end
end

if exist('ind', 'var') && exist('indTC', 'var')
  cells = {eval('topcell')};
  for ii = 1:length(ind)
    cells{ii+1} = eval(allname(ind(ii)).name);
  end
elseif exist('indTC', 'var')
  cells = {eval('topcell')};
end
clear indTC ind cc

