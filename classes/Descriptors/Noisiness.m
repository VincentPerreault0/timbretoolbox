classdef Noisiness < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Noisiness';
        repType = 'Harmonic';
        descrFamilyLeader = 'FrameErg';
    end
    
    methods
        function noisiness = Noisiness(tfDistr, tSupport, value)
            
            noisiness = noisiness@TVDescr(tfDistr);
            
            noisiness.tSupport = tSupport;
            
            noisiness.value = value;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = eval(['descr.rep.descrs.' descr.descrFamilyLeader '.HasSameConfig(config)']);
        end
    end
    
end