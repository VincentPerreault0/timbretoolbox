function y=outmidear(x,sr)
% y=outmidear(x,sr) - outer/middle ear filter
% 
% x: sound pressure at ear (?) (column vector or matrix)
% 
% y: effective signal at entrance of cochlear filter bank
% sr: Hz - sampling rate
%
% Filters waveform to simulate the loss of sensitivity at low (<1kHz)
% and high (>10kHz) frequencies due to outer and middle ear transmission
% characteristics (and likely other causes).  Despite its name, the
% aim of this function is not to accurately model acoustical properties
% of the outer and middle ear.

% Magnitude transfer function is deduced from behavioral measures of 
% minimum audible field.  It is implemented as a cascade of an IIR 
% high-pass filter (two cascaded 2nd order filters) to account for the
% sharp loss of sensitivity at low frequencies, and an FIR 
% equalizer to account for the peak of sensitivity around 2 kHz and 
% the loss of sensitivity near 16 kHz.  No concern for phase.

if nargin<2; help outmidear; return; end
[m,n]=size(x);
if m==1; x=x'; end

% Derive transfer function from behavioral measures of minimum audible field:
dataset = 'killion';			% 'killion' or 'moore'
[maf,f]=ERB.isomaf([], dataset);	% minimum audible field sampled at f
g = ERB.isomaf(1000)-maf;			% gain re: 1kHz
g = 10 .^ (g/20);				% dB to lin
f=[0, f, 20000];				% add 0 and 20 kHz points
g = [eps, g, g(end)];			% give them zero amplitude
if (sr/2>20000) 
	f=[f, sr/2];				% extend to sr/2		
	g = [g, g(end)];
end
%plot(f,max(-30,20*log10(g)),'r'); pause
%plot(f,g,'r'); pause

% Model low frequency part with 2 cascaded second-order highpass sections:
fc=680; 						% Hz - corner frequency
q=0.65;							% quality factor
pwr=2;							% times to apply same filter
a=sof(fc/sr,q);					% second order low-pass
b=[sum(a)-1, -a(2), -a(3)];		% convert to high-pass 
for k=1:pwr
	x=filter(b,a,x);			% apply to signal
end
% These parameters are OK for Killion's dataset (that goes down to 100 Hz).
% For Moore's dataset (that goes down to 20 Hz) a cascade of 3 sections
% with with slightly different fc and q is better.

% Transfer function of filter applied so far:
[gg,ff]=freqz(b,a);				% transfer function applied so far
gg=abs(gg).^pwr; 	
ff=ff*sr/(2*pi);				% 0-pi to 0-sr/2
%plot(ff, gg, 'g'); pause

% Transfer function that remains to apply:
g = interp1(f,g,ff,'lin');		% interpolate maf-derived tf at ff
gain = g ./ (gg+eps); 			% divide by tf of first filter
gain(find(ff<f(2)))=1;			% no data below f(2), ignore
%plot(ff,gain,'r'); pause;

% Synthesize FIR filter
N=50;	% order
b=fir2(N,linspace(0,1,size(gain,1))',gain);
[ggg,fff]=freqz(b,1);
fff=fff*sr/(2*pi);
ggg=20*log10(abs(ggg)); gain=20*log10(gain);
%plot(fff,ggg,'r',fff,gain,'b'); pause
difference=gain-ggg; 
%plot(fff,difference, 'r'); pause
maxdif=max(abs(difference(find(fff<16000))));
%disp(['max error from ', num2str(f(2)), ' to 16000 Hz: ', num2str(maxdif), ' dB']);

% Apply to signal
y=filter(b,1,x);

function a=sof(f,q)
% a=sof(f,q) - second-order lowpass filter
%
% f: normalized resonant frequency (or column vector of frequencies)
% q: quality factor (or column vector of quality factors)
% 
% a: filter coeffs 
%
% based on Malcolm Slaney's auditory toolbox

if nargin < 2; help sof; return; end

[m,n]=size(f);
if n>1; f=f'; if m>1; error('sof: f should be column vector'); end; m=n; end
[mm,nn]=size(q);
if nn>1; f=f'; if mm>1; error('sof: f should be column vector'); end; mm=nn; end
if m ~= mm; error('sof: f and q should have same size'); end
rho = exp(-pi * f./q);
theta = 2*pi*f.*sqrt(1 - 1./(4*q.^2));
a = [ones(size(rho)), -2*rho.*cos(theta), rho.^2 ];
