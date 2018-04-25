classdef (Abstract) TimeSignal < Rep
    %Time-frequency distribution representation
    properties (Abstract, GetAccess = public, SetAccess = protected)
        sound        % Sound object of which it is a representation
        
        tSupport %(in seconds)
        
        value
    end
    properties (Abstract, Access = public)
        descrs % structure containing possible descriptors of this representation
    end
    methods (Abstract)
        sameConfig = HasSameConfig(rep, config)
    end
    properties (Constant)
        exceptions = {'exceptions'}
    end
    methods (Access = public)
        function timeSig = TimeSignal(sound)
            timeSig = timeSig@Rep(sound);
        end
        
        function PlotAndYLabel(timeSig, ax, alone, timeRes)
            [tSup, val] = timeSig.EvalTimeRes(timeRes);
            plot(ax, tSup, val);
            soundLen = (timeSig.sound.info.TotalSamples-1)/timeSig.sound.info.SampleRate;
            if min(val) < 0
                axis(ax,[0, max(soundLen, tSup(end)), -1.025*max(abs(val)), 1.025*max(abs(val))]);
            else
                axis(ax,[0, max(soundLen, tSup(end)), 0.975*min(val), 1.025*max(val)]);
            end
            ylabel(ax, class(timeSig));
            if alone
                title(ax, [class(timeSig) ' Representation']);
                xlabel(ax, 'Time (s)');
            end
        end
        
        function csvfile = ExportCSVValue(timeSig, csvfile, directory, csvfileName, valueType, timeRes)
            if strcmp(valueType, 'ts')
                [tSup, val] = timeSig.EvalTimeRes(timeRes);
                fprintf(csvfile, 'Time Support Vector,Value Vector\n');
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],[tSup', val'],'-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
            else
                fprintf(csvfile, 'Minimum,%s\n', num2str(min(timeSig.value)));
                fprintf(csvfile, 'Maximum,%s\n', num2str(max(timeSig.value)));
                fprintf(csvfile, 'Median,%s\n', num2str(median(timeSig.value)));
                fprintf(csvfile, 'Interquartile Range,%s\n', num2str(iqr(timeSig.value)));
            end
        end
    end
end
