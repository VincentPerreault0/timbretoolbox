classdef SpecCent < TVDescr
    %SPECCENT Class for the spectral centroid descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Constant)
        yLabel = 'Spectral Centroid (Hz)';
        % y-Label of the descriptor when it is plotted.
        repType = 'GenTimeFreqDistr';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function specCent = SpecCent(gtfDistr, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            %   Additionally, the SpecSpread, SpecSkew and SpecKurt
            %   descriptors are also evaluated and created.
            
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
                specSkew = sum(zeroMeanFSupportDistr.^3 .* distrProb) ./ (specSpread .^ 3 + eps);
                % Spectral kurtosis (kurtosis)
                specKurt = sum(zeroMeanFSupportDistr.^4 .* distrProb) ./ (specSpread .^ 4 + eps);
            else
                % === Harmonic centroid
                partialProb = gtfDistr.partialAmps ./ repmat(sum(gtfDistr.partialAmps, 1)+eps, gtfDistr.nHarms,1);	% === divide by zero
                specCent.value = sum(gtfDistr.partialFreqs .* partialProb, 1);
                % === Harmonic variable of integration (of mean=0)
                zeroMeanPartialFreqs = gtfDistr.partialFreqs - repmat(specCent.value, gtfDistr.nHarms, 1);
                % === Harmonic spread
                specSpread = sqrt(sum(zeroMeanPartialFreqs.^2 .* partialProb, 1));
                % === Harmonic skew
                specSkew = sum( zeroMeanPartialFreqs.^3 .* partialProb, 1 ) ./ (specSpread.^3 + eps);
                % === Harmonic kurtosis
                specKurt = sum( zeroMeanPartialFreqs.^4 .* partialProb, 1 ) ./ (specSpread.^4 + eps);
            end
            gtfDistr.descrs.SpecSpread = SpecSpread(gtfDistr, specCent.tSupport, specSpread);
            gtfDistr.descrs.SpecSkew = SpecSkew(gtfDistr, specCent.tSupport, specSkew);
            gtfDistr.descrs.SpecKurt = SpecKurt(gtfDistr, specCent.tSupport, specKurt);
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
    
end

