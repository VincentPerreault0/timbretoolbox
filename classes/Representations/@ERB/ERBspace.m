function y=ERBspace(lo,hi,N)
% y=ERBspace(lo,hi,N) - values uniformly spaced on  erb-rate scale
%
% lo, hi: Hz - upper and lower limits of vector
% N: number of values to produce
% 
% y: vector of values
%
% This function computes an array of N frequencies uniformly spaced between
% lo and hi on an ERB scale.  N is set to 100 if not specified.
%
% See also ERB, ERBtohz, ERBfromhz, linspace, logspace
% 
% For a definition of ERB, see Moore, B. C. J., and Glasberg, B. R. (1983). 
% "Suggested formulae for calculating auditory-filter bandwidths and 
% excitation patterns," J. Acoust. Soc. Am. 74, 750-753.  


if nargin < 3
    N = 100;
end

% Change the following parameters if you wish to use a different
% ERB scale.  Must change in MakeERBCoeffs too.
EarQ = 9.26449;               %  Glasberg and Moore Parameters
minBW = 24.7;
order = 1;

% All of the following expressions are derived in Apple TR #35, "An
% Efficient Implementation of the Patterson-Holdsworth Cochlear
% Filter Bank."  See pages 33-34.
a = EarQ*minBW;
cf = -a + exp((0:N-1)*(-log(hi + a) + log(lo + a))/(N-1)) * (hi + a);

y = fliplr(cf);
