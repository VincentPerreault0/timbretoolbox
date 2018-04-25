classdef TriStim < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Tristimulus';
        repType = 'Harmonic';
        descrFamilyLeader = '';
    end
    
    methods
        function triStim = TriStim(harmRep, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            triStim = triStim@TVDescr(harmRep);
            
            triStim.tSupport = harmRep.tSupport;
            
            triStim.value = zeros(3, length(triStim.tSupport));
            
            triStim.value(1, :) = harmRep.partialAmps(1, :) ./ (sum(harmRep.partialAmps, 1) + eps);
            triStim.value(2, :) = sum(harmRep.partialAmps(2:4, :), 1) ./ (sum(harmRep.partialAmps, 1) + eps);
            triStim.value(3, :) = sum(harmRep.partialAmps(5:end, :), 1) ./ (sum(harmRep.partialAmps, 1) + eps);
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = true;
        end
    end
end