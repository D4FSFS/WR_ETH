function  SurveyDataEthiopiaReducedNumeric=convertDataToNumeric(CleanEthiopiaDataArray)

    % function to convert cell array with survey data to numeric array,
    % including data about wheat growth stage.

    SurveyDataEthiopiaReducedNumeric=[];
    SurveyDataEthiopiaReducedNumeric(:,1)=cell2mat(CleanEthiopiaDataArray(:,2));   % year
    SurveyDataEthiopiaReducedNumeric(:,2)=cell2mat(CleanEthiopiaDataArray(:,3));   % month
    SurveyDataEthiopiaReducedNumeric(:,3)=cell2mat(CleanEthiopiaDataArray(:,4));   % day
    SurveyDataEthiopiaReducedNumeric(:,4)=cell2mat(CleanEthiopiaDataArray(:,5));   % latitude
    SurveyDataEthiopiaReducedNumeric(:,5)=cell2mat(CleanEthiopiaDataArray(:,6));   % longitude
    SurveyDataEthiopiaReducedNumeric(:,6)=cell2mat(CleanEthiopiaDataArray(:,11));  % severity
    SurveyDataEthiopiaReducedNumeric(:,7)=cell2mat(CleanEthiopiaDataArray(:,12));  % incidence
    SurveyDataEthiopiaReducedNumeric(:,8)=cell2mat(CleanEthiopiaDataArray(:,13));  % binary disease status (severity OR incidence >0)
    SurveyDataEthiopiaReducedNumeric(:,9)=cell2mat(CleanEthiopiaDataArray(:,8));   % area of field surveyed - take that as approximate "infected/not infected area"
    SurveyDataEthiopiaReducedNumeric(:,10)=cell2mat(CleanEthiopiaDataArray(:,10)); % GS
    
end

