classdef SpecFlat < TVDescr
    %SPECFLAT Class for the spectral flatness descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Constant)
        yLabel = 'Spectral Flatness';
        % y-Label of the descriptor when it is plotted.
        repType = 'GenTimeFreqDistr';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function specFlat = SpecFlat(gtfDistr, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            specFlat = specFlat@TVDescr(gtfDistr);
            
            specFlat.tSupport = gtfDistr.tSupport;
            
            if ~isa(gtfDistr, 'Harmonic')
                geometricMean = exp( (1/gtfDistr.fSize) * sum(log(gtfDistr.value+eps)) );
                arithmeticMean = sum(gtfDistr.value) ./ gtfDistr.fSize;
            else
                geometricMean = exp((1/gtfDistr.nHarms) * sum(log(gtfDistr.partialAmps+eps), 1));
                arithmeticMean = sum(gtfDistr.partialAmps, 1) / gtfDistr.nHarms;
            end
            specFlat.value = geometricMean ./ (arithmeticMean+eps);
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
    
end