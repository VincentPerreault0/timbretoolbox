classdef (Abstract) Descr < TimeSeries
    % An abstract class for descriptors.
    
    properties (Abstract, GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that 
                    % indicates at what times the data refers to (in
                    % seconds).
        value
        rep
    end
    
    properties (Abstract, Constant)
        repType
        descrFamilyLeader
        exceptions
    end
    
    methods (Abstract)
        PlotAndYLabel(descr, axes, alone, timeRes)
        
        csvfile = ExportCSVValue(descr, csvfile, directory, csvfileName, valueType, timeRes)
        
        sameConfig = HasSameConfig(rep, config)
    end
    
    methods
        function descr = Descr(rep)
            if strcmp(descr.repType, class(rep)) || ...
                    ismember(descr.repType, superclasses(class(rep)))
                descr.rep = rep;
            else
                error(['A ' class(descr) ' descriptor can only be instantiated from a ' descr.repType ' representation.'])
            end
        end
    end
    
end
