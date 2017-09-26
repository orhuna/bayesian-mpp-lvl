function fault_pnt = Y2Point(fault_network)
% fault_network = current_state ;
%This function Calculates a 3D Point from a Fault Object
fault_pnt = zeros(length(fault_network),3) ;

for i = 1 : length(fault_network)
    fault_vertices = [];
    for k = 1 : length(fault_network{i})
        fault_vertices = [fault_vertices;vertcat(fault_network{i}{k}.vertices)] ;
    end
    fault_pnt(i,:) = median(fault_vertices) ;
end

