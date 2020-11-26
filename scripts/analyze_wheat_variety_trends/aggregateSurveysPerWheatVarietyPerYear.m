function [NumberSurveysPerWheatVarietyPerYear,DiseaseCountsPerWheatVarietyPerYear] = AggregateSurveysPerWheatVarietyPerYear(AllSurveysPerWheatVariety,icolD,VarietyNumericIDs, AllYears)

% aggregate all surveys per wheat variety and year and count disease prevalence
% levels (low, mod, high)

    % initialize array to store disease prevalence scores per wheat variety
    DiseaseCountsPerWheatVarietyPerYear=zeros(length(VarietyNumericIDs),4);
    NumberSurveysPerWheatVarietyPerYear=zeros(length(VarietyNumericIDs),1);


    % loop years
    for iY=1:length(AllYears)
        iYear=AllYears(iY);

        % get all surveys for this year
        AllSurveysPerWheatVarietyPerYear=[];
        count=1;
        for i=1:length(AllSurveysPerWheatVariety(:,1))
            iYearSurvey=AllSurveysPerWheatVariety(i,1);
            if iYear==iYearSurvey
                AllSurveysPerWheatVarietyPerYear(count,:)=AllSurveysPerWheatVariety(i,:);
                count=count+1;
            end
        end

        % count number of surveys and prevalence levels
        if ~isempty(AllSurveysPerWheatVarietyPerYear)
            NumberSurveysPerWheatVarietyPerYear(iY)=length(AllSurveysPerWheatVarietyPerYear(:,1));
            DiseaseCountsPerWheatVarietyPerYear(iY,:)=hist(AllSurveysPerWheatVarietyPerYear(:,icolD),[0,1,2,3]);
        else
            NumberSurveysPerWheatVarietyPerYear(iY)=0;
            DiseaseCountsPerWheatVarietyPerYear(iY,1:4)=0;
        end

    end % end loop over years
 

end