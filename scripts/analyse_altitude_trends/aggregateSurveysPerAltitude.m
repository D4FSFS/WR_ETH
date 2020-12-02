function [NumberSurveysPerAltitudeInterval,DiseaseCountsPerAltitude] = aggregateSurveysPerAltitude(iSurveyData,icolD,AltitudeBinArray)

    % function to aggregate surveys per altitude bin

    % initialize array to store disease prevalence scores per altitude bin
    DiseaseCountsPerAltitude=zeros(length(AltitudeBinArray)-1,4);
    NumberSurveysPerAltitudeInterval=zeros(length(AltitudeBinArray)-1,1);

    % loop all altitude bins
    for iA=1:length(AltitudeBinArray)-1
        % get boundaries of altitude bin
        iBottomB=AltitudeBinArray(iA);
        iTopB=AltitudeBinArray(iA+1);

        % get all surveys in this altitude interval
        AllSurveysPerAltitudeBin=[];
        count=1;
        for i=1:length(iSurveyData(:,1))
            iAltitude=iSurveyData(i,9);
            if iBottomB<=iAltitude && iTopB>iAltitude
                AllSurveysPerAltitudeBin(count,:)=iSurveyData(i,:);
                count=count+1;
            end
        end

        % count number of surveys and prevalence levels
        if ~isempty(AllSurveysPerAltitudeBin)
            NumberSurveysPerAltitudeInterval(iA)=length(AllSurveysPerAltitudeBin(:,1));
            DiseaseCountsPerAltitude(iA,:)=hist(AllSurveysPerAltitudeBin(:,icolD),[0,1,2,3]);
        else
            NumberSurveysPerAltitudeInterval(iA)=0;
            DiseaseCountsPerAltitude(iA,1:4)=0;
        end

    end

end

