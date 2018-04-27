classdef SpecSlope < TVDescr
    %SPECSLOPE Class for the spectral slope descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Constant)
        yLabel = 'Spectral Slope (Hz^-1)';
        % y-Label of the descriptor when it is plotted.
        repType = 'GenTimeFreqDistr';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function specSlope = SpecSlope(gtfDistr, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            specSlope = specSlope@TVDescr(gtfDistr);
            
            specSlope.tSupport = gtfDistr.tSupport;
            
            if ~isa(gtfDistr, 'Harmonic')
                distrProb = gtfDistr.value ./ repmat(sum(gtfDistr.value, 1)+eps, gtfDistr.fSize, 1); % === normalize distribution in Y dim
                
                numerator = gtfDistr.fSize * (gtfDistr.fSupport' * distrProb) - sum(gtfDistr.fSupport) * sum(distrProb);
                denominator = gtfDistr.fSize * sum(gtfDistr.fSupport.^2) - sum(gtfDistr.fSupport).^2;
            else
                partialProb = gtfDistr.partialAmps ./ repmat(sum(gtfDistr.partialAmps, 1)+eps, gtfDistr.nHarms,1);	% === divide by zero
                
                numerator = gtfDistr.nHarms * sum(gtfDistr.partialFreqs .* partialProb, 1) - sum(gtfDistr.partialFreqs, 1);
                denominator = gtfDistr.nHarms * sum(gtfDistr.partialFreqs.^2, 1) - sum(gtfDistr.partialFreqs, 1).^2;
            end
            specSlope.value	= numerator ./ denominator;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
    
end

