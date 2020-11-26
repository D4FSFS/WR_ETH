function plotROCCurves(PredictionLogisticTemp,PredictionLogisticALLT,DiseaseStatusBinary,colorsBarChart,SubSubPlotFolderPath,RustType,iDiseaseClassification)

    % function to plot two ROC curves in one figure

    % model 1 - univariate logistic curve 
    [X1Uniform,Y1Uniform,ThresholdsUniform,AUCUniform,OPTROCPTUniform]=perfcurve(DiseaseStatusBinary,PredictionLogisticTemp,1);
    BestClassifierUniform=ThresholdsUniform((X1Uniform==OPTROCPTUniform(1))&(Y1Uniform==OPTROCPTUniform(2)));
    AllYoudenUniform=[];
    for iEUniform=1:length(X1Uniform)
        iXUniform=X1Uniform(iEUniform);
        iYUniform=Y1Uniform(iEUniform);
        iSensUniform=iYUniform;
        iSpecUniform=1-iXUniform;
        iYoudenUniform=iSensUniform+iSpecUniform-1;
        AllYoudenUniform(iEUniform)=iYoudenUniform;
    end
    [MaxYouUniform,IndexMaxYouUniform]=max(AllYoudenUniform);
    OptPointUniform=[X1Uniform(IndexMaxYouUniform),Y1Uniform(IndexMaxYouUniform)];

    % model 2 - multivariate logistic curve
    [X1Logistic,Y1Logistic,ThresholdsLogistic,AUCLogistic,OPTROCPTLogistic]=perfcurve(DiseaseStatusBinary,PredictionLogisticALLT,1);
    BestClassifierLogistic=ThresholdsLogistic((X1Logistic==OPTROCPTLogistic(1))&(Y1Logistic==OPTROCPTLogistic(2)));
    AllYoudenLogistic=[];
    for iELogistic=1:length(X1Logistic)
        iXLogistic=X1Logistic(iELogistic);
        iYLogistic=Y1Logistic(iELogistic);
        iSensLogistic=iYLogistic;
        iSpecLogistic=1-iXLogistic;
        iYoudenLogistic=iSensLogistic+iSpecLogistic-1;
        AllYoudenLogistic(iELogistic)=iYoudenLogistic;
    end
    [MaxYouLogistic,IndexMaxYouLogistic]=max(AllYoudenLogistic);
    OptPointLogistic=[X1Logistic(IndexMaxYouLogistic),Y1Logistic(IndexMaxYouLogistic)];

    % merge onto the axis
    CommonXAxisHelper=[];
    CommonXAxis=[];
    CommonXAxisHelper=[X1Uniform;X1Logistic];
    CommonXAxis=sort(unique(CommonXAxisHelper),'ascend');

    % fill the y values on common x axis for uniform
    YValsOnCommonXAxis_Uniform=ones(length(CommonXAxis(:,1)),1).*(-9999);
    for iy=1:length(X1Uniform(:,1))
        xInROC=X1Uniform(iy,1);
        yInROC=Y1Uniform(iy,1);
        Ind=find(CommonXAxis==xInROC);
        YValsOnCommonXAxis_Uniform(Ind,1)=yInROC;
    end
    AllNoData=find(YValsOnCommonXAxis_Uniform==-9999);
    YValsOnCommonXAxis_Uniform(AllNoData,1)=NaN;
    idx=find(~isnan(YValsOnCommonXAxis_Uniform));
    YValsOnCommonXAxis_UniformInterpolated=interp1(CommonXAxis(idx),YValsOnCommonXAxis_Uniform(idx),CommonXAxis,'linear');

    % fill the y values on common x axis for logistic
    YValsOnCommonXAxis_Logistic=ones(length(CommonXAxis(:,1)),1).*(-9999);
    for iy=1:length(X1Logistic(:,1))
        xInROC=X1Logistic(iy,1);
        yInROC=Y1Logistic(iy,1);
        Ind=find(CommonXAxis==xInROC);
        YValsOnCommonXAxis_Logistic(Ind,1)=yInROC;
    end
    AllNoData=find(YValsOnCommonXAxis_Logistic==-9999);
    YValsOnCommonXAxis_Logistic(AllNoData,1)=NaN;
    idx=find(~isnan(YValsOnCommonXAxis_Logistic));
    YValsOnCommonXAxis_LogisticInterpolated=interp1(CommonXAxis(idx),YValsOnCommonXAxis_Logistic(idx),CommonXAxis,'linear');

    % get line of random model
    ind=[1,length(CommonXAxis)];
    ROCRandom=interp1(CommonXAxis(ind),[0,1],CommonXAxis,'linear');

    % plot of uniform and logistic model for all years
    figure
    box on 
    grid on
    set(gcf,'PaperUnits','inches','PaperSize',[5,5],'PaperPosition',[0,0,5,5]);
    hold all
    p2=plot(CommonXAxis(:,1),YValsOnCommonXAxis_UniformInterpolated,':','LineWidth',2.5,'Color',colorsBarChart(2,:));
    p3=plot(CommonXAxis(:,1),YValsOnCommonXAxis_Logistic,'-','LineWidth',2.5,'Color',colorsBarChart(3,:));
    p4=plot(CommonXAxis(:,1),ROCRandom,'k--','LineWidth',1);
    xlabel({'False positive rate (1-specificity)',''},'FontSize',16);
    ylabel('True positive rate (sensitivity)','FontSize',16);
    set(gca,'FontSize',14,'XTick',0:0.2:1,'YTick',0:0.2:1,'FontSize',14);
    legend([p4 p2 p3],['un-informed (random choice)'],['model 1: logistic curve (time)'],['model 2: logistic curve (time, lat., long., alt.)'],'Location','southeast','FontSize',10);
    figname=strcat(SubSubPlotFolderPath,'ROC_UniformAndLogistic_',RustType,'_',iDiseaseClassification,'.png');
    saveas(gcf,figname);

   
end

