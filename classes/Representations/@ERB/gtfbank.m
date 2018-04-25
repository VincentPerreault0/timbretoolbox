function [b,f] = gtfbank(a,sr,cfarray,bwfactor)
%GTFBANK - apply gammatone filterbank to signal
%  [B,F]=GTFBANK(A,SR,CFARRAY,BWFACTOR)
%
%  A: input signal
%  SR: Hz - sampling rate
%  CFARRAY: Hz - array of center frequencies (default: 2/ERB between 30 and 16000 Hz)
%  BWFACTOR: factor to apply to standard bandwidth (default: 1)
%  B: array of filtered signals, one row per channel
%  F: array of center frequencies
%
%  AdC @ CNRS/Ircam 2001, repackaged code from Malcolm Slaney's auditory toolbox
%  (c) 2001 CNRS


if nargin < 1 | isempty(a) ; error('no input vector'); end
if nargin < 2 | isempty(sr) ; error('need to specify sr'); end
if nargin < 3 | isempty(cfarray)
	% space cfs at 1/2 ERB intervals from about 30Hz to 16kHz (or sr/2 if smaller):
	lo = 30;                            % Hz - lower cf
	hi = 16000;                         % Hz - upper cf
	hi = min(hi, (sr/2-ERB.CFERB(sr/2)/2));	% limit to 1/2 erb below Nyquist
	nchans	= round(2*(ERB.ERBfromhz(hi)-ERB.ERBfromhz(lo)));
	cfarray = ERB.ERBspace(lo,hi,nchans); 
end
[nchans,m]=size(cfarray);
if m>1; cfarray = cfarray'; if nchans>1; error('channel array should be 1D'); end; nchans=m; end

if nargin < 4 | isempty(bwfactor); bwfactor = 1; end
[m,n]=size(a);
if m>1; a=a'; if n>1; error('signal should be 1D'); end; n=m; end

% make array of filter coefficients
fcoefs=ERB.MakeERBCoeffs(sr, cfarray, bwfactor);
A0  = fcoefs(:,1);
A11 = fcoefs(:,2);
A12 = fcoefs(:,3);
A13 = fcoefs(:,4);
A14 = fcoefs(:,5);
A2  = fcoefs(:,6);
B0  = fcoefs(:,7);
B1  = fcoefs(:,8);
B2  = fcoefs(:,9);
gain= fcoefs(:,10);	

output = zeros(nchans, n);
for chan = 1: nchans
	y1 = filter([A0(chan)/gain(chan) A11(chan)/gain(chan) A2(chan)/gain(chan)],[B0(chan) B1(chan) B2(chan)], a);
	y2 = filter([A0(chan) A12(chan) A2(chan)],[B0(chan) B1(chan) B2(chan)], y1);
	y3 = filter([A0(chan) A13(chan) A2(chan)],[B0(chan) B1(chan) B2(chan)], y2);
	y4 = filter([A0(chan) A14(chan) A2(chan)],[B0(chan) B1(chan) B2(chan)], y3);
	b(chan, :) = y4;
end

if 0
	semilogx((0:(length(x)-1))*(fs/length(x)),20*log10(abs(fft(output))));
end
