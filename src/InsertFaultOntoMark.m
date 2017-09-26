function fault_sim = InsertFaultOntoMark(current_state, proposal,res,sim_size,az,dip, curv_par)
%InsertFaultOntoMark simulate fault surface on a given set of points

%   INPUTS:
%   current_state: 3D surfaces for pre-existing faults in the network
%   proposal: faults to insert into the network (faults younger than
%   current_state)
%   res: 1x3 array containing x, y, z resolution for the 3-D cube for
%   sim_size: 1x3 array containing dx, dy, dz for the simulation area
%   az: azimuth angle(in degrees)
%   dip: dip angle (in degrees)
%   curv_par = curvature parameter for fault surface to be fitted(1:planar)
%   

%   level-set
%   OUTPUTS:
%   fault_sim: fault network with proposed faults inserted onto current
%   state

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	August 2016; Last revision: 23-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.
%% Write Out the Current State As a Series of Faults

seed=randi([10^7,10^8]);
nugget = 0.05 ;
range.min=30; range.med=40; range.max=50;
angle.x=0; angle.y=0; angle.z=0;

fault_prev = [];
if ~isempty(current_state)
    for net_ind = 1 : size(current_state,2)
            fault_prev = [fault_prev, current_state{net_ind}] ;
    end
end

sim_ext = repmat(proposal,2,1) + [-0.5 * sim_size; 0.5 * sim_size];
%Propose Level-Sets for the Y-System
[x_sim,y_sim,z_sim,L_sim] = createNumericFaultOnMark(az,dip,repmat(sim_size,2,1),res,proposal,curv_par);
%Index If simulation Does not Break
sim_break = 0 ;
% close all
%% Impose Structural Relations Between Pre-Existing Network and Proposed Fault(s)
for fault_sim_ind = 1 : size(L_sim,2)
    %Set the Level-Set to Initial Values
    perturb_cube = runSGSIM(res,seed,nugget,range,angle)/20;
    
    L{fault_sim_ind} = L_sim{fault_sim_ind} + perturb_cube ;
    
    flag = containsPreviousFaults(fault_prev,proposal(fault_sim_ind,:),sim_size(fault_sim_ind,:)) ;  

    for data_match_fault = find(flag~=0)
        %Calculate the Level-Set for Intersection
%         L_inter = pointset2LevelSet(fault_prev(data_match_fault).vertices,2,res, [min([x_sim{fault_sim_ind}(:),y_sim{fault_sim_ind}(:),z_sim{fault_sim_ind}(:)]);max([x_sim{fault_sim_ind}(:),y_sim{fault_sim_ind}(:),z_sim{fault_sim_ind}(:)])]) ;
        L_inter = ComputeIntersectionLVL(fault_prev(data_match_fault).vertices, x_sim{fault_sim_ind}, y_sim{fault_sim_ind}, z_sim{fault_sim_ind}) ;
        %Find the sign of the 
        F_proposal = scatteredInterpolant(x_sim{fault_sim_ind}(:), y_sim{fault_sim_ind}(:), z_sim{fault_sim_ind}(:),L_inter(:)) ;
        proposal_side = F_proposal(proposal(fault_sim_ind,1), proposal(fault_sim_ind,2),proposal(fault_sim_ind,3));
        
        if proposal_side >= 0
           L{fault_sim_ind}(L_inter<0) = NaN;
        else if proposal_side < 0
                L{fault_sim_ind}(L_inter >= 0) = NaN;
            end
        end
    end
    % Cut-Out the Fault As an Isosurface from Level-Set
    F = scatteredInterpolant(x_sim{fault_sim_ind}(:),y_sim{fault_sim_ind}(:),z_sim{fault_sim_ind}(:),L{fault_sim_ind}(:)) ;
    cont(fault_sim_ind) = F(proposal(fault_sim_ind,1), proposal(fault_sim_ind,2), proposal(fault_sim_ind,3)) ;
    fault_sim{fault_sim_ind} = isosurface(x_sim{fault_sim_ind}, y_sim{fault_sim_ind},z_sim{fault_sim_ind},L{fault_sim_ind},cont(fault_sim_ind)) ;
end
% patch(fault{2})
%%
% c = {'r','b','g','y','m'};
% % close all
% % for f_ind = 1
%     figure,
%     %Plot Pre-Existing Faults
%     for net_ind = 1 : size(fault_prev,2)
%         patch(fault_prev(net_ind),'FaceColor','k','EdgeColor','none','FaceAlpha',1)
%     end
%     %Simualted Faullts
%     for net_ind = 1 : size(cont,2)
%         patch(fault_sim{net_ind},'FaceColor',c{net_ind},'EdgeColor','none','FaceAlpha',1)
%     end
%     hold on
%     scatter3(marks.point(:,1),marks.point(:,2),marks.point(:,3),100,marks.mark,'filled')
% xlabel('x (m)','FontName','Arial','FontSize',14)
% ylabel('y (m)','FontName','Arial','FontSize',14)
% zlabel('z (m)','FontName','Arial','FontSize',14)
% set(gca,'FontName','Arial','FontSize',14)
% view([5 4])
%     for fault_sim_ind = 1 : size(x_sim,2)
%         visualizeLevelSet(x_sim{fault_sim_ind},y_sim{fault_sim_ind},z_sim{fault_sim_ind},L_sim{fault_sim_ind},0.1)
%     end
%     
% figure,
% scatter3(fault_prev(data_match_fault).vertices(:,1),fault_prev(data_match_fault).vertices(:,2),fault_prev(data_match_fault).vertices(:,3),100,'filled')
% hold on
% visualizeLevelSet(x_sim{fault_sim_ind}, y_sim{fault_sim_ind}, z_sim{fault_sim_ind},L{fault_sim_ind},0.1)
% hold on
% patch(isosurface(x_sim{fault_sim_ind}, y_sim{fault_sim_ind}, z_sim{fault_sim_ind},L_inter,0))
% hold on
% scatter3(proposal(2,1),proposal(2,2),proposal(2,3),1000,'filled')
% hold off
%     
%     hold on
%     patch(fault{1},'FaceColor','k')
%     patch(fault{2},'FaceColor','m')
%     drawBox(repmat(proposal,2,1)+[-sim_size/2;sim_size/2])
%     scatter3(proposal(1),proposal(2),proposal(3),100,'filled')
%     scatter3(fault_prev(data_match_fault).vertices(:,1), fault_prev(data_match_fault).vertices(:,2),fault_prev(data_match_fault).vertices(:,3),'filled')
%     visualizeLevelSet(x_sim{1},y_sim{1},z_sim{1},L_sim{1},0.4)
%     visualizeLevelSet(x_sim{1},y_sim{1},z_sim{1},L_p,0.5)
%     view([-11 30])
%     %Plot Proposed Object Location
%     scatter3(proposal(1),proposal(2),proposal(3),100,'filled')
%     %Draw Proposed Simulation Box
%     drawBox(sim_ext)
%      %saveas(gcf, 'C:\Users\orhuna\Desktop\Autumn 2015\Figures\BirthProposalBox.emf')
%     visualizeLevelSet(x_sim{f_ind},y_sim{f_ind},z_sim{f_ind},L_sim{f_ind},1)
%      %saveas(gcf, ['C:\Users\orhuna\Desktop\Autumn 2015\Figures\BirthProposalInitLVL_',num2str(f_ind),'.emf'])
% end
% % 
% %Plot the Sculpted Level-Sets
% for f_ind = 1
%     figure,
%     %Plot Pre-Existing Faults
%     for net_ind = 1 : size(current_state,2)
%         for fault_ind = 1 : size(current_state{net_ind},2)
%             patch(current_state{net_ind}{fault_ind},'FaceColor',c{net_ind},'EdgeColor','none','FaceAlpha',1)
%         end
%     end
%     hold on
%     view([-11 30])
%     patch(fault{f_ind})
%     %Plot Proposed Object Location
%     scatter3(proposal(1),proposal(2),proposal(3),100,'filled')
%     %Draw Proposed Simulation Box
%     drawBox(sim_ext )
%     visualizeLevelSet(x_sim{f_ind},y_sim{f_ind},z_sim{f_ind},L{f_ind},1)
%      %saveas(gcf, ['C:\Users\orhuna\Desktop\Autumn 2015\Figures\BirthProposalSculptedLVL_',num2str(f_ind),'.emf'])
% end
% % 
% figure,
% %Plot Pre-Existing Faults
% for net_ind = 1 : size(current_state,2)
%     for fault_ind = 1 : size(current_state{net_ind},2)
%         patch(current_state{net_ind}{fault_ind},'FaceColor',c{net_ind},'EdgeColor','none','FaceAlpha',1)
%     end
% end
% view([-2 4])
% patch(fault{1})
% %saveas(gcf, 'C:\Users\orhuna\Desktop\Autumn 2015\Figures\FinalFaults')
%%
% close all
% clc
% data_match_fault = 1 ;
% fault_sim_ind = 1 ;
% 
% L_inter = ComputeIntersectionLVL(fault_prev(data_match_fault).vertices, x_sim{fault_sim_ind}, y_sim{fault_sim_ind}, z_sim{fault_sim_ind}) ;
% 
% L_p = L_sim{fault_sim_ind} ; L_n = L_p ;
% % Compute Level-Sets on Both Side of the Abutting Fault- Positive Side
% L_p(L_inter > 0.2) = NaN ;
% L_n(L_inter < -0.2) = NaN ;
% 
% visualizeLevelSet(x_sim{fault_sim_ind},y_sim{fault_sim_ind},z_sim{fault_sim_ind},L_inter,0.5)
% patch(fault_prev(data_match_fault))
% patch(isosurface(x_sim{fault_sim_ind},y_sim{fault_sim_ind},z_sim{fault_sim_ind},L_inter,0))
% hold on
% scatter3(proposal(1),proposal(2),proposal(3),'filled')
% 
% figure,
% visualizeLevelSet(x_sim{fault_sim_ind},y_sim{fault_sim_ind},z_sim{fault_sim_ind},L_p,0.5)
% hold on
% scatter3(proposal(1),proposal(2),proposal(3),'filled')
% patch(fault_prev(data_match_fault))
% 
% figure,
% visualizeLevelSet(x_sim{fault_sim_ind},y_sim{fault_sim_ind},z_sim{fault_sim_ind},L_n,0.5)
% hold on
% scatter3(proposal(1),proposal(2),proposal(3),'filled')
% patch(fault_prev(data_match_fault))
% 
% 
% 
