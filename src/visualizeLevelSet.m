function visualizeLevelSet(x,y,z,L,alpha_val)
%visualizeLevelSet  Utility function for plotting a level-set a 4-D 
%   level-set for a 3-D surface for a given transparency value alpha_val.

%   INPUTS:
%   x, y, z: 3-D gridded x, y and z locations
%   alpha_val: Transparency for level-set visualizations. 0 is transparent,
%   1 is opaque.
%   L: Level-set values for x, y and z
%   OUTPUTS:

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	August 2016; Last revision: 23-Sep-2017
%   Written by: Orhun Aydin
%   Date: 12/7/2016


for thresh = min(min(min(L))):(max(max(max(L)))-min(min(min(L))))/100:max(max(max(L)))
    isosurface(x, y, z,L,thresh);
    alpha(alpha_val)
end