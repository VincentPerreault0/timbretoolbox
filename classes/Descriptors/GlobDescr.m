classdef (Abstract) GlobDescr < Descr
    % An abstract class for global descriptors.
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        tSupport    % All Global Descr classes have a temporal support vector
        % that indicates at what times the data strats ands
        % stops to refer to (in seconds).
        value
        rep
    end
    
    properties (Abstract, Constant)
        repType
        descrFamilyLeader
        unit
    end
    properties (Constant)
        exceptions = {'exceptions', 'repType', 'descrFamilyLeader'}
    end
    methods (Abstract)
        sameConfig = HasSameConfig(rep, config)
    end
    methods
        function descr = GlobDescr(rep)
            descr = descr@Descr(rep);
        end
        function PlotAndYLabel(descr)
            disp([class(descr) ': ' num2str(descr.value) ' ' eval([class(descr) '.unit'])])
        end
        function [tSup, val] = EvalTimeRes(globDescr, timeRes)
            error('Global Descriptor do not have time resolution...');
        end
        function csvfile = ExportCSVValue(descr, csvfile, directory, csvfileName, valueType, timeRes)
            fprintf(csvfile, 'Value,%s\n', num2str(descr.value));
        end
    end
end

