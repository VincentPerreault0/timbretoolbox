classdef HarmDev < TVDescr
    %HARMDEV Class for the harmonic deviation descriptor.
    
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
        function harmDev = HarmDev(harmRep, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            harmDev = harmDev@TVDescr(harmRep);
            
            harmDev.tSupport = harmRep.tSupport;
            
            specEnv = zeros(size(harmRep.partialAmps));
            specEnv(1, :) = harmRep.partialAmps(1, :);
            specEnv(2:end-1, :) = (harmRep.partialAmps(1:end-2, :) + harmRep.partialAmps(2:end-1, :) + harmRep.partialAmps(3:end, :)) / 3;
            specEnv(end, :) = (harmRep.partialAmps(end-1, :) + harmRep.partialAmps(end, :)) / 2;
            harmDev.value = sum(abs(harmRep.partialAmps - specEnv), 1) ./ harmRep.nHarms;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
end