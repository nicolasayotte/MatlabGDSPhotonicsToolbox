function is = isGDSStructure(structure)
%ISGDSSRUCTURE Verify that a struct possesses certain fields.
%
%     See also ISWAVEGUIDE.

structure = structure(1,1);

if(isstruct(structure))
  is = all([isfield(structure, 'xy') isfield(structure, 'layer') ...
    isfield(structure, 'dtype') isfield(structure, 'pos') ...
    isfield(structure, 'ori') isfield(structure, 'len')]);
else
  is = false;
end

end