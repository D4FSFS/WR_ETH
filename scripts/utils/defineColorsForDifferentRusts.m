function colorsBarChart = defineColorsForDifferentRusts(iRustStr)

    % function to set the colors used for plotting results of different types
    % of wheat rusts

    colorsBarChart=[];
    if strcmp(iRustStr,'Sr')
        colorsBarChart(1,:)=[200/255,200/255,200/255];
        colorsBarChart(2,:)=[150/255,150/255,150/255];
        colorsBarChart(3,:)=[30/255,30/255,30/255];
    elseif strcmp(iRustStr,'Yr')
        colorsBarChart(1,:)=[255/255,255/255,51/255];
        colorsBarChart(2,:)=[255/255,204/255,0];
        colorsBarChart(3,:)=[204/255,153/255,0/255];
    elseif strcmp(iRustStr,'Lr')
        colorsBarChart(1,:)=[255/255,153/255,102/255];
        colorsBarChart(2,:)=[204/255,51/255,0];
        colorsBarChart(3,:)=[102/255,0,0];
    end    

end

