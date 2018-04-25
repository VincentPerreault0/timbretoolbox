classdef HarmErg < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Harmonic Energy';
        repType = 'Harmonic';
        descrFamilyLeader = 'FrameErg';
    end
    
    methods
        function harmErg = HarmErg(tfDistr, tSupport, value)
            
            harmErg = harmErg@TVDescr(tfDistr);
            
            harmErg.tSupport = tSupport;
            
            harmErg.value = value;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = eval(['descr.rep.descrs.' descr.descrFamilyLeader '.HasSameConfig(config)']);
        end
    end
    
end