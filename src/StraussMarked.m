function [state,varargout] = StraussMarked(gamma, beta, d, max_mark, num_iter, sim_ext, initialization, move_bounds )
%StraussMarked function for simulating Marked Strauss Process for fault
%center locations

%   INPUTS:
%   gamma: Global mark intensity parameter
%   beta: Beta parameter that controls attraction (positive) and repulsion
%   (negative) values
%   d: Attraction-repulsion distance between marks
%   max_mark: Maximum value for discrete marks
%   num_iter: Number of Interations
%   sim_ext: Simulation extent in x, y, z
%   initialization: marked points that match fault data
%   move_bounds : 1X3 array for maximum move perturbation in x, y and z

%   level-set
%   OUTPUTS:
%   state: Marked strauss points process realization
%   varargout{1} = action : Record of add, remove, move perturbations
%   varargout{2} = record : Snapshots of fault network throughout McMC
%   varargout{3} = acc :
%   varargout{4} = dissimilarity: Dissimilarity between fault networks 
%   throughout McMC
%   

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	August 2016; Last revision: 23-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.
%% 
state.point = initialization.point ;
state.mark =  initialization.mark ;

birth_num = 0 ;
acceptance = 0 ;
action = [];
h = waitbar(0,'Markov Chain Monte Carlo in Progress...');
for iter = 2 : num_iter
    waitbar(iter / num_iter)
    
    state_proposed = [];
    change_flag = 0 ;
    n = length(state.point) ;
    %Propose a New State (Birth-Death, Modify or Move)
    u = rand() ;
    %%
    %Birth-Death
    if u <= 0.5
        %Calculate Probability for Death or a Birth Process
        p_death_birth = rand() ;
        switch p_death_birth <= 0.5
            %%
            %BIRTH PROCESS
            case 1
            %Propose a Location in 3D Space
            mark = randi([1 max_mark]) ;
            proposal = rand(1,3) .* diff(sim_ext) + sim_ext(1,:) ;
            r_green_birth = ComputeTransitionMarkedPP(gamma, beta, d, proposal, mark, state, 1, 0, max_mark, n) ;
            p_birth  =min([1,r_green_birth]) ;

            display('Birth Picked')
            
            action  = [action,1] ;
            
            if p_birth >rand()
                
                old.point = state.point ;
                acc(iter) = 1 ;

                state.point = [state.point; proposal] ;
                state.mark  =[state.mark;mark] ;
                if ~isempty(old.point)
                    dissimilarity.point(iter) = MHD(old.point,state.point) ;
                end
            else
                acc(iter) = 0 ;
            end
            %%
            %DEATH PROCESS
            case 0
                display('Death Picked')
                if size(state.point,1) > size(initialization.point,1)
                    death_ind = randi([size(initialization.point,1) + 1, size(state.point,1)]) ;               
                    r_green = ComputeTransitionMarkedPP(gamma, beta, d, 0, state.mark(death_ind), state, 2, death_ind, max_mark, n) ;
                    p_death  =min([1,r_green]) ;
                else
                    p_death = 0;
                end
                
                action  = [action,-1] ;
                if p_death > rand()
                    acc(iter) = 1 ;
                   
                   display('Death Proposed')
                   
                   old.point = state.point ;
                   
                   state.point(death_ind,:)=[];
                   state.mark(death_ind,:)=[];

                    if ~isempty(old.point) && ~isempty(state.point)
                        dissimilarity.point(iter) = MHD(old.point,state.point) ;
                    end
                else
                    acc(iter) = 0 ;
                end
        end
%% MOVE FAULT OBJECT        
        else if u > 0.5 && ~isempty(state.point)
                if size(state.point,1) > size(initialization.point,1)
                    move_ind = randi([size(initialization.point,1)+1 size(state.point,1)]);
                    proposal = state.point(move_ind, :) ;
                    proposal = proposal + move_bounds(:,1)' + (-1 + 2* rand(1,3)) .* range(move_bounds') ;
                    r_green_move = ComputeTransitionMarkedPP(gamma, beta, d, proposal, 0, state, 3, move_ind, max_mark, n) ;
                else
                    r_green_move = 0 ;
                end
                action = [action,0.5] ;
                if r_green_move > rand()
                    acc(iter) = 1 ;
                    old.point = state.point ;
                    
                    state.point(move_ind,:) = [] ;
                    state.point = [state.point;proposal] ;
                    
                    move_mark = state.mark(move_ind,:) ;
                    state.mark(move_ind,:) = [] ;
                    state.mark = [state.mark;move_mark] ;
                    dissimilarity.point(iter) = MHD(old.point,state.point) ;
                else
                    acc(iter) = 0 ;
                end
            end   
    end
   
    record{iter} = state ;
end
close(h)
%Return 
varargout{1} = action ;
varargout{2} = record ;
varargout{3} = acc ;
varargout{4} = dissimilarity;
