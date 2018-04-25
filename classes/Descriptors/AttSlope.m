classdef AttSlope < GlobDescr
    % Weighted mean of the slope of the attack (as if the sound was a single synthesized note)
    
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
        unit = 'sec^(-1)'
    end
    
    methods
        function attSlope = AttSlope(tee, tSupport, value)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold         - See properties
            attSlope = attSlope@GlobDescr(tee);
            
            attSlope.tSupport = tSupport;
            
            attSlope.value = value;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = eval(['descr.rep.descrs.' descr.descrFamilyLeader '.HasSameConfig(config)']);
        end
    end
    
end