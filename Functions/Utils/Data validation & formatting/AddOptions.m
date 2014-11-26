function structure = AddOptions(structure, varargin)
%ADDOPTIONS is a general function that reads the varargin standard matlab format of
% argument pairs: 'string', value.
%
%     This uses an input structure that defines the options handled as well as the
%     default values for those options. In AddOptions, a field that does not exist
%     is created contrary to ReadOptions.
%
%     Example: function structure = CreateStructure(varargin)
%                structure = struct('invert', true, 'rotate', 90);
%                structure = ReadOptions(structure, varargin{:});
%              end
%
%     Then:
%              structure = AddOptions(structure, 'rotate', 180);
%
%     sets the value of structure.rotate to 180. And:
%
%              structure = AddOptions(structure, 'flip', true);
%
%     adds the field 'flip' to structure and sets it to true.
%
%     See also READOPTIONS, STRUCT, VARARGIN.

if(size(varargin, 1) > 0)
  
  while ~isempty(varargin)
    
    if((size(structure, 1) < 2) && (size(varargin{2}, 1) < 2))
      field = varargin{1};
      if(ischar(field))
        structure.(field) = varargin{2};
        varargin(1:2) = [];
      else
        error('This argument type is not handled, the first argument of a pair must be a string');
      end
      
    else
      
      %% Distribute rows to structure
      rows = max([size(structure, 1), size(varargin{2}, 1)]);
      targ = varargin{2};
      [structure, targ] = NumberOfRows(rows, structure, targ);
      field = varargin{1};
      if(ischar(field))
        for row = 1 : rows
          if(iscell(targ))
            structure(row).(field) = targ{row};
          else
            structure(row).(field) = targ(row, :);
          end
        end
        varargin(1:2) = [];
      else
        error('This argument type is not handled');
      end
    end
    
  end
end

end