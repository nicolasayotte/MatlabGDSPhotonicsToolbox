function [struct, info, infoInput, arraySize] = PlaceCouplerArray(struct, info, arrayInputs, guide, fiberArray, coupler, layerMap, varargin)
%PLACECOUPLERARRAY places a coupler array
%Author: Nicolas Ayotte                                     Creation date: 20/01/2014
%
%     This function receives multiple input positions that need to be aligned and
%     parallel and creates a coupler array pattern. The physical layout of the input
%     and output ports from a device should be grouped together as in:
%
%                   DEVICE 1                           DEVICE 2
%      port 1   port 2     ...    port N   port 1   port 2     ...    port N
%
%       |  |     |  |     |  |     |  |     |  |     |  |     |  |     |  |
%       |  |     |  |     |  |     |  |     |  |     |  |     |  |     |  |
%       |  |     |  |     |  |     |  |     |  |     |  |     |  |     |  |
%
%     * The function does not require the input variable info to be sorted to work as
%     described.
%
%
%     [struct, info, infoInput, arraySize] = PLACECOUPLERARRAY(struct, info, arrayInputs, guide, fiberArray, coupler, varargin)
%
%     VARIABLE NAME   SIZE        DESCRIPTION
%     struct          1           topcell in which to place the current element
%     info.pos        m, 2        current position
%     info.ori        m|1         orientation angle in degrees
%     infoInput.pos   m, 2        input position
%     infoInput.ori   m|1         inverse of input orientation
%     arrayInputs     1           number of I/Os per device
%     guide           1           Waveguide struture used for routing
%     fiberArray      1           FiberArray structure
%     coupler         1           coupler reference name
%
%     OPTION NAME    SIZE        DESCRIPTION
%     'direction'    1           clockwise or counter-clockwise pattern
%     'type'         1           'cladding', 'normal', 'metal'
%     'text'         1| (m/arrayInputs) incremented or custom strings to be placed at
%                                the center of a coupler in each coupler group
%     'textIndex'    1           index of the coupler to place the text in
%
%     See also PlaceRect, PlaceArc, PlaceTaper, PlaceSBend

rows = size(info.pos, 1);


%% Varargin and parameters definitions
% CouplerArray fields definition
couplerArray.direction = 1;
couplerArray.type = 'normal';
couplerArray.text = {};
couplerArray.textIndex = 1;
couplerArray.flip = false;
couplerArray.cluster = floor((fiberArray.sp - guide.r)/((2*arrayInputs - 1) * guide.sp + fiberArray.w));
couplerArray = ReadOptions(couplerArray, varargin{:});

if(abs(couplerArray.direction) ~= 1)
   error('couplerArray.direction must equal 1 or -1');
end

turnAngle = 90 * couplerArray.direction;
if(isempty(info.length)); info.length = zeros(rows, length(info.neff)); end

% Sort the entry positions
[info, originalOrder, spacing] = CheckParallelAndNormal(info);
infoInput = InvertInfo(info);

% Calculate the maximum number of couplers per input per column
cluster = min([couplerArray.cluster, floor((fiberArray.sp - guide.r)/((2*arrayInputs - 1) * guide.sp + fiberArray.w))]);
cols = ceil(rows / (cluster * arrayInputs));      % Get the number of required columns

% This is the width of a column
tlen = fiberArray.len + fiberArray.safety + fiberArray.dx + guide.r + (0.5 + 2 * cluster * arrayInputs) * guide.sp;
tl0 = guide.r + (cluster * arrayInputs + 0.5) * guide.sp;

% Adapt the dy if it was underestimated
dy = max([fiberArray.dy, arrayInputs * guide.sp + fiberArray.w]);
distances = CalculateSpreadDistances(arrayInputs, cluster, guide, dy);

len = 0;
w = 0;
if couplerArray.flip
   %% Flipped output
   for col = 1 : cols
      
      guideMask = (1 : cluster * arrayInputs) + (col - 1) * cluster * arrayInputs;
      guideMask = guideMask(guideMask <= rows);
      if(couplerArray.direction == 1)
         guideMask = rows - guideMask + 1;
      end
      
      IOsPerCol = length(guideMask)/arrayInputs;
      colInfo = SplitInfo(info, guideMask);
      
      if(IOsPerCol == 1)    % Simplified case where there is only space for one set of IOs per column
         clusterInfo = colInfo;
         
         twmin = 0.5 *  fiberArray.w + 0.5 * guide.sp - 2 * guide.r;
         tlen3 = fiberArray.len + fiberArray.safety + 2 * guide.r + (arrayInputs - 1) * guide.sp;
         if(cluster == 1)
            [struct, clusterInfo] = PlaceRect(struct, clusterInfo, col * tlen3 - guide.r - (arrayInputs - 0.5) * guide.sp, guide.w, guide.layer, guide.dtype);
         else
            [struct, clusterInfo] = PlaceRect(struct, clusterInfo, (col - 1) * tlen - tl0 + cluster * arrayInputs * guide.sp + tlen3 - guide.r - (arrayInputs - 0.5) * guide.sp, guide.w, guide.layer, guide.dtype);
         end
         [struct, clusterInfo] = PlaceArc(struct, clusterInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', guide.sp,'type', couplerArray.type);
         [struct, clusterInfo] = PlaceRect(struct, clusterInfo, (col - 1) * arrayInputs * guide.sp  + twmin * (twmin > 0), guide.w, guide.layer, guide.dtype);
         [struct, clusterInfo] = PlaceArc(struct, clusterInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', fiberArray.sp, 'type', couplerArray.type);
         [struct, clusterInfo] = PlaceRect(struct, clusterInfo, fiberArray.safety, guide.w, guide.layer, guide.dtype);
         
         finalMask = guideMask;
         
         info.pos(finalMask,:) = clusterInfo.pos;
         info.ori(finalMask) = clusterInfo.ori;
         info.length(finalMask, :) = clusterInfo.length;
         
         struct = PlaceRef(struct, clusterInfo, coupler);
         
         if(~isempty(couplerArray.text))
            strEl = cell(1, size(clusterInfo.pos(couplerArray.textIndex,:), 1));
            if(size(couplerArray.text) > 1)
               txt = couplerArray.text{1};
            else
               txt = [couplerArray.text num2str(ceil(finalMask(1)/arrayInputs))];
            end
            strEl{1} = gds_element('text', 'text', txt, 'xy', clusterInfo.pos(couplerArray.textIndex, :), 'layer', layerMap.TXT(1));
            struct = add_element(struct, strEl);
         end
         len = len + tlen3;
      else
         [struct, colInfo] = PlaceRect(struct, colInfo, col * tlen - tl0, guide.w, guide.layer, guide.dtype);
         [struct, colInfo] = PlaceArc(struct, colInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', guide.sp,'type', couplerArray.type);
         [struct, colInfo] = PlaceRect(struct, colInfo, (col - 1) * (cluster * arrayInputs * guide.sp), guide.w, guide.layer, guide.dtype);
         
         remClusterInfo = colInfo;
         for inputGuide = 1 : arrayInputs
            distance = diff(distances{inputGuide}');
            remGuides = size(remClusterInfo.pos, 1);
            tn = arrayInputs + 1 - inputGuide;
            clusterMask = tn:tn:tn*IOsPerCol;
            
            tdist = 0.5 * fiberArray.w - guide.r + 0.5 * guide.sp;            
            if(inputGuide == arrayInputs)
               [struct, remClusterInfo] = PlaceRect(struct, remClusterInfo, tdist, guide.w, guide.layer, guide.dtype);
               [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', distance(1 : remGuides - 1),'type', couplerArray.type);
            else
               tmask = zeros(1, remGuides - 1);       tmask(1:tn:end) = 1;       tmask(tn:tn:end) = -1;
               [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', distance(1 : remGuides - 1) + tdist * tmask,'type', couplerArray.type);
            end
            
            % Connect the one cluster to optical couplers
            clusterInfo = SplitInfo(remClusterInfo, clusterMask);
            
            tlen2 = ones(IOsPerCol,1) * fiberArray.safety;
            tlen2(1:2:IOsPerCol) = tlen2(1:2:IOsPerCol) + fiberArray.dx;
            [struct, clusterInfo] = PlaceRect(struct, clusterInfo, tlen2, guide.w, guide.layer, guide.dtype);
            
            % Save final info
            if(couplerArray.direction == 1)
               tMask = tn*IOsPerCol + 1 - clusterMask;
            else
               tMask = clusterMask;
            end
            finalMask = guideMask(tMask);
            
            info.pos(finalMask,:) = clusterInfo.pos;
            info.ori(finalMask) = clusterInfo.ori;
            info.length(finalMask, :) = clusterInfo.length;
            
            guideMask = guideMask(setxor(tMask, 1:tn*IOsPerCol));
            
            struct = PlaceRef(struct, clusterInfo, coupler);
            
            if((inputGuide == couplerArray.textIndex) && (~isempty(couplerArray.text)))
               strEl = cell(1, size(clusterInfo.pos, 1));
               for index = 1 : size(clusterInfo.pos, 1)
                  if(size(couplerArray.text) > 1)
                     txt = couplerArray.text{index};
                  else
                     txt = [couplerArray.text num2str(ceil(finalMask(index)/arrayInputs))];
                  end
                  strEl{index} = gds_element('text', 'text', txt, 'xy', clusterInfo.pos(index , :), 'layer', layerMap.TXT(1));
               end
               struct = add_element(struct, strEl);
            end
            
            % Relay the clusters farther away
            if(tn > 1)
               
               remClusterInfo = SplitInfo(remClusterInfo, setxor(clusterMask, 1:tn*IOsPerCol));
               
               [struct, remClusterInfo] = PlaceRect(struct, remClusterInfo, fiberArray.len + fiberArray.safety + fiberArray.dx + guide.r, guide.w, guide.layer, guide.dtype);
               [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, -turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', guide.sp,'type', couplerArray.type);
               [struct, remClusterInfo] = PlaceRect(struct, remClusterInfo, fiberArray.sp - (IOsPerCol - 1) * dy - ((tn - 1) * (1 + IOsPerCol) - 3) * guide.sp -  4 * guide.r, guide.w, guide.layer, guide.dtype);
               [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, -turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true,'type',couplerArray.type);
               [struct, remClusterInfo] = PlaceRect(struct, remClusterInfo, fiberArray.len + fiberArray.safety + fiberArray.dx + guide.r, guide.w, guide.layer, guide.dtype);
               [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true,'type',couplerArray.type);
            end
         end
         
         len = len + tlen;
      end
   end
else
   
   %% Unflipped output
   for col = 1 : cols
      
      % Je devrais tout simplement les sorter pour jamais avoir de trouble.
      % En plus ca serait indépendant de l'ordre des positions;
      guideMask = (1 : cluster * arrayInputs) + (col - 1) * cluster * arrayInputs;
      guideMask = guideMask(guideMask <= rows);
      if(couplerArray.direction == 1)
         guideMask = rows - guideMask + 1;
      end
      
      IOsPerCol = length(guideMask)/arrayInputs;
      colInfo = SplitInfo(info, guideMask);
      
      if(IOsPerCol == 1)    % Simplified case where there is only space for one set of IOs per column
         clusterInfo = colInfo;
         
         twmin = (arrayInputs * guide.sp + guide.r) -  0.5 * fiberArray.w;
         tlen3 = fiberArray.len + fiberArray.safety + 2 * guide.r + (arrayInputs - 1) * guide.sp;
         if(cluster == 1)
            [struct, clusterInfo] = PlaceRect(struct, clusterInfo, (col - 1) * tlen3, guide.w, guide.layer, guide.dtype);
         else
            [struct, clusterInfo] = PlaceRect(struct, clusterInfo, (col - 1) * tlen - tl0 + cluster * arrayInputs * guide.sp, guide.w, guide.layer, guide.dtype);
         end
         [struct, clusterInfo] = PlaceArc(struct, clusterInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', guide.sp,'type', couplerArray.type);
         [struct, clusterInfo] = PlaceRect(struct, clusterInfo, (col - 1) * arrayInputs * guide.sp - twmin * (twmin < 0), guide.w, guide.layer, guide.dtype);
         [struct, clusterInfo] = PlaceArc(struct, clusterInfo, -turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', fiberArray.sp, 'type', couplerArray.type);
         [struct, clusterInfo] = PlaceRect(struct, clusterInfo, fiberArray.safety, guide.w, guide.layer, guide.dtype);
         
         finalMask = guideMask;
         
         info.pos(finalMask,:) = clusterInfo.pos;
         info.ori(finalMask) = clusterInfo.ori;
         info.length(finalMask, :) = clusterInfo.length;
         
         struct = PlaceRef(struct, clusterInfo, coupler);
         
         if(~isempty(couplerArray.text))
            strEl = cell(1, size(clusterInfo.pos(couplerArray.textIndex,:), 1));
            if(size(couplerArray.text) > 1)
               txt = couplerArray.text{1};
            else
               txt = [couplerArray.text num2str(ceil(finalMask(1)/arrayInputs))];
            end
            strEl{1} = gds_element('text', 'text', txt, 'xy', clusterInfo.pos(couplerArray.textIndex, :), 'layer', layerMap.TXT(1));
            struct = add_element(struct, strEl);
         end
         len = len + tlen3;
      else
         [struct, colInfo] = PlaceRect(struct, colInfo, col * tlen - tl0, guide.w, guide.layer, guide.dtype);
         [struct, colInfo] = PlaceArc(struct, colInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', guide.sp,'type', couplerArray.type);
         [struct, colInfo] = PlaceRect(struct, colInfo, (col - 1) * (cluster * arrayInputs * guide.sp), guide.w, guide.layer, guide.dtype);
         
         remClusterInfo = colInfo;
         for inputGuide = 1 : arrayInputs
            distance = diff(distances{inputGuide}');
            remGuides = size(remClusterInfo.pos, 1);
            tn = arrayInputs + 1 - inputGuide;
            clusterMask = tn:tn:tn*IOsPerCol;
            
            [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', distance(1 : remGuides - 1),'type', couplerArray.type);
            
            % Connect the one cluster to optical couplers
            clusterInfo = SplitInfo(remClusterInfo, clusterMask);
            
            tlen2 = ones(IOsPerCol,1) * (fiberArray.len + fiberArray.safety);
            tlen2(1:2:IOsPerCol) = tlen2(1:2:IOsPerCol) + fiberArray.dx;
            
            [struct, clusterInfo] = PlaceRect(struct, clusterInfo, tlen2, guide.w, guide.layer, guide.dtype);
            [struct, clusterInfo] = PlaceArc(struct, clusterInfo, -turnAngle, guide.r, guide.w, guide.layer, guide.dtype,'type', couplerArray.type);
            [struct, clusterInfo] = PlaceRect(struct, clusterInfo, 0.5 * fiberArray.w - 2 * guide.r + 0.5 * guide.sp, guide.w, guide.layer, guide.dtype);
            [struct, clusterInfo] = PlaceArc(struct, clusterInfo, -turnAngle, guide.r, guide.w, guide.layer, guide.dtype,'type', couplerArray.type);
            [struct, clusterInfo] = PlaceRect(struct, clusterInfo, fiberArray.safety, guide.w, guide.layer, guide.dtype);
            
            
            % Save final info
            if(couplerArray.direction == 1)
               tMask = tn*IOsPerCol + 1 - clusterMask;
            else
               tMask = clusterMask;
            end
            finalMask = guideMask(tMask);
            
            info.pos(finalMask,:) = clusterInfo.pos;
            info.ori(finalMask) = clusterInfo.ori;
            info.length(finalMask, :) = clusterInfo.length;
            
            guideMask = guideMask(setxor(tMask, 1:tn*IOsPerCol));
            
            struct = PlaceRef(struct, clusterInfo, coupler);
            
            if((inputGuide == couplerArray.textIndex) && (~isempty(couplerArray.text)))
               strEl = cell(1, size(clusterInfo.pos, 1));
               for index = 1 : size(clusterInfo.pos, 1)
                  if(size(couplerArray.text) > 1)
                     txt = couplerArray.text{index};
                  else
                     txt = [couplerArray.text num2str(ceil(finalMask(index)/arrayInputs))];
                  end
                  strEl{index} = gds_element('text', 'text', txt, 'xy', clusterInfo.pos(index , :), 'layer', layerMap.TXT(1));
               end
               struct = add_element(struct, strEl);
            end
            
            % Relay the clusters farther away
            if(tn > 1)
               remClusterInfo = SplitInfo(remClusterInfo, setxor(clusterMask, 1:tn*IOsPerCol));
               
               [struct, remClusterInfo] = PlaceRect(struct, remClusterInfo, fiberArray.len + fiberArray.safety + fiberArray.dx + guide.r, guide.w, guide.layer, guide.dtype);
               [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, -turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', guide.sp,'type', couplerArray.type);
               [struct, remClusterInfo] = PlaceRect(struct, remClusterInfo, fiberArray.sp - (IOsPerCol - 1) * dy - ((tn - 1) * (1 + IOsPerCol) - 3) * guide.sp -  4 * guide.r, guide.w, guide.layer, guide.dtype);
               [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, -turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true,'type',couplerArray.type);
               [struct, remClusterInfo] = PlaceRect(struct, remClusterInfo, fiberArray.len + fiberArray.safety + fiberArray.dx + guide.r, guide.w, guide.layer, guide.dtype);
               [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true,'type',couplerArray.type);
            end
         end
         
         len = len + tlen;
      end
   end
   
end

info = SplitInfo(info, originalOrder);  % Put info back in its original order

if(cluster == 1)
   w = spacing(end) + (arrayInputs - 1) * fiberArray.sp + 0.5 * fiberArray.w + 2 * guide.r + twmin * (twmin > 0);
else
   w = spacing(end) + (arrayInputs - 1) * fiberArray.sp + (cluster - 1) * dy + fiberArray.w + (arrayInputs) * guide.sp + 2 * guide.r;
end
arraySize = [len, w];

return



function distances = CalculateSpreadDistances(arrayInputs, cluster, guide, dy)

distances = cell(arrayInputs, 1);
for ii = 1 : arrayInputs
   tn = arrayInputs + 1 - ii;
   tdy = dy * ceil((1:(cluster * tn))' / tn);
   tdIn = repmat((0:guide.sp:(guide.sp * (tn - 1)))', cluster, 1);
   distances{ii} = tdy + tdIn;
end

return