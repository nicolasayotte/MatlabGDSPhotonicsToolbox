% Octave & MATLAB Toolbox for GDS II libraries
% --------------------------------------------
%
% The functions in this toolbox are used to generate layout databases
% for direct write lithography tools in GDS II format. They are
% particularly useful when a layout is the result of a calculation.
% Matlab / Octave can then be used as a macro language for writing the
% layout. Most functionality of the GDS II format (elements,
% structures) is supported with the exception of some arcane corners.
%
% The functions and methods of the toolbox are grouped in the
% following directories:
%
% Basic/
%    Contains basic functions for writing and reading records,
%    elements, structures, and libraries in GDS II format. Also
%    contains the object framework for creating and GDS II
%    libraries.
%
% Elements/
%    Contains higher level functions that return gds_element
%    objects.
%
% Structures/
%    Contains higher level functions that return gds_structure
%    objects.
%
% Boolean/
%    Low level functions for Boolean set operations on polygons and
%    polygon lists.
%
% Scripts/
%    Several scripts that can be run directly from a Linux shell  prompt.
%
%
% Compiling 
% --------- 
% This software contains several MEX functions, which must be compiled
% with a C compiler (or a C++ compiler in one case), before the
% library can be used.  From the gdsii directory this can be done
% by executing 
%
% >>  makemex
%
% at the MATLAB command prompt. If a C++ compiler is not
% installed, the 
%
% >> makemex-gpc
%
% should be used instead so that the General Polygon Clipper (GPC)
% library is used for Boolean set operations. 
% 
% In Octave for Windows, the command
%
% >> omakemex
%
% must be used instead.
% 
% In Linux/Unix the MEX functions are best compiled by running
%
% ./makemex-octave
%
% at the command line.
%
%
% Useful Stuff:
% -------------
% Layout viewer and editor (highly recommended !):
% http://www.klayout.de
% 
% LayoutEditor for inspecting and editing of GDS II files:
% http://www.layouteditor.net
%
% This software is in the Public Domain, with the exception of the mex
% function for DataMatrix creation, which is under the GNU GPL version
% 2., and the functions for Booean set operations.
%
% Ulf Griesmann, NIST, 2008, 2009, 2010, 2011, 2012, 2013
% -------------------------------------------------------

