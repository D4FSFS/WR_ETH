function CleanEthiopiaDataArray = cleanAltitudeEntries(DataArrayAll,RustType,SubPlotFolderPath)

    % function to check consistency of data entries for data attribute
    % altitude

    AllEntriesWithMissingData=[];
    cleandatacounter=1;
    for iEntry=1:length(DataArrayAll(:,1))
        AltitudeHelper=DataArrayAll{iEntry,7};
        % there are a number of empty entries, -9999 entries etc. in the
        % column "altitude". Sort out all rows with missing values.
        if ischar(AltitudeHelper)
            AllEntriesWithMissingData=[AllEntriesWithMissingData,iEntry];
        else
            % if empty, or NaN, or smaller zero (no wheat below sea level
            % in ET; so all neg. values should be nodata), sort out.
            % there are a couple of occasions where the longitude is
            % repeated in the altitude; sort these out; there are also a
            % couple of occasions where a character is missing
            if  isnan(AltitudeHelper) || (AltitudeHelper<0 || AltitudeHelper==0 || AltitudeHelper<50)
                AllEntriesWithMissingData=[AllEntriesWithMissingData,iEntry];
            else
                % if altitude entry is fine, then write to clean data array
                CleanEthiopiaDataArray(cleandatacounter,:)=DataArrayAll(iEntry,:);
                cleandatacounter=cleandatacounter+1;
            end
        end 
    end
    % get the overall number of NaN/missing entries
    NumberOfMissingAreaEntries=length(AllEntriesWithMissingData);

    % get the overall number of NaN/missing entries per year
    AllYears=[2010,2011,2012,2013,2014,2015,2016,2017,2018,2019];
    NumberOfMissingDataPerYear=zeros(1,length(AllYears(1,:)));
    for iD=1:length(AllEntriesWithMissingData(1,:))
        % get index of survey in original data-array
        iIndex=AllEntriesWithMissingData(iD);
        % get year of Survey from original data-array
        iYear=DataArrayAll{iIndex,2};
        % count entries per year
        for iY=1:length(AllYears(1,:))
            checkYear=AllYears(iY);
            if iYear==checkYear
                NumberOfMissingDataPerYear(iY)=NumberOfMissingDataPerYear(iY)+1;
            end
        end
    end
    
%     % plot to keep track
%     figure
%     plot(NumberOfMissingDataPerYear)
%     set(gca,'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'},'XLim',[1,10]);
%     rotateXLabels(gca(),45);
%     xlabel(strcat('year')); 
%     ylabel('Number of missing values');
%     figName=strcat(SubPlotFolderPath,'NumberOfMissingAltitudeEntriesPerYear_',RustType,'.png');
%     print(figName,'-dpng','-r300');

    close all;

end

