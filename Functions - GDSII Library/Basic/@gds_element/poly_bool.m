function [bo] = poly_bool(ba, bb, op, varargin);
%function [bo] = poly_bool(ba, bb, op, varargin);
%
% poly_bool - method for boolean set algebra on 
%             boundary elements.
%
%             bo = poly_bool(ba, bb, op)
%          
%             IMPORTANT: user and database units must be defined
%             before calls to 'poly_bool' either by creating the 
%             library object or with a call to 'gdsii_units'.
%             This is necessary because the boolean operations
%             are performed on the database grid.
%
% ba :    input boundary element. If ba is a compound element
%         (i.e. contains more than one polygon) the boolean set
%         operation is applied to all polygons in sequence.
% bb :    2nd input boundary element (may be a compound element)
% op :    operation applied to the inputs:
%           'and'  -  intersection of both sets; points are in ba
%                     and also in bb
%           'or'   -  union of both sets; points are either in ba
%                     or bb. 
%           'xor'  -  points that are either in ba or in bb, but
%                     not in both sets.
%           'notb' -  set difference; points that are in ba and 
%                     not in bb.
% varargin :  property - value pairs that modify the properties of
%             the output boundary element. 
% bo :    output boundary element, the result of the boolean set
%         operation. Can contain more than one polygon. By default,
%         the output polygon is on the same layer as ba and has the 
%         same data type.
%
% Example:
%          out = poly_bool(square, circle, 'or', 'layer',10);
%       
%          returns a boundary element describing the set union of
%          two elements 'square' and 'circle'. The output element
%          is on layer 10.
%
% NOTES: 
% 1) Some operations can result in complex polygons containing holes.
% Since these are difficult to convert into simple polygons the
% function currently exits with an error when the output polygons are
% not all simple.
%
% 2) This function can use either the polygon clipper library by 
% Angus Johnson (www.angusj.com), or the General Polygon 
% Clipper library by Alan Murta (www.cs.man.ac.uk/~toby/gpc/).

% Initial version, Ulf Griesman, August 2012

% global variables
global gdsii_uunit;

% check arguments
if nargin < 3
   error('gds_element.poly_bool :  expecting at least 3 input arguments');
end

% only works with boundary elements
if ~strcmp(get_etype(ba.data.internal), 'boundary') || ...
   ~strcmp(get_etype(bb.data.internal), 'boundary')
   error('gds_element.poly_bool :  input elements must be boundary elements');
end

% units must be defined
if isempty(gdsii_uunit) 
   fprintf('%s', '\n  +-------------------- WARNING -----------------------+\n');
   fprintf('%s', '  | Units are not defined; setting uunit/dbunit = 1.   |\n'); 
   fprintf('%s', '  | Define units by creating the library object or     |\n'); 
   fprintf('%s', '  | by calling gdsii_units.                            |\n'); 
   fprintf('%s', '  +----------------------------------------------------+\n\n');
   duf = 1;
else
   duf = gdsii_uunit;      % conversion factor to db units
end

% apply boolean set operation
[xyo, hf] = poly_boolmex(ba.data.xy, bb.data.xy, op, duf);
if any(hf)
   error('gds_element.poly_bool :  a polygon with a hole was created.');
end

% create a boundary element for the output polygons
bo = ba;
bo.data.xy = xyo;

% add any property arguments
if ~isempty(varargin)
   bo.data.internal = set_element_data(bo.data.internal, varargin);
end

return
