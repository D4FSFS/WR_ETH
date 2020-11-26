function [NumberSurveysPerBiweek,DiseaseCountsPerBiweek] = getDiseaseCountsPerBiweek(AllBiWeeklyDataArrays,iAllBiWeeks,icolD)

    % function to analyse disease prevalence per bi-weekly time-window

    % initialize array to store disease prevalence scores 
    DiseaseCountsPerBiweek=zeros(length(iAllBiWeeks(1,:)),4);
    NumberSurveysPerBiweek=zeros(length(iAllBiWeeks(1,:)),1);
    
    % loop bi-weeks
    for k=1:length(iAllBiWeeks(1,:))
        
        % def. date and keep track
        iBiWeek=datestr(iAllBiWeeks(1,k),'mm/dd');
        disp(['checking surveys in biweekly interval starting at:',iBiWeek,'...']);
        
        % initialize arrays for storing
        iBiWeeklyDataArray=[];
        iBiWeeklyDataArrayHelper=[];
        
        % get all surveys conducted during the 14-day time-window 
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
        
        % count the number of surveys and prevalence levels
        NumberSurveysPerBiweek(k)=length(iBiWeeklyDataArray(:,1));
        if ~isempty(iBiWeeklyDataArray)
            DiseaseCountsPerBiweek(k,:)=hist(iBiWeeklyDataArray(:,icolD),[0,1,2,3]);
        else
            DiseaseCountsPerBiweek(k,1:4)=0;
        end
    end
    
end

