% 2-D Marked Strauss Point Process (MSPP) Example for Visualizing the 
%effect of MSPP input parameter
clear all
close all
clc
%Add src to directory
addpath(fileparts(pwd))
%% Example of a Poisson Process depicted for different lambda values
% Lambda values for simulations
la=[0.2; 0.6];  

for i = 1 : length(la)
    lala=la(i)*100;
    npoints = poissrnd(lala);

    pproc = rand(npoints, 2);
    figure, plot(pproc(:, 1),pproc(:, 2),'o','LineWidth',2,'MarkerSize',8,'COlor','k');
    xlabel('X (m)','Fontname','Arial','FontSize',14)
    ylabel('Y (m)','Fontname','Arial','FontSize',14)
    set(gca,'Fontname','Arial','FontSize',14)
    title(['\lambda  = ',num2str(la(i))], 'FontName', 'Calibri','FontSize', 16)
end
%% Example of a 2-D Strauss Point Process with 1 mark type (same as Strauss 
%point process)
%Global mark intensity
gamma = -2.5;
%Attraction (+) and repulsion (-) parameter
beta = 0;
%Interaction distance
d = 0.05;
%Number of distinct marks
max_mark = 1;
%Extents of the simulation box
sim_ext = [0, 0; 1, 1];
%Number of iterations to perform to create final point set
num_iter = 5000;
%Constraining data-points (empty if no conditioning data exist)
initialization.point = [];
%Marks for conditioning data
initialization.mark = [];
%Maximum for move perturbation in x and y directions, respectively
move_bounds = [0,0.05];
%Perform MSPP
state = StraussMarked2D(gamma, beta, d, max_mark, num_iter, sim_ext, initialization, move_bounds ) ;
%Plot the marked-point scatter
plot(state.point(:,1),state.point(:,2),'o','LineWidth',2,'MarkerSize',8,'COlor','k');
xlabel('X (m)','Fontname','Arial','FontSize',14)
ylabel('Y (m)','Fontname','Arial','FontSize',14)
set(gca,'Fontname','Arial','FontSize',14,'XLim',[0 1], 'YLim', [0 1])
title(['\gamma  = ',num2str(gamma),', \beta = ',num2str(beta),', \tau = ',num2str(d)], 'FontName', 'Calibri','FontSize', 16)

%% Marked Strauss Point Process
close all
clear all
for k = 1
figure,
clear all
gamma = [-4; -4] ;
beta = [10000, 0; 0 , 0];
d = [0.1,0.1; 0.1, 0.1];
max_mark = 2;
sim_ext = [0, 0; 1, 1];
num_iter = 10000;
initialization.point = [];
initialization.mark = [];
move_bounds = [0,0.1; 0,0.1];

state = StraussMarked2D(gamma, beta, d, max_mark, num_iter, sim_ext, initialization, move_bounds ) ;

plot(state.point(state.mark==1,1),state.point(state.mark==1,2),'o','LineWidth',2,'MarkerSize',16,'Color','k');
hold on
plot(state.point(state.mark==2,1),state.point(state.mark==2,2),'o','LineWidth',2,'MarkerSize',8,'Color','k');
hold off
xlabel('X (m)','Fontname','Arial','FontSize',14)
ylabel('Y (m)','Fontname','Arial','FontSize',14)
set(gca,'Fontname','Arial','FontSize',14,'XLim',[0 1], 'YLim', [0 1])
end
% title(['\gamma  = ',num2str(gamma),', \beta = ',num2str(beta),', \tau = ',num2str(d)], 'FontName', 'Calibri','FontSize', 16)