MatlabGDSPhotonicsToolbox
=========================
This software is under the MIT license. (Very public)

This is a Matlab library of functions to facilitate the design of Photonics Integrated Circuits GDS layouts that I have developped during my PhD.

This is oriented towards intuitive and adaptable creation of GDS layout files for fabrication in different facilities across the world. The toolbox creates a GDS based on a custom general layer map, but can be set up to export to any other layer map once the design is done.

Nicolas Ayotte and Alexandre D. Simard have used this library to create multiple layouts (quickly) for different fabrication facilities across the world with successful results.

Features:
- Fast and intuitive waveguide routing including group turns and group s-bends and the possibility to customize inter-waveguide distance at any point.
- Access to the travelled distance (physical or optical) of any waveguide offering a quick way to measure your devices
- Possibility of referencing premade structures (fiber couplers, directional couplers, detectors, etc.)
- Premade functions for microrings and Bragg gratings..
- Tutorial project with many cells showcasing the features.
- A PDF presentation presenting the library's purpose.
- Intuitive cell placement in the master floorplan for easy teamwork.
- Includes functions to export to other layer, possibly including boolean operations on the layers.
- Untested learning curve! Come and test it yourself. :)


It is strongly encouraged to get the free software KLayout to look at your GDS files:
http://www.klayout.de/

=========================
Includes in the Functions - GDSII Library Folder :

- GDS II Toolbox, Copyright © 2008-2014 Ulf Griesmann. This software is in the Public Domain.

https://sites.google.com/site/ulfgri/numerical/gdsii-toolbox

The GDS II library, or database, format has become an important industry standard for the description of nano-structure designs that are fabricated with either photo- or electron lithography - despite being poorly documented. GDS II library files are used to define the layout of integrated circuits, MEMS devices, nano-structured optics, and so on. This toolbox of functions for MATLAB or Octave can be used to create, read, and modify files in GDS II library format. The toolbox is particularly useful when a layout  is the result of numerical modeling as is often the case, e.g., for nano-structured optics, photonic devices, or micro-fluidic devices. MATLAB or Octave can become very efficient tools for post-processing  of modeling results and for creating a lithographic layout as input to the fabrication process. The toolbox can also be used to modify GDS II layout files using scripts, e.g. for merging of several layout files. Layouts can be inspected with the excellent free layout viewer KLayout.


- Clipper library, Copyright © 2010-2014 Angus Johnson. Boost Software License - Version 1.0 - August 17th, 2003

http://www.angusj.com/delphi/clipper.php

The Clipper library performs line & polygon clipping - intersection, union, difference & exclusive-or, and line & polygon offsetting. The library is based on Vatti's clipping algorithm. The download package contains the library's full source code (written in Delphi, C++ and C#), numerous demos, a help file and links to third party Python, Perl, Ruby and Haskell modules. This was inserted into the GDS II Toolbox by Ulf Griesmann.
