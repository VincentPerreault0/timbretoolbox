function sameConfig = HasSameConfig(harmRep, config)
%HASSAMECONFIG Checks if the harmonic representation has the same
%configuration as the given configuration structure.
            
sameConfig = false;
if isfield(config,'Threshold')
    if harmRep.threshold ~= config.Threshold
        return;
    end
else
    if harmRep.threshold ~= 0.3
        return;
    end
end
if isfield(config,'NHarms')
    if harmRep.nHarms ~= config.NHarms
        return;
    end
else
    if harmRep.nHarms ~= 20
        return;
    end
end
timeRes = 1/harmRep.sound.info.SampleRate;
if isfield(config,'HopSize')
    if abs(harmRep.stft.hopSize_sec - config.HopSize*timeRes) > timeRes/2
        return;
    end
else
    if isfield(config,'HopSize_sec')
        if abs(harmRep.stft.hopSize_sec - config.HopSize_sec) > timeRes/2
            return;
        end
    else
        if abs(harmRep.stft.hopSize_sec - 0.025) > timeRes/2
            return;
        end
    end
end
if isfield(config,'WinSize')
    if abs(harmRep.stft.winSize_sec - config.WinSize*timeRes) > timeRes/2
        return;
    end
else
    if isfield(config,'WinSize_sec')
        if abs(harmRep.stft.winSize_sec - config.WinSize_sec) > timeRes/2
            return;
        end
    else
        if abs(harmRep.stft.winSize_sec - 0.1) > timeRes/2
            return;
        end
    end
end
if isfield(config, 'FFTSize')
    if harmRep.stft.fftSize ~= config.FFTSize
        return;
    end
else
    if harmRep.stft.fftSize ~= 4*2^nextpow2(harmRep.stft.winSize)
        return;
    end
end
if isfield(config,'Win')
    if any(size(harmRep.stft.win) ~= size(config.Win)) || any(harmRep.stft.win ~= config.Win)
        return;
    end
else
    if isfield(config,'WinType')
        if ~strcmp(harmRep.stft.winType, config.WinType)
            return;
        end
    else
        if ~strcmp(harmRep.stft.winType, 'blackman')
            return;
        end
    end
end
sameConfig = true;
end