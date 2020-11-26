function [WheatPrice_USDPerTonne] = GetWheatPriceFromFAO(filename)
    
    % initialize array for storing yearly wheat prices
    WheatPrice_USDPerTonne=[];
    
    % read file with yearly wheat prices
    fid = fopen(filename, 'r');

    % read line by line because of funny format
    DummyHeader=fgetl(fid);
    
    % loop through lines / years
    tline=fgetl(fid);
    iY=1;
    while ischar(tline)
        H1=strsplit(tline,',');
        H1=H1{12};
        H1=H1(3:7);
        WheatPrice_USDPerTonne(iY)=str2num(H1);
        tline=fgetl(fid);
        iY=iY+1;    
    end
    
    % no data for 2019, so assume average from all other years
    WheatPrice_USDPerTonne(iY)=mean(WheatPrice_USDPerTonne(:));

end

