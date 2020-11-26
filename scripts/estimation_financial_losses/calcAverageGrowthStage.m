function AvgGrowthStage=calcAverageGrowthStage(DataArrayCleanFieldsNumericSubYears,iRustStr,AllYears,SubPlotFolderPath,fidSummaryFile)

    % function to calculate the average growth stage in surveys

    if length(AllYears(1,:))>1
        
        % calc average over all years
        minGS=min(cell2mat(DataArrayCleanFieldsNumericSubYears(:,10)));
        maxGS=max(cell2mat(DataArrayCleanFieldsNumericSubYears(:,10)));
        AvgGrowthStage=mean(cell2mat(DataArrayCleanFieldsNumericSubYears(:,10)));
    
    elseif length(AllYears(1,:))==1
        
        % calc average per year
        iYear=AllYears;    
        indexYearlySurveys=find(cell2mat(DataArrayCleanFieldsNumericSubYears(:,2))==iYear);
        YearlySurveys=DataArrayCleanFieldsNumericSubYears(indexYearlySurveys,:);
        minGS=min(cell2mat(YearlySurveys(:,10)));
        maxGS=max(cell2mat(YearlySurveys(:,10)));
        AvgGrowthStage=mean(cell2mat(YearlySurveys(:,10)));
    
    end  
    
end

