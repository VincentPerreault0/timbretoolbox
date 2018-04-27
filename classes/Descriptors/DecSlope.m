classdef DecSlope < GlobDescr
    %DECSLOPE Class for exponential slope of the release descriptor (as if
    %the sound was a single synthesized note).
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal range vector (in seconds), of the form
                    %   [starttime, endtime].
        value       % Value of the descriptor.
    end
    
    properties (Constant)
        repType = 'TEE';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = 'Att';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
        unit = 'sec^(-1)'
        % Unit of the descriptor.
    end
    
    methods
        function decSlope = DecSlope(tee, tSupport, value)
            %CONSTRUCTOR From the representation, tSupport and value, the
            %descriptor is created.
            
            decSlope = decSlope@GlobDescr(tee);
            
            decSlope.tSupport = tSupport;
            
            decSlope.value = value;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = eval(['descr.rep.descrs.' descr.descrFamilyLeader '.HasSameConfig(config)']);
        end
    end
    
end