clear all
close all
clc
%%
% fault_num = 2 ;
% 
% 
res = [5,5,10] ;
az_init = [0,5] ;
dip_init = [50,70] ;
size_init = [6000,4000,500;...
             8000,6000,600] ;
sim_ext = [0,0,-5500;...
          8*10^3, 8*10^3,-5000] ;
area_min = [10^ 4,10^ 4] ;

%%
tot_num_sce = 1 ;
%% Create Data from Ellipses Defined
% load init_100
data_areal_res = 10 ^ 5 ;

%Convert the Initial Data Structure to Single Faults For Every Network
for net_id = 1 : size(initial_network,2)
    count = 0 ;
    for y_id = 1 : size(initial_network{net_id},2)
        for fault_id = 1 : size(initial_network{net_id}{y_id},2)
            count = count + 1;
            fault_network{net_id}{count} = initial_network{net_id}{y_id}{fault_id} ;
        end
    end
end

for i = 1 : tot_num_sce
    %Create Data At Observation Locations Defined in createData function
    [data{i,1},match_faults{i}] = createData(fault_network{i}) ;
    % Erase Faults That Are to Small to be Seen
    if ~isempty(data{i,1})
        for k = 1 : length(data{i,1})
            data_area(k) = SurfaceArea(data{i,1}{k}) ;
        end

        % Determine Which Faults Are Sub-Resolution
        erase_ind = find(data_area < data_areal_res) ;
        % Update Data List
        data{i,1}(erase_ind) = [] ;
        % Update Index List
        match_faults{i}(erase_ind) = [] ;
        clearvars data_area
    end
end
%%
grid_dim = [5,5,5] ;
num_iter = 1000;
area_min = [5 * 10^5, 4 * 10^5] ;

%%Uncommnet 2  Lines Below to Run Unconditional Simulations
% tot_num_sce = 1 ;
% data = cell(tot_num_sce,1) ;

lambda = 15 ;
n_sce_sim = poissrnd(lambda,1,tot_num_sce) ;

sim_ext = [0,0,-5500;...
           9*10^3, 9*10^3,-4800] ;
       
num_iter = 1000;
epsilon = 0.2 ;
sim_fault_network = cell(tot_num_sce,1) ;

drawBox(sim_ext)

for num_sce = 1 : tot_num_sce
    display(num_sce)
    net_id = [] ;

    %INITIALIZATION
    if ~isempty(data{num_sce})
        for data_ind = 1 : size(data{num_sce},2)
            fval = Inf ;
            while fval > epsilon
                %Propose a Point On the Data
                proposal = data{num_sce}{data_ind}.vertices(randi([1,size(data{num_sce}{data_ind}.vertices,1)]),:) ;

                %Sample a Size
                sim_size = [] ;
                for i = 1 : 3
                    sim_size = [sim_size,size_init(1,i) + rand() * diff(size_init(:,i))] ;
                end
                %Calculate the Extents of the Simulation Box
                box_ext = repmat(proposal,2,1) + [-sim_size/2 ; sim_size /2] ;

                [L, x, y, z, cont,fval,par_opt] = LvlOptimize(data{num_sce}{data_ind}, ...
                                                  box_ext, [-5,5], [-80,80],grid_dim) ;
                display(fval)
            end
            % Plot the Matched Surface At Contour
            L_init{data_ind} = L ;
            x_init{data_ind} = x ; 
            y_init{data_ind} = y ; 
            z_init{data_ind} = z ;
            match_par{data_ind} = par_opt ; 
            cont_init(data_ind) = cont ;
            mismatch(data_ind) = fval ;

            fault_orig{data_ind}=isosurface(x,y,z,L,cont) ;
            c = rand(1,3) ;
            patch(fault_orig{data_ind},'FaceColor',c,'EdgeColor',c)
            hold on
            drawBox(box_ext)
            drawnow
        end
    else
        %If there is no data to match
        L_init = {}; x_init={}; y_init={};z_init ={};
        match_par = {} ; cont_init = {}; mismatch  ={} ;
        fault_orig = {};
    end
    %%END INITIALIZATION
    %Impose Structural Relations on Data Matching Surfaces
    if ~isempty(data{num_sce})
        fault_match{num_sce} = ImposeHierOnLvl(x_init,y_init,z_init,L_init,cont_init,data{num_sce},[2,2,5]);
    else
        fault_match{num_sce} = {};
        match_par = {};
    end
    % Write Initialization to Simulated Fault Scenario
    sim_fault_network{num_sce} = fault_match{num_sce} ;
    %START MARKOV CHAIN
    %Run Strauss Process On the Initialization
    gamma = -5; beta = 20; d =1000; num_iter = 200; move_bounds = [1,50;1,50;0.5,10]; res=[5,5,10];
    tic
    [posterior{num_sce}, actions{num_sce}, L_dm{num_sce}, az_sim{num_sce}, dip_sim{num_sce}, d_state{num_sce}] = StraussMarked(data{num_sce},sim_fault_network{num_sce}, match_par, gamma, beta, d, num_iter, size_init, sim_ext, area_min, move_bounds, res, az_init, dip_init);
%                                                                                                                                 (gamma, beta, d, max_mark, num_iter, sim_ext, initialization, move_bounds )
    save('Loop_Output.mat','posterior', 'actions', 'L_dm', 'az_sim', 'dip_sim')
    display(num2str(num_sce))
    clearvars x_init y_init z_init L_init match_par cont_init mismatch fault_orig
end
%% Summary Statistics
az_sim_cum = [] ;
az_init_cum = [] ;
dip_sim_cum = [] ;
dip_init_cum = [] ;

for i = 1 : tot_num_sce
    az_sim_cum = [az_sim_cum;az_sim{i}] ;
    az_init_cum = [az_init_cum,az_cum{i}] ;
    
    dip_sim_cum = [dip_sim_cum;dip_sim{i}] ;
    dip_init_cum = [dip_init_cum,dip_cum{i}] ;
end

figure,
subplot(1,2,1),hist(az_init_cum(:))
title('Initial Azimuth')
subplot(1,2,2),hist(az_sim_cum(:))
title('Simulated Azimuth')

figure,
subplot(1,2,1),hist(dip_init_cum(:))
title('Initial Azimuth')
subplot(1,2,2),hist(dip_sim_cum(:))
title('Simulated Azimuth')
%%
[f_az.init,x_az.init] = ksdensity(az_init_cum(:));
[f_az.sim,x_az.sim] = ksdensity(az_sim_cum(:));
%
[f_dip.init,x_dip.init] = ksdensity(dip_init_cum(:));
[f_dip.sim,x_dip.sim] = ksdensity(dip_sim_cum(:));

figure,
plot(x_az.init,f_az.init,'LineWidth',3)
hold on
plot(x_az.sim,f_az.sim,'LineWidth',3,'Color','r')
legend('Initial Models','Simulated Models')

figure, h = qqplot(az_init_cum(:), az_sim_cum(:));
set(h(1),'marker','*','markersize',5,'markeredgecolor',[1 0 0]);
set(h(2),'linewidth',3,'color',[0 0 1]);
set(h(3),'linewidth',3,'color',[0 0 1]);
set(gca,'FontName','Arial','FontSize',14)
legend([h(3) h(1)],{'Initial Models','Simulated Models'},'Location','NorthWest')
xlabel('Initial Azimuth  (^{0})')
ylabel('Simulation Azimuth  (^{0})')
title('Q-Q Plot for Azimuth')

figure,
plot(x_dip.init,f_dip.init,'LineWidth',3)
hold on
plot(x_dip.sim,f_dip.sim,'LineWidth',3,'Color','r')
legend('Initial Models','Simulated Models')
xlabel('Initial Dip  (^{0})')
ylabel('Simulation Dip  (^{0})')
title('Q-Q Plot for Dip')

figure,h = qqplot(dip_init_cum(:), dip_sim_cum(:));
set(h(1),'marker','*','markersize',5,'markeredgecolor',[1 0 0]);
set(h(2),'linewidth',1,'color',[0 0 1]);
set(h(3),'linewidth',3,'color',[0 0 1]);
set(gca,'FontName','Arial','FontSize',14)
legend([h(3) h(1)],{'Initial Models','Simulated Models'},'Location','NorthWest')
xlabel('Initial Dip  (^{0})')
ylabel('Simulation Dip  (^{0})')
title('Q-Q Plot for Dip')