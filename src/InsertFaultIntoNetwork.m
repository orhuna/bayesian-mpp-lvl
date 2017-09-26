function fault = InsertFaultIntoNetwork(current_state, proposal,res,sim_size,az,dip,area_min)
% close all
% clearvars -except current_state proposal res sim_size az dip area_min data_surf
% state_proposed = {};
% prev_network = data_surf ;
% existing_network = horzcat(state_proposed,horzcat(prev_network{:})) ;
%             
% if ~isempty(existing_network)
%     existing_network = struct2cellFIX(existing_network) ;
% end
% current_state = existing_network ;
% 
% proposal = [4.92*10^5, 1.1955*10^5 , -5000 ];
% res = [10,10,10];
% sim_size = [400,400,500] ;
% az = [-50];
% dip = [5];
% area_min = [10^5,10^5];
%Write Out the Current State As a Series of Faults
cross_extent = -0.05 ;

fault_prev = [] ;
for net_ind = 1 : size(current_state,2)
    for fault_ind = 1 : size(current_state{net_ind},2)
        fault_prev = [fault_prev, current_state{net_ind}{fault_ind}] ;
    end
end

sim_ext = repmat(proposal,2,1) + [-0.5 * sim_size; 0.5 * sim_size];
%Propose Level-Sets for the Y-System
[x_sim,y_sim,z_sim,L_sim] = createNumericFaultProposal(az,dip,repmat(sim_size,2,1),res,sim_ext);
%Index If simulation Does not Break                      
sim_break = 0 ;
% close all
%% Impose Structural Relations Between Pre-Existing Network and Proposed Fault(s)
for fault_sim_ind = 1 : size(L_sim,2)
    %Set the Level-Set to Initial Values
    L{fault_sim_ind} = L_sim{fault_sim_ind} ;
    flag = containsPreviousFaults(fault_prev,proposal,sim_size) ;  
    count =0;
    for data_match_fault = find(flag~=0)
        %Calculate the Level-Set for Intersection
%         L_inter = pointset2LevelSet(fault_prev(data_match_fault).vertices,2,res, [min([x_sim{fault_sim_ind}(:),y_sim{fault_sim_ind}(:),z_sim{fault_sim_ind}(:)]);max([x_sim{fault_sim_ind}(:),y_sim{fault_sim_ind}(:),z_sim{fault_sim_ind}(:)])]) ;
        L_inter = ComputeIntersectionLVL(fault_prev(data_match_fault).vertices, x_sim{fault_sim_ind}, y_sim{fault_sim_ind}, z_sim{fault_sim_ind}) ;

        %Implicit Representation of Abutting Rules on Level-Set
        L_p = L{fault_sim_ind} ; L_n = L_p ;
        % Compute Level-Sets on Both Side of the Abutting Fault- Positive Side
        L_p(L_inter > cross_extent) = NaN ;
        [fault_area.p, contour_values.p]  = possibleAreaswithinLVL(fault_prev(data_match_fault),x_sim{fault_sim_ind},y_sim{fault_sim_ind},z_sim{fault_sim_ind},L_p) ;
        ind.p= find(fault_area.p > area_min(fault_sim_ind));
       
        % Compute Level-Sets on Both Side of the Abutting Fault- Negative Side
        L_n(L_inter < -cross_extent) = NaN ;
        [fault_area.n, contour_values.n] = possibleAreaswithinLVL(fault_prev(data_match_fault),x_sim{fault_sim_ind},y_sim{fault_sim_ind},z_sim{fault_sim_ind},L_n) ;
        ind.n = find(fault_area.n > area_min(fault_sim_ind));
        %Calculate Where the Proposed Point Is
%         D = signed_distance(fault_prev(data_match_fault).vertices,proposal);
        F = scatteredInterpolant(x_sim{fault_sim_ind}(:),y_sim{fault_sim_ind}(:),z_sim{fault_sim_ind}(:),L_inter(:)) ;
        D = F(proposal(1),proposal(2),proposal(3)) ;
        %If Surface Has Contours that Satisfy Relations on Both Sides
%         if ~isempty(ind.n) && ~isempty(ind.p)
            if D>0
                L{fault_sim_ind} = L_n;
            else
                L{fault_sim_ind} = L_p;
            end
%         end
        %If Contours that Satisfy Relations Exist only on One Side
%         if ~isempty(ind.n) && isempty(ind.p)
%             if D>0
%                 L{fault_sim_ind} = L_n;
%             end
%         else if isempty(ind.n) && ~isempty(ind.p)
%                 if D<0
%                     L{fault_sim_ind} = L_p ;
%                 end
%             end
%         end
        %If there are No Contours That Satisfy Relations - Do Not Modify
        count =count+1;
    end
    % Cut-Out the Fault As an Isosurface from Level-Set
    F = scatteredInterpolant(x_sim{fault_sim_ind}(:),y_sim{fault_sim_ind}(:),z_sim{fault_sim_ind}(:),L{fault_sim_ind}(:)) ;
    cont(fault_sim_ind) = F(proposal(1), proposal(2), proposal(3)) ;
end
%Impose Structural Rules on Faults
if length(cont) > 1
    if dip(1) > 0
       L_major = L{1} ;
       L_minor = L{2} ;
       L_minor(L_major < cont(1) * 1.02) = NaN;
    else dip(2)
            L_major = L{2} ;
            L_minor = L{1} ;
        L_minor(L_major < cont(2) * 1.02) = NaN;
    end
    fault{1} = isosurface(x_sim{1}, y_sim{1}, z_sim{1}, L_major, cont(1));
    fault{2} = isosurface(x_sim{1}, y_sim{1}, z_sim{1}, L_minor, cont(2));
else
    %%TRIAL Erase One Line Below ;; cont(1) = 0 ;
    L_major = L{1} ;
    fault{1} = isosurface(x_sim{1}, y_sim{1}, z_sim{1}, L_major, cont(1));
end
% patch(fault{2})
%%
% c = {'r','b','g','k','m'};
% close all
% % for f_ind = 1
%     figure,
%     %Plot Pre-Existing Faults
%     for net_ind = 1 : size(current_state,2)
%         for fault_ind = 1 : size(current_state{net_ind},2)
%             patch(current_state{net_ind}{fault_ind},'FaceColor',c{fault_ind},'EdgeColor','none','FaceAlpha',1)
%         end
%     end
%     hold on
%     patch(fault{1},'FaceColor','k')
% %     patch(fault{2},'FaceColor','m')
% %     drawBox(repmat(proposal,2,1)+[-sim_size/2;sim_size/2])
% %     scatter3(proposal(1),proposal(2),proposal(3),100,'filled')
% %     scatter3(fault_prev(data_match_fault).vertices(:,1), fault_prev(data_match_fault).vertices(:,2),fault_prev(data_match_fault).vertices(:,3),'filled')
% %     visualizeLevelSet(x_sim{1},y_sim{1},z_sim{1},L_sim{1},0.4)
%     visualizeLevelSet(x_sim{1},y_sim{1},z_sim{1},L_p,0.5)
%     view([-11 30])
% %     %Plot Proposed Object Location
% %     scatter3(proposal(1),proposal(2),proposal(3),100,'filled')
% %     %Draw Proposed Simulation Box
% %     drawBox(sim_ext)
% %      %saveas(gcf, 'C:\Users\orhuna\Desktop\Autumn 2015\Figures\BirthProposalBox.emf')
% %     visualizeLevelSet(x_sim{f_ind},y_sim{f_ind},z_sim{f_ind},L_sim{f_ind},1)
% %      %saveas(gcf, ['C:\Users\orhuna\Desktop\Autumn 2015\Figures\BirthProposalInitLVL_',num2str(f_ind),'.emf'])
% % end
% % % 
% % %Plot the Sculpted Level-Sets
% % for f_ind = 1
% %     figure,
% %     %Plot Pre-Existing Faults
% %     for net_ind = 1 : size(current_state,2)
% %         for fault_ind = 1 : size(current_state{net_ind},2)
% %             patch(current_state{net_ind}{fault_ind},'FaceColor',c{net_ind},'EdgeColor','none','FaceAlpha',1)
% %         end
% %     end
% %     hold on
% %     view([-11 30])
% %     patch(fault{f_ind})
% %     %Plot Proposed Object Location
% %     scatter3(proposal(1),proposal(2),proposal(3),100,'filled')
% %     %Draw Proposed Simulation Box
% %     drawBox(sim_ext )
% %     visualizeLevelSet(x_sim{f_ind},y_sim{f_ind},z_sim{f_ind},L{f_ind},1)
% %      %saveas(gcf, ['C:\Users\orhuna\Desktop\Autumn 2015\Figures\BirthProposalSculptedLVL_',num2str(f_ind),'.emf'])
% % end
% % % 
% % figure,
% % %Plot Pre-Existing Faults
% % for net_ind = 1 : size(current_state,2)
% %     for fault_ind = 1 : size(current_state{net_ind},2)
% %         patch(current_state{net_ind}{fault_ind},'FaceColor',c{net_ind},'EdgeColor','none','FaceAlpha',1)
% %     end
% % end
% % view([-2 4])
% % patch(fault{1})
% % %saveas(gcf, 'C:\Users\orhuna\Desktop\Autumn 2015\Figures\FinalFaults')
% %%
% % close all
% % clc
% % data_match_fault = 1 ;
% % fault_sim_ind = 1 ;
% % 
% % L_inter = ComputeIntersectionLVL(fault_prev(data_match_fault).vertices, x_sim{fault_sim_ind}, y_sim{fault_sim_ind}, z_sim{fault_sim_ind}) ;
% % 
% % L_p = L_sim{fault_sim_ind} ; L_n = L_p ;
% % % Compute Level-Sets on Both Side of the Abutting Fault- Positive Side
% % L_p(L_inter > 0.2) = NaN ;
% % L_n(L_inter < -0.2) = NaN ;
% % 
% % visualizeLevelSet(x_sim{fault_sim_ind},y_sim{fault_sim_ind},z_sim{fault_sim_ind},L_inter,0.5)
% % patch(fault_prev(data_match_fault))
% % patch(isosurface(x_sim{fault_sim_ind},y_sim{fault_sim_ind},z_sim{fault_sim_ind},L_inter,0))
% % hold on
% % scatter3(proposal(1),proposal(2),proposal(3),'filled')
% % 
% % figure,
% % visualizeLevelSet(x_sim{fault_sim_ind},y_sim{fault_sim_ind},z_sim{fault_sim_ind},L_p,0.5)
% % hold on
% % scatter3(proposal(1),proposal(2),proposal(3),'filled')
% % patch(fault_prev(data_match_fault))
% % 
% % figure,
% % visualizeLevelSet(x_sim{fault_sim_ind},y_sim{fault_sim_ind},z_sim{fault_sim_ind},L_n,0.5)
% % hold on
% % scatter3(proposal(1),proposal(2),proposal(3),'filled')
% % patch(fault_prev(data_match_fault))
% % 
% % 
% % 
