% calcul des cartes ISAS en salinité sur la grille EASE
% isas15 entre 2010 et 2015 et les produits NRT entre 2016 et 2019
% profondeur : 5 m
% creation d'un fichier .mat SSSisas_CATDS.mat contenant les cartes ISAS 5m
% interpolées sur la grille EASE POLAIRE south ou north
%

clear
set(groot,'DefaultFigureColormap',jet)

load('I:\dataSMOS\ISAS15\all_insitu\ISAS15_all\ISAS15_All_insitu_SSS_SST_5m_2010_2015.mat')
yearisas=year;
monthisas=month;
latisas=latmapISAS;
lonisas=lonmapISAS;

lonisas(end+1)=180;

% grille ease
polar='south';
namegrid='F:\vergely\SMOS\CCI\grilles\EASE2_N25km.geolocation_reduced.nc';
if strcmp(polar,'north')
    lat0=ncread(namegrid,'latitude');
    lon0=ncread(namegrid,'longitude');
else
    lat0=-ncread(namegrid,'latitude');
    lon0=-ncread(namegrid,'longitude');
end

nlon=size(lon0,1);
nlat=size(lon0,2);


year=['10'; '11'; '12'; '13'; '14'; '15'; '16'; '17'; '18'; '19']   % annees
nyear=10;

isasSSS=zeros(nyear*12,nlon,nlat);
isasTEMP=zeros(nyear*12,nlon,nlat);
isasPCTVAR=zeros(nyear*12,nlon,nlat);
datemois_isas=zeros(nyear*12,2);

k=0;
for ia=1:6  % boucle sur les annees : 6 premières années pour ISAS15
    ia
    for imonth=1:12;
        
        
        
        k=k+1;
        
        datemois_isas(k,1)=imonth;
        datemois_isas(k,2)=yearisas(k)-2000;
        
        SSSisas=squeeze(SSS_ISAS_5m(:,:,k));
        SSSisas(721,:)=SSSisas(1,:);
        
        SSS0=interp2(lonisas,latisas,SSSisas',lon0,lat0);
        
        isasSSS(k,:,:)=SSS0;
        
        
        TEMPisas=squeeze(SST_ISAS_5m(:,:,k));
        TEMPisas(721,:)=TEMPisas(1,:);
        
        TEMP0=interp2(lonisas,latisas,TEMPisas',lon0,lat0);
        
        isasTEMP(k,:,:)=TEMP0;
        
        
        PCTVARisas=squeeze(SSS_PCTVAR_5m(:,:,k));
        PCTVARisas(721,:)=PCTVARisas(1,:);
        
        PCTVAR0=interp2(lonisas,latisas,PCTVARisas',lon0,lat0);
        
        isasPCTVAR(k,:,:)=PCTVAR0;
        
        
       %  keyboard
    end
end

% on complête avec ISAS NRT sur les annees 2016-2019

repISAS='I:\dataSMOS\ISASv6.2'
name_isas='OA_NRTOAGL01_20120115_fld_PSAL.nc';
name_isas_temp='OA_NRTOAGL01_20120115_fld_TEMP.nc';
file_exemple='I:\dataSMOS\ISASv6.2\2012\OA_NRTOAGL01_20120115_fld_PSAL.nc'
depth=ncread(file_exemple,'depth');

idepth=3;   % =3 pour 5m

for ia=7:nyear  % boucle sur les annees
    ia
    diryear=['20' year(ia,:)];
    for imonth=1:12;
        k=k+1;
        if imonth < 10; imonc=['0' num2str(imonth)]; else imonc=num2str(imonth); end;
        
        name_isas(14:17)=diryear;
        name_isas(18:19)=imonc;
        reptot=[repISAS '\' diryear '\' name_isas]
        
        %infout=ncinfo(reptot);
        psal=ncread(reptot,'PSAL');
        dateisas(k,:)=[diryear imonc];
        datemois_isas(k,1)=imonth;
        datemois_isas(k,2)=str2num(year(ia,:));
        
        SSSisas=squeeze(psal(:,:,idepth));
        SSSisas(721,:)=SSSisas(1,:);
        
        SSS0=interp2(lonisas,latisas,SSSisas',lon0,lat0);
        
        isasSSS(k,:,:)=SSS0;
        
        ptctvar=ncread(reptot,'PCTVAR');
        
        PCTvarisas=squeeze(ptctvar(:,:,idepth));
        PCTvarisas(721,:)=PCTvarisas(1,:);
        
        PCTVAR0=interp2(lonisas,latisas,PCTvarisas',lon0,lat0);
        
        isasPCTVAR(k,:,:)=PCTVAR0;

        
        name_isas_temp(14:17)=diryear;
        name_isas_temp(18:19)=imonc;
        reptot=[repISAS '\' diryear '\' name_isas_temp];
        
        %infout=ncinfo(reptot);
        ptemp=ncread(reptot,'TEMP');
        
        TEMPisas=squeeze(ptemp(:,:,idepth));
        TEMPisas(721,:)=TEMPisas(1,:);
        
        TEMP0=interp2(lonisas,latisas,TEMPisas',lon0,lat0);
        
        isasTEMP(k,:,:)=TEMP0;
        
        
        %  keyboard
    end
end

save(['isas_CATDS_' polar '.mat'],'isasPCTVAR', 'isasSSS', 'isasTEMP', 'lat0' ,'lon0', 'dateisas', 'datemois_isas');


