function [D_signed,varargout] = signed_distance(coord, grid_coords)
%% SIGNED DISTANCE COMPUTATION FOR LEVEL-SET GENERATION
% This function computes a signed dissimilarity function to a scatter of
% points in 3D space. A Cartesian grid containing the points scatter and
% coordinates of the points need to be specified.
% Input :
% ------------------------------------------------------------------------
% coord : m x 3 matrix. Coordinates (in 3-D) of the point scatter 
% representing a surface
% 
% grid_coords = n x 3 matrix. Column vector form of every grid cell x, y
% and z of the Cartesian grid, respectively.
% 
% Output:
% ------------------------------------------------------------------------
% D_signed = Signed Distance computed for the entire grid
% f : optionally output the surface fit to point scatters
%%
% Fit Surface of to Point Scatter
f = fit( coord(:,[1,3]), coord(:,2), 'poly22' ) ; warning('off','all') ;
% figure,plot(f,coord(:,[1,3]), coord(:,2))
% Compute the Signed Distance from the Grid Cells to the Surface for Point
% Scatters
D_signed = f(grid_coords(:,[1,3])) - grid_coords(:,2);
varargout{1} = f ;