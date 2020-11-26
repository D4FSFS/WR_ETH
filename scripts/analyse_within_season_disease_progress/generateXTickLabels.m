function [XTickLabelVec]=GenerateXTickLabels()
        
        % function to define x-tick levels with bi-weekly time-intervals

        %WeeklyLabels1='\begin{tabular}{c} 1st Aug. - \\ 14th Aug. \end{tabular}';
        WeeklyLabels2='\begin{tabular}{c} 15th Aug. - \\ 28th Aug. \end{tabular}';
        WeeklyLabels3='\begin{tabular}{c} 29th Aug. - \\ 11th Sep. \end{tabular}';
        WeeklyLabels4='\begin{tabular}{c} 12th Sep - \\ 25th Sep. \end{tabular}';
        WeeklyLabels5='\begin{tabular}{c} 26th Sep. - \\ 9th Oct \end{tabular}';
        WeeklyLabels6='\begin{tabular}{c} 10th Oct. - \\ 23th Oct. \end{tabular}';
        WeeklyLabels7='\begin{tabular}{c} 24th Oct. - \\ 6th Nov. \end{tabular}';
        WeeklyLabels8='\begin{tabular}{c} 7th Nov. - \\  20th Nov. \end{tabular}';
        WeeklyLabels9='\begin{tabular}{c} 21st Nov. - \\ 4th Dec. \end{tabular}';
        WeeklyLabels10='\begin{tabular}{c} 5th Dec. - \\ 18th Dec. \end{tabular}';
        WeeklyLabels11='\begin{tabular}{c} 19th Dec - \\ 1st Jan. \end{tabular}';
        XTickLabelVec={WeeklyLabels2;WeeklyLabels3;WeeklyLabels4;WeeklyLabels5;WeeklyLabels6;WeeklyLabels7;WeeklyLabels8;WeeklyLabels9;WeeklyLabels10;WeeklyLabels11};

end

