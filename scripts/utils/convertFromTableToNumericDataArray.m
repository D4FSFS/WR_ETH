function SurveyDataEthiopiaReducedNumeric = convertFromTableToNumericDataArray(DataArrayAll)

   % convert from data table to array with data    

    SurveyDataEthiopiaReducedNumeric=[];
    SurveyDataEthiopiaReducedNumeric(:,1)=table2array(DataArrayAll(2:end,2));  % year
    SurveyDataEthiopiaReducedNumeric(:,2)=table2array(DataArrayAll(2:end,3));  % month
    SurveyDataEthiopiaReducedNumeric(:,3)=table2array(DataArrayAll(2:end,4));  % day
    SurveyDataEthiopiaReducedNumeric(:,4)=table2array(DataArrayAll(2:end,5));  % latitude
    SurveyDataEthiopiaReducedNumeric(:,5)=table2array(DataArrayAll(2:end,6));  % longitude
    SurveyDataEthiopiaReducedNumeric(:,6)=table2array(DataArrayAll(2:end,11)); % severity
    SurveyDataEthiopiaReducedNumeric(:,7)=table2array(DataArrayAll(2:end,12)); % incidence
    SurveyDataEthiopiaReducedNumeric(:,8)=table2array(DataArrayAll(2:end,13)); % binary disease status (severity OR incidence >0)

end
