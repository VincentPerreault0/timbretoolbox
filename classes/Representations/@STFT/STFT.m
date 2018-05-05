classdef STFT < TimeFreqDistr
    %STFT Class for spectrogram representation.
    
    properties (GetAccess = public, SetAccess = protected)
        sound       % SoundFile object of which it is a representation.
        distrType = 'pow'   % The type of spectrum computed. By default
                            %	this is "pow" andcomputes the power
                            %	spectrum. Other possible values are:
                            %	- 'pow' : Computes the power spectrum. The
                            %       spectrum is divided by two times the
                            %       FFT size, the sum of the squared values
                            %       of the window and all values except for
                            %       the first value are divided by 2 to
                            %       remove energy contributed by the
                            %       Hilbert transform.
                            %	- 'mag' : Computes the magnitude spectrum.
                            %       Spectrum is scaled as for 'pow' except
                            %       that it is instread divided by the sum
                            %       of the unsquared values of the window.
                            %	- 'complex' : Computes the complex
                            %       spectrum, which is then scaled the same
                            %       way as for 'mag'.
                            %	- 'mag_noscaling' : Computes the magnitude
                            %       spectrum without any of the scaling.
        hopSize     % Hop size of the window (in samples). Determines the 
                    %   time resolution of the representation.
        hopSize_sec = 0.0058% Hop size of the window (in seconds). See
                            %   Peeters (2011) for defaults.
        winSize     % Size of the window (in samples). Determines the 
                    %   frequency resolution of the representation.
        winSize_sec = 0.0232% Size of the window (in seconds). See Peeters 
                            %   (2011) for defaults.
        winType = 'hamming' % The kind of window used. This can be the name
                            %   of any function that accepts an integer
                            %   argument N and returns a vector of length N
                            %   containing a window.
        win         % A vector containing a window. If this is specified in
                    %   the configuration structure, the winSize will be
                    %   updated the winType will become 'custom'.
        fftSize     % The size of the FFT performed on each frame. This
                    %   should be greater than or equal to the window size
                    %   in samples because the STFT algorithm will not
                    %   window and fold the time-domain signal
                    %   appropriately if the FFT size is shorter than the
                    %   window as described in Portnoff (1980).
        binSize     % If not specified this is the sample rate divided by
                    %   the FFT size in samples.
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
        descrs      % Structure containing all the representation's 
                    %   possible descriptors. All fields correspond to a
                    %   possible descriptor type and are instantiated with
                    %   a value of 0 (see Rep's getDescrTypes() method).
    end
    methods (Access = public)
        function stftRep = STFT(sound, varargin)
            %CONSTRUCTOR From an audio signal representation, evaluates its
            %specrogram.
            %   Evaluates the spectrogram of the audio signal.
            
            stftRep = stftRep@TimeFreqDistr(sound);
            as = sound.reps.AudioSignal;
            
            if isempty(varargin)
                config = struct();
            else
                config = varargin{1};
            end
            if isfield(config, 'DistrType')
                if ~any(strcmp(config.DistrType, {'pow', 'mag', 'complex', 'mag_noscaling'}))
                    error('Config.DistrType can only accept the values ''pow'' (power spectrum), ''mag'' (magnitude spectrum), ''mag_noscaling'' (unscaled magnitude spectrum) or ''complex'' (full complex spectrogram).');
                end
                stftRep.distrType = config.DistrType;
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
                stftRep.hopSize_sec = config.HopSize_sec;
            end
            stftRep.hopSize = round(stftRep.hopSize_sec * as.sampRate);
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
                stftRep.winSize_sec = config.WinSize_sec;
            end
            stftRep.winSize = round(stftRep.winSize_sec * as.sampRate);
            if isfield(config, 'WinType')
                if ~any(strcmp(config.WinType, {'barthannwin', 'bartlett', 'blackman', 'blackmanharris', 'bohmanwin', 'chebwin', 'flattopwin', 'gausswin', 'hamming', 'hann', 'kaiser', 'nuttallwin', 'parzenwin', 'rectwin', 'taylorwin', 'triang', 'tukeywin'}))
                    error('Config.WinType must be a window type. It can accept the values ''barthannwin'', ''bartlett'', ''blackman'', ''blackmanharris'', ''bohmanwin'', ''chebwin'', ''flattopwin'', ''gausswin'', ''hamming'', ''hann'', ''kaiser'', ''nuttallwin'', ''parzenwin'', ''rectwin'', ''taylorwin'', ''triang'' and ''tukeywin''.');
                end
                stftRep.winType = config.WinType;
            end;
            if isfield(config, 'Win')
                if ~isa(config.Win, 'double') || length(config.Win) < 2
                    error('Config.Win must be a window in (double array of length > 1).');
                end
                stftRep.win = config.Win;
                stftRep.winSize = length(stftRep.win);
                stftRep.winType = 'custom';
            else
                stftRep.win = eval([stftRep.winType '(' num2str(stftRep.winSize) ')']);
            end;
            if isfield(config, 'FFTSize')
                if ~isa(config.FFTSize, 'double') || config.FFTSize <= 0
                    error('Config.FFTSize must be a Fast-Fourier Transform size in bins (double > 0).');
                end
                if config.FFTSize < stftRep.winSize
                    warning('The FFT size is less than the window size, the STFT algorithm might not work properly (as described in Portnoff (1980))');
                end
                stftRep.fftSize = config.FFTSize;
            else
                stftRep.fftSize = 2^nextpow2(stftRep.winSize);
            end;
            stftRep.binSize	= as.sampRate / stftRep.fftSize;
            
            stftRep.fSize = stftRep.fftSize/2;
            
            % If the window is centred at t, this is the starting index at which to
            % look up the sound.value which you want to multiply by the window. It is a
            % negative number because (almost) half of the window will be before time t
            % and half after. In fact, if the length of the window N is an even number,
            % it is set up so this number equals (N/2 - 1). If the length of the window
            % is odd, this number equals (N-1)/2.
            winFirstRelIdx = floor((stftRep.winSize-1)/2);
            % This is the last index at which to look up signal values and is equal to
            % (N-1)/2 if the length N of the window is odd and N/2 if the length of the
            % window is even. This means that in the even case, the window has an
            % unequal number of past and future values, i.e., time t is not the centre
            % of the window, but slightly to the left of the centre of the window
            % (before it).
            winLastRelIdx = ceil((stftRep.winSize-1)/2);
            
            if sound.chunkSize > 0
                if sound.chunkSize >= winFirstRelIdx
                    chunkSize = stftRep.hopSize * ceil(sound.chunkSize / stftRep.hopSize);
                else
                    chunkSize = stftRep.hopSize * ceil(winFirstRelIdx / stftRep.hopSize);
                end
            else
                chunkSize = as.len;
            end
            
            rangeStarts = 1:chunkSize:as.len;
            if length(rangeStarts) > 1
                wtbar = waitbar(0, 'Evaluating Analytic Signal', 'Name', 'Evaluating Short-Term Fourier Transform Representation');
            end
            
            paddedSignal = [zeros(1,winFirstRelIdx), as.value, zeros(1,winLastRelIdx)];
            paddedSignal = hilbert(paddedSignal);
            
            stftRep.value = [];
            
            for i = 1:length(rangeStarts)
                if length(rangeStarts) > 1
                    waitbar(i/(length(rangeStarts)+1), wtbar, ['Chunk ' num2str(i) ' of ' num2str(length(rangeStarts))]);
                end
                
                if i == length(rangeStarts)
                    signalChunk = paddedSignal(rangeStarts(i):min(rangeStarts(i) + stftRep.winSize + chunkSize - 1, end));
                else
                    signalChunk = paddedSignal(rangeStarts(i):min(rangeStarts(i) + stftRep.winSize - stftRep.hopSize + chunkSize - 1, end));
                end
               
                [distr, stftRep.fSupport, tSupport] = ...
                    spectrogram(signalChunk, stftRep.win, stftRep.winSize - stftRep.hopSize, stftRep.fftSize, as.sampRate);
                
                distr = distr(1:stftRep.fSize, :); % Only return frequencies below Nyquist rate.
                tSupport = tSupport - winFirstRelIdx/as.sampRate;
                
                if strcmp(stftRep.distrType, 'complex')
                    distr = distr ./ (sum(stftRep.win)); % remove window energy
                elseif strcmp(stftRep.distrType, 'pow') % Power distribution
                    distr = abs(distr).^2;
                    distr = distr ./ (sum(stftRep.win) .^2); %remove window energy
                elseif strcmp(stftRep.distrType, 'mag') % Magnitude distribution
                    distr = abs(distr);
                    distr = distr ./ sum(abs(stftRep.win));
                elseif strcmp(stftRep.distrType, 'mag_noscaling')
                    % magnitude distribution with no scaling
                    distr = abs(distr);
                else % Might want to add 'log' option as well (similar to IRCAM toolbox)
                    error('Unknown distribution type (options are: pow/mag)');
                end;
                
                stftRep.value = [stftRep.value, distr];
                
                if i == 1
                    stftRep.tSupport = tSupport;
                else
                    stftRep.tSupport = [stftRep.tSupport, stftRep.tSupport(end) + (stftRep.hopSize - 1)/as.sampRate + tSupport];
                end
            end
            
            stftRep.fSupport = stftRep.fSupport(1:stftRep.fSize); % Only return frequencies below Nyquist rate.
            stftRep.tSize = length(stftRep.tSupport);
            
            if length(rangeStarts) > 1
                close(wtbar);
            end
        end
        
        sameConfig = HasSameConfig(stftRep, config)
    end
end

