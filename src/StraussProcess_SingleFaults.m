function [fault_network, action, L_dm, az_sim, dip_sim, d_state] = StraussProcess_SingleFaults(data_init,initialization, prev_network, fault_num, gamma, beta, d, num_iter, size_init, sim_ext, area_min, move_bounds, res, az_init, dip_init)
% clearvars hier ind_Y Y_major Y_minor Y_inds ind_isolated fault_network current_state fault_pnt L_dm state_proposed proposal
% close all
% clc
% initialization = {};
% gamma=-2;beta=-10;
% d = 500;
% num_iter = 10000 ;
% 
% size_init = [8000,6000,500;...
%              10000, 8000,700] ;
% res = [5,5,10] ;
% 
% sim_ext = [0, 0, -5500;
%            5000, 1000, -5000];
% 
% area_min = [5*10^5, 4*10^5] ;
% move_bounds = [ 1,50;...
%                 1,50;...
%                  0.5,10] ;
%% Append Faults To Faults with No Y-Faults
% appendFault_fun;
%%
if ~isempty(prev_network)
    prev_network = struct2cellFIX(prev_network);
end

current_state = initialization ;
if ~isempty(current_state)
    current_state = struct2cellFIX(current_state);

end
L_dm(1) = ComputeLikelihood(current_state, data_init) ;
birth_num = 0 ;
acceptance = 0 ;
action = [];
    az_sim = [];
    dip_sim = [];

for iter = 2 : num_iter
    iter
    state_proposed = {};
    change_flag = 0 ;
    n = length(current_state) ;
    %Calculate the Median of Every Y-Fault Mark
    fault_pnt = Y2Point(current_state) ;
    %Propose a New State (Birth-Death, Modify or Move)
    u = rand() ;
    %%
    %Birth-Death
    if u <= 0.33
        %Calculate Probability for Death or a Birth Process
        p_death_birth = rand() ;
        switch p_death_birth <= 0.5
            %%
            %BIRTH PROCESS
            case 1
            %Propose a Location in 3D Space
            proposal = rand(1,3) .* diff(sim_ext) + sim_ext(1,:) ;
            proposal(2) = mean(sim_ext(:,2)) ;
            proposal(3) = mean(sim_ext(:,3)) ;
            
            r_green_birth = 1/(n+1) * exp(-gamma - beta * PairsWithinD(proposal,fault_pnt,d)) ;
            p_birth  =min([1,r_green_birth]) ;
            %Propose a Size for Simulation Cube
            cube_size = [] ;
            for dim = 1 : 3
                cube_size = [cube_size,size_init(1,dim) + rand() * diff(size_init(:,dim))] ;
            end
            cube_size(2) = diff(sim_ext(:,2)) ;
            cube_size(3) = abs(diff(sim_ext(:,3)));
            %Check if Proposed Box is Within Bounds
            flag_bound(iter) = 1;%check_bounds(sim_ext,proposal,cube_size);
            %Modify Birth Probability wrt Simulation Box being within Bounds
            p_birth  = p_birth  * flag_bound(iter);
            display('Birth Picked')
            if p_birth >rand()
                action  = [action,1] ;
                state_proposed = current_state ;
%                 fault_num = 2 ;
                [az,dip] = sampleAz_Dip(az_init, dip_init, fault_num);
                
                az_sim = [az_sim;az];
                dip_sim = [dip_sim;dip];
                
                sim_size = cube_size ;
                existing_network = horzcat(state_proposed,horzcat(prev_network{:})) ;
                
                if ~isempty(existing_network)
                    existing_network = struct2cellFIX(existing_network) ;
                end
                
                fault_proposed = InsertFaultIntoNetwork(existing_network, proposal,res,sim_size,az,dip,area_min);
                
                flag_insert = 1;
                for fault_proposed_ind = 1 : length(fault_proposed)
                    if SurfaceArea(fault_proposed{fault_proposed_ind}) < area_min(fault_proposed_ind)
                        flag_insert = 0;
                        change_flag = 0;
                    end
                end
                if flag_insert
                    state_proposed = horzcat(state_proposed,horzcat(fault_proposed{:})) ;
                    display('Birth Proposed')
                    
                    change_flag = 1 ;
                    birth_num = birth_num + 1 ;
                end
                clearvars fault_proposed
                
            end
            %%
            %DEATH PROCESS
            case 0
                display('Death Picked')
                if size(current_state,2) > 0
                death_ind = randi([1, size(current_state,2)]) ;               
                r_green_death = n * exp(gamma + beta * PairsWithinD(fault_pnt(death_ind,:),fault_pnt(setdiff(1 : size(fault_pnt,1), death_ind),:),d)) ;
                p_death  =min([1,r_green_death]) ;
                else
                    p_death = 0;
                end
                if p_death > rand() 
                   action  = [action,2] ;
                   display('Death Proposed')
                   state_proposed =  current_state ;
                   state_proposed{death_ind}=[];
                   state_proposed = state_proposed(~cellfun('isempty',state_proposed)) ;
                   change_flag = 1 ;
                end
        end
    %%   
    %MODIFY EXISTING NETWORK
    else if u >0.33 && u<=0.66  && ~isempty(current_state)
            action  = [action,3] ;
            display('Modify Picked')
            %Set Proposed State to Current State
            state_proposed = current_state ;
            %Pick an Object to Modify
            modify_ind = randi([1,length(state_proposed)]);
            %Sample Perturbation Parameters
            seed = randi([10^7,10^8]);
            pert_magnitude = 0.10 ;
            nugget = 0.01 * rand() ;
            rng.min = randi([10,50]); rng.med = rng.min; rng.max = rng.min ;
            angle.x = randi([0,10]) ; angle.y = randi([0,10]) ;angle.z = randi([5,20]) ;
            
            for fault_mod_ind = 1 : length(state_proposed{modify_ind})
                [L_mod,x_mod,y_mod,z_mod] = pointset2LevelSet(state_proposed{modify_ind}{fault_mod_ind}.vertices,2,res);
                
%                 patch(isosurface(x_mod,y_mod,z_mod,L_mod,0),'FaceColor','r')
%                 hold on
                perturb_cube = runSGSIM(res,seed,nugget,rng,angle) * pert_magnitude ;
                L_mod = L_mod + perturb_cube ;
%                 patch(isosurface(x_mod,y_mod,z_mod,L_mod,0),'FaceColor','g')
                
                state_proposed{modify_ind}{fault_mod_ind} = isosurface(x_mod,y_mod,z_mod,L_mod,0) ;
            end
            state_proposed = current_state ;
        change_flag = 1 ;
    %%
    %MOVE FAULT OBJECT        
        else if u > 0.66 && ~isempty(current_state)
                action  = [action,4] ;
                change_flag = 1 ;
                display('Move Picked')
                %Pick an Object to Move
                move_ind = randi([1,length(current_state)]);
                %Propose a 3D movement
                for dim = 1 : 3
                    move_3D(dim) = move_bounds(dim,1) + rand() * diff(move_bounds(dim,:));
                end
                state_proposed = current_state ;
%                 %Move the Fault Object
                for move_fault_id = 1 : length(state_proposed{move_ind})
                    move_vert = state_proposed{1,move_ind}{1,move_fault_id}.vertices ;
                    %Calculate the Proposed State
                    state_proposed{1,move_ind}{1,move_fault_id}.vertices = move_vert +...
                        repmat(move_3D,size(move_vert,1),1) ;
                end
            end
        end
    end
    %If there were alterations to network structure correct it (Numerical)
    if ~isempty(state_proposed)
        state_proposed = struct2cellFIX(state_proposed);
    end
    %If a Change Has been Made in the State Calculate the Likelihood
    if change_flag && ~isempty(state_proposed)
        %Calculate Likelihood for The Proposed State        
         L_dm(iter) = ComputeLikelihood(state_proposed, data_init) ;

        %Calculate Metropolis Ratio for the New State
        r_metropolis(iter) = L_dm(iter)/L_dm(iter-1) ;
       
        %Truncate if Above 1
        alfa_metropolis(iter) = min([1,r_metropolis(iter)]);
        u = rand();
        if u <= alfa_metropolis(iter) && L_dm(iter) >= L_dm(iter-1)
            display('State Changed')
            % Calculate Dissimilarity Between States
            d_state(iter) = 0;%DistBtwStates(state_proposed, current_state);
            %Update The Current State to Proposed State
            current_state = state_proposed ;
            acceptance = acceptance + 1 ;
        else
            L_dm(iter) = ComputeLikelihood(current_state, data_init) ;
        end
    else
        L_dm(iter) = ComputeLikelihood(current_state, data_init) ;
    end
    
end
fault_network = current_state;