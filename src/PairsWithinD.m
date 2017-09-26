function s = PairsWithinD(proposal,current_state,d)
%ComputeTransitionMarkedPP compute transition kernel for the
%Metropolis-hastings sampler for Marked Strauss Point Process (MSPP)

%   INPUTS:
%   proposal: proposed mark
%   current_state: pre-existing marks
%   d: Attraction-repulsion distance between marks

%   level-set
%   OUTPUTS:
%   s: Index of pairs with distance d

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	February 2016; Last revision: 24-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.
%% Calculate the Distance of the Proposal to Every State Variable
d_p = pdist([proposal;current_state]) ;
d_p(length(current_state)+1:end) = [] ;
s = length(find(d_p<=d)) ;

