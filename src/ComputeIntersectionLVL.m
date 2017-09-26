function L_inter = ComputeIntersectionLVL(fault_vertices, x_g, y_g, z_g)
%ComputeIntersectionLVL compute where a fault surface intersects the
%level-set of another fault

%   INPUTS:
%   fault vertices: 3-D scatter for fault surface
%   x_g, y_g, z_g: Grid points for the level-set

%   OUTPUTS:
%   L_inter : Level-set for intersection

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	August 2016; Last revision: 23-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.
%%
res = size(x_g) ;
D_s = signed_distance(fault_vertices, [x_g(:),y_g(:),z_g(:)]) ;
L_inter = reshape(D_s,res(1),res(2),res(3));
