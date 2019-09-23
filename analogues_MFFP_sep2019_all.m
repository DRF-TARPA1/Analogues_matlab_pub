%% Spatial analogue pilot projects 

clc;clear all;
cd C:\Users\PATAR\Documents\MATLAB
reg(1) = shaperead('S:\MATLAB\CHAAU2\Reg_Eco_detail\REG_ECO4a_4326.shp','Usegeocoords',true);% import polygon file with regions of interest
reg(2) = shaperead('S:\MATLAB\CHAAU2\Reg_Eco_detail\REG_ECO4b_4326.shp','Usegeocoords',true);% import polygon file with regions of interest
reg(3) = shaperead('S:\MATLAB\CHAAU2\Reg_Eco_detail\REG_ECO4c_4326.shp','Usegeocoords',true);% import polygon file with regions of interest
reg(4) = shaperead('S:\MATLAB\CHAAU2\Reg_Eco_detail\REG_ECO5a_4326.shp','Usegeocoords',true);% import polygon file with regions of interest
reg(5) = shaperead('S:\MATLAB\CHAAU2\Reg_Eco_detail\REG_ECO5b_4326.shp','Usegeocoords',true);% import polygon file with regions of interest
reg(6) = shaperead('S:\MATLAB\CHAAU2\Reg_Eco_detail\REG_ECO5c_4326.shp','Usegeocoords',true);% import polygon file with regions of interest

reg(1).Region = 'REG_ECO_4a';
reg(2).Region = 'REG_ECO_4b';
reg(3).Region = 'REG_ECO_4c';
reg(4).Region = 'REG_ECO_5a';
reg(5).Region = 'REG_ECO_5b';
reg(6).Region = 'REG_ECO_5c';

% Define map extent for 'southern' analogue (type1)
%extent.lon = [-110 -110 -50 -50 -110];
%extent.lat = [20 80 80 20 20];
extent.lon = [-168.0416  -51.2087];
extent.lat = [24.9584   85.7913];
% out folder location for 'Southern' analogues
outrep1 = 'S:\MATLAB\CHAAU2\analogue\';

% Define present and future years
years_now = 1981:2010;  % some models stop in november 1999 so can't go all the way to 2000
years_fut = {[2040:2069] [2070:2099]}; % same thing.. can't go all the way to 2100
rcp={'rcp45' 'rcp85'};
% years_fut = {[2070:2098]}; % same thing.. can't go all the way to 2100
% rcp={'rcp45'};

tic
for valHFut = years_fut
    for valRCP = rcp
    % Creating outfile names for region 'reg' in this example 
        outfile = strrep([outrep1 'metric_'  num2str(valHFut{1}(1)) '_' valRCP{1}],'é','e');
        %mod_select = {'BCC-BCC_CSM1_1','FIO-FIO_ESM','IPSL-IPSL_CM5A_LR','MIROC-MIROC5','MRI-MRI_CGCM3','NCC-NorESM1_M'};
        mod_select = {'rcp'};
        display(outfile);
        analogue_CMIP5_sep2019(reg,extent,years_now, valHFut{1}, outfile, valRCP{1}, mod_select);
    end    
end
toc