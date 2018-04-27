classdef (Abstract) TimeFreqDistr < GenTimeFreqDistr
    %TIMEFREQDISTR Abstract class for time-frequency distribution 
    %representations.
    %   This class is the parent of all representations of type
    %   time-frequency distribution : STFT & ERB.
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        sound       % SoundFile object of which it is a representation.
        hopSize     % Hop size of the window (in samples). Determines the 
                    %   time resolution of the representation.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        tSize       % Length of the temporal support vector.
        fSupport    % Frequency support column vector that indicates to
                    %   what frequencies the bins (lines) of the value
                    %   refer to (in Hz).
        fSize       % Length of the frequency support vector.
        value       % Value of the time-frequency distribution (fSize by
                    %   tSize matrix).
    end
    properties (Abstract, Access = public)
        descrs      % Structure containing all the representation's 
                    %   possible descriptors. All fields correspond to a
                    %   possible descriptor type and are instantiated with
                    %   a value of 0 (see Rep's getDescrTypes() method).
    end
    methods (Abstract)
        sameConfig = HasSameConfig(rep, config)
    end
    properties (Constant)
        exceptions = {'exceptions'}
    end
    methods (Access = public)
        function tfDistr = TimeFreqDistr(sound)
            %CONSTRUCTOR From a SoundFile, instantiates a TimeFreqDistr
            %object.
            %   Keeps a reference to the original SoundFile in the sound
            %   property and instantiates its descrs property.
            
            tfDistr = tfDistr@GenTimeFreqDistr(sound);
        end
        
        function PlotAndYLabel(tfDistr, ax, alone, timeRes)
            %PLOTANDYLABEL Plots the TimeFreqDistr in the specified axes.
            %   Plots the TimeFreqDistr object in the specified axes at the
            %   specified time resolution. If it is to be plotted alone in
            %   the figure, a title and an x-label will be added as well.
            
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
            %EXPORTCSVVALUE Exports the value of the TimeFreqDistr in the
            %specified .csv file.
            %   Exports the TimeFreqDistr's value in the specified value
            %   type ('ts' for the time series at the specified time
            %   resolution and 'stats' for the minimum, maximum, median and
            %   interquartile range statistics) in the specified .csv file
            %   with the specified .csv file name in the specified
            %   directory.
            
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
