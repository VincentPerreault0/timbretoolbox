classdef FrameErg < TVDescr
    %FRAMEERG Class for the frame energy descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Constant)
        yLabel = 'Frame Energy';
        % y-Label of the descriptor when it is plotted.
        repType = 'GenTimeFreqDistr';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function frameErg = FrameErg(gtfDistr, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            %   Additionally, for Harmonic representations, the HarmErg,
            %   NoiseErg and Noisiness descriptors are also evaluated and
            %   created.
            
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
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
end