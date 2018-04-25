%y=rsmooth(x,smooth,npasses,trim) - smooth by running convolution
%
% X: input matrix
% SMOOTH: samples - size of square smoothing window
% NPASSES: number of smoothing passes (default=1)
% TRIM: if true, clip Y to same size as X
% 
% Y: output matrix
%
% RSMOOTH smooths each column of matrix X by convolution with a square window
% followed by division by the window size.
% Multiple passes allow smoothing with a triangular window (npasses=2), or
% window shapes that approach a gaussian (npasses large).  Convolution is
% implemented as a running sum for speed.
% 
% Y has NPASSES*(SMOOTH-1) more rows than X unless TRIM is set.
%
% mex function
