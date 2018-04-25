classdef NoiseErg < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Noise Energy';
        repType = 'Harmonic';
        descrFamilyLeader = 'FrameErg';
    end
    
    methods
        function noiseErg = NoiseErg(tfDistr, tSupport, value)
            
            noiseErg = noiseErg@TVDescr(tfDistr);
            
            noiseErg.tSupport = tSupport;
            
            noiseErg.value = value;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = eval(['descr.rep.descrs.' descr.descrFamilyLeader '.HasSameConfig(config)']);
        end
    end
    
end