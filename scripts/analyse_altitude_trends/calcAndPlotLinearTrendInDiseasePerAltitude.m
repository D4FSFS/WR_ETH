function calcAndPlotLinearTrendInDiseaseAltitude(XValues,AllProps,NumberSurveysPerAltitudeInterval,AltitudeBinArray,colorsBarChart,iRustStr,iDisStrLeg,figName,fileName)

    % function for calculating a linear fit to the mean prevalence values per altitude bin and for plotting the fitted lines on top of a stacked bar-graph    

    % get all non-zero disease scores in a separate array
    LowDiseaseProps=AllProps(:,3)+AllProps(:,2)+AllProps(:,1);
    ModDiseaseProps=AllProps(:,2)+AllProps(:,1);
    HighDiseaseProps=AllProps(:,1);

    % calc. linear fit
    
    % low disease levels
    LinearTrendLowPrevalence=fitlm(XValues,LowDiseaseProps);
    Rsquared(1)=LinearTrendLowPrevalence.Rsquared.Ordinary;
    [p(1),F(1)] = coefTest(LinearTrendLowPrevalence);
    
    % moderate disease levels
    LinearTrendModPrevalence=fitlm(XValues,ModDiseaseProps);
    Rsquared(2)=LinearTrendModPrevalence.Rsquared.Ordinary;
    [p(2),F(2)] = coefTest(LinearTrendModPrevalence);
    
    % high disease levels
    LinearTrendHighPrevalence=fitlm(XValues,HighDiseaseProps);
    Rsquared(3)=LinearTrendHighPrevalence.Rsquared.Ordinary;
    [p(3),F(3)] = coefTest(LinearTrendHighPrevalence);

    % write fitting diagnostics to file
    fid=fopen(fileName,'w');
    fprintf(fid,'low: rsquared %s \n',num2str(Rsquared(1)));
    fprintf(fid,'low: Fstat %s \n',num2str(F(1)));
    fprintf(fid,'low: p-value %s \n',num2str(p(1)));
    fprintf(fid,'mod: rsquared %s \n',num2str(Rsquared(2)));
    fprintf(fid,'mod: Fstat %s \n',num2str(F(2)));
    fprintf(fid,'mod: p-value %s \n',num2str(p(2)));
    fprintf(fid,'high: rsquared %s \n',num2str(Rsquared(3)));
    fprintf(fid,'high: Fstat %s \n',num2str(F(3)));
    fprintf(fid,'high: p-value %s \n',num2str(p(3)));
    fclose(fid);

    % define rust-specific color for figures
    colorsBarChartLine=[];
    if strcmp(iRustStr,'Sr')
        colorsBarChartLine(1,:)=[200/255,200/255,200/255];
        colorsBarChartLine(2,:)=[150/255,150/255,150/255];
        colorsBarChartLine(3,:)=[30/255,30/255,30/255];
    elseif strcmp(iRustStr,'Yr')
        colorsBarChartLine(1,:)=[0.9290, 0.6940, 0.1250];
        colorsBarChartLine(2,:)=[255/255,204/255,0];
        colorsBarChartLine(3,:)=[204/255,153/255,0/255];
    elseif strcmp(iRustStr,'Lr')
        colorsBarChartLine(1,:)=[255/255,153/255,102/255];
        colorsBarChartLine(2,:)=[204/255,51/255,0];
        colorsBarChartLine(3,:)=[102/255,0,0];
    end

    % plot stacked bar chart and fitted lines
    figure
    grid on

    % plot prop. positives in categories (low, mod., high)
    PropsPositives=AllProps(:,1:3);
    TotProp=PropsPositives(:,1)+PropsPositives(:,2)+PropsPositives(:,3);

    figure

    % plot bars
    b=bar(PropsPositives,'stacked','BarWidth',0.7);
    hold on
    
    % set grid lines
    grid on

    % set colors of bars
    b(1).FaceColor=colorsBarChart(3,:); % high in darker at bottom
    b(2).FaceColor=colorsBarChart(2,:);
    b(3).FaceColor=colorsBarChart(1,:); % low in lighter at top
    b(1).FaceAlpha=0.5;
    b(2).FaceAlpha=0.5;
    b(3).FaceAlpha=0.5;
    hold on

    % write number of surveys on top of axis
    XTickTopVec={};
    for i=1:length(AllProps)
        XTickTopVec{i}=['n=',num2str(NumberSurveysPerAltitudeInterval(i))];
    end
    xt = get(gca, 'XTick');
    y=ones(1,length(TotProp))+0.13;
    if strcmp(iDisStrLeg,'incidence')
        t=text(xt,y,XTickTopVec,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',12);
        set(t,'Rotation',45);
    end
    hold on

    % set figure labels
    XTickLabelVec={};
    for i=1:length(AltitudeBinArray)-1
        XTickLabelVec{i}=strcat('[',num2str(AltitudeBinArray(i)),'-',num2str(AltitudeBinArray(i+1)),'[');
    end
    
    % rotate x labels
    rotateXLabels(gca(),45);

    % set size / margin ratio
    pos = get(gca, 'Position');
    pos(4) = 0.7;
    set(gca, 'Position', pos)

    % low disease levels
    p1=plot(1:length(XValues),LowDiseaseProps,'o','MarkerSize',4,'LineWidth',1);
    p1.MarkerFaceColor=colorsBarChart(1,:);
    p1.MarkerEdgeColor=[0,0,0];
    hold on
    l1=plot(1:length(XValues),LinearTrendLowPrevalence.Fitted,'LineStyle','--','LineWidth',2.5,'color',colorsBarChartLine(1,:));
    hold on

    % moderate disease levels
    p2=plot(1:length(XValues),ModDiseaseProps,'square','MarkerSize',4,'LineWidth',1);
    p2.MarkerFaceColor=colorsBarChart(2,:);
    p2.MarkerEdgeColor=[0,0,0];
    hold on
    l2=plot(1:length(XValues),LinearTrendModPrevalence.Fitted,'LineStyle',':','LineWidth',2.5,'color',colorsBarChart(2,:));
    hold on

    % high disease levels
    p3=plot(1:length(XValues),HighDiseaseProps,'diamond','MarkerSize',4,'LineWidth',1);
    p3.MarkerFaceColor=colorsBarChart(3,:);
    p3.MarkerEdgeColor=[0,0,0];
    hold on
    l3=plot(1:length(XValues),LinearTrendHighPrevalence.Fitted,'LineStyle','-','LineWidth',2.5,'color',colorsBarChart(3,:)); 
    hold on

    % set labels
    if strcmp(iDisStrLeg,'severity')
        xlabel('altitude','FontSize',12);
        set(gca,'XTick',1:length(XValues),'XTickLabel',XValues,'XLim',[0,length(XValues)+1],'YLim',[0,1],'FontSize',12);
        rotateXLabels(gca(),45);
    elseif strcmp(iDisStrLeg,'incidence')
        set(gca,'XTick',1:length(XValues),'XTickLabel',[],'XLim',[0,length(XValues)+1],'YLim',[0,1],'FontSize',12);
    end
    ylabel('Prevalence','FontSize',12);

    % legend
    linelow=['linear fit to ',iRustStr,' ','[>= low]',' ',iDisStrLeg];
    linemod=['linear fit to ',iRustStr,' ','[>= mod]',' ',iDisStrLeg];
    linehigh=['linear fit to ',iRustStr,' ','high',' ',iDisStrLeg];
    if strcmp(iRustStr,'Yr')
        legend([b(3),l1,b(2),l2,b(1),l3],[iRustStr,' ','low',' ',iDisStrLeg],linelow,[iRustStr,' ','mod',' ',iDisStrLeg],linemod,[iRustStr,' ','high',' ',iDisStrLeg],linehigh,'FontSize',10,'Location','NorthWest')
    else 
        legend([b(3),l1,b(2),l2,b(1),l3],[iRustStr,' ','low',' ',iDisStrLeg],linelow,[iRustStr,' ','mod',' ',iDisStrLeg],linemod,[iRustStr,' ','high',' ',iDisStrLeg],linehigh,'FontSize',10,'Location','NorthEast')
    end
    
    % set size / margin ratio
    pos = get(gca, 'Position');
    pos(4) = 0.65;
    pos(2) = 0.2;
    set(gca, 'Position', pos)

    % write to file
    print(figName,'-dpng','-r300');
   
end
    



