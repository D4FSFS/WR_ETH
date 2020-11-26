function [CleanEthiopiaDataArray,NumberOfDataUnexpectedDiseaseStatusPerYear] = sortOutUnexpectedDiseaseStatus(ETDATA,colSevNew,colIncNew,AllYears)

    % function to check that the survey data attributes disease incidence and disease severity
    % are in the range defined by the survey protocol (allowed values are: 0, 1, 2, 3)

    % initialize empty array for clean data for this rust
    CleanEthiopiaDataArray={};
    cleandatacounter=1;
    AllMissingEntries=[];

    for iEntry=1:length(ETDATA(:,1))
        % copy header
        if iEntry==1
            CleanEthiopiaDataArray(cleandatacounter,1:colIncNew)=ETDATA(1,1:colIncNew);
            cleandatacounter=cleandatacounter+1;
        else

            % check that either severity and incidence are both zero, or both have one of the
            % three expected non-zero values 1, 2, 3 
            if ( (ETDATA{iEntry,colSevNew}==0) && (ETDATA{iEntry,colIncNew}==0) )...
                    || ( ( (ETDATA{iEntry,colSevNew}==1) || (ETDATA{iEntry,colSevNew}==2) || (ETDATA{iEntry,colSevNew}==3) )...
                    && ( (ETDATA{iEntry,colIncNew}==1) || (ETDATA{iEntry,colIncNew}==2) || (ETDATA{iEntry,colIncNew}==3) ) )

                % copy all clean entries to new clean data array
                CleanEthiopiaDataArray(cleandatacounter,1:colIncNew)=ETDATA(iEntry,1:colIncNew);
                cleandatacounter=cleandatacounter+1;
            else
                % keep track of inconsistent entries with unexpected
                % data entries about infection levels
                AllMissingEntries=[AllMissingEntries,iEntry];
            end
       end
    end

    % count the number of surveys with unexpected disease entries per year
    NumberOfDataUnexpectedDiseaseStatusPerYear=zeros(1,length(AllYears(1,:)));
    NumberSortedOutUnexpectedDisease=length(ETDATA(:,1))-length(CleanEthiopiaDataArray(:,1));
    if NumberSortedOutUnexpectedDisease>0
        for iD=1:length(AllMissingEntries(1,:))
            % get index of survey in original data-array
            iIndex=AllMissingEntries(iD);
            % get year of survey from original data-array
            iYear=ETDATA{iIndex,2};
            % iterate counter of unexpected disease entries
            for iY=1:length(AllYears(1,:))
                checkYear=AllYears(iY);
                if iYear==checkYear
                    NumberOfDataUnexpectedDiseaseStatusPerYear(iY)=NumberOfDataUnexpectedDiseaseStatusPerYear(iY)+1;
                end
            end
        end
    end


end

