classdef EffDur < GlobDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
        threshold = 0.4% Relative minimum energy level at which the sound is
                    % considered to be effectively playing.
    end
    
    properties (Constant)
        repType = 'TEE';
        descrFamilyLeader = '';
        unit = 'sec'
    end
    
    methods
        function effDur = EffDur(tee, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold         - See properties
            effDur = effDur@GlobDescr(tee);
            
            if ~isempty(varargin)
                config = varargin{1};
                
                if isfield(config, 'Threshold')
                    if ~isa(config.Threshold, 'double') || config.Threshold <= 0 || config.Threshold > 1
                        error('Config.Threshold must be a threshold (1 >= double > 0).');
                    end
                    effDur.threshold = config.Threshold;
                end
            end
            
            effDur.tSupport = [tee.tSupport(1) tee.tSupport(end)];
            
            [envMax, envMaxIdx]= max(tee.value); % === max value and index
            effectivePlayingIdcs	= find((tee.value ./ envMax) > effDur.threshold);
            
            effectiveStart = effectivePlayingIdcs(1);
            if( effectiveStart == envMaxIdx)
                effectiveStart = effectiveStart - 1;
            end
            effectiveEnd = effectivePlayingIdcs(end);
            
            effDur.value = (effectiveEnd - effectiveStart + 1) / tee.sound.info.SampleRate;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = false;
            if isfield(config,'Threshold')
                if descr.threshold ~= config.Threshold
                    return;
                end
            else
                if descr.threshold ~= 0.4
                    return;
                end
            end
            sameConfig = true;
        end
    end
    
end

