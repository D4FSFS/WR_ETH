function testIndepedenceOfPrevalenceAndWheatVariety(iSurveyData,VarietyNames,VarietyNumericIDs,icolD,fileName)
 
     % function to test if disease prevalence levels are independent of
     % wheat varieties (chi-square)

     % open file for writing the results of chisquare tests
     fid=fopen(fileName,'w');

     % test independence including all three disease categories
     [tblall,chi2all,pall,labelsall] = crosstab(iSurveyData(:,8),iSurveyData(:,icolD));

     % write results of chi-square to file
     fprintf(fid,'Test independence of disease prevalence in all categories (low, mod, high) and all wheat varietes: \n');
     
     % print wheat variety indicees in this data set
     fprintf(fid,'wheat variety indicees:');
     for i=1:length(labelsall(:,1))
        fprintf(fid,'%s,',labelsall{i,1});
     end
     fprintf(fid,'\n');
     
     % print wheat variety names corresponding to the indicees
     fprintf(fid,'wheat varieties:');
     for i=1:length(labelsall(:,1))
         ilabel=labelsall{i,1};
         indexoflabel=find(VarietyNumericIDs==str2num(ilabel));
         iwheatvarietyname=VarietyNames{1,indexoflabel};
         fprintf(fid,'%s,',iwheatvarietyname);
     end
     fprintf(fid,'\n');
     
     % print disease indicees
     fprintf(fid,'disease indicees: ');
     for i=1:length(labelsall(:,2))
         ilabel=labelsall{i,2};
         if ~isempty(ilabel)
            fprintf(fid,'%s,',ilabel);     
         end    
     end
     fprintf(fid,'\n');
     fprintf(fid,'chisquare: %s \n',num2str(chi2all));
     fprintf(fid,'pvalue: %s \n\n\n',num2str(pall));

     % dichotimize the disease data into binary yes / no scores and 
     % test independence of disease prevalence and wheat variety

     % loop data and add column with binary disease score
     for iEntry=1:length(iSurveyData(:,1))
         iDiseaseScore=iSurveyData(iEntry,icolD);
         % classify into binary disease score using different classifieres
         % (low, mod, high; in data these correspond to indicees: 1,2,3)
         for iDiseaseClassifier=1:3
             icolBinaryScore=8+iDiseaseClassifier;
             if iDiseaseScore<iDiseaseClassifier
                 iSurveyData(iEntry,icolBinaryScore)=0;
             elseif iDiseaseScore>=iDiseaseClassifier
                 iSurveyData(iEntry,icolBinaryScore)=1;
             end
         end
     end

     % check independence of binary disease score and wheat variety for all
     % three binary classifiers of disease status
     [tbllow,chi2low,plow,labelslow] = crosstab(iSurveyData(:,8),iSurveyData(:,9));
     [tblmod,chi2mod,pmod,labelsmod] = crosstab(iSurveyData(:,8),iSurveyData(:,10));
     [tblhigh,chi2high,phigh,labelshigh] = crosstab(iSurveyData(:,8),iSurveyData(:,11));

     % print results to file
     for iclass=1:3
         if iclass==1
             class='low';
             labelsall=labelslow;
             chi2all=chi2low;
             pall=plow;
         elseif iclass==2
             class='mod';
             labelsall=labelsmod;
             chi2all=chi2mod;
             pall=pmod;
         elseif iclass==3
             class='high';
             labelsall=labelshigh;
             chi2all=chi2high;
             pall=phigh;
         end

         fprintf(fid,'Test independence of disease binary disease prevalence (all above a classifier are considered as "diseased") and all wheat varietes: \n');
         fprintf(fid,strcat('classifier: ',class,'\n')); 
         
         % print wheat variety indicees in this data set
         fprintf(fid,'wheat variety indicees:');
         for i=1:length(labelsall(:,1))
             fprintf(fid,'%s,',labelsall{i,1});
         end
         fprintf(fid,'\n');
         
         % print wheat variety names corresponding to the indicees
         fprintf(fid,'wheat varieties:');
         for i=1:length(labelsall(:,1))
             ilabel=labelsall{i,1};
             indexoflabel=find(VarietyNumericIDs==str2num(ilabel));
             iwheatvarietyname=VarietyNames{1,indexoflabel};
             fprintf(fid,'%s,',iwheatvarietyname);
         end
         fprintf(fid,'\n');
         
         % print disease indicees
         fprintf(fid,'disease indicees: ');
         for i=1:length(labelsall(:,2))
             ilabel=labelsall{i,2};
             if ~isempty(ilabel)
                 fprintf(fid,'%s,',ilabel);
             end
         end
         fprintf(fid,'\n');
         fprintf(fid,'chisquare: %s \n',num2str(chi2all));
         fprintf(fid,'pvalue: %s \n\n\n',num2str(pall));
     end

     % conduct pairwise tests, i.e. test if disease prevalence on wheat
     % variety, A, is different to wheat variety, B. Conduct test for all 
     % pairs of wheat varieties
     AllWheatVarieties=unique(iSurveyData(:,8));
     for i=1:length(AllWheatVarieties)
         
         % get subset of data for wheat variety i
         iWheatVarietyA=AllWheatVarieties(i);
         iSurveyDataSubsetA=[];
         iSurveyDataSubsetA=iSurveyData(iSurveyData(:,8)==iWheatVarietyA,:);
         
         if ~isempty(iSurveyDataSubsetA)
             for j=1:length(AllWheatVarieties)
                 iWheatVarietyB=AllWheatVarieties(j);
                 if iWheatVarietyA~=iWheatVarietyB

                     % get subset of data for wheat variety j
                     iSurveyDataSubsetB=[];
                     iSurveyDataSubsetB=iSurveyData(iSurveyData(:,8)==iWheatVarietyB,:);

                     if ~isempty(iSurveyDataSubsetB)
                         
                         % merge subsets to get data for the pair (i,j)
                         iSurveyDataWheatVarietyPair=[iSurveyDataSubsetA;iSurveyDataSubsetB];

                         % test independence for all disease levels
                         [tbl,chi2all,pall,labelsall] = crosstab(iSurveyDataWheatVarietyPair(:,8),iSurveyDataWheatVarietyPair(:,icolD));
                         
                         % test independence for different disease levels
                         [tbllow,chi2low,plow,labelslow] = crosstab(iSurveyDataWheatVarietyPair(:,8),iSurveyDataWheatVarietyPair(:,9));
                         [tblmod,chi2mod,pmod,labelsmod] = crosstab(iSurveyDataWheatVarietyPair(:,8),iSurveyDataWheatVarietyPair(:,10));
                         [tblhigh,chi2high,phigh,labelshigh] = crosstab(iSurveyDataWheatVarietyPair(:,8),iSurveyDataWheatVarietyPair(:,11));

                         % write to file
                         fprintf(fid,'Test independence of disease prevalence in all categories (low, mod, high) between pairs of wheat variety: \n');
                         
                         % print wheat variety indicees in this data set
                         fprintf(fid,'wheat variety indicees:');
                         for i=1:length(labelsall(:,1))
                             if ~isempty(labelsall{i,1})
                                fprintf(fid,'%s,',labelsall{i,1});
                             end
                         end
                         fprintf(fid,'\n');
                         
                         % print wheat variety names corresponding to the indicees
                         fprintf(fid,'wheat varieties:');
                         for i=1:length(labelsall(:,1))
                             ilabel=labelsall{i,1};
                             if ~isempty(ilabel)
                                 indexoflabel=find(VarietyNumericIDs==str2num(ilabel));
                                 iwheatvarietyname=VarietyNames{1,indexoflabel};
                                 fprintf(fid,'%s,',iwheatvarietyname);
                             end
                         end
                         fprintf(fid,'\n');
                         
                         % print disease indicees
                         fprintf(fid,'disease indicees: ');
                         for i=1:length(labelsall(:,2))
                             ilabel=labelsall{i,2};
                             if ~isempty(ilabel)
                                 fprintf(fid,'%s,',ilabel);
                             end
                         end
                         fprintf(fid,'\n');
                         fprintf(fid,'chisquare: %s \n',num2str(chi2all));
                         fprintf(fid,'pvalue: %s \n\n\n',num2str(pall));

                         % print test results for binary categories to file
                         for iclass=1:3
                             if iclass==1
                                 class='low';
                                 labelsall=labelslow;
                                 chi2all=chi2low;
                                 pall=plow;
                             elseif iclass==2
                                 class='mod';
                                 labelsall=labelsmod;
                                 chi2all=chi2mod;
                                 pall=pmod;
                             elseif iclass==3
                                 class='high';
                                 labelsall=labelshigh;
                                 chi2all=chi2high;
                                 pall=phigh;
                             end

                             fprintf(fid,'Test independence of binary disease prevalence (all above a classifier are considered as "diseased") and pairs of wheat varietes: \n');
                             fprintf(fid,strcat('classifier: ',class,'\n'));
                             
                             % print wheat variety indicees in this data set
                             fprintf(fid,'wheat variety indicees:');
                             for i=1:length(labelsall(:,1))
                                 if ~isempty(labelsall{i,1})
                                    fprintf(fid,'%s,',labelsall{i,1});
                                 end
                             end
                             fprintf(fid,'\n');
                             
                             % print wheat variety names corresponding to the indicees
                             fprintf(fid,'wheat varieties:');
                             for i=1:length(labelsall(:,1))
                                 ilabel=labelsall{i,1};
                                 if ~isempty(ilabel)
                                     indexoflabel=find(VarietyNumericIDs==str2num(ilabel));
                                     iwheatvarietyname=VarietyNames{1,indexoflabel};
                                     fprintf(fid,'%s,',iwheatvarietyname);
                                 end
                             end
                             fprintf(fid,'\n');
                             
                             % print disease indicees
                             fprintf(fid,'disease indicees: ');
                             for i=1:length(labelsall(:,2))
                                 ilabel=labelsall{i,2};
                                 if ~isempty(ilabel)
                                     fprintf(fid,'%s,',ilabel);
                                 end
                             end
                             fprintf(fid,'\n');
                             fprintf(fid,'chisquare: %s \n',num2str(chi2all));
                             fprintf(fid,'pvalue: %s \n\n\n',num2str(pall));
                         end
                        
                     end % test if subset B is empty
                 end % test if subset A and B differ
             end % loop all wheat varieties
         end % test if subset A is empty
     end % loop all wheat varieties

     fclose(fid);

end

