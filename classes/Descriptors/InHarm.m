classdef InHarm < TVDescr
    %INHARM Class for the inharmonicity descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Constant)
        yLabel = 'Inharmonicity';
        % y-Label of the descriptor when it is plotted.
        repType = 'Harmonic';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function inharm = InHarm(harmRep, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            inharm = inharm@TVDescr(harmRep);
            
            inharm.tSupport = harmRep.tSupport;
            
            harmonics = (1:harmRep.nHarms)' * harmRep.fundamentalFreqs;
            inharm.value = 2 * sum(abs(harmRep.partialFreqs - harmonics) .* (harmRep.partialAmps.^ 2), 1) ./ (sum(harmRep.partialAmps.^2, 1) .* harmRep.fundamentalFreqs + eps);
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
end