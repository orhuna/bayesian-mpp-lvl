function d=MHD(A,B)
%Modified Hausdorff distance between two pointsets

%   INPUTS:
%   A: First pointset to compare
%   B: Second pointset to compare

%   level-set
%   OUTPUTS:
%   d: Modified Hausdorff distance between pointsets A and B

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	Sep 2013; Last revision: 23-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.

%% 

s(1,:)=size(A);s(2,:)=size(B);
%Check for Dimensional Consistency
if s(1,2)==s(2,2)
    %Forward Distance
    da=pdist(vertcat(A,B));
    da=squareform(da);
    da=da+999*max(max(da))*eye(size(da)); 
    fma=da(1:s(1,1),s(1,1)+1:end);
    rma=da(s(2,1)+1:end,1:s(2,1));
    
    fhd=sum(min(fma));
    rhd=sum(min(rma));
    
    fhd=fhd./s(1,1);
    rhd=rhd./s(2,1);
    d=max(fhd,rhd);
end   