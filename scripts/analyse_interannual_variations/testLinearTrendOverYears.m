function testLinearTrendOverYears(AllYears,AllProps,colorsBarChart,iRustStr,iDisStrLeg,figName,fileName)

    % function to calculate and plot a linear trend to disease prevalence
    % levels during years 2010-2019

    % get all non-zero disease scores in a separate array
    LowDiseaseProps=AllProps(:,3)+AllProps(:,2)+AllProps(:,1);
    ModDiseaseProps=AllProps(:,2)+AllProps(:,1);
    HighDiseaseProps=AllProps(:,1);

    % calc. linear fit
    
    % low disease levels
    LinearTrendLowPrevalence=fitlm(1:length(AllYears),LowDiseaseProps);
    Rsquared(1)=LinearTrendLowPrevalence.Rsquared.Ordinary;
    [p(1),F(1)] = coefTest(LinearTrendLowPrevalence);
    
    % moderate disease levels
    LinearTrendModPrevalence=fitlm(1:length(AllYears),ModDiseaseProps);
    Rsquared(2)=LinearTrendModPrevalence.Rsquared.Ordinary;
    [p(2),F(2)] = coefTest(LinearTrendModPrevalence);
    
    % high disease levels
    LinearTrendHighPrevalence=fitlm(1:length(AllYears),HighDiseaseProps);
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
        
    % plot scatter plot and fitted linear curves 
    figure
    grid on

    % low disease levels
    p1=plot(1:length(AllYears),LowDiseaseProps,'o','MarkerSize',8,'LineWidth',1);
    p1.MarkerFaceColor=colorsBarChart(1,:);
    p1.MarkerEdgeColor=[0,0,0];
    hold on
    l1=plot(1:length(AllYears),LinearTrendLowPrevalence.Fitted,'LineStyle','--','LineWidth',2.5,'color',colorsBarChart(1,:));
    hold on

    % moderate disease levels
    p2=plot(1:length(AllYears),ModDiseaseProps,'square','MarkerSize',8,'LineWidth',1);
    p2.MarkerFaceColor=colorsBarChart(2,:);
    p2.MarkerEdgeColor=[0,0,0];
    hold on
    l2=plot(1:length(AllYears),LinearTrendModPrevalence.Fitted,'LineStyle',':','LineWidth',2.5,'color',colorsBarChart(2,:));
    hold on

    % high disease levels
    p3=plot(1:length(AllYears),HighDiseaseProps,'diamond','MarkerSize',8,'LineWidth',1);
    p3.MarkerFaceColor=colorsBarChart(3,:);
    p3.MarkerEdgeColor=[0,0,0];
    hold on
    l3=plot(1:length(AllYears),LinearTrendHighPrevalence.Fitted,'LineStyle','-','LineWidth',2.5,'color',colorsBarChart(3,:)); 
    hold on
    
    % set labels
    set(gca,'XTick',1:length(AllYears),'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'},'XLim',[0,11],'YLim',[0,1],'FontSize',12);
    rotateXLabels(gca(),45);
    ylabel('Prevalence','FontSize',12);
    xlabel('Year','FontSize',12);    
    
    % legend
    ldatalow=[iRustStr,' ','low',' ',iDisStrLeg];
    linelow=['linear fit to ',ldatalow];
    ldatamod=[iRustStr,' ','mod',' ',iDisStrLeg];
    linemod=['linear fit to ',ldatamod];
    ldatahigh=[iRustStr,' ','high',' ',iDisStrLeg];
    linehigh=['linear fit to ',ldatahigh];
    legend([p1,l1,p2,l2,p3,l3],ldatalow,linelow,ldatamod,linemod,ldatahigh,linehigh,'FontSize',10)
  
    % set size / margin ratio
    pos = get(gca, 'Position');
    pos(4) = 0.7;
    set(gca, 'Position', pos)

    % write to file
    print(figName,'-dpng','-r300');

end
