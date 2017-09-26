function fault_final = createFault(res, size_fault, az, dip,varargin)
%createFault creates a planar guide-surface for level-set creation

%   INPUTS:
%   res: x, y, z resolution 
%   size_fault: 1x3 array containing dx, dy, dz for fault
%   az: azimuth angle(in degrees)
%   dip: dip angle (in degrees)
%   varargin: curvature for fault surface, default= 1, planar
%   angle: angle value for variogram, angle object consists of x, y and z

%   OUTPUTS:
%   fault_final: 3-D point scatter for guide surface

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	May 2016; Last revision: 24-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.
%   

[s1,s2,s3] = meshgrid(linspace(0,0, res(1)),...
                      linspace(-0.5,0.5, res(2)),...
                      linspace(-0.5,0.5, res(3)));

s1 = s1 .* size_fault(1) ;
s2 = s2 .* size_fault(2) ;
s3 = s3 .* size_fault(3) ;

if nargin == 5
    
    ord = varargin{1};
    
    fault_planar = rotateSurface([s1(:),s2(:),s3(:)], az, dip);
    sgn = (dip<0) - (dip>=0) ;
    
    curvature_par = abs((fault_planar(:,3) - max(fault_planar(:,3))) ./ range(fault_planar(:,3))) .^ ord;
    curvature_par =  curvature_par / max(curvature_par) ;

    fault_final = fault_planar ;
    
    fault_final(:,1) = fault_planar(:,1) + sgn * size_fault(1) * cosd(az) .* curvature_par ;
    fault_final(:,2) = fault_planar(:,2) + sgn * size_fault(2) * sind(az) .* curvature_par ;
    
    %Scale the Guide Surface so It Does Not Extrude Out of Simulation Box
    for dim = 1 : 3
        fault_final(:,dim) = fault_final(:,dim) * range(fault_planar(:,dim)) / range(fault_final(:,dim));
    end
        
else
  fault_final = rotateSurface([s1(:),s2(:),s3(:)], az, dip);
end
