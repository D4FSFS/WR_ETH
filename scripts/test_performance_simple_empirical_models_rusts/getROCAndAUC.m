function [ROCX1,ROCY1,ROCThresdhold,ROCAUC,ROCOPTROC,ROCOptPointYOUDEN]=getROCAndAUC(iSurveyData,ModelPrediction)

    % function to calculate the ROC curve and AUC value

    [X1Logistic,Y1Logistic,ThresholdsLogistic,AUCLogistic,OPTROCPTLogistic]=perfcurve(iSurveyData,ModelPrediction,1);
    
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

    % store ROC etc of this year
    ROCX1=X1Logistic;
    ROCY1=Y1Logistic;
    ROCThresdhold=ThresholdsLogistic;
    ROCAUC=AUCLogistic;
    ROCOPTROC=OPTROCPTLogistic;
    ROCOptPointYOUDEN=OptPointLogistic;

end

