Matlab GDS Photonics Toolbox
============================

This is a Matlab library of functions to facilitate the design of Photonics Integrated Circuits GDS layouts that I (Nicolas Ayotte) have developped with Alexandre D. Simard during my PhD.

This is oriented towards intuitive and adaptable creation of GDS layout files for fabrication in different facilities across the world. The toolbox creates a GDS based on a general layer map, but can be set up to export to any other layer map once the design is done.

Nicolas Ayotte and Alexandre D. Simard have used this library to efficiently create multiple layouts for different fabrication facilities across the world with successful results.

Features
--------
- Relative orientation group waveguide routing including turns, tapers, s-bends and the possibility to customize inter-waveguide distance at any point.
- Access to the travelled distance (physical or optical) of any waveguide offering a quick way to measure your devices.
- Possibility of referencing premade structures (fiber couplers, directional couplers, detectors, etc.)
- Possibility of referencing custom structures created on the fly.
- Premade functions for microrings, Bragg gratings, multi-mode interferometer, contra-directional couplers, output array of fiber couplers, etc.
- Tutorial project with many cells showcasing the features.
- A PDF presentation presenting the library's purpose and principles.
- Intuitive relative cell placement in the master floorplan for easy teamwork.
- Relative and scalable routing solution.
- Includes functions to export to other layer maps, including boolean operations on the layers.
- Easy scripting language (i.e.: Matlab).

It is strongly encouraged to get the free software KLayout to look at your GDS files:
http://www.klayout.de/

Suggested first steps
---------------------
- Look through the PDF presentation
- (Optional) Run the command "mex -setup" to install a C compiler in matlab.
- Run the makemex.m function in the main folder to compile all the C functions needed for the library.
- Open the tutorial project folder: Project - New Project
- Go through the Cells script, run them, look at the resulting .gds files.
- Look at the Cell_RoutingWG.m script that places the cell in the floorplan.
- Read at the ProjectDefinition.m file.
- Run the Main.m to merge the gds cells and export to the ouput layer map.
- Duplicate the Project folder and make your own!

License
---------
Copyright © 2014 Nicolas Ayotte and Alexandre D. Simard. MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

GDS II Toolbox
-----------------------------
Copyright © 2008-2014 Ulf Griesmann. This software is in the Public Domain.
https://sites.google.com/site/ulfgri/numerical/gdsii-toolbox

The GDS II library, or database, format has become an important industry standard for the description of nano-structure designs that are fabricated with either photo- or electron lithography - despite being poorly documented. GDS II library files are used to define the layout of integrated circuits, MEMS devices, nano-structured optics, and so on. This toolbox of functions for MATLAB or Octave can be used to create, read, and modify files in GDS II library format. The toolbox is particularly useful when a layout  is the result of numerical modeling as is often the case, e.g., for nano-structured optics, photonic devices, or micro-fluidic devices. MATLAB or Octave can become very efficient tools for post-processing  of modeling results and for creating a lithographic layout as input to the fabrication process. The toolbox can also be used to modify GDS II layout files using scripts, e.g. for merging of several layout files. Layouts can be inspected with the excellent free layout viewer KLayout.


Clipper library
---------------
Copyright © 2010-2014 Angus Johnson. Boost Software License - Version 1.0 - August 17th, 2003
http://www.angusj.com/delphi/clipper.php

The Clipper library performs line & polygon clipping - intersection, union, difference & exclusive-or, and line & polygon offsetting. The library is based on Vatti's clipping algorithm. The download package contains the library's full source code (written in Delphi, C++ and C#), numerous demos, a help file and links to third party Python, Perl, Ruby and Haskell modules. This was inserted into the GDS II Toolbox by Ulf Griesmann.
