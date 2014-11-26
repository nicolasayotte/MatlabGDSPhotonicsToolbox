function [chp] = gdsii_checky(tname, N, minel, maxel, pos, repl, ang, fmt, layer);
%function [chp] = gdsii_checky(tname, N, minel, maxel, pos, repl, ang, fmt, layer);
%
% gdsii_checky :  returns a nested checker board pattern with
%                 alternating rows of solid and checkered patterns. 
%
% tname : (Optional) name of the top level structure.
%         Default is CHECKY_TOP.
% N :     (Optional) size of checkerboard pattern (NxN). 
%         Default is 10. 
% minel : (Optional) length of the smallest (lowest level) box edge 
%         the checker board is composed of in user units. Default is 1.
% maxel : (Optional) length of the largest box edge (top level) in
%         user units. Default is 10000. maxel should be an integer
%         multiple of minel.
% pos :   (Optional) position of the left lower corner of the
%         pattern. Default is [0,0].
% repl :  (Optional) replicate the checkerbox pattern using a 
%         repl(1) x repl(2) tiling. repl(1) is the number of rows, 
%         repl(2) the number of columns. Default is [1,1] (no
%         replication). 
% ang :   (Optional) rotate the structure by an angle
%         'ang' in radians. Default is 0 (no rotation). 
% fmt :   (Optional) format structure defining the format of the
%         labels for the size of blocks. 
%             fmt.scale : height of numbers as fraction of block
%                         width. Default is 0.2
%             fmt.str :   format string for numbers. Default is '%d'.
% layer : (Optional) layer to which the pattern is written.
%         Default is 1.
%
% chp :   cell array of gds_structure objects.

% initial version: Ulf Griesmann, NIST, Jan 2011
% add solid boxes and labels: u.g., Feb 2011
% return gds_structure objects: U.G., NIST, November 2012
%

% check arguments
if nargin < 9, layer = []; end
if nargin < 8, fmt = []; end
if nargin < 7, ang = []; end
if nargin < 6, repl = []; end
if nargin < 5, pos = []; end
if nargin < 4, maxel = []; end
if nargin < 3, minel = []; end
if nargin < 2, N = []; end
if nargin < 1, tname = []; end

if isempty(tname), tname = 'CHECKY_TOP'; end
if isempty(N), N = 10; end;
if isempty(minel), minel = 1; end;
if isempty(maxel), maxel = 10000; end;
if isempty(pos), pos = [0,0]; end;
if isempty(repl), repl = [1,1]; end;
if isempty(ang), ang = 0; end;
if isempty(fmt) 
   fmt.scale = 0.2; 
   fmt.str = '%d'; 
else
   if ~isfield(fmt, 'scale')
      fmt.scale = 0.2;
   end
   if ~isfield(fmt, 'str')
      fmt.str = '%d';
   end
end
if isempty(layer), layer = 1; end;

% The checky pattern consists of solid boxes and nested checkered 
% boxes. The nested checkered boxes are composed recursively from
% the checky pattern of the preceeding level. The smallest checky box
% and solid box are identical.

% Define the smallest box using a boundary.
sbox = [0,0; ...
        minel,0; ...
        minel,minel; ...
        0,minel; ...
        0,0];

% Create structures with solid boxes derived from the smallest box
k = 0;
cwid = minel;
chp = {};
while cwid < maxel
  
   % boxes
   boxname = sprintf('SOLIDBOX_%d', k);
   chp{end+1} = gds_structure(boxname, ...
                              gds_element('boundary', 'xy',sbox, 'layer',layer));   
   k = k + 1;
   cwid = N * cwid;  % calculate the size of the next larger box
   sbox = N * sbox;
   
end

% smallest checkybox is the same as the smallest solid box
cb0 = gds_structure('CHECKYBOX_0');
chp{end+1} = add_ref(cb0, 'SOLIDBOX_0', 'xy',[0,0]);

% create the hierarchy of checker patterns using nested AREFs
cwid = minel;              % this level box width
nwid = N * cwid;           % next higher level box width
level = 0;                 % current level of iteration
adim.row = 1;
adim.col = floor(N/2);

% build up the pattern from the smallest to the largest
while cwid < maxel
   
   % next level
   level = level + 1;
   
   % add a label between all but the smallest solid boxes
   if level > 1
      labelname = sprintf('CHECKYLBL_%d', level-1);
      labelheight = fmt.scale * cwid;
      label = sprintf(fmt.str, cwid);
      [lblxy, labelwidth] = gdsii_ptext(label, [0,0], labelheight, layer);
      if labelwidth > 0.8*cwid  % scale down to fit in width
         labelheight = (0.8*cwid / labelwidth) * cwid / 5;
         [lblxy, labelwidth] = gdsii_ptext(label, [0,0], labelheight, layer);
      end
      chp{end+1} = gds_structure(labelname, lblxy);
   end
      
   % contains a structure with checkerlines
   nxtname = sprintf('CHECKYBOX_%d', level);
   nxts = gds_structure(nxtname);
   
   % lay out N stacked horizontal lines of boxes of the previous
   % level alternating with lines of solid boxes
   for k = 1:N
      if rem(k,2) == 1  % odd numbered line has checkered boxes
        
         xy = [0,(k-1)*cwid; nwid,(k-1)*cwid; 0,k*cwid];
         nxts = add_ref(nxts, sprintf('CHECKYBOX_%d', level-1), 'xy',xy, 'adim',adim);
         
      else              % even numbered line has solid boxes
        
         xy = [cwid,(k-1)*cwid; nwid+cwid,(k-1)*cwid; 0,k*cwid];
         nxts = add_ref(nxts, sprintf('SOLIDBOX_%d', level-1), 'xy',xy, 'adim',adim);
         
         % add size labels
         if level > 1
            xy = [0,(k-1)*cwid; nwid,(k-1)*cwid; 0,k*cwid] + ...
                 repmat(0.1*cwid, 3, 2);
            nxts = add_ref(nxts, labelname, 'xy',xy, 'adim',adim);
         end
         
      end
   end

   % add to structure list
   chp{end+1} = nxts;

   % prepare for the next level
   cwid = nwid;
   nwid = N * cwid;
   
end

% tile the pattern if desired
if repl(1) > 1 || repl(2) > 1
   arc = [0,0; repl(2)*cwid,0; 0,repl(1)*cwid];
   adim.row = repl(1);
   adim.col = repl(2);
   rs = gds_structure('REPL_CHECKY');
   chp{end+1} = add_ref(rs, sprintf('CHECKYBOX_%d', level), 'xy',arc, 'adim',adim);
end

% move everything to the desired position and define a 
% top level structure which also rotates and translates 
% the checky pattern if required.
tls = gds_structure(tname);

% structure transformation parameters
strans.angle = 180 * ang / pi;
if repl(1) > 1 || repl(2) > 1
   rsname = 'REPL_CHECKY';
else
   rsname = sprintf('CHECKYBOX_%d', level);
end
chp{end+1} = add_ref(tls, rsname, 'xy',pos, 'strans',strans);

return
