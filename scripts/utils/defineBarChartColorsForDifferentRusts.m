function [colorsBarChart,Colours]=defineBarChartColorsForDifferentRusts(iRustStr)

    % function to define the colour of bar charts for different rusts

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

    Colours(1,:)=[0.9290, 0.6940, 0.1250]; % 2010; some kind of yellow
    Colours(2,:)=[0.8500, 0.3250, 0.0980]; % 2011;  orange
    Colours(3,:)=[0.6350, 0.0780, 0.1840]; % 2012; dark pink
    Colours(4,:)=[0.75, 0, 0.75]; % 2013; pink
    Colours(5,:)=[0, 0.75, 0.75]; % 2014; tuerkis
    Colours(6,:)=[0, 0.4470, 0.7410]; % 2015; light blue
    Colours(7,:)=[0, 0, 1]; % 2016; blue
    Colours(8,:)=[0, 0.5, 0]; % 2017; green
    Colours(9,:)=[0.8, 0.8, 0.8]; % 2018; dark gray
    Colours(10,:)=[0.3, 0.3, 0.3]; % 2019; light gray

end

