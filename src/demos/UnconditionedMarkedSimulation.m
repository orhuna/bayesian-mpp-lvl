clear all
close all
clc
%Add src to directory
addpath(fileparts(pwd))
%% Define Simulation Extent and Resolution for Simulation

sim_ext = [500,  500, -2500;...
           3500, 1000, -1600] ;

res = [10,10,10];
% fault_network = []; 
% init.point = [];
% init.mark = [];
%% Create Hard-Data
data.point = [ 2500, 750, -2000;...
               2450, 750, -1900;...
               1100, 750, -1900; ...
               1350, 750, -2000] ;
data.mark = [1; 2; 1; 2];
az_data = [5, 5, 5, 5] ;
dip_data =  [70,-80, 70, -80] ;

data_size = [1000,1000,400;...
            1000,1000,300;...
            1000,300,300;...
            1000,400,500] ;

data_network = createDataMarkedCase(data, az_data, dip_data, data_size, res) ;

for i = 1 : length(data_network)
%     scatter3(data_network{i}.vertices(:,1),data_network{i}.vertices(:,2),data_network{i}.vertices(:,3),50,'filled')
    patch(data_network{i},'FaceColor','r','EdgeColor','none')
    hold on
end
xlabel('X (m)','Fontname','Arial','FontSize',14)
ylabel('Y (m)','Fontname','Arial','FontSize',14)
zlabel('Z (m)','Fontname','Arial','FontSize',14)
set(gca,'Fontname','Arial','FontSize',14,'YTick',[],'XLim',[-500 4000],...
    'YLim',sim_ext(:,2)','ZLim',[-2300 -1800])
view([-3 10])
%%saveas(gcf, 'C:\Users\orhuna\Desktop\Autumn 2015\Figures\hard_data.emf')
%% Initializations
%Number of Different Initializations
num_init = 100;
for ind_init = 1 : num_init
init_size = [randi([1000 4000]),randi([1200 1500]),randi([400 550]);...
            randi([1000 4000]),randi([1200 1500]),randi([300 550]);...
            randi([1000 4000]),randi([1200 1500]),randi([300 550]);...
            randi([1000 4000]),randi([1200 1500]),randi([500 550])] ;

    initial_network{ind_init} = createDataMarkedCase(data, az_data, dip_data, init_size, res) ;
end
%% Simulate Unconditional Realiations
num_rels = 100 ;
for rel_ind = 1 : num_rels
    display(num2str(num_rels))
init.point = [];
init.mark = [];
gamma=[-4*rand(),-4*rand()];
%Check if beta and d is consistent with mark size if not return error
beta = [100,50;...
        50,100] ;
d = [400,100;...
     100,300] ;

%Number of Marks to Simulate
max_mark = 2;
% Simulation Inputs
num_iter = 10000 ;

move_bounds = [ 1,50;...
                0,0;...
                 0,0] ;

num_horizons = 5;
[state,action, states, acc] = StraussMarked(gamma, beta, d, max_mark, num_iter, sim_ext, init, move_bounds );             
fault_network =[];
colors = ['b','r','m','g'];
c ='bbrr';
%Simulate Fault Network by Hierarchy (Oldest to Youngest)
for mark_type = 1 : max(state.mark)
    sign = (mark_type==1)-1*(mark_type==2) ;
    sim_size = randi([800,1500],length(find(state.mark==mark_type)),3) ;
    az = repmat(5, length(find(state.mark==mark_type)),1) ;
    dip = sign * randi([70 80], length(find(state.mark==mark_type)),1) ;
    proposal = state.point(state.mark==mark_type,:) ;
    count = 0 ;
    for fault_ind = 1 : length(find(state.mark==mark_type))
        fault_proposed = InsertFaultOntoMark(fault_network, proposal(fault_ind,:),res,sim_size(fault_ind,:),az(fault_ind),dip(fault_ind), 2) ;
        if ~isempty(fault_proposed{1}.vertices)
            count = count + 1 ;
            fault_network = [fault_network, fault_proposed] ;
        end
    end
    c = [c , repmat(colors(mark_type),1,count)] ;
end
network_ensemble{rel_ind} = fault_network ;
end
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
view([21 12])
axis tight
view([-2 2])
%% Compute Dissimilarity Matrices
%Lump Data Points into Matrices
lumped_data = [];
for data_ind = 1 : size(data_network,2)
    lumped_data = [lumped_data ; data_network{data_ind}.vertices];
end
% Lump Fault Points in Networks into Matrices
count_nonempty = 0 ;
for net_ind = 1 : size(network_ensemble,2)
    fault_points = [];
    if ~isempty(network_ensemble{net_ind})
        count_nonempty = count_nonempty + 1 ;
        for fault_ind = 1 : size(network_ensemble{net_ind},2)       
            fault_points = [fault_points;network_ensemble{net_ind}{fault_ind}.vertices];
        end
        lumped_points{count_nonempty} = fault_points;
    end
end
%Lump Fault Networks
for net_ind = 1 : size(initial_network,2)
    fault_points = [];
    if ~isempty(initial_network{net_ind})
        count_nonempty = count_nonempty + 1 ;
        for fault_ind = 1 : size(initial_network{net_ind},2)       
            fault_points = [fault_points;initial_network{net_ind}{fault_ind}.vertices];
        end
        lumped_points{count_nonempty} = fault_points;
    end
end
lumped_points{count_nonempty+1} = lumped_data ;
d = zeros(size(lumped_points,2), size(lumped_points,2)) ;
%% Compute MHD Between Data and Networks
for comp_ind_1 = 1 : size(lumped_points,2) - 1
    comp_ind_1
    for comp_ind_2 = comp_ind_1 +1 :size(lumped_points,2)
        comp_ind_2
        d(comp_ind_1,comp_ind_2) = MHD(lumped_points{comp_ind_1},lumped_points{comp_ind_2}) ;
    end
end
d = d + d' ;
[y, e]= cmdscale(d) ;
%%
    c_mat = zeros(size(y,1),3) ;
    c_mat(end,:) = [1 0  0] ;
    figure,scatter(y(:,1),y(:,2),150,c_mat,'filled','MarkerEdgeColor','k')
    set(gca,'XTickLabel','','YTickLabel','','ZTickLabel','')
    xlabel('')
    ylabel('')
%%
f_net = [] ;
for net_ind = 1 : size(network_ensemble,2)
    if ~isempty(network_ensemble{net_ind})
        f_net =[f_net,network_ensemble(net_ind)];
    end
end
%% Visualize Fault Data Initializations
figure,
c = 'rbgmcrbgmc' ;

for net_ind = 1:10
    fault_network = initial_network{net_ind} ;
    figure,
    for ind = 1 : size(fault_network,2)
        patch(fault_network{ind},'FaceColor',c(ind),'EdgeColor','k','FaceAlpha',1)
    end
    xlim([-100 4500])
    ylim([500 1000])
    zlim([-2275 -1750])
    xlabel('X (m)','Fontname','Arial','FontSize',14)
    ylabel('Y (m)','Fontname','Arial','FontSize',14)
    zlabel('Z (m)','Fontname','Arial','FontSize',14)
    set(gca,'Fontname','Arial','FontSize',14,'XTick',[],'YTick',[],'ZTick',[],...
        'LineWidth',4)
    view([-2 2])
    axis off
end
%%
C(1:size(y,1),1:3) = repmat([0.8 0.8 0.8],size(y,1),1);
C(size(y,1)-num_init:size(y,1)-1,:) = repmat([0 0 1],num_init,1);

C(size(y,1),:) = [1 0 0] ;

figure,
h1 = plot(y(1,1), y(1,2), 'o', 'Color',C(1,:), ...
        'MarkerSize', 12,'LineWidth',1,'MarkerFaceColor',C(1,:),...
        'MarkerEdgeColor','k');
        hold on
h2 = plot(y(end-1,1), y(end-1,2), 'o', 'Color',C(end-1,:), ...
        'MarkerSize', 12,'LineWidth',1,'MarkerFaceColor',C(end-1,:),...
        'MarkerEdgeColor','k');
        hold on

for i = 2: size(y,1)-1
    plot(y(i,1), y(i,2), 'o', 'Color',C(i,:), ...
    'MarkerSize', 12,'LineWidth',1,'MarkerFaceColor',C(i,:),...
    'MarkerEdgeColor','k');
    hold on
end

hf= plot(y(end,1), y(end,2),'x', 'Color',C(end,:), ...
    'MarkerSize', 20,'LineWidth',4, 'MarkerEdgeColor','r');
hold off
        
ax = legend([hf, h2, h1],{'Data', 'Data Initialization', 'Prior Realization', 'Initialization'},'Location','NorthWest');

set(gca,'fontsize',16,'fontweight','b');
set(gca,'YTickLabel',{''},'XTickLabel',{''},'ZTickLabel',{''});

set(ax,'FontSize',16)

xlabel([num2str((e(1) - min(e(e<0)))/sum(abs(e))*100,'%.2f'),'%'])
ylabel([num2str((e(2) - min(e(e<0)))/sum(abs(e))*100,'%.2f'),'%'])
% saveas(gcf, 'Figures/OriginalDataConsistencyMDS_2D.jpg')
