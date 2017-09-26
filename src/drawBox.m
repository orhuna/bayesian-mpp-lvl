function drawBox(extents)
%drawBox draws a bounding box given by the extents
%	INPUT:
%	extents : 2-by-3 matrix containing minimum and maximum of the x,y,z 
%	coordinates, respectively

%   INPUTS:
%   extents : 2-by-3 matrix containing x,y,z extents of simulation area  

%   OUTPUTS:

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	January 2016; Last revision: 24-Sep-2017

%% Define vertices of a unit cube
ver = [1 1 0;0 1 0;0 1 1;1 1 1;0 0 1;1 0 1;1 0 0;0 0 0];
%  Define the faces of the unit cube
fac = [1 2 3 4;4 3 5 6;6 7 8 5;1 2 8 7;6 7 1 4;2 3 5 8];
% Scale and translate the unit cube to specified extents
ver = ver .* repmat(diff(extents),size(ver,1),1) ;
ver = ver + repmat(min(extents),size(ver,1),1) ;
% Create a patch object
cube.vertices = ver ;
cube.faces = fac;
% Plot using patch
patch(cube,'FaceColor','none')