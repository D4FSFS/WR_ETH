function AllBiWeeklyDataArraysFromFile=readAllSurveysPerBiWeek(iAllBiWeeks,SubPlotFolderPath)

    % function to read all surveys per bi-weekly time window in the main
    % wheat season

    for k=1:length(iAllBiWeeks(1,:))

            % get bi-week, def. filename and initialize array for storing surveys
            iBiWeek=datestr(iAllBiWeeks(1,k),'mmdd');
            filename=strcat(SubPlotFolderPath,'TempFiles\Surveys',iBiWeek,'.csv');

            % read from file 
            DataArrayAll=readtable(filename);

            % convert to numeric array
            TempBiWeekArray=[];
            TempBiWeekArray(:,1)=table2array(DataArrayAll(:,1)); % year
            TempBiWeekArray(:,2)=table2array(DataArrayAll(:,2)); % month
            TempBiWeekArray(:,3)=table2array(DataArrayAll(:,3)); % day
            TempBiWeekArray(:,4)=table2array(DataArrayAll(:,4)); % latitude
            TempBiWeekArray(:,5)=table2array(DataArrayAll(:,5)); % longitude
            TempBiWeekArray(:,6)=table2array(DataArrayAll(:,6)); % severity
            TempBiWeekArray(:,7)=table2array(DataArrayAll(:,7)); % incidence
            TempBiWeekArray(:,8)=table2array(DataArrayAll(:,8)); % binary disease status (severity OR incidence >0)
            TempBiWeekArray(:,9)=table2array(DataArrayAll(:,9)); % days into the main season
            TempBiWeekArray(:,10)=table2array(DataArrayAll(:,10)); % biweeks into the season        

            AllBiWeeklyDataArraysFromFile(k,:,:)=TempBiWeekArray;

    end
end

