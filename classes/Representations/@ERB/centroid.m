function [c,s]=centroid(x)
%[c,s]=centroid(x) - centroid and spread
% 
% x: matrix
% c: row vector of column centroids
% s: row vector of column spreads
%
% centroid is weighted average of row index
% spread is weighted RMS deviation of index from centroid

[m,n]	= size(x);
idx		= repmat((1:m)',1,n);		% indices
c		= sum(x .* idx);			% weighted sum
w		= sum(x); 					% total weight
c		= (c+eps)./(w+eps);   		% normalize

if nargout > 1; error('spread needs debugging'); end
s	= sum(x .* (idx-repmat(c,m,1)).^2);		% weighted square deviation
s	= (s+eps)./(w+eps);						% normalize
s	= s.^0.5;		
