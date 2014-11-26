function is = isWaveguide(structure)
%ISWAVEGUIDE Verify that a struct possesses certain fields.
%
%     See also ISGDSSRUCTURE.

if(isstruct(structure))
  is = all([isfield(structure, 'w') isfield(structure, 'layer')]);
else
  is = false;
end

end