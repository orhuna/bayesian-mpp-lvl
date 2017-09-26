%LevelSetDemo2 depicts level-sets associated with planar and noisy-planar
%surfaces
clear all
close all
clc
%Add src to directory
addpath(fileparts(pwd))
%% Define simulation area geometry
%Locus for proposed fault
proposal = [4.92*10^5, 1.1955*10^5 , -5000];
%Resolution in x, y and z
res = [10,10,10];
%Extent in x, y and z for the proposed fault
sim_size = [400,400,500] ;
%Azimuth angle (degrees) for proposed fault
az = [-50];
%Dip angle (degrees) for proposed fault
dip = [5];
%Define simulation extent from locus and extent
sim_ext = repmat(proposal,2,1) + [-0.5 * sim_size; 0.5 * sim_size];
%%  Plot Level-Set for Given Fault Surface Parameters and Fault Surface 
%   Realizations
%Create the level-set for fault surface parameters
[x_sim,y_sim,z_sim,L_sim] = createNumericFaultProposal(az,dip,repmat(sim_size,2,1),res,sim_ext);
%Plot level-set
visualizeLevelSet(x_sim{1},y_sim{1},z_sim{1},L_sim{1},0.2)
hold on
%Plot the simulation geometry
drawBox(sim_ext)
%Plot fault surfaces corresponding to different iso-contours
for i = -0.2:0.1:0.2
    %Plot fault surface corresponding to a iso-contour
    patch(isosurface(x_sim{1},y_sim{1},z_sim{1},L_sim{1},i),'FaceColor','k')
    %Set plot annotation
    xlabel('X (m)','Fontname','Arial','FontSize',14)
    ylabel('Y (m)','Fontname','Arial','FontSize',14)
    zlabel('Z (m)','Fontname','Arial','FontSize',14)
    set(gca,'Fontname','Arial','FontSize',14,'XTick',[])
    view([-67 18])
    axis off
end
%Attach colorbar
colorbar
%% 
az = [1];
dip = [5];
sim_ext = repmat(proposal,2,1) + [-0.5 * sim_size; 0.5 * sim_size];

[x_sim,y_sim,z_sim,L_sim] = createNumericFaultProposal(az,dip,repmat(sim_size,2,1),res,sim_ext);


range.min=10; range.med=10; range.max=10;
angle.x=0; angle.y=0; angle.z=0;

perturb_cube = runSGSIM(res,randi([10^5 10^6]),0.05,range,angle) ;
perturb_cube = 0.25 * perturb_cube ;

count = 0 ;

hold on
for lvl = -0.2 : 0.2 : 0.2
    count = count + 1;
    L_new = L_sim{1} + perturb_cube ;
    figure,
    visualizeLevelSet(x_sim{1},y_sim{1},z_sim{1},L_new,0.4)
    patch(isosurface(x_sim{1},y_sim{1},z_sim{1},L_new+lvl, 0),'FaceColor','k')
    drawBox(sim_ext)
    colorbar

    xlabel('X (m)','Fontname','Arial','FontSize',14)
    ylabel('Y (m)','Fontname','Arial','FontSize',14)
    zlabel('Z (m)','Fontname','Arial','FontSize',14)
    set(gca,'Fontname','Arial','FontSize',14,'XTick',[])
    view([-45 8])
%     saveas(gcf, ['C:\Users\orhuna\OneDrive\Stanford\PhD Research\Thesis\Figures\LVL_Demo',num2str(count),'.emf'])
%     close all
end