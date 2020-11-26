function [AllBiWeeklyDataArrays] = aggregateSurveysPerBiWeek(iSurveyDataMeher,AllYears,RustType,iAllBiWeeks,SubPlotFolderPath)

    % function to aggregate all surveys conducted per bi-weekly time-window during the main wheat season

    % initialize arrays to store all surveys per bi-weekly time-interval
    AllBiWeeklyDataArrays=ones(length(iAllBiWeeks(1,:)),length(iSurveyDataMeher(:,1)),length(iSurveyDataMeher(1,:)))*(-9);
    SurveysPerBiWeek=ones(length(iAllBiWeeks(1,:)),1);
    
    % loop all surveys and get the bi-weekly time-window during which the survey was conducted 
    for i=1:length(iSurveyDataMeher(:,1))
        iFlagFoundInterval=0;
        
        % keep track
        if mod(i,1000)==0
            disp(['checking survey number: ',num2str(i)])
        end        
        
        % loop all bi-weeks
        for k=1:length(iAllBiWeeks(1,:))
            % aggregating over all years                   
            for j=1:length(AllYears)
                
                % def. 14-day interval/bi-week
                iStartDateIntervall=iAllBiWeeks(j,k);
                iEndDateIntervall=iStartDateIntervall+caldays(13);
                
                % get date of survey
                YearOfSurvey=iSurveyDataMeher(i,1);
                MonthOfSurvey=iSurveyDataMeher(i,2);
                DayOfSurvey=iSurveyDataMeher(i,3);
                iDateOfSurvey=datetime(YearOfSurvey,MonthOfSurvey,DayOfSurvey);
                
                % check if survey date falls in bi-weekly time-interval;
                if isbetween(iDateOfSurvey,iStartDateIntervall,iEndDateIntervall)
                    SurveysCounter=SurveysPerBiWeek(k);
                    AllBiWeeklyDataArrays(k,SurveysCounter,:)=iSurveyDataMeher(i,:);
                    SurveysPerBiWeek(k)=SurveysPerBiWeek(k)+1;
                    iFlagFoundInterval=1;
                    break
                end
            end % end loop year
            
            if iFlagFoundInterval==1
                break
            end
            
        end % end loop biweeks
   end % end loop surveys
   
   % print to file
   
   % def. temp. folder for storing file
   PathToFolder=strcat(SubPlotFolderPath,'\TempFiles\');
   mkdir(PathToFolder);
   
   % loop bi-weekly time-intervals and store
   for k=1:length(iAllBiWeeks(1,:))
        
        % get bi-week, def. filename and initialize array for storing surveys
        iBiWeek=datestr(iAllBiWeeks(1,k),'mmdd');
        filename=strcat(PathToFolder,'Surveys',iBiWeek,'.csv');
        iBiWeeklyDataArray=[];
        
        % keep track
        disp(['surveys in biweekly interval starting at:',iBiWeek,'...']);
        
        % write to file 
        iBiWeeklyDataArrayHelper=squeeze(AllBiWeeklyDataArrays(k,:,:)); 
        fid=fopen(filename,'w');
        fprintf(fid,strcat('Year, Month, Day, Latitude, Longitude,',RustType,'Severity,',RustType,' Incidence, Disease presence, Days into season, bi-weeks into season  \n'));
        fclose(fid);
        if isempty(iBiWeeklyDataArrayHelper)
            Helper=[];
            Helper(1,:)=[-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999];
            dlmwrite(filename,Helper,'-append','delimiter',',');
        else
            dlmwrite(filename,iBiWeeklyDataArrayHelper,'-append','delimiter',',','precision', 4);
        end  
      
   end % end loop over all bi-weeks   
   
end % end function





