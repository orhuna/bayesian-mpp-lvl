function [hard_data,match_ind] = createData(input)
%createData utility function to assess the 
% clc,close all
% input = fault_network{i};

center = [1500,2000;2500,3500;4000,1500];
radii = [500,250;500,1000;500,500] ;

hard_data = {};
count = 0;
for data_area_ind = 1 : 3
    
    [x_el{data_area_ind},y_el{data_area_ind}] = calculateEllipse(center(data_area_ind,1),center(data_area_ind,2),...
                               radii(data_area_ind,1), radii(data_area_ind,2), 0, 100);

    for fault_ind = 1 : length(input)
        % Find Indeces of Fault Coordinates Within Data
        ind_erase = ~inpolygon(input{fault_ind}.vertices(:,1),...
                       input{fault_ind}.vertices(:,2),x_el{data_area_ind},y_el{data_area_ind}) ;


        if prod(ind_erase) == 0
            count = count + 1 ;
            hard_data{count} = RemainingPatchFace(input{fault_ind},find(ind_erase==1)) ;
            match_ind(count) =fault_ind ;
        end            

    end
end

if isempty(hard_data)
    match_ind = [];
end