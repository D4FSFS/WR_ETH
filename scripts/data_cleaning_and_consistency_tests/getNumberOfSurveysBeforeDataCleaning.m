function [TotalNumberSurveys,NumberSurveysPerYear] = getNumberOfSurveysBeforeDataCleaning(dataArray,AllYears)

% function to calc. the total number of surveys and surveys per year in the "raw" data-file 

% total number of surveys
TotalNumberSurveys=length(dataArray(:,1))-1;
disp(strcat('total number of surveys before data cleaning:',num2str(TotalNumberSurveys)));    

% number of surveys per year
NumberSurveysPerYear=zeros(1,length(AllYears(1,:)));
for iD=2:length(dataArray(:,1))
    iYear=dataArray{iD,2};
    for iY=1:length(AllYears(1,:))
        checkYear=AllYears(iY);
        if iYear==checkYear
           NumberSurveysPerYear(iY)=NumberSurveysPerYear(iY)+1;
        end 
    end
end

end

