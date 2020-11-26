function [ApproxLossFraction]=calcFieldScaleYieldLoss(SampleSeverity,iRust,varargin)

    % function for estimating yield losses on surveyed wheat fields as a function of disease
    % severity and growth stage combined with published empirical values
    % (Roelfs, 1992).
 
    % estimate yield loss separately for each wheat rust (Sr, Yr, Lr)
    % wheat stem rust
    if strcmp(iRust,"Sr")    
        
        % get growth stage and severity from survey data and then calculate yield loss based on 
        % empirical relations between severity and yield loss for this growth stage as 
        % given in (Roelfs, 1992). 
        
        if nargin==2           
            
            % if no data for growth stage is given, use mean growth stage
            % in all surveys, which is 4.1 in scale of growth stages used in surveys; 
            
            % define empirical values of yield loss for different classes 
            % severity scores and growth stage 4, as given in table 23, Roelfs, 1992, p.51
            SeverityD=[0,5,10,25,40,65];
            YieldLossD=[0,5,15,50,75,100];

            % calc. a linear fit for yield loss as a function of severity for this growth stage
            % to approximate yield loss as a function of the severity score
            % given in surveys (which does not necessarily fall int one of
            % the categories given in Roelfs).
            LinearTrendD=fitlm(SeverityD,YieldLossD);
            Rsquared(1)=LinearTrendD.Rsquared.Ordinary;
            [p(1),F(1)] = coefTest(LinearTrendD);
            ApproxLossFraction=predict(LinearTrendD,SampleSeverity)/100;
                   
            % check boundaries
            if ApproxLossFraction>1
                ApproxLossFraction=1;
            end
            if ApproxLossFraction<0
                if SampleSeverity==0
                    ApproxLossFraction=0;
                elseif SampleSeverity>0
                    ApproxLossFraction=0.001; % if a small severity leads to 0 due to fit, set to a a minimal percent loss 0.1%
                end
            end
        
        % if a growth stage is supplied (for individual fields) 
        elseif nargin==3
            
            % get growth stage of wheat in surveyed field
            iGS=varargin{1};
            
            % get empirical relation between severity and 
            % yield loss for this growth stage from (Roelfs, 1992) 
            if iGS==1
                
                % GS category 1 in surveys corresponds to "tillering"; in
                % table 23, Roelfs, 1992, p.51, there is no category of growth stage called
                % tillering because a slightly different categorization scheme
                % appears to be used. As both growth stage scales have 6 categories, assume
                % that category 1 in surveys corresponds to cateogry 1 in
                % table 23 (Roelfs, 1992) (i.e. very early growth stages) and define.
                Severity=[0,5,10];
                YieldLoss=[0,75,100];
            
            elseif iGS==2
                
                % GS category 2 in surveys corresponds to "boot"; assume category 2 in surveys corresponds 
                % to category 2 in table 23 (Roelfs, 1992)
                Severity=[0,5,10,25];
                YieldLoss=[0,50,75,100];
            
            elseif iGS==3  
                
                % GS category 3 corresponds to "flowering" in surveys; assume
                % correspondance to category 3 in table 23 (Roelfs, 1992)
                Severity=[0,5,10,25,40];
                YieldLoss=[0,15,50,75,100];
            
            elseif iGS==4 || iGS==7  
                
                % GS4 in surveys is "milk", GS 7 is introduced only in later years of surveys 
                % to represent "heading"; assume correspondance to 4th
                % category in table 23 (Roelfs, 1992)
                Severity=[0,5,10,25,40,65];
                YieldLoss=[0,5,15,50,75,100];
            
            elseif iGS==5
                
                % 5th category in surveys is "dough". There are two
                % different "doughs" in table 23; assume correspondance to
                % 5th category (Roelfs, 1992)
                Severity=[0,5,10,25,40,65,100];
                YieldLoss=[0,0.5,5,15,50,75,100];
            
            elseif iGS==6
                
                % latest growth stage category in surveys is "maturity";
                % assume correspondance to latest growth stage category in
                % table 23 (Roelfs, 1992)
                Severity=[0,5,10,25,40,65,100];
                YieldLoss=[0,0,0.5,5,15,50,100];            
            
            end % end condition testing growth stage in surveys
        
            % calc. a linear fit for yield loss as a function of severity for this growth stage
            % to approximate yield loss as a function of the severity score
            % given in surveys (which does not necessarily fall int one of
            % the categories given in Roelfs).
            LinearTrend=fitlm(Severity,YieldLoss);
            Rsquared(1)=LinearTrend.Rsquared.Ordinary;
            [p(1),F(1)] = coefTest(LinearTrend);
            ApproxLossFraction=predict(LinearTrend,SampleSeverity)/100;
                   
            % check boundaries
            if ApproxLossFraction>1
                ApproxLossFraction=1;
            end
            if ApproxLossFraction<0
                if SampleSeverity==0
                    ApproxLossFraction=0;
                elseif SampleSeverity>0
                    ApproxLossFraction=0.001; % if small severity that leads to 0 due to fit, set to a a minimal percent loss 0.1%
                end
            end
        end % end conditional for testing growth stage input argument
    % wheat leaf rust 
    elseif strcmp(iRust,"Lr")    
        % check growth stage in surveys and get relation between severity and 
        % yield loss for this growth stage from Roelfs, 1992         
        if nargin==2
            % if no growth stage is provided, use total sample mean GS
            
            % (Roelfs, 1992, p. 51, table 24) provides estimates of yield loss
            % caused by leaf rust as a function of growth stage and severity. 
            % The average growth stage in all surveys is "milk", 
            % so take empirical values for GS milk from Roelfs, 1992 
            SeverityT=[0,25,40,65,100];
            YieldLoss=[0,1,3,10,50];

            % In contrast to stem rust, the values provided in table 24 for leaf
            % rust do not suggest a linear relationship. Hence fit a
            % third order polynomial as a fairly simple function which is
            % used here to approximate the categorical values given in Roelfs 
            QuadraticFit=polyfit(SeverityT,YieldLoss,3);
            YFit=polyval(QuadraticFit,SeverityT);
            ApproxLossFraction=polyval(QuadraticFit,SampleSeverity)/100;

            % check boundaries
            if ApproxLossFraction>1
                ApproxLossFraction=1;
            end
            if ApproxLossFraction<0
                if SampleSeverity==0
                    ApproxLossFraction=0;
                elseif SampleSeverity>0
                    ApproxLossFraction=0.001; % if small severity that leads to 0 due to fit, set to a a minimal percent loss 0.1%
                end
            end
        % if a growth stage is supplied (for individual fields)
        elseif nargin==3
            iGS=varargin{1};
            if iGS==1
                
                % GS category 1 in surveys corresponds to "tillering"; in
                % table 24 (Roelfs, 1992) there is pre-tillering and jointing. Take
                % jointing as it appears closest
                Severity=[0,10,25,40,65,100];
                YieldLoss=[0,10,20,35,50,70];
            
            elseif iGS==2 || iGS==7
                % GS category 2 in surveys corresponds to "boot" and 7 to
                % "heading";  take category "boot to heading" from table 24
                % (Roelfs, 1992)
                Severity=[0,10,25,40,65,100];
                YieldLoss=[0,3,10,20,35,50];
            elseif iGS==3 
                
                % GS category 3 in surveys corresponds to "flowering"; assume category
                % "flowering" from table 24 (Roelfs, 1992)
                Severity=[0,10,25,40,65,100];
                YieldLoss=[0,1,3,10,20,50];
            
            elseif iGS==4
                
                % GS category 4 in surveys corresponds to "milk"; 
                % assume category "milk" from table 24 (Roelfs, 1992)
                Severity=[0,25,40,65,100];
                YieldLoss=[0,1,3,10,35];
            
            elseif iGS==5 || iGS==6 
                
                % GS category 5 and 6 in surveys correspond to "dough" and
                % "ripe"; assume category "early dough" as it
                % is the latest growth stage provided in table 24 (Roelfs, 1992)
                % (potentially overestimating losses? but seem low already)
                Severity=[0,40,65,100];
                YieldLoss=[0,1,3,10];
            
            end % end conditional testing growth stage in surveys    
            
            % In contrast to stem rust, the values provided in table 24 for leaf
            % rust do not suggest a linear relationship. Hence fit a
            % third order polynomial as a fairly simple function which is
            % used here to approximate the categorical values given in Roelfs 
            QuadraticFit=polyfit(Severity,YieldLoss,3);
            YFit=polyval(QuadraticFit,Severity);
            ApproxLossFraction=polyval(QuadraticFit,SampleSeverity)/100;

            % check boundaries
            if ApproxLossFraction>1
                ApproxLossFraction=1;
            end
            if ApproxLossFraction<0
                if SampleSeverity==0
                    ApproxLossFraction=0;
                elseif SampleSeverity>0
                    ApproxLossFraction=0.001; % if small severity that leads to 0 due to fit, set to a a minimal percent loss 0.1%
                end
            end            
        end % end conditional testing input argument
    % wheat stripe rust
    elseif strcmp(iRust,"Yr")
        if nargin==2
            
            % If no growth stage provided, assume sample mean GS.
            % For estimating yield loss as a function of severity and growth stage, 
            % use the empirical formula given in (Roelfs, 1992, p.59; formula for later growth stages, because first formula is for
            % flowering, which is before milk, the sample mean GS in survey data.
            ApproxLossFraction=(0.44*SampleSeverity+3.15)/100;
            
        % if a growth stage is supplied (for individual fields)
        elseif nargin==3
            iGS=varargin{1};
            % if growth stage is provided, use that information to pick the corresponding
            % empirical relation from Roelfs, 1992 (there are different
            % empirical relations given depending on the growth stage of the data)
            if iGS==1 || iGS==2 || iGS==3 || iGS==7 % note that GS 7 corresponds to heading, i.e. early growth stage
                
                % use formula/params provided in Roelfs, 1992, p.59, for early
                % growth stages
                ApproxLossFraction=(0.442*SampleSeverity+13.18)/100;
            
            elseif iGS==4 || iGS==5 || iGS==6
                
                % use formula/params provided in Roelfs, 1992, p.59, for later
                % growth stages (smaller losses)
                ApproxLossFraction=(0.44*SampleSeverity+3.15)/100;
            
            end % end conditional testing growth stage            
        end % end conditional testing if growth stage is provided
    end % end conditional testing type of rust
    
    close all;

end

