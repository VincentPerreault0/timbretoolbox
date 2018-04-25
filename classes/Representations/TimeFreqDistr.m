classdef (Abstract) TimeFreqDistr < GenTimeFreqDistr
    %Time-frequency distribution representation
    properties (Abstract, GetAccess = public, SetAccess = protected)
        sound        % Sound object of which it is a representation
        
        hopSize
        
        tSupport %(in seconds)
        tSize
        tSampRate
        
        fSupport %(in Hz)
        fSize
        fSampRate
        
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
        function tfDistr = TimeFreqDistr(sound)
            tfDistr = tfDistr@GenTimeFreqDistr(sound);
        end
        
        function PlotAndYLabel(tfDistr, ax, alone, timeRes)
            [tSup, val] = tfDistr.EvalTimeRes(timeRes);
            axes(ax);
            logDistr = log(val+eps);
            maxLogDistr=max(max(logDistr));
            logDistr(logDistr < maxLogDistr-15) = maxLogDistr-15;
            imagesc(tSup, tfDistr.fSupport, logDistr);
            soundLen = (tfDistr.sound.info.TotalSamples-1)/tfDistr.sound.info.SampleRate;
            axis(ax,[0 soundLen 0 16000]);
            ylabel(ax, class(tfDistr));
            clrMap = colormap(ax, 'gray'); %colormap(); % for color
            colormap(ax, 1 - clrMap);
            axis(ax,'xy');
            if alone
                title(ax, [class(tfDistr) ' Representation']);
                xlabel(ax, 'Time (s)');
            end
        end
        
        function csvfile = ExportCSVValue(tfDistr, csvfile, directory, csvfileName, valueType, timeRes)
            if strcmp(valueType, 'ts')
                [tSup, val] = tfDistr.EvalTimeRes(timeRes);
                fprintf(csvfile, '-1,Frequency Support Vector\n');
                fprintf(csvfile, 'Time Support Vector,Value Matrix\n');
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],[[-1, tfDistr.fSupport'];[tSup', val']],'-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
            elseif strcmp(valueType, 'stats')
                fprintf(csvfile, 'Minimums,\n');
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],min(tfDistr.value,[],2)','-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
                fprintf(csvfile, 'Maximums,\n');
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],max(tfDistr.value,[],2)','-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
                fprintf(csvfile, 'Medians,\n');
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],median(tfDistr.value,2)','-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
                fprintf(csvfile, 'Interquartile Ranges,\n');
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],iqr(tfDistr.value,2)','-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
            end
        end
    end
end
