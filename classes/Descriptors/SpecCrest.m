classdef SpecCrest < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Spectral Crest';
        repType = 'GenTimeFreqDistr';
        descrFamilyLeader = '';
    end
    
    methods
        function specCrest = SpecCrest(gtfDistr, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold
            specCrest = specCrest@TVDescr(gtfDistr);
            
            specCrest.tSupport = gtfDistr.tSupport;
            
            if ~isa(gtfDistr, 'Harmonic')
                arithmeticMean = sum(gtfDistr.value) / gtfDistr.fSize;
                specCrest.value = max(gtfDistr.value) ./ (arithmeticMean+eps);
            else
                arithmeticMean = sum(gtfDistr.partialAmps, 1) / gtfDistr.nHarms;
                specCrest.value = max(gtfDistr.partialAmps) ./ (arithmeticMean+eps);
            end
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = true;
        end
    end
    
end