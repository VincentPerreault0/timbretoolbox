function ERBpower(erbRep, signal, wtbar)
%ERBPOWER FFT-based cochlear power spectrogram
%  [C,F,T,WSIZE] = ERBPOWER(A,SR,CFARRAY,HOPSIZE,BWFACTOR) 
%  Power spectrogram with same frequency resolution and scale as human ear.
%
%  A: audio signal
%  sr: Hz - sampling rate
%  CFARRAY: array of channel frequencies (default: 1/2 ERB-spaced 30Hz-16 KHz)
%  HOPSIZE: s - interval between analyses (default: 0.01 s)
%  BWFACTOR: factor to apply to filter bandwidths (default=1)
%  PAD:        A vector of values that can be used to pad the beginning of the
%              signal. This is useful when computing the spectrogram in chunks.
%              As the first window's centre is aligned with the first sample,
%              half (or half-1 if an odd sized window) of the window's samples
%              will be before the first sample. If this argument is not given,
%              these samples are taken to be 0. Otherwise N samples from the end
%              of this vector will be taken to be the signal before the 1st
%              sample where N is half the window length if the window is of even
%              length or half the window length - 1 if the window is of odd
%              length.
%
%  C: spectrogram matrix
%  F: Hz - array of channel frequencies
%  T: s - array of times
%  FORWARD_WINSIZE:  samples - This is the number of samples after the hop index
%                    that fit within the window. This might not be equal to the
%                    window size if the window is not aligned to the hop index
%                    at the beginning, e.g., when the window's centre is aligned
%                    with the hop index. This is used to calculate how many hops
%                    will be taken when calculating the spectrogram.
%
%  Spectral resolution is similar to that of the cochlea, temporal resolution is
%  similar to the ERD of the impulse response of the lowest CF channels (about 20 ms).
%  This is about twice behavioral estimates of auditory temporal resolution (8-13 ms).
%
% See also ERB, ERBtohz, ERBfromhz, MakeERBCoeffs, spectrogram.

% AdC @ CNRS/Ircam 2001
% (c) 2001 CNRS

%  ERBPOWER splits the signal into overlapping frames and windows each with
%  a function shaped like the time-reversed envelope of a gammatone impulse 
%  response with parameters appropriate for a low-frequency cochlear filter,
%  with an equivalent rectangular duration (ERD) of about 20ms. 
%  The FFT size is set to the power of two immediately larger than twice
%  that value (sr*0.040), and the windowed slices are Fourier transformed to 
%  obtain a power spectrum.  
%  The frequency resolution is that of a "cf=0 Hz" channel, ie narrower than 
%  even the lowest cf channels, and the frequency axis is linear.  To get a
%  resolution similar to the cochlea, and channels evenly spaced on an 
%  equal-resolution scale (Cambridge ERBs), the power spectrum is remapped.  
%  Each channel of the new spectrum is the weighted sum of power spectrum
%  coefficients, obtained by forming the vector product with a weighting function 
%  so that the channel has its proper spectral width.  

% TODO: calibrate output magnitude scale (?).

% space cfs at 1/2 ERB intervals from about 30Hz to 16kHz (or sr/2 if smaller):
lo		= 30;                            % Hz - lower cf
hi		= 16000;                         % Hz - upper cf
hi		= min(hi, (erbRep.sound.info.SampleRate/2-ERB.CFERB(erbRep.sound.info.SampleRate/2)/2));	% limit to 1/2 erb below Nyquist
nchans	= round(2*(ERB.ERBfromhz(hi)-ERB.ERBfromhz(lo)));
cfarray = ERB.ERBspace(lo,hi,nchans)';

% Window size and shape are based on the envelope of the gammatone
% impulse response of the lowest CF channel, with ERB = 24.7 Hz. 
% The FFT window size is the smallest power of 2 larger than twice the 
% ERD of this window.
bw0		= 24.7;        	% Hz - base frequency of ERB formula (= bandwidth of "0Hz" channel)
b0		= bw0/0.982;    % gammatone b parameter (Hartmann, 1997)
ERD		= 0.495 / b0; 	% based on numerical calculation of ERD
wsize	= 2^nextpow2(ERD*erbRep.sound.info.SampleRate*2);
window	= ERB.gtwindow(wsize, wsize/(ERD*erbRep.sound.info.SampleRate));

% pad signal with zeros to align analysis point with window power centroid
% n is the length of the signal, m is the number of channels
[m,n]=size(signal);
if m>1
    signal=signal';
    if n>1
        error('signal should be 1D');
    end
    n=m;
end
% if window size is odd and window is symmetric, offset = floor(wsize/2), if
% window size is even, offset = wsize/2
offset	= ceil(ERB.centroid(window.^2))-1;

forward_winsize=(wsize-offset);

signal = [zeros(1,offset), signal];

% last hop index where the window will fit within the end of the signal
last_index=floor((n-(wsize-offset))/erbRep.hopSize)*erbRep.hopSize+1;
startsamples=(1:erbRep.hopSize:last_index);

% array of kernel bandwidth coeffs:
b	= ERB.CFERB(cfarray)/0.982; % ERB to gammatone b parameter
% b	= b * bwfactor; % we assume bwfactor = 1
bb	= sqrt(b.^2 - b0.^2);			% factor 2 is for power

% test: compare desired gammatone response with result of convolution:
% if (0)
% 	channel=20;
% 	[b(channel),bb(channel),cfarray(channel)]
% 	f	= (1:wsize/2)'*sr/wsize;
% 	z	= abs(1./(i*(f-cfarray(channel))+b(channel)).^4).^2;	% target
% 	z0	= abs(1./(i*(f-cfarray(channel))+b0).^4).^2;			% FFT window TF shape
% 	zz	= abs(1./(i*(f-cfarray(channel))+bb(channel)).^4).^2;	% kernel
% 	zz	= conv(zz,z0);											% convolve
% 	zz	= zz(round(cfarray(channel)*wsize/sr):end);				% shift so peaks match
% 	z	= z/max(z); zz = zz/max(zz); 
% 	plot(f, todb(z), 'r', (1:size(zz,1))'*sr/wsize, todb(zz), 'b'); 
% 	set(gca, 'xlim', [1, cfarray(channel)*3]); pause
% end

% matrix of kernels (array of gammatone power tfs sampled at fft spectrum frequencies).
fSupport		= repmat((1:wsize/2)'*erbRep.sound.info.SampleRate/wsize,1,nchans);
cf		= repmat(cfarray',wsize/2,1);
bb		= repmat(bb',wsize/2,1);
wfunct			= abs(1./(length(startsamples)*(fSupport - cf) + bb).^4).^2;		% power transfer functions
adjustweight	= ERB.CFERB(cfarray') ./ sum(wfunct);			% adjust so weight == ERB
wfunct	= wfunct .* repmat(adjustweight, wsize/2, 1); 
wfunct	= wfunct/max(max(wfunct));

if erbRep.sound.chunkSize > 0
    chunkSize = ceil(erbRep.sound.chunkSize / erbRep.hopSize);
else
    chunkSize = length(startsamples);
end

rangeStartIdcs = 1:chunkSize:length(startsamples);

erbRep.value = [];

for k = 1:length(rangeStartIdcs)
    
    if nargin == 3
        waitbar(0.1+0.85*(k-1)/length(rangeStartIdcs), wtbar, ['Chunk ' num2str(k) ' of ' num2str(length(rangeStartIdcs))]);
    end
    
    % matrix of windowed slices of signal
    fr=zeros(wsize,min(chunkSize, length(startsamples) - rangeStartIdcs(k) + 1));
    
    for i=rangeStartIdcs(k):min(rangeStartIdcs(k) + chunkSize - 1, length(startsamples))
        fr(:,i-rangeStartIdcs(k)+1) = signal(startsamples(i):(startsamples(i)+(wsize-1))) .* window';
    end
    
    % power spectrum
    pwrspect = abs(fft(fr)).^2;
    clear 'fr';
    pwrspect = pwrspect(1:wsize/2,:);
    %plot(sum(pwrspect').^(1/3)); pause
    % Power spectrum samples are weighted and summed (an operation similar to
    % convolution, except that the convolution kernel changes from channel
    % to channel).  The weighting function (kernel) for each channel is the
    % power transfer function of a gammatone with a bandwidth equal to sqrt(b^2-b0^2).
    % The rationale is:
    % - by convolution the nominal bandwidth is b, which is what we want,
    % - at low CFs the shape is dominated by the TF of the FFT window, ie OK,
    % - at high CFs the shape is dominated by the kernel, also OK,
    % - at intermediate CFs (around 200 Hz), the convolved shape turns out to
    % quite close to the correct gammatone response shape (less than 3dB difference
    % down to -50 dB from peak).
    
    tmp = wfunct' * pwrspect;
    %disp(size(tmp));
    % multiply fft power spectrum matrix by weighting function matrix:
    erbRep.value = [erbRep.value, tmp];
    clear 'pwrspect';
end

erbRep.fSupport = cfarray;
erbRep.tSupport = (startsamples-1)/erbRep.sound.info.SampleRate;
