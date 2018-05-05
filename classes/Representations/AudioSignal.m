classdef AudioSignal < TimeSignal
    %AUDIOSIGNAL Class for the Audio Signal representation.
    
    properties (GetAccess = public, SetAccess = protected)
        sound       % SoundFile object of which it is a representation.
        tSupport    % Temporal support line vector that indicates at what 
                    %   times the value columns refer to (in seconds).
        value       % Value of the AudioSignal (line vector of the same 
                    %   length as tSupport) : the samples read from the
                    %   file. If the file comprises many channels, these
                    %   are the samples from the first channel.
        len         % The number of samples read from the file. This will
                    %   only be equal to the total number of samples in one
                    %   channel of the audiofile if no sample range was
                    %   specified.
        sampRate    % Sample rate of the sound file.
        
    end
    properties (Access = public)
        descrs      % Structure containing all the representation's 
                    %   possible descriptors. All fields correspond to a
                    %   possible descriptor type and are instantiated with
                    %   a value of 0 (see Rep's getDescrTypes() method).
    end
    methods (Access = public)
        function audioSignal = AudioSignal(sound, varargin)
            %CONSTRUCTOR From a SoundFile, creates an AudioSignal
            %representation.
            %   Reads the audio signal of the given sound file.

            audioSignal = audioSignal@TimeSignal(sound);
            
            audioSignal.sampRate = audioSignal.sound.info.SampleRate;
            
            if nargin ~= 1 && nargin ~= 2
                error('AudioSignal takes as arguments a SoundFile object and (optionally) a configuration structure.');
            end
            
            % === Read file
            if strcmp(audioSignal.sound.fileType, '.raw')
                f=fopen([sound.directory '/' sound.fileName sound.fileType],'r');
                if audioSignal.sound.info.SampleRange(2) > 0
                    % skip over samples
                    fseek(f,audioSignal.sound.info.BitsPerSample/8*(audioSignal.sound.info.SampRange(1)-1)*audioSignal.sound.info.NumChannels,'bof');
                    % read in samples
                    data=fread(f,(diff(audioSignal.sound.info.SampRange)+1)*audioSignal.sound.info.NumChannels,audioSignal.sound.info.FileFormat);
                else
                    data=fread(f,Inf,audioSignal.sound.info.FileFormat);
                end
                % Only keep the first channel
                data = data(1:audioSignal.sound.info.NumChannels:end);
                audioSignal.value = data';
                fclose(f);
                fileInfo = dir([sound.directory '/' sound.fileName sound.fileType]);
                audioSignal.sound.info.TotalSamples = fileInfo.bytes*8 / (audioSignal.sound.info.NumChannels * audioSignal.sound.info.BitsPerSample);
                if audioSignal.sound.info.SampleRange(2) == 0
                    audioSignal.sound.info.SampleRange(2) = audioSignal.sound.info.TotalSamples;
                end
            else
                if sound.chunkSize > 0
                    chunkSize = sound.chunkSize;
                else
                    chunkSize = audioSignal.sound.info.TotalSamples;
                end
                audioSignal.value = zeros(1, audioSignal.sound.info.SampleRange(2) - audioSignal.sound.info.SampleRange(1) + 1);
                rangeStarts = audioSignal.sound.info.SampleRange(1):chunkSize:audioSignal.sound.info.SampleRange(2);
                if length(rangeStarts) > 1
                    wtbar = waitbar(0, '', 'Name', 'Reading Audio Signal Representation');
                end
                for i = 1:length(rangeStarts)
                    if length(rangeStarts) > 1
                        waitbar((i-1)/length(rangeStarts), wtbar, ['Chunk ' num2str(i) ' of ' num2str(length(rangeStarts))]);
                    end
                    [signal, ~] = audioread([sound.directory '/' sound.fileName sound.fileType], [rangeStarts(i) min(rangeStarts(i) + chunkSize - 1, audioSignal.sound.info.SampleRange(2))]);
                    if numel(signal) > 0
                        % Only keep the first channel
                        signal = signal(:,1);
                        chunkLength = length(signal);
                        expectedLength = min(chunkSize, audioSignal.sound.info.SampleRange(2) - rangeStarts(i) + 1);
                        if chunkLength < expectedLength
                            warning('Received less samples in chunk than expected. Zero-padded for further processing.');
                            signal = [signal;zeros(expectedLength - chunkLength,1)];
                        elseif chunkLength > expectedLength
                            error('Received more samples in chunk than expected.');
                        end
                        audioSignal.value((rangeStarts(i) - audioSignal.sound.info.SampleRange(1) + 1):min(rangeStarts(i) + chunkSize - audioSignal.sound.info.SampleRange(1), end)) = signal;
                    end
                end
                if length(rangeStarts) > 1
                    close(wtbar);
                end
            end
            audioSignal.len = length(audioSignal.value);
            audioSignal.tSupport = (0:(audioSignal.len-1))/audioSignal.sampRate;
        end
        
        function sameConfig = HasSameConfig(as, config)
            %HASSAMECONFIG Checks if the audio signal has the same
            %configuration as the given configuration structure.
            
            sameConfig = true;
        end
    end
end