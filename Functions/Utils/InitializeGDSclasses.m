function InitializeGDSclasses()

gdslib = gds_library('temp');
gdsst = gds_structure('temp');
gdsel = gds_element('boundary', 'xy', [0,0;1,0;1,1]);
gdsst = add_element(gdsst, gdsel);
end