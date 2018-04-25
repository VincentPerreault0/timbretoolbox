classdef SpecVar < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Spectro-temporal Variation';
        repType = 'GenTimeFreqDistr';
        descrFamilyLeader = '';
    end
    
    methods
        function specVar = SpecVar(gtfDistr, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold
            specVar = specVar@TVDescr(gtfDistr);
            
            specVar.tSupport = 0.5*(gtfDistr.tSupport(1:end-1) + gtfDistr.tSupport(2:end));
            
            if ~isa(gtfDistr, 'Harmonic')
                crossProduct = sum(gtfDistr.value .* [zeros(gtfDistr.fSize,1), gtfDistr.value(:,1:gtfDistr.tSize-1)] , 1);
                autoProduct = sum(gtfDistr.value.^2 , 1) .* sum( [zeros(gtfDistr.fSize,1), gtfDistr.value(:,1:gtfDistr.tSize-1)].^2, 1);
                specVar.value = 1 - crossProduct ./ (sqrt(autoProduct) + eps);
                specVar.value = specVar.value(2:end);
                % === the first value is always incorrect because of "tfDistr.value .* [zeros(tfDistr.fSize,1)"
            else
                previousFrame = gtfDistr.partialAmps(:, 1:end-1);
                currentFrame = gtfDistr.partialAmps(:, 2:end);
                i_Sz = max( length(currentFrame), length(previousFrame) );
                previousFrame(end+1:i_Sz) = 0;
                currentFrame(end+1:i_Sz) = 0;
                crossProduct = sum(previousFrame .* currentFrame, 1);
                autoProduct = sqrt(sum(previousFrame.^2, 1) .* sum(currentFrame.^2, 1));
                specVar.value = 1 - crossProduct ./ (autoProduct+eps);
            end
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = true;
        end
    end
    
end