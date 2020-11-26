function [NumberSurveysPerBiweek,DiseaseCountsPerBiweek] = getDiseaseCountsPerBiweekTraining(AllBiWeeklyDataArrays,iAllBiWeeks,year,icolD)

    % function to count disease occurrences per bi-weekly time-window

    % initialize array to store disease prevalence scores per biweek
    DiseaseCountsPerBiweek=zeros(length(iAllBiWeeks(1,:)),4);
    NumberSurveysPerBiweek=zeros(length(iAllBiWeeks(1,:)),1);
    
    % loop bi-weeks
    for k=1:length(iAllBiWeeks(1,:))
        % this bi-week
        iBiWeek=datestr(iAllBiWeeks(1,k),'mm/dd');
        disp(['checking surveys in biweekly interval starting at:',iBiWeek,'...']);
        
        % initialize
        iBiWeeklyDataArray=[];
        iBiWeeklyDataArrayHelper=[];
        
        % get all surveys
        iBiWeeklyDataArrayHelper=squeeze(AllBiWeeklyDataArrays(k,:,:));
        % get rid of padded -9 entries
        count=1;
        for iE=1:length(iBiWeeklyDataArrayHelper(:,1))
            iEntry=iBiWeeklyDataArrayHelper(iE,2);
            if iEntry>0
                iBiWeeklyDataArray(count,:)=iBiWeeklyDataArrayHelper(iE,:);
                count=count+1;
            end
        end                
        
        % exclude data from test year
        iBiWeeklyDataArrayTraining=[];
        count=1;
        for i=1:length(iBiWeeklyDataArray(:,1))
            iy=iBiWeeklyDataArray(i,1);
            if iy~=year
                iBiWeeklyDataArrayTraining(count,:)=iBiWeeklyDataArray(i,:);
                count=count+1;
            end
        end
        
        % count number of surveys and prevalence levels
        NumberSurveysPerBiweek(k)=length(iBiWeeklyDataArrayTraining(:,1));
        if ~isempty(iBiWeeklyDataArrayTraining)
            DiseaseCountsPerBiweek(k,:)=hist(iBiWeeklyDataArrayTraining(:,icolD),[0,1,2,3]);
        else
            DiseaseCountsPerBiweek(k,1:4)=0;
        end
    end
    
end

