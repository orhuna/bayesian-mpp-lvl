function [az,dip] = sampleAz_Dip(az_init, dip_init, fault_num)
%This function samples azimuth and dip values for a y_faulted system from a
%Normal Distribution

%Prior: Azimuth for a Y-Faulted System Should be Similar btw Components
az = repmat(min(az_init) + rand() * diff(az_init),1,fault_num);
%Prior: To form a Y One Needs Opposing Dip Directions
dip(1,1) = [min(dip_init) + rand() * diff(dip_init)];
if fault_num > 1
    for n = 2:fault_num
        ang =  [min(dip_init) + rand() * diff(dip_init)];
        dip(1,n) = (dip(1,n-1)<=0)*ang - (dip(1,n-1)>=0) * ang  ;
    end
end
