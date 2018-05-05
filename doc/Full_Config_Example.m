%%% =================== FULL CONFIGURATION EXAMPLE =======================
%%%
%%% Specify the desired directories below and, if only a single sound must
%%% be processed, its filename. If you wish to process all sounds in the
%%% specified sounds directory, leave the fileName variable empty (i.e. =
%%% '').
%%% 
%%% Specify (if necessary) parameters for the processing of the SoundFiles
%%% by uncommenting the necessary lines specifying the fields in the
%%% sndConfig structure (and changing their values: the current ones are
%%% the default values and thus need not be specified).
%%% 
%%% Configure which representation and their descriptors must be evaluated
%%% (and saved/exported/plotted) by uncommenting the necessary lines
%%% specifying the fields in the evalConfig structure. If no descriptor or
%%% representation are specified, all will be evaluated. Again, all
%%% parameters currently specified have the default values and thus need
%%% not be specified. To see what the parameters mean and what possible
%%% valueas they may take, look inside their classdef file in the classes
%%% folder (e.g. SoundFile.m for SoundFile objects, AudioSignal.m for
%%% AudioSignal Representation objects, etc.).
%%% 
%%% Currently, all evaluated representations/descriptors will be exported
%%% to .csv (Excel readable files), saved to .mat (Matlab readable files
%%% with more precision) or have their plots (grouped by representation)
%%% saved to .png in the specified directories (unless the directories are
%%% left empty, i.e. are = '').
%%% 
%%% Currently, the representations and descriptors will be exported to .csv
%%% grouped by sound file and as statistics ('stats', such as minimum,
%%% maximum, median and interquartile range) and as time series ('ts')
%%% with a time resolution of 10 Hz. They can also be grouped by
%%% descriptor, be saved as only 'stats' or 'ts' and have any positive time
%%% resolution (warning: bigger time resolutions means bigger .csv files).
%%% These parameters can be changed below in the csvConfig structure.
%%% 
%%% Currently, all representations and descriptors will be plotted in their
%%% full time resolution, but they can also be plotted in any specified
%%% time resolution by changing the timeRes parameter of the plotConfig
%%% structure from 0 (default) to the desired time resolution (in Hz).
%%% 
%%% If you wish to export to .csv or to save plots in .png only specific
%%% evaluated representations/descriptors, you can specify them
%%% respectively in the csvConfig structure and the plotConfig structure in
%%% the same manner as in the evalConfig
%%% 
%%% An example of a custom plot figure is shown commented at the bottom of
%%% this code.
%%% 
%%% For longer sound files (more than several minutes), matlab might not
%%% have enough memory to store all representations and their descriptors
%%% in the SoundFile object. In that case, you can simply evaluate the
%%% representations (and their descriptors) one at a time.
%%% 
%%% Feel free to copy this full configuration code example and delete
%%% all unnecessary lines. Simply make sure to add the timbretoolbox and
%%% its subfolders to the matlab path.

close all
clear variables
clc

soundsDirectory = './doc/sounds';
singleFileName = '';

csvDirectory = '../CSV Files';
matDirectory = '../Mat Files';
pltDirectory = '../Plot Images';

sndConfig = struct();
% sndConfig.SampRange = [1 inf];
% sndConfig.ChunkSize = 30*44100;
% sndConfig.FileFormat = 'double';    % needed for .raw files only (e.g. 'example.raw')
% sndConfig.NumChannels = 1;          % needed for .raw files only (e.g. 'example.raw')
% sndConfig.SampleRate = 48000;       % needed for .raw files only (e.g. 'example.raw')

evalConfig = struct();

%%% Whether or not the evalConfig.AudioSignal structure exists, the Audio
%%% Signal representation will be evaluated/plotted.

%%% If no descriptors are specified in the evalConfig.AudioSignal
%%% structure, all audio signal descriptors will be evaluated, unless
%%% NoDescr is specified in which case no AudioSignal descriptors will be
%%% evaluated.

% evalConfig.AudioSignal.NoDescr = struct();      % Overwrites any specified descriptor

% evalConfig.AudioSignal.AutoCorr = struct();     % Specified to be evaluated
% evalConfig.AudioSignal.AutoCorr.NCoeffs = 12;
% evalConfig.AudioSignal.AutoCorr.HopSize_sec = 0.0029;
% evalConfig.AudioSignal.AutoCorr.HopSize = 128;  % Overwrites HopSize_sec parameter
% evalConfig.AudioSignal.AutoCorr.WinSize_sec = 0.0232;
% evalConfig.AudioSignal.AutoCorr.WinSize = 1023; % Overwrites WinSize_sec parameter

% evalConfig.AudioSignal.ZcrRate = struct();      % Specified to be evaluated
% evalConfig.AudioSignal.ZcrRate.HopSize_sec = 0.0029;
% evalConfig.AudioSignal.ZcrRate.HopSize = 128;   % Overwrites HopSize_sec parameter
% evalConfig.AudioSignal.ZcrRate.WinSize_sec = 0.0232;
% evalConfig.AudioSignal.ZcrRate.WinSize = 1023;  % Overwrites WinSize_sec parameter


%%% If the evalConfig.TEE structure doesn't exist, the TEE representation (and
%%% its descriptors) will not be evaluated/plotted.

% evalConfig.TEE = struct();              % Specified to be evaluated/plotted
% evalConfig.TEE.CutoffFreq = 5;

%%% If no descriptors are specified in the evalConfig.TEE structure, all TEE
%%% descriptors will be evaluated, unless NoDescr is specified in which
%%% case no TEE descriptors will be evaluated.

% evalConfig.TEE.NoDescr = struct();      % Overwrites any specified descriptor

% evalConfig.TEE.Att = struct();          % Specified to be evaluated/plotted
% evalConfig.TEE.Att.Method = 3;
% evalConfig.TEE.Att.NoiseThresh = 0.15;
% evalConfig.TEE.Att.DecrThresh = 0.4;
%%% evalConfig.TEE.Att's parameters are shared with evalConfig.TEE.Dec,
%%% evalConfig.TEE.Rel, evalConfig.TEE.LAT, evalConfig.TEE.AttSlope and
%%% evalConfig.TEE.DecSlope.

% evalConfig.TEE.TempCent = struct();     % Specified to be evaluated/plotted
% evalConfig.TEE.TempCent.Threshold = 0.15;

% evalConfig.TEE.EffDur = struct();       % Specified to be evaluated/plotted
% evalConfig.TEE.EffDur.Threshold = 0.4;

% evalConfig.TEE.FreqMod = struct();      % Specified to be evaluated/plotted
% evalConfig.TEE.FreqMod.Method = 'fft';
%%% evalConfig.TEE.FreqMod's parameters are shared with evalConfig.TEE.AmpMod. It
%%% should also be noted that FreqMod and AmpMod need Dec and Rel to be
%%% evaluated. If they are not specified, they will be evaluated with
%%% default parameter values.

% evalConfig.TEE.RMSEnv = struct();       % Specified to be evaluated/plotted
% evalConfig.TEE.RMSEnv.HopSize_sec = 0.0029;
% evalConfig.TEE.RMSEnv.HopSize = 128;    % Overwrites HopSize_sec parameter
% evalConfig.TEE.RMSEnv.WinSize_sec = 0.0232;
% evalConfig.TEE.RMSEnv.WinSize = 1023;   % Overwrites WinSize_sec parameter


%%% If the evalConfig.STFT structure doesn't exist, the STFT representation
%%% (and its descriptors) will not be evaluated/plotted.

% evalConfig.STFT = struct();             % Specified to be evaluated/plotted
% evalConfig.STFT.DistrType = 'pow';
% evalConfig.STFT.HopSize_sec = 0.0058;
% evalConfig.STFT.HopSize = 256;          % Overwrites HopSize_sec parameter
% evalConfig.STFT.WinSize_sec = 0.0232;
% evalConfig.STFT.WinSize = 1023;         % Overwrites WinSize_sec parameter
% evalConfig.STFT.WinType = 'hamming';
% evalConfig.STFT.Win = hamming(1023);    % Overwrites WinType and WinSize
% evalConfig.STFT.FFTSize = 1024;

%%% If no descriptors are specified in the evalConfig.STFT structure, all STFT
%%% descriptors will be evaluated, unless NoDescr is specified in which
%%% case no STFT descriptors will be evaluated.

% evalConfig.STFT.NoDescr = struct();     % Overwrites any specified descriptor

% evalConfig.STFT.SpecCent = struct();    % Specified to be evaluated/plotted
%%% evalConfig.STFT.SpecCent's parameters are shared with
%%% evalConfig.STFT.SpecSpread, evalConfig.STFT.SpecSkew and evalConfig.STFT.SpecKurt.

% evalConfig.STFT.SpecSlope = struct();   % Specified to be evaluated/plotted

% evalConfig.STFT.SpecDecr = struct();    % Specified to be evaluated/plotted

% evalConfig.STFT.SpecRollOff = struct(); % Specified to be evaluated/plotted
% evalConfig.STFT.SpecRollOff.Threshold = 0.95;

% evalConfig.STFT.SpecVar = struct();     % Specified to be evaluated/plotted

% evalConfig.STFT.FrameErg = struct();    % Specified to be evaluated/plotted

% evalConfig.STFT.SpecFlat = struct();    % Specified to be evaluated/plotted

% evalConfig.STFT.SpecCrest = struct();   % Specified to be evaluated/plotted


%%% If the evalConfig.ERB structure doesn't exist, the ERB representation (and
%%% its descriptors) will not be evaluated/plotted.

% evalConfig.ERB = struct();              % Specified to be evaluated/plotted
% evalConfig.ERB.HopSize_sec = 0.0058;
% evalConfig.ERB.HopSize = 256;           % Overwrites HopSize_sec parameter
% evalConfig.ERB.Method = 'fft';
% evalConfig.ERB.Exponent = 1/4;

%%% If no descriptors are specified in the evalConfig.ERB structure, all ERB
%%% descriptors will be evaluated, unless NoDescr is specified in which
%%% case no ERB descriptors will be evaluated.

% evalConfig.ERB.NoDescr = struct();      % Overwrites any specified descriptor

% evalConfig.ERB.SpecCent = struct();     % Specified to be evaluated/plotted
%%% evalConfig.ERB.SpecCent's parameters are shared with evalConfig.ERB.SpecSpread,
%%% evalConfig.ERB.SpecSkew and evalConfig.ERB.SpecKurt.

% evalConfig.ERB.SpecSlope = struct();    % Specified to be evaluated/plotted

% evalConfig.ERB.SpecDecr = struct();     % Specified to be evaluated/plotted

% evalConfig.ERB.SpecRollOff = struct();  % Specified to be evaluated/plotted
% evalConfig.ERB.SpecRollOff.Threshold = 0.95;

% evalConfig.ERB.SpecVar = struct();      % Specified to be evaluated/plotted

% evalConfig.ERB.FrameErg = struct();     % Specified to be evaluated/plotted

% evalConfig.ERB.SpecFlat = struct();     % Specified to be evaluated/plotted

% evalConfig.ERB.SpecCrest = struct();    % Specified to be evaluated/plotted


%%% If the evalConfig.Harmonic structure doesn't exist, the Harmonic
%%% representation (and its descriptors) will not be evaluated/plotted.

% evalConfig.Harmonic = struct();             % Specified to be evaluated/plotted
% evalConfig.Harmonic.Threshold = 0.3;
% evalConfig.Harmonic.NHarms = 20;
% evalConfig.Harmonic.HopSize_sec = 0.025;
% evalConfig.Harmonic.HopSize = 1103;         % Overwrites HopSize_sec parameter
% evalConfig.Harmonic.WinSize_sec = 0.1;
% evalConfig.Harmonic.WinSize = 4410;         % Overwrites WinSize_sec parameter
% evalConfig.Harmonic.WinType = 'blackman';
% evalConfig.Harmonic.Win = blackman(4410);   % Overwrites WinType and WinSize
% evalConfig.Harmonic.FFTSize = 32768;

%%% If no descriptors are specified in the evalConfig.Harmonic structure, all
%%% Harmonic descriptors will be evaluated, unless NoDescr is specified in
%%% which case no Harmonic descriptors will be evaluated.

% evalConfig.Harmonic.NoDescr = struct();     % Overwrites any specified descriptor

% evalConfig.Harmonic.SpecCent = struct();    % Specified to be evaluated/plotted
%%% evalConfig.Harmonic.SpecCent's parameters are shared with
%%% evalConfig.Harmonic.SpecSpread, evalConfig.Harmonic.SpecSkew and
%%% evalConfig.Harmonic.SpecKurt.

% evalConfig.Harmonic.SpecSlope = struct();   % Specified to be evaluated/plotted

% evalConfig.Harmonic.SpecDecr = struct();    % Specified to be evaluated/plotted

% evalConfig.Harmonic.SpecRollOff = struct(); % Specified to be evaluated/plotted
% evalConfig.Harmonic.SpecRollOff.Threshold = 0.95;

% evalConfig.Harmonic.SpecVar = struct();     % Specified to be evaluated/plotted

% evalConfig.Harmonic.FrameErg = struct();    % Specified to be evaluated/plotted
%%% evalConfig.Harmonic.FrameErg's parameters are shared with
%%% evalConfig.Harmonic.HarmErg, evalConfig.Harmonic.NoiseErg and
%%% evalConfig.Harmonic.Noisiness.

% evalConfig.Harmonic.SpecFlat = struct();    % Specified to be evaluated/plotted

% evalConfig.Harmonic.SpecCrest = struct();   % Specified to be evaluated/plotted

% evalConfig.Harmonic.F0 = struct();          % Specified to be evaluated/plotted

% evalConfig.Harmonic.InHarm = struct();      % Specified to be evaluated/plotted

% evalConfig.Harmonic.TriStim = struct();     % Specified to be evaluated/plotted

% evalConfig.Harmonic.HarmDev = struct();     % Specified to be evaluated/plotted

% evalConfig.Harmonic.OddEvenRatio = struct();% Specified to be evaluated/plotted

csvConfig = struct();
csvConfig.Directory = csvDirectory;
csvConfig.TimeRes = 10;
csvConfig.Grouping = 'sound';               % group by descriptor: replace with 'descr'
% csvConfig.ValueTypes = {'stats', 'ts'};     % only statistics: replace with 'stats'
%%%                                           % only time series: replace with 'ts'
matConfig = struct();
matConfig.Directory = matDirectory;

plotConfig = struct(); 
plotConfig.Directory = pltDirectory;
plotConfig.TimeRes = 0;

if ~isdir(soundsDirectory)
    error('soundsDirectory must be a valid directory.');
end
if ~isempty(singleFileName)
    filelist.name = singleFileName;
else
    filelist = dir(soundsDirectory);
end
acceptedFormats = {'wav', 'ogg', 'flac', 'au', 'aiff', 'aif', 'aifc', 'mp3', 'm4a', 'mp4'};
for i = 1:length(filelist)
    [~, fileName, fileExt] = fileparts(filelist(i).name);
    if ~isempty(fileName) && fileName(1) ~= '.' && (any(strcmp(fileExt(2:end), acceptedFormats)) || (length(filelist) == 1 && strcmp(fileExt(2:end), 'raw')))
        sound = SoundFile([soundsDirectory '/' fileName fileExt], sndConfig);
        sound.Eval(evalConfig);
        if ~isempty(csvDirectory)
            sound.ExportCSV(csvConfig);
        end
        if ~isempty(matDirectory)
            sound.Save(matConfig);
        end
        if ~isempty(pltDirectory)
            sound.Plot(plotConfig);
            close all;
            clc
        end
        clear 'sound';
    end
end


%%% CUSTOM PLOT EXAMPLE
% 
% sound = SoundFile([soundsDirectory '/' singleFileName], sndConfig);
% 
% evalConfig = struct();
% evalConfig.AudioSignal.AutoCorr = struct();
% evalConfig.TEE.NoDescr = struct();
% evalConfig.STFT.NoDescr = struct();
% evalConfig.ERB.NoDescr = struct();
% evalConfig.Harmonic.NoDescr = struct();
% sound.Eval(evalConfig);
% 
% fig = figure();
% ax = {subplot(3,2,1),subplot(3,2,2),subplot(3,2,3),subplot(3,2,4),subplot(3,2,5),subplot(3,2,6)};
% 
% plotConfig = struct();
% plotConfig.AudioSignal.Axes = ax{1};
% plotConfig.AudioSignal.AutoCorr.Axes = ax{3};
% plotConfig.TEE.Axes = ax{5};
% plotConfig.STFT.Axes = ax{2};
% plotConfig.ERB.Axes = ax{4};
% plotConfig.Harmonic.Axes = ax{6};
% sound.Plot(plotConfig);
% 
% saveas(fig,[pltDirectory '/' 'CustomPlotExample.png']);