function [pitches, times, strengths] = swipep(signal, sampRate, pitchLims, timeStep, log2PitchStep, ERBStep, normOverlap, strenThresh)
% SWIPEP Pitch estimation using SWIPE'.
%    P = SWIPEP(X,Fs,[PMIN PMAX],DT,DLOG2P,DERBS,STHR) estimates the pitch 
%    of the vector signal X every DT seconds. The sampling frequency of
%    the signal is Fs (in Hertz). The spectrum is computed using a Hann
%    window with an overlap WOVERLAP between 0 and 1. The spectrum is
%    sampled uniformly in the ERB scale with a step size of DERBS ERBs. The
%    pitch is searched within the range [PMIN PMAX] (in Hertz) with samples
%    distributed every DLOG2P units on a base-2 logarithmic scale of Hertz. 
%    The pitch is fine-tuned using parabolic interpolation with a resolution
%    of 1 cent. Pitch estimates with a strength lower than STHR are treated
%    as undefined.
%    
%    [P,T,S] = SWIPEP(X,Fs,[PMIN PMAX],DT,DLOG2P,DERBS,WOVERLAP,STHR) 
%    returns the times T at which the pitch was estimated and the pitch 
%    strength S of every pitch estimate.
%
%    P = SWIPEP(X,Fs) estimates the pitch using the default settings PMIN =
%    30 Hz, PMAX = 5000 Hz, DT = 0.001 s, DLOG2P = 1/48 (48 steps per 
%    octave), DERBS = 0.1 ERBs, WOVERLAP = 0.5, and STHR = -Inf.
%
%    P = SWIPEP(X,Fs,...,[],...) uses the default setting for the parameter
%    replaced with the placeholder [].
%
%    REMARKS: (1) For better results, make DLOG2P and DERBS as small as 
%    possible and WOVERLAP as large as possible. However, take into account
%    that the computational complexity of the algorithm is inversely 
%    proportional to DLOG2P, DERBS and 1-WOVERLAP, and that the  default 
%    values have been found empirically to produce good results. Consider 
%    also that the computational complexity is directly proportional to the
%    number of octaves in the pitch search range, and therefore , it is 
%    recommendable to restrict the search range to the expected range of
%    pitch, if any. (2) This code implements SWIPE', which uses only the
%    first and prime harmonics of the signal. To convert it into SWIPE,
%    which uses all the harmonics of the signal, replace the word
%    PRIMES with a colon (it is located almost at the end of the code).
%    However, this may not be recommendable since SWIPE' is reported to 
%    produce on average better results than SWIPE (Camacho and Harris,
%    2008).
%
%    EXAMPLE: Estimate the pitch of the signal X every 10 ms within the
%    range 75-500 Hz using the default resolution (i.e., 48 steps per
%    octave), sampling the spectrum every 1/20th of ERB, using a window 
%    overlap factor of 50%, and discarding samples with pitch strength 
%    lower than 0.2. Plot the pitch trace.
%       [x,Fs] = wavread(filename);
%       [p,t,s] = swipep(x,Fs,[75 500],0.01,[],1/20,0.5,0.2);
%       plot(1000*t,p)
%       xlabel('Time (ms)')
%       ylabel('Pitch (Hz)')
%
%    REFERENCES: Camacho, A., Harris, J.G, (2008) "A sawtooth waveform 
%    inspired pitch estimator for speech and music," J. Acoust. Soc. Am.
%    124, 1638-1652.
%
%    MAINTENANCE HISTORY:
%    - Added line 153 to avoid division by zero in line 154 if loudness
%      equals zero (06/23/2010).
if ~ exist( 'pitchLims', 'var' ) || isempty(pitchLims)
    pitchLims = [30 5000];
end
if ~ exist( 'timeStep', 'var' ) || isempty(timeStep)
    timeStep = 0.001;
end
if ~ exist( 'log2FreqStep', 'var' ) || isempty(log2PitchStep)
    log2PitchStep = 1/48;
end
if ~ exist( 'ERBStep', 'var' ) || isempty(ERBStep)
    ERBStep = 0.1;
end
if ~ exist( 'normOverlap', 'var' ) || isempty(normOverlap)
    normOverlap = 0.5;
elseif normOverlap > 1 || normOverlap < 0
    error('Window overlap must be between 0 and 1.')
end
if ~ exist( 'sTHR', 'var' ) || isempty(strenThresh)
    strenThresh = -Inf;
end
times = (0: timeStep: length(signal)/sampRate)'; % Times
% Define pitch candidates
log2PitchCands = (log2(pitchLims(1)): log2PitchStep: log2(pitchLims(2)))';
pitchCands = 2 .^ log2PitchCands;
globStrenMtrx = zeros(length(pitchCands), length(times)); % Pitch strength matrix
% Determine P2-WinSizes
logWinSizeLims = round( log2( 8*sampRate ./ pitchLims ) ); 
winSizes = 2.^(logWinSizeLims(1): -1: logWinSizeLims(2)); % P2-WSs
winSizeOptPitches = 8 * sampRate ./ winSizes; % Optimal pitches for P2-WSs
% Determine window sizes used by each pitch candidate
log2DistWin1OptPitchAndPitchCands = log2PitchCands - log2(winSizeOptPitches(1)) + 1;
% Create ERB-scale uniformly-spaced frequencies (in Hertz)
ERBs = erbs2hz((hz2erbs(min(pitchCands)/4): ERBStep: hz2erbs(sampRate/2))');
for winSizeIdx = 1 : length(winSizes)
    hopSize = max(1, round((1 - normOverlap) * winSizes(winSizeIdx))); % Hop size
    % Zero pad signal
    paddedSignal = [zeros(winSizes(winSizeIdx)/2, 1); signal(:); zeros(hopSize + winSizes(winSizeIdx)/2, 1)];
    % Compute spectrum
    win = hanning(winSizes(winSizeIdx)); % Hann window 
    overlap = max(0, winSizes(winSizeIdx) - hopSize); % Window overlap
    [distr, fSupport, tSupport ] = spectrogram(paddedSignal, win, overlap, [], sampRate);
    % Select candidates that use this window size
    if length(winSizes) == 1
        optPitchCandsIdcs = (1:length(pitchCands))';
        imperfectFitIdcs = [];
    elseif winSizeIdx == length(winSizes)
        optPitchCandsIdcs = find(log2DistWin1OptPitchAndPitchCands - winSizeIdx > -1);
        imperfectFitIdcs = find(log2DistWin1OptPitchAndPitchCands(optPitchCandsIdcs) - winSizeIdx < 0);
    elseif winSizeIdx == 1
        optPitchCandsIdcs = find(log2DistWin1OptPitchAndPitchCands - winSizeIdx < 1);
        imperfectFitIdcs = find(log2DistWin1OptPitchAndPitchCands(optPitchCandsIdcs) - winSizeIdx > 0);
    else
        optPitchCandsIdcs = find(abs(log2DistWin1OptPitchAndPitchCands - winSizeIdx) < 1);
        imperfectFitIdcs = (1:length(optPitchCandsIdcs))';
    end
    % Compute loudness at ERBs uniformly-spaced frequencies
    ERBs = ERBs(find(ERBs > pitchCands(optPitchCandsIdcs(1))/4, 1, 'first'):end);
    ERBsDistrValues = sqrt(max(0, interp1(fSupport, abs(distr), ERBs, 'spline', 0)));
    % Compute pitch strength
    locStrenMtrx = pitchStrengthAllCandidates(ERBs, ERBsDistrValues, pitchCands(optPitchCandsIdcs));
    % Interpolate pitch strength at desired times
    if size(locStrenMtrx, 2) > 1
        warning off MATLAB:interp1:NaNinY
        locStrenMtrx = interp1(tSupport, locStrenMtrx', times, 'linear', NaN )';
        warning on MATLAB:interp1:NaNinY
    else
        locStrenMtrx = NaN(length(locStrenMtrx), length(times));
    end
    % Add pitch strength to combination
    currWinRelStren = ones(size(optPitchCandsIdcs));
    log2DistCurrWinOptPitchAndOptPitchCands = log2DistWin1OptPitchAndPitchCands(optPitchCandsIdcs(imperfectFitIdcs)) - winSizeIdx;
    currWinRelStren(imperfectFitIdcs) = 1 - abs(log2DistCurrWinOptPitchAndOptPitchCands);
    globStrenMtrx(optPitchCandsIdcs,:) = globStrenMtrx(optPitchCandsIdcs,:) + repmat(currWinRelStren,1,size(locStrenMtrx,2)) .* locStrenMtrx;
end
% Fine tune pitch using parabolic interpolation
pitches = NaN(size(globStrenMtrx,2), 1);
strengths = NaN(size(globStrenMtrx,2), 1);
for timeIdx = 1 : size(globStrenMtrx,2)
    [strengths(timeIdx), maxStrenPitchIdx] = max(globStrenMtrx(:,timeIdx), [], 1);
    if strengths(timeIdx) < strenThresh
        continue;
    end
    if maxStrenPitchIdx == 1 || maxStrenPitchIdx == length(pitchCands)
        pitches(timeIdx) = pitchCands(maxStrenPitchIdx);
    else
        maxStrenPitchLocIdcs = maxStrenPitchIdx - 1 : maxStrenPitchIdx + 1;
        tc = 1 ./ pitchCands(maxStrenPitchLocIdcs);
        ntc = (tc/tc(2) - 1) * 2*pi;
        c = polyfit(ntc, globStrenMtrx(maxStrenPitchLocIdcs,timeIdx), 2);
        ftc = 1 ./ 2.^(log2(pitchCands(maxStrenPitchLocIdcs(1))): 1/12/100: log2(pitchCands(maxStrenPitchLocIdcs(3))));
        nftc = (ftc/tc(2) - 1) * 2*pi;
        [strengths(timeIdx), maxPolyFitIdcs] = max(polyval(c, nftc));
        pitches(timeIdx) = 2 ^ (log2(pitchCands(maxStrenPitchLocIdcs(1))) + (maxPolyFitIdcs-1)/12/100);
    end
end

function locStrenMtrx = pitchStrengthAllCandidates(ERBs, ERBsDistrValues, pitchCands)
% Create pitch strength matrix
locStrenMtrx = zeros(length(pitchCands), size(ERBsDistrValues,2));
% Define integration regions
k = ones(1, length(pitchCands) + 1);
for j = 1 : length(k)-1
    k(j+1) = k(j) - 1 + find(ERBs(k(j):end) > pitchCands(j)/4, 1, 'first');
end
k = k(2:end);
% Create loudness normalization matrix
N = sqrt(flipud(cumsum(flipud(ERBsDistrValues.*ERBsDistrValues))));
for j = 1 : length(pitchCands)
    % Normalize loudness
    n = N(k(j),:);
    n(n==0) = Inf; % to make zero-loudness equal zero after normalization
    NL = ERBsDistrValues(k(j):end,:) ./ repmat( n, size(ERBsDistrValues,1)-k(j)+1, 1);
    % Compute pitch strength
    locStrenMtrx(j,:) = pitchStrengthOneCandidate( ERBs(k(j):end), NL, pitchCands(j) );
end

function locStrenLine = pitchStrengthOneCandidate(ERBS, normERBsDistrValues, pitchCand)
n = fix( ERBS(end)/pitchCand - 0.75 ); % Number of harmonics
if n==0, locStrenLine=NaN; return, end
k = zeros( size(ERBS) ); % Kernel
% Normalize frequency w.r.t. candidate
q = ERBS / pitchCand;
% Create kernel
for i = [ 1 primes(n) ]
    a = abs( q - i );
    % Peak's weigth
    p = a < .25; 
    k(p) = cos( 2*pi * q(p) );
    % Valleys' weights
    v = .25 < a & a < .75;
    k(v) = k(v) + cos( 2*pi * q(v) ) / 2;
end
% Apply envelope
k = k .* sqrt( 1./ERBS  ); 
% K+-normalize kernel
k = k / norm( k(k>0) ); 
% Compute pitch strength
locStrenLine = k' * normERBsDistrValues; 

function ERBs = hz2erbs(Hzs)
ERBs = 6.44 * ( log2( 229 + Hzs ) - 7.84 );

function Hzs = erbs2hz(ERBs)
Hzs = ( 2 .^ ( ERBs./6.44 + 7.84) ) - 229;
