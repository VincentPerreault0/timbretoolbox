classdef (Abstract) TimeSeries < TTObject
    %TIMESERIES Abstract class containing all vector-valued time series.
    %   This class is the parent of all representations and descriptors.
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value matrix of the object (dimension by
                    %   length(tSupport) matrix), whether it is a
                    %   representation or a descriptor.
    end
    properties (Abstract, Constant)
        exceptions  % The properties with default values that should not be
                    %    exported (in .csv format).
    end
    
    methods (Abstract)
        PlotAndYLabel(descr, axes, alone, timeRes)
        
        csvfile = ExportCSVValue(timeSeries, csvfile, directory, csvfileName, valueType, timeRes)
    end
    
    methods
        function [tSup, val] = EvalTimeRes(timeSeries, timeRes)
            %EVALTIMERES Downsamples the time series at a lower time
            %resolution.
            %   Unless the specified time resolution timeRes is 0 or is
            %   greater than the time series' full time resolution, the
            %   time series is re-evaluated at the specified time
            %   resolution.
            if timeRes == 0
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
            %EXPORTCSV Exports the time series in the specified .csv file.
            %   Depending on the header parameter, the name of the class
            %   could be exported (|header| < 2 & header ~= 0), the
            %   parameters of the object could be exported (header ~= 0)
            %   and the time series' value could be exported (header >= 0).
            %   The value type ('ts' or 'stats') indicates whether the time
            %   series' value should be exported respectiely as a whole
            %   (possibly at a lower time resolution) or as statistics
            %   (minimum, maximum, median and interquartile range).
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
