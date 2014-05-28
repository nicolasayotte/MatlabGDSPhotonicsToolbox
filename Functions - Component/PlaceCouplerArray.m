function [struct, info, infoInput, arraySize] = PlaceCouplerArray(struct, info, arrayInputs, guide, fiberArray, coupler, varargin)
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
%     couplerArray.direction  1   clockwise or counter-clockwise pattern
%     coupelrArray.type       1   'cladding', 'normal', 'metal'
%
%     See also PlaceRect, PlaceArc, PlaceTaper, PlaceSBend

rows = size(info.pos, 1);


%% Varargin and parameters definitions
% CouplerArray fields definition
couplerArray.direction = 1;
couplerArray.type = 'normal';
couplerArray = ReadOptions(couplerArray, varargin{:});

if(abs(couplerArray.direction) ~= 1)
  error('couplerArray.direction must equal 1 or -1');
end

turnAngle = 90 * couplerArray.direction;
if(isempty(info.length)); info.length = zeros(rows, length(info.neff)); end

% Sort the entry positions
[info, originalOrder] = CheckParallelAndNormal(info);
infoInput = InvertInfo(info);

% Calculate the maximum number of couplers per input per column
cluster = floor((fiberArray.sp - guide.r)/((2*arrayInputs - 1) * guide.sp + fiberArray.w));
cols = ceil(rows / (cluster * arrayInputs));      % Get the number of required columns

% This is the width of a column
tlen = fiberArray.len + fiberArray.safety + fiberArray.dx + guide.r + (0.5 + 2 * cluster * arrayInputs) * guide.sp;
tl0 = guide.r + (cluster * arrayInputs + 0.5) * guide.sp;

% Adapt the dy if it was underestimated
dy = max([fiberArray.dy, arrayInputs * guide.sp + fiberArray.w]);

distances = CalculateSpreadDistances(arrayInputs, cluster, guide, dy);

for col = 1 : cols
  
  % Je devrais tout simplement les sorter pour jamais avoir de trouble.
  % En plus ca serait indépendant de l'ordre des positions;
  guideMask = (1 : cluster * arrayInputs) + (col - 1) * cluster * arrayInputs;
  guideMask = guideMask(guideMask <= rows);
  if(couplerArray.direction == 1)
    guideMask = rows - guideMask + 1;
  end
  
  tnP = length(guideMask)/arrayInputs;
  colInfo = SplitInfo(info, guideMask);
  
  [struct, colInfo] = PlaceRect(struct, colInfo, col * tlen - tl0, guide.w, guide.layer, guide.dtype);
  [struct, colInfo] = PlaceArc(struct, colInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', guide.sp,'type', couplerArray.type);
  [struct, colInfo] = PlaceRect(struct, colInfo, (col - 1) * (cluster * arrayInputs * guide.sp), guide.w, guide.layer, guide.dtype);
  
  remClusterInfo = colInfo;
  for inputGuide = 1 : arrayInputs
    distance = diff(distances{inputGuide}');
    remGuides = size(remClusterInfo.pos, 1);
    tn = arrayInputs + 1 - inputGuide;
    clusterMask = tn:tn:tn*tnP;
    
    [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', distance(1 : remGuides - 1),'type', couplerArray.type);
    
    
    % Connect the one cluster to optical couplers
    clusterInfo = SplitInfo(remClusterInfo, clusterMask);
    
    tlen2 = ones(tnP,1) * (fiberArray.len + fiberArray.safety);
    tlen2(1:2:tnP) = tlen2(1:2:tnP) + fiberArray.dx;
    
    [struct, clusterInfo] = PlaceRect(struct, clusterInfo, tlen2, guide.w, guide.layer, guide.dtype);
    [struct, clusterInfo] = PlaceArc(struct, clusterInfo, -turnAngle, guide.r, guide.w, guide.layer, guide.dtype,'type', couplerArray.type);
    [struct, clusterInfo] = PlaceRect(struct, clusterInfo, 0.5 * fiberArray.w - 2 * guide.r + 0.5 * guide.sp, guide.w, guide.layer, guide.dtype);
    [struct, clusterInfo] = PlaceArc(struct, clusterInfo, -turnAngle, guide.r, guide.w, guide.layer, guide.dtype,'type', couplerArray.type);
    [struct, clusterInfo] = PlaceRect(struct, clusterInfo, fiberArray.safety, guide.w, guide.layer, guide.dtype);
    
    % Save final info
    if(couplerArray.direction == 1)
      tMask = tn*tnP + 1 - clusterMask;
    else
      tMask = clusterMask;
    end
    finalMask = guideMask(tMask);
    info.pos(finalMask,:) = clusterInfo.pos;
    info.ori(finalMask) = clusterInfo.ori;
    info.length(finalMask, :) = clusterInfo.length;
    guideMask = guideMask(setxor(tMask, 1:tn*tnP));
    
    struct = PlaceRef(struct, clusterInfo, coupler);
    
    % Relay the clusters farther away
    if(tn > 1)
      remClusterInfo = SplitInfo(remClusterInfo, setxor(clusterMask, 1:tn*tnP));
      
      [struct, remClusterInfo] = PlaceRect(struct, remClusterInfo, fiberArray.len + fiberArray.safety + fiberArray.dx + guide.r, guide.w, guide.layer, guide.dtype);
      [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, -turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true, 'distance', guide.sp,'type', couplerArray.type);
      [struct, remClusterInfo] = PlaceRect(struct, remClusterInfo, fiberArray.sp - (tnP - 1) * dy - ((tn - 1) * (1 + tnP) - 3) * guide.sp -  4 * guide.r, guide.w, guide.layer, guide.dtype);
      [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, -turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true,'type',couplerArray.type);
      [struct, remClusterInfo] = PlaceRect(struct, remClusterInfo, fiberArray.len + fiberArray.safety + fiberArray.dx + guide.r, guide.w, guide.layer, guide.dtype);
      [struct, remClusterInfo] = PlaceArc(struct, remClusterInfo, turnAngle, guide.r, guide.w, guide.layer, guide.dtype, 'group', true,'type',couplerArray.type);
    end
  end
end

info = SplitInfo(info, originalOrder);  % Put info back in its original order

len = cols * tlen - tl0 + guide.r + (tnP * arrayInputs - 0.5) * guide.sp;
w = (arrayInputs - 1) * fiberArray.sp + (cluster - 1) * dy + fiberArray.w + (rows + arrayInputs) * guide.sp + 2 * guide.r;
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