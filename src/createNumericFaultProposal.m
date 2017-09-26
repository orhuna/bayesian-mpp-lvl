function [x, y, z, L] = createNumericFaultProposal(az,dip,sim_size,res,varargin)
%createNumericFaultProposal calculates the level-set representation of a 
%planar surface defined by azimuth, dip and extent in x, y and z.

%   INPUTS:
%   az: azimuth angle(in degrees)
%   dip: dip angle (in degrees)
%   sim_size: 1x3 array containing dx, dy, dz for the simulation area
%   res: 1x3 array containing x, y, z resolution for the 3-D cube for
%   level-set
%   OUTPUTS:
%   x, y, z: 3-D gridded x, y and z locations
%   L: Level-set values for x, y and z

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	August 2016; Last revision: 23-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.
%   
%   2-) Cherpeau, N., Caumon, G., & Lévy, B. (2010). Stochastic 
%   simulations of fault networks in 3D structural modeling. Comptes Rendus
%   Geoscience, 342(9), 687-694.
%%
for i = 1 : length(az)
    surface_guide = createFault(res, sim_size(i,:), az(i), dip(i),1)  ;
    [L{i},x{i},y{i},z{i}] = pointset2LevelSet(surface_guide,2,res,varargin{1});
end
