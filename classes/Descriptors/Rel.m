classdef Rel < GlobDescr
    % End time of the release (as if the sound was a single synthesized note)
    
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
        function rel = Rel(tee, tSupport, value)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold         - See properties
            rel = rel@GlobDescr(tee);
            
            rel.tSupport = tSupport;
            
            rel.value = value;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = eval(['descr.rep.descrs.' descr.descrFamilyLeader '.HasSameConfig(config)']);
        end
    end
    
end