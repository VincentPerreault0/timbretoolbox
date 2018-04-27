classdef AutoCorr < TVDescr
    %AUTOCORR Class for the autocorrelation descriptor.
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the descriptor (nCoeffs by length(tSupport) 
                    %   matrix).
        nCoeffs = 12;   % Number of autocorrelation coefficients.
        hopSize     % Hop size of the window (in samples). Determines the 
                    %   time resolution of the descriptor.
        hopSize_sec = 0.0029% Hop size of the window (in seconds). See
                            %   Peeters (2011) for defaults.
        winSize     % Size of the window (in samples).
        winSize_sec = 0.0232% Size of the window (in seconds). See Peeters 
                            %   (2011) for defaults.
    end
    
    properties (Constant)
        yLabel = 'Autocorrelation';
        % y-Label of the descriptor when it is plotted.
        repType = 'AudioSignal';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
    end
    
    methods
        function autoCorr = AutoCorr(as, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            
            autoCorr = autoCorr@TVDescr(as);
            
            if ~isempty(varargin)
                config = varargin{1};
            else
                config = struct();
            end
            if isfield(config, 'NCoeffs')
                if ~isa(config.NCoeffs, 'double') || config.NCoeffs < 1
                    error('Config.NCoeffs must be a number of autocorrelation coefficients (double >= 1).');
                end
                autoCorr.nCoeffs = config.NCoeffs;
            end
            % If hop size in samples specified, calculate the window size in
            % seconds (will overwrite hop size in seconds if also specified).
            if isfield(config,'HopSize')
                config.HopSize_sec = config.HopSize/as.sampRate;
            end
            if isfield(config,'HopSize_sec')
                autoCorr.hopSize_sec = config.HopSize_sec;
            end
            autoCorr.hopSize = round(autoCorr.hopSize_sec * as.sampRate);
            % If window size in samples specified, calculate the window size in
            % seconds (will overwrite window size in seconds if also specified).
            if isfield(config,'WinSize')
                config.WinSize_sec = config.WinSize/as.sampRate;
            end
            if isfield(config,'WinSize_sec')
                autoCorr.winSize_sec = config.WinSize_sec;
            end
            autoCorr.winSize = round(autoCorr.winSize_sec * as.sampRate);
            
            autoCorr.tSupport = 0:autoCorr.hopSize:(autoCorr.hopSize*(floor((as.len - autoCorr.winSize)/autoCorr.hopSize)));
            autoCorr.value = zeros(autoCorr.nCoeffs, length(autoCorr.tSupport));
            
            for i = 1:length(autoCorr.tSupport)
                % Windowed signal starting from time tSupport(i)
                windowedSignal = as.value(autoCorr.tSupport(i) + (1:autoCorr.winSize));
                % Autocorrelation evaluation (eps is to avoid division by zero in
                % coefficient normalization)
                negAndPosLagAutoCorrCoeffs = xcorr(windowedSignal + eps, autoCorr.nCoeffs, 'coeff');
                autoCorr.value(:,i)	= negAndPosLagAutoCorrCoeffs((end - autoCorr.nCoeffs + 1) : end);
            end
            autoCorr.tSupport = (autoCorr.tSupport + ceil(autoCorr.winSize/2))/as.sampRate;
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = false;
            if isfield(config,'NCoeffs')
                if descr.nCoeffs ~= config.NCoeffs
                    return;
                end
            else
                if descr.nCoeffs ~= 12
                    return;
                end
            end
            timeRes = 1/descr.rep.sound.info.SampleRate;
            if isfield(config,'HopSize')
                if abs(descr.hopSize_sec - config.HopSize*timeRes) > timeRes/2
                    return;
                end
            else
                if isfield(config,'HopSize_sec')
                    if abs(descr.hopSize_sec - config.HopSize_sec) > timeRes/2
                        return;
                    end
                else
                    if abs(descr.hopSize_sec - 0.0029) > timeRes/2
                        return;
                    end
                end
            end
            if isfield(config,'WinSize')
                if abs(descr.winSize_sec - config.WinSize*timeRes) > timeRes/2
                    return;
                end
            else
                if isfield(config,'WinSize_sec')
                    if abs(descr.winSize_sec - config.WinSize_sec) > timeRes/2
                        return;
                    end
                else
                    if abs(descr.winSize_sec - 0.0232) > timeRes/2
                        return;
                    end
                end
            end
            sameConfig = true;
        end
    end
    
end

