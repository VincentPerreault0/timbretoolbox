classdef TriStim < TVDescr
    %TRISTIM Class for the tristimulus descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Constant)
        yLabel = 'Tristimulus';
        % y-Label of the descriptor when it is plotted.
        repType = 'Harmonic';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function triStim = TriStim(harmRep, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            triStim = triStim@TVDescr(harmRep);
            
            triStim.tSupport = harmRep.tSupport;
            
            triStim.value = zeros(3, length(triStim.tSupport));
            
            triStim.value(1, :) = harmRep.partialAmps(1, :) ./ (sum(harmRep.partialAmps, 1) + eps);
            triStim.value(2, :) = sum(harmRep.partialAmps(2:4, :), 1) ./ (sum(harmRep.partialAmps, 1) + eps);
            triStim.value(3, :) = sum(harmRep.partialAmps(5:end, :), 1) ./ (sum(harmRep.partialAmps, 1) + eps);
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
end