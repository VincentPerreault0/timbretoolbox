classdef TempCent < GlobDescr
    %TEMPCENT Class for the temporal centroid descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal range vector (in seconds), of the form
                    %   [starttime, endtime].
        value       % Value of the descriptor.
        threshold = 0.15% Threshold for the evaluation of the descriptor.
    end
    
    properties (Constant)
        repType = 'TEE';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
        unit = 'sec'
        % Unit of the descriptor.
    end
    
    methods
        function tempCent = TempCent(tee, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            tempCent = tempCent@GlobDescr(tee);
            
            if ~isempty(varargin)
                config = varargin{1};
                
                if isfield(config, 'Threshold')
                    if ~isa(config.Threshold, 'double') || config.Threshold <= 0 || config.Threshold > 1
                        error('Config.Threshold must be a threshold (1 >= double > 0).');
                    end
                    tempCent.threshold = config.Threshold;
                end
            end
            
            tempCent.tSupport = [tee.tSupport(1) tee.tSupport(end)];
            
            [envMax, envMaxIdx]= max(tee.value); % === max value and index
            overThreshIdcs	= find((tee.value ./ envMax) > tempCent.threshold);
            
            overThreshStartIdx = overThreshIdcs(1);
            if( overThreshStartIdx == envMaxIdx)
                overThreshStartIdx = overThreshStartIdx - 1;
            end
            overThreshEndIdx = overThreshIdcs(end);
            
            overThreshTEE = tee.value(overThreshStartIdx : overThreshEndIdx);
            overThreshSupport = 0:length(overThreshTEE)-1;
            overThreshMean = sum(overThreshSupport .* overThreshTEE) ./ sum(overThreshTEE); % centroid
            
            tempCent.value	= (overThreshStartIdx + overThreshMean) / tee.sound.info.SampleRate;
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
                if descr.threshold ~= 0.15
                    return;
                end
            end
            sameConfig = true;
        end
    end
    
end

