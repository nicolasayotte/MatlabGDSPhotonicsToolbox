function [structure, info] = PlaceARef(structure, info, refname, arrayPar, arrayNorm, arrayMove, varargin)
%PLACEAREF places an array of reference
%Author : Nicolas Ayotte                                   Creation date : 28/11/2014
% 
%     The whole placement of this array is relative to the cursor position and orientation
%     where all references to parallel means in the same direction as the cursor and
%     normal means normal to it.
% 
%     ARGUMENT NAME     SIZE        DESCRIPTION
%     refname           1           cell name
%     arrayPar          1 x p       multipliers for the parallel vector
%     arrayNorm         1 x n       multipliers for the normal vector
%     arrayMove         1 x 2       [parallel length, normal length]
%
%     See also PlaceArc, PlaceTaper, PlaceSBend, PlaceRef

rows = size(info.pos, 1);


%% Default value for valid options
options.ang = 0;
options.reflect = 0;
options = ReadOptions(options, varargin{ : });

for row = 1 : rows
      vectorPar = RotTransXY([arrayMove(1), 0], [0, 0], info.ori(row));
      vectorNorm = RotTransXY([0, arrayMove(2)], [0, 0], info.ori(row));
      [nPar, nNorm] = meshgrid(arrayPar, arrayNorm);
      
      x = info.pos(row, 1) + nPar * vectorPar(1) + nNorm * vectorNorm(1);
      y = info.pos(row, 2) + nPar * vectorPar(2) + nNorm * vectorNorm(2);
      xy = [x(:), y(:)];
      
      strans.angle = info.ori(row) + options.ang;
      strans.reflect = options.reflect;
      structure = add_ref(structure, refname, 'xy', xy, 'strans', strans);
      
      info.ori(row) = ConstrainAngle(info.ori(row) + 180);
end

end