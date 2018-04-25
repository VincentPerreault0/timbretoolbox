function Save(sound, varargin)

if isempty(varargin)
    config = struct();
else
    config = varargin{1};
end

directory = GetConfigSaveParams(config);

wtbar = waitbar(0, 'Checking size...', 'Name', ['Saving SoundFile object as .mat for sound ' [sound.fileName sound.fileType]]);
sizeLimit = 2e9;
size = sound.GetSize();
size = size/1.10; % TTObject.GetSize() seems to overestimate the size by ~12
% (divided by 110% so as not to underestimate...)
waitbar(.5, wtbar, 'Saving...');
if size < sizeLimit
    pltfileName = NewSaveFileName(directory, sound.fileName);
    save([directory '/' pltfileName '.mat'], 'sound');
else
    warning(['SoundFile object for sound ' sound.fileName sound.fileType ' is too big to be saved in .mat format. Try exporting it to CSV (although with less precision).']);
end
close(wtbar);

end

function directory = GetConfigSaveParams(config)

if isfield(config, 'Directory')
    if ~isdir(config.Directory)
        error('Config.Directory must be a valid directory.');
    end
    directory = config.Directory;
else
    directory = pwd();
end

end

function pltfileName = NewSaveFileName(directory, pltfileName)

filelist = dir(directory);
count = 0;
for k = 1:length(filelist)
    [~,fileName,~] = fileparts(filelist(k).name);
    if strcmp(pltfileName, fileName)
        count = count + 1;
        if count == 1
            pltfileName = [pltfileName '_' num2str(count)];
        else
            if count <= 10
                pltfileName = [pltfileName(1:end-1) num2str(count)];
            elseif count <= 100
                pltfileName = [pltfileName(1:end-2) num2str(count)];
            elseif count <= 1000
                pltfileName = [pltfileName(1:end-3) num2str(count)];
            elseif count <= 10000
                pltfileName = [pltfileName(1:end-4) num2str(count)];
            else
                error('Too many csv files with the same name (10000).');
            end
        end
    end
end

end
