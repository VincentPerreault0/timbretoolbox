classdef ZcrRate < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % seconds).
        value
        rep
        winSize
        winSize_sec = 0.0232
        hopSize
        hopSize_sec = 0.0029
    end
    
    properties (Constant)
        yLabel = 'Zero-Crossing Rate';
        repType = 'AudioSignal';
        descrFamilyLeader = '';
    end
    
    methods
        function zCrRate = ZcrRate(as, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            zCrRate = zCrRate@TVDescr(as);
            
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
                config.HopSize_sec = config.HopSize/as.sampRate;
            end
            if isfield(config,'HopSize_sec')
                if ~isa(config.HopSize_sec, 'double') || config.HopSize_sec <= 0
                    error('Config.HopSize_sec must be a hop size in seconds (double > 0).');
                end
                zCrRate.hopSize_sec = config.HopSize_sec;
            end
            zCrRate.hopSize = round(zCrRate.hopSize_sec * as.sampRate);
            % If window size in samples specified, calculate the window size in
            % seconds (will overwrite window size in seconds if also specified).
            if isfield(config,'WinSize')
                if ~isa(config.WinSize, 'double') || config.WinSize <= 0
                    error('Config.WinSize must be a window size in samples (double > 0).');
                end
                config.WinSize_sec = config.WinSize/as.sampRate;
            end
            if isfield(config,'WinSize_sec')
                if ~isa(config.WinSize_sec, 'double') || config.WinSize_sec <= 0
                    error('Config.WinSize_sec must be a window size in seconds (double > 0).');
                end
                zCrRate.winSize_sec = config.WinSize_sec;
            end
            zCrRate.winSize = round(zCrRate.winSize_sec * as.sampRate);

            % Time beginnings of the windows in samples (starting at 0)
            zCrRate.tSupport = 0:zCrRate.hopSize:(zCrRate.hopSize*(floor((as.len - zCrRate.winSize)/zCrRate.hopSize)));
            
            zCrRate.value = zeros(1, length(zCrRate.tSupport));
            
            for i = 1:length(zCrRate.tSupport)
                % Windowed signal starting from time tSupport(i)
                windowedSignal = as.value(zCrRate.tSupport(i) + (1:zCrRate.winSize));
                % Autocorrelation evaluation (eps is to avoid division by zero in
                % coefficient normalization)
                zCrRate.value(i) = (as.sampRate/zCrRate.winSize) * nnz(diff(sign(windowedSignal - mean(windowedSignal))));
            end
            zCrRate.tSupport = (zCrRate.tSupport + ceil(zCrRate.winSize/2))/as.sampRate;
            % arbitrary displacement of the support vector (aligned here with the
            % center of the windows)
        end
        
        function sameConfig = HasSameConfig(descr, config)
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

