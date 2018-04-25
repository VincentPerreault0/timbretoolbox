function e=ERBfromhz(f, formula)
% e=ERBfromhz(f,formula) - convert frequency from Hz to erb-rate scale 
%
% e: ERB rate
% 
% f: Hz - frequency
% formula: 'glasberg90' [default] or 'moore83'
%
% see ERB, ERBtohz, ERBspace

if nargin<2; formula='glasberg90'; end

switch formula
case 'glasberg90'
	e = 9.26*log(0.00437*f + 1);
	
case 'moore83'
	% from John Cullings 'signal' (IWAVE) code:
	erb_k1 = 11.17;
	erb_k2 = 0.312;
	erb_k3 = 14.675;
	erb_k4 = 43;
	f=f/1000;
	e = erb_k1 * log((f + erb_k2) ./ (f + erb_k3)) + erb_k4;
otherwise
	error('unexpected formula');
end
