function fault_network = createDataMarkedCase(init, az, dip, sim_size, res)
%createDataMarkedCase create fault data for given azimuth, dip, size and
%resolution

%   INPUTS:
%   init: structure containing fault centroid and fault hiearchy
%   az: azimuth angle(in degrees)
%   dip: dip angle (in degrees)
%   sim_size: 1x3 array containing dx, dy, dz for the simulation area
%   res: 1x3 array containing x, y, z resolution for the 3-D cube for

%   level-set
%   OUTPUTS:
%   fault_network: resulting fault surface

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	August 2016; Last revision: 23-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.
%%
fault_network = {};

for mark_type = 1 : max(init.mark)
    fault_network = [fault_network, InsertFaultOntoMark(fault_network, init.point(init.mark==mark_type,:),res,sim_size(init.mark==mark_type,:),az(init.mark==mark_type),dip(init.mark==mark_type),2)] ;
end