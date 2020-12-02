function [NumberSurveysPerLongitudeInterval,DiseaseCountsPerLongitude] = aggregateSurveysPerLongitude(iSurveyData,icolD,LongitudeBinArray)

    % function to aggregate surveys per longitude bin

    % initialize array to store disease prevalence scores per bin
    DiseaseCountsPerLongitude=zeros(length(LongitudeBinArray)-1,4);
    NumberSurveysPerLongitudeInterval=zeros(length(LongitudeBinArray)-1,1);

    % loop bins
    for iA=1:length(LongitudeBinArray)-1
        
        % get boundaries of bin
        iBottomB=LongitudeBinArray(iA);
        iTopB=LongitudeBinArray(iA+1);

        % get all surveys in this bin interval
        AllSurveysPerLongitudeBin=[];
        count=1;
        for i=1:length(iSurveyData(:,1))
            iLongitude=iSurveyData(i,5);    % get long from surveys
            if iBottomB<=iLongitude && iTopB>iLongitude
                AllSurveysPerLongitudeBin(count,:)=iSurveyData(i,:);
                count=count+1;
            end
        end

        % count number of surveys and prevalence levels
        if ~isempty(AllSurveysPerLongitudeBin)
            NumberSurveysPerLongitudeInterval(iA)=length(AllSurveysPerLongitudeBin(:,1));
            DiseaseCountsPerLongitude(iA,:)=hist(AllSurveysPerLongitudeBin(:,icolD),[0,1,2,3]);
        else
            DiseaseCountsPerLongitude(iA,1:4)=0;
            NumberSurveysPerLongitudeInterval(iA)=0;
        end

    end

end

