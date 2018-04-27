classdef OddEvenRatio < TVDescr
    %ODDEVENRATIO Class for the odd-to-even ratio descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Constant)
        yLabel = 'Odd-Even Harmonic Ratio';
        % y-Label of the descriptor when it is plotted.
        repType = 'Harmonic';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function oddEvenRatio = OddEvenRatio(harmRep, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            oddEvenRatio = oddEvenRatio@TVDescr(harmRep);
            
            oddEvenRatio.tSupport = harmRep.tSupport;
            
            oddEvenRatio.value = sum(harmRep.partialAmps(1:2:end, :).^2, 1) ./ (sum(harmRep.partialAmps(2:2:end, :).^2, 1) + eps);
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
end