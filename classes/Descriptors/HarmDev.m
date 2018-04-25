classdef HarmDev < TVDescr
    
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
        function harmDev = HarmDev(harmRep, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold
            harmDev = harmDev@TVDescr(harmRep);
            
            harmDev.tSupport = harmRep.tSupport;
            
            specEnv = zeros(size(harmRep.partialAmps));
            specEnv(1, :) = harmRep.partialAmps(1, :);
            specEnv(2:end-1, :) = (harmRep.partialAmps(1:end-2, :) + harmRep.partialAmps(2:end-1, :) + harmRep.partialAmps(3:end, :)) / 3;
            specEnv(end, :) = (harmRep.partialAmps(end-1, :) + harmRep.partialAmps(end, :)) / 2;
            harmDev.value = sum(abs(harmRep.partialAmps - specEnv), 1) ./ harmRep.nHarms;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = true;
        end
    end
end