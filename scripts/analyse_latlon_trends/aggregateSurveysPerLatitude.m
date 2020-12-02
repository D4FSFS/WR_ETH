function [NumberSurveysPerLatitudeInterval,DiseaseCountsPerLatitude] = aggregateSurveysPerLatitude(iSurveyData,icolD,LatitudeBinArray)

    % function to aggregate field surveys per latitude bin

    % initialize array to store disease prevalence scores per bin
    DiseaseCountsPerLatitude=zeros(length(LatitudeBinArray)-1,4);
    NumberSurveysPerLatitudeInterval=zeros(length(LatitudeBinArray)-1,1);

    % loop bins
    for iA=1:length(LatitudeBinArray)-1
        
        % get boundaries of altitude bin
        iBottomB=LatitudeBinArray(iA);
        iTopB=LatitudeBinArray(iA+1);

        % get all surveys in this bininterval
        AllSurveysPerLatitudeBin=[];
        count=1;
        for i=1:length(iSurveyData(:,1))
            iLat=iSurveyData(i,4);  % get lat from surveys
            if iBottomB<=iLat && iTopB>iLat
                AllSurveysPerLatitudeBin(count,:)=iSurveyData(i,:);
                count=count+1;
            end
        end

        % count number of surveys and prevalence levels
        if ~isempty(AllSurveysPerLatitudeBin)
            NumberSurveysPerLatitudeInterval(iA)=length(AllSurveysPerLatitudeBin(:,1));
            DiseaseCountsPerLatitude(iA,:)=hist(AllSurveysPerLatitudeBin(:,icolD),[0,1,2,3]);
        else
            DiseaseCountsPerLatitude(iA,1:4)=0;
            NumberSurveysPerLatitudeInterval(iA)=0;
        end

    end

end


