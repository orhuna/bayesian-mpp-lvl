function L_dm = ComputeLikelihood(state, data_network)
 
% data_network = data_init ;
% state = state_proposed ; 
% clearvars sigma mismatch data_area state_fixed
% state = initialization  ;

if isempty(data_network)
L_dm = 1 ;
else
    for data_ind = 1 : length(data_network)
        count = 0 ;
        clearvars d sig
        for net_ind = 1 : length(state)

            for fault_ind = 1 : length(state{net_ind})

                count = count + 1 ;
                [d(count),sig(count)] = distDatatoSurface(data_network{data_ind}.vertices, state{net_ind}{fault_ind}.vertices);
            end
        end
        [mismatch(data_ind), min_ind] = min(d);
        sigma(data_ind) = sig(min_ind) ;
        data_area(data_ind) = SurfaceArea(data_network{data_ind}) ;
    end

    %Define a Sigma That is Larger for Smaller Surface Area
    % sigma = 1 ;

    L_dm =  exp(-sum(mismatch.^2 ./data_area) ) ;
    
end
