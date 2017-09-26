%ConvergenceDisplay demo shows diagnostic metrics for Markov Chain
%convergence used for conditional fault network simulation First part
%demonstrates a case with sparse data (4 fault observations) and the second
%part shows the dense data case (10 fault observations)
clear all
close all
clc
addpath(fileparts(pwd))
%%
%Define Simulation Extent
sim_ext = [500,  500, -2500;...
           3500, 1000, -1600] ;
%Define Level-Set Resolution
res = [10,10,40];
%% Create Hard-Data
%Hard-Data: Fault Locations
data.point = [ 2500, 750, -2000;...
               2450, 750, -1900;...
               1100, 750, -1900; ...
               1350, 750, -2000] ;
%Hard-Data: Fault Hiearchies
data.mark = [1; 2; 1; 2];
%Hard-Data: Fault Azimuths
az_data = [5, 5, 5, 5] ;
%Hard-Data: Fault Dips
dip_data =  [70,-80, 70, -80] ;
%Hard-Data: Fault Sizes
data_size = [1000,1000,400;...
            1000,1000,300;...
            1000,300,300;...
            1000,400,500] ;
%Create Surface Representation of the Fault Data
data_network = createDataMarkedCase(data, az_data, dip_data, data_size, res) ;
%Set Initilization to be Hard-Data
init = data;
%% Define Markes Strauss Point Process (MSPP) Parameters
gamma=[2,-2];
%Check if beta and d is consistent with mark size if not return error
beta = [100,-50;...
        0,100] ;
d = [400,100;...
     100,300] ;
%Number of Marks to Simulate
max_mark = 2;
% Simulation Inputs
num_iter = 1000 ;
%Define Move Perturbation Bounds in 3-D
move_bounds = [ 1,50;...
                0,0;...
                 0,0] ;
%Create Simulations Constrained to Fault Data
for rel_ind = 1 : num_rel
[state{rel_ind},action{rel_ind}, ~, acc{rel_ind},dd{rel_ind}] = StraussMarked(gamma, beta, d, max_mark, num_iter, sim_ext, init, move_bounds );
end
%% Plot McMC Convergence
for k =1 : size(acc,2)
    for i = 1 : length(acc{k})
        acc_ratio(i,k) = sum(acc{k}(1:i))/i; 
    end
    plot(1:length(acc{k}),acc_ratio(:,k),'b','LineWidth',2)
    hold on
end
plot(1:length(acc{k}),mean(acc_ratio,2),'r','LineWidth',3)
hold off
xlabel('Iterations','Fontname','Arial','FontSize',14)
ylabel('Acceptance Rate','Fontname','Arial','FontSize',14)
set(gca,'Fontname','Arial','FontSize',14)
%% Plot Perturbation History for 2 Realizations
k = 1 ;
x = 1:num_iter;
action_count = zeros(1,4);
count = 0 ;
for k = [1,4]
for i=2:200%num_iter-1
    switch action{k}(i)
        case 1 
            C='b';
            action_count(1) = action_count(1) + 1 ;
            if action_count(1) == 1
                count = count + 1 ;
                h(count)=line(x(1,[i-1 i]), acc_ratio([i-1 i],k), 'Color', C,'LineWidth',5);
            else
                line(x(1,[i-1 i]), acc_ratio([i-1 i],k), 'Color', C,'LineWidth',5);
            end
        case -1
            C='r';
            action_count(2) = action_count(2) + 1 ;
            if action_count(2) == 1
                count = count + 1 ;
                h(count)=line(x(1,[i-1 i]), acc_ratio([i-1 i],k), 'Color', C,'LineWidth',5);
            else
                line(x(1,[i-1 i]), acc_ratio([i-1 i],k), 'Color', C,'LineWidth',5);
            end
        case 0
            C='k';
            action_count(3) = action_count(3) + 1 ;
            if action_count(3) == 1
                count = count + 1 ;
                h(count)=line(x(1,[i-1 i]), acc_ratio([i-1 i],k), 'Color', C,'LineWidth',5);
            else
                line(x(1,[i-1 i]), acc_ratio([i-1 i],k), 'Color', C,'LineWidth',5);
            end
        case 0.5
            C='g';
            action_count(4) = action_count(4) + 1 ;
            if action_count(4) == 1
                count = count + 1 ;
                h(count)=line(x(1,[i-1 i]), acc_ratio([i-1 i],k), 'Color', C,'LineWidth',5);
                else
                line(x(1,[i-1 i]), acc_ratio([i-1 i],k), 'Color', C,'LineWidth',5);
            end
    end   
%     line(x(1,[i-1 i]), log(dd{1}.point([i-1 i])), 'Color', C,'LineWidth',5);
hold on
end
end
xlabel('Iterations','Fontname','Arial','FontSize',14)
ylabel('Acceptance Rate','Fontname','Arial','FontSize',14)
set(gca,'Fontname','Arial','FontSize',14)
legend(h,'Death','Modify','Birth')
%% Repeat Convergence Inspection for Densely Fault Dataset
%Hard-Data:Fault locations
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
%Hard-Data:Fault Hierarchies
data.mark = [1; 2; 1; 2; 1; 2; 1; 1; 2; 1];
%Hard-Data:Fault Azimuth and Dip           
az_data = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5] ;
dip_data =  [70,-80, 70, -80, 70, -80, 70, 70, -80, 70] ;
%Hard-Data:Fault Sizes
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
%Initial fault network (observed faults only)
data_network = createDataMarkedCase(data, az_data, dip_data, data_size, res) ;
%% Create Hard-Data
init = data ;
%Number of Marks to Simulate
max_mark = 2;
%Update Move Bounds
move_bounds = [ 1,50;...
                0,0;...
                 0,0] ;
num_iter = 5000;
%Perform Conditional Simualations for Dense Data Case
for rel_dense = 1 : num_rel
[state_dense{rel_dense},action_dense{rel_dense}, ~, acc_dense{rel_dense},dd_dense{rel_dense}] = StraussMarked(gamma, beta, d, max_mark, num_iter, sim_ext, init, move_bounds );
end
%% Show Multi-Plateu Convergence for the Dense Data-case (bottom line more 
%iterations are needed)
num_iter = 1000;
x = 1:num_iter;
for k =1 : size(acc_dense,2)
    for i = 1 : length(acc_dense{k})
        acc_ratio_dense(i,k) = sum(acc_dense{k}(1:i))/i; 
    end
    plot(x,acc_ratio_dense(1:num_iter,k),'b','LineWidth',2)
    hold on
end
hold off

xlabel('Iterations','Fontname','Arial','FontSize',14)
ylabel('Acceptance Rate','Fontname','Arial','FontSize',14)
set(gca,'Fontname','Arial','FontSize',14)