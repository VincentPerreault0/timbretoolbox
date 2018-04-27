classdef RMSEnv < TVDescr
    %RMSENV Class for the RMS-Energy Envelope descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
        hopSize     % Hop size of the window (in samples). Determines the 
                    %   time resolution of the descriptor.
        hopSize_sec = 0.0029% Hop size of the window (in seconds). See
                            %   Peeters (2011) for defaults.
        winSize     % Size of the window (in samples).
        winSize_sec = 0.0232% Size of the window (in seconds). See Peeters 
                            %   (2011) for defaults.
    end
    
    properties (Constant)
        yLabel = 'RMS-Energy Envelope';
        % y-Label of the descriptor when it is plotted.
        repType = 'TEE';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function rmsEnv = RMSEnv(tee, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            rmsEnv = rmsEnv@TVDescr(tee);
            
            if ~isempty(varargin)
                config = varargin{1};
            else
                config = struct();
            end
                
            % If hop size in samples specified, calculate the window size in
            % seconds (will overwrite hop size in seconds if also specified).
            if isfield(config,'HopSize')
                if ~isa(config.HopSize, 'double') || config.HopSize <= 0
                    error('Config.HopSize must be a hop size in samples (double > 0).');
                end
                config.HopSize_sec = config.HopSize/tee.sound.info.SampleRate;
            end
            if isfield(config,'HopSize_sec')
                if ~isa(config.HopSize_sec, 'double') || config.HopSize_sec <= 0
                    error('Config.HopSize_sec must be a hop size in seconds (double > 0).');
                end
                rmsEnv.hopSize_sec = config.HopSize_sec;
            end
            rmsEnv.hopSize = round(rmsEnv.hopSize_sec * tee.sound.info.SampleRate);
            % If window size in samples specified, calculate the window size in
            % seconds (will overwrite window size in seconds if also specified).
            if isfield(config,'WinSize')
                if ~isa(config.WinSize, 'double') || config.WinSize <= 0
                    error('Config.WinSize must be a window size in samples (double > 0).');
                end
                config.WinSize_sec = config.WinSize/tee.sound.info.SampleRate;
            end
            if isfield(config,'WinSize_sec')
                if ~isa(config.WinSize_sec, 'double') || config.WinSize_sec <= 0
                    error('Config.WinSize_sec must be a window size in seconds (double > 0).');
                end
                rmsEnv.winSize_sec = config.WinSize_sec;
            end
            rmsEnv.winSize = round(rmsEnv.winSize_sec * tee.sound.info.SampleRate);
            
            rmsEnv.tSupport = 0:rmsEnv.hopSize:(rmsEnv.hopSize*(floor((length(tee.value) - rmsEnv.winSize)/rmsEnv.hopSize)));
            rmsEnv.value = zeros(1, length(rmsEnv.tSupport));
            
            for i = 1:length(rmsEnv.tSupport)
                % Windowed signal starting from time tSupport(i)
                rmsEnv.value(i) = sqrt(mean(tee.value(rmsEnv.tSupport(i) + (1:rmsEnv.winSize)).^2));
            end
            rmsEnv.tSupport = (rmsEnv.tSupport + ceil(rmsEnv.winSize/2))/tee.sound.info.SampleRate;
            % arbitrary displacement of the support vector (aligned here with the
            % center of the windows)
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = false;
            timeRes = 1/descr.rep.sound.info.SampleRate;
            if isfield(config,'HopSize')
                if abs(descr.hopSize_sec - config.HopSize*timeRes) > timeRes/2
                    return;
                end
            else
                if isfield(config,'HopSize_sec')
                    if abs(descr.hopSize_sec - config.HopSize_sec) > timeRes/2
                        return;
                    end
                else
                    if abs(descr.hopSize_sec - 0.0029) > timeRes/2
                        return;
                    end
                end
            end
            if isfield(config,'WinSize')
                if abs(descr.winSize_sec - config.WinSize*timeRes) > timeRes/2
                    return;
                end
            else
                if isfield(config,'WinSize_sec')
                    if abs(descr.winSize_sec - config.WinSize_sec) > timeRes/2
                        return;
                    end
                else
                    if abs(descr.winSize_sec - 0.0232) > timeRes/2
                        return;
                    end
                end
            end
            sameConfig = true;
        end
    end
    
end

