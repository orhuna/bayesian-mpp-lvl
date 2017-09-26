function [L, x, y, z,  cont, att] = LvlMatch(hard_data,tol,proposal,box_ext,grid_dim)
%% This function creates a LvlSet that matches hard_data within a given simulation box
% Find Azimuth and Dip That Roughly Explains hard_data
% match_ind = 3 ;
% hard_data = data{1,1}{1,match_ind} ;
% tol = [0.10,0.05] ;
% proposal = median(hard_data.vertices);
% size_f = 2 *range(hard_data.vertices) ;
% box_ext = repmat(proposal,2,1) + [-size_f/2;size_f/2] ;

size_fault = diff(box_ext);
count = 0 ;
flag = 1 ;
while flag
    count = count + 1 ;
    az = -1 + 2*rand();
    dip = -70 + 140*rand() ;
  
    [L_rough,x,y,z] = createNumericFaultLvl(az,dip,size_fault,proposal,grid_dim) ;

    F = scatteredInterpolant(x(:),y(:),z(:), L_rough(:) ) ;

    Lvl_fit = F(hard_data.vertices(:,1),hard_data.vertices(:,2),hard_data.vertices(:,3));
    flag = range(Lvl_fit) > tol(1) ;
    mismatch(count) = range(Lvl_fit) ;
    display(['az = ',num2str(az),' dip = ', num2str(dip),' misfit = ',num2str(mismatch(count))])
    
    
    if mod(count,100) == 0
        tol(1) = 1.1 * tol(1) ;
    end
end

perturb_cube = GradualDeformation(tol(2), x,y,z,L_rough, hard_data) ;

% Return the Matched Level-Set
L = L_rough+perturb_cube ;
% Fit An Interpolant to Level-Set to Calculate hard_data Contour
F = scatteredInterpolant(x(:),y(:),z(:), L(:)) ;
Lvl_fit = F(hard_data.vertices(:,1),hard_data.vertices(:,2),hard_data.vertices(:,3));
% Find the Contour in the Level-Set that Contains hard_data
cont = mean(Lvl_fit) ;
att = [az,dip] ;
