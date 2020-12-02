function plotDiseasePrevalenceScoresLatLon(figName,DiseaseCountsPerVariableInterval,NumberSurveysPerVariableInterval,XBins,iRustStr,iDisStrLeg,colorsBarChart,xlabelstr)

    % calc. and plot disease prevalence (proportions of low/medium/high disease
    % level) per bin
    ProportionIncidenceLow=[];
    ProportionIncidenceMed=[];
    ProportionIncidenceHigh=[];
    ProportionIncidenceNegative=[];

    % loop bins
    for iA=1:length(XBins)-1
        iNumS=NumberSurveysPerVariableInterval(iA);
        if iNumS>0
            ProportionIncidenceLow(iA)=DiseaseCountsPerVariableInterval(iA,2)./ NumberSurveysPerVariableInterval(iA);
            ProportionIncidenceMed(iA)=DiseaseCountsPerVariableInterval(iA,3)./NumberSurveysPerVariableInterval(iA);
            ProportionIncidenceHigh(iA)=DiseaseCountsPerVariableInterval(iA,4)./ NumberSurveysPerVariableInterval(iA);
            ProportionIncidenceNegative(iA)=DiseaseCountsPerVariableInterval(iA,1)./NumberSurveysPerVariableInterval(iA);
        else
            ProportionIncidenceLow(iA)=0;
            ProportionIncidenceMed(iA)=0;
            ProportionIncidenceHigh(iA)=0;
            ProportionIncidenceNegative(iA)=0;
        end
    end

    % combine all three props one array for plotting stacked histogram
    AllProps=[];
    AllProps(:,4)=ProportionIncidenceNegative;
    AllProps(:,3)=ProportionIncidenceLow;
    AllProps(:,2)=ProportionIncidenceMed;
    AllProps(:,1)=ProportionIncidenceHigh;


    % plot prop. positives in categories (low, mod., high)
    PropsPositives=AllProps(:,1:3);
    TotProp=PropsPositives(:,1)+PropsPositives(:,2)+PropsPositives(:,3);

    figure

    % plot bars
    b=bar(PropsPositives,'stacked','BarWidth',0.7);

    % set grid lines
    grid on

    % set colors of bars
    b(1).FaceColor=colorsBarChart(3,:); % high in darker at bottom
    b(2).FaceColor=colorsBarChart(2,:);
    b(3).FaceColor=colorsBarChart(1,:); % low in lighter at top

    % set labels
    XTickLabelVec={};
    %XTickLabelVec{1}=strcat('<',num2str(XBins(2)));
    for i=1:length(XBins)-1
        XTickLabelVec{i}=strcat('[',num2str(XBins(i)),'-',num2str(XBins(i+1)),'[');
    end
    %XTickLabelVec{length(XBins)-1}=strcat('>',num2str(XBins(end-1)));
    if strcmp(iDisStrLeg,'severity')
    set(gca,'YLim',[0,1],'XLim',[0.5,length(XBins)-0.5],'XTick',1:length(XBins)-1,'XTickLabel',XTickLabelVec);
    rotateXLabels(gca(),45);
    xlabel(xlabelstr)
    elseif strcmp(iDisStrLeg,'incidence')
        set(gca,'YLim',[0,1],'XLim',[0.5,length(XBins)-0.5],'XTick',1:length(XBins)-1,'XTickLabel',[]);
    end
    ylabel('prevalence')

    % write number of surveys on top of axis
    XTickTopVec={};
    for i=1:length(AllProps)
        XTickTopVec{i}=['n=',num2str(NumberSurveysPerVariableInterval(i))];
    end
    xt = get(gca, 'XTick');
    y=ones(1,length(TotProp))+0.13;
    if strcmp(iDisStrLeg,'incidence')
        t=text(xt,y,XTickTopVec,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',12);
        set(t,'Rotation',45);
    end

    % set legend
    legend([b(3),b(2),b(1)],[iRustStr,' ','low',' ',iDisStrLeg],[iRustStr,' ','moderate',' ',iDisStrLeg],[iRustStr,' ','high',' ',iDisStrLeg],'FontSize',10);

    % set size / margin ratio
    %set(gcf, 'Units', 'centimeters', 'Position', [3, 3, 10, 8], 'PaperUnits', 'centimeters', 'PaperSize', [12, 12])
    pos = get(gca, 'Position');
    pos(4) = 0.7;
    set(gca, 'Position', pos)

    % print to file
    print(figName,'-dpng','-r300');

end
