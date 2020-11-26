% script to test the performance of two simple empirical models (logistic curves) for predicting wheat rust disease
% outbreaks in Ethiopia
%
% @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
%
% summary script-structure: 
%   for all three types of wheat rust
%       read clean survey data and get subset of data for the main wheat season
%       get time-duration into the main wheat season for each survey entry
%       for both disease measures (incidence and severity) 
%           use all survey data to
%                 fit a uni-variate, 3-parameter logistic curve to survey data (with time-duration into the main wheat season as 
%                 the independent variable) and calculate model performance (accuracy, ROC curve, etc.)
%                 fit a multi-variate, single parameter logistic curve to the survey data (with time, latitude, longitude and altitude as
%                 independent variables) and calculate model performance
%           separate survey data into "training" and "test" data (use all years but 1 as training data and the other year as testdata 
%               repeat iterating through all 10 years as "test-data" for cross-validation
%                     use training data to fit the two logistic curven and
%                     test performance on test-data
%           Calculate average performance scores from all training/test iterations 
%           Plot interannual variations of AUC score and of ROC curves for each training/test run 
%           interannual variations in model predictive performance
%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear workspace
clear all;
close all;

% define paths and setup results folder
ProjectPath='C:\Users\marce\Desktop\FilesMM\Ethiopia_WheatRustDataRevival\wheat_rusts_Ethiopia';
PathToCleanDataFolder=strcat(ProjectPath,'\SurveyData_cleaned\');
PlotFilePath=strcat(ProjectPath,'\Results\TestLogisticModelPredictions\');
mkdir(PlotFilePath);

% add paths to some additional required helper functions
addpath(genpath(strcat(ProjectPath,'\Scripts\AltitudeCorrelation')));
addpath(genpath(strcat(ProjectPath,'\Scripts\WithinSeasonDiseaseProgress')));
addpath(genpath(strcat(ProjectPath,'\Scripts\Utils\')));

% define start dates of bi-weekly time-intervalls as temporal bins
AllYears=[2010,2011,2012,2013,2014,2015,2016,2017,2018,2019];

% initialize array to store the glm-object (generalized linear model) for each rust
AllModels={};

% loop all three wheat rusts
AllRusts={'WheatStemRust','WheatLeafRust','WheatYellowRust'};
iAllRustAbbr={'Sr','Lr','Yr'};
for iR=1:length(AllRusts)
    
    % get identifier for type of rust
    RustType=AllRusts{iR};
    iRustStr=iAllRustAbbr{iR};

    % create directory for figures/results
    SubPlotFolderPath=strcat(PlotFilePath,RustType,'\');
    mkdir(SubPlotFolderPath);
    
    % read the cleaned data set
    CleanDataFileName=strcat(PathToCleanDataFolder,'CleanSurveyDataWithAdditionals_ET',RustType,'.csv');
    DataArrayAll=readCleanSurveyData(CleanDataFileName);
        
    % check and clean altitude entries
    CleanEthiopiaDataArray={};
    CleanEthiopiaDataArray=cleanAltitudeEntries(DataArrayAll,RustType,SubPlotFolderPath);
    
    % convert to numeric array
    SurveyDataEthiopiaReducedNumeric=convertDataArrayToNumeric(CleanEthiopiaDataArray);
              
    % separate data into main and minor wheat season
    iSurveyDataMeher=[];
    count=0;
    for iS=1:length(SurveyDataEthiopiaReducedNumeric(:,1))
        iYear=SurveyDataEthiopiaReducedNumeric(iS,1);
        iMonth=SurveyDataEthiopiaReducedNumeric(iS,2);
        if (iYear>=2010 && iYear<=2019) && (iMonth>=8 && iMonth<=12)
            count=count+1;
            iSurveyDataMeher(count,:)=SurveyDataEthiopiaReducedNumeric(iS,:);
        end
    end
     
    % calc. the time-duration from the start of main season to the survey
    % date
    for iEntry=1:length(iSurveyDataMeher(:,1))
        iDayOfSurvey=iSurveyDataMeher(iEntry,3);
        iMonthOfSurvey=iSurveyDataMeher(iEntry,2);
        iYearOfSurvey=iSurveyDataMeher(iEntry,1);
        iDateOfSurvey=datetime(iYearOfSurvey,iMonthOfSurvey,iDayOfSurvey);
        % calc number of days into the main wheat season, which is assumed to
        % start at the 1st of August every year
        iBeginningMainSeason=datetime(iYearOfSurvey,8,1);
        iDaysIntoMainSeason=days(iDateOfSurvey-iBeginningMainSeason);
        iBiweekIntoMainSeason=(iDaysIntoMainSeason/14)+1;
        iSurveyDataMeher(iEntry,10)=iDaysIntoMainSeason;
        iSurveyDataMeher(iEntry,11)=iBiweekIntoMainSeason;
    end    
    
    % define start dates of bi-weekly time-intervalls as temporal bins
    iStartDate=datetime(AllYears,8,15);
    iEndDate=datetime(AllYears,12,31);
    iAllBiWeeks=datetime();
    for iY=1:length(AllYears)
        start=iStartDate(iY);
        enddate=iEndDate(iY);
        alldates=start:calweeks(2):enddate;
        if iY==1
            iAllBiWeeks=alldates;
        else
            iAllBiWeeks=[iAllBiWeeks;alldates];
        end
    end
    
    % aggregate all surveys per bi-weekly interval 
    PathToTempFiles=strcat(ProjectPath,'\Results\WithinSeasonDiseaseProgress\',RustType,'\');
    AllBiWeeklyDataArraysFromFile=readAllSurveysPerBiWeek(iAllBiWeeks,PathToTempFiles);
    AllBiWeeklyDataArrays=AllBiWeeklyDataArraysFromFile;
        
    % define rust-specific color for figures
    [colorsBarChart,Colours]=defineBarChartColorsForDifferentRusts(iRustStr);
    
    % loop disease metrics
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
        
        % create directory for plotting
        SubSubPlotFolderPath=strcat(SubPlotFolderPath,iDiseaseStr,'\');
        mkdir(SubSubPlotFolderPath);
        
        % count disease occurences per bi-week
        [NumberSurveysPerBiweek,DiseaseCountsPerBiweek] = getDiseaseCountsPerBiweek(AllBiWeeklyDataArrays,iAllBiWeeks,icolD);

        % calc. proportion of disease levels, i.e. number disease entries / total number surveys 
        AllProps=calcPrevalenceScores(DiseaseCountsPerBiweek,NumberSurveysPerBiweek,iAllBiWeeks);
        
        % calc. 3-parameter logistic curve fit 
        figName=strcat(SubSubPlotFolderPath,RustType,'_WithinSeasonTempDyn_',iDiseaseStr,'_','LogFit.png');
        fileName=strcat(SubSubPlotFolderPath,RustType,'_WithinSeasonTempDyn_',iDiseaseStr,'_','LogFit.txt');
        [mdlloglow,mdllogmod,mdlloghigh]=fitLogisticWithoutPlot(AllProps,iAllBiWeeks,NumberSurveysPerBiweek,SubSubPlotFolderPath,RustType,iDiseaseStr,iDisStrLeg,iRustStr,colorsBarChart,figName,fileName);
                 
        % write model prediction from fit as additional column into data
        % array
        colmdllow=15;
        colmdlmod=16;
        colmdlhigh=17;
        for iEntry=1:length(iSurveyDataMeher(:,1))
            iTimeOfSurvey=iSurveyDataMeher(iEntry,11); % in units: bi-weeks into main season
            iSurveyDataMeher(iEntry,colmdllow)= predict(mdlloglow,iTimeOfSurvey);  % low disease levels
            iSurveyDataMeher(iEntry,colmdlmod)=predict(mdllogmod,iTimeOfSurvey);   % moderate disease levels
            iSurveyDataMeher(iEntry,colmdlhigh)=predict(mdlloghigh,iTimeOfSurvey); % high disease levels
        end        
        close all;
       
        % loop different disease classifications, fit glm and calculate ROC
        AllDiseaseClassifications={'LowAsPos','ModAsPos','HighAsPos'};
        AllDiseaseClassificationNums=[1,2,3];
        for iD=1:length(AllDiseaseClassifications)
            
            % get identifier for this binary disease classification
            iDiseaseClassification=AllDiseaseClassifications{iD};
            iDiseaseClassifier=AllDiseaseClassificationNums(iD);
            
            % create directory for plotting
            SubSubSubPlotFolderPath=strcat(SubSubPlotFolderPath,iDiseaseClassification,'\');
            mkdir(SubSubSubPlotFolderPath);
    
            % get binary disease status for this disease classification
            colBinaryDisease=20;
            DiseaseStatusBinary=[];
            for iEntry=1:length(iSurveyDataMeher(:,icolD))
                iDiseaseScore=iSurveyDataMeher(iEntry,icolD);
                if iDiseaseScore>=iDiseaseClassifier
                    DiseaseStatusBinary(iEntry,1)=1;
                    iSurveyDataMeher(iEntry,colBinaryDisease+iD)=1;
                else
                    DiseaseStatusBinary(iEntry,1)=0;
                    iSurveyDataMeher(iEntry,colBinaryDisease+iD)=0;
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Model 1: 
            %%%%%%%%%%%%%%%%%
            
            % calc ROC and other performance metrics
            ModelStr=strcat('TempUniform');
            PredictionLogisticTime=[];
            if iD==1
                PredictionLogisticTime=iSurveyDataMeher(:,colmdllow);
            elseif iD==2
                PredictionLogisticTime=iSurveyDataMeher(:,colmdlmod);
            elseif iD==3
                PredictionLogisticTime=iSurveyDataMeher(:,colmdlhigh);
            end
            % calc performance and write to file
            Accuracy=calcPerformanceOfEmpiricalModel(PredictionLogisticTime,DiseaseStatusBinary,SubSubSubPlotFolderPath,RustType,iDiseaseClassification,ModelStr);
                   
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Model 2:
            %%%%%%%%%%%%%%%%%
            
            % fit glm without interaction term 
            DataArray=[DiseaseStatusBinary,iSurveyDataMeher(:,9),iSurveyDataMeher(:,4),iSurveyDataMeher(:,5),iSurveyDataMeher(:,10)];
            DataSet=mat2dataset(DataArray);
            DataSet.Properties.VarNames{1}='DiseaseStatus';
            DataSet.Properties.VarNames{2}='Altitude';
            DataSet.Properties.VarNames{3}='Latitude';
            DataSet.Properties.VarNames{4}='Longitude';
            DataSet.Properties.VarNames{5}='TimeDaysIntoSeason';
            modelspec = 'DiseaseStatus ~ Altitude+Latitude+Longitude+TimeDaysIntoSeason';
            MdlNoInt = fitglm(DataSet,modelspec,'Distribution','binomial','Intercept',[0]);
            AllModels{iR,iD}=MdlNoInt;
            
            % write results to survey data array
            colGLMPrediction=30;
            iSurveyDataMeher(:,colGLMPrediction+iD)=MdlNoInt.Fitted.Probability;
            
            % calc ROC and other performance metrics
            ModelStr=strcat('AltLatLongTime');
            Accuracy=calcPerformanceOfEmpiricalModel(iSurveyDataMeher(:,colGLMPrediction+iD),DiseaseStatusBinary,SubSubSubPlotFolderPath,RustType,iDiseaseClassification,ModelStr);
                        
            % plot both ROC curves in one figure
            plotROCCurves(PredictionLogisticTime,iSurveyDataMeher(:,colGLMPrediction+iD),DiseaseStatusBinary,colorsBarChart,SubSubSubPlotFolderPath,RustType,iDiseaseClassification);
            close all;
            
            % loop over all years, separate data into training data and
            % test data; use training data for fitting and then evaluate
            % performance in test-year
                 
            % initialize arrays for storing ROC curves and metrics 
            % of Model 1 - univariate logistic curve
            AllYearlyModels={};
            ROCX1={};
            ROCY1={};
            ROCThresdhold={};
            ROCAUC={};
            ROCOPTROC={};
            
            % initialize arrays for storing ROC curves and metrics 
            % of Model 2 - multivariate logistic curve
            AllYearlyModelsSp={};
            ROCX1Sp={};
            ROCY1Sp={};
            ROCThresdholdSp={};
            ROCAUCSp={};
            ROCOPTROCSp={};
            
            % initialize arrays for storing the performance scores 
            % for both models 
            Accuracy=zeros(length(AllYears),2);
            Kappa=zeros(length(AllYears),2);
            Sensitivity=zeros(length(AllYears),2);
            Specificity=zeros(length(AllYears),2);
            BrierScore=zeros(length(AllYears),2);
            SkillScore=zeros(length(AllYears),2);
                       
            % loop all years with surveys
            for iYY=1:length(AllYears)
                
                % use this year as test-year
                iYear=AllYears(iYY);     
                
                % get training- and test-data
                [iSurveyDataTraining,iSurveyDataPrediction]=getTrainingAndTestData(iSurveyDataMeher,iYear);                  
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Model 1
                %%%%%%%%%%%%%%%%%
                
                % fit model 1 to training data
                
                % count disease occurance in training data
                [NumberSurveysPerBiweek,DiseaseCountsPerBiweek] = getDiseaseCountsPerBiweekTraining(AllBiWeeklyDataArrays,iAllBiWeeks,iYear,icolD);
                
                % get prevalence scores
                AllProps=calcPrevalenceScores(DiseaseCountsPerBiweek,NumberSurveysPerBiweek,iAllBiWeeks);
              
                % fit 
                figName=strcat(SubSubSubPlotFolderPath,RustType,'_WithinSeasonTempDyn_',iDiseaseStr,'_Train_',num2str(iYear),'LogFit.png');
                fileName=strcat(SubSubSubPlotFolderPath,RustType,'_WithinSeasonTempDyn_',iDiseaseStr,'_Train_',num2str(iYear),'LogFit.txt');
                [mdlloglow,mdllogmod,mdlloghigh]=fitLogisticWithoutPlot(AllProps,iAllBiWeeks,NumberSurveysPerBiweek,SubPlotFolderPath,RustType,iDiseaseStr,iDisStrLeg,iRustStr,colorsBarChart,figName,fileName);
                
                % use fitted model to predict disease in test-year
                colPredLowTestYear=40;
                colPredModTestYear=41;
                colPredHighTestYear=42;
                for iEntry=1:length(iSurveyDataPrediction(:,1))
                    iTimeOfSurvey=iSurveyDataPrediction(iEntry,11); % in units: bi-weeks into main season
                    iSurveyDataPrediction(iEntry,colPredLowTestYear)= predict(mdlloglow,iTimeOfSurvey); % low
                    iSurveyDataPrediction(iEntry,colPredModTestYear)=predict(mdllogmod,iTimeOfSurvey);  % mod
                    iSurveyDataPrediction(iEntry,colPredHighTestYear)=predict(mdlloghigh,iTimeOfSurvey); % high
                end          
                
                % calc. performance scores
                ModelStr=strcat('TempUniform',num2str(iYear));
                PredictionLogisticTime=[];
                if iD==1        % low
                   PredictionLogisticTime=iSurveyDataPrediction(:,colPredLowTestYear);
                elseif iD==2    % mod
                   PredictionLogisticTime=iSurveyDataPrediction(:,colPredModTestYear);
                elseif iD==3    % high
                   PredictionLogisticTime=iSurveyDataPrediction(:,colPredHighTestYear);
                end
                Accuracy(iYY,1)=calcPerformanceOfEmpiricalModel(PredictionLogisticTime,iSurveyDataPrediction(:,colBinaryDisease+iD),SubSubSubPlotFolderPath,RustType,iDiseaseClassification,ModelStr);
                [ROCX1{iYY},ROCY1{iYY},ROCThresdhold{iYY},ROCAUC{iYY},ROCOPTROC{iYY},ROCOptPointYOUDEN{iYY}]=getROCAndAUC(iSurveyDataPrediction(:,colBinaryDisease+iD),PredictionLogisticTime);
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Model 2
                %%%%%%%%%%%%%%%%%
                
                % fit model 2 to training data
                DataArray=[iSurveyDataTraining(:,20+iD),iSurveyDataTraining(:,9),iSurveyDataTraining(:,4),iSurveyDataTraining(:,5),iSurveyDataTraining(:,10)];
                DataSet=mat2dataset(DataArray);
                DataSet.Properties.VarNames{1}='DiseaseStatus';
                DataSet.Properties.VarNames{2}='Altitude';
                DataSet.Properties.VarNames{3}='Latitude';
                DataSet.Properties.VarNames{4}='Longitude';
                DataSet.Properties.VarNames{5}='TimeDaysIntoSeason';
                modelspec = 'DiseaseStatus ~ Altitude+Latitude+Longitude+TimeDaysIntoSeason';
                MdlLogistic = fitglm(DataSet,modelspec,'Distribution','binomial','Intercept',[0]);
                AllYearlyModelsSp{iR,iD,iYY}=MdlLogistic;
                
                % use params from fit to predict risk for prediction year
                iPredictorArray=[iSurveyDataPrediction(:,9),iSurveyDataPrediction(:,4),iSurveyDataPrediction(:,5),iSurveyDataPrediction(:,10)];
                PredictedRisk=predict(MdlLogistic,iPredictorArray);
                
                % compute performance metrics
                ModelStr=strcat('YearlyAltLatLongTime',num2str(iYear));
                Accuracy(iYY,2)=calcPerformanceOfEmpiricalModel(PredictedRisk,iSurveyDataPrediction(:,colBinaryDisease+iD),SubSubSubPlotFolderPath,RustType,iDiseaseClassification,ModelStr);
                [ROCX1Sp{iYY},ROCY1Sp{iYY},ROCThresdholdSp{iYY},ROCAUCSp{iYY},ROCOPTROCSp{iYY},ROCOptPointYOUDENSp{iYY}]=getROCAndAUC(iSurveyDataPrediction(:,colBinaryDisease+iD),PredictedRisk);
                
                % plot the ROC curves for both models in one figure
                fignamelabel=strcat(iDiseaseClassification,num2str(iYear));
                plotROCCurves(PredictionLogisticTime,PredictedRisk,iSurveyDataPrediction(:,colBinaryDisease+iD),colorsBarChart,SubSubSubPlotFolderPath,RustType,fignamelabel);
                
                close all;
     
            end % end loop over years              
                    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % plot ROC curves for all years - Model 1
            figname=strcat(SubSubSubPlotFolderPath,'ROC_AllYearsLogisticTime_',RustType,'_',iDiseaseClassification,'.png');
            plotInterannualVariationOfROCCurves(ROCX1,ROCY1,AllYears,Colours,figname);                       
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % plot ROC curves for all years - Model 2
            figname=strcat(SubSubSubPlotFolderPath,'ROC_AllYearsLogisticALLT_',RustType,'_',iDiseaseClassification,'.png');
            plotInterannualVariationOfROCCurves(ROCX1Sp,ROCY1Sp,AllYears,Colours,figname);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % plot interannual variations of AUC values
            figure
            box on 
            grid on
            set(gcf,'PaperUnits','inches','PaperSize',[5,5],'PaperPosition',[0,0,5,5]);
            hold all
            p1=plot(1:length(AllYears),cell2mat(ROCAUC),':x','MarkerSize',6,'LineWidth',2,'Color',colorsBarChart(2,:));
            p2=plot(1:length(AllYears),cell2mat(ROCAUCSp),':o','MarkerSize',6,'LineWidth',2,'Color',colorsBarChart(3,:));
            p3=plot(1:length(AllYears),ones(1,length(AllYears))*0.5,'k--','LineWidth',1);
            set(gca,'XTick',1:length(AllYears),'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'},'XLim',[1,10],'YLim',[0,1],'FontSize',12);
            rotateXLabels(gca(),45);
            xlabel('years');
            ylabel('AUC');
            legend([p3 p1 p2],['un-informed (random choice)'],['model 1: logistic curve (time)'],['model 2: logistic curve (time, lat., long., alt.)'],'Location','southeast','FontSize', 10);
            figname=strcat(SubSubSubPlotFolderPath,'AUC_AllYears_',RustType,'_',iDiseaseClassification,'.png');
            saveas(gcf,figname);
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % calc mean performance all years for both models
            Filename=strcat(SubSubSubPlotFolderPath,'MeanAUC_',RustType,'_',iDiseaseClassification,'.txt');
            fid=fopen(Filename,'w');
            % model 1
            fprintf(fid,'Mean AUC - Temporal Model: %s \n',num2str(mean(cell2mat(ROCAUC))));
            fprintf(fid,'Mean Accuracy - Temporal Model: %s \n',num2str(mean(Accuracy(:,1))));
            fprintf(fid,'Mean Sensitivity - Temporal Model: %s \n',num2str(mean(Sensitivity(:,1))));
            fprintf(fid,'Mean Specificity - Temporal Model: %s \n\n',num2str(mean(Specificity(:,1))));
            % model 2
            fprintf(fid,'Mean AUC - SpatioTemp Model: %s \n',num2str(mean(cell2mat(ROCAUCSp))));
            fprintf(fid,'Mean Accuracy - SpatioTemp Model: %s \n',num2str(mean(Accuracy(:,2))));
            fprintf(fid,'Mean Sensitivity - SpatioTemp Model: %s \n',num2str(mean(Sensitivity(:,2))));
            fprintf(fid,'Mean Specificity - SpatioTemp Model: %s \n',num2str(mean(Specificity(:,2))));
            fclose(fid);     
  
        end % end loop disease classification schemes (low, mod, high)
    end % end loop disease measures (severity, incidence)
end % end loop types of wheat rusts


