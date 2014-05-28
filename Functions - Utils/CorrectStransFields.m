function strans = CorrectStransFields(strans)
%CORRECTSTRANSFIELD Adds the required fields to an strans struct if they do not
% already exist and orders the fields.


if(~isfield(strans, 'reflect'))
  strans.reflect = 0;
end

if(~isfield(strans, 'angle'))
  strans.angle = 0;
end
strans = orderfields(strans);

end