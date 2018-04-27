classdef FreqMod < GlobDescr
    %FREQMOD Class for frequency modulation of the release phase descriptor
    %(as if the sound was a single synthesized note).
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal range vector (in seconds), of the form
                    %   [starttime, endtime].
        value       % Value of the descriptor.
        method = 'fft'  % Method for the evaluation. It can take values
                        %   'fft' or 'hilbert'.
    end
    
    properties (Constant)
        repType = 'TEE';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
        unit = 'Hz'
        % Unit of the descriptor.
    end
    
    methods
        function freqMod = FreqMod(tee, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            %   Additionally, the AmpMod descriptor is also evaluated and
            %   created.
            
            freqMod = freqMod@GlobDescr(tee);
            
            if ~isempty(varargin)
                config = varargin{1};
                
                if isfield(config, 'Method')
                    if ~any(strcmp(config.Method, {'fft', 'hilbert'}))
                        error('Config.Method must be a valid method (''fft'' or ''hilbert'').');
                    end
                    freqMod.method = config.Method;
                end
            end
            
            freqMod.tSupport = [tee.tSupport(1) tee.tSupport(end)];
            
            sampleTimes = (0:length(tee.value)-1)/tee.sound.info.SampleRate;
            
            if ~isa(tee.descrs.Att, 'Descr')
                tee.descrs.Att = Att(tee);
            end
            
            sustainStartTime = tee.descrs.Dec.value; % === start sustain
            sustainEndTime = tee.descrs.Rel.value; % === end   sustain
            
            sustainIdcs = find(sustainStartTime <= sampleTimes & sampleTimes <= sustainEndTime);
            if (sustainEndTime - sustainStartTime) <= 0.02 || isempty(sustainIdcs)% === if there is no sustained part
                tee.descrs.AmpMod = AmpMod(tee, freqMod.tSupport, 0);
                freqMod.value = 0;
                return;
            end
            
            sustainEnergyEnv = tee.value(sustainIdcs);
            sustainTimes	= sampleTimes(sustainIdcs);
            meanSustainEnergyEnv = mean(sustainEnergyEnv);
            
            % === TAKING THE ENVELOP
            sustainPolynomeFit = polyfit(sustainTimes, log(sustainEnergyEnv), 1);
            sustainPolynomeFitSignal = exp(polyval(sustainPolynomeFit, sustainTimes));
            sustainPolynomeFitErrorSignal = sustainEnergyEnv - sustainPolynomeFitSignal;
            
            switch freqMod.method
                case 'hilbert', % ==========================
                    errorSignalAmp = abs(sustainPolynomeFitErrorSignal);
                    errorSignalPhase = unwrap(angle(hilbert(sustainPolynomeFitErrorSignal)));
                    errorSignalInstFreq = 1/(2*pi)*errorSignalPhase./(sustainTimes);
                    
                    tee.descrs.AmpMod = AmpMod(tee, freqMod.tSupport, median(errorSignalAmp));
                    freqMod.value = median(errorSignalInstFreq);
                    
                case 'fft', % ==========================
                    
                    % === par FFT
                    sustainLen = length(sustainTimes);
                    N      		= max([tee.sound.info.SampleRate, 2^nextpow2(sustainLen)]);
                    window = hamming(sustainLen)';
                    window		= window*2/sum(window) ;
                    errorSignalFFT = fft(sustainPolynomeFitErrorSignal.*window, round(N));
                    errorSignalFFTAmps = abs(errorSignalFFT);
                    errorSignalFFTFreqs = ((1:N)-1)/N*tee.sound.info.SampleRate;
                    
                    tremoloFreqMin = 1;
                    tremoloFreqMax = 10;
                    tremoloFreqsIdcs = find(errorSignalFFTFreqs < tremoloFreqMax & errorSignalFFTFreqs > tremoloFreqMin);
                    
                    errorSignalFFTAmpsPeaksIdcs = FreqMod.ComparePeaks(errorSignalFFTAmps(tremoloFreqsIdcs), 2);
                    if ~isempty(errorSignalFFTAmpsPeaksIdcs)
                        [ampModMax, ampModMaxIdx] = max(errorSignalFFTAmps(tremoloFreqsIdcs(errorSignalFFTAmpsPeaksIdcs)));
                        ampModMaxIdx = tremoloFreqsIdcs(errorSignalFFTAmpsPeaksIdcs(ampModMaxIdx));
                    else
                        [ampModMax, ampModMaxIdx] = max(errorSignalFFTAmps(tremoloFreqsIdcs));
                        ampModMaxIdx = tremoloFreqsIdcs(ampModMaxIdx);
                    end
                    
                    ampModValue = ampModMax/meanSustainEnergyEnv;
                    freqModValue = errorSignalFFTFreqs(ampModMaxIdx);
                    
                    if isempty(ampModValue) || isempty(freqModValue),
                        tee.descrs.AmpMod = AmpMod(tee, freqMod.tSupport, 0);
                        freqMod.value = 0;
                    else
                        tee.descrs.AmpMod = AmpMod(tee, freqMod.tSupport, ampModValue);
                        freqMod.value = freqModValue;
                    end
            end
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = false;
            if isfield(config,'Method')
                if ~strcmp(descr.method, config.Method)
                    return;
                end
            else
                if ~strcmp(descr.method, 'fft')
                    return;
                end
            end
            sameConfig = true;
        end
    end
    
    methods (Static)
        function peaksIdcs = ComparePeaks(signal, delta)
            
            len = length(signal);
            
            localMaxIdcs = find(diff(sign(diff(signal,1))) < 0) + 1;
            
            peaksIdcs = [];
            
            for p = 1 : length(localMaxIdcs);
                localMaxIdx = localMaxIdcs(p);
                
                localSignal = signal(max([localMaxIdx-delta 1]):min([localMaxIdx+delta len]));
                [~, localSignalMaxIdx]	= max(localSignal);
                localSignalMaxIdx = localSignalMaxIdx + max([localMaxIdx-delta 1]) - 1;
                
                if localSignalMaxIdx == localMaxIdx && signal(localSignalMaxIdx) > 0
                    peaksIdcs = [peaksIdcs; localMaxIdx];
                end
            end
        end
    end
    
end