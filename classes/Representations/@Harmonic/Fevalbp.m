% function[y_v] = Fevalbp(bp, x_v)
%
% DESCRIPTION:
% ============
% From a set of time-pitch pairs in bp, estimate pitches at the times in x_v via
% linear interpolation. If x_v contains times greater than or less than all the
% times in bp for which there are pitches, these pitches are set to the last and
% first pitches in bp, respectively. 
%
% INPUTS:
% =======
% bp - A matrix of two columns where the first column is vector of times at
%      which a pitch was estimated and the second column is vector of pitches
%      (corresponding to the times).
% x_v - vector containing the times at which we like to have pitches
%
%
% OUTPUTS:
% ========
% y_v - A vector containing pitches at the times in x_v estimated by linearly
%       interpolating between two (pitch,time) pairs that flank the times. For
%       all values in x_v before (after) the first (last) value in bp, the first
%       (last) pitch value in bp is used for that time. In other words, the
%       extrapolation scheme is to continue the first and last pitches outside
%       the interval for which pitches have been defined.
% 
% Copyright (c) 2010 IRCAM, All Rights Reserved. (peeters@ircam.fr
% Permission is only granted to use for research purposes
%


function[y_v] = Fevalbp(bp, x_v)

if max(max(isnan(bp))), error('bp is Nan'), end
if max(isnan(x_v)), error('bp is Nan'), end

x_v = x_v(:);
% Find all the indices of the times in x_v that are less than the first time in
% bp (times are in the first column)
pos1 = find(x_v < bp(1,1));
% If pos1 is not empty, set these rows (from the indices in pos1) of the first
% column to the value in the 1st row and 2nd column of bp (a pitch in Hz)
if ~isempty(pos1),
    y_v(pos1,1) = bp(1,2);
end
% Find all the indices of the times in x_v that are greater than the last time
% in bp.
pos2 = find(x_v > bp(end,1));
% If pos2 is not empty set these rows (from the indices in pos2) to the value in
% the last row and 2nd column of bp (a pitch in Hz)
if ~isempty(pos2),
    y_v(pos2,1) = bp(end,2);
end

% Find times in x_v that are >= to the first time for which we have a pitch and
% <= to the last time for which we have a pitch.
pos  = find((x_v >= bp(1,1)) & (x_v <= bp(end,1)));

if length(x_v(pos)) > 1,
    % If there are more than one index with the above property (which is probably
    % almost always the case, no?) estimate the pitch at the times in x_v with the
    % above property by interpolating on the (time,pitch) pairs in bp
	y_v(pos,1) = interp1(bp(:,1), bp(:,2), x_v(pos));
else

    % Vector of length equal to the number of times at which we would like to
    % have values
	y_v = zeros(length(x_v), 1);

	for n = 1:length(x_v)
		%fprintf(1,'Fevalbp %d/%d\r', n, length(x_v));

		x = x_v(n);

        % Find the time and index closest to x
		[minimum.value, minimum.pos] = min(abs(bp(:,1) - x));

        % calculate the number of rows in bp
        % (this shouldn't need to be calculated every time)
		L = size(bp, 1);

        % (Shouldn't L be only of 1 dimension?)
		if (bp(minimum.pos,1) == x) | (L(1) == 1) | ...
				((bp(minimum.pos,1) < x) & (minimum.pos==L)) | ...
				((bp(minimum.pos,1) > x) & (minimum.pos==1))
            % If the closest time in bp is exactly equal to x OR
            % if the number of rows in bp is equal to 1 OR
            % if the closest time is less than x and its index is the last one
            % in bp OR
            % if the closest time is greater than x and its index is the first
            % one in bp ...
            % SET y_v AT THIS INDEX n TO THE PITCH AT THE TIME CLOSEST TO x IN
            % bp

			y_v(n) = bp(minimum.pos,2);

		elseif (bp(minimum.pos,1) < x)
            % Otherwise,
            % If the time closest to x is less than x (but is not the last
            % row-value in bp)
            % linearly interpolate between the frequency at the index closest to
            % x and the one afterward to obtain the frequency to put in y_v(n)

			y_v(n) = (bp(minimum.pos+1,2) - bp(minimum.pos,2)) / ...
				(bp(minimum.pos+1,1) - bp(minimum.pos,1)) * ...
				(x - bp(minimum.pos,1)) + ...
				bp(minimum.pos,2);

		elseif (bp(minimum.pos,1) > x)
            % Otherwise,
            % If the time closest to x is greater than x (but is not the first
            % row-value in bp)
            % linearly interpolate between the index one before the index
            % closest to x and the one closest to x to obtain the frequency to
            % put in y_v(n)

			y_v(n) = (bp(minimum.pos,2) - bp(minimum.pos-1,2)) / ...
				(bp(minimum.pos,1) - bp(minimum.pos-1,1)) * ...
				(x - bp(minimum.pos-1,1)) + ...
				bp(minimum.pos-1,2);

		else

			error('not a case')

		end


	end

end


if nargout == 0
	subplot(111)
	plot(bp(:,1), bp(:,2), 'k.-')
	hold on
	plot(x_v, y_v, '*')
	hold off
end




