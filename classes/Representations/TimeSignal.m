classdef (Abstract) TimeSignal < Rep
    %TIMESIGNAL Abstract class for time signal representations.
    %   This class is the parent of all representations of type time
    %   signal : AudioSignal & TEE.
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        sound       % SoundFile object of which it is a representation.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the time signal (line vector of the same 
                    %   length as tSupport).
    end
    properties (Abstract, Access = public)
        descrs      % Structure containing all the representation's 
                    %   possible descriptors. All fields correspond to a
                    %   possible descriptor type and are instantiated with
                    %   a value of 0 (see Rep's getDescrTypes() method).
    end
    properties (Constant)
        exceptions = {'exceptions'} % The properties with default values
                                    %     that should not be exported (in
                                    %     .csv format).
    end
    methods (Abstract)
        sameConfig = HasSameConfig(rep, config)
    end
    methods (Access = public)
        function timeSig = TimeSignal(sound)
            %CONSTRUCTOR From a SoundFile, instantiates a TimeSignal
            %object.
            %   Keeps a reference to the original SoundFile in the sound
            %   property and instantiates its descrs property.
            
            timeSig = timeSig@Rep(sound);
        end
        
        function PlotAndYLabel(timeSig, ax, alone, timeRes)
            %PLOTANDYLABEL Plots the TimeSignal in the specified axes.
            %   Plots the TimeSignal object in the specified axes at the
            %   specified time resolution. If it is to be plotted alone in
            %   the figure, a title and an x-label will be added as well.
            
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
            %EXPORTCSVVALUE Exports the value of the TimeSignal in the
            %specified .csv file.
            %   Exports the TimeSignal's value in the specified value type
            %   ('ts' for the time series at the specified time resolution
            %   and 'stats' for the minimum, maximum, median and
            %   interquartile range statistics) in the specified .csv file
            %   with the specified .csv file name in the specified
            %   directory.
            
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
