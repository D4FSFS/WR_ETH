function [SampleMeanYieldLossFraction]=calcSampleMeanYieldLossFraction(DataArrayCleanFieldsNumericSubYears,iYear,AvgGrowthStageperYear,iAverageYieldETFAO_TonnesPerHa,iWheatPricePerTonneFAO_USDperTonne,iRust)

    % function ot estimate yield lost due to wheat rusts for each surveyed
    % field
    
    % summary:
    % for each surveyed wheat field:
    %   get severity and growth stage score
    %       if there is no entry for growth stage, use mean growth stage
    %   approximate yield loss per field
    % calculate mean yield loss on all fields surveyed in a given year

    % get all surveys this year
    indexYearlySurveys=find(DataArrayCleanFieldsNumericSubYears(:,1)==iYear);
    YearlySurveys=DataArrayCleanFieldsNumericSubYears(indexYearlySurveys,:);

    % for each surveyed field calculate approximate yield loss
    for iS=1:length(YearlySurveys(:,1))

       % get survey data about sev. and growth stage
       iSevScore=YearlySurveys(iS,6); 
       iGrowthStage=round(YearlySurveys(iS,10)); 
       if ischar(iGrowthStage) || isnan(iGrowthStage) || (iGrowthStage<0) || (iGrowthStage==0)
           iGrowthStage=round(AvgGrowthStageperYear);
       end

       % for no or low infections, losses are negligible
       if iSevScore==0 || iSevScore==1
           
           % store loss fraction
           YearlySurveys(iS,13)=0;           
       
       else
           
           % get severity from severity index
           if iSevScore==2
               Severity=30;
           elseif iSevScore==3
               Severity=50;
           end
           
           % approximate yield loss fraction for the surveyed field based on severity, growth stage and
           % literature (Roelfs, 1992)
           iApproxLossFraction=calcFieldScaleYieldLoss(Severity,iRust,iGrowthStage);

           % store
           YearlySurveys(iS,13)=iApproxLossFraction;
           
       end % end conditional checking if field is infected
    
    end % end loop all surveys of this year
   
    % calc mean loss fraction on all moderately / highly infected fields
    IndexAllSurveysWithInfection=find(YearlySurveys(:,13)>0);
    SampleMeanYieldLossFraction=mean(YearlySurveys(IndexAllSurveysWithInfection,13));   

end

