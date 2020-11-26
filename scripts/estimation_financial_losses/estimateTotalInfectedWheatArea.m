function [PropsIncAllYears]=estimateTotalInfectedWheatArea(SurveyDataEthiopiaReducedNumeric,iRustStr,AllYears,SubPlotFolderPath,fidSummaryFile)

    % function to estimate the total infected area infected with rusts
    % based on the proportion of disease incidence scores reported in surveys

    % get fraction of surveys with low / mod / high disease incidence 
    TotalHighIncInfected=0;
    TotalMedIncInfected=0;
    TotalLowIncInfected=0;
        
    for iEntry=1:length(SurveyDataEthiopiaReducedNumeric(:,1))
        
        % get incidence score
        iIncScore=SurveyDataEthiopiaReducedNumeric(iEntry,7);
        
        % low disease level
        if iIncScore == 1
            TotalLowIncInfected=TotalLowIncInfected+1;
        end
        
        % moderate disease level
        if iIncScore == 2
            TotalMedIncInfected=TotalMedIncInfected+1;
        end
        
        % high disease level
        if iIncScore == 3
            TotalHighIncInfected=TotalHighIncInfected+1;
        end
        
        
    end % end loop over all surveys
    
    % calc. proportions
    PropLowInc=TotalLowIncInfected/length(SurveyDataEthiopiaReducedNumeric(:,1));
    PropModInc=TotalMedIncInfected/length(SurveyDataEthiopiaReducedNumeric(:,1));
    PropHighInc=TotalHighIncInfected/length(SurveyDataEthiopiaReducedNumeric(:,1));
        
    % estimate infected area per year
    
    % initialize empty
    TotalHighIncInfectedAllYears=zeros(length(AllYears(1,:)),1);
    TotalMedIncInfectedAllYears=zeros(length(AllYears(1,:)),1);
    TotalLowIncInfectedAllYears=zeros(length(AllYears(1,:)),1);
    PropHighIncInfectedAllYears=zeros(length(AllYears(1,:)),1);
    PropMedIncInfectedAllYears=zeros(length(AllYears(1,:)),1);
    PropLowIncInfectedAllYears=zeros(length(AllYears(1,:)),1);       
    
    % loop over years
    for iY=1:length(AllYears(1,:))
        
        % subset data for this year
        iYear=AllYears(iY);
        iSurveyData=[];
        counter=1;
        for iEntry=1:length(SurveyDataEthiopiaReducedNumeric(:,1))
           YearOfDataEntry=SurveyDataEthiopiaReducedNumeric(iEntry,1);
           if YearOfDataEntry==iYear
               iSurveyData(counter,:)=SurveyDataEthiopiaReducedNumeric(iEntry,:);
               counter=counter+1;
           end
        end   
 
        % calc. infected/non infected area and store in array
        for iEntry=1:length(iSurveyData(:,1))
                                   
            % get incidence score
            iIncScore=iSurveyData(iEntry,7);
                                  
            % sum up high incidence fields
            if iIncScore==3
                TotalHighIncInfectedAllYears(iY,1)=TotalHighIncInfectedAllYears(iY,1)+1;
            end
            
            % sum up moderate incidence fields
            if iIncScore==2
                TotalMedIncInfectedAllYears(iY,1)=TotalMedIncInfectedAllYears(iY,1)+1;
            end
            
            % sum up low incidence fields
            if iIncScore==1
                TotalLowIncInfectedAllYears(iY,1)=TotalLowIncInfectedAllYears(iY,1)+1;
            end
            
        end % end loop over all surveys this year
        
        % calc. proportions
        PropLowIncInfectedAllYears(iY,1)=TotalLowIncInfectedAllYears(iY,1)/length(iSurveyData(:,1));
        PropMedIncInfectedAllYears(iY,1)=TotalMedIncInfectedAllYears(iY,1)/length(iSurveyData(:,1));
        PropHighIncInfectedAllYears(iY,1)=TotalHighIncInfectedAllYears(iY,1)/length(iSurveyData(:,1));
              
        % write
        fprintf(fidSummaryFile,'Year: %s \n',num2str(iYear));
        fprintf(fidSummaryFile,'Prop low inc:  %s \n',num2str(PropLowIncInfectedAllYears(iY,1)));
        fprintf(fidSummaryFile,'Prop mod inc:  %s \n',num2str(PropMedIncInfectedAllYears(iY,1)));
        fprintf(fidSummaryFile,'Prop high inc:  %s \n\n',num2str(PropHighIncInfectedAllYears(iY,1)));                
                 
    end % end loop all years
           
    % store proportions and feed back to main script
    PropsIncAllYears=zeros(3,length(AllYears(1,:)));
    PropsIncAllYears(1,:)=PropLowIncInfectedAllYears;
    PropsIncAllYears(2,:)=PropMedIncInfectedAllYears;
    PropsIncAllYears(3,:)=PropHighIncInfectedAllYears;    
    
 end

