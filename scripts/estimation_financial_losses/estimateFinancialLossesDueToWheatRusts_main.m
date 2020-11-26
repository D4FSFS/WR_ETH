% Script for estimating financial losses caused by past wheat rust epidemics
% in ET using the historical disease survey data, FAO production statistics
% and published empirical relationships between growth stage, severity and
% yield loss 
%
% @ Marcel Meyer (2020); Visual Data Analysis Group, Uni Hamburg; Epidemiology Group, Uni Cambridge
% 
% Summary script-structure:
%   load FAO wheat price and wheat production stats for Ethiopia
%   loop all wheat rusts
%       check consistency/clean data attribute "growth stage"
%       subset data years of this analysis: 2010-2019
%       Loop all years
%           calculate the sample mean fraction of wheat areas infected with
%           wheat rusts per year
%           calculate the sample mean severity on infected areas
%           calcuate approximate losses based on the sample mean severity
%           for each surveyed field: calculate the approximate yield loss based on survey
%           information about incidence, severity, field area and growth
%           stage using FAO production stats and empirical relationships
%           published in Roelfs, 1992.
%       Calculate mean, max and min losses 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    
% clear workspace
clear all;
close all;

% define paths and setup results folder
ProjectPath='C:\Users\marce\Desktop\FilesMM\Ethiopia_WheatRustDataRevival\wheat_rusts_Ethiopia';
PathToCleanDataFolder=strcat(ProjectPath,'\SurveyData_cleaned\');
PlotFilePath=strcat(ProjectPath,'\Results\EstimateFinancialLosses\');
mkdir(PlotFilePath);

% add path to helper functions
addpath(genpath(strcat(ProjectPath,'\Scripts\Utils\')));

% define types of wheat rusts
AllRusts={'WheatStemRust','WheatLeafRust','WheatYellowRust'};
iAllRustAbbr={'Sr','Lr','Yr'};

% define years of interest
AllYears=[2010,2011,2012,2013,2014,2015,2016,2017,2018,2019];

% get FAO statistics with information about the wheat price per tonne in ET
filename=strcat(ProjectPath,'\AuxiliaryData\FAO_Data_WheatPriceEthiopia\FAOWheatPrice20102019.csv');
WheatPriceET_USDPerTonne=getWheatPriceFromFAO(filename);

% get FAO statistics with information about wheat area, wheat yield and wheat production in ET
filename=strcat(ProjectPath,'\AuxiliaryData\FAO_Data_WheatProductionEthiopia\FAOWheatProductionStats.csv');
[AreaWheatHarvested_ha,Yield_TonnesPerha,WheatProduction_Tonnes]=getWheatProductionFromFAO(filename);

% initialize arrays for storing results
TotalWheatMarketVolume=zeros(1,length(AllYears(1,:)));
AreaInfectedEstimates=zeros(3,length(AllYears(1,:)));
YielLossFractionEstimatesFS=zeros(3,length(AllYears(1,:)));
TotalLossEstimatesFS=zeros(3,length(AllYears(1,:)));
RelativeLossEstimatesFS=zeros(3,length(AllYears(1,:)));

% loop all three types of wheat rusts 
for iR=1:length(AllRusts)
    
    % get identifier for type of rust
    RustType=AllRusts{iR};
    iRustStr=iAllRustAbbr{iR};

    % keep track
    disp(['estimating losses due to ',RustType])
    
    % create plot directory
    SubPlotFolderPath=strcat(PlotFilePath,RustType,'\');
    mkdir(SubPlotFolderPath);
    
    % open file for writing loss estimates and other results
    SummaryFilename=strcat(SubPlotFolderPath,'EstimatedFinancialLosses_ET_',iRustStr,'.txt');
    fidSummaryFile=fopen(SummaryFilename,'w');
    fprintf(fidSummaryFile,'Survey data  %s \n\n',RustType);
       
    % read the cleaned data set
    CleanDataFileName=strcat(PathToCleanDataFolder,'CleanSurveyDataWithAdditionals_ET',RustType,'.csv');
    DataArrayAll=readCleanSurveyData(CleanDataFileName);
    
    % conduct additional consistency checks for data in column "growth stage"
    figName=strcat(SubPlotFolderPath,'NumberOfMissingGSEntriesPerYear',RustType,'.png');
    [DataArrayCleanGrowthStage,NumberOfMissingGSEntries] = cleanGrowthStageData(DataArrayAll,AllYears,RustType,figName);
    
    % convert survey data to numeric array
    DataArrayCleanFieldsNumeric=convertDataToNumeric(DataArrayAll);
     
    % get subset of data for years: 2010 - 2019
    DataArrayCleanFieldsNumericSubYears=[];
    i=1;
    for iEntry=1:length(DataArrayCleanFieldsNumeric(:,1))
       iYear=DataArrayCleanFieldsNumeric(iEntry,1);
       if iYear >= 2010
           DataArrayCleanFieldsNumericSubYears(i,:)=DataArrayCleanFieldsNumeric(iEntry,:);
           i=i+1;
       end
    end
    
    % initialize arrays for storing annual loss estimates
    ApproxWheatAreaInfected_Ha_perYear_IncProp=zeros(1,length(AllYears(1,:)));
    ApproxProductionLossFS_Tonnes_perYear=zeros(length(AllYears(:,1)));
    ApproxYieldLossFractionFS_perYear=zeros(1,length(AllYears(1,:)));
    ApproxFinancialLossFS_MioUSD_perYear=zeros(length(AllYears(:,1)));
    
    % initialize arrays for storing wheat market and relative losses
    TotalWheatIncome=zeros(1,length(AllYears(1,:)));
    RelativeLossWheatRustsFS=zeros(1,length(AllYears(1,:)));
    
    % estimate the total area infected for all years
    [PropsIncAllYears]=estimateTotalInfectedWheatArea(DataArrayCleanFieldsNumericSubYears,iRustStr,AllYears,SubPlotFolderPath,fidSummaryFile);   
      
    % loop years and estimate losses due to rusts
    for iY=1:length(AllYears(1,:))
        
        iYear=AllYears(iY);
        
        % keep track
        disp(num2str(iYear))
        
        % get total wheat area in ET from FAO
        iTotalHarvestedAreaWheatEthiopiaFAO_Ha=AreaWheatHarvested_ha(iY);
                
        % get average wheat yield in ET from FAO
        iAverageYieldETFAO_TonnesPerHa=Yield_TonnesPerha(iY); 
        
        % get wheat price per Tonne in Mio US-D from FAO 
        iWheatPricePerTonneFAO_USDperTonne=WheatPriceET_USDPerTonne(iY);  
        
        % get average growth stage in fields surveys
        AvgGrowthStageperYear=calcAverageGrowthStage(DataArrayCleanGrowthStage,iRustStr,iYear,SubPlotFolderPath,fidSummaryFile);
                  
        %%% approximate area with moderate or high infection levels        
        % according to the survey protocol, moderate incidence reports for
        % a given wheat field mean that approximately 30% of the field area is infected 
        FractionAreaMod=0.3;
        iApproximateAreasCoveredWithModIncFields=iTotalHarvestedAreaWheatEthiopiaFAO_Ha*PropsIncAllYears(2,iY);
        iAreasInfectedFromModIncReports=iApproximateAreasCoveredWithModIncFields*FractionAreaMod;
        % according to the survey protocol, high incidence reports for
        % a given wheat field mean that approximately 50% of the field area is infected 
        FractionAreaHigh=0.5;
        iApproximateAreasCoveredWithHighIncFields=iTotalHarvestedAreaWheatEthiopiaFAO_Ha*PropsIncAllYears(3,iY);
        iAreasInfectedFromHighIncReports=iApproximateAreasCoveredWithHighIncFields*FractionAreaHigh;
        % total area moderately or highly infected
        iApproxAreaInfected_Ha_PropInc=iAreasInfectedFromModIncReports+iAreasInfectedFromHighIncReports;
       
        % get average yield loss fraction from field-scale analysis
        [SampleMeanYieldLossFraction]=calcSampleMeanYieldLossFraction(DataArrayCleanFieldsNumericSubYears,iYear,AvgGrowthStageperYear,iAverageYieldETFAO_TonnesPerHa,iWheatPricePerTonneFAO_USDperTonne,iRustStr);
    
        % calculate losses based on average yield loss fraction
        iApproxProductionLossFS_Tonnes=iApproxAreaInfected_Ha_PropInc*iAverageYieldETFAO_TonnesPerHa*SampleMeanYieldLossFraction;
        iFinancialLossFS_USD=iApproxProductionLossFS_Tonnes*iWheatPricePerTonneFAO_USDperTonne;   
        ApproxFinancialLossFS_MioUSD_perYear(iY)=iFinancialLossFS_USD/1000000;               
        
        % estimate the total wheat income in Mio US-D
        TotalWheatIncome(iY)=WheatPriceET_USDPerTonne(iY)*AreaWheatHarvested_ha(iY)*Yield_TonnesPerha(iY)/1000000;          
        
        % calc. losses relative to total wheat income
        RelativeLossWheatRustsFS(iY)=(ApproxFinancialLossFS_MioUSD_perYear(iY)/TotalWheatIncome(iY))*100;            

        % store results for this year
        ApproxWheatAreaInfected_Ha_perYear_IncProp(iY)=iApproxAreaInfected_Ha_PropInc;
        ApproxYieldLossFractionFS_perYear(iY)=SampleMeanYieldLossFraction*100;
        ApproxProductionLossFS_Tonnes_perYear(iY)=iApproxProductionLossFS_Tonnes;
        
        % write results to file
        fprintf(fidSummaryFile,'Year: %s \n', num2str(iYear));
        fprintf(fidSummaryFile,'Approx wheat area infected based on prop. of inc. scores (in Ha): %s \n', num2str(ApproxWheatAreaInfected_Ha_perYear_IncProp(iY)));   
        fprintf(fidSummaryFile,'Approx yield loss fraction based on field-scale sev and gs: %s \n', num2str(SampleMeanYieldLossFraction));
        fprintf(fidSummaryFile,'Approx production losses (in Tonnes): based on field-scale sev and gs: %s \n', num2str(ApproxProductionLossFS_Tonnes_perYear(iY)));
        fprintf(fidSummaryFile,'Approx financial losses (in Mio USD) based on field-scale sev and gs: %s \n\n', num2str(ApproxFinancialLossFS_MioUSD_perYear(iY)));
        fprintf(fidSummaryFile,'Approx total wheat income (in Mio USD): %s \n', num2str(TotalWheatIncome(iY)));
        fprintf(fidSummaryFile,'Approx relative losses FS: %s \n\n', num2str(RelativeLossWheatRustsFS(iY)));
                
  
    end % end loop over all years

    % calc. mean values over all years and write to file
    fprintf(fidSummaryFile,'Mean all years: \n');
    fprintf(fidSummaryFile,'Approx wheat area infected prop inc (in Ha): %s \n', num2str(mean(ApproxWheatAreaInfected_Ha_perYear_IncProp(:))));
    fprintf(fidSummaryFile,'Approx production losses FS (in Tonnes): %s \n', num2str(mean(ApproxProductionLossFS_Tonnes_perYear(:))));
    fprintf(fidSummaryFile,'Approx financial losses FS (in Mio USD): %s \n', num2str(mean(ApproxFinancialLossFS_MioUSD_perYear(:))));
    fprintf(fidSummaryFile,'Approx total wheat price (in Mio USD): %s \n', num2str(mean(TotalWheatIncome(:))));
    fprintf(fidSummaryFile,'Approx relative losses due to rusts: %s \n\n', num2str(mean(RelativeLossWheatRustsFS(:))));
        
    % calc. minimum value of all years and write to file
    fprintf(fidSummaryFile,'Min all years: \n');
    fprintf(fidSummaryFile,'Approx wheat area infected prop inc (in Ha): %s \n', num2str(min(ApproxWheatAreaInfected_Ha_perYear_IncProp(:))));
    fprintf(fidSummaryFile,'Approx production losses FS (in Tonnes): %s \n', num2str(min(ApproxProductionLossFS_Tonnes_perYear(:))));
    fprintf(fidSummaryFile,'Approx financial losses FS (in Mio USD): %s \n', num2str(min(ApproxFinancialLossFS_MioUSD_perYear(:))));
    fprintf(fidSummaryFile,'Approx total wheat price (in Mio USD): %s \n', num2str(min(TotalWheatIncome(:))));
    fprintf(fidSummaryFile,'Approx relative losses due to rusts: %s \n\n', num2str(min(RelativeLossWheatRustsFS(:))));
        
    % calc. maximum value of all years and write to file
    fprintf(fidSummaryFile,'Max all years: \n');
    fprintf(fidSummaryFile,'Approx wheat area infected prop inc (in Ha): %s \n', num2str(max(ApproxWheatAreaInfected_Ha_perYear_IncProp(:))));
    fprintf(fidSummaryFile,'Approx production losses FS (in Tonnes): %s \n', num2str(max(ApproxProductionLossFS_Tonnes_perYear(:))));
    fprintf(fidSummaryFile,'Approx financial losses FS (in Mio USD): %s \n', num2str(max(ApproxFinancialLossFS_MioUSD_perYear(:))));
    fprintf(fidSummaryFile,'Approx total wheat price (in Mio USD): %s \n', num2str(max(TotalWheatIncome(:))));
    fprintf(fidSummaryFile,'Approx relative losses due to rusts: %s \n\n', num2str(max(RelativeLossWheatRustsFS(:))));
    
    fclose(fidSummaryFile);
    close all;
    
    % store results for plotting the comparison between rusts 
    TotalWheatMarketVolume=TotalWheatIncome;    
    AreaInfectedEstimates(iR,:)=ApproxWheatAreaInfected_Ha_perYear_IncProp;   
    TotalLossEstimatesFS(iR,:)=ApproxFinancialLossFS_MioUSD_perYear;
    RelativeLossEstimatesFS(iR,:)=RelativeLossWheatRustsFS;
    YielLossFractionEstimatesFS(iR,:)=ApproxYieldLossFractionFS_perYear;
    
end


% plot comparison of loss estimates between rusts

% define rust-specific color for figures
colorsBarChart=[];
% Sr
colorsBarChart(1,:)=[150/255,150/255,150/255];
% Yr
colorsBarChart(2,:)=[255/255,204/255,0];
% Lr
colorsBarChart(3,:)=[204/255,51/255,0];

% total wheat market volume
figure 
grid on
box on
hold on
plot(TotalWheatMarketVolume(1:9),'x-','MarkerSize',10,'LineWidth',2.5);
set(gca,'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018'},'XLim',[1,9],'FontSize',11);
rotateXLabels(gca(),45);
ylabel(strcat('Total wheat market [Mio US-D]'),'FontSize',14);
figName=strcat(PlotFilePath,'ApproxTotalWheatVolumeAllYears.png');
print(figName,'-dpng','-r300');
    
% FAO wheat price
figure 
grid on
box on
hold on
plot(WheatPriceET_USDPerTonne(1:9),'x-','MarkerSize',10,'LineWidth',2.5);
set(gca,'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018'},'XLim',[1,9],'FontSize',11);
rotateXLabels(gca(),45);
ylabel(strcat('Wheat price [US-D / tonne]'),'FontSize',14);
figName=strcat(PlotFilePath,'WheatPricePerTonneAllYears.png');
print(figName,'-dpng','-r300');

% FAO harvested area
figure 
grid on
box on
hold on
plot(AreaWheatHarvested_ha(1:9),'x-','MarkerSize',10,'LineWidth',2.5);
set(gca,'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018'},'XLim',[1,9],'FontSize',11);
rotateXLabels(gca(),45);
ylabel(strcat('Harvested area wheat [ha]'),'FontSize',14);
figName=strcat(PlotFilePath,'HarvestedAreaAllYears.png');
print(figName,'-dpng','-r300');

% FAO average wheat yield
figure 
grid on
box on
hold on
plot(Yield_TonnesPerha(1:9),'x-','MarkerSize',10,'LineWidth',2.5);
set(gca,'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018'},'XLim',[1,9],'FontSize',11);
rotateXLabels(gca(),45);
ylabel(strcat('Average wheat yield [t/ha] '),'FontSize',14);
figName=strcat(PlotFilePath,'AverageYieldAllYears.png');
print(figName,'-dpng','-r300');

% relative losses caused by wheat rusts FS
figure 
grid on
box on
hold on
plot(RelativeLossEstimatesFS(1,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(1,:));
hold on
plot(RelativeLossEstimatesFS(2,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(3,:));
hold on
plot(RelativeLossEstimatesFS(3,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(2,:));
set(gca,'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'},'XLim',[1,10],'FontSize',11);
rotateXLabels(gca(),45);
ylabel(strcat('Loss relative to total wheat market [%]'),'FontSize',14);
figName=strcat(PlotFilePath,'ApproxRelativeLossesAllYearsFS.png');
print(figName,'-dpng','-r300');

% total financial losses 
figure 
grid on
box on
hold on
plot(TotalLossEstimatesFS(1,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(1,:));
hold on
plot(TotalLossEstimatesFS(2,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(3,:));
hold on
plot(TotalLossEstimatesFS(3,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(2,:));
set(gca,'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'},'XLim',[1,10],'FontSize',11);
rotateXLabels(gca(),45);
ylabel(strcat('Total loss [Mio US-D]'),'FontSize',14);
figName=strcat(PlotFilePath,'ApproxTotalLossesAllYearsFS.png');
print(figName,'-dpng','-r300');

% infected area
figure 
grid on
box on
hold on
plot(AreaInfectedEstimates(1,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(1,:));
hold on
plot(AreaInfectedEstimates(2,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(3,:));
hold on
plot(AreaInfectedEstimates(3,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(2,:));
set(gca,'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'},'XLim',[1,10],'FontSize',11);
rotateXLabels(gca(),45);
ylabel(strcat('Area infected (mod./high infections) [ha]'),'FontSize',14);
figName=strcat(PlotFilePath,'ApproxAreaInfectedAllYears.png');
print(figName,'-dpng','-r300');

% yield loss fraction 
figure 
grid on
box on
hold on
plot(YielLossFractionEstimatesFS(1,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(1,:));
hold on
plot(YielLossFractionEstimatesFS(2,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(3,:));
hold on
plot(YielLossFractionEstimatesFS(3,:),'x-','MarkerSize',10,'LineWidth',2.5,'color',colorsBarChart(2,:));
set(gca,'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'},'XLim',[1,10],'FontSize',11);
rotateXLabels(gca(),45);
ylabel(strcat('Yield loss (mod./high infections) [%]'),'FontSize',14);
figName=strcat(PlotFilePath,'ApproxYieldLossFractionAllYearsFS.png');
print(figName,'-dpng','-r300');

close all;
