function [AllPropsReordered,NumberSurveysPerWheatVarietyReordered] = reorderWheatVarietiesForPlotting(AllProps,NumberSurveysPerWheatVariety)
            
            % function for reordering the bars for plotting

            AllPropsReordered(1,:)=AllProps(3,:); % write Kubsa from row 3 into row 1 as it is the most frequent var 
            AllPropsReordered(2,:)=AllProps(4,:); % write Digalue from row 4 into row 2 " "
            AllPropsReordered(3,:)=AllProps(5,:); % write Kakaba from row 5 into row 3 " "
            AllPropsReordered(4,:)=AllProps(6,:); % write Ogolcho from row 6 into row 4 " "
            AllPropsReordered(5,:)=AllProps(7,:); % write Dandaa from row 7 into row 5 " "
            AllPropsReordered(6,:)=AllProps(1,:); % write all categorized as local into row 6, behind the key varieties
            AllPropsReordered(7,:)=AllProps(2,:); % write all categorized as improved into row 7
            AllPropsReordered(8,:)=AllProps(8,:); % write the rest, i.e. all entries not classified into one of the above
            
            NumberSurveysPerWheatVarietyReordered(1)=NumberSurveysPerWheatVariety(3);
            NumberSurveysPerWheatVarietyReordered(2)=NumberSurveysPerWheatVariety(4);
            NumberSurveysPerWheatVarietyReordered(3)=NumberSurveysPerWheatVariety(5);
            NumberSurveysPerWheatVarietyReordered(4)=NumberSurveysPerWheatVariety(6);
            NumberSurveysPerWheatVarietyReordered(5)=NumberSurveysPerWheatVariety(7);
            NumberSurveysPerWheatVarietyReordered(6)=NumberSurveysPerWheatVariety(1);
            NumberSurveysPerWheatVarietyReordered(7)=NumberSurveysPerWheatVariety(2);
            NumberSurveysPerWheatVarietyReordered(8)=NumberSurveysPerWheatVariety(8);
end

