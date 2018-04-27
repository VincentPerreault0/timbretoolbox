classdef (Abstract) Descr < TimeSeries
    %DESCR Abstract class for all descriptors.
    %   This class is the parent of all descriptor types : TVDescr &
    %   GlobDescr.
    
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
        exceptions  % The properties with default values that should not be
                    %    exported (in .csv format).
    end
    
    methods (Abstract)
        PlotAndYLabel(descr, axes, alone, timeRes)
        
        csvfile = ExportCSVValue(descr, csvfile, directory, csvfileName, valueType, timeRes)
        
        sameConfig = HasSameConfig(rep, config)
    end
    
    methods
        function descr = Descr(rep)
            %CONSTRUCTOR From a Rep, instantiates a Descr object.
            %   Keeps a reference to the original Rep in the rep
            %   property.
            if strcmp(descr.repType, class(rep)) || ...
                    ismember(descr.repType, superclasses(class(rep)))
                descr.rep = rep;
            else
                error(['A ' class(descr) ' descriptor can only be instantiated from a ' descr.repType ' representation.'])
            end
        end
    end
    
end
