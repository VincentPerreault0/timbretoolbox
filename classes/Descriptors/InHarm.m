classdef InHarm < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Inharmonicity';
        repType = 'Harmonic';
        descrFamilyLeader = '';
    end
    
    methods
        function inharm = InHarm(harmRep, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold
            inharm = inharm@TVDescr(harmRep);
            
            inharm.tSupport = harmRep.tSupport;
            
            harmonics = (1:harmRep.nHarms)' * harmRep.fundamentalFreqs;
            inharm.value = 2 * sum(abs(harmRep.partialFreqs - harmonics) .* (harmRep.partialAmps.^ 2), 1) ./ (sum(harmRep.partialAmps.^2, 1) .* harmRep.fundamentalFreqs + eps);
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = true;
        end
    end
end