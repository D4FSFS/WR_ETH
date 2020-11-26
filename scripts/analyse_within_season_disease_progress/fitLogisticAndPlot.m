function [mdlloglow,mdllogmod,mdlloghigh]=fitLogisticAndPlot(AllProps,iAllBiWeeks,NumberSurveysPerBiweek,SubPlotFolderPath,RustType,iDiseaseStr,iDisStrLeg,iRustStr,colorsBarChart,figName,fileName)

    % function to fit a 3-parameter logistic curve to the mean within-season rust
    % disease prevalence levels per bi-weekly time-interval.  

    % distinguish three types of binary disease prevalence measures
    LowDiseaseProps=AllProps(:,3)+AllProps(:,2)+AllProps(:,1);
    ModDiseaseProps=AllProps(:,2)+AllProps(:,1);
    HighDiseaseProps=AllProps(:,1);

    % define initial values for fitting procedure
    if strcmp(iRustStr,'Sr')
        FitInitialGuess=[0.5,0.2,0.1];
        FitInitialGuessb2=[6];
        FitInitialGuessb3=[1];
    elseif strcmp(iRustStr,'Yr')
        FitInitialGuess=[0.6,0.15,0.1];
        FitInitialGuessb2=[6];
        FitInitialGuessb3=[1];
    elseif strcmp(iRustStr,'Lr')
        FitInitialGuess=[0.2,0.1,0.05];
        FitInitialGuessb2=[2];
        FitInitialGuessb3=[0.1];
    end

    % define time and logistic curve
    Time=1:length(iAllBiWeeks(1,:));          % time is in units of 2-weeks
    modelfun=@(b,x)(b(1)./(1+exp(-b(2).*(x-b(3)))));
    
    % calc. logistic fit to low disease prevalence levels
    mdlloglow=fitnlm(Time',LowDiseaseProps',modelfun,[FitInitialGuess(1) FitInitialGuessb2(1) FitInitialGuessb3(1)]);
    LogisticFitApproxLow=predict(mdlloglow,Time');

    % calc. logistic fit to moderate disease prevalence levels
    mdllogmod=fitnlm(Time',ModDiseaseProps',modelfun,[FitInitialGuess(2) FitInitialGuessb2(1) FitInitialGuessb3(1)]);
    LogisticFitApproxMod=predict(mdllogmod,Time');

    % calc logistic fit to high disease prevalence levels
    mdlloghigh=fitnlm(Time',HighDiseaseProps',modelfun,[FitInitialGuess(3) FitInitialGuessb2(1) FitInitialGuessb3(1)]);
    LogisticFitApproxHigh=predict(mdlloghigh,Time');

    % write fitting diagnostics to file
    diary(fileName);
    disp('low\n')
    mdlloglow
    disp('\n\n mod\n')
    mdllogmod
    disp('\n\n mod\n')
    mdlloghigh
    diary off

    % get proportion of positives per disease categories (low, mod., high)
    PropsPositives=AllProps(:,1:3);
    TotProp=PropsPositives(:,1)+PropsPositives(:,2)+PropsPositives(:,3);

    % plot...
    figure

    % stacked bar-chart with mean disease levels per bi-weekly
    % time-interval
    b=bar(PropsPositives,'stacked','BarWidth',0.7);

    % set grid lines
    grid on

    % set colors of bars
    b(1).FaceColor=colorsBarChart(3,:); % high in darker at bottom
    b(2).FaceColor=colorsBarChart(2,:);
    b(3).FaceColor=colorsBarChart(1,:); % low in lighter at top
    b(1).FaceAlpha=0.5;
    b(2).FaceAlpha=0.5;
    b(3).FaceAlpha=0.5;

    % write number of surveys on top of axis
    XTickTopVec={};
    for i=1:length(iAllBiWeeks(1,:))
        XTickTopVec{i}=['n=',num2str(NumberSurveysPerBiweek(i))];
    end
    xt = get(gca, 'XTick');
    y=ones(1,length(TotProp))+0.13;
    if strcmp(iDiseaseStr,'Inc')
    t=text(xt,y,XTickTopVec,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',10);
    set(t,'Rotation',45);
    end

    % set axis ticks and labels
    XTickLabelVec=generateXTickLabels();
    if strcmp(iDiseaseStr,'Sev')
    set(gca,'YLim',[0,1],'XLim',[0.5,length(iAllBiWeeks(1,:))+0.5],'XTick',1:length(iAllBiWeeks(1,:)),'XTickLabel',XTickLabelVec,'TickLabelInterpreter', 'latex','FontSize',11);
    elseif strcmp(iDiseaseStr,'Inc')
    set(gca,'YLim',[0,1],'XLim',[0.5,length(iAllBiWeeks(1,:))+0.5],'XTick',1:length(iAllBiWeeks(1,:)),'XTickLabel',[]);
    end
    rotateXLabels(gca(),45);
    ylabel('Prevalence','FontSize',12);
   
    % set size / margin ratio
    pos = get(gca, 'Position');
    pos(4) = 0.6;
    set(gca, 'Position', pos)
    hold on

    grid on

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

    % plot curve fitted to low disease levels
    p1=plot(Time,LowDiseaseProps,'o','MarkerSize',4,'LineWidth',1);
    p1.MarkerFaceColor=colorsBarChart(1,:);
    p1.MarkerEdgeColor=[0,0,0];
    hold on
    l1=plot(Time,LogisticFitApproxLow,'LineStyle','--','LineWidth',2.5,'color',colorsBarChartLine(1,:));
    hold on
    %l1=plot(Time,LogisticFitApproxLow,'LineStyle','-','LineWidth',0.5,'color','black');

    % plot curve fitted to moderate disease levels
    p2=plot(Time,ModDiseaseProps,'square','MarkerSize',4,'LineWidth',1);
    p2.MarkerFaceColor=colorsBarChart(2,:);
    p2.MarkerEdgeColor=[0,0,0];
    hold on
    l2=plot(Time,LogisticFitApproxMod,'LineStyle',':','LineWidth',2.5,'color',colorsBarChart(2,:));
    hold on

    % plot curve fitted to high disease levels
    p3=plot(Time,HighDiseaseProps,'diamond','MarkerSize',4,'LineWidth',1);
    p3.MarkerFaceColor=colorsBarChart(3,:);
    p3.MarkerEdgeColor=[0,0,0];
    hold on
    l3=plot(Time,LogisticFitApproxHigh,'LineStyle','-','LineWidth',2.5,'color',colorsBarChart(3,:));
    hold on

    % legend
    ldatalow=[iRustStr,' ','low',' ',iDisStrLeg];
    linelow=['logistic curve fitted to ',ldatalow];
    ldatamod=[iRustStr,' ','mod',' ',iDisStrLeg];
    linemod=['logistic curve fitted to ',ldatamod];
    ldatahigh=[iRustStr,' ','high',' ',iDisStrLeg];
    linehigh=['logistic curve fitted to ',ldatahigh];
    %legend([p1,l1,p2,l2,p3,l3],ldatalow,linelow,ldatamod,linemod,ldatahigh,linehigh,'FontSize',10,'Location','NorthWest')
    legend([b(3),l1,b(2),l2,b(1),l3],[iRustStr,' ','low',' ',iDisStrLeg],linelow,[iRustStr,' ','moderate',' ',iDisStrLeg],linemod,[iRustStr,' ','high',' ',iDisStrLeg],linehigh,'FontSize',10,'Location','NorthWest')

    % set size / margin ratio
    %set(gcf, 'Units', 'centimeters', 'Position', [3, 3, 10, 8], 'PaperUnits', 'centimeters', 'PaperSize', [12, 12])
    pos = get(gca, 'Position');
    pos(4) = 0.65;
    pos(2) = 0.2;
    set(gca, 'Position', pos)

    grid on

    % write to file
    print(figName,'-dpng','-r300');

end

