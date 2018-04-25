classdef LAT < GlobDescr
    % Log-time of the attack segment (as if the sound was a single synthesized note)
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        repType = 'TEE';
        descrFamilyLeader = 'Att';
        unit = 'sec'
    end
    
    methods
        function lat = LAT(tee, tSupport, value)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold         - See properties
            lat = lat@GlobDescr(tee);
            
            lat.tSupport = tSupport;
            
            lat.value = value;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = eval(['descr.rep.descrs.' descr.descrFamilyLeader '.HasSameConfig(config)']);
        end
    end
    
end