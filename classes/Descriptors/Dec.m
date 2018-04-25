classdef Dec < GlobDescr
    % End time of the attack (as if the sound was a single synthesized note)
    
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
        function dec = Dec(tee, tSupport, value)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold         - See properties
            dec = dec@GlobDescr(tee);
            
            dec.tSupport = tSupport;
            
            dec.value = value;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = eval(['descr.rep.descrs.' descr.descrFamilyLeader '.HasSameConfig(config)']);
        end
    end
    
end