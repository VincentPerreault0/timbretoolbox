classdef SpecVar < TVDescr
    %SPECVAR Class for the spectro-temporal variation descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Constant)
        yLabel = 'Spectro-temporal Variation';
        % y-Label of the descriptor when it is plotted.
        repType = 'GenTimeFreqDistr';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function specVar = SpecVar(gtfDistr, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
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
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
    
end