classdef (Abstract) TVDescr < Descr
    %TVDESCR Abstract class for all time-varying descriptors.
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Abstract, Constant)
        repType     % Class of the representation or abstract class of the
                    %   representation type of which it can be a
                    %   descriptor.
        descrFamilyLeader   % Name of the class of the descriptor that
                            %   evaluates its value. If empty, the
                            %   descriptor evaluates its own value.
        yLabel      % y-Label of the descriptor when it is plotted.
    end
    properties (Constant)
        exceptions = {'exceptions', 'yLabel', 'repType', 'descrFamilyLeader'}
        % The properties with default values that should not be exported
        %   (in .csv format).
    end
    methods (Abstract)
        sameConfig = HasSameConfig(rep, config)
    end
    methods
        function descr = TVDescr(rep)
            %CONSTRUCTOR From a Rep, instantiates a TVDescr object.
            %   Keeps a reference to the original Rep in the rep
            %   property.
            descr = descr@Descr(rep);
        end
        
        function PlotAndYLabel(descr, ax, alone, timeRes)
            %PLOTANDYLABEL Plots the TVDescr in the specified axes.
            %   Plots the TVDescr object in the specified axes at the
            %   specified time resolution. If it is to be plotted alone in
            %   the figure, an x-label will be added as well.
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
            %EXPORTCSVVALUE Exports the value of the TVDescr in the
            %specified .csv file.
            %   Exports the TVDescr's value in the specified value type
            %   ('ts' for the time series at the specified time resolution
            %   and 'stats' for the minimum, maximum, median and
            %   interquartile range statistics) in the specified .csv file
            %   with the specified .csv file name in the specified
            %   directory.
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

