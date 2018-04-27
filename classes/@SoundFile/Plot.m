function Plot(sound, varargin)
%PLOT Plots all evaluated selected representations and descriptors.
%   In the possibly given configuration structure are specified
%   representations and their descriptors selected for plotting, possibly
%   with specified Axes (such as subplot handles) to plot in. If no such
%   Axes are provided, the descriptors will be plotted in the same figure
%   as their representation. If no evaluated representations are specified,
%   all are plotted. If no evaluated descriptors are specified for a
%   particular representation, all of its evaluated descriptors will be
%   plotted, unless it has the field 'NoDescr' in which case none of its
%   descriptors will be plotted. A lower time resolution (in Hz) to plot
%   the timeseries in can also be given in the configuration structure
%   under the field 'TimeRes'. Finally, if a directory is provided under
%   the field 'Directory', the plotted figures will be saved in .png format
%   in that directory.

if isempty(varargin)
    config = struct();
else
    config = varargin{1};
end

[config, directory, timeRes] = GetConfigPlotParams(config);

[config, sz, specifiedAxes] = CheckConfigRepsDescrs(sound, config);

reps = fieldnames(config);
if specifiedAxes
    wtbar = waitbar(0, '', 'Name', 'Plotting custom subplots...');
    counter = 0;
    for i = 1:length(reps)
        if isfield(config.(reps{i}), 'Axes')
            waitbar(counter/sz, wtbar, ['Plotting ' reps{i} ' Representation']);
            sound.reps.(reps{i}).PlotAndYLabel(config.(reps{i}).Axes, true, timeRes);
            counter = counter + 1;
        end
        descrs = fieldnames(config.(reps{i}));
        for j = 1:length(descrs)
            if ~strcmp(descrs{j}, 'Axes')
                waitbar(counter/sz, wtbar, ['Plotting ' reps{i} '''s ' descrs{j} ' Descriptor...']);
                sound.reps.(reps{i}).descrs.(descrs{j}).PlotAndYLabel(config.(reps{i}).(descrs{j}).Axes, true, timeRes);
                counter = counter + 1;
            end
        end
    end
    close(wtbar);
else
    for i = 1:length(reps)
        fig = figure();
        wtbar = waitbar(0, ['Plotting ' reps{i} ' Representation'], 'Name', ['Plotting ' reps{i} 'Representation and All its Descriptors...']);
        counter = 1;
        ax = subplot(sz.(reps{i}), 1, counter);
        counter = counter + 1;
        sound.reps.(reps{i}).PlotAndYLabel(ax, false, timeRes);
        title(ax, [reps{i} ' Representation']);
        descrs = fieldnames(config.(reps{i}));
        for j = 1:length(descrs)
            if isa(sound.reps.(reps{i}).descrs.(descrs{j}), 'TVDescr')
                waitbar((counter-1)/sz.(reps{i}), wtbar, ['Plotting ' reps{i} '''s ' descrs{j} ' Descriptor...']);
                ax = subplot(sz.(reps{i}), 1, counter);
                sound.reps.(reps{i}).descrs.(descrs{j}).PlotAndYLabel(ax, false, timeRes);
                counter = counter + 1;
            elseif isa(sound.reps.(reps{i}).descrs.(descrs{j}), 'GlobDescr')
                sound.reps.(reps{i}).descrs.(descrs{j}).PlotAndYLabel();
            end
        end
        xlabel(ax, 'Time (s)');
        if ~isempty(directory)
            if timeRes == 0
                pltfileName = [sound.fileName '_' reps{i}];
            else
                pltfileName = [sound.fileName '_' reps{i} '_' num2str(round(timeRes)) 'Hz'];
            end
            pltfileName = NewPlotFileName(directory, pltfileName);
            saveas(fig,[directory '/' pltfileName '.png']);
        end
        close(wtbar);
    end
end

end

function [config, directory, timeRes] = GetConfigPlotParams(config)
%GETCONFIGPLOTPARAMS Gets all specified plotting parameters.
%   Under the field 'TimeRes', a possible lower time resolution (in Hz) to
%   plot the timeseries in is retrieved. In the field 'Directory', a
%   possible directory where the plotted figures could be saved in in .png
%   format is retrieved.

if isfield(config, 'Directory')
    if ~isdir(config.Directory)
        error('Config.Directory must be a valid directory.');
    end
    directory = config.Directory;
    config = rmfield(config, 'Directory');
else
    directory = '';
end
if isfield(config, 'TimeRes')
    if ~isa(config.TimeRes, 'double') || config.TimeRes < 0
        error('Config.TimeRes must be a time resolution in Hz (double >= 0, with 0 for default time resolutions). It is ignored for ValueType ''stats''.');
    end
    timeRes = config.TimeRes;
    config = rmfield(config, 'TimeRes');
else
    timeRes = 0;
end

end

function [config, sz, specifiedAxes] = CheckConfigRepsDescrs(sound, config)
%CHECKCONFIGREPSDESCRS Makes sure all selected representations and
%descriptors are valid.
%   In the possibly given configuration structure are specified
%   representations and their descriptors selected for plotting, possibly
%   with specified Axes (such as subplot handles) to plot in. If no such
%   Axes are provided, the descriptors will be plotted in the same figure
%   as their representation. If no representations are specified, all are
%   plotted. If no descriptors are specified for a particular
%   representation, all of its descriptors will be plotted, unless it has
%   the field 'NoDescr' in which case none of its descriptors will be
%   plotted.

sz = struct();
specifiedAxes = false;
reps = fieldnames(config);
noSpecifiedRep = true;
for i = 1:length(reps)
    if ~isfield(sound.reps, reps{i}) || ~isa(sound.reps.(reps{i}), 'Rep')
        config = rmfield(config, reps{i});
    else
        sz.(reps{i}) = 1;
        noSpecifiedRep = false;
        if isfield(config.(reps{i}), 'Axes')
            specifiedAxes = true;
        end
        if isfield(config.(reps{i}), 'NoDescr')
            config.(reps{i}) = struct();
        else
            descrs = fieldnames(config.(reps{i}));
            noSpecifiedDescr = true;
            for j = 1:length(descrs)
                if ~strcmp(descrs{j}, 'Axes')
                    if ~isfield(sound.reps.(reps{i}).descrs, descrs{j}) || ~isa(sound.reps.(reps{i}).descrs.(descrs{j}), 'Descr')
                        config.(reps{i}) = rmfield(config.(reps{i}), descrs{j});
                    else
                        if isa(sound.reps.(reps{i}).descrs.(descrs{j}), 'TVDescr')
                            sz.(reps{i}) = sz.(reps{i}) + 1;
                            if isfield(config.(reps{i}).(descrs{j}), 'Axes')
                                specifiedAxes = true;
                            end
                        end
                        noSpecifiedDescr = false;
                    end
                end
            end
            if noSpecifiedDescr
                descrs = fieldnames(sound.reps.(reps{i}).descrs);
                for j = 1:length(descrs)
                    if isa(sound.reps.(reps{i}).descrs.(descrs{j}), 'Descr')
                        config.(reps{i}).(descrs{j}) = struct();
                        if isa(sound.reps.(reps{i}).descrs.(descrs{j}), 'TVDescr')
                            sz.(reps{i}) = sz.(reps{i}) + 1;
                        end
                    end
                end
            end
        end
    end
end
if specifiedAxes
    sz = 0;
    for i = 1:length(reps)
        if ~isfield(config.(reps{i}), 'Axes')
            repShouldGo = true;
        else
            sz = sz + 1;
            repShouldGo = false;
        end
        descrs = fieldnames(config.(reps{i}));
        for j = 1:length(descrs)
            if ~strcmp(descrs{j}, 'Axes')
                if ~isa(sound.reps.(reps{i}).descrs.(descrs{j}), 'TVDescr') || ~isfield(config.(reps{i}).(descrs{j}), 'Axes')
                    config.(reps{i}) = rmfield(config.(reps{i}), descrs{j});
                else
                    sz = sz + 1;
                    repShouldGo = false;
                end
            end
        end
        if repShouldGo
            config = rmfield(config, reps{i});
        end
    end
elseif noSpecifiedRep
    reps = fieldnames(sound.reps);
    for i = 1:length(reps)
        if isa(sound.reps.(reps{i}), 'Rep')
            sz.(reps{i}) = 1;
            config.(reps{i}) = struct();
            descrs = fieldnames(sound.reps.(reps{i}).descrs);
            for j = 1:length(descrs)
                if isa(sound.reps.(reps{i}).descrs.(descrs{j}), 'Descr')
                    config.(reps{i}).(descrs{j}) = struct();
                    if isa(sound.reps.(reps{i}).descrs.(descrs{j}), 'TVDescr')
                        sz.(reps{i}) = sz.(reps{i}) + 1;
                    end
                end
            end
        end
    end
end

end

function pltfileName = NewPlotFileName(directory, pltfileName)
%NEWPLOTFILENAME Finds a new plot figure file name under which to save.
%   In the directory provided under the field 'Directory', it finds the
%   greatest current numbered file with the desired pltfileName and gives
%   out the next numbered plot file name.

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
