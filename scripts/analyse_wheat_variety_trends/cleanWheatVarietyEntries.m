function iSurveyDataCleaned = cleanWheatVarietyEntries(iSurveyData,RustType,SubPlotFolderPath)

    % function to clean the data entries in the attribute "wheat variety"
    % cleaning steps:
    % sort out NaN and empty values. 
    % sort out numeric entries, because it is supposed to be a text-string
    
    % sort out empty entries
    iSurveyDataNoEmpties={};
    cleandatacounter=1;
    AllEntriesWithMissingData=[];
    for iEntry=1:length(iSurveyData(:,1))
        iWheatVariety=iSurveyData{iEntry,9};
        if ~isempty(iWheatVariety)
            iSurveyDataNoEmpties(cleandatacounter,:)=iSurveyData(iEntry,:);
            cleandatacounter=cleandatacounter+1;
        else
            AllEntriesWithMissingData=[AllEntriesWithMissingData,iEntry];
        end
    end
     
    % sort out numeric entries, cause should be string description
    iSurveyDataNoEmptiesNoNumeric={};
    cleandatacounter=1;
    AllEntriesWithMissingDataNum=[];
    for iEntry=1:length(iSurveyDataNoEmpties(:,1))
        if  ~isnumeric(iSurveyDataNoEmpties{iEntry,9})
            iSurveyDataNoEmptiesNoNumeric(cleandatacounter,:)=iSurveyDataNoEmpties(iEntry,:);
            cleandatacounter=cleandatacounter+1;
        else
            AllEntriesWithMissingDataNum=[AllEntriesWithMissingDataNum,iEntry];
        end
    end
    
    % sort out all entries with a string of form: NaN, nan, NAN
    iSurveyDataNoEmptiesNoNumericNoNaN={};
    cleandatacounter=1;
    AllEntriesWithMissingDataNumNaN=[];
    for iEntry=1:length(iSurveyDataNoEmptiesNoNumeric(:,1))
        if  ~strcmp(iSurveyDataNoEmptiesNoNumeric{iEntry,9},'NaN')...
                && ~strcmp(iSurveyDataNoEmptiesNoNumeric{iEntry,9},'NAN')...
                && ~strcmp(iSurveyDataNoEmptiesNoNumeric{iEntry,9},'nan')...
                && ~strcmp(iSurveyDataNoEmptiesNoNumeric{iEntry,9},'Nan')
            iSurveyDataNoEmptiesNoNumericNoNaN(cleandatacounter,:)=iSurveyDataNoEmptiesNoNumeric(iEntry,:);
            cleandatacounter=cleandatacounter+1;
        else
            AllEntriesWithMissingDataNumNaN=[AllEntriesWithMissingDataNumNaN,iEntry];
        end
    end
    
    % sort out all strings that say 'unknown'
    iSurveyDataCleaned={};
    cleandatacounter=1;
    AllEntriesWithMissingDataNumNaNUnknown=[];
    for iEntry=1:length(iSurveyDataNoEmptiesNoNumericNoNaN(:,1))
        if  ~strcmp(iSurveyDataNoEmptiesNoNumericNoNaN{iEntry,9},'unknown')...
                && ~strcmp(iSurveyDataNoEmptiesNoNumericNoNaN{iEntry,9},'Unknown')...
                && ~strcmp(iSurveyDataNoEmptiesNoNumericNoNaN{iEntry,9},'UNKNOWN')
            iSurveyDataCleaned(cleandatacounter,:)=iSurveyDataNoEmptiesNoNumericNoNaN(iEntry,:);
            cleandatacounter=cleandatacounter+1;
        else
            AllEntriesWithMissingDataNumNaNUnknown=[AllEntriesWithMissingDataNumNaNUnknown,iEntry];
        end
    end

end

