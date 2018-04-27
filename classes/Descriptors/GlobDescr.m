classdef (Abstract) GlobDescr < Descr
    %GLOBDESCR Abstract class for all global descriptors.
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal range vector (in seconds), of the form
                    %   [starttime, endtime].
        value       % Value of the descriptor.
    end
    
    properties (Abstract, Constant)
        repType     % Class of the representation or abstract class of the
                    %   representation type of which it can be a
                    %   descriptor.
        descrFamilyLeader   % Name of the class of the descriptor that
                            %   evaluates its value. If empty, the
                            %   descriptor evaluates its own value.
        unit        % Unit of the descriptor.
    end
    properties (Constant)
        exceptions = {'exceptions', 'repType', 'descrFamilyLeader'}
        % The properties with default values that should not be exported
        %   (in .csv format).
    end
    methods (Abstract)
        sameConfig = HasSameConfig(rep, config)
    end
    methods
        function descr = GlobDescr(rep)
            %CONSTRUCTOR From a Rep, instantiates a GlobDescr object.
            %   Keeps a reference to the original Rep in the rep
            %   property.
            descr = descr@Descr(rep);
        end
        function PlotAndYLabel(descr)
            %PLOTANDYLABEL Displays the GlobDescr's value
            %   Displays in the command window the value of the global
            %   descriptor.
            disp([class(descr) ': ' num2str(descr.value) ' ' eval([class(descr) '.unit'])])
        end
        function [tSup, val] = EvalTimeRes(globDescr, timeRes)
            %EVALTIMERES Not available for global descriptors.
            %   Overwrites the TimeSeries function to output an error if
            %   called.
            error('Global Descriptor do not have time resolution...');
        end
        function csvfile = ExportCSVValue(descr, csvfile, directory, csvfileName, valueType, timeRes)
            %EXPORTCSVVALUE Exports the value of the GlobDescr in the
            %specified .csv file.
            %   Exports the GlobDescr's value (no matter the value type) in
            %   the specified .csv file with the specified .csv file name
            %   in the specified directory.
            fprintf(csvfile, 'Value,%s\n', num2str(descr.value));
        end
    end
end

