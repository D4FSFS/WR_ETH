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
    % diary(fileName);
    % disp('low\n')
    % mdlloglow
    % disp('\n\n mod\n')
    % mdllogmod
    % disp('\n\n mod\n')
    % mdlloghigh
    % diary off

    % get proportion of positives per disease categories (low, mod., high)
    PropsPositives=AllProps(:,1:3);
    TotProp=PropsPositives(:,1)+PropsPositives(:,2)+PropsPositives(:,3);   

end

