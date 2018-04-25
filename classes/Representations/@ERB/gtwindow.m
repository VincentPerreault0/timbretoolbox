function y=gtwindow(n,b,order)
% y=gtwindow(n,b,order) - window shaped like a time-reversed gammatone envelope 
%
% y: output
% n: number of points
% b: b-parameter (default = 2)
% order: order of function (default = 4)
%
% The window shape is defined by b^order * t^(order-1) * exp(-2*pi*b*t) with t=(0:n-1)/n,
% scaled so that its max is 1

if nargin < 1; help gtwindow; return; end
if nargin < 2; b = 2; end
if nargin < 3; order = 4; end

t = (0:n-1)'/n;
y = b^order * t.^(order-1) .* exp(-2*pi*b*t);
y = flipud(y);
y = y/max(y);

% test
if (0) 
	% calculate equivalent rectangular duration (width of squared window divided
	% by its maximum, in samples
	y = sum(y.^2)/max(y.^2);
end
 
