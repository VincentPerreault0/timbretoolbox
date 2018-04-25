function b=fbankpwrsmooth(a,sr,cfarray)
%B=FBANKPWRSMOOTH(A,SR,cfarray) - temporally smoothed power of filterbank output
% 
%  A: input matrix (cf X time)
%  SR: Hz - sampling rate
%  CFARRAY: Hz - array of center frequencies
%

if nargin < 1 | isempty(a),			error('no input vector');				end
if nargin < 2 | isempty(sr),		error('need to specify sampling rate'); end
if nargin < 3 | isempty(cfarray),	error('need to specify frequencies');	end
[nchans,m] = size(cfarray);
if m>1; cfarray = cfarray'; if nchans>1; error('channel array should be 1D'); end; nchans=m; end

% index matrix to apply pi/2 shift at each cf:
shift = round(sr./(4*cfarray));

a = a.^2;  		% power
b = zeros(size(a));
%b=a+shiftmat(a',shift)'; needs too much memory...

for j=1:nchans
% b(j,:)=(a(j,:)+[zeros(1,shift(j)), a(j,shift(j)+1:end)])/2; 
  b(j,:)=(a(j,:)+[ a(j,shift(j)+1:end),zeros(1,shift(j))])/2;	% add to shifted version
end
