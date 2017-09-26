function [x_r,y_r,z_r,lvl_rot] = rotateFault(deflection_azimuth, deflection_dip, xx,yy,zz,L)
%rotateFault rotates the a planar surface for a given azimuth and dip

%   INPUTS:
%   deflection_az: azimuth angle(in degrees)
%   deflection_dip: dip angle (in degrees)
%   xx, yy, zz, L: grid points and level-set for the rotated surface

%   OUTPUTS:
%   x_r,y_r,z_r: Grid for rotated level-set
%   lvl_rot: level-set for rotated fault surface

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	May 2016; Last revision: 24-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.

% Rotation Angles
rota = [deflection_dip,0,deflection_azimuth] ;
% Eulerian Rotation Matrix
rotm = SpinCalc('EA123toDCM',rota);

fault = isosurface(xx,yy,zz,L);
fault_orig = fault.vertices ;
fault_rot = fault_orig * rotm ;

fault_rot= fault_rot + ...
repmat(median(fault_orig) - median(fault_rot),length(fault_rot),1 ) ;

[lvl_rot,x_r,y_r,z_r] = pointset2LevelSet(fault_rot,2,[20,20,20]);