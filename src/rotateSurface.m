function fault_rot = rotateSurface(fault, deflection_azimuth, deflection_dip)
%rotateSurface rotates a fault at 0 azimuth and 90 dip to desired angles

%   INPUTS:
%   fault: input point scatter for 0,0 fault surface
%   deflection_azimuth: azimuth angle for fault
%   deflection_dip: dip angle for fault

%   OUTPUTS:
%   fault_rot: 3-D point scatter for rotated fault surfaces

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	May 2016; Last revision: 24-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.  
%% Rotation Angles
rota = [0,deflection_dip,deflection_azimuth] ;
% Eulerian Rotation Matrix
rotm = SpinCalc('EA123toDCM',rota);

fault_rot = fault * rotm ;

fault_rot = fault_rot + repmat(median(fault) - median(fault_rot),length(fault_rot),1 ) ;
