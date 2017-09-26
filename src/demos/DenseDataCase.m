clear all
close all
clc
%Add src to directory
addpath(fileparts(pwd))
%%

sim_ext = [500,  500, -2500;...
           3500, 1000, -1600] ;

res = [20,20,40];
% fault_network = []; 
% init.point = [];
% init.mark = [];
%% Create Hard-Data
%Centroids for fault observations
data.point = [ 2500, 750, -2000;...
               2450, 750, -1900;...
               1100, 750, -1900; ...
               1350, 750, -2000; ...
               3000, 750, -2000; ...
               3500, 750, -2000; ...
               1500, 750, -2000; ...
               1600, 750, -1700; ...
               1700, 750, -2000; ...
               1800, 750, -2200] ;
           
%Hiearchy for fault observations (1-> Older fault, 2-> Younger fault)
data.mark = [1; 2; 1; 2; 1; 2; 1; 1; 2; 1];

scatter3(data.point(:,1), data.point(:,2), data.point(:,3),100,data.mark, 'Filled')   
hold on
drawBox(sim_ext)
hold off
           
az_data = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5] ;
dip_data =  [70,-80, 70, -80, 70, -80, 70, 70, -80, 70] ;

data_size = [1000,1000,400;...
            1000,1000,300;...
            1000,300,300;...
            1000,400,500;...
            1000,400,300;...
            1000,400,300;...
            1000,400,300;...
            1000,400,300;...
            1000,400,300;...
            1000,400,300] ;

data_network = createDataMarkedCase(data, az_data, dip_data, data_size, res) ;

figure,
for i = 1 : length(data_network)
%     scatter3(data_network{i}.vertices(:,1),data_network{i}.vertices(:,2),data_network{i}.vertices(:,3),50,'filled')
    patch(data_network{i},'FaceColor',rand(1,3),'EdgeColor','none')
    hold on
end
xlabel('X (m)','Fontname','Arial','FontSize',14)
ylabel('Y (m)','Fontname','Arial','FontSize',14)
zlabel('Z (m)','Fontname','Arial','FontSize',14)
set(gca,'Fontname','Arial','FontSize',14,'YTick',[],'XLim',[1000 4000],...
    'YLim',sim_ext(:,2)','ZLim',[-2300 -1600])
view([-2 2])
% %saveas(gcf, 'C:\Users\orhuna\Desktop\Autumn 2015\Figures\dense_hard_data.emf')
%% Create Hard-Data
num_rels = 10 ;
num_iter = 10000 ;
for rel_ind = 1 : num_rels
% init.point = [];
% init.mark = [];
init = data ;
gamma=[-2-10*rand(),-1-5*rand()];
%Check if beta and d is consistent with mark size if not return error
beta = [100,50;...
        50,100] ;
    
d = [400,100;...
     100,300] ;
 
% beta = [100,-100,0;...
%         0, 200, -1000;...
%         0,-200, 0] ;
% d = [200,20,50;...
%      0,300,50;
%      0,0,100] ; 
 
%Number of Marks to Simulate
max_mark = 2;
% Simulation Inputs


% initialization.point = [];
% 
% initialization.mark = [] ;

move_bounds = [ 1,50;...
                0,0;...
                 0,0] ;
param{rel_ind}.gamma = gamma ;
param{rel_ind}.beta = beta ;
param{rel_ind}.d = d ;
num_horizons = 5;
[state{1},action{1}, states{1}, acc{1}] = StraussMarked(gamma, beta, d, max_mark, num_iter, sim_ext, init, move_bounds );             
%Compute Dissimilarity Between States of the Markov Chain
% for state_length = 2 : num_iter-1
%     d_states(state_length-1,1) = MHD(states{1}{state_length}.point,states{1}{state_length+1}.point) ;
%     l_point(state_length-1,1) = length(states{1}{state_length}.point);
% end
% figure, plot(2:num_iter,d_states,'LineWidth',2)
% figure, scatter(2:num_iter,l_point,'Marker', '.')
% gamma=[-1,-2];
[state{rel_ind},action{rel_ind}, states{rel_ind}, acc{rel_ind}] = StraussMarked(gamma, beta, d, max_mark, num_iter, sim_ext, init, move_bounds );
end
% figure, plot(cumsum(acc{1})/length(acc{1}),'LineWidth',3)
% hold on
% plot(cumsum(acc{2})/length(acc{2}),'LineWidth',3,'Color','r')
% xlabel('Number of Interations','Fontname','Arial','FontSize',14)
% ylabel('Acceptance Rate','Fontname','Arial','FontSize',14)
% legend('\gamma = -5 , \beta=-4','\gamma = -1 , \beta=-2','Fontname','Arial','FontSize',14,'Location','NorthWest')
% set(gca,'Fontname','Arial','FontSize',14)
% hold off
%%
fault_network =[];
colors = ['b','r','m','g'];
c ='bbrr';
for mark_type = 1 : max(state{2}.mark)
    sign = (mark_type==1)-1*(mark_type==2) ;
    sim_size = randi([800,1500],length(find(state{2}.mark==mark_type)),3) ;
    az = repmat(5, length(find(state{2}.mark==mark_type)),1) ;
    dip = sign * randi([70 80], length(find(state{2}.mark==mark_type)),1) ;
    proposal = state{2}.point(state{2}.mark==mark_type,:) ;
    count = 0 ;
    for fault_ind = 1 : length(find(state{2}.mark==mark_type))
        fault_proposed = InsertFaultOntoMark(fault_network, proposal(fault_ind,:),res,sim_size(fault_ind,:),az(fault_ind),dip(fault_ind), 2) ;
        if ~isempty(fault_proposed{1}.vertices)
            count = count + 1 ;
            fault_network = [fault_network, fault_proposed] ;
        end
    end
    c = [c , repmat(colors(mark_type),1,count)] ;
end
network_ensemble{rel_ind} = fault_network ;
%%
figure,

for i = 1 : length(data_network)
    patch(data_network{i},'FaceColor','r','EdgeColor','none')
    hold on
end

for ind = 1 : size(fault_network,2)
    patch(fault_network{ind},'FaceColor','k','EdgeColor','none','FaceAlpha',0.8)
end
xlabel('X (m)','Fontname','Arial','FontSize',14)
ylabel('Y (m)','Fontname','Arial','FontSize',14)
zlabel('Z (m)','Fontname','Arial','FontSize',14)
set(gca,'Fontname','Arial','FontSize',14,'YTick',[],'XLim',[-500 4000],...
    'YLim',sim_ext(:,2)','ZLim',[-2300 -1800])
view([-2 2])