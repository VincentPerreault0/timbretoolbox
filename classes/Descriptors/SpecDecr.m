classdef SpecDecr < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Spectral Decrease';
        repType = 'GenTimeFreqDistr';
        descrFamilyLeader = '';
    end
    
    methods
        function specDecr = SpecDecr(gtfDistr, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
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
            sameConfig = true;
        end
    end
    
end

