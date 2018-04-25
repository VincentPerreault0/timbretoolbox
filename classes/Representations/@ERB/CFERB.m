function bw=CFERB(cf)
%bw=ERB(cf) - Cambridge equivalent rectangular bandwidth at cf
%
% cf: Hz - characteristic frequency
% bw: Hz - equivalent rectangular bandwidth at cf

% From Hartmann (1997)
bw = 24.7 * (1 +4.37*cf/1000);


 

