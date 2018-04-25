classdef OddEvenRatio < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Odd-Even Harmonic Ratio';
        repType = 'Harmonic';
        descrFamilyLeader = '';
    end
    
    methods
        function oddEvenRatio = OddEvenRatio(harmRep, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold
            oddEvenRatio = oddEvenRatio@TVDescr(harmRep);
            
            oddEvenRatio.tSupport = harmRep.tSupport;
            
            oddEvenRatio.value = sum(harmRep.partialAmps(1:2:end, :).^2, 1) ./ (sum(harmRep.partialAmps(2:2:end, :).^2, 1) + eps);
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = true;
        end
    end
end