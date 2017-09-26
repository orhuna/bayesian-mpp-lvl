function [L, x, y, z, cont, fval, par_opt] = LvlOptimize(hard_data,box_ext, az_bound, dip_bound, grid_dim)
%%LvlOptimize finds surface parameters for given fault interpretations

proposal = mean(box_ext) ;

options = optimset('Display', 'off') ;

lb = [az_bound(1),dip_bound(1)];
ub = [az_bound(2),dip_bound(2)];
x0 = [min(az_bound) + rand * range(az_bound),...
      min(dip_bound) + rand * range(dip_bound)];

[par_opt,fval] = fmincon(@(dims) LvlMismatch(hard_data, proposal,box_ext,grid_dim, dims),x0,[],[],[],[],lb,ub,[],options);

[L, x, y, z,  cont] = LvlCalculate(hard_data,proposal,box_ext,grid_dim,par_opt(1),par_opt(2));



