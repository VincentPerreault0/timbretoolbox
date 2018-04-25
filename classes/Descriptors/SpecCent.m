classdef SpecCent < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Spectral Centroid (Hz)';
        repType = 'GenTimeFreqDistr';
        descrFamilyLeader = '';
    end
    
    methods
        function specCent = SpecCent(gtfDistr, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            specCent = specCent@TVDescr(gtfDistr);
            
            specCent.tSupport = gtfDistr.tSupport;
            
            if ~isa(gtfDistr, 'Harmonic')
                distrProb = gtfDistr.value ./ repmat(sum(gtfDistr.value, 1)+eps, gtfDistr.fSize, 1); % === normalize distribution in Y dim
                
                % Compute the variable of integration
                fSupportDistr = repmat(gtfDistr.fSupport, 1, gtfDistr.tSize);
                % Spectral centroid (mean)
                specCent.value = sum(fSupportDistr .* distrProb);
                % Centre variable of integration around the mean
                zeroMeanFSupportDistr = fSupportDistr - repmat(specCent.value, gtfDistr.fSize, 1);
                % Spectral spread (variance)
                specSpread = sum(zeroMeanFSupportDistr.^2 .* distrProb) .^ (1/2);
                % Spectral skewness (skewness)
                specSkew = sum(zeroMeanFSupportDistr.^3 .* distrProb) ./ (specSpread .^ 3);
                % Spectral kurtosis (kurtosis)
                specKurt = sum(zeroMeanFSupportDistr.^4 .* distrProb) ./ (specSpread .^ 4);
            else
                % === Harmonic centroid
                partialProb = gtfDistr.partialAmps ./ repmat(sum(gtfDistr.partialAmps, 1)+eps, gtfDistr.nHarms,1);	% === divide by zero
                specCent.value = sum(gtfDistr.partialFreqs .* partialProb, 1);
                % === Harmonic variable of integration (of mean=0)
                zeroMeanPartialFreqs = gtfDistr.partialFreqs - repmat(specCent.value, gtfDistr.nHarms, 1);
                % === Harmonic spread
                specSpread = sqrt(sum(zeroMeanPartialFreqs.^2 .* partialProb, 1));
                % === Harmonic skew
                specSkew = sum( zeroMeanPartialFreqs.^3 .* partialProb, 1 ) ./ (specSpread).^3;
                % === Harmonic kurtosis
                specKurt = sum( zeroMeanPartialFreqs.^4 .* partialProb, 1 ) ./ (specSpread).^4;
            end
            gtfDistr.descrs.SpecSpread = SpecSpread(gtfDistr, specCent.tSupport, specSpread);
            gtfDistr.descrs.SpecSkew = SpecSkew(gtfDistr, specCent.tSupport, specSkew);
            gtfDistr.descrs.SpecKurt = SpecKurt(gtfDistr, specCent.tSupport, specKurt);
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = true;
        end
    end
    
end

