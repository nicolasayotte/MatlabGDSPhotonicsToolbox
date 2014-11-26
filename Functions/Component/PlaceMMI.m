function [structure, InfoOut, infoIn] = PlaceMMI(structure, info, wgIn, wgOut, mmi, varargin)
%PLACEMMI place a multi-mode interferometer
%Author: Alexandre D. Simard                                Creation date: 04/08/2014
%
%     [structure, InfoOut, infoIn] = PlaceMMI(structure, info, wgIn, wgOut, mmi, varargin)
%
%
%     OPTION NAME       SIZE        DESCRIPTION
%     'nout'            1           [] number of outputs
%                                   by default it is the same as the number of inputs
%     'sBendOut'        1           [true] place a s-bend at the output
%     'taperIn'         1           [true] place a taper at the input
%     'taperOut'        1           [true] place a taper at the output
%     'sBendLength'     1           [0] length of the s-bends (0: minimumLength)
%     'backgroundRect'  1           [false] for the s-bend
%     'type'            1           ['cladding'] for the s-bend
%
%
%     See also PlaceRect, PlaceArc, PlaceTaper, PlaceSBend

rows = size(info.pos, 1);


%% Default values for valid options
options.nout = [];
options.sBendOut = true;
options.taperOut = true;
options.taperIn = true;
options.sBendLength = 0;
options.backgroundRect = false;
options.type = 'cladding';
options = ReadOptions(options, varargin{:});


%% Parameter validation
if options.sBendOut
   if ~options.taperOut
      error('A taper is required to use the output sbend');
   end
end

if options.nout ~= abs(round(options.nout))
   error('nout must be a positive integer');
end

if ~isempty(options.nout)
   if rows > 1
      error('When specifying nout, only one input waveguide is allowed');
   end
   mmi.nout = options.nout;
   mmi.len = mmi.len / 4;
else
   mmi.nout = rows;
end

infoIn = InvertInfo(info);


%% Distance between input waveguides of the MMI and sbend length
sectionWidth = min(mmi.w)/(mmi.nout); % subsection of MMI width
inputDistance = sectionWidth;


%% Input waveguides sbent
if (rows > 1)
   %    [structure, info] = PlaceRect(structure, info, 5, wgIn.w, wgIn.layer, wgIn.dtype);
   %    [structure, info, infodrcclean] = PlaceSBend(structure, info, options.sBendLength, 0, wgIn.r, wgIn.w, wgIn.layer, wgIn.dtype, ...
   [structure, info] = PlaceSBend(structure, info, options.sBendLength, 0, wgIn.r, wgIn.w, wgIn.layer, wgIn.dtype, ...
      'group', true, 'distance', inputDistance, 'backgroundRect', options.backgroundRect, ...
      'type', options.type, 'minimumLength', ~(options.sBendLength > 0));
   %    infodrccleanpos = mean(infodrcclean.pos);
   %    infodrcclean = InvertInfo(SplitInfo(infodrcclean, 1));infodrcclean.pos = infodrccleanpos;
%    [structure, info] = PlaceRect(structure, info, 5, wgIn.w, wgIn.layer, wgIn.dtype);
end


%% Input waveguides taper
if options.taperIn
   if rows == 1
      taper = Taper(wgIn.w, [sectionWidth * mmi.ff, mmi.w(2)], mmi.layer, mmi.dtype);
   else
      taper = Taper([wgIn.w(1), mmi.w(2) - sectionWidth], [sectionWidth * mmi.ff, mmi.w(2) - sectionWidth], mmi.layer, mmi.dtype);
   end
   [structure, info] = PlaceTaper(structure, info, taper, mmi.tapl);
end


%% MMI rectangle
if (rows > 1)
   
   mmiWidth = mmi.w/2;
   mmiWidth(2) = mmi.w(2) - sectionWidth;
   [structure, info] = PlaceRect(structure, info, mmi.len, mmiWidth, mmi.layer, mmi.dtype);
   
else
   
   [structure, info] = PlaceRect(structure, info, mmi.len, mmi.w, mmi.layer, mmi.dtype);
   [~, info1] = PlaceArc(structure, info, -90, 0, 0, 0, 0, 'type', 'metal');
   [~, info2] = PlaceArc(structure, info, 90, 0, 0, 0, 0, 'type', 'metal');
   
   if mod(mmi.nout, 2)
      
      devlen =  sectionWidth;
      for ii = 1:(mmi.nout-1)/2-1
         info1 = MergeInfo(info1, info1);
         info2 = MergeInfo(info2, info2);
         devlen = [devlen, devlen(end) + sectionWidth];
      end
      [~, info1] = PlaceRect(structure, info1, devlen', 0, mmi.layer(1), mmi.dtype(1));
      [~, info2] = PlaceRect(structure, info2, devlen', 0, mmi.layer(1), mmi.dtype(1));
      [~, info1] = PlaceArc(structure, info1, 90, 0, 0, mmi.layer, mmi.dtype, 'type', 'metal');
      [~, info2] = PlaceArc(structure, info2, -90, 0, 0, mmi.layer, mmi.dtype, 'type', 'metal');
      info = CheckParallelAndNormal(MergeInfo(info, info1, info2));
      
   else
      
      devlen =  sectionWidth/2;
      for ii = 1:(mmi.nout/2)-1
         info1 = MergeInfo(info1, info1);
         info2 = MergeInfo(info2, info2);
         devlen = [devlen, devlen(end) + sectionWidth];
      end
      [~, info1] = PlaceRect(structure, info1, devlen', 0, mmi.layer(1), mmi.dtype(1));
      [~, info2] = PlaceRect(structure, info2, devlen', 0, mmi.layer(1), mmi.dtype(1));
      [~, info1] = PlaceArc(structure, info1, 90, 0, 0, mmi.layer, mmi.dtype, 'type', 'metal');
      [~, info2] = PlaceArc(structure, info2, -90, 0, 0, mmi.layer, mmi.dtype, 'type', 'metal');
      info = CheckParallelAndNormal(MergeInfo(info1, info2));
   end   
   
end


%% Out waveguides taper
if options.taperOut
   taper = Taper([sectionWidth * mmi.ff, mmi.w(2) - sectionWidth], [wgOut.w(1), mmi.w(2) - sectionWidth], mmi.layer, mmi.dtype);
   [structure, info] = PlaceTaper(structure, info, taper, mmi.tapl);
   if options.sBendOut
%          [structure, info] = PlaceRect(structure, info, 5, wgOut.w, wgOut.layer, wgOut.dtype);
         [structure, info] = PlaceSBend(structure, info, options.sBendLength, 0, wgOut.r, wgOut.w, wgOut.layer, wgOut.dtype, ...
            'group', true, 'distance', wgOut.sp, 'backgroundRect', options.backgroundRect, ...
            'type', options.type, 'minimumLength', ~(options.sBendLength > 0));
%          [structure, info] = PlaceRect(structure, info, 5, wgOut.w, wgOut.layer, wgOut.dtype);
   end
end

InfoOut = info;

end