function [NumberSurveysPerWheatVariety,DiseaseCountsPerWheatVariety] = AggregateSurveysPerWheatVariety(iSurveyData,icolD,VarietyNumericIDs)

    % aggregate all surveys per wheat variety and count disease prevalence
    % levels (low, mod, high) 
    
    % initialize array to store disease prevalence scores per wheat variety
    DiseaseCountsPerWheatVariety=zeros(length(VarietyNumericIDs),4);
    NumberSurveysPerWheatVariety=zeros(length(VarietyNumericIDs),1);

    % loop all wheat varieties
    for iA=1:length(VarietyNumericIDs)

        % get ID of this wheat variety
        WVarID=VarietyNumericIDs(iA);

        % get all surveys for this wheat variety (WVarID)
        AllSurveysPerWheatVariety=[];
        count=1;
        for i=1:length(iSurveyData(:,1))
            iWVar=iSurveyData(i,8);
            if iWVar==WVarID
                AllSurveysPerWheatVariety(count,:)=iSurveyData(i,:);
                count=count+1;
            end
        end

        % count number of surveys and prevalence levels
        if ~isempty(AllSurveysPerWheatVariety)
            NumberSurveysPerWheatVariety(iA)=length(AllSurveysPerWheatVariety(:,1));
            DiseaseCountsPerWheatVariety(iA,:)=hist(AllSurveysPerWheatVariety(:,icolD),[0,1,2,3]);
        else
            NumberSurveysPerWheatVariety(iA)=0;
            DiseaseCountsPerWheatVariety(iA,1:4)=0;
        end

    end

end

