classdef FrameErg < TVDescr
    
    properties (GetAccess = public, SetAccess = protected)
        tSupport    % All Descr classes have a temporal support vector that
        % indicates at what times the data refers to (in
        % samples).
        value
        rep
    end
    
    properties (Constant)
        yLabel = 'Frame Energy';
        repType = 'GenTimeFreqDistr';
        descrFamilyLeader = '';
    end
    
    methods
        function frameErg = FrameErg(gtfDistr, varargin)
            % varargin is an (optional) configuration structure containing
            % the (optional) fields below :
            % 
            % Threshold
            frameErg = frameErg@TVDescr(gtfDistr);
            
            frameErg.tSupport = gtfDistr.tSupport;
            
            if ~isa(gtfDistr, 'Harmonic')
                frameErg.value = sum(gtfDistr.value);
            else
                % === Energy
                frameErg.value = sum(gtfDistr.stft.value, 1);
                % Calculate power from distribution points assuming it is magnitude spectrum
                harmErg	= sum(gtfDistr.partialAmps.^2, 1);
                gtfDistr.descrs.HarmErg = HarmErg(gtfDistr, frameErg.tSupport, harmErg);
                noiseErg = frameErg.value - harmErg;
                gtfDistr.descrs.NoiseErg = NoiseErg(gtfDistr, frameErg.tSupport, noiseErg);
                % === Noisiness
                noisiness = noiseErg ./ (frameErg.value + eps);
                gtfDistr.descrs.Noisiness = Noisiness(gtfDistr, frameErg.tSupport, noisiness);
            end
        end
        
        function sameConfig = HasSameConfig(descr, config)
            sameConfig = true;
        end
    end
end