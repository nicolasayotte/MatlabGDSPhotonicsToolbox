% Classes and Methods for GDS II 
% ==============================
%
% GDS II libraries (files) consist of elements of the types boundary,
% sref, aref, path, node, box, and text, that are grouped into
% structures (sometimes called cells). The structures are combined
% into libries that describe a layout.
%
% Elements
% --------
% gds_element   - constructor for the gds_element class
% display       - display method for the gds_element class
% get           - retrieve element properties
% set           - set element properties
% is_etype      - method to test the element type
% is_ref        - method to test if element is sref or aref
% poly_box      - method to convert box to boundary element
% poly_text     - method to convert text to boundary element
% poly_path     - method to convert path to boundary element
% poly_bool     - method for Boolean set algebra with boundary elements
%
% NOTE: 
% Element properties can be read and set using field name indexing
% (e.g.: el.layer = 2). 
%
% Structures
% ----------
% gds_structure   - constructor for the gds_structure class
% display         - display method for the gds_structure class
% find            - method to find elements with certain properties
% findref         - method to find names of referenced structures
% get             - method to retrieve structure properties
% numel           - method that returns the number of elements in a
%                   structure
% rename          - method to rename a structure
% sname           - method that returns the structure name
% sdate           - return structure creation/modification dates
% stuctfun        - iterator method for the gds_structure class
% poly_convert    - converts box, text, and path elements to 
%                   boundary elements
% add_element     - add element(s) to structures
% add_ref         - convenient method to create sref elements in structures 
%
% NOTES:
% - Elements in the structures can be addressed using array
%   indexing.
% - The number of elements can be read and the structure name can
%   be read and set using field name indexing.
%
% Libraries
% ---------
% gds_library      - constructor for the gds_library class
% display          - display method for the gds_library class
% treeview         - structure hierarchy view method
% subtree          - copy structure with referenced structures
% topstruct        - return name(s) of the top structure(s)
% get              - method to retrieve class properties
% set              - method to set class properties
% rename           - changes the library name
% numst            - number of structures in the library
% length           - method that returns the number of structures
%                    in a library.
% libraryfun       - iterator method for the gds_library class
% write_gds_library- method to write a gds_library object to a file
%
% NOTE:
% - Structures in a library can be addressed using array indexing.
%
% Ulf Griesmann, NIST, 2008, 2009, 2010, 2011, 2012
% -------------------------------------------------------

