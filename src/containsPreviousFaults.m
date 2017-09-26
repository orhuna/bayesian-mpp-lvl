function flag = containsPreviousFaults(data_input,proposal,cube_size)
%containsPreviousFaults checks if simulation area contains all the hard
%data and proposed fault to be added to the network

%   INPUTS:
%   init: structure containing fault centroid and fault hiearchy
%   az: azimuth angle(in degrees)
%   dip: dip angle (in degrees)
%   sim_size: 1x3 array containing dx, dy, dz for the simulation area
%   res: 1x3 array containing x, y, z resolution for the 3-D cube for

%   level-set
%   OUTPUTS:
%   flag: flag can be 1(contains data_input entirely), 0 (does not contain
%   data_input) or 0.5(contains partial data_input). If there is no 
%   data_input data_input containment flag is 0

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	August 2016; Last revision: 23-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.
%%
if isempty(data_input) || length(data_input)==0
    flag = 0 ;
else
    
    %Compute Cube Extents
    extents = repmat(proposal,2,1) + [-cube_size/2;cube_size/2] ;
    %Create a Cube in Polygonal Convention    
    ver = [1 1 0;0 1 0;0 1 1;1 1 1;0 0 1;1 0 1;1 0 0;0 0 0];
    ver = ver .* repmat(diff(extents),size(ver,1),1) ;
    ver = ver + repmat(min(extents),size(ver,1),1) ;
    %Compute the Convex Hull for Right Ordering of Vertices
    K = convhull(ver(:,1:2)) ;
 
    for data_input_length = 1 : length(data_input)
        %If data_input is Contained in Z-Direction   
        %Check if data_input is contained in XY direction
        in = inpolygon(data_input(data_input_length).vertices(:,1),data_input(data_input_length).vertices(:,2),ver(K,1),ver(K,2)) ;
        % Make a Variable for z-values, easier to keep track
        z_vals = data_input(data_input_length).vertices(:,3) ;
        %Check if z-values are out of bounds
        z_out_of_bounds = max(z_vals) < min(extents(:,3)) || min(z_vals) > max(extents(:,3)) ;
        % If all data points are outside
        if sum(in) == 0 || z_out_of_bounds
           flag(data_input_length) = 0 ;
           %If some data points are inside in xy and also in z
            else if sum(in) < length(in) && ~z_out_of_bounds
                    flag(data_input_length) = 0.5 ;
                %If all entries are inside
                else if sum(in) == length(in) && ~z_out_of_bounds
                        flag(data_input_length) =  1 ;
                    end
                end
        end
    end
end
end