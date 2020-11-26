function [CleanEthiopiaDataArray,NumberOfDataUnexpectedLatLongPerYear] = sortOutLatLongInLake(ETDATA,LakeIDRasterFilename,LakeIDListFilename,AllYears)

    % function for ensuring that no data is used for which the survey
    % coordinates have been reported to be located within one of the lakes in Ethiopia
    
    % note: these are only very few exceptions (<< 1% of all data entries) which are handled here!

    % read a 2D raster-file with auxiliary data about the geographical distribution of lakes in Ethiopia
    [ncolsLakeIDRaster, nrowsLakeIDRaster, xllLakeIDRaster, yllLakeIDRaster, extremeLakeIDRaster, cellsizeLakeIDRaster, nodataLakeIDRaster, LakeIDRaster] = readFromRasterAll(LakeIDRasterFilename);

    % read a list with unique IDs of all lakes (used in above raster-file) in Ethiopia
    fid = fopen(LakeIDListFilename);
    LakeListAll = textscan(fid,'%f %f %f %f %s','HeaderLines',1,'delimiter',',');
    fclose(fid);
    LakeListID=[];
    ListLength=length(LakeListAll{1,1});
    iNameList=LakeListAll{:,5};
    IDList=LakeListAll{:,4};
    for iL=1:ListLength
        iName=iNameList{iL};
        if ~isnan(iName)
            LakeListID=[LakeListID,IDList(iL)];
        end
    end

    % initialize empty array for clean data for this rust
    CleanEthiopiaDataArray={};
    cleandatacounter=1;
    AllMissingEntries=[];

    for iEntry=1:length(ETDATA(:,1))

        % copy header
        if iEntry==1
            CleanEthiopiaDataArray(cleandatacounter,1:12)=ETDATA(1,1:12);
            cleandatacounter=cleandatacounter+1;
        else

            % get survey coordinates (lat, lon)
            iLat=ETDATA{iEntry,5};
            iLong=ETDATA{iEntry,6};

            % determine index of survey coordinates in the 2D raster
            % with data about lakes
            iDistLat=iLat-yllLakeIDRaster;                      
            iDistLong=iLong-xllLakeIDRaster;
            IndexLat=floor(iDistLat/cellsizeLakeIDRaster)+1; 
            IndexLong=floor(iDistLong/cellsizeLakeIDRaster)+1;
            % note that for rows/latitudes/y-values the Matlab indexing starts in
            % the upper left corner. E.g.: index 1 in w.r.t. to lowerleft
            % corresponds to NLats, index 2 is NLats-1,..., index NLats
            % corresponds to 1. So swap.
            IndexLat=nrowsLakeIDRaster-IndexLat+1;

            % check if the raster-cell corresponding to the reported survey coordinates 
            % is located within the geographical area of one of the lakes
            % of Ethiopia
            countInLakes=0;
            if IndexLat>0 && IndexLong>0
                iLakeIDRaster=LakeIDRaster(IndexLat,IndexLong);
                for iLake=1:length(LakeListID)
                    iLakeID=LakeListID(iLake);
                    if iLakeIDRaster==iLakeID
                        countInLakes=countInLakes+1;
                    end
                end
            end
            if countInLakes==0
                % copy all entries to new clean data array
                CleanEthiopiaDataArray(cleandatacounter,1:12)=ETDATA(iEntry,1:12);
                cleandatacounter=cleandatacounter+1;
            else
                AllMissingEntries=[AllMissingEntries,iEntry];
            end
         end
    end

    % count number of surveys per year reported to be located in a lake
    NumberOfDataUnexpectedLatLongPerYear=zeros(1,length(AllYears(1,:)));
    NumberSortedOut=length(ETDATA(:,1))-length(CleanEthiopiaDataArray(:,1));
    if NumberSortedOut>0
        for iD=1:length(AllMissingEntries(1,:))
            % get index of survey in original data-array
            iIndex=AllMissingEntries(iD);
            % get country and year of Survey from original data-array
            iYear=ETDATA{iIndex,2};
            % count entries per year, and per country per year
            for iY=1:length(AllYears(1,:))
                checkYear=AllYears(iY);
                if iYear==checkYear
                    NumberOfDataUnexpectedLatLongPerYear(iY)=NumberOfDataUnexpectedLatLongPerYear(iY)+1;
                end
            end
        end
    end
end

