classdef (Abstract) TimeSeries < TTObject
    % An abstract class for descriptors.
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that 
                    % indicates at what times the data refers to (in
                    % seconds).
        value
    end
    properties (Abstract, Constant)
        exceptions
    end
    
    methods (Abstract)
        PlotAndYLabel(descr, axes, alone, timeRes)
        
        csvfile = ExportCSVValue(timeSeries, csvfile, directory, csvfileName, valueType, timeRes)
    end
    
    methods
        function [tSup, val] = EvalTimeRes(timeSeries, timeRes)
            if timeRes == 0% || isa(timeSeries, 'AudioSignal')
                tSup = timeSeries.tSupport;
                val = timeSeries.value;
            else
                timeStep = 1/timeRes;
                tSupportStep = mean(diff(timeSeries.tSupport));
                timeStepMult = ceil(timeStep/tSupportStep);
                if timeStepMult > 1
                    tSup = timeSeries.tSupport(ceil(timeStepMult/2):timeStepMult:(end-floor(timeStepMult/2)));
                    tmp = zeros(timeStepMult, size(timeSeries.value,1), length(tSup));
                    for i = 1:timeStepMult
                        tmp(i,:,:) = timeSeries.value(:, i:timeStepMult:(end-timeStepMult+i));
                    end
                    val = squeeze(mean(tmp));
                    if size(val, 2) ~= length(tSup)
                        val = val';
                    end
                else
                    tSup = timeSeries.tSupport;
                    val = timeSeries.value;
                end
            end
        end
        
        function csvfile = ExportCSV(ts, csvfile, directory, csvfileName, valueType, timeRes, header)
            if header
                if abs(header) < 2
                    if isa(ts, 'Rep')
                        fprintf(csvfile, 'Representation,%s\n', class(ts));
                    elseif isa(ts, 'Descr')
                        fprintf(csvfile, 'Descriptor,%s\n', class(ts));
                    end
                end
                mc = metaclass(ts);
                metaProps = mc.PropertyList;
                for i = 1:length(metaProps)
                    prop = metaProps(i).Name;
                    if metaProps(i).HasDefault && ~any(strcmp(prop, ts.exceptions))
                        if isa(ts.(prop), 'TimeSeries')
                            csvfile = ts.(prop).ExportCSV(csvfile, directory, csvfileName, {}, [], -2);
                        elseif isa(ts.(prop), 'double')
                            if length(ts.(prop)) == 1
                                fprintf(csvfile, '%s,%s\n', [upper(prop(1)) prop(2:end)], num2str(ts.(prop)));
                            else
                                fprintf(csvfile, '%s,[', [upper(prop(1)) prop(2:end)]);
                                for j = 1:length(ts.(prop))
                                    if j < length(ts.(prop))
                                        fprintf(csvfile, '%s;', num2str(ts.(prop)(j)));
                                    else
                                        fprintf(csvfile, '%s]\n', num2str(ts.(prop)(j)));
                                    end
                                end
                            end
                        else
                            fprintf(csvfile, '%s,%s\n', [upper(prop(1)) prop(2:end)], ts.(prop));
                        end
                    end
                end
            end
            if header >= 0
                csvfile = ts.ExportCSVValue(csvfile, directory, csvfileName, valueType, timeRes);
            end
            if abs(header) < 2
                fprintf(csvfile, '\n');
            end
        end
    end
    
end
