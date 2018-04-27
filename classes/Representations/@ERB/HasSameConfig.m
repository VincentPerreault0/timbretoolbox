function sameConfig = HasSameConfig(erbRep, config)
%HASSAMECONFIG Checks if the ERB representation has the same configuration
%as the given configuration structure.

sameConfig = false;
timeRes = 1/erbRep.sound.info.SampleRate;
if isfield(config,'HopSize')
    if abs(erbRep.hopSize_sec - config.HopSize*timeRes) > timeRes/2
        return;
    end
else
    if isfield(config,'HopSize_sec')
        if abs(erbRep.hopSize_sec - config.HopSize_sec) > timeRes/2
            return;
        end
    else
        if abs(erbRep.hopSize_sec - 0.0058) > timeRes/2
            return;
        end
    end
end
if isfield(config,'Method')
    if ~strcmp(erbRep.method, config.Method)
        return;
    end
else
    if ~strcmp(erbRep.method, 'fft')
        return;
    end
end
if isfield(config,'Exponent')
    if erbRep.exponent ~= config.Exponent
        return;
    end
else
    if erbRep.exponent ~= 1/4
        return;
    end
end
sameConfig = true;
end