classdef Harmonic < GenTimeFreqDistr
    %HARMONIC Class for harmonic sinusoidal model representation.
    
    properties (Constant)
        exceptions = {'exceptions', 'fundamentalFreqs', 'partialFreqs', 'partialAmps'}
        % The properties with default values that should not be exported
        %   (in .csv format).
    end
    properties (GetAccess = public, SetAccess = protected)
        sound       % SoundFile object of which it is a representation.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the representation (2*nHarms by 
                    %   length(tSupport) matrix). The first nHarms lines
                    %   are the frequencies of the first nHarms harmonic
                    %   partials. The last nHarms lines are the amplitudes
                    %   of the first nHarms harmonic partials.
        threshold = 0.3 % Threshold over which at least one estimated pitch
                        %   must be in order to consider the chunk harmonic
                        %   and continue the evaluation. Otherwise the
                        %   whole chunk (partials' frequencies and
                        %   amplitudes) will have a value of 0.
        nHarms = 20 % Number of harmonic partials considered for the model.
        stft        % Spectrogram (STFT object) from which values the
                    %   harmonic representation will be evaluated.
    end
    properties (Dependent)
        fundamentalFreqs% Fundamental frequencies of the harmonic
                        %   representation (first line of the value
                        %   matrix).
        partialFreqs% Frequencies of the nHarms first harmonic partials of
                    %   the model (first nHarms lines of the value matrix).
        partialAmps % Amplitudes of the nHarms first harmonic partials of
                    %   the model (last nHarms lines of the value matrix).
    end
    properties (Access = public)
        descrs      % Structure containing all the representation's 
                    %   possible descriptors. All fields correspond to a
                    %   possible descriptor type and are instantiated with
                    %   a value of 0 (see Rep's getDescrTypes() method).
    end
    methods
        % Get and Set functions for the dependent properties.
        function fundamentalFreqs = get.fundamentalFreqs(harmRep)
            fundamentalFreqs = harmRep.value(1,:);
        end
        function partialFreqs = get.partialFreqs(harmRep)
            partialFreqs = harmRep.value(1:harmRep.nHarms,:);
        end
        function partialAmps = get.partialAmps(harmRep)
            partialAmps = harmRep.value(harmRep.nHarms+1:2*harmRep.nHarms,:);
        end
        function set.fundamentalFreqs(harmRep, fundamentalFreqs)
            harmRep.value(1,:) = fundamentalFreqs;
        end
        function set.partialFreqs(harmRep, partialFreqs)
            harmRep.value(1:harmRep.nHarms,:) = partialFreqs;
        end
        function set.partialAmps(harmRep, partialAmps)
            harmRep.value(harmRep.nHarms+1:2*harmRep.nHarms,:) = partialAmps;
        end
    end
    methods (Access = public)
        function harmRep = Harmonic(sound, varargin)
            %CONSTRUCTOR From an audio signal representation, evaluates a
            %Harmonic Sinusoidal Model representation.
            %   Firstly, evaluates a spectrogram of the audio signal.
            %   Secondly, using the spectrogram, estimates the fundamental
            %   pitches for all hop times. Finally, optimizes and corrects
            %   the fundamental frequencies while evaluating the
            %   inharmonicity coefficient which, in turn, gives out the
            %   frequencies of the rest of the harmonic partials and all
            %   their amplitudes (using again the spectrogram).
            
            harmRep = harmRep@GenTimeFreqDistr(sound);
            as = sound.reps.AudioSignal;
            
            if isempty(varargin)
                config = struct();
            else
                config = varargin{1};
            end
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
            else
                config.WinSize_sec = 0.1;
            end
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
            else
                config.HopSize_sec = 0.025;
            end
            if isfield(config, 'WinType')
                if ~any(strcmp(config.WinType, {'barthannwin', 'bartlett', 'blackman', 'blackmanharris', 'bohmanwin', 'chebwin', 'flattopwin', 'gausswin', 'hamming', 'hann', 'kaiser', 'nuttallwin', 'parzenwin', 'rectwin', 'taylorwin', 'triang', 'tukeywin'}))
                    error('Config.WinType must be a window type. It can accept the values ''barthannwin'', ''bartlett'', ''blackman'', ''blackmanharris'', ''bohmanwin'', ''chebwin'', ''flattopwin'', ''gausswin'', ''hamming'', ''hann'', ''kaiser'', ''nuttallwin'', ''parzenwin'', ''rectwin'', ''taylorwin'', ''triang'' and ''tukeywin''.');
                end
            else
                config.WinType = 'blackman';
            end
            if isfield(config, 'FFTSize')
                if ~isa(config.FFTSize, 'double') || config.FFTSize <= 0
                    error('Config.FFTSize must be a Fast-Fourier Transform size in bins (double > 0).');
                end
            else
                config.FFTSize = 4*2^nextpow2(round(config.WinSize_sec*as.sampRate));% === large zero-padding to get better frequency resolution
            end
            config.DistrType = 'pow';
            
            harmRep.stft = STFT(sound, config);
            harmRep.tSupport = harmRep.stft.tSupport;
            
            if isfield(config, 'Threshold')
                if ~isa(config.Threshold, 'double') || config.Threshold <= 0 || config.Threshold > 1
                    error('Config.Threshold must be a threshold (1 >= double > 0).');
                end
                harmRep.threshold = config.Threshold;
            end
            if isfield(config, 'NHarms')
                if ~isa(config.NHarms, 'double') || config.NHarms < 1
                    error('Config.NHarms must be a number of harmonic partials (double >= 1).');
                end
                harmRep.nHarms = config.NHarms;
            end
            
            maxSwipepWinSize = harmRep.stft.hopSize*ceil(2^(round(log2(8*harmRep.sound.info.SampleRate ./ 50))-1)/harmRep.stft.hopSize);
            
            if sound.chunkSize > 0
                if sound.chunkSize >= maxSwipepWinSize
                    chunkSize = harmRep.stft.hopSize * ceil(sound.chunkSize / harmRep.stft.hopSize);
                else
                    chunkSize = harmRep.stft.hopSize * ceil(maxSwipepWinSize / harmRep.stft.hopSize);
                end
            else
                chunkSize = as.len;
            end
            
            rangeStarts = 1:chunkSize:as.len;
            if length(rangeStarts) > 1
                wtbar = waitbar(0, 'Evaluating Analytic Signal', 'Name', 'Evaluating Harmonic Partials Representation');
            end
            
            harmRep.value = [];
            
            freqCorrs		= -5:0.1:5;
            nFreqCorrs		= length(freqCorrs);
            inharmCoeffs	= 0:0.00005:0.001;
            nInharmCoeffs	= length(inharmCoeffs);
            
            for i = 1:length(rangeStarts)
                if length(rangeStarts) > 1
                    waitbar(i/(length(rangeStarts)+1), wtbar, ['Chunk ' num2str(i) ' of ' num2str(length(rangeStarts))]);
                end
                
                if i > 1
                    startIdx = find(harmRep.tSupport>as.tSupport(rangeStarts(i)),1);
                else
                    startIdx = 1;
                end
                if i < length(rangeStarts)
                    endIdx = find(harmRep.tSupport<=as.tSupport(min(rangeStarts(i) + chunkSize - 1, end)),1,'last');
                else
                    endIdx = length(harmRep.tSupport);
                end
                
                tSupport = harmRep.tSupport(startIdx:endIdx) - harmRep.tSupport(startIdx);
                tSize = endIdx - startIdx + 1;
                distr = harmRep.stft.value(:,startIdx:endIdx);
                
                if i == 1
                    signalChunk = as.value(rangeStarts(i):min(rangeStarts(i) + maxSwipepWinSize + chunkSize - 1, end));
                else
                    signalChunk = as.value(rangeStarts(i) - maxSwipepWinSize:min(rangeStarts(i) + maxSwipepWinSize + chunkSize - 1, end));
                end
                
                % ==========================================================
                % === We consider only harmonic sounds -> if the sound is not harmonic then we do not analyse it
                [estPitches, estTimes, estStrengths] = Harmonic.swipep(signalChunk, harmRep.sound.info.SampleRate, [50 500], harmRep.stft.hopSize / harmRep.sound.info.SampleRate, 1/48, 0.1, 0.2, -Inf);
                estPitches(isnan(estPitches)) = median(estPitches(~isnan(estPitches)));
                
                if max(estStrengths)>harmRep.threshold
                    estTimePitchPairs = zeros(length(estTimes), 2);
                    if i == 1
                        estTimePitchPairs(:,1) = estTimes;
                    else
                        estTimePitchPairs(:,1) = estTimes - maxSwipepWinSize/as.sampRate;
                    end
                    estTimePitchPairs(:,2) = estPitches;
                    % Estimate f0 at times at which spectrogram was evaluated by interpolating
                    % between times when f0 was evaluated
                    fundamentalFreqs = Harmonic.Fevalbp(estTimePitchPairs, tSupport);
                    fundamentalFreqs = fundamentalFreqs';
                else
                    warning('Sound deemed not harmonic. Setting f0 estimate to 0.');
                    % If sound not harmonic, we just fill in with 0s as fundamental estimate,
                    % otherwise this will cause there to be misalignment if the sound
                    % analysed is a chunk of a whole sound.
                    harmRep.value = [harmRep.value, zeros(2*harmRep.nHarms, tSize)];
                    continue;
                end
                
                % === corrected Frequencies indexed by Time and Frequency (nb_frame, nb_FrqCorrs)
                % This is a range of frequencies around f0 the harmonics of which are
                % searched for spectral peaks.
                corrFreqsTF = repmat(fundamentalFreqs(:), 1, nFreqCorrs) + repmat(freqCorrs, tSize, 1);
                
                inharmFactorsHI = repmat((1:harmRep.nHarms)', 1, nInharmCoeffs) .* sqrt( 1 + ((1:harmRep.nHarms)').^2 * inharmCoeffs);
                
                fSupIdcsTFHI = 1 + round(1 / harmRep.stft.binSize * reshape(reshape(corrFreqsTF, [tSize*nFreqCorrs 1]) *...
                    reshape(inharmFactorsHI, [1 harmRep.nHarms*nInharmCoeffs]), [tSize nFreqCorrs harmRep.nHarms nInharmCoeffs]));
                fSupIdcsTFHI(fSupIdcsTFHI > harmRep.stft.fSize) = harmRep.stft.fSize;
                
                distrIdcsTFHI = fSupIdcsTFHI + harmRep.stft.fSize * repmat((0:tSize-1)', [1 nFreqCorrs harmRep.nHarms nInharmCoeffs]);
                
                totalErgTFI = squeeze(sum(distr(distrIdcsTFHI), 3));
                
                % The optimal harmonicity coefficient is chosen for the entire
                % soundfile analysed.
                % === choix du coefficient d'inharmonicite
                scoreTI = squeeze(max(totalErgTFI,[], 2));
                
                % If the maximum score is within 1% of the first score, just choose the first
                % score. That is, just choose the inharmonicity coefficient at index 1.
                [maxScoreTI, inharmCoeffIdcsT] = max(scoreTI, [], 2);
                inharmCoeffIdcsT((maxScoreTI-scoreTI(:,1))./scoreTI(:,1)<=0.01) = 1;
                
                colIdcs = reshape(repmat((1:tSize)' + tSize*nFreqCorrs*(inharmCoeffIdcsT - 1), 1, nFreqCorrs) + repmat(tSize*((1:nFreqCorrs) - 1), tSize, 1), [tSize*nFreqCorrs 1]);
                totalErgTF = zeros(tSize, nFreqCorrs);
                totalErgTF(:) = totalErgTFI(colIdcs);
                
                colIdcs = reshape(repmat(reshape((1:tSize)' + tSize*nFreqCorrs*harmRep.nHarms*(inharmCoeffIdcsT - 1), [tSize 1 1]), [1, nFreqCorrs, harmRep.nHarms]) + tSize*(repmat(reshape(1:nFreqCorrs, [1 nFreqCorrs 1]), [tSize, 1, harmRep.nHarms]) + nFreqCorrs*(repmat(reshape(1:harmRep.nHarms, [1 1 harmRep.nHarms]), [tSize, nFreqCorrs, 1]) - 1) - 1), [tSize*nFreqCorrs*harmRep.nHarms 1]);
                fSupIdcsHTF = zeros(tSize, nFreqCorrs, harmRep.nHarms);
                fSupIdcsHTF(:) = fSupIdcsTFHI(colIdcs);
                fSupIdcsHTF = permute(fSupIdcsHTF, [3 1 2]);
                
                [~, freqCorrIdcsT] = max(totalErgTF, [], 2);
                
                colIdcs = reshape(repmat((1:harmRep.nHarms)', 1, tSize) + repmat(harmRep.nHarms*((1:tSize) + tSize*(freqCorrIdcsT' - 1) - 1), harmRep.nHarms, 1), [harmRep.nHarms*tSize 1]);
                partialFreqs = zeros(harmRep.nHarms, tSize);
                partialFreqs(:) = harmRep.stft.fSupport(fSupIdcsHTF(colIdcs));
                partialAmps = zeros(harmRep.nHarms, tSize);
                partialAmps(:) = distr(fSupIdcsHTF(colIdcs) + harmRep.stft.fSize*reshape(repmat((0:tSize-1), harmRep.nHarms, 1), [harmRep.nHarms*tSize 1]));
                
                harmRep.value = [harmRep.value, [partialFreqs; partialAmps]];
            end
            
            if length(rangeStarts) > 1
                close(wtbar);
            end
        end
        
        function PlotAndYLabel(harmRep, ax, alone, timeRes)
            %PLOTANDYLABEL Plots the harmonic representation in the
            %specified axes.
            %   Plots the Harmonic object in the specified axes at the
            %   specified time resolution. If it is to be plotted alone in
            %   the figure, a title and an x-label will be added as well.
            
            harmRep.stft.PlotAndYLabel(ax, false, timeRes);
            maxTimeRes = 500/harmRep.tSupport(end);
            if timeRes == 0 || timeRes > maxTimeRes
                timeRes = maxTimeRes;
            end
            [tSup, val] = harmRep.EvalTimeRes(timeRes);
            fundFreqs = val(1,:);
            partFreqs = val(1:harmRep.nHarms,:);
            partAmps = val(harmRep.nHarms+1:2*harmRep.nHarms,:);
            hold(ax, 'on');
            maxAmps = max(max(partAmps));
            multTSupport = repmat(tSup, harmRep.nHarms, 1);
            scatter(ax, multTSupport(:), partFreqs(:), 10*max(0.1,10 + log10(partAmps(:)/maxAmps)), 'g.');
            scatter(ax, tSup, fundFreqs, 10*max(0.1,10 + log10(partAmps(1,:)/maxAmps)), 'b.');
            hold(ax, 'off');
            if alone
                title(ax, 'Harmonic Representation');
                xlabel(ax, 'Time (s)');
            end
        end
        
        sameConfig = HasSameConfig(harmRep, config)
        
        function csvfile = ExportCSVValue(harmRep, csvfile, directory, csvfileName, valueType, timeRes)
            %EXPORTCSVVALUE Exports the value of the Harmonic in the
            %specified .csv file.
            %   Exports the Harmonic's value in the specified value type
            %   ('ts' for the time series at the specified time resolution
            %   and 'stats' for the minimum, maximum, median and
            %   interquartile range statistics) in the specified .csv file
            %   with the specified .csv file name in the specified
            %   directory.
            
            if strcmp(valueType, 'ts')
                [tSup, val] = harmRep.EvalTimeRes(timeRes);
                fprintf(csvfile, 'Time Support Vector, Fundamental Frequencies, Other Partials'' Frequencies,');
                for i = 3:harmRep.nHarms
                    fprintf(csvfile, ',');
                end
                fprintf(csvfile, 'Partials'' Amplitudes\n');
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],[tSup', val'],'-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
            else
                fprintf(csvfile, 'Fundamental Frequencies, Other Partials'' Frequencies,');
                for i = 3:harmRep.nHarms
                    fprintf(csvfile, ',');
                end
                fprintf(csvfile, 'Partials'' Amplitudes\n');
                fprintf(csvfile, 'Minimums,\n');
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],min(harmRep.value,[],2)','-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
                fprintf(csvfile, 'Maximums,\n');
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],max(harmRep.value,[],2)','-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
                fprintf(csvfile, 'Medians,\n');
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],median(harmRep.value,2)','-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
                fprintf(csvfile, 'Interquartile Ranges,\n');
                fclose(csvfile);
                dlmwrite([directory '/' csvfileName '.csv'],iqr(harmRep.value,2)','-append','newline','unix','precision',10);
                csvfile = fopen([directory '/' csvfileName '.csv'], 'a');
            end
        end
    end
    
    methods (Static)
        [pitches, times, strengths] = swipep(signal, sampRate, pitchLims, timeStep, log2FreqStep, ERBStep, normOverlap, strenThresh)
        % SWIPEP Pitch estimation using SWIPE'.
        
        [y_v] = Fevalbp(bp, x_v) % From a set of time-pitch pairs in bp,
        % estimate pitches at the times in x_v vialinear interpolation.
    end
end