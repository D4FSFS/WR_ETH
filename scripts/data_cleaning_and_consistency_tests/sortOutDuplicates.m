function [CleanEthiopiaDataArray,CleanEthiopiaDataArrayHelperUnique,NumberOfDataDuplicatesPerYear] = sortOutDuplicates(ETDATA,AllYears)

    % function to check for and sort out duplicates in core data attributes
    % (year, month, day, lat, long, sev, inc)

    % use Matlab's built-in "unique" function to look for duplicates. 
    % "unique" requires a numeric array as input, so
    % first copy core attributes to a numeric array, then sort out all duplicates,
    % then put into a new array with unique entries
    CleanEthiopiaDataArray={};
    CleanEthiopiaDataArrayHelper=[];
    CleanEthiopiaDataArrayHelperUnique=[];

    for iEntry=2:length(ETDATA(:,1))
        CleanEthiopiaDataArrayHelper(iEntry-1,1)=ETDATA{iEntry,2};  % year
        CleanEthiopiaDataArrayHelper(iEntry-1,2)=ETDATA{iEntry,3};  % month
        CleanEthiopiaDataArrayHelper(iEntry-1,3)=ETDATA{iEntry,4};  % day
        CleanEthiopiaDataArrayHelper(iEntry-1,4)=ETDATA{iEntry,5};  % latitude
        CleanEthiopiaDataArrayHelper(iEntry-1,5)=ETDATA{iEntry,6};  % longitude
        if ~isempty(ETDATA{iEntry,11})
            CleanEthiopiaDataArrayHelper(iEntry-1,6)=ETDATA{iEntry,11};  % rust severity
        else
            CleanEthiopiaDataArrayHelper(iEntry-1,6)=-9999;              
        end
        if ~isempty(ETDATA{iEntry,12})
            CleanEthiopiaDataArrayHelper(iEntry-1,7)=ETDATA{iEntry,12};  % rust incidence
        else
            CleanEthiopiaDataArrayHelper(iEntry-1,7)=-9999;  
        end
    end

    % check for duplicates and write out
    % indicees for checking where the duplicates occured
    [CleanEthiopiaDataArrayHelperUnique,ia,ic]=unique(CleanEthiopiaDataArrayHelper,'rows');

    % get unique entries in original data array 
    CleanEthiopiaDataArray(1,:)=ETDATA(1,:);   
    for iEntry=1:length(CleanEthiopiaDataArrayHelperUnique(:,1)) 
        Index=ia(iEntry)+1;    % because the ia indices are from the array that is shorter by 1 (without header)
        CleanEthiopiaDataArray(iEntry+1,:)=ETDATA(Index,:);
    end

    % distinguish where and when duplicates occured by looping over the iC 
    % vector and counting the number of occurences of each index, which 
    % gives the number of duplicates of the data-entry with that index.
    NumberOfDataDuplicatesPerYear=zeros(1,length(AllYears(1,:)));
    NumberOfOccurancesOfIndex=zeros(1,length(ic));
    IndiceesOfOccurances=[];
    dummycounter=0;
    for j=1:length(ic)
        sameIndexAtPositions=find(ic==j);
        NumberOfOccurancesOfIndex(j)=length(sameIndexAtPositions);
        for k=1:length(sameIndexAtPositions)
            IndiceesOfOccurances(j,k)=sameIndexAtPositions(k);
        end
    end
    
    % get number of duplicates per year
    for l=1:length(NumberOfOccurancesOfIndex(1,:))
        % get entry
        iNumberOccurance=NumberOfOccurancesOfIndex(l);
        if iNumberOccurance>1
            % get year of the actual survey entry
            iYear=CleanEthiopiaDataArrayHelperUnique(l,1);
            % iterate counter per year
            for iY=1:length(AllYears(1,:))
                checkYear=AllYears(iY);
                if iYear==checkYear
                    NumberOfDataDuplicatesPerYear(iY)=NumberOfDataDuplicatesPerYear(iY)+(iNumberOccurance-1);  % because if there are e.g. two occurances, then one should be kept and one counted as duplicate
                end
            end
        end
    end
end
