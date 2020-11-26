% script for writing the survey data into a set of .csv files which are used 
% as input by the R scripts for mapping the point surveys
%  
% @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
% open-source under the GNU General Public License; without any WARRANTY.
%
% summary:
% - read the data file with all clean surveys per wheat variety
% - sub-divide the data into time-intervals and print one .csv file per
%   time-interval 

clear all;
close all;

% Def. paths and setup results folder
ProjectPath='C:\Users\marce\Desktop\FilesMM\Ethiopia_WheatRustDataRevival\wheat_rust_outbreaks_Ethiopia';
PathToCleanDataFolder=strcat(ProjectPath,'\SurveyData_cleaned\');
PlotFilePath=strcat(ProjectPath,'\Results\CSVFilesForMapping\');
mkdir(PlotFilePath);

% loop over types of wheat rust, read cleaned survey data
% and print it out to a set of .csv files (one file per time-interval)
AllRusts={'WheatStemRust','WheatLeafRust','WheatYellowRust'};
iAllRustAbbr={'Sr','Lr','Yr'};
for iR=1:length(AllRusts)
    
    % get identifier of the type of rust in this iteration
    RustType=AllRusts{iR};
    iRustStr=iAllRustAbbr{iR};

    % create directory for results
    SubPlotFolderPath=strcat(PlotFilePath,iRustStr,'\');
    mkdir(SubPlotFolderPath); 
    
    % read the cleaned data set
    CleanFieldDiseaseSurveyData=strcat(PathToCleanDataFolder,'CleanSurveyDataNumeric_ET_',RustType,'.csv');
    DataArrayAll=readtable(CleanFieldDiseaseSurveyData);
    
    % convert to numeric array
    SurveyDataEthiopiaReducedNumeric=[];
    SurveyDataEthiopiaReducedNumeric(:,1)=table2array(DataArrayAll(:,1)); % year
    SurveyDataEthiopiaReducedNumeric(:,2)=table2array(DataArrayAll(:,2)); % month
    SurveyDataEthiopiaReducedNumeric(:,3)=table2array(DataArrayAll(:,3)); % day
    SurveyDataEthiopiaReducedNumeric(:,4)=table2array(DataArrayAll(:,4)); % latitude
    SurveyDataEthiopiaReducedNumeric(:,5)=table2array(DataArrayAll(:,5)); % longitude
    SurveyDataEthiopiaReducedNumeric(:,6)=table2array(DataArrayAll(:,6)); % severity
    SurveyDataEthiopiaReducedNumeric(:,7)=table2array(DataArrayAll(:,7)); % incidence
    SurveyDataEthiopiaReducedNumeric(:,8)=table2array(DataArrayAll(:,8)); % binary disease status (severity OR incidence >0)
    
    % write yearly survey data (all main season surveys) 
    AllYears={'2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'};
    AllYearNumbers=[2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019];
    AllYearlyData=[];
    iYearlyEntryCounter=1; 
    % separate surveys of the main wheat season in each year
    for iyear=1:length(AllYears)
        thisYear=AllYearNumbers(iyear);
        for iEntry=1:length(SurveyDataEthiopiaReducedNumeric(:,1))
            if (SurveyDataEthiopiaReducedNumeric(iEntry,1)==thisYear) && (SurveyDataEthiopiaReducedNumeric(iEntry,2)>=8 && SurveyDataEthiopiaReducedNumeric(iEntry,2)<=12)
                AllYearlyData(iyear,iYearlyEntryCounter,:)=SurveyDataEthiopiaReducedNumeric(iEntry,:);
                iYearlyEntryCounter=iYearlyEntryCounter+1;
            end
        end
        iYearlyEntryCounter=1;
    end
    % write to csv file
    for iYear=1:length(AllYears)
        Year=AllYears{iYear};
        iYearlyFilename=strcat(SubPlotFolderPath,'YearlyMeher_',iRustStr,'_ET_',Year,'.csv');
        Helper=squeeze(AllYearlyData(iYear,:,:));
        % get rid of the rows containing zeros for padding at the end of the array 
        Helper(all(Helper==0,2),:)=[];
        Helper(all(Helper==-9999,2),:)=[];
        if isempty(Helper)
                Helper(1,:)=[-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999];
        end
        fid=fopen(iYearlyFilename,'w');
        fprintf(fid,strcat('Year, Month, Day, Latitude, Longitude,',RustType,'Severity,',RustType,' Incidence, Disease presence  \n'));
        fclose(fid);
        dlmwrite(iYearlyFilename,Helper,'-append','delimiter',',');
    end
    
    % write monthly data - i.e. all data in a certain month, aggregating data from all years
    AllMonths=[1:1:12];
    AllMonthlyData=[];
    iMonthlyEntryCounter=1; 
    for imonth=1:length(AllMonths)
        thisMonth=AllMonths(imonth);
        for iEntry=1:length(SurveyDataEthiopiaReducedNumeric(:,1))
            if SurveyDataEthiopiaReducedNumeric(iEntry,2)==thisMonth
                AllMonthlyData(imonth,iMonthlyEntryCounter,:)=SurveyDataEthiopiaReducedNumeric(iEntry,:);
                iMonthlyEntryCounter=iMonthlyEntryCounter+1;
            end
        end
        iMonthlyEntryCounter=1;
    end
    % write to csv file
    for iM=1:length(AllMonths)
        iMonthlyFilename=strcat(SubPlotFolderPath,'Monthly_',iRustStr,'_ET_',num2str(iM),'.csv');
        Helper=squeeze(AllMonthlyData(iM,:,:));
        % get rid of the rows containing zeros for padding at the end of the array 
        Helper(all(Helper==0,2),:)=[];
        Helper(all(Helper==-9999,2),:)=[];
        if isempty(Helper)
                Helper(1,:)=[-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999];
        end
        fid=fopen(iMonthlyFilename,'w');
        fprintf(fid,strcat('Year, Month, Day, Latitude, Longitude,',RustType,'Severity,',RustType,' Incidence, Disease presence  \n'));
        fclose(fid);
        dlmwrite(iMonthlyFilename,Helper,'-append','delimiter',',');
    end   
    
    %%% write cumulative monthly data - i.e. all data in certain month, aggregating data from all years
    AllMonths=[1:1:12];
    CumMonthlyData=[];
     
    % separate surveys according to main season in each year
    for imonth=8:length(AllMonths)
        thisMonth=AllMonths(imonth);
        AllMonthlyData=[];
        iMonthlyEntryCounter=1;
        for iEntry=1:length(SurveyDataEthiopiaReducedNumeric(:,1))
            if SurveyDataEthiopiaReducedNumeric(iEntry,2)==thisMonth
                AllMonthlyData(iMonthlyEntryCounter,:)=SurveyDataEthiopiaReducedNumeric(iEntry,:);
                iMonthlyEntryCounter=iMonthlyEntryCounter+1;
            end
        end
        
        % get cumulative monthly data array
        CumMonthlyData=[CumMonthlyData;AllMonthlyData];
    
        % write to csv file
        iMonthlyFilename=strcat(SubPlotFolderPath,'CumMonthly_',iRustStr,'_ET_',num2str(thisMonth),'.csv');
        fid=fopen(iMonthlyFilename,'w');
        fprintf(fid,strcat('Year, Month, Day, Latitude, Longitude,',RustType,'Severity,',RustType,' Incidence, Disease presence  \n'));
        fclose(fid);
        dlmwrite(iMonthlyFilename,CumMonthlyData,'-append','delimiter',',');
    end   
    
        
    % print surveys per bi-weekly time-interval
     
    % create directories fo results
    PlotFilePathBiWeekly=strcat(SubPlotFolderPath,'\BiWeekly\');
    mkdir(PlotFilePathBiWeekly);    
    PlotFilePathCumBiWeekly=strcat(SubPlotFolderPath,'\CumBiWeekly\');
    mkdir(PlotFilePathCumBiWeekly);
    
    % def. time-domain; start mid march - beginning of Belg season
    StartDateString=strcat('2007-03-15');
    EndDateString=strcat('2019-12-31');
    StartDate=datetime(StartDateString,'InputFormat','uuuu-MM-dd');
    EndDate=datetime(EndDateString,'InputFormat','uuuu-MM-dd');
        
    % initialize survey data array for cumulative bi-weekly data per season
    IterativeCumBiWeeklyData=[];
    
    % define start date
    iDate=StartDate;     
    StartOfSeasonDate=StartDate;
    while iDate<EndDate
        
        % def. 14 day intervall
        iStartDateIntervall=iDate;
        iEndDateIntervall=iDate+caldays(13);
        
        % initialize data array to store all surveys in this time-intervall
        IterativeBiWeeklyData=[];
     
        % keep track
        disp(strcat('printing:',RustType,', start of bi-week intervall:', datestr(iStartDateIntervall), ', end of bi-week intervall:', datestr(iEndDateIntervall)));
        
        % get all survey data entries per time-intervall
        SurveysPerBiWeek=1;
        for iDataEntry=1:length(SurveyDataEthiopiaReducedNumeric(:,2))
            YearOfSurvey=SurveyDataEthiopiaReducedNumeric(iDataEntry,1);
            MonthOfSurvey=SurveyDataEthiopiaReducedNumeric(iDataEntry,2);
            DayOfSurvey=SurveyDataEthiopiaReducedNumeric(iDataEntry,3);
            iDateOfSurvey=datetime(YearOfSurvey,MonthOfSurvey,DayOfSurvey);
            % isbetween tests: tlower<=t<=tupper
            if isbetween(iDateOfSurvey,iStartDateIntervall,iEndDateIntervall)
                IterativeBiWeeklyData(SurveysPerBiWeek,:)=SurveyDataEthiopiaReducedNumeric(iDataEntry,:);
                SurveysPerBiWeek=SurveysPerBiWeek+1;
            end
        end
        
        % print bi-weekly data arrays to file
        iBiWeeklyFilename=strcat(PlotFilePathBiWeekly,'BiWeekly_',datestr(iStartDateIntervall,'yyyy-mm-dd'),'_',datestr(iEndDateIntervall,'yyyy-mm-dd'),'_',iRustStr,'.csv');
        fid=fopen(iBiWeeklyFilename,'w');
        fprintf(fid,strcat('Year, Month, Day, Latitude, Longitude,',RustType,'Severity,',RustType,' Incidence, Disease presence  \n'));
        fclose(fid);
        if isempty(IterativeBiWeeklyData)
            Helper=[];
            Helper(1,:)=[-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999];
            dlmwrite(iBiWeeklyFilename,Helper,'-append','delimiter',',');
        else
            dlmwrite(iBiWeeklyFilename,IterativeBiWeeklyData,'-append','delimiter',',');
        end
        
        % get cumulative bi-weekly data array
        IterativeCumBiWeeklyData=[IterativeCumBiWeeklyData;IterativeBiWeeklyData];
        
        % print to file
        iCumBiWeeklyFilename=strcat(PlotFilePathCumBiWeekly,'CumBiWeekly',datestr(StartOfSeasonDate,'yyyy-mm-dd'),'_',datestr(iEndDateIntervall,'yyyy-mm-dd'),'_',iRustStr,'.csv');
        fid=fopen(iCumBiWeeklyFilename,'w');
        fprintf(fid,strcat('Year, Month, Day, Latitude, Longitude,',RustType,'Severity,',RustType,' Incidence, Disease presence  \n'));
        fclose(fid);
        if isempty(IterativeCumBiWeeklyData)
            Helper=[];
            Helper(1,:)=[-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999];
            dlmwrite(iCumBiWeeklyFilename,Helper,'-append','delimiter',',');
        else
            dlmwrite(iCumBiWeeklyFilename,IterativeCumBiWeeklyData,'-append','delimiter',',');
        end
                
        % iterate bi-weeks
        iDate=iDate+caldays(14);
        
        % re-set the cumulative bi-weekly array such that it re-starts 
        % at the beginning of each minor/Belg season and at the beginning of each main/Meher season.
        % the minor/Belg season is assumed to last from mid March until July and
        % the main/Meher season is assumed to last from August until mid
        % March for the purpose of mapping all surveys.
        % On most areas the main wheat season ends in Nov/Dec.
        iYear=year(iEndDateIntervall);
        
        % re-set if the end of the belg season is reached
        ResetStartDateBelg=datetime(strcat(num2str(iYear),'-07-22'));
        ResetEndDateBelg=datetime(strcat(num2str(iYear),'-08-04'));
        if isbetween(iEndDateIntervall,ResetStartDateBelg,ResetEndDateBelg)
            IterativeCumBiWeeklyData=[];
            StartOfSeasonDate=iDate;
        end
        
        % reset if the end of the meher season is reached
        ResetStartDateMeher=datetime(strcat(num2str(iYear),'-02-15'));
        ResetEndDateMeher=datetime(strcat(num2str(iYear),'-02-28'));
        if isbetween(iEndDateIntervall,ResetStartDateMeher,ResetEndDateMeher)
            IterativeCumBiWeeklyData=[];
            StartOfSeasonDate=iDate;
        end               
       
    end % end while loop over time-interval of field campaign
 
end