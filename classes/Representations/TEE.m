classdef TEE < TimeSignal
    %TEE Class for the Temporal Energy Envelope representation.
    
    properties (GetAccess = public, SetAccess = protected)
        sound       % SoundFile object of which it is a representation.
        cutoffFreq = 5  % Cutoff frequency (in Hz) of the lowpass filter on
                        %   the energy envelope.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the Temporal Energy Envelope (line vector of
                    %   the same length as tSupport).
    end
    properties (Access = public)
        descrs      % Structure containing all the representation's 
                    %   possible descriptors. All fields correspond to a
                    %   possible descriptor type and are instantiated with
                    %   a value of 0 (see Rep's getDescrTypes() method).
    end
    methods (Access = public)
        function tee = TEE(sound, varargin)
            %CONSTRUCTOR From an audio signal representation, evaluates a
            %Temporal Energy Envelope representation.
            %   Evaluates the Temporal Energy Envelope of the audio signal
            %   by keeping the amplitude of the analytic signal and
            %   filtering it through a lowpass filter with a specified
            %   cutoff frequency.
            
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
            %HASSAMECONFIG Checks if the Temporal Energy Envelope has the
            %same configuration as the given configuration structure.
            
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