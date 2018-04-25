classdef AudioSignal < TimeSignal
    %Audio Signal representation
    properties (GetAccess = public, SetAccess = protected)
        tSupport
        sampRate       %Sample rate of audio file.
        value          %The samples read from the file. If the file comprises many
        % channels, these are the samples from the first channel.
        len             %The number of samples read from the file. This will only be
        % equal to the total number of samples in one channel of the
        % audiofile if no sample range was specified.
        sound % reference to its soundfile object
    end
    properties (Access = public)
        descrs % structure containing possible descriptors of this representation (Sound)
    end
    methods (Access = public)
        function audioSignal = AudioSignal(sound, varargin)
            % INPUTS:
            % =======
            % A string specifying a path to the soundfile
            %
            % and (optionally)
            %
            % A configuration structure containing the fields
            % sampRange         - an array of two elements. The first is the
            %                     index at which to start reading (indexed starting at 1)
            %                     and the second is the index at which to stop reading. The
            %                     samples indices are given as if the file only contained
            %                     one channel. For example, if the file has a sampling rate
            %                     of 48000 Hz and contains 2 channels and you would like to
            %                     have the sound from 1 second in for a duration of 1
            %                     second, you would set this field to the array [1*48000
            %                     2*48000]. If it is not specified, all of the first channel
            %                     of the audio file is read.
            % fileFormat        - (.raw file only) specifies the datatype of one sample.
            %                     This can be any datatype supported by fread.
            % nChannels         - (.raw file only) specifies the number of channels.
            % sampRate          - (.raw file only) Sample rate of audio file.
            %
            % It will also contain all of the fields in the configuration structure (if they
            % weren't specified, they were given a default value) except for: fileFormat,
            % nChannels and sampRange.
            %
            % Copyright (c) 2011 IRCAM/ McGill, All Rights Reserved.
            % Permission is only granted to use for research purposes
            %
            % === Evaluate input args
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
                    % Only keep the first channel
                    signal = signal(:,1);
                    audioSignal.value((rangeStarts(i) - audioSignal.sound.info.SampleRange(1) + 1):min(rangeStarts(i) + chunkSize - audioSignal.sound.info.SampleRange(1), end)) = signal;
                end
                if length(rangeStarts) > 1
                    close(wtbar);
                end
            end
            audioSignal.len = length(audioSignal.value);
            audioSignal.tSupport = (0:(audioSignal.len-1))/audioSignal.sampRate;
        end
        
        function sameConfig = HasSameConfig(as, config)
            sameConfig = true;
        end
    end
end