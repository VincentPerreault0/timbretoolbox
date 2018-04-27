classdef ERB < TimeFreqDistr
    %ERB Class for Equivalent Rectangular Bandwidth Cochleagram
    %representation.
    
    properties (GetAccess = public, SetAccess = protected)
        sound       % SoundFile object of which it is a representation.
        method = 'fft'  % Method to compute the ERB representation. Can
                        %   take the values 'fft' or 'gammatone'.
        exponent = 1/4  % Partial loudness exponent (0.25 from Hartmann97)
        hopSize     % Hop size of the window (in samples). Determines the 
                    %   time resolution of the representation.
        hopSize_sec = 0.0058% Hop size of the window (in seconds). See
                            %   Peeters (2011) for defaults.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        tSize       % Length of the temporal support vector
        fSupport    % Frequency support column vector that indicates to
                    %   what frequencies the bins (lines) of the value
                    %   refer to (in Hz).
        fSize       % Length of the frequency support vector
        value       % Value of the time-frequency distribution (fSize by
                    %   tSize matrix).
    end
    properties (Access = public)
        descrs % structure containing possible descriptors of this representation
    end
    methods (Access = public)
        function erbRep = ERB(sound, varargin)
            %CONSTRUCTOR From an audio signal representation, evaluates its
            %Equivalent Rectangular Bandwidth Cochleagram.
            %   Evaluates the ERB cochleagram of the audio signal. If the
            %   method is 'gammatone', the ERB will be computed exactly
            %   with gammatone filterbanks. If the method is 'fft', the ERB
            %   will be approximated by a linearly-transformed spectrogram.
            
            erbRep = erbRep@TimeFreqDistr(sound);
            as = sound.reps.AudioSignal;
            
            if isempty(varargin)
                config = struct();
            else
                config = varargin{1};
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
                erbRep.hopSize_sec = config.HopSize_sec;
            end
            erbRep.hopSize = round(erbRep.hopSize_sec * as.sampRate);
            if isfield(config, 'Method')
                if ~any(strcmp(config.Method, {'fft', 'gammatone'}))
                    error('Config.Method must be a valid method (''fft'' or ''gammatone'').');
                end
                erbRep.method = config.Method;
            end
            if isfield(config, 'Exponent')
                if ~isa(config.Exponent, 'double') || config.Exponent <= 0
                    error('Config.Exponent must be a partial loudness exponent (double > 0).');
                end
                erbRep.exponent = config.Exponent;
            end
            
            if sound.chunkSize > 0
                wtbar = waitbar(0, 'Applying outer/middle ear filter...', 'Name', 'Evaluating Equivalent Rectangular Bandwidth Representation');
            end
            
            % apply outer/middle ear filter:
            signal = ERB.outmidear(as.value(:),as.sampRate);
            
            switch lower(erbRep.method)
                case 'fft'
                    if sound.chunkSize > 0
                        erbRep.ERBpower(signal, wtbar)
                    else
                        erbRep.ERBpower(signal)
                    end
                case 'gammatone'
                    if sound.chunkSize > 0
                        waitbar(0.1, wtbar, 'Evaluating distribution via gammatone filterbanks method (in 1 chunk)...');
                    end
                    erbRep.ERBpower2(signal, [], 1, [])
                otherwise
                    error('unexpected method');
            end
            clear('signal');
            
            if sound.chunkSize > 0
                waitbar(0.95, wtbar, 'Evaluating instantaneous partial loudness...');
            end
            erbRep.value = erbRep.value.^erbRep.exponent; % instantaneous partial loudness
            
            if sound.chunkSize > 0
                close(wtbar);
            end
            
            erbRep.tSize = length(erbRep.tSupport);
            erbRep.fSize = length(erbRep.fSupport);
        end
        
        ERBpower(erbRep, signal, wtbar)
        
        ERBpower2(erbRep, signal, cfarray, bwfactor, signalPadding)
        
        sameConfig = HasSameConfig(erbRep, config)
    end
    
    methods (Static)
        bw = CFERB(cf) % Cambridge equivalent rectangular bandwidth at cf
        
        [c, s] = centroid(x) % centroid and spread
        
        e = ERBfromhz(f, formula) % convert frequency from Hz to erb-rate scale
        
        f = ERBtohz(e, formula) % convert frequency from ERB to Hz scale
        
        y = ERBspace(lo, hi, N) % values uniformly spaced on  erb-rate scale
        
        b = fbankpwrsmooth(a, sr, cfarray) % temporally smoothed power of filterbank output
        
        [b, f] = gtfbank(a, sr, cfarray, bwfactor) % apply gammatone filterbank to signal
        
        y = gtwindow(n, b, order) % window shaped like a time-reversed gammatone envelope
        
        [mafs, f] = isomaf(f, dataset) % Minimum audible field at frequency f
        
        fcoefs = MakeERBCoeffs(fs, cfArray, Bfactor) % filter coefficients for a bank of Gammatone filters
        
        y = outmidear(x, sr) % outer/middle ear filter
        
        y = rsmooth(x, smooth, npasses, trim) % smooth by running convolution
    end
end
