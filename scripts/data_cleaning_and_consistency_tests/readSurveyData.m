function [dataArray] = readSurveyData(iDataFilename20072019)
    
    % function to read the wheat rust survey data 
    
    % Key data attributes (columns) available for all years 
    % are written into "dataArray", which is returned by this function

    % initialize array to store survey data
    dataArray={};
    
    % initialize cell array with column headers for storing survey data.
    dataArray{1,1}='CountryID';
    dataArray{1,2}='Year';
    dataArray{1,3}='Month';
    dataArray{1,4}='Day';
    dataArray{1,5}='Latitude';
    dataArray{1,6}='Longitude';
    dataArray{1,7}='Altitude';
    dataArray{1,8}='Area';
    dataArray{1,9}='HostCultivar';
    dataArray{1,10}='GrowthStage';
    dataArray{1,11}='StemRustSeverity';
    dataArray{1,12}='StemRustIncidence';
    dataArray{1,13}='LeafRustSeverity';
    dataArray{1,14}='LeafRustIncidence';
    dataArray{1,15}='StripeRustSeverity';
    dataArray{1,16}='StripeRustIncidence';
    
    % read survey data
    [~,~,DataArray20072019]=xlsread(iDataFilename20072019);

    % get all data entries from Ethiopia, selecting the sub-set of data-attributes required for our analysis. 
    % not all data-attributes are required for our analysis - e.g. the name of the surveyor is one column in the data file, which we do not use and
    % therefore do not need to carry through. 
    iEntryET=1;
    for iEntry=1:(length(DataArray20072019(:,1))-1)
        
        % get country ID
        iCountryID=DataArray20072019{iEntry,13};
        
        % select Ethiopia
        if strcmp(iCountryID,'ET')
            iEntryET=iEntryET+1;

            % write country
            dataArray{iEntryET,1}=iCountryID;

            % get date of survey and write into separate columns for year, month, day
            Helper=DataArray20072019{(iEntry+1),24};
            if isnan(Helper)
                dataArray{(iEntryET),2}=' ';
                dataArray{(iEntryET),3}=' ';
                dataArray{(iEntryET),4}=' ';
            elseif ~isnan(Helper)
                Helper1=strsplit(Helper,'/');
                if length(Helper1)==3
                    iYearHelper=strsplit(Helper1{3},' ');
                    iYear=str2num(iYearHelper{1});
                    iDay=str2num(Helper1{2});
                    iMonth=str2num(Helper1{1});
                elseif length(Helper1)==1
                    Helper1=strsplit(Helper,'.');
                    iYearHelper=strsplit(Helper1{3},' ');
                    iYear=str2num(iYearHelper{1});
                    iDay=str2num(Helper1{2});
                    iMonth=str2num(Helper1{1});
                end
                dataArray{(iEntryET),2}=iYear;
                dataArray{(iEntryET),3}=iMonth;
                dataArray{(iEntryET),4}=iDay;
            end

            % select required data attributes
            dataArray{(iEntryET),5}=DataArray20072019{(iEntry+1),16};  % latitude
            dataArray{(iEntryET),6}=DataArray20072019{(iEntry+1),17};  % longitude
            dataArray{(iEntryET),7}=DataArray20072019{(iEntry+1),18};  % altitude
            dataArray{(iEntryET),8}=DataArray20072019{(iEntry+1),20};  % Field area
            dataArray{(iEntryET),9}=DataArray20072019{(iEntry+1),6};   % get crop cultivar
            dataArray{(iEntryET),10}=DataArray20072019{(iEntry+1),27}; % get growth stage
            dataArray{(iEntryET),11}=DataArray20072019{(iEntry+1),32}; % get stem rust severity
            dataArray{(iEntryET),12}=DataArray20072019{(iEntry+1),34}; % get stem rust incidence
            dataArray{(iEntryET),13}=DataArray20072019{(iEntry+1),40}; % get leaf rust severity
            dataArray{(iEntryET),14}=DataArray20072019{(iEntry+1),42}; % get leaf rust incidence
            dataArray{(iEntryET),15}=DataArray20072019{(iEntry+1),48}; % get stripe rust severity
            dataArray{(iEntryET),16}=DataArray20072019{(iEntry+1),50}; % get stripe rust incidence

        end % end condition for selection entries in ET
    end % end loop over all data entries   
end % end function def
            


