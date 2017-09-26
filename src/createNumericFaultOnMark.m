function [x, y, z, L] = createNumericFaultOnMark(az,dip,sim_size,res,proposal,curv_par,varargin)
%createNumericFaultOnMark insert fault surfaces onto marked points

%   INPUTS:
%   az: azimuth angle(in degrees)
%   dip: dip angle (in degrees)
%   sim_size: 1x3 array containing dx, dy, dz for the simulation area
%   res: 1x3 array containing x, y, z resolution for the 3-D cube for
%   proposal: faults to insert onto marks
%   curv_par = curvature parameter for fault surface to be fitted(1:planar)
%   varargin

%   level-set
%   OUTPUTS:
%   x, y, z: Grid locations for level-set
%   L: level-set for the fault network

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	August 2016; Last revision: 23-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.
%%
for i = 1 : length(az)
    surface_guide = createFault(res, sim_size(i,:), az(i), dip(i),curv_par)  ;

    if ~isempty(varargin)
        [L{i},x{i},y{i},z{i}] = pointset2LevelSet(surface_guide,2,res,varargin{1});
    else 
        [L{i},x{i},y{i},z{i}] = pointset2LevelSet(surface_guide,2,res);
        x{i} = x{i} - mean(x{i}(:)) + proposal(i,1);
        y{i} = y{i} - mean(y{i}(:)) + proposal(i,2);
        z{i} = z{i} - mean(z{i}(:)) + proposal(i,3);
    end
end

% varargout{1} = x  ;
% varargout{2} = y ;
% varargout{3} = z ;
% varargout{4} = L ;
% c = {'r','b'};
% for i = 1 : length(fault)
% patch(fault{1,i},'FaceColor',c{i},'EdgeColor','k')
% SurfaceArea(fault{1,i})
% hold on
% end
% hold off

% for i = 1 : length(fault)
%    figure,visualizeLevelSet( x{i},y{i},z{i},L{i},0.2)
% end
% 
