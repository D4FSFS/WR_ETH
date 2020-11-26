function  plotInterannualVariationOfROCCurves(ROCX1,ROCY1,AllYears,Colours,figname)

    % function to plot ROC curves from all years into a single figure for
    % analysing inter-annual variations

    % define common axis
    CommonXAxisHelper=[];
    CommonXAxis=[];
    CommonXAxisHelper=[ROCX1{1};ROCX1{2};ROCX1{3};ROCX1{4};ROCX1{5};ROCX1{6};ROCX1{7};ROCX1{8};ROCX1{9};ROCX1{10}];
    CommonXAxis=sort(unique(CommonXAxisHelper),'ascend');

    % fill the y values on common x axis
    AllYValsOnCommonXAxis={};
    for iYY=1:length(AllYears)
        X1Vals=ROCX1{iYY};
        Y1Vals=ROCY1{iYY};
        YValsOnCommonXAxis=ones(length(CommonXAxis(:,1)),1).*(-9999);
        for iy=1:length(X1Vals(:,1))
            xInROC=X1Vals(iy,1);
            yInROC=Y1Vals(iy,1);
            Ind=find(CommonXAxis==xInROC);
            YValsOnCommonXAxis(Ind,1)=yInROC;
        end
        AllNoData=find(YValsOnCommonXAxis==-9999);
        YValsOnCommonXAxis(AllNoData,1)=NaN;
        idx=find(~isnan(YValsOnCommonXAxis));
        YValsOnCommonXAxis_Interpolated=interp1(CommonXAxis(idx),YValsOnCommonXAxis(idx),CommonXAxis,'linear');
        % store
        AllYValsOnCommonXAxis{iYY}=YValsOnCommonXAxis_Interpolated;
    end

    % get line for mimicking "random choice"
    ind=[1,length(CommonXAxis)];
    ROCRandom=interp1(CommonXAxis(ind),[0,1],CommonXAxis,'linear');

    % plot of ROC for different years
    figure
    box on 
    grid on
    set(gcf,'PaperUnits','inches','PaperSize',[5,5],'PaperPosition',[0,0,5,5]);
    hold all
    for YY=1:length(AllYears)
        colorTriple=Colours(YY,:);
        p(YY)=plot(CommonXAxis(:,1),AllYValsOnCommonXAxis{YY},'LineWidth',2,'Color',colorTriple);
    end
 
    p(2*length(AllYears)+1)=plot(CommonXAxis(:,1),ROCRandom,'k--','LineWidth',1);
    xlabel({'False positive rate (1-specificity)',''},'FontSize',16);
    ylabel('True positive rate (sensitivity)','FontSize',16);
    set(gca,'FontSize',14,'XTick',0:0.2:1,'YTick',0:0.2:1,'FontSize',14);
    legend([p(1:length(AllYears))],'2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','Location','southeast');
    saveas(gcf,figname);                       
             

end

