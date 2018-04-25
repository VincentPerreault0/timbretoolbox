classdef SpecFlat < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Spectral Flatness';
        repType = 'GenTimeFreqDistr';
        descrFamilyLeader = '';
    end
    
    methods
        function specFlat = SpecFlat(gtfDistr, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold
            specFlat = specFlat@TVDescr(gtfDistr);
            
            specFlat.tSupport = gtfDistr.tSupport;
            
            if ~isa(gtfDistr, 'Harmonic')
                geometricMean = exp( (1/gtfDistr.fSize) * sum(log(gtfDistr.value+eps)) );
                arithmeticMean = sum(gtfDistr.value) ./ gtfDistr.fSize;
            else
                geometricMean = exp((1/gtfDistr.nHarms) * sum(log(gtfDistr.partialAmps+eps), 1));
                arithmeticMean = sum(gtfDistr.partialAmps, 1) / gtfDistr.nHarms;
            end
            specFlat.value = geometricMean ./ (arithmeticMean+eps);
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = true;
        end
    end
    
end