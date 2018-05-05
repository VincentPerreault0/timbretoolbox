classdef SoundFile < TTObject
    %SOUNDFILE Container object for the sound file and its representations.
    %   Object that is unique for a sound file and a particular sample
    %   range for that sound. It also contains all its different evaluated
    %   representations which, in turn, also contain all their evaluated
    %   descriptors.
    
    properties (GetAccess = public, SetAccess = private)
        directory   % Directory where the sound file of interest is
                    %	located.
        fileName    % File name of the sound file of interest.
        fileType    % File format of the sound file of interest.
        reps        % Structure containing all the sound file's possible 
                    %   representations. All fields correspond to a
                    %   possible representation type and are instantiated
                    %   with a value of 0 (see SoundFile's getRepTypes()
                    %   method).
        chunkSize = 30*44100  % Chunk size (in samples) for the evaluation of
                            %   its representations. If negative or equal
                            %   to 0, the evaluations will be done in a
                            %   single chunk.
    end
    properties
        info = struct() % Structure containing information on the sound
                        %   file, such as (at least) :
                        %   - TotalSamples : Total number of samples in
                        %       the file.
                        %   - SampleRate : Sample rate of the sound file.
                        %   - NumChannels : Number of channels (mono : 1,
                        %       stereo : 2).
                        %   - BitsPerSample : Number of bits per sample
                        %       in the sound file.
                        %   - SampleRange : Desired range (in samples) of
                        %       the sound file to be analyzed, of the form
                        %       [startsample, endsample].
    end
    
    methods
        function sound = SoundFile(filename, varargin)
            %CONSTRUCTOR From a file name, instantiates a SoundFile object.
            %   An additional configuration structure can be passed as an
            %   argument to specify required parameters for sound file
            %   formats .raw (FileFormat, NumChannels and SampleRate) or to
            %   specify additional SoundFile parameters such as a custom
            %   chunk size or a custom sample range.
            sound.getRepTypes();
            
            if nargin > 1
                config = varargin{1};
            else
                config = struct();
            end
            
            fileInfo = dir(filename);
            if length(fileInfo) ~= 1
                error('Sound filename should be a valid file address.');
            end;
            
            [sound.directory, sound.fileName, sound.fileType] = fileparts(filename);
            
            if ~any(strcmp(sound.fileType(2:end), {'wav', 'ogg', 'flac', 'au', 'aiff', 'aif', 'aifc', 'mp3', 'm4a', 'mp4', 'raw'}))
                error('Sound file format should be a valid sound file format.');
            end
            
            if ~strcmp(sound.fileType, '.raw')
                sound.info = audioinfo([sound.directory '/' sound.fileName sound.fileType]);
            else
                if nargin < 2 || ~isfield(config,'FileFormat') || ~isfield(config,'NumChannels') ...
                        || ~isfield(config,'SampleRate')
                    error('For files of type .raw, must be specified the FileFormat (e.g. ''double''), NumChannels (number of channels) and SampleRate.');
                end
                if ~exist(config.FileFormat, 'class') || ~isa(eval([config.FileFormat '(0)']), 'numeric')
                    error('Config.FileFormat must be the name (stored as a char) of a numeric class (e.g. ''double'').');
                end
                if ~isa(config.NumChannels, 'double') || config.NumChannels < 1 || config.NumChannels ~= round(config.NumChannels)
                    error('Config.NumChannels must be the number of channels (double >= 1 and an integer).');
                end
                if ~isa(config.SampleRate, 'double') || config.SampleRate <= 0
                    error('Config.SampleRate must be the sample rate in samples/second (double > 0).');
                end
                sound.info.TotalSamples = 0;
                sound.info.FileFormat = config.FileFormat;
                x__=eval(sprintf('%s(1)',sound.info.FileFormat));
                s__=whos('x__');
                sound.info.BitsPerSample = s__.bytes*8;
                sound.info.NumChannels = config.NumChannels;
                sound.info.SampleRate = config.SampleRate;
            end
            
            if isfield(config,'SampleRange')
                if ~isa(config.SampleRange, 'double') || length(config.SampleRange)~=2 || config.SampleRange(2) <= config.SampleRange(1) || any(round(config.SampleRange)~=config.SampleRange)
                    error('Config.SampleRange must be a matrix of sample indices like such: [StartSample, EndSample].');
                end
                if config.SampleRange(1) < 1
                    config.SampleRange(1) = 1;
                end
                if sound.info.TotalSamples > 0 && config.SampleRange(2) > sound.info.TotalSamples
                    config.SampleRange(2) = sound.info.TotalSamples;
                end
                sound.info.SampleRange = config.SampleRange;
            else
                sound.info.SampleRange = [1 sound.info.TotalSamples];
            end
            if isfield(config, 'ChunkSize_bytes')
                if ~isa(config.ChunkSize_bytes, 'double') || config.ChunkSize_bytes <= 0
                    error('Config.ChunkSize_bytes must be a positive number (not equal to 0) of bytes to process (approx.) in each chunk.');
                end
                sound.chunkSize = round(config.ChunkSize_bytes / (sound.info.NumChannels * sound.info.BitsPerSample / 8));
            end
            if isfield(config, 'ChunkSize')
                if ~isa(config.ChunkSize, 'double')
                    error('Config.ChunkSize must be a positive number of samples to process (approx.) in each chunk. To compute in a single chunk, ChunkSize should be a negative number or 0.');
                end
                sound.chunkSize = config.ChunkSize;
            end
        end
        
        Eval(sound, varargin)
        
        Plot(sound, varargin)
        
        ExportCSV(sound, varargin)
        
        Save(sound, varargin)
    end
    
    methods (Access = private)
        EvalRep(sound, config)
        
        function getRepTypes(sound)
            %GETREPTYPES Instantiates the sound's reps property.
            %   Finds all possible representations of the sound and adds
            %   them as a field with initial value of 0 to the reps
            %   structure.
            sound.reps = struct();
            
            repsFilepath = mfilename('fullpath');
            repsFilepath = [repsFilepath(1:end-21) '/Representations'];
            filelist = dir(repsFilepath);
            
            for i=1:length(filelist)
                if filelist(i).name(1) ~= '.'
                    if filelist(i).name(1) == '@'
                        filelist(i).name = filelist(i).name(2:end);
                    elseif strcmp(filelist(i).name(end-1:end), '.m')
                        filelist(i).name = filelist(i).name(1:end-2);
                    end
                    if exist(filelist(i).name, 'class') &&...
                            ismember('Rep', superclasses(filelist(i).name))
                        mc = eval(['?' filelist(i).name]);
                        if ~mc.Abstract
                            sound.reps.(filelist(i).name) = 0;
                        end
                    end
                end
            end
        end
    end
    
end

