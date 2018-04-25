classdef (Abstract) TVDescr < Descr
    % An abstract class for time-varying descriptors.
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % seconds).
        value
        rep
    end
    
    properties (Abstract, Constant)
        yLabel
        repType
        descrFamilyLeader
    end
    properties (Constant)
        exceptions = {'exceptions', 'yLabel', 'repType', 'descrFamilyLeader'}
    end
    methods (Abstract)
        sameConfig = HasSameConfig(rep, config)
    end
    methods
        function descr = TVDescr(rep)
            descr = descr@Descr(rep);
        end
        
        function PlotAndYLabel(descr, ax, alone, timeRes)
            valueSize = size(descr.value);
            [tSup, val] = descr.EvalTimeRes(timeRes);
            if any(valueSize == 1)
                plot(ax, tSup, val);
            else
                width = valueSize(1);
                legnd = cell(1, width);
                for i = 1:width
                    plot(ax, tSup, val(i,:));
                    legnd{i} = [descr.yLabel ' Coeff. #' num2str(i)];
                    if i == 1
                        hold(ax, 'on');
                    end
                end
                hold(ax, 'off');
                legend(ax, legnd);
                ylabel(ax, descr.yLabel);
            end
            soundLen = (descr.rep.sound.info.TotalSamples-1)/descr.rep.sound.info.SampleRate;
            if min(min(val)) < 0
                axis(ax,[0, soundLen, 1.025*min(min(val)), 1.025*max(max(val))]);
            else
                axis(ax,[0, soundLen, 0.975*min(min(val)), 1.025*max(max(val))]);
            end
            ylabel(ax, descr.yLabel);
            if alone
                xlabel(ax, 'Time (s)');
            end
        end
        
        function csvfile = ExportCSVValue(descr, csvfile, directory, csvfileName, valueType, timeRes)
            if strcmp(valueType, 'ts')
                [tSup, val] = descr.EvalTimeRes(timeRes);
                if size(val,1) == 1
                    fprintf(csvfile, 'Time Support Vector,Value Vector\n');
                else
                    fprintf(csvfile, 'Time Support Vector,Value Matrix\n');
                end
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],[tSup', val'],'-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
            else
                if size(descr.value,1) == 1
                    fprintf(csvfile, 'Minimum,%s\n', num2str(min(descr.value)));
                    fprintf(csvfile, 'Maximum,%s\n', num2str(max(descr.value)));
                    fprintf(csvfile, 'Median,%s\n', num2str(median(descr.value)));
                    fprintf(csvfile, 'Interquartile Range,%s\n', num2str(iqr(descr.value)));
                else
                    fprintf(csvfile, 'Minimums,\n');
                    fclose(csvfile);
                    dlmwrite([directory '/' csvfileName '.csv'],min(descr.value,[],2)','-append','newline','unix','precision',10);
                    csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
                    fprintf(csvfile, 'Maximums,\n');
                    fclose(csvfile);
                    dlmwrite([directory '/' csvfileName '.csv'],max(descr.value,[],2)','-append','newline','unix','precision',10);
                    csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
                    fprintf(csvfile, 'Medians,\n');
                    fclose(csvfile);
                    dlmwrite([directory '/' csvfileName '.csv'],median(descr.value,2)','-append','newline','unix','precision',10);
                    csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
                    fprintf(csvfile, 'Interquartile Ranges,\n');
                    fclose(csvfile);
                    dlmwrite([directory '/' csvfileName '.csv'],iqr(descr.value,2)','-append','newline','unix','precision',10);
                    csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
                end
            end
        end
    end
    
end

