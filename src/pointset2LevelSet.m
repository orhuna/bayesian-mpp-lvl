function [lvlset,x3,y3,z3,varargout] = pointset2LevelSet(fault_points,distance_type,grid_size, bounds)
%pointset2LevelSet takes a 3D point scatter and represents it as a
%level-set within a user-defined bound and resolution. Output level-set has
%the original point scatter as its 0-isocontour

%   INPUTS:
%   fault_points: input point scatter for fault
%   distance_type: Type of distance to use to create level-set
%   grid_size: resolution for output level set 1X3 array
%   bounds: 2X3 matrix for bounds of simulation area, columns 1:3 are for
%   x,y,z respectively

%   OUTPUTS:
%   lvlset: Level-set for the given fault surface
%   x3,y3,z3: Grid locations for the level-set

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	May 2016; Last revision: 24-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.  

%%
switch nargin 
    case 3
        [x1, y1,z1] = meshgrid(linspace(min(min(min(fault_points(:,1)))), max(max(max(fault_points(:,1)))), grid_size(1)), ...
                       linspace(min(min(min(fault_points(:,2)))), max(max(max(fault_points(:,2)))), grid_size(2)), ...
                       linspace(min(min(min(fault_points(:,3)))), max(max(max(fault_points(:,3)))), grid_size(3)));
        
        x3 = x1 ; y3 = y1; z3 = z1 ; 
    case 4
        
        [x1, y1,z1] = meshgrid(linspace(min(min(min(fault_points(:,1)))), max(max(max(fault_points(:,1)))), grid_size(1)), ...
                       linspace(min(min(min(fault_points(:,2)))), max(max(max(fault_points(:,2)))), grid_size(2)), ...
                       linspace(min(min(min(fault_points(:,3)))), max(max(max(fault_points(:,3)))), grid_size(3)));
        
        [x3, y3,z3] = meshgrid(linspace(bounds(1,1), bounds(2,1), grid_size(1)), ...
               linspace(bounds(1,2), bounds(2,2), grid_size(2)), ...
               linspace(bounds(1,3), bounds(2,3), grid_size(3)));
end
grid_coords = [ x1(:), y1(:), z1(:) ] ;
% Compute the Euclidean Distance Field on the Grid
switch distance_type
    case 1
        D = distance2fault(fault_points, grid_coords) ;
    case 2
        D = signed_distance(fault_points, grid_coords); warning('off','all') ;
end

F = scatteredInterpolant(grid_coords(:,1), grid_coords(:,2), grid_coords(:,3), D ) ;

eg = F(x1,y1,z1);
lvlset = eg/max(max(max(abs(eg)))) ;

varargout{1} = F ;
