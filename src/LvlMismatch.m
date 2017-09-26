function mismatch = LvlMismatch(hard_data,proposal,box_ext,grid_dim, pars)
%% This function creates a LvlSet that matches hard_data within a given simulation box
% Find Azimuth and Dip That Roughly Explains hard_data
% match_ind = 3 ;
% hard_data = data{1,1}{1,match_ind} ;
% tol = [0.10,0.05] ;
% proposal = median(hard_data.vertices);
% size_f = 2 *range(hard_data.vertices) ;
% box_ext = repmat(proposal,2,1) + [-size_f/2;size_f/2] ;

size_fault = diff(box_ext);


[L_rough,x,y,z] = createNumericFaultLvl(pars(1),pars(2),size_fault,proposal,grid_dim) ;

F = scatteredInterpolant(x(:),y(:),z(:), L_rough(:) ) ;

Lvl_fit = F(hard_data.vertices(:,1),hard_data.vertices(:,2),hard_data.vertices(:,3));
mismatch = range(Lvl_fit) ;  
