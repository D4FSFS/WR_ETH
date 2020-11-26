function [CleanEthiopiaDataArray,NumberOfDataUnexpectedLatLongPerYear] = sortOutUnexpectedLatLong(ETDATA,CountryIDRasterFilename,colIncNew,AllYears)

    % function to check if the survey coordinates are located within the 
    % geographic area of the administrative boundary/borders of Ethiopia 

    % initialize empty array for storing the resulting clean data 
    CleanEthiopiaDataArray={};
    cleandatacounter=1;
    AllMissingEntriesCountryID=[];

    % read auxiliary data-file with information about the administrative boundary of Ethiopia
    [ncolsCountryIDRaster, nrowsCountryIDRaster, xllCountryIDRaster, yllCountryIDRaster, extremeCountryIDRaster, cellsizeCountryIDRaster, nodataCountryIDRaster, CountryIDRaster] = readFromRasterAll(CountryIDRasterFilename);

    for iEntry=1:length(ETDATA(:,1))
        % copy header
        if iEntry==1
            CleanEthiopiaDataArray(cleandatacounter,1:12)=ETDATA(1,1:12);
            cleandatacounter=cleandatacounter+1;
        else
            % get suvey coordinates
            iLat=ETDATA{iEntry,5};
            iLong=ETDATA{iEntry,6};
            
            % first roughly check if in a rectangle around Ethiopia
            if (iLat>=3 && iLat<=16) && (iLong>=31 && iLong<=49)
                % then check if within the borders of Ethiopia by
                % rasterizing the point surveys and comparing to a raster 
                % with information about the admin borders of ET
                iDistLat=iLat-yllCountryIDRaster;
                iDistLong=iLong-xllCountryIDRaster;
                IndexLat=floor(iDistLat/cellsizeCountryIDRaster)+1;
                IndexLong=floor(iDistLong/cellsizeCountryIDRaster)+1;
                IndexLat=nrowsCountryIDRaster-IndexLat+1; 
                
                % check if raster-cell of survey is in Ethiopia
                iCountryID=CountryIDRaster(IndexLat,IndexLong);
                % Ethiopia ID is 74 in pre-defined countryID data file
                if iCountryID==74
                    % copy all entries to new clean data array
                    CleanEthiopiaDataArray(cleandatacounter,1:colIncNew)=ETDATA(iEntry,1:colIncNew);
                    cleandatacounter=cleandatacounter+1;
                else
                    % keep track of inconsistent data reported to be
                    % outside of ET
                    AllMissingEntriesCountryID=[AllMissingEntriesCountryID,iEntry];
                end
            else
                AllMissingEntriesCountryID=[AllMissingEntriesCountryID,iEntry];
            end
        end
    end

    % count the number of surveys with coordinates outside of Ethiopia
    NumberOfDataUnexpectedLatLongPerYear=zeros(1,length(AllYears(1,:)));
    NumberSortedOut=length(ETDATA(:,1))-length(CleanEthiopiaDataArray(:,1));
    if NumberSortedOut>0
        for iD=1:length(AllMissingEntriesCountryID(1,:))
            % get index of survey in original data-array
            iIndex=AllMissingEntriesCountryID(iD);
            % get country and year of Survey from original data-array
            iYear=ETDATA{iIndex,2};
            % iterate counter per year
            for iY=1:length(AllYears(1,:))
                checkYear=AllYears(iY);
                if iYear==checkYear
                    NumberOfDataUnexpectedLatLongPerYear(iY)=NumberOfDataUnexpectedLatLongPerYear(iY)+1;
                end
            end
        end
    end
end




