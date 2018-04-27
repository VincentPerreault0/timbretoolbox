classdef HarmErg < TVDescr
    %HARMERG Class for the harmonic energy descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Constant)
        yLabel = 'Harmonic Energy';
        % y-Label of the descriptor when it is plotted.
        repType = 'Harmonic';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = 'FrameErg';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function harmErg = HarmErg(tfDistr, tSupport, value)
            %CONSTRUCTOR From the representation, tSupport and value, the
            %descriptor is created.
            
            harmErg = harmErg@TVDescr(tfDistr);
            
            harmErg.tSupport = tSupport;
            
            harmErg.value = value;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = eval(['descr.rep.descrs.' descr.descrFamilyLeader '.HasSameConfig(config)']);
        end
    end
    
end