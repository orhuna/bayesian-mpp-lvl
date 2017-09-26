function perturb_cube = runSGSIM(grid,seed,nugget,range,angle)
%runSGSIM simulates spatially-correlationed noise for small-scale 
%perturbation using sgsim 

% Note: this function requires setting environment parameter 
% AR2GEMS_PLUGINS_DIR to plugins directory of sgems

%   INPUTS:
%   grid: azimuth angle(in degrees)
%   seed: seed number for simulation
%   nugget: nugget value for variogram
%   range: range value for variogram, range object consists of min, med=10 
%   and max for minimum, mid and maximum range value
%   angle: angle value for variogram, angle object consists of x, y and z

%   OUTPUTS:
%   perturb_cube: 4-D gridded perturbation to level-set

%   Author: Orhun Aydin
%   email: orhuna@alumni.stanford.edu
%	May 2016; Last revision: 24-Sep-2017

%   References:
%   1-) Aydin, O., & Caers, J. K. (2017). Quantifying structural 
%   uncertainty on fault networks using a marked point process within a 
%   Bayesian framework. Tectonophysics, 712, 101-124.
%   
%   2-) Cherpeau, N., Caumon, G., & Lévy, B. (2010). Stochastic 
%   simulations of fault networks in 3D structural modeling. Comptes Rendus
%   Geoscience, 342(9), 687-694.
%% Prepare SGEMS Input File
% Define S-Gems location
sgems_dir = fullfile(fileparts(fileparts(pwd)), 'SGeMS-ar2tech-x64');
% Input File Directory
write_dir = fullfile(fileparts(fileparts(pwd)), 'perturb_cube.csv');
% Replace backslashes
write_dir = strrep(write_dir,'\','/') ;
sgems_dir = strrep(sgems_dir,'\','/') ;
% Write S-Gems Input File with user-defined input
s1 = ['NewCartesianGrid  grid::',num2str(grid(2)),'::',num2str(grid(1)),'::',num2str(grid(3)),...
 '::1.0::1.0::1.0::0::0::0::0.00'];
s2 = ['RunGeostatAlgorithm  sgsim::/GeostatParamUtils/XML::<parameters>  ',...
 '<algorithm name="sgsim" />     <Grid_Name value="grid" region=""  />',...
 '     <Property_Name  value="perturbation" />     <Nb_Realizations  value="1" />',...
 '     <Seed  value="',num2str(seed),'" />     <Kriging_Type  value="Simple Kriging (SK)"  />',...
 '     <Trend  value="0 0 0 0 0 0 0 0 0 " />    <Local_Mean_Property  value=""  />',...
 '     <Assign_Hard_Data  value="0"  />     <Hard_Data  grid=""   property=""   region=""  />',...
 '     <Max_Conditioning_Data  value="12" />     <Max_Conditioning_Simul_Data  value="12" />',...
 '     <Search_Ellipsoid  value="10 10 10  0 0 0" />    <AdvancedSearch  use_advanced_search="0"></AdvancedSearch>',...
 '    <Use_Target_Histogram  value="0"  />     <Variogram  nugget="',num2str(nugget),'" structures_count="1"  >',...
 '    <structure_1  contribution="1"  type="Spherical"   >',...
 '      <ranges max="',num2str(range.max),'"  medium="',num2str(range.med),'"  min="',num2str(range.min),'"   />',...
 '      <angles x="',num2str(angle.x),'"  y="',num2str(angle.y),'"  z="',num2str(angle.z),'"   />',...
 '    </structure_1>  </Variogram>  </parameters>  '];
s3 = strcat('SaveGeostatGrid  grid::', write_dir, '::csv::0::perturbation__real0');
%% Run SGEMS on Input File
fid = fopen(fullfile(fileparts(fileparts(pwd)),'SGSIM.txt'), 'w') ;
fprintf(fid,[s1,'\n']);
fprintf(fid,[s2,'\n']);
fprintf(fid,[s3,'\n']);
fclose(fid);
% rd = system('Z:/Stanford/Back-Up/SES-MJ90TW8/C_DRIVE/SGeMS-ar2tech-x64/ar2gems.exe Z:/Stanford/Back-Up/SES-MJ90TW8/Desktop/SGSIM.txt');
run_str = char(strcat(fullfile(sgems_dir, 'ar2gems.exe '), {' '}, fullfile(fileparts(fileparts(pwd)),'SGSIM.txt'))) ;
% Replace backslashes
run_str = strrep(run_str,'\','/') ;
rd = system(run_str) ;

perturb_cube  = reshape(csvread(write_dir,1),grid(2),grid(1),grid(3));
perturb_cube = perturb_cube / max(abs(perturb_cube(:)));
