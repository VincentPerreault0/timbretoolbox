function Save(sound, varargin)
%SAVE Saves to .mat the whole SoundFile object.
%   A directory must be provided under the field 'Directory'. It will be
%   the directory in which the sound will be saved as a matlab-loadable
%   .mat file.

if isempty(varargin)
    config = struct();
else
    config = varargin{1};
end

directory = GetConfigSaveParams(config);

wtbar = waitbar(0, 'Checking size...', 'Name', ['Saving SoundFile object as .mat for sound ' [sound.fileName sound.fileType]]);
sizeLimit = 2e9; % Matlab save function has a 2Gb size limit
size = sound.GetSize();
size = size/1.10; % TTObject.GetSize() seems to overestimate the size by ~12
% (divided by 110% so as not to underestimate...)
waitbar(.5, wtbar, 'Saving...');
if size < sizeLimit
    matfileName = NewSaveFileName(directory, sound.fileName);
    save([directory '/' matfileName '.mat'], 'sound');
else
    warning(['SoundFile object for sound ' sound.fileName sound.fileType ' is too big to be saved in .mat format. Try exporting it to CSV (although with less precision).']);
end
close(wtbar);

end

function directory = GetConfigSaveParams(config)
%GETCONFIGSAVEPARAMS Gets the specified saving parameter.
%   A directory is retrieved under the field 'Directory'. It will be
%   the directory in which the sound will be saved as a matlab-loadable
%   .mat file.

if isfield(config, 'Directory')
    if ~isdir(config.Directory)
        error('Config.Directory must be a valid directory.');
    end
    directory = config.Directory;
else
    directory = pwd();
end

end

function matfileName = NewSaveFileName(directory, matfileName)
%NEWSAVEFILENAME Finds a new .mat file name to save the SoundFile to.
%   In the directory provided under the field 'Directory', it finds the
%   greatest current numbered file with the desired matfileName and gives
%   out the next numbered plot file name.

filelist = dir(directory);
count = 0;
for k = 1:length(filelist)
    [~,fileName,~] = fileparts(filelist(k).name);
    if strcmp(matfileName, fileName)
        count = count + 1;
        if count == 1
            matfileName = [matfileName '_' num2str(count)];
        else
            if count <= 10
                matfileName = [matfileName(1:end-1) num2str(count)];
            elseif count <= 100
                matfileName = [matfileName(1:end-2) num2str(count)];
            elseif count <= 1000
                matfileName = [matfileName(1:end-3) num2str(count)];
            elseif count <= 10000
                matfileName = [matfileName(1:end-4) num2str(count)];
            else
                error('Too many csv files with the same name (10000).');
            end
        end
    end
end

end
