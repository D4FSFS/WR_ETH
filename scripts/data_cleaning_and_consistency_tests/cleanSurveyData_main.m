%%% script for checking data consistency and for cleaning the historical
%%% wheat rust survey data 
%  
% @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
% open-source under the GNU General Public License; without any WARRANTY.
%
% Overview:
% The data cleaning/consistency checking consists of the following steps: 
% 1.) sort out all missing data entries: empty, NaN,-9,0 entries
% 2.) check that disease status in expected range (and sort out if not)
% 3.) check that date in expected range (and sort out if not)
% 4.) check that lat long in expected range - within Ethiopia (and sort out if not)
% 5.) check that no points on lakes in Ethiopia (and sort out if not)
% 6.) check that no duplicates with respect to core survey entries (sort out duplicates) 
%
% summary script-structure:
%    read survey data files  
%      loop over different types of rust
%         clean and check consistency of core data entries, printing some info to a summary log-file and plotting some summary stats; 
%         write 1 "cleaned" dataset for each type of rust into a csv file 
%

% clear workspace
clear all; 
close all;

%%%%%%%%%%% 
% def paths to data and aux. data, setup results folder and helpers

% def. paths to project, data folder and data file
ProjectPath='C:\Users\marce\Desktop\FilesMM\Ethiopia_WheatRustDataRevival\wheat_rust_outbreaks_Ethiopia';
PathToDataFolder=strcat(ProjectPath,'\SurveyData\');
iDataFilename20072019=strcat(PathToDataFolder,'WheatRustSurveys_Published_2019.xlsx');

% def path to folder with resulting, cleaned data arrays
CleanDataPath=strcat(ProjectPath,'\SurveyData_cleaned\');
mkdir(CleanDataPath);

% path to a data-file with information about the administrative boundaries of
% Ethiopia for checking if the reported coordinates of surveys are located
% within Ethiopia
CountryIDRasterFilename=strcat(ProjectPath,'\AuxiliaryData\countryIDRasterLimitedExtent.txt');

% path to files with information about the locations of lakes in
% Ethiopia for making sure that no survey coordinates are located in lakes
LakeIDRasterFilename=strcat(ProjectPath,'\AuxiliaryData\lakesInEthiopia_raster.txt');
LakeIDListFilename=strcat(ProjectPath,'\AuxiliaryData\lakesInEthiopia_IDs.csv');

% def years with available data and a corresponding array for labelling figures
AllYears=2007:1:2019;
XLabelVec={'2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'};

%%%%%%%%%%
% read survey data and get total number of surveys before cleaning
DataArrayReduced=readSurveyData(iDataFilename20072019);
[TotalNumberSurveys,TotalNumberSurveysPerYear]=getNumberOfSurveysBeforeDataCleaning(DataArrayReduced,AllYears);

%%%%%%%%%%
% clean survey data. 
% data cleaning is done separately for each type of rust - Sr, Lr, Yr.
% Steps:
% 1.) sort out all missing data entries: empty, NaN,-9,0 entries
% 2.) check that disease status is in expected range
% 3.) check that date in expected range
% 4.) check that coordinates of surveys (lat, long) are in expected range - within Ethiopia
% 5.) check that no survey points are located in lakes in Ethiopia
% 6.) check that there are no duplicates (with respect to key data column entries)
 
% loop all types of wheat rust
AllRusts={'WheatStemRust','WheatLeafRust','WheatYellowRust'};
for iR=1:length(AllRusts)
    
    % get identifier for current type of rust
    RustType=AllRusts{iR};

    % write data specs to a summary/log-file
    SummaryFilename=strcat(CleanDataPath,'SummaryData_ET',RustType,'.txt');
    fidSummaryFile=fopen(SummaryFilename,'w');
    fprintf(fidSummaryFile,'Summary of data cleaning for:  %s \n\n',RustType);
    fprintf(fidSummaryFile,'General info about all surveys for all types of wheat rust\n');
    fprintf(fidSummaryFile,'Total number of survey entries any rust:  %f \n',TotalNumberSurveys);
    fprintf(fidSummaryFile,'Number of survey entries per year any rust:\n');
    for iY=1:length(AllYears)
        iYear=num2str(AllYears(iY));
        fprintf(fidSummaryFile,'%s: %f \n',iYear,TotalNumberSurveysPerYear(iY));    
    end
    fprintf(fidSummaryFile,'\nCleaning data %s \n\n',RustType);  
    
    % define the columns with data about rust infection with the type of
    % rust analysed in this iteration
    if iR==1
        colSev=11;
        colInc=12;
    elseif iR==2
        colSev=13;
        colInc=14;
    elseif iR==3
        colSev=15;
        colInc=16;
    end
    
    % define the columns for writing rust infection levels into the
    % cleaned data array
    colSevNew=11;
    colIncNew=12;
      
    
    %%%%%
    % sort out MISSING DATA
    [DataArray_cleaned1,NumberOfMissingDataPerYear]=sortOutMissingData(DataArrayReduced,colSev,colInc,colSevNew,colIncNew,AllYears);
    
    % write a summary of this step of the data cleaning to the log-file
    TotalNumberCleanDataEntries=length(DataArray_cleaned1(:,1));
    NumberSurveysSortedOut=TotalNumberSurveys-TotalNumberCleanDataEntries;
    fprintf(fidSummaryFile,' Total number of survey entries sorted out because of missing values: NaN (isnan()), 0 entry or -9 entry:  %f \n',NumberSurveysSortedOut);
    fprintf(fidSummaryFile,'Total number survey entries after sorting out missing values: %f \n',TotalNumberCleanDataEntries);
    fprintf(fidSummaryFile,'Number of missing entries (isnan,0,-9) per year:\n');
    for iY=1:length(AllYears)
        iYear=num2str(AllYears(iY));
        fprintf(fidSummaryFile,'%s: %f \n',iYear,NumberOfMissingDataPerYear(iY));       
    end
    
    
    %%%%%
    % check that the DISEASE STATUS is range defined by the survey protocol (numeric indicator in range 0-3)
    [DataArray_cleaned2,NumberOfDataUnexpectedDiseaseStatusPerYear]=sortOutUnexpectedDiseaseStatus(DataArray_cleaned1,colSevNew,colIncNew,AllYears);  
    
    % write a summary of this step of the data cleaning to the log-file
    TotalNumberCleanDataNoUnexpectedDiseaseEntries=length(DataArray_cleaned2(:,1));
    NumberSortedOutUnexpectedDisease=TotalNumberCleanDataEntries-TotalNumberCleanDataNoUnexpectedDiseaseEntries;
    fprintf(fidSummaryFile,'\n Total number of survey entries sorted out because disease status is not in expected range:  %f \n',NumberSortedOutUnexpectedDisease);
    fprintf(fidSummaryFile,'Total number of surveys after sorting out unexpected disease status:  %f \n',TotalNumberCleanDataNoUnexpectedDiseaseEntries);
    fprintf(fidSummaryFile,'Number of survey entries with unexpected disease status per year:\n');
    for iY=1:length(AllYears)
        iYear=num2str(AllYears(iY));
        fprintf(fidSummaryFile,'%s: %f \n',iYear,NumberOfDataUnexpectedDiseaseStatusPerYear(iY));       
    end

    
    %%%%%       
    % check that the DATE is in the time-interval of this study
    [DataArray_cleaned3,NumberOfDataUnexpectedDatePerYear]=sortOutUnexpectedDate(DataArray_cleaned2,colIncNew,AllYears);  
    
    % write a summary of this step of the data cleaning to the log-file
    TotalNumberCleanDataNoUnexpectedDiseaseDateEntries=length(DataArray_cleaned3(:,1));
    NumberSortedOutUnexpectedDate=TotalNumberCleanDataNoUnexpectedDiseaseEntries-TotalNumberCleanDataNoUnexpectedDiseaseDateEntries;
    fprintf(fidSummaryFile,'\n Total number of survey entries sorted out because the survey date is not in expected range:  %f \n',NumberSortedOutUnexpectedDate);
    fprintf(fidSummaryFile,'Total number of survey entries after sorting out surveys with unexpected date:  %f \n',TotalNumberCleanDataNoUnexpectedDiseaseDateEntries);
    fprintf(fidSummaryFile,'Number of survey entries with unexpected date (month, year or day out-of-bounds):\n');
    for iY=1:length(AllYears)
        iYear=num2str(AllYears(iY));
        fprintf(fidSummaryFile,'%s: %f \n',iYear,NumberOfDataUnexpectedDatePerYear(iY));       
    end
    
    
    %%%%%
    % check that survey coordinates (LAT, LON) are plausible
    [DataArray_cleaned4,NumberOfDataUnexpectedLatLongPerYear]=sortOutUnexpectedLatLong(DataArray_cleaned3,CountryIDRasterFilename,colIncNew,AllYears);  
    
    % write a summary of this step of the data cleaning to the log-file
    TotalNumberCleanDataNoUnexpectedDiseaseDateLatEntries=length(DataArray_cleaned4(:,1));
    NumberSortedOutUnexpectedLatLong=TotalNumberCleanDataNoUnexpectedDiseaseDateEntries-TotalNumberCleanDataNoUnexpectedDiseaseDateLatEntries;
    fprintf(fidSummaryFile,'\n Total number of survey entries sorted out because of (Lat, Long) is not within Ethiopia:  %f \n',NumberSortedOutUnexpectedLatLong);
    fprintf(fidSummaryFile,'Total number of survey entries after sorting out surveys outside of Ethiopia:  %f \n',TotalNumberCleanDataNoUnexpectedDiseaseDateLatEntries);
    fprintf(fidSummaryFile,'Number of entries with unexpected (Lat, Long) per year:\n');
    for iY=1:length(AllYears)
        iYear=num2str(AllYears(iY));
        fprintf(fidSummaryFile,'%s: %f \n',iYear,NumberOfDataUnexpectedLatLongPerYear(iY));
    end
    
    
    %%%%%
    % check that survey coordinates are not located in a LAKE in Ethiopia
    [DataArray_cleaned5,NumberOfDataUnexpectedLatLongLakePerYear]=sortOutLatLongInLake(DataArray_cleaned4,LakeIDRasterFilename,LakeIDListFilename,AllYears);      
   
    % write a summary of this step of the data cleaning to the log-file
    TotalNumberCleanDataNoUnexpectedDiseaseDateLatLakeEntries=length(DataArray_cleaned5(:,1));
    NumberSortedOutUnexpectedLatLong=TotalNumberCleanDataNoUnexpectedDiseaseDateLatEntries-TotalNumberCleanDataNoUnexpectedDiseaseDateLatLakeEntries;
    fprintf(fidSummaryFile,'\n Total number of survey entries sorted out because of survey coordinates are located in a lake:  %f \n',NumberSortedOutUnexpectedLatLong);
    fprintf(fidSummaryFile,'Total number of survey entries after sorting out surveys in lakes:  %f \n',TotalNumberCleanDataNoUnexpectedDiseaseDateLatLakeEntries);
    fprintf(fidSummaryFile,'Number of survey entries in lakes in Ethiopia per year:\n');
    for iY=1:length(AllYears)
        iYear=num2str(AllYears(iY));
        fprintf(fidSummaryFile,'%s: %f \n',iYear,NumberOfDataUnexpectedLatLongLakePerYear(iY));       
    end
       
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % check for DUPLICATES with respect to key data attributes
    [DataArray_cleaned6,DataArray_cleaned6_numeric,NumberOfDataDuplicatesPerYear]=sortOutDuplicates(DataArray_cleaned5,AllYears);  
       
    % write a summary of this step of the data cleaning to the log-file
    TotalNumberCleanEntries=length(DataArray_cleaned6(:,1));
    TotalNumberDuplicates=TotalNumberCleanDataNoUnexpectedDiseaseDateLatLakeEntries-TotalNumberCleanEntries;
    fprintf(fidSummaryFile,'\n Total number of survey entries sorted out because they are duplicates (with respect to information in key columns selected here):  %f \n',TotalNumberDuplicates);
    fprintf(fidSummaryFile,'Total number of survey entries after sorting out duplicates:  %f \n',TotalNumberCleanEntries);
    fprintf(fidSummaryFile,'Number of duplicates per year (w.r.t. entries in columns: year, month, day, lat, long, sev, inc):\n');
    for iY=1:length(AllYears)
        iYear=num2str(AllYears(iY));
        fprintf(fidSummaryFile,'%s: %f \n',iYear,NumberOfDataDuplicatesPerYear(iY));       
    end
    
    %%%%%
    % get a summary of the data cleaning (how many entries per year) for this type of rust and write to file   
    fprintf(fidSummaryFile,'\n From total of %f there are %f remaining as cleaned data entries (corresponding to %f percent)\n',TotalNumberSurveys,TotalNumberCleanEntries,(TotalNumberCleanEntries/TotalNumberSurveys));
    % number of surveys per year after cleaning up
    NumberOfCleanDataEntriesPerYear=zeros(1,length(AllYears(1,:)));
    for iD=2:length(DataArray_cleaned6(:,1))
        % get year 
        iYear=DataArray_cleaned6{iD,2};
        % count entries per year
        for iY=1:length(AllYears(1,:))
            checkYear=AllYears(iY);
            if iYear==checkYear
                NumberOfCleanDataEntriesPerYear(iY)=NumberOfCleanDataEntriesPerYear(iY)+1;
            end
        end
    end
    fprintf(fidSummaryFile,'Number of clean data entries per year: \n');
    TotalNumberOfCleanSurveys20102019=0;
    for iY=1:length(AllYears)
        iYear=num2str(AllYears(iY));
        fprintf(fidSummaryFile,'%s: %f \n',iYear,NumberOfCleanDataEntriesPerYear(iY));   
        if AllYears(iY)>=2010
            TotalNumberOfCleanSurveys20102019=TotalNumberOfCleanSurveys20102019+NumberOfCleanDataEntriesPerYear(iY);
        end
    end
    fprintf(fidSummaryFile,'\n after sorting out data for years 2007-2009, there are %f remaining data entries\n',TotalNumberOfCleanSurveys20102019);
    fclose(fidSummaryFile);
    
    
    %%%%%%%%%%
    % plot figures summarizing the data cleaning
    
    % figure: total number of surveys and clean surveys per year
    figure
    bar(TotalNumberSurveysPerYear,'r')
    hold on
    bar(NumberOfCleanDataEntriesPerYear,'b')
    set(gca,'XTickLabel',XLabelVec,'XLim',[0,length(XLabelVec)+1]);
    rotateXLabels(gca(),45);
    xlabel('Year of Surveys');
    ylabel('Number of Survey Entries (r:all;b:cleaned)');
    figName=strcat(CleanDataPath,'NumberSurveysPerYear_ET',RustType,'.png');
    print(figName,'-dpng','-r300');
       
    % figure: types of cleaning - number of surveys sorted out per year
    AllDataTypesPerYear=[NumberOfCleanDataEntriesPerYear;NumberOfMissingDataPerYear;NumberOfDataDuplicatesPerYear;NumberOfDataUnexpectedDiseaseStatusPerYear;NumberOfDataUnexpectedLatLongPerYear;NumberOfDataUnexpectedDatePerYear];
    TotalsPerYear=sum(AllDataTypesPerYear(:,:),1);
    DoubleCheck=TotalsPerYear-TotalNumberSurveysPerYear;
    figure
    H=bar(AllDataTypesPerYear','stacked');
    set(gca,'XTickLabel',XLabelVec,'XLim',[0,length(XLabelVec)+1]);
    rotateXLabels(gca(),45);
    xlabel(strcat('Year of Surveys:',RustType));
    ylabel('Number of Survey Entries');
    legend(H,{'Clean data (disease status)','N/A or 0 or -9 or empty','duplicates','unexpected disease status','unexpected lat-long','unexptected date'},'Location','Best');
    figName=strcat(CleanDataPath,'NumberSurveyTypesPerYear_ET_',RustType,'.png');
    print(figName,'-dpng','-r300');
    
    
    %%%%%%%%%%
    % write the cleaned data array to file 
       
    % add one additional column with dichotimized disease status
    for i=1:length(DataArray_cleaned6_numeric(:,1))
        if ((DataArray_cleaned6_numeric(i,6) >0) || (DataArray_cleaned6_numeric(i,7) >0))
            DataArray_cleaned6_numeric(i,8)=1;
        else
            DataArray_cleaned6_numeric(i,8)=0;
        end
    end
    CleanedSurveyDataFilename=strcat(CleanDataPath,'CleanSurveyDataNumeric_ET_',RustType,'.csv');
    fid=fopen(CleanedSurveyDataFilename,'w');
    fprintf(fid,strcat('Year, Month, Day, Latitude, Longitude, Rust Severity:',RustType,', Rust Incidence:',RustType,', Binary disease presence  \n'));
    fclose(fid);
    dlmwrite(CleanedSurveyDataFilename,DataArray_cleaned6_numeric,'-append','delimiter',',');

    % write the same clean data file with additional attributes of
    % different types
    for i=1:length(DataArray_cleaned6(:,1))
        if i==1
            DataArray_cleaned6{i,13}='Binary disease presence';
        else 
            if ((DataArray_cleaned6{i,11} >0) || (DataArray_cleaned6{i,12} >0))
                DataArray_cleaned6{i,13}=1;
            else
                DataArray_cleaned6{i,13}=0;
            end
        end
    end 
    % in some of the survey entries for wheat variety names there is a comma which screws up the writing
    % to file, and needs to be handled here
    for i=2:length(DataArray_cleaned6(:,1))
        iVarName=DataArray_cleaned6{i,9};
        if ischar(iVarName)
            SplitVarName=strsplit(iVarName,',');
            if length(SplitVarName(1,:))>1
                iVarNameNew=SplitVarName(1,1);
                DataArray_cleaned6{i,9}=char(iVarNameNew);
                disp(num2str(i));
            end
        end
    end
    CleanedSurveyDataLongFilename=strcat(CleanDataPath,'CleanSurveyDataWithAdditionals_ET',RustType,'.csv');
    fid2=fopen(CleanedSurveyDataLongFilename,'w');
    fprintf(fid2,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',DataArray_cleaned6{1,:});
    for i=2:length(DataArray_cleaned6(:,1))
        fprintf(fid2,'%s,%d,%d,%d,%.4f,%.4f,%d,%d,%s,%d,%d,%d,%d\n',DataArray_cleaned6{i,:});
    end
    fclose(fid2);

end % end of loop over types of wheat rust

