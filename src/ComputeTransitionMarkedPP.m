function r_green = ComputeTransitionMarkedPP(gamma, beta, d, proposal, mark, state, perturbation, pert_ind, num_mark, n)
%ComputeTransitionMarkedPP compute transition kernel for the
%Metropolis-hastings sampler for Marked Strauss Point Process (MSPP)

%   INPUTS:
%   gamma: Global mark intensity parameter
%   beta: Beta parameter that controls attraction (positive) and repulsion
%   (negative) values
%   d: Attraction-repulsion distance between marks
%   mark: Mark for proposed object
%   state: Pre-existing mark configuration
%   perturbation: Proposed perturbation: add, remove or move
%   pert_ind: index for point to perturb
%   num_mark: number of marks
%   n: number of marks

%   level-set
%   OUTPUTS:
%   r_green: Green transition kernel for MSPP

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	March 2016; Last revision: 24-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.
%% 
% state.point = current_state ;
% state.mark = ones(size(current_state,1),1);
% mark = 2 ;
% beta = [-100,-100;-100,-100] ; 
% d = [100,200;200,500] ;
switch perturbation
    case 1
%% BIRTH PROCESS
        interaction_term = 0 ;
        for comp_mark = 1 :num_mark
            interaction_term = interaction_term + ...
                beta(mark,comp_mark) * PairsWithinD(proposal,state.point(state.mark==comp_mark,:),d(mark,comp_mark)) ;
        end
        
        r_green = 1/(n+1) * exp(-gamma(mark) - interaction_term) ;
%% DEATH PROCESS
    case 2
%         pert_ind = randi([size(initialization,1) + 1, size(state.point,1)]) ;
        death_mark = state.mark(pert_ind) ;
        %Compared State without the Erased Mark
        comp.state = state.point(setdiff(1 : size(state.point,1), pert_ind),:) ;
        comp.mark = state.mark(setdiff(1 : size(state.point,1), pert_ind));
        %Compute Interaction Term for Marked Process
        interaction_term_death = 0 ;
        for comp_mark = 1 :num_mark
            interaction_term_death = interaction_term_death + beta(death_mark,comp_mark) * ...
                                     PairsWithinD(state.point(pert_ind,:),comp.state(comp.mark==comp_mark,:),d(mark,comp_mark)) ;
        end
        r_green = n * exp(gamma(mark) + interaction_term_death) ;
%% MOVE PROCESS
    case 3
%         pert_ind = randi([size(initialization,1) + 1, size(state.point,1)]) ;
        mark = state.mark(pert_ind) ;
        %Compared State without the Erased Mark
        comp.state = state.point(setdiff(1 : size(state.point,1), pert_ind),:) ;
        comp.mark = state.mark(setdiff(1 : size(state.point,1), pert_ind));

        interaction_term = 0 ;
        for comp_mark = 1 :num_mark
            interaction_term = interaction_term + ...
                beta(mark,comp_mark) * ...
                PairsWithinD(proposal,comp.state(comp.mark==comp_mark,:),d(mark,comp_mark)) ;
        end

        r_green_new = 1/(n) * exp(-gamma(mark) - interaction_term) ;

        interaction_term = 0 ;
        for comp_mark = 1 :num_mark
            interaction_term = interaction_term + ...
                beta(mark,comp_mark) * ...
                PairsWithinD(state.point(pert_ind,:),comp.state(comp.mark==comp_mark,:),d(mark,comp_mark)) ;
        end
        r_green_old = 1/(n) * exp(-gamma(mark) - interaction_term) ;

        r_green = r_green_new / r_green_old ;
end