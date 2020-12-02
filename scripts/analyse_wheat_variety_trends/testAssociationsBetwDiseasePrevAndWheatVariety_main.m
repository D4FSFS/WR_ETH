% script for analysing associations between wheat rust disease prevalence 
% and wheat varieties in Ethiopia
%
% @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
%
% summary script-structure:
% For all types of wheat rust
%    read the cleaned survey data
%    conduct additional consistency and cleaning for the data entries in the
%    attribute "wheat variety" 
%    group all surveys according to the wheat variety reported in surveys
%    (this requires accounting for different spellings of wheat varieties
%    by different surveyors; restricting the analysis here to the most
%    frequent varieties and including a group consisting of surveys on 
%    all other wheat varieites
%    For both wheat seasons (Meher, Belg)
%       For both disease measures (severity and incidence)
%          count prevalence scores per wheat variety
%          For a selection of key varieties (e.g. Digalu) analyse interannual variations in prevalence 
%          for comparison with the time of incursion of novel strains into
%          Ethiopia
%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear workspace
clear all;
close all;  
   
% define paths and setup results folder
ProjectPath='C:\Users\marce\Desktop\FilesMM\Ethiopia_WheatRustDataRevival\wheat_rusts_Ethiopia';
PathToCleanDataFolder=strcat(ProjectPath,'\SurveyData_cleaned\');
PlotFilePath=strcat(ProjectPath,'\Results\WheatVarietyCorrelation\');
mkdir(PlotFilePath);

% add path to helper functions
addpath(genpath(strcat(ProjectPath,'\Scripts\Utils\')));

% loop all three wheat rusts 
AllRusts={'WheatStemRust','WheatLeafRust','WheatYellowRust'};
iAllRustAbbr={'Sr','Lr','Yr'};
for iR=1:length(AllRusts)
    
    % get identifier for type of rust
    RustType=AllRusts{iR};
    iRustStr=iAllRustAbbr{iR};

    % create plot directory
    SubPlotFolderPath=strcat(PlotFilePath,RustType,'\');
    mkdir(SubPlotFolderPath);
    
    % read the cleaned data set
    CleanFieldDiseaseSurveyData=strcat(PathToCleanDataFolder,'CleanSurveyDataWithAdditionals_ET',RustType,'.csv');
    DataArrayAll = convertFromNumericToCellDataArray(CleanFieldDiseaseSurveyData);
    
    % define rust-specific color for figures
    colorsBarChart = defineColorsForDifferentRusts(iRustStr);    
    
    % check consistency of survey entries in column "wheat variety", as these
    % have not been cleaned in the initial generic cleaning scripts
    iSurveyDataCleaned={};
    iSurveyDataCleaned=cleanWheatVarietyEntries(DataArrayAll,RustType,SubPlotFolderPath);
    
    % count the number of survey entries that have been sorted out because
    % of missing entries
    NumSortedOut=length(DataArrayAll(:,1))-length(iSurveyDataCleaned(:,1));
    disp([RustType,': number surveys sorted out because not valid wheat variety entry: ' num2str(NumSortedOut)]);
    disp([RustType,': ',num2str(NumSortedOut/length(DataArrayAll(:,1))),' of the total: ',num2str(length(DataArrayAll(:,1)))]);     
    
    % get the number of unique character-strings in the data-attribute "wheat variety" 
    UniqueVarietyNames=unique(iSurveyDataCleaned(:,9));
     
    % count all unique strings to find the most frequent varieties
    VarietyCounterAll=zeros(length(UniqueVarietyNames),1);
    for iS=1:length(iSurveyDataCleaned(:,1))
        iWheatVariety=iSurveyDataCleaned{iS,9};
        for iWV=1:length(UniqueVarietyNames)
            iWheatVarietyName=UniqueVarietyNames(iWV);
            if strcmp(iWheatVariety,iWheatVarietyName)
                VarietyCounterAll(iWV)=VarietyCounterAll(iWV)+1;
            end
        end
    end
    
    % sort varieties by frequency of occurence
    [SortedVarietyCounter,IndexVariety]=sort(VarietyCounterAll,'descend');
    SortedVarietyNames=UniqueVarietyNames(IndexVariety);
        
    % analyse disease prevalence on the most frequent wheat varieties as
    % well as for the categories "local" and "improved". Add a category
    % "non-classified" for all other varieties
    VarietyNames={'Local','improved','Kubsa','Digalu','Kakaba','Ogolcho','Dandaa','not-classified'};
    VarietyNumericIDs=[1:1:(length(VarietyNames)-1),-9];  % set not classified to -9
          
    % group the surveys by wheat variety (taking into consideration
    % different types of spellings for similar varieties (e.g. "Digalu"
    % and "digelu") and count surveys per variety
    iSurveyDataCleanedWithVarietyGroups={};
    [SurveyDatawVariety,VarietyCounter]=groupSurveysByWheatVariety(iSurveyDataCleaned,VarietyNames);     
     
     % get separate data arrays for Belg and Meher wheat season 2010-2019
     % Meher season
     iSurveyDataMeher=[];
     count=0;
     for iS=1:length(SurveyDatawVariety(:,1))
         iYear=SurveyDatawVariety(iS,1);
         iMonth=SurveyDatawVariety(iS,2);
         if (iYear>=2010 && iYear<=2019) && (iMonth>=8 && iMonth<=12)
             count=count+1;
             iSurveyDataMeher(count,:)=SurveyDatawVariety(iS,:);
         end
     end
        
     % Belg season
     iSurveyDataBelg=[];
     count=0;
     for iS=1:length(SurveyDatawVariety(:,1))
         iYear=SurveyDatawVariety(iS,1);
         iMonth=SurveyDatawVariety(iS,2);
         if (iYear>=2010 && iYear<=2019) && (iMonth>=3 && iMonth<=7)
             count=count+1;
             iSurveyDataBelg(count,:)=SurveyDatawVariety(iS,:);
         end
     end
       
     % loop wheat seasons
     Seasons={'Belg_MarJul','Meher_AugDec'};
     for iS=1:length(Seasons)
         
         iSeasonStr=Seasons{iS};
         
         iSurveyData=[];
         if iS==1
             iSurveyData=iSurveyDataBelg;
         elseif iS==2
             iSurveyData=iSurveyDataMeher;
         end
         
         % loop disease scores (for separate analysis of severity and incidence scores)
         DiseaseMeasure={'Sev','Inc'};
         DisStrLegend={'severity','incidence'};
         for iD=1:length(DiseaseMeasure)
             iDiseaseStr=DiseaseMeasure{iD};
             iDisStrLeg=DisStrLegend{iD};
             if strcmp(iDiseaseStr,'Sev')
                 icolD=6;
             elseif strcmp(iDiseaseStr,'Inc')
                 icolD=7;
             end
             
             % aggregate surveys per wheat variety, counting the number of surveys with low, medium and
             % high disease prevalence per vareity
             NumberSurveysPerWheatVariety=[];
             DiseaseCountsPerWheatVariety=[];
             [NumberSurveysPerWheatVariety,DiseaseCountsPerWheatVariety]=aggregateSurveysPerWheatVariety(iSurveyData,icolD,VarietyNumericIDs);
             
             % calculate and plot the proportions of low/medium/high disease
             % level per wheat variety
             ProportionIncidenceLow=[];
             ProportionIncidenceMed=[];
             ProportionIncidenceHigh=[];
             ProportionIncidenceNegative=[];
             for iA=1:length(VarietyNumericIDs)
                iNumS=NumberSurveysPerWheatVariety(iA);
                if iNumS>0
                    ProportionIncidenceLow(iA)=DiseaseCountsPerWheatVariety(iA,2)./ NumberSurveysPerWheatVariety(iA);
                    ProportionIncidenceMed(iA)=DiseaseCountsPerWheatVariety(iA,3)./ NumberSurveysPerWheatVariety(iA);
                    ProportionIncidenceHigh(iA)=DiseaseCountsPerWheatVariety(iA,4)./ NumberSurveysPerWheatVariety(iA);
                    ProportionIncidenceNegative(iA)=DiseaseCountsPerWheatVariety(iA,1)./NumberSurveysPerWheatVariety(iA);
                else
                    ProportionIncidenceLow(iA)=0;
                    ProportionIncidenceMed(iA)=0;
                    ProportionIncidenceHigh(iA)=0;
                    ProportionIncidenceNegative(iA)=0;
                end
            end
            
            % combine all three props one array for plotting stacked histogram
            AllProps=[];
            AllProps(:,4)=ProportionIncidenceNegative;
            AllProps(:,3)=ProportionIncidenceLow;
            AllProps(:,2)=ProportionIncidenceMed;
            AllProps(:,1)=ProportionIncidenceHigh;
            
            % change order of bars for plotting 
            VarietyNamesReordered={'Kubsa','Digalu','Kakaba','Ogolcho','Dandaa','Local','Improved','All others'};
            AllPropsReordered=[];
            NumberSurveysPerWheatVarietyReordered=[];
            [AllPropsReordered,NumberSurveysPerWheatVarietyReordered]=reorderWheatVarietiesForPlotting(AllProps,NumberSurveysPerWheatVariety);
     
            % plot disease prevalence per wheat variety
            figName=strcat(SubPlotFolderPath,RustType,'_ProbDiseasePerWheatVar_',iDiseaseStr,'_',iSeasonStr,'.png');
            plotPrevalencePerVarietyBarChart(AllPropsReordered,NumberSurveysPerWheatVarietyReordered,VarietyNamesReordered,VarietyNumericIDs,colorsBarChart,iRustStr,iDisStrLeg,figName);
            
            % test if disease prevalence is independent of wheat variety
            fileName=strcat(SubPlotFolderPath,RustType,'_ChiSquareTest_',iDiseaseStr,'_',iSeasonStr,'.txt');
            testIndependenceOfPrevalenceAndWheatVariety(iSurveyData,VarietyNames,VarietyNumericIDs,icolD,fileName);            
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % plot prevalence levels for each year and wheat variety
            for iA=1:length(VarietyNumericIDs)
                
                % get Name and ID of the wheat variety in this iteration
                WVarID=VarietyNumericIDs(iA);
                WVarName=VarietyNames{iA};
                
                % create plot directory
                WVarPlotFolderPath=strcat(SubPlotFolderPath,WVarName,'\');
                mkdir(WVarPlotFolderPath);
                
                % get all surveys for this wheat variety (WVarID)
                AllSurveysPerWheatVariety=[];
                count=1;
                for i=1:length(iSurveyData(:,1))
                    iWVar=iSurveyData(i,8);
                    if iWVar==WVarID
                        AllSurveysPerWheatVariety(count,:)=iSurveyData(i,:);
                        count=count+1;
                    end
                end
                
                % if there are any surveys for this wheat variety,
                % aggregate per year and count disease occurences
                if ~isempty(AllSurveysPerWheatVariety)
                     AllYears=[2010,2011,2012,2013,2014,2015,2016,2017,2018,2019];
                    [NumberSurveysPerWheatVarietyPerYear,DiseaseCountsPerWheatVarietyPerYear] = aggregateSurveysPerWheatVarietyPerYear(AllSurveysPerWheatVariety,icolD,VarietyNumericIDs,AllYears);
                                                
                    % calculate and plot the proportions of low/medium/high disease
                    % levels per wheat variety
                    ProportionIncidenceLow=[];
                    ProportionIncidenceMed=[];
                    ProportionIncidenceHigh=[];
                    ProportionIncidenceNegative=[];
                    for iA=1:length(AllYears)
                        iNumS=NumberSurveysPerWheatVarietyPerYear(iA);
                        if iNumS>0
                            ProportionIncidenceLow(iA)=DiseaseCountsPerWheatVarietyPerYear(iA,2)./ NumberSurveysPerWheatVarietyPerYear(iA);
                            ProportionIncidenceMed(iA)=DiseaseCountsPerWheatVarietyPerYear(iA,3)./ NumberSurveysPerWheatVarietyPerYear(iA);
                            ProportionIncidenceHigh(iA)=DiseaseCountsPerWheatVarietyPerYear(iA,4)./ NumberSurveysPerWheatVarietyPerYear(iA);
                            ProportionIncidenceNegative(iA)=DiseaseCountsPerWheatVarietyPerYear(iA,1)./NumberSurveysPerWheatVarietyPerYear(iA);
                        else
                            ProportionIncidenceLow(iA)=0;
                            ProportionIncidenceMed(iA)=0;
                            ProportionIncidenceHigh(iA)=0;
                            ProportionIncidenceNegative(iA)=0;
                        end
                    end

                    % combine all three props one array for plotting stacked histogram
                    AllProps=[];
                    AllProps(:,3)=ProportionIncidenceLow;
                    AllProps(:,2)=ProportionIncidenceMed;
                    AllProps(:,1)=ProportionIncidenceHigh;

                    % plot...
                    figure
                    
                    % bar charts
                    b=bar(AllProps,'stacked','BarWidth',0.7);
                    
                    % set grid lines
                    grid on
                    
                    % set colors of bars
                    b(1).FaceColor=colorsBarChart(3,:); % high in darker at bottom
                    b(2).FaceColor=colorsBarChart(2,:);
                    b(3).FaceColor=colorsBarChart(1,:); % low in lighter at top
                    b(1).FaceAlpha=0.5;
                    b(2).FaceAlpha=0.5;
                    b(3).FaceAlpha=0.5;
                    
                    % set y-labels and limits
                    ylabel(strcat('prevalence'));
                    set(gca,'YLim',[0,1]);                    
                    
                    % set x-labels and limits and ticks
                    xlabel('year')
                    set(gca,'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'},'XLim',[0,11]);
                    rotateXLabels(gca(),45);

                    % write number of surveys on top of axis
                    XTickTopVec={};
                    for i=1:length(AllYears)
                        XTickTopVec{i}=['n=',num2str(NumberSurveysPerWheatVarietyPerYear(i))];
                    end
                    xt = get(gca, 'XTick');
                    y=ones(1,length(AllYears))+0.13;
                    t=text(xt,y,XTickTopVec,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',12);
                    set(t,'Rotation',45);
                    
                    % set legend
                    legend([b(3),b(2),b(1)],[iRustStr,' ','low',' ',iDisStrLeg],[iRustStr,' ','moderate',' ',iDisStrLeg],[iRustStr,' ','high',' ',iDisStrLeg],'FontSize',10,'Location','NorthWest');
                    
                    % set size / margin ratio
                    pos = get(gca, 'Position');
                    pos(4) = 0.7;
                    set(gca, 'Position', pos)

                    % print to file
                    figName=strcat(WVarPlotFolderPath,iRustStr,'_ProbDis_',WVarName,'_',iDiseaseStr,'_',iSeasonStr,'.png');
                    print(figName,'-dpng','-r300');
                    close all;
                
                end % end of checker for empty survey array per wheat variety
            end % end loop over wheat varieties for interannual plots     
         end % end loop over disease scores
     end % end loop over wheat seasons
end % end loop types of wheat rust
