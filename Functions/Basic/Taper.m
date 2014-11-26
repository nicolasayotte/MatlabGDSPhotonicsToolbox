function taper = Taper(varargin)

%TAPER Create a taper information structure
%Author : Nicolas Ayotte                                   Creation date : 26/03/2014
%
%
%     taper = Taper(widthsIn, widthsOut, layers, datatypes)
%     taper = Taper(waveguideIn, waveguideOut)
%
%     This function can either create a Taper information structure from parameters
%     or extrapolate it from two structures having at minimum the fields 'w', 'layer'
%     and 'dtype'. This function can return a column array of Taper structures if one
%     of either waveguide structures is a column array or if one of the parameters
%     has a number of rows higher than 1.
%
% 
%     FIELD NAME     SIZE        DESCRIPTION
%     'w1'           1 x m       width of each layer at the beginning
%     'w2'           1 x m       width of each layer at the end
%     'layer'        1 x m       layer number
%     'dtype'        1 x m       datatype
%
%     OPTION NAME    SIZE        DESCRIPTION
%     'offset'       1 x 2       [] vertical offset in the taper
%     'widthmin',    1 x m       [0.1] width of a layer where one end has no information
%     'invert'       bool        [false] invert taper direction
%     'default2rect' bool        [false] forces layers with information on only on side
%                                to have the same width as the other side.
%
%     See also Waveguide, FiberArray

taper = struct('w1', [],...
   'w2', [],...
   'layer', [], ...
   'dtype', [], ...
   'invert', false, ...
   'default2rect', false,...
   'widthmin', 0.1, ...
   'offset', [], ...
   'group', false, ...
   'distance', [], ...
   'type', 'normal');


if(isWaveguide(varargin{1}) && isWaveguide(varargin{2}))
   
   
   %% Create the taper using two waveguides
   guideIn = varargin{1};
   guideOut = varargin{2};
   varargin(1 : 2) = [];
   
   % Parameters validation
   rows = max([size(guideIn, 1) size(guideOut, 1)]);
   [guideIn, guideOut] = NumberOfRows(rows, guideIn, guideOut);
   
   % Default parameter values and read options
   taper.offset = 0;
   taper(1 : rows, 1) = taper;
   taper = ReadOptions(taper, varargin{ : });
   
   for row = 1 : rows
      lyr1 = guideIn(row).layer + 1i * guideIn(row).dtype;
      lyr2 = guideOut(row).layer + 1i * guideOut(row).dtype;
      layer = unique([lyr1, lyr2]);
      
      cols = size(layer, 2);
      
      widthIn = taper(row).widthmin * ones(1, cols);
      widthOut = taper(row).widthmin * ones(1, cols);
      
      for ii = 1 : cols
         ti1 = find(lyr1 == layer(ii));
         ti2 = find(lyr2 == layer(ii));
         if(~isempty(ti2))
            widthOut(ii) = guideOut(row).w(ti2);
         else
            if(~isempty(ti1) && taper(row).default2rect)
               widthOut(ii) = guideIn(row).w(ti1);
            end
         end
         if(~isempty(ti1))
            widthIn(ii) = guideIn(row).w(ti1);
         else
            if(~isempty(ti2) && taper(row).default2rect)
               widthIn(ii) = guideOut(row).w(ti2);
            end
         end
      end
      
      NonNegative(widthIn, widthOut);
      [widthIn, widthOut, layer] = NumberOfColumns(cols, widthIn, widthOut, layer);
      
      taper(row).w1 = widthIn;
      taper(row).w2 = widthOut;
      taper(row).layer = real(layer);
      taper(row).dtype = imag(layer);
   end
   
elseif(isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3}) && isnumeric(varargin{4}))
   
   
   %% Create the taper using parameters
   widthIn = varargin{1};
   widthOut = varargin{2};
   layer = varargin{3};
   dtype = varargin{4};
   varargin(1 : 4) = [];
   
   % Parameters validation
   NonNegative(widthIn, widthOut);
   rows = max([size(widthIn, 1) size(widthOut, 1) size(layer, 1)]);
   [widthIn, widthOut, layer, dtype] = NumberOfRows(rows, widthIn, widthOut, layer, dtype);
   cols = max([size(widthIn, 2) size(widthOut, 2) size(layer, 2)]);
   [widthIn, widthOut, layer, dtype] = NumberOfColumns(cols, widthIn, widthOut, layer, dtype);
   
   % Default parameter values and read options
   taper.offset = zeros(1, rows);
   taper = ReadOptions(taper, varargin{ : });
   
   taper(1 : rows) = taper;
   for row = 1 : rows
      taper(row).w1 = widthIn(row, : );
      taper(row).w2 = widthOut(row, : );
      taper(row).layer = layer(row, : );
      taper(row).dtype = dtype(row, : );
   end
   
else
   
   % Wrong arguments for the function call
   error('Arguments format is not supported. Please consult documentation.');
   
end

return