classdef SpecCrest < TVDescr
    %SPECCREST Class for the spectral crest descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (descriptor dimension
                    %   by length(tSupport) matrix).
    end
    
    properties (Constant)
        yLabel = 'Spectral Crest';
        % y-Label of the descriptor when it is plotted.
        repType = 'GenTimeFreqDistr';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function specCrest = SpecCrest(gtfDistr, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            specCrest = specCrest@TVDescr(gtfDistr);
            
            specCrest.tSupport = gtfDistr.tSupport;
            
            if ~isa(gtfDistr, 'Harmonic')
                arithmeticMean = sum(gtfDistr.value) / gtfDistr.fSize;
                specCrest.value = max(gtfDistr.value) ./ (arithmeticMean+eps);
            else
                arithmeticMean = sum(gtfDistr.partialAmps, 1) / gtfDistr.nHarms;
                specCrest.value = max(gtfDistr.partialAmps) ./ (arithmeticMean+eps);
            end
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
    
end