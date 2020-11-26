function [Accuracy]=calcPerformanceOfEmpiricalModel(PredictorArray,BinDiseaseStatusArray,FolderPath,Disease,DiseaseClassification,ModelStr)

       % function to assess the performance of the empirical models
       % for modelling wheat rust outbreaks in Ethiopia. As main
       % performance scores we use the Accuracy, ROC curve and AUC. 

       % calc. ROC curve
       [X1,Y1,Thresholds,AUC,OPTROCPT]=perfcurve(BinDiseaseStatusArray,PredictorArray,1);
            
       % get Youdens classifier (max of sens+spec)
       AllYouden=[];
       for iE=1:length(X1)
           iX=X1(iE);
           iY=Y1(iE);
           iSens=iY;
           iSpec=1-iX;
           iYouden=iSens+iSpec-1;
           AllYouden(iE)=iYouden;
       end
       [MaxYou,IndexMaxYou]=max(AllYouden);
       ClassifierFixedSpecificity=Thresholds(IndexMaxYou);       
       
       % calc accuracy and other performance indicators
       ClassifiedModelPredictions=[];
       for iE=1:length(PredictorArray(:,1))
           iMPred=PredictorArray(iE,1);
           if iMPred<ClassifierFixedSpecificity
               ClassifiedModelPredictions(iE,1)=0;
           else
               ClassifiedModelPredictions(iE,1)=1;
           end
       end      
       BestClassifierPerformance=classperf(BinDiseaseStatusArray,ClassifiedModelPredictions,'Positive',[1],'Negative',[0]);
     
       % write performance indicators to file
       Filenamecheck=strcat(FolderPath,'SummaryStats_LogisticPrediction_',Disease,'_',DiseaseClassification,'_',ModelStr,'.txt');
       fid=fopen(Filenamecheck,'w');
       fprintf(fid,strcat('SurveyDataDiseaseStatusClassification:\n'));
       fprintf(fid,'%s\n',DiseaseClassification);
       fprintf(fid,strcat('NumSurveys\n'));
       fprintf(fid,'%f\n\n',length(BinDiseaseStatusArray(:,1)));
       fprintf(fid,strcat('TotPositives\n'));
       fprintf(fid,'%f\n\n',sum(BinDiseaseStatusArray(:,1)));
       fprintf(fid,strcat('PropPositives\n'));
       fprintf(fid,'%f\n\n',sum(BinDiseaseStatusArray(:,1))/length(BinDiseaseStatusArray(:,1)));
       fprintf(fid,'AUCModel:%f\n\n',AUC);
       fprintf(fid,'Accuracy:%f\n',BestClassifierPerformance.CorrectRate);
       fprintf(fid,'Sensitivity:%f\n',BestClassifierPerformance.Sensitivity);
       fprintf(fid,'Specificity:%f\n',BestClassifierPerformance.Specificity);
       fprintf(fid,'\n\n');
       fclose(fid);
       
       % return accuracy used as main performance indicator
       Accuracy=BestClassifierPerformance.CorrectRate;   
     
    end   
