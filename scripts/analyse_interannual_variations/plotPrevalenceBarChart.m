function PlotPrevalenceBarChart(AllProps,NumberSurveysPerYear,colorsBarChart,iDisStrLeg,iRustStr,figName)
% function to plot bar chart of rust prevalence per year
                        
            % plot prop. positives in categories (low, mod., high)
            PropsPositives=AllProps(:,1:3);
            TotProp=PropsPositives(:,1)+PropsPositives(:,2)+PropsPositives(:,3);
            NumberSurveys=flipud(NumberSurveysPerYear(:,1));

            figure

            % plot bars
            b=bar(PropsPositives,'stacked','BarWidth',0.7);
            
            % set grid lines
            grid on
            
            % set colors of bars
            b(1).FaceColor=colorsBarChart(3,:); % high in darker at bottom
            b(2).FaceColor=colorsBarChart(2,:);
            b(3).FaceColor=colorsBarChart(1,:); % low in lighter at top
               
            % write number of surveys on top of axis
            XTickTopVec={};
            for i=1:length(AllProps)
                XTickTopVec{i}=['n=',num2str(NumberSurveys(i))];
            end         
            xt = get(gca, 'XTick');
            y=ones(1,length(TotProp))+0.13;
            if strcmp(iDisStrLeg,'incidence')
                t=text(xt,y,XTickTopVec,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',12);
                set(t,'Rotation',45);  
            end
           
            
            % set axis ticks and labels
            if strcmp(iDisStrLeg,'incidence')
               set(gca,'XTickLabel',[],'XLim',[0,11],'YLim',[0,1],'FontSize',12);
            elseif strcmp(iDisStrLeg,'severity')
               set(gca,'XTickLabel',{'2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'},'XLim',[0,11],'YLim',[0,1],'FontSize',12);
            end
            rotateXLabels(gca(),45);
            ylabel('Prevalence','FontSize',12);
            %xlabel('Year','FontSize',12);
            
                        
            % set legend
            legend([b(3),b(2),b(1)],[iRustStr,' ','low',' ',iDisStrLeg],[iRustStr,' ','moderate',' ',iDisStrLeg],[iRustStr,' ','high',' ',iDisStrLeg],'FontSize',10);
            
            % set size / margin ratio
            %set(gcf, 'Units', 'centimeters', 'Position', [3, 3, 10, 8], 'PaperUnits', 'centimeters', 'PaperSize', [12, 12])
            pos = get(gca, 'Position');
            pos(4) = 0.7;
            set(gca, 'Position', pos)
            
            % write to file
            print(figName,'-dpng','-r300');
           
end
