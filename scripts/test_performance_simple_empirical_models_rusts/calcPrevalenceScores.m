function  AllProps=calcPrevalenceScores(DiseaseCountsPerBiweek,NumberSurveysPerBiweek,iAllBiWeeks)

    % function to calculate prevalence scores

    ProportionIncidenceLow=[];
    ProportionIncidenceMed=[];
    ProportionIncidenceHigh=[];
    ProportionIncidenceNegative=[];
    for iA=1:length(iAllBiWeeks(1,:))
        iNumS=NumberSurveysPerBiweek(iA);
        if iNumS>0
            ProportionIncidenceLow(iA)=DiseaseCountsPerBiweek(iA,2)./ NumberSurveysPerBiweek(iA);
            ProportionIncidenceMed(iA)=DiseaseCountsPerBiweek(iA,3)./ NumberSurveysPerBiweek(iA);
            ProportionIncidenceHigh(iA)=DiseaseCountsPerBiweek(iA,4)./ NumberSurveysPerBiweek(iA);
            ProportionIncidenceNegative(iA)=DiseaseCountsPerBiweek(iA,1)./NumberSurveysPerBiweek(iA);
        else
            ProportionIncidenceLow(iA)=0;
            ProportionIncidenceMed(iA)=0;
            ProportionIncidenceHigh(iA)=0;
            ProportionIncidenceNegative(iA)=0;
        end
    end

    % combine props into one array 
    AllProps=[];
    AllProps(:,4)=ProportionIncidenceNegative;
    AllProps(:,3)=ProportionIncidenceLow;
    AllProps(:,2)=ProportionIncidenceMed;
    AllProps(:,1)=ProportionIncidenceHigh;


end

