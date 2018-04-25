function f=ERBtohz(e,formula)
% f=ERBtohz(e,formula) - convert frequency from ERB to Hz scale 
% 
% f: Hz - frequency
%
% e: ERB rate
% formula: 'glasberg90' [default] or 'moore83'
%
% see also ERBfromhz, ERBspace

if nargin<2; formula='glasberg90'; end

switch formula
case 'glasberg90'
	f = (exp(e/9.26)-1)/0.00437;

case 'moore83'
	% from John Cullings 'signal' (IWAVE) code:
	erb_k1 = 11.17;
	erb_k2 = 0.312;
	erb_k3 = 14.675;
	erb_k4 = 43;
	tmp = exp((e-erb_k4)/erb_k1);
	f = (erb_k2 - erb_k3*tmp) ./ (tmp - 1.0);
	f = f * 1000;
otherwise
	error('ERBtohz: unexpected formula');
end
