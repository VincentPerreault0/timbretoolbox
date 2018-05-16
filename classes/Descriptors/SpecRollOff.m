classdef SpecRollOff < TVDescr
    %SPECROLLOFF Class for the spectral rolloff descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
        threshold = 0.95% Threshold for the evaluation of the descriptor.
    end
    
    properties (Constant)
        yLabel = 'Spectral Rolloff (Hz)';
        % y-Label of the descriptor when it is plotted.
        repType = 'GenTimeFreqDistr';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function specRollOff = SpecRollOff(gtfDistr, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            specRollOff = specRollOff@TVDescr(gtfDistr);
            if ~isempty(varargin)
                config = varargin{1};
                if isfield(config, 'Threshold')
                    if ~isa(config.Threshold, 'double') || config.Threshold <= 0 || config.Threshold > 1
                        error('Config.Threshold must be a threshold (1 >= double > 0).');
                    end
                    specRollOff.threshold = config.Threshold;
                end
            end
            
            specRollOff.tSupport = gtfDistr.tSupport;
            
            if ~isa(gtfDistr, 'Harmonic')
                cumulativeSum = cumsum(gtfDistr.value);
                Sum = specRollOff.threshold * sum(gtfDistr.value, 1);
                cumuOverSumBins = cumulativeSum >= repmat( Sum, gtfDistr.fSize, 1 );
                [idx, ~] = find(cumsum(cumuOverSumBins) == 1);
                specRollOff.value = gtfDistr.fSupport(idx);
                specRollOff.value = specRollOff.value';
            else
                cumulativeSum = cumsum(gtfDistr.partialAmps, 1);
                normalizedCumulativeSum = cumulativeSum ./ repmat(sum(gtfDistr.partialAmps,1)+eps, gtfDistr.nHarms, 1);
                specRollOff.value = zeros(1, gtfDistr.stft.tSize);
                for i = 1:gtfDistr.stft.tSize
                    cumuOverThresholdIcs = find(normalizedCumulativeSum(:, i) >= specRollOff.threshold);
                    if ~isempty(cumuOverThresholdIcs)
                        specRollOff.value(i) = gtfDistr.partialFreqs(cumuOverThresholdIcs(1), i);
                    else
                        specRollOff.value(i) = gtfDistr.partialFreqs(1, i);
                    end
                end
            end
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = false;
            if isfield(config,'Threshold')
                if descr.threshold ~= config.Threshold
                    return;
                end
            else
                if descr.threshold ~= 0.95
                    return;
                end
            end
            sameConfig = true;
        end
    end
    
end