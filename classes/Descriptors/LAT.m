classdef LAT < GlobDescr
    %LAT Class for Log-time of the attack segment descriptor (as if the
    %sound was a single synthesized note).
    
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
        unit = 'sec'
        % Unit of the descriptor.
    end
    
    methods
        function lat = LAT(tee, tSupport, value)
            %CONSTRUCTOR From the representation, tSupport and value, the
            %descriptor is created.
            
            lat = lat@GlobDescr(tee);
            
            lat.tSupport = tSupport;
            
            lat.value = value;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = eval(['descr.rep.descrs.' descr.descrFamilyLeader '.HasSameConfig(config)']);
        end
    end
    
end