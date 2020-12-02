function plotPrevalencePerVarietyBarChart(AllPropsReordered,NumberSurveysPerWheatVarietyReordered,VarietyNamesReordered,VarietyNumericIDs,colorsBarChart,iRustStr,iDisStrLeg,figName)
    
    % function to plot bar chart of rust prevalence per year
                        
    % get proportin of positives in different categories (low, mod., high disease)
    PropsPositives=AllPropsReordered(:,1:3);
    TotProp=PropsPositives(:,1)+PropsPositives(:,2)+PropsPositives(:,3);

    % plot...
    figure

    % plot bars
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
    for i=1:length(AllPropsReordered)
        XTickTopVec{i}=['n=',num2str(NumberSurveysPerWheatVarietyReordered(i))];
    end         
    xt = get(gca, 'XTick');
    y=ones(1,length(AllPropsReordered))+0.13;
    if strcmp(iDisStrLeg,'incidence')
        t=text(xt,y,XTickTopVec,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',12);
        set(t,'Rotation',45);  
    end

    % define x axis tix and axis labels
    XTickLabelVec=VarietyNamesReordered;
    if strcmp(iDisStrLeg,'severity')
        set(gca,'YLim',[0,1],'XLim',[0.5,length(VarietyNumericIDs)+0.5],'XTick',1:length(VarietyNumericIDs),'XTickLabel',XTickLabelVec);
        rotateXLabels(gca(),45);
        xlabel('wheat variety');
    elseif strcmp(iDisStrLeg,'incidence')
         set(gca,'YLim',[0,1],'XLim',[0.5,length(VarietyNumericIDs)+0.5],'XTick',1:length(VarietyNumericIDs),'XTickLabel',[]);
    end
    ylabel('prevalence');

    % set legend
    legend([b(3),b(2),b(1)],[iRustStr,' ','low',' ',iDisStrLeg],[iRustStr,' ','moderate',' ',iDisStrLeg],[iRustStr,' ','high',' ',iDisStrLeg],'FontSize',10,'Location','NorthWest');

    % set size / margin ratio
    pos = get(gca, 'Position');
    pos(4) = 0.7;
    set(gca, 'Position', pos)

    % write to file
    print(figName,'-dpng','-r300');      

          
end
