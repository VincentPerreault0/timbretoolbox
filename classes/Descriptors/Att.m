classdef Att < GlobDescr
    %ATT Class for start time of the attack descriptor (as if the sound was
    %a single synthesized note).
    
    properties (GetAccess = public, SetAccess = protected)
        rep         % Representation object of which it is a descriptor.
        tSupport    % Temporal range vector (in seconds), of the form
                    %   [starttime, endtime].
        value       % Value of the descriptor.
        method = 3	% Method for the start/stop times detection method (1 
                    %   for 80% of maximum, 2 for maximum and 3 for
                    %   effort).
        noiseThresh = 0.15  % Noise threshold (over which the wave form is
                            %   considered part of the desired signal).
        decrThresh = 0.4    % Decrease threshold (the noise threshold for
                            %   the release part).
    end
    
    properties (Constant)
        repType = 'TEE';
        % Class of the representation or abstract class of the
        %   representation type of which it can be a descriptor.
        descrFamilyLeader = '';
        % Name of the class of the descriptor that evaluates its value. If
        %   empty, the descriptor evaluates its own value.
        unit = 'sec'
        % Unit of the descriptor.
    end
    
    methods
        function att = Att(tee, varargin)
            %CONSTRUCTOR From the representation, the descriptor is
            %evaluated.
            %   Additionally, the LAT, AttSlope, Dec, Rel and DecSlope
            %   descriptors are also evaluated and created.
            
            att = att@GlobDescr(tee);
            
            if ~isempty(varargin)
                config = varargin{1};
                
                if isfield(config, 'Method')
                    if ~any(config.Method*[1 1 1] == [1 2 3])
                        error('Config.Method must be a valid start/stop times detection method (1 for 80% of maximum, 2 for maximum and 3 for effort).');
                    end
                    att.method = config.Method;
                end
                if isfield(config, 'NoiseThresh')
                    if ~isa(config.NoiseThresh, 'double') || config.NoiseThresh <= 0 || config.NoiseThresh > 1
                        error('Config.NoiseThresh must be a threshold (1 >= double > 0).');
                    end
                    att.noiseThresh = config.NoiseThresh;
                end
                if isfield(config, 'DecrThresh')
                    if ~isa(config.DecrThresh, 'double') || config.DecrThresh <= 0 || config.DecrThresh > 1
                        error('Config.DecrThresh must be a threshold (1 >= double > 0).');
                    end
                    att.decrThresh = config.DecrThresh;
                end
            end
            
            att.tSupport = [tee.tSupport(1) tee.tSupport(end)];
            
            [envMax, envMaxIdx] = max(tee.value);
            normEnergyEnv = tee.value / (envMax - eps); % normalize by maximum value
            
            % ============================================
            % === calcul de l'index du début d'atteinte de chaque niveau
            superlevelSetsDomainStep = 0.1;
            superlevelSetsDomain = superlevelSetsDomainStep:superlevelSetsDomainStep:1;
            superlevelSetsStartIdcs = zeros(1, length(superlevelSetsDomain));
            for i=1:length(superlevelSetsDomain)
                superlevelSetIdcs = find(normEnergyEnv >= superlevelSetsDomain(i));
                superlevelSetsStartIdcs(i) = superlevelSetIdcs(1);
            end
            
            % ==== détection du start (attStart) et du stop (attEnd) de l'attaque ========================
            superThreshSetIdcs 	= find(normEnergyEnv > att.noiseThresh);
            switch att.method
                case 1
                    attStartIdx	= superThreshSetIdcs(1);
                    attEndIdx	= superlevelSetsStartIdcs(0.8/superlevelSetsDomainStep); % === équivalent à 80%
                    
                case 2
                    attStartIdx	= superThreshSetIdcs(1);
                    attEndIdx	= superlevelSetsStartIdcs(1.0/superlevelSetsDomainStep); % === équivalent à 100%
                    
                case 3
                    % === PARAMETRES
                    midSuperlevelSetsDomainStartIdx	= round(0.3/superlevelSetsDomainStep); % === BORNES pour calcul mean
                    midSuperlevelSetsDomainEndIdx	= round(0.6/superlevelSetsDomainStep);
                    
                    multiplier = 3; % === facteur multiplicatif de l'effort
                    
                    lowSuperlevelSetsDomainStartIdx	= round(0.1/superlevelSetsDomainStep); % === BORNES pour correction satt (start attack)
                    lowSuperlevelSetsDomainEndIdx	= round(0.3/superlevelSetsDomainStep);
                    
                    highSuperlevelSetsDomainStartIdx= round(0.5/superlevelSetsDomainStep); % === BORNES pour correction eatt (end attack)
                    highSuperlevelSetsDomainEndIdx	= round(0.9/superlevelSetsDomainStep);
                    
                    superlevelSetsLengths = diff(superlevelSetsStartIdcs); % === dpercent_posn_v = effort
                    midSuperlevelSetsLengthsMean = mean(superlevelSetsLengths(midSuperlevelSetsDomainStartIdx:midSuperlevelSetsDomainEndIdx)); % === M = effort moyen
                    
                    % === 1) START ATTACK
                    % === on DEMARRE juste APRES que l'effort à fournir (écart temporal entre percent) soit trop important
                    tmpIdcs = find(superlevelSetsLengths(lowSuperlevelSetsDomainStartIdx:lowSuperlevelSetsDomainEndIdx) > multiplier*midSuperlevelSetsLengthsMean);
                    if ~isempty(tmpIdcs)
                        superlevelSetsDomainAttStartIdx = tmpIdcs(end)+lowSuperlevelSetsDomainStartIdx;
                    else
                        superlevelSetsDomainAttStartIdx = lowSuperlevelSetsDomainStartIdx;
                    end
                    attStartIdx = superlevelSetsStartIdcs(superlevelSetsDomainAttStartIdx);
                    
                    % === raffinement: on cherche le minimum local
                    delta = round(0.25*(superlevelSetsLengths(superlevelSetsDomainAttStartIdx)));
                    [~, normEnergyEnvAttStartLocalMinRelIdx]= min(normEnergyEnv(max([attStartIdx-delta 1]):min([attStartIdx+delta length(tee.value)])));
                    attStartIdx = normEnergyEnvAttStartLocalMinRelIdx + max([attStartIdx-delta 1]) - 1;
                    
                    % === 2) END ATTACK
                    % === on ARRETE juste AVANT que l'effort à fournir (écart temporal entre niveaux) soit trop important
                    tmpIdcs = find(superlevelSetsLengths(highSuperlevelSetsDomainStartIdx:highSuperlevelSetsDomainEndIdx) > multiplier*midSuperlevelSetsLengthsMean);
                    if ~isempty(tmpIdcs)
                        superlevelSetsDomainAttEndIdx = tmpIdcs(1)+highSuperlevelSetsDomainStartIdx-1;
                    else
                        superlevelSetsDomainAttEndIdx = highSuperlevelSetsDomainEndIdx+1;
                    end
                    attEndIdx = superlevelSetsStartIdcs(superlevelSetsDomainAttEndIdx);
                    % === raffinement: on cherche le maximum local
                    delta	= round(0.25*(superlevelSetsLengths(superlevelSetsDomainAttEndIdx-1)));
                    [~, normEnergyEnvAttEndLocalMaxRelIdx] = max(normEnergyEnv(max([attEndIdx-delta 1]):min([attEndIdx+delta length(tee.value)])));
                    attEndIdx = normEnergyEnvAttEndLocalMaxRelIdx + max([attEndIdx-delta 1]) - 1;
            end
            
            att.value = attStartIdx/tee.sound.info.SampleRate;
            
            % ==============================================
            % === D: Log-Attack-Time
            if (attStartIdx == attEndIdx)
                attStartIdx = attEndIdx - 1;
            end
            
            tee.descrs.LAT = LAT(tee, att.tSupport, log10((attEndIdx - attStartIdx)/tee.sound.info.SampleRate));
            
            % ==============================================
            % === D: croissance temporelle NEW 13/01/2003
            % === moyenne pondérée (gaussienne centrée sur percent=50%) des pentes entre attStart et eattpos_n
            % === iEnvMaxInd, stop_posn
            attStartValue = normEnergyEnv(attStartIdx);
            attEndValue = normEnergyEnv(attEndIdx);
            %
            attValues = attStartValue:0.1:attEndValue;
            attValuesCorrespTimes = zeros(1, length(attValues));
            for i=1:length(attValues)
                tmpIdcs = find(normEnergyEnv(attStartIdx:attEndIdx) >= attValues(i));
                attValuesCorrespTimes(i) = tmpIdcs(1)/tee.sound.info.SampleRate;
            end
            attSlopes = diff(attValues)./diff(attValuesCorrespTimes);
            % === moyenne : f_Incr = mean(pente_v);
            % === moyenne pondérée par une gaussienne (maximum autour de 50%)
            attSlopesCorrespValues = 0.5*(attValues(1:end-1)+attValues(2:end));
            attSlopesWeights = exp( -(attSlopesCorrespValues-0.5).^2 / (0.5)^2);
            
            tee.descrs.AttSlope = AttSlope(tee, att.tSupport, sum(attSlopes.*attSlopesWeights)/sum(attSlopesWeights));
            
            % =======================================================
            % === D: décroissance temporelle
            % === iEnvMaxInd, stop_posn
            envMaxIdx = round(0.5*(envMaxIdx+attEndIdx));% === NEW 13/01/2003 (iEnvMaxInd est trop loin pour estimer MOD)
            
            tee.descrs.Dec = Dec(tee, att.tSupport, envMaxIdx/tee.sound.info.SampleRate);
            
            superThreshSetIdcs = find(normEnergyEnv > att.decrThresh);		% === NEW 13/01/2003 augmentation du seuil
            superThreshSetEndIdx = superThreshSetIdcs(end);
            
            tee.descrs.Rel = Rel(tee, att.tSupport, superThreshSetEndIdx/tee.sound.info.SampleRate);
            
            % === NEW GFP 2007/01/11
            if envMaxIdx == superThreshSetEndIdx
                if superThreshSetEndIdx < length(normEnergyEnv)
                    superThreshSetEndIdx = superThreshSetEndIdx+1;
                elseif envMaxIdx > 1
                    envMaxIdx = envMaxIdx-1;
                end
            end
            
            decrIdcs = (envMaxIdx:superThreshSetEndIdx);
            decrLog1DegPolynomeFit = polyfit(decrIdcs/tee.sound.info.SampleRate, log(normEnergyEnv(decrIdcs)), 1);
            
            tee.descrs.DecSlope = DecSlope(tee, att.tSupport, decrLog1DegPolynomeFit(1));
        end
        
        function sameConfig = HasSameConfig(descr, config)
            %HASSAMECONFIG Checks if the descriptor has the same
            %configuration as the given configuration structure.
            
            sameConfig = false;
            if isfield(config,'Method')
                if descr.method ~= config.Method
                    return;
                end
            else
                if descr.method ~= 3
                    return;
                end
            end
            if isfield(config,'NoiseThresh')
                if descr.noiseThresh ~= config.NoiseThresh
                    return;
                end
            else
                if descr.noiseThresh ~= 0.15
                    return;
                end
            end
            if isfield(config,'DecrThresh')
                if descr.decrThresh ~= config.DecrThresh
                    return;
                end
            else
                if descr.decrThresh ~= 0.4
                    return;
                end
            end
            sameConfig = true;
        end
    end
    
end

