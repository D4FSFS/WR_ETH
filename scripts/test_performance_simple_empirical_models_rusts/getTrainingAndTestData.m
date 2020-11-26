function  [iSurveyDataTraining,iSurveyDataPrediction]=GetTrainingAndTestData(iSurveyDataMeher,iYear)

    % function to separate training and test data    

    % get subset of data used for training empirical models
    % (all data except one year)
    iSurveyDataTraining=[];
    count=0;
    for iS=1:length(iSurveyDataMeher(:,1))
        iYearSurvey=iSurveyDataMeher(iS,1);
        if iYearSurvey~=iYear
            count=count+1;
            iSurveyDataTraining(count,:)=iSurveyDataMeher(iS,:);
        end
    end
    % get subset of data used for testing empirical models
    iSurveyDataPrediction=[];
    count=0;
    for iS=1:length(iSurveyDataMeher(:,1))
        iYearSurvey=iSurveyDataMeher(iS,1);
        if iYearSurvey==iYear
            count=count+1;
            iSurveyDataPrediction(count,:)=iSurveyDataMeher(iS,:);
        end
    end


end

