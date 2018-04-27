classdef EffDur < GlobDescr
    %EFFDUR Class for effective duration descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal range vector (in seconds), of the form
                    %   [starttime, endtime].
        value       % Value of the descriptor.
        threshold = 0.4 % Relative minimum energy level at which the sound
                        %   is considered to be effectively playing.
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
        function effDur = EffDur(tee, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
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
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
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

