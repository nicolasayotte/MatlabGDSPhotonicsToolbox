function el = MergeElements(els)
%%MERGEELEMENTS creates on compound element with many gds_element
% 
%     See also CASTPREPROCESSING, CHECKFORLARGEPOLYGONS. 

el = els{1};
if(length(els) > 1)
   for ii = 2 : length(els)
      el = add_poly(el, els{ii}.xy);
   end
end
end