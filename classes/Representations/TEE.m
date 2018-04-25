classdef TEE < TimeSignal
    %Sound wave representation
    properties (GetAccess = public, SetAccess = protected)
        tSupport
        sound        % Sound object of which it is a representation
        value       %The samples read from the file. If the file comprises many
        % channels, these are the samples from the first channel.
        cutoffFreq = 5  % (Hz) Cutoff frequency of the lowpass filter on the energy envelope
    end
    properties (Access = public)
        descrs % structure containing possible descriptors of this representation
    end
    methods (Access = public)
        function tee = TEE(sound, varargin)
            % INPUTS:
            % =======
            % A sound object
            %
            % and (optionally)
            %
            % A configuration structure containing the fields
            %
            % CutoffFreq        - Specifies a cutoff frequency to be used
            %                   for the low-pass filter on the energy envelope
            tee = tee@TimeSignal(sound);
            as = sound.reps.AudioSignal;
            
            tee.tSupport = as.tSupport;
            
            if ~isempty(varargin)
                config = varargin{1};
                
                if isfield(config, 'CutoffFreq')
                    if ~isa(config.CutoffFreq, 'double') || config.CutoffFreq <= 0
                        error('Config.CutoffFreq must be a low-pass filter cutoff frequency in Hertz (double > 0).');
                    end
                    tee.cutoffFreq = config.CutoffFreq;
                end
            end
            
            analyticSignal = hilbert(as.value); % analytic signal
            amplitudeModulation = abs(analyticSignal);  % amplitude modulation of analytic signal
            
            % === Filter amplitude modulation with 3rd order butterworth filter
            normalizedFreq = tee.cutoffFreq/(as.sampRate/2);
            [transfFuncCoeffB, transfFuncCoeffA] = butter(3, normalizedFreq);
            signal = filter(transfFuncCoeffB, transfFuncCoeffA, amplitudeModulation);
            
            tee.value = signal(:)';
        end
        
        function sameConfig = HasSameConfig(tee, config)
            sameConfig = false;
            if isfield(config,'CutoffFreq')
                if tee.cutoffFreq ~= config.CutoffFreq
                    return;
                end
            else
                if tee.cutoffFreq ~= 5
                    return;
                end
            end
            sameConfig = true;
        end
    end

end