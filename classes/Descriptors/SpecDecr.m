classdef SpecDecr < TVDescr
    %SPECDECR Class for the spectral decrease descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Constant)
        yLabel = 'Spectral Decrease';
        % y-Label of the descriptor when it is plotted.
        repType = 'GenTimeFreqDistr';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function specDecr = SpecDecr(gtfDistr, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            specDecr = specDecr@TVDescr(gtfDistr);
            
            specDecr.tSupport = gtfDistr.tSupport;
            
            if ~isa(gtfDistr, 'Harmonic')
                numerator = gtfDistr.value(2:gtfDistr.fSize, :) - repmat(gtfDistr.value(1,:), gtfDistr.fSize-1, 1);
                denominator = 1 ./ (1:gtfDistr.fSize-1);
                % The sum is carried out by inner product.
                specDecr.value = (denominator * numerator) ./ sum(gtfDistr.value(2:gtfDistr.fSize,:)+eps);
            else
                if gtfDistr.nHarms < 5
                    specDecr.value = zeros(1, gtfDistr.stft.tSize);
                else
                    numerator = sum((gtfDistr.partialAmps(2:gtfDistr.nHarms, :) - repmat(gtfDistr.partialAmps(1, :), gtfDistr.nHarms - 1, 1)) ./ repmat((1:gtfDistr.nHarms-1)', 1, gtfDistr.stft.tSize), 1);
                    denominator = sum(gtfDistr.partialAmps(2:gtfDistr.nHarms, :), 1);
                    specDecr.value = (numerator ./ (denominator+eps));	% === divide by zero
                end
            end
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
    
end

