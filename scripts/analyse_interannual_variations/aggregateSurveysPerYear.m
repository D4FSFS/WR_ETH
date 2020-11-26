function [NumberSurveysPerYear,Counts] = AggregateSurveysPerYear(iSurveyData,icolD,AllYears)

    % function to aggregate surveys per year - counting the total number of surveys
    % per year as well as the number of surveys with low, medium and
    % high disease leves for both disease measures: severity and incidence

    % initialise a data array for each year
    % ToDo: this should be put in a 3-D array for avoiding repetitive stuff
    % for each year
    SurveysPerYear2010=[];
    SurveysPerYear2011=[];
    SurveysPerYear2012=[];
    SurveysPerYear2013=[];
    SurveysPerYear2014=[];
    SurveysPerYear2015=[];
    SurveysPerYear2016=[];
    SurveysPerYear2017=[];
    SurveysPerYear2018=[];
    SurveysPerYear2019=[];

    % count the number of surveys per year
    CounterPerYear=ones(length(AllYears),1);
    for i=1:length(iSurveyData(:,1))
        if iSurveyData(i,1)==2010
            SurveysPerYear2010(CounterPerYear(1),:)=iSurveyData(i,:);
            CounterPerYear(1)=CounterPerYear(1)+1;
        elseif iSurveyData(i,1)==2011
            SurveysPerYear2011(CounterPerYear(2),:)=iSurveyData(i,:);
            CounterPerYear(2)=CounterPerYear(2)+1;
        elseif iSurveyData(i,1)==2012
            SurveysPerYear2012(CounterPerYear(3),:)=iSurveyData(i,:);
            CounterPerYear(3)=CounterPerYear(3)+1;
        elseif iSurveyData(i,1)==2013
            SurveysPerYear2013(CounterPerYear(4),:)=iSurveyData(i,:);
            CounterPerYear(4)=CounterPerYear(4)+1;
        elseif iSurveyData(i,1)==2014
            SurveysPerYear2014(CounterPerYear(5),:)=iSurveyData(i,:);
            CounterPerYear(5)=CounterPerYear(5)+1;
        elseif iSurveyData(i,1)==2015
            SurveysPerYear2015(CounterPerYear(6),:)=iSurveyData(i,:);
            CounterPerYear(6)=CounterPerYear(6)+1;
        elseif iSurveyData(i,1)==2016
            SurveysPerYear2016(CounterPerYear(7),:)=iSurveyData(i,:);
            CounterPerYear(7)=CounterPerYear(7)+1;
        elseif iSurveyData(i,1)==2017
            SurveysPerYear2017(CounterPerYear(8),:)=iSurveyData(i,:);
            CounterPerYear(8)=CounterPerYear(8)+1;
        elseif iSurveyData(i,1)==2018
            SurveysPerYear2018(CounterPerYear(9),:)=iSurveyData(i,:);
            CounterPerYear(9)=CounterPerYear(9)+1;
        elseif iSurveyData(i,1)==2019
            SurveysPerYear2019(CounterPerYear(10),:)=iSurveyData(i,:);
            CounterPerYear(10)=CounterPerYear(10)+1;
        end
    end
    NumberSurveysPerYear=[];
    % 2019
    if ~isempty(SurveysPerYear2019)
        NumberSurveysPerYear(1,1)=length(SurveysPerYear2019(:,1)); % total number
    else
        NumberSurveysPerYear(1,1)=0;
    end
    % 2018
    if ~isempty(SurveysPerYear2018)
        NumberSurveysPerYear(2,1)=length(SurveysPerYear2018(:,1)); % total number
    else
        NumberSurveysPerYear(2,1)=0;
    end
    % 2017
    if ~isempty(SurveysPerYear2017)
        NumberSurveysPerYear(3,1)=length(SurveysPerYear2017(:,1)); % total number
    else
        NumberSurveysPerYear(3,1)=0;
    end
    % 2016
    if ~isempty(SurveysPerYear2016)
        NumberSurveysPerYear(4,1)=length(SurveysPerYear2016(:,1)); % total number
    else
        NumberSurveysPerYear(4,1)=0;
    end
    %2015
    if ~isempty(SurveysPerYear2015)
        NumberSurveysPerYear(5,1)=length(SurveysPerYear2015(:,1));
    else
        NumberSurveysPerYear(5,1)=0;
    end
    % 2014
    if ~isempty(SurveysPerYear2014)
        NumberSurveysPerYear(6,1)=length(SurveysPerYear2014(:,1));
    else
        NumberSurveysPerYear(6,1)=0;
    end
    % 2013
    if ~isempty(SurveysPerYear2013)
        NumberSurveysPerYear(7,1)=length(SurveysPerYear2013(:,1));
    else
        NumberSurveysPerYear(7,1)=0;
    end
    % 2012
    if ~isempty(SurveysPerYear2012)
        NumberSurveysPerYear(8,1)=length(SurveysPerYear2012(:,1));
    else
        NumberSurveysPerYear(8,1)=0;
    end
    % 2011
    if ~isempty(SurveysPerYear2011)
        NumberSurveysPerYear(9,1)=length(SurveysPerYear2011(:,1));
    else
        NumberSurveysPerYear(9,1)=0;
    end
    % 2010
    if ~isempty(SurveysPerYear2010)
        NumberSurveysPerYear(10,1)=length(SurveysPerYear2010(:,1));
    else
        NumberSurveysPerYear(10,1)=0;
    end

    % count and plot incidence levels over years
    Counts=[];
    if ~isempty(SurveysPerYear2010)
        Counts(1,:)=hist(SurveysPerYear2010(:,icolD),[0,1,2,3]);
    else
        Counts(1,1:4)=0;
    end
    if ~isempty(SurveysPerYear2011)
        Counts(2,:)=hist(SurveysPerYear2011(:,icolD),[0,1,2,3]);
    else
        Counts(2,1:4)=0;
    end
    if ~isempty(SurveysPerYear2012)
        Counts(3,:)=hist(SurveysPerYear2012(:,icolD),[0,1,2,3]);
    else
        Counts(3,1:4)=0;
    end
    if ~isempty(SurveysPerYear2013)
        Counts(4,:)=hist(SurveysPerYear2013(:,icolD),[0,1,2,3]);
    else
        Counts(4,1:4)=0;
    end
    if ~isempty(SurveysPerYear2014)
        Counts(5,:)=hist(SurveysPerYear2014(:,icolD),[0,1,2,3]);
    else
        Counts(5,1:4)=0;
    end
    if ~isempty(SurveysPerYear2015)
        Counts(6,:)=hist(SurveysPerYear2015(:,icolD),[0,1,2,3]);
    else
        Counts(6,1:4)=0;
    end
    if ~isempty(SurveysPerYear2016)
        Counts(7,:)=hist(SurveysPerYear2016(:,icolD),[0,1,2,3]);
    else
        Counts(7,1:4)=0;
    end
    if ~isempty(SurveysPerYear2017)
        Counts(8,:)=hist(SurveysPerYear2017(:,icolD),[0,1,2,3]);
    else
        Counts(8,1:4)=0;
    end
    if ~isempty(SurveysPerYear2018)
        Counts(9,:)=hist(SurveysPerYear2018(:,icolD),[0,1,2,3]);
    else
        Counts(9,1:4)=0;
    end
    if ~isempty(SurveysPerYear2019)
        Counts(10,:)=hist(SurveysPerYear2019(:,icolD),[0,1,2,3]);
    else
        Counts(10,1:4)=0;
    end


end

