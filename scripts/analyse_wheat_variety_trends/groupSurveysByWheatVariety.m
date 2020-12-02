function [SurveyDatawVariety,VarietyCounter] = groupSurveysByWheatVariety(iSurveyDataCleaned,VarietyNames)

    % function to group surveys by wheat variety    
    
    % write a numeric identifier for each variety;
    VarietyCounter=zeros(length(VarietyNames),1);

    for iS=1:length(iSurveyDataCleaned(:,1))
        iWheatVariety=iSurveyDataCleaned{iS,9};        

        % ID 1: "Local"
        % categorize different spellings of local into one group
        if (strcmp(iWheatVariety,'local') || strcmp(iWheatVariety,'Local') || strcmp(iWheatVariety,'LOCAL'))
            iSurveyDataCleaned{iS,14}=1;
            VarietyCounter(1)=VarietyCounter(1)+1;

        % ID 2: "Improved"
        % categorize different spellings of "improved" into one group
        elseif (strcmp(iWheatVariety,'improved') || strcmp(iWheatVariety,'Improved'))
            iSurveyDataCleaned{iS,14}=2;
            VarietyCounter(2)=VarietyCounter(2)+1;

        % ID 3: Kubsa
        % "Kubsa" is also known as "Har1686" or "har1685"
        % categorize different spellings of "Kubsa" into one group
        elseif strcmp(iWheatVariety,'Kubsa') || strcmp(iWheatVariety,'kubsa')...
                || strcmp(iWheatVariety,'Kubse') || strcmp(iWheatVariety,'kubse')...
                || strcmp(iWheatVariety,'KUBSA') || strcmp(iWheatVariety,'KUBSE')...
                || strcmp(iWheatVariety,'HAR 1685') || strcmp(iWheatVariety,'HAR-1685')...
                || strcmp(iWheatVariety,'HAR 1686') || strcmp(iWheatVariety,'HAR-1686')
            iSurveyDataCleaned{iS,14}=3;
            VarietyCounter(3)=VarietyCounter(3)+1;

        % ID 4: "Digalu"
        % categorize different spellings of "Digalu" into one group
        elseif strcmp(iWheatVariety,'Digalu') || strcmp(iWheatVariety,'Digelu')...
                || strcmp(iWheatVariety,'Digalo)') || strcmp(iWheatVariety,'Digelo')...
                || strcmp(iWheatVariety,'digalu') || strcmp(iWheatVariety,'digelu')...
                || strcmp(iWheatVariety,'digalo') || strcmp(iWheatVariety,'digelo')...
                || strcmp(iWheatVariety,'Digelu (mix)') || strcmp(iWheatVariety,'DIGELU')...
                || strcmp(iWheatVariety,'Diggegelu') || strcmp(iWheatVariety,'Diggelu')...
                || strcmp(iWheatVariety,'Diggalu') || strcmp(iWheatVariety,'diggelu')...
                || strcmp(iWheatVariety,'diggalu') || strcmp(iWheatVariety,'diglo')...
                || strcmp(iWheatVariety,'Diggalo') || strcmp(iWheatVariety,'Diggelo')...
                || strcmp(iWheatVariety,'diggalo') || strcmp(iWheatVariety,'diggelo')...
                || strcmp(iWheatVariety,'digallu') || strcmp(iWheatVariety,'digellu')
            iSurveyDataCleaned{iS,14}=4;
            VarietyCounter(4)=VarietyCounter(4)+1;

        % ID 5: "Kakaba"
        % "picaflor" is also known as "picaflow" or "kakaba"
        % categorize different spellings of "Kakaba" into one group
        elseif strcmp(iWheatVariety,'Kakaba') || strcmp(iWheatVariety,'kakaba')...
                || strcmp(iWheatVariety,'KAKABA') || strcmp(iWheatVariety,'Kekeba')...
                || strcmp(iWheatVariety,'Picaflor') || strcmp(iWheatVariety,'Picoflor') || strcmp(iWheatVariety,'Pikaflor')
            iSurveyDataCleaned{iS,14}=5;
            VarietyCounter(5)=VarietyCounter(5)+1;

        % ID 6: "Ogolcho"
        % categorize different spellings of "ogolcho" into one group
        elseif strcmp(iWheatVariety,'Ogelcho') || strcmp(iWheatVariety,'Ogolcho')
            iSurveyDataCleaned{iS,14}=6;
            VarietyCounter(6)=VarietyCounter(6)+1;

        % ID 7: "Dandaa"
        % cateogrize different spellings of "Dandaa" into one group
        elseif strcmp(iWheatVariety,'dandaa') || strcmp(iWheatVariety,'Dandaa')...
                || strcmp(iWheatVariety,'DANDAA') || strcmp(iWheatVariety,'DANDA-|-A') || strcmp(iWheatVariety,'Danda-|-a')  || strcmp(iWheatVariety,'Danda')...
                || strcmp(iWheatVariety,'Danada') || strcmp(iWheatVariety,'Danda(Damphe)') || strcmp(iWheatVariety,'Danda(Danphe)')...
                || strcmp(iWheatVariety,'Denda') || strcmp(iWheatVariety,'dendaa') || strcmp(iWheatVariety,'dendea') || strcmp(iWheatVariety,"Danda'a")
            iSurveyDataCleaned{iS,14}=7;
            VarietyCounter(7)=VarietyCounter(7)+1;

        % ID 8: "not classified"
        % store all other varieties into one group (as a sort of control group with mixed varieties)
        else
            iSurveyDataCleaned{iS,14}=-9;
            VarietyCounter(8)=VarietyCounter(8)+1;
        end
    end

    % convert to numeric array
     SurveyDatawVariety=[];
     SurveyDatawVariety(:,1)=cell2mat(iSurveyDataCleaned(:,2));  % year
     SurveyDatawVariety(:,2)=cell2mat(iSurveyDataCleaned(:,3));  % month
     SurveyDatawVariety(:,3)=cell2mat(iSurveyDataCleaned(:,4));  % day
     SurveyDatawVariety(:,4)=cell2mat(iSurveyDataCleaned(:,5));  % lat
     SurveyDatawVariety(:,5)=cell2mat(iSurveyDataCleaned(:,6));  % long
     SurveyDatawVariety(:,6)=cell2mat(iSurveyDataCleaned(:,11)); % disease severity
     SurveyDatawVariety(:,7)=cell2mat(iSurveyDataCleaned(:,12)); % disease incidence
     SurveyDatawVariety(:,8)=cell2mat(iSurveyDataCleaned(:,14)); % numeric identifier wheat variety

end

