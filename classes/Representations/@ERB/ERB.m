classdef ERB < TimeFreqDistr
    % ERB cochleagram representation
    properties (GetAccess = public, SetAccess = protected)
        sound        % Sound object of which it is a representation
        
        method = 'fft'      % 'fft' or 'gammatone'
        
        exponent = 1/4 % partial loudness exponent (0.25 from Hartmann97)
        
        hopSize
        hopSize_sec = 0.0058
        
        tSupport
        tSize
        tSampRate
        
        fSupport
        fSize
        fSampRate
        
        value
    end
    properties (Access = public)
        descrs % structure containing possible descriptors of this representation
    end
    methods (Access = public)
        function erbRep = ERB(sound, varargin)
            % INPUTS:
            % =======
            % (1) Sound object (mandatory)
            % (2) configuration structure (optional)
            % The configuration structure contains the following fields. If any of the
            % fields are not specified, they are calculated or given default values.
            % w_Method      -- The method that is used for doing the transformation. It can
            %                  be one of 'fft' or 'gammatone'.
            % f_hopSize_sec -- The distance between the centres of two analysis windows in
            %                  seconds. The default is the number of seconds that would give
            %                  a distance of 256 samples at 44100 Hz sample rate.
            % i_hopSize     -- The distance between the centres of two analysis windows in
            %                  samples.
            % f_Exp         -- Exponent to obtain loudness from power. See
            %                  private/ERBspect.m to see more details. Default is 1/4.
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
            erbRep.tSampRate = as.sampRate / erbRep.hopSize;
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
            erbRep.fSampRate = erbRep.fSize / as.sampRate;
            erbRep.tSampRate = as.sampRate / erbRep.hopSize;
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
