function [mafs,f] = isomaf(f,dataset)
% [mafs, f] = isomaf(f,dataset)) - Minimum audible field at frequency f
%
% in:
% f: Hz - frequencies at which to interpolate function ([]: use frequencies of dataset)
% dataset: 'moore' or 'killion' (default)
% 
% out:
% mafs: dB SPL - minimum audible field
% f: frequencies at which mafs are given
%
% 2 datasets available: 
% - ISO according to Moore's model, 
% - ISO according to Killion, M.C. (1978), "Revised estimate of minimum audible 
% pressure: Where is the ''missing 6 dB?," J. Acoust. Soc. Am. 63, 1501-1508.

if nargin<1; help isomaf; return; end

if nargin == 1
  dataset = 'killion';
end

if strcmp(dataset, 'moore')
	% Moore
  freqs = [0, 20.,    25.,   31.5,   40.,    50.,    63.,   80.,  100., 125.,...
  160.,  200.,   250.,   315.,   400.,  500.,  630., 800.,  1000., 1250.,  1600., ...
  2000.,  2500., 3150., 4000., 5000.,  6300., 8000., 10000., 12500., 15000.,20000.];

  datamaf = [75.8, 70.1,  60.8,  52.1,   44.2,   37.5,    31.3, 25.6,  20.9, ...
  16.5,  12.6,    9.6,   7.0,    4.7,     3.0,  1.8,   0.8, 0.2,   0.0,  -0.5,...
  -1.6,   -3.2,    -5.4, -7.8,  -8.1, -5.3,  2.4,   11.1,  12.2,    7.4,    17.8, 17.8];

  freqs=freqs(2:end-1);		% why?
  datamaf=datamaf(2:end-1); 
elseif strcmp(dataset,'killion')
  % Killian
  freqs = [100, 150, 200, 300, 400, 500, 700, 1000, 1500, 2000, 2500, 3000,  3500, ...
  4000, 4500, 5000, 6000, 7000, 8000, 9000, 10000];

  datamaf = [33, 24, 18.5, 12, 8, 6, 4.7, 4.2, 3, 1, -1.2, -2.9, -3.9, -3.9, ...
  -3, -1, 4.6, 10.9, 15.3, 17, 16.4];
 else
	error (['unexpected data set: ', dataset]);

end    

if isempty(f)
	f=freqs;
	mafs=datamaf;
else
	[mafs] = interp1(freqs,datamaf,f,'pchip');
end


% for out of range queries use closest sample
mafs(f<min(freqs)) = datamaf(1); 
mafs(f>max(freqs)) = datamaf(end);
    
