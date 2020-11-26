function [AreaWheatHarvested_ha,Yield_TonnesPerha,WheatProduction_Tonnes]=GetWheatProductionFromFAO(filename);

    % initialize array for storing yearly wheat prices
    AreaWheatHarvested_ha=[];
    
    % read file with yearly wheat prices
    fid = fopen(filename, 'r');

    % read line by line because of funny format
    DummyHeader=fgetl(fid);

    % loop through lines / years
    
    % area wheat harvested in first 9 entries
    for i=1:9
        tline=fgetl(fid);
        H1=strsplit(tline,',');
        H1=H1{12};
        H1=H1(3:9);
        AreaWheatHarvested_ha(i)=str2num(H1);
    end
    % no data for 2019, so assume average from all other years
    AreaWheatHarvested_ha(10)=mean(AreaWheatHarvested_ha(1:9));

    % average yield wheat in entries 10-18
    for i=1:9
        tline=fgetl(fid);
        H1=strsplit(tline,',');
        H1=H1{12};
        H1=H1(3:7);
        H1=str2num(H1);
        Yield_TonnesPerha(i)=H1/10000; % convert from hg to T
    end
    % no data for 2019, so assume average from all other years
    Yield_TonnesPerha(10)=mean(Yield_TonnesPerha(1:9));
    
    % average production of wheat in entries 19-27
    for i=1:9
        tline=fgetl(fid);
        H1=strsplit(tline,',');
        H1=H1{12};
        H1=H1(3:9);
        WheatProduction_Tonnes(i)=str2num(H1); 
    end
    % no data for 2019, so assume average from all other years
    WheatProduction_Tonnes(10)=mean(WheatProduction_Tonnes(1:9));
    

end

