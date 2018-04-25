classdef F0 < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Fundamental Frequency (Hz)';
        repType = 'Harmonic';
        descrFamilyLeader = '';
    end
    
    methods
        function f0 = F0(harmRep, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold
            f0 = f0@TVDescr(harmRep);
            
            f0.tSupport = harmRep.tSupport;
            
            f0.value = harmRep.fundamentalFreqs;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = true;
        end
    end
end