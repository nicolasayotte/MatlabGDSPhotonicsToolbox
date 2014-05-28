function [structure, infoThru, infoInput, infoContra, infoCross] = PlaceMicroring(structure, infoThru, ring, wid, layer, dtype, varargin)

%PLACEMICRORING Place a microring in a information structure
%Author: Nicolas Ayotte                                     Creation date: 12/05/2014
%
%     This function receives an input GDS structure and the parameters for one or
%     many tapers to create and place at positions and orientations determined by the
%     info variable. It then updates info to the output positions.
%
%     [struct, info] = PlaceMicroring(struct, len, taper, info, varargin)
%
%     VARIABLE NAME   SIZE        DESCRIPTION
%     len             m|1, 1      straight section length
%     wid             m|1, n|1    straight section widths
%     layer           m|1, n      straight section layers
%     datatype        m|1, n      straight section datatypes
%     ring            m|1         ring structure
%     info.pos        m, 2        current position
%     info.ori        m|1         orientation angle in degrees
%     infoInput.pos   m, 2        input position
%     infoInput.ori   m|1         inverse of input orientation
%
%     See also PLACERECT, PLACEARC, PLACESBEND

rows = size(infoThru.pos, 1);

% Default value for valid options
ring = ReadOptions(ring, varargin{:});
[wid, layer, dtype, ring, infoThru.ori] = NumberOfRows(rows, wid, layer, dtype, ring, infoThru.ori);
infoInput = InvertInfo(infoThru);


%% Ring element
infoOut = cell(rows, 1);
infoCross = cell(rows, 1);
infoContra = cell(rows, 1);

for row = 1 : rows
  rowInfoOut = SplitInfo(infoThru, row);
  rowInfoRing = StransInfo(rowInfoOut, RotTransXY([0, ring(row).gap + ring(row).w(1)/2 + wid(1)/2], [0, 0], rowInfoOut.ori), struct());
  rowInfoCross = StransInfo(rowInfoOut, RotTransXY([0, 2 * ring(row).gap + 2 * ring(row).radiusmax(1) + wid(1)], [0, 0], rowInfoOut.ori), struct());
  
  % Input straight segment
  [structure, rowInfoOut] = PlaceRect(structure, rowInfoOut, ring(row).straightLength, wid(row,:), layer(row,:), dtype(row,:));
  
  % Microring or microdisk
  [structure, rowInfoRing] = PlaceRect(structure, rowInfoRing, ring(row).straightLength, ring(row).w, ring(row).layer, ring(row).dtype);
  [structure, rowInfoRing] = PlaceArc(structure, rowInfoRing, 180, ring(row).radius(1), ring(row).w, ring(row).layer, ring(row).dtype, 'type', 'normal');
  [structure, rowInfoRing] = PlaceRect(structure, rowInfoRing, ring(row).straightLength, ring(row).w, ring(row).layer, ring(row).dtype);
  [structure] = PlaceArc(structure, rowInfoRing, 180, ring(row).radius(1), ring(row).w, ring(row).layer, ring(row).dtype, 'type', 'normal');

  % Output straight segment
  [structure, rowInfoCross, tinfoContra] = PlaceRect(structure, rowInfoCross, ring(row).straightLength, wid(row,:), layer(row,:), dtype(row,:));
  
  infoOut{row} = rowInfoOut;
  infoCross{row} = rowInfoCross;
  infoContra{row} = tinfoContra;
end

infoThru = MergeInfo(infoOut{:});
infoCross = MergeInfo(infoCross{:});
infoContra = MergeInfo(infoContra{:});

