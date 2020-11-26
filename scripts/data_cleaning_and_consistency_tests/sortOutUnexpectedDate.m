function [CleanEthiopiaDataArray,NumberOfDataUnexpectedDatePerYear] = sortOutUnexpectedDate(ETDATA,colIncNew,AllYears)

    % function to check that the date of the survey falls into the
    % time-interval of this study (years: 2007-2019)

    % initialize empty array for storing the resulting clean data 
    CleanEthiopiaDataArray={};
    cleandatacounter=1;
    AllMissingEntries=[];

    for iEntry=1:length(ETDATA(:,1))

        % copy header
        if iEntry==1
            CleanEthiopiaDataArray(cleandatacounter,1:colIncNew)=ETDATA(1,1:colIncNew);
            cleandatacounter=cleandatacounter+1;
        else

            % check if date is in expected interval
            YearHelper=ETDATA{iEntry,2};
            MonthHelper=ETDATA{iEntry,3};
            DayHelper=ETDATA{iEntry,4};       
            if (YearHelper>=AllYears(1) && YearHelper<=AllYears(end))...
                    && (MonthHelper>=1 && MonthHelper<=12)...
                    && (DayHelper>=1 && DayHelper<=31)

                % copy all entries to new clean data array
                CleanEthiopiaDataArray(cleandatacounter,1:colIncNew)=ETDATA(iEntry,1:colIncNew);
                cleandatacounter=cleandatacounter+1;

            else
                AllMissingEntries=[AllMissingEntries,iEntry];
            end
        end
    end

    % count the number of survey entries with date out-of-range
    NumberOfDataUnexpectedDatePerYear=zeros(1,length(AllYears(1,:)));
    NumberSortedOut=length(ETDATA(:,1))-length(CleanEthiopiaDataArray(:,1));
    if NumberSortedOut>0
        for iD=1:length(AllMissingEntries(1,:))
            % get index of survey in original data-array
            iIndex=AllMissingEntries(iD);
            % get year of survey from original data-array
            iYear=ETDATA{iIndex,2};
            % iterate counter of unexpected date entries
            for iY=1:length(AllYears(1,:))
                checkYear=AllYears(iY);
                if iYear==checkYear
                    NumberOfDataUnexpectedDatePerYear(iY)=NumberOfDataUnexpectedDatePerYear(iY)+1;
                end
            end
        end
    end
end

