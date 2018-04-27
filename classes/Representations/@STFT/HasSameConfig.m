function sameConfig = HasSameConfig(stftRep, config)
%HASSAMECONFIG Checks if the STFT representation has the same configuration
%as the given configuration structure.

sameConfig = false;
timeRes = 1/stftRep.sound.info.SampleRate;
if isfield(config,'HopSize')
    if abs(stftRep.hopSize_sec - config.HopSize*timeRes) > timeRes/2
        return;
    end
else
    if isfield(config,'HopSize_sec')
        if abs(stftRep.hopSize_sec - config.HopSize_sec) > timeRes/2
            return;
        end
    else
        if abs(stftRep.hopSize_sec - 0.0058) > timeRes/2
            return;
        end
    end
end
if isfield(config,'WinSize')
    if abs(stftRep.winSize_sec - config.WinSize*timeRes) > timeRes/2
        return;
    end
else
    if isfield(config,'WinSize_sec')
        if abs(stftRep.winSize_sec - config.WinSize_sec) > timeRes/2
            return;
        end
    else
        if abs(stftRep.winSize_sec - 0.0232) > timeRes/2
            return;
        end
    end
end
if isfield(config, 'FFTSize')
    if stftRep.fftSize ~= config.FFTSize
        return;
    end
else
    if stftRep.fftSize ~= 2^nextpow2(stftRep.winSize)
        return;
    end
end
if isfield(config,'DistrType')
    if ~strcmp(stftRep.distrType, config.DistrType)
        return;
    end
else
    if ~strcmp(stftRep.distrType, 'pow')
        return;
    end
end
if isfield(config,'Win')
    if any(size(stftRep.win) ~= size(config.Win)) || any(stftRep.win ~= config.Win)
        return;
    end
else
    if isfield(config,'WinType')
        if ~strcmp(stftRep.winType, config.WinType)
            return;
        end
    else
        if ~strcmp(stftRep.winType, 'hamming')
            return;
        end
    end
end
sameConfig = true;
end