function analogue_CMIP5_sep2019(reg, extent, years_now, years_fut, outfile, rcp, mod_select)


vari = struct(  'pr', '/climateData/Precipitation', ...
                'tasmin', '/climateData/TemperatureMin', ...
                'tasmax', '/climateData/TemperatureMax');
vari.names = fieldnames(vari);
inrep = ['D:\MB\h5\' rcp];
files = dir(inrep); files=files(~[files.isdir]);
[R.ndx, R.geo]=geotiffread('S:\MATLAB\ref4326.tif');

for f=1:length(files)
    clear h5 analogue climNow climFut reg_all
    if any(arrayfun(@(x) ~isempty(strfind(files(f).name,x)),mod_select))
        inFullfilename = fullfile(inrep,files(f).name);
        h5.y = h5read(inFullfilename,'/dateData/year');
        h5.m = h5read(inFullfilename,'/dateData/month');
        %Find index all polygon in reg and extent
        h5.lon = h5read(inFullfilename,'/spatialInfo/lon');
        h5.lat = h5read(inFullfilename,'/spatialInfo/lat');
        ndxMAP = find(inpolygon(h5.lon,h5.lat,extent.lon,extent.lat))';


        %Clim Now (map)
        h5.ndxNow = find(ismember(h5.y,years_now));
        h5.start = [h5.ndxNow(1),1 1];
        h5.count = [length(h5.ndxNow),1392 720]; % lire les données en contigües sinon on utilise h5r low level pour des accès aléatoires
        for v=1:length(vari.names)
            climNow.(vari.names{v})=h5read(inFullfilename,vari.(vari.names{v}),h5.start,h5.count);
        end
        climNow.tas=0.5*(climNow.tasmin+climNow.tasmax);
        %Analogue Now (test & map)
        h5.ndx_ANNpr=find(ismember(h5.m(h5.ndxNow),1:12));       
        h5.y_gr=h5.y(h5.ndxNow);
        analogue.test.pr=splitapply(@sum,climNow.pr(h5.ndx_ANNpr,ndxMAP),findgroups(h5.y_gr(h5.ndx_ANNpr)));   
        analogue.test.tas=splitapply(@mean,climNow.tas(:,ndxMAP),findgroups(h5.y_gr)); 
        
        %Clim Fut (reg)
        h5.ndxFut = find(ismember(h5.y,years_fut));
        h5.start = [h5.ndxFut(1),1 1];
        h5.count = [length(h5.ndxFut),1392 720]; % lire les données en contigües sinon on utilise h5r low level pour des accès aléatoires
        for v=1:length(vari.names)
            climFut.(vari.names{v})=h5read(inFullfilename,vari.(vari.names{v}),h5.start,h5.count);
        end
        climFut.tas=0.5*(climFut.tasmin+climFut.tasmax);
        %Analogue Futur (ref & reg)
        h5.ndx_ANNpr=find(ismember(h5.m(h5.ndxFut),1:12));
        h5.y_gr=h5.y(h5.ndxFut);
        dist = zeros(h5.count(2:3))+nan;
        iFinite = find(isfinite(analogue.test.pr(1,:,:)));
        analogue.test=structfun(@(x) (x(:,iFinite)),analogue.test,'UniformOutput', false);

        for r=1:length(reg)
            display(reg(r).Region);
            ndxREG = cell2mat(arrayfun(@(x) (find((inpolygon(h5.lon, h5.lat, x.Lon(1:end-1),x.Lat(1:end-1))))'), reg(r),'UniformOutput', false));
            analogue.ref.pr=mean(splitapply(@sum,climFut.pr(h5.ndx_ANNpr,ndxREG),findgroups(h5.y_gr(h5.ndx_ANNpr))),2)';  
            analogue.ref.tas=mean(splitapply(@mean,climFut.tas(:,ndxREG),findgroups(h5.y_gr)),2)';    
            
            %Computing metric
            d2v = struct('ZAEpwrl', dist, 'ZAElog', dist, 'SED', dist);
            fVar2 = {'pr'; 'tas'}; 
            d2v.SED(iFinite) = A01_SED(analogue.ref,analogue.test, fVar2);
            fGTIFF=[outfile '_' num2str(f) '_' reg(r).Region(end-1:end) '_SED' '.tif'];            
            geotiffwrite(fGTIFF,d2v.SED',R.geo);  
            d2v.ZAEpwrl(iFinite) = A01_method_ZAE_multipoint(analogue.ref,analogue.test,fVar2,1);
            fGTIFF=[outfile '_' num2str(f) '_' reg(r).Region(end-1:end) '_ZAEpwrl' '.tif'];            
            geotiffwrite(fGTIFF,d2v.ZAEpwrl',R.geo);  
            d2v.ZAElog(iFinite) = A01_method_ZAE_multipointPG(analogue.ref,analogue.test,fVar2,1);
            fGTIFF=[outfile '_' num2str(f) '_' reg(r).Region(end-1:end) '_ZAElog' '.tif'];            
            geotiffwrite(fGTIFF,d2v.ZAElog',R.geo);  
%             d2v.names=fieldnames(d2v);
%             d2v.rcp=rcp;
%             d2v.HFutur=years_fut(1);
%             reg_all(r).d2v_all(f) = d2v; 
%             reg_all(r).name = reg(r).Region;
        end
    end  
end

% %Sauvegarde des données par rcp/horizon en formt .mat
% save([outfile '.mat'],'reg_all');


end