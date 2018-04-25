classdef TempCent < GlobDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
        threshold = 0.15
    end
    
    properties (Constant)
        repType = 'TEE';
        descrFamilyLeader = '';
        unit = 'sec'
    end
    
    methods
        function tempCent = TempCent(tee, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold         - See properties
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

