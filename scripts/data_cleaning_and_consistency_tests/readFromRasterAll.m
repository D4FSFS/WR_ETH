function [ncols, nrows, xll, yll, extreme, cellsize, nodata, DATA] = readFromRasterAll(continuousRasterFilename)  

    % function to read data from a text-file formatted in accordance with the ESRI ArcGIS 2D raster file 
    % conventions 

    % read header
    fid = fopen(continuousRasterFilename,'r');            
    dum1 = fscanf(fid,'%s',1);            
    ncols = fscanf(fid,'%u',1);           
    dum2 = fscanf(fid,'%s',1);            
    nrows = fscanf(fid,'%u',1);           
    dum3 = fscanf(fid,'%s',1);            
    xll = fscanf(fid,'%f',1);            
    dum4 = fscanf(fid,'%s',1);            
    yll = fscanf(fid,'%f',1);             
    dum5 = fscanf(fid,'%s',1);            
    cellsize = fscanf(fid,'%f',1);        
    dum6 = fscanf(fid,'%s',1);            
    nodata = fscanf(fid,'%f',1);          
    fclose(fid); 

    % read data
    DATA = dlmread(continuousRasterFilename,'',6,0); 

    % determine if grid boundary coords. given as corner or center
    if strcmp(dum3,'xllcorner')
        extreme = 'corner';
    elseif strcmp(dum3,'xllcenter')
        extreme = 'center';
    else
        extreme = 'null';
        disp('ERROR: unrecognised xllcorner or xllcenter')
    end

    fprintf('Finished reading raster data from file: %s\n',continuousRasterFilename);

end



