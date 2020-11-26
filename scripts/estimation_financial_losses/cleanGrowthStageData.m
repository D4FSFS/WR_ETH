function [DataArrayCleanGS,NumberOfMissingAreaEntries] = cleanGrowthStageData(DataArrayAll,AllYears,RustType,figName)
    
    % function to check consistency and clean survey entries for data
    % attribute "growth stage"

    % initialize array and counter for missing/clean data
    DataArrayCleanGS={};
    AllEntriesWithMissingData=[];
    cleandatacounter=1;

    % loop all survey entries and check if data in column field area appears ok
    for iEntry=1:length(DataArrayAll(:,1))
        
        GSHelper=DataArrayAll{iEntry,10};
                
        % if a string, sort out
        if ischar(GSHelper)
            AllEntriesWithMissingData=[AllEntriesWithMissingData,iEntry];
        else
            % if empty, or NaN, or smaller zero, or zero sort out
            if  ( isnan(GSHelper) || (GSHelper<0) || (GSHelper==0) )
                AllEntriesWithMissingData=[AllEntriesWithMissingData,iEntry];
            else
                % else use data
                DataArrayCleanGS(cleandatacounter,:)=DataArrayAll(iEntry,:);
                cleandatacounter=cleandatacounter+1;
            end
        end
    end

    % get the overall number of NaN/missing entries
    NumberOfMissingAreaEntries=length(AllEntriesWithMissingData);

    % get the overall number of NaN/missing entries per year
    NumberOfMissingDataPerYear=zeros(1,length(AllYears(1,:)));
    for iD=1:length(AllEntriesWithMissingData(1,:))
        % get index of survey in original data-array
        iIndex=AllEntriesWithMissingData(iD);
        % get year of Survey from original data-array
        iYear=DataArrayAll{iIndex,2};
        % iterate counter
        for iY=1:length(AllYears(1,:))
            checkYear=AllYears(iY);
            if iYear==checkYear
                NumberOfMissingDataPerYear(iY)=NumberOfMissingDataPerYear(iY)+1;
            end
        end
        
        
    end
    
    
end
