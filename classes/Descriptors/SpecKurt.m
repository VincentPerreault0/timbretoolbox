classdef SpecKurt < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Spectral Kurtosis';
        repType = 'GenTimeFreqDistr';
        descrFamilyLeader = 'SpecCent';
    end
    
    methods
        function specKurt = SpecKurt(gtfDistr, tSupport, value)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            specKurt = specKurt@TVDescr(gtfDistr);
            
            specKurt.tSupport = tSupport;
            
            specKurt.value = value;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = eval(['descr.rep.descrs.' descr.descrFamilyLeader '.HasSameConfig(config)']);
        end
    end
    
end