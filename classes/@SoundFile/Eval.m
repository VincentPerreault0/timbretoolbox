function Eval(sound, varargin)

if isempty(varargin)
    config = struct();
else
    config = varargin{1};
end

config = CheckConfigReps(sound, config);

sound.EvalRep(config);

config = CheckConfigDescrs(sound, config);

reps = fieldnames(config);
for i = 1:length(reps)
    descrs = fieldnames(config.(reps{i}));
    wtbar = waitbar(0, 'Evaluating ', 'Name', ['Evaluating ' reps{i} ' Descriptors...']);
    for j = 1:length(descrs)
        waitbar((j-1)/length(descrs), wtbar, ['Evaluating ' descrs{j} ' Descriptor...']);
        sound.reps.(reps{i}).descrs.(descrs{j}) = eval([descrs{j} '(sound.reps.(reps{i}), config.(reps{i}).(descrs{j}))']);
    end
    close(wtbar);
end

end

function config = CheckConfigReps(sound, config)

reps = fieldnames(config);
noSpecifiedRep = true;
for i = 1:length(reps)
    if ~isfield(sound.reps, reps{i})
        config = rmfield(config, reps{i});
    else
        noSpecifiedRep = false;
    end
end
if noSpecifiedRep
    reps = fieldnames(sound.reps);
    for i = 1:length(reps)
        config.(reps{i}) = struct();
    end
elseif ~isfield(config, 'AudioSignal')
    config.AudioSignal.NoDescr = struct();
end

end

function config = CheckConfigDescrs(sound, config)

reps = fieldnames(config);
for i = 1:length(reps)
    descrs = fieldnames(config.(reps{i}));
    if ~any(strcmp('NoDescr', descrs))
        noSpecifiedDescr = true;
        for j = 1:length(descrs)
            if ~isfield(sound.reps.(reps{i}).descrs, descrs{j})
                config.(reps{i}) = rmfield(config.(reps{i}), descrs{j});
            else
                noSpecifiedDescr = false;
                descrFamilyLeader = eval([descrs{j} '.descrFamilyLeader']);
                if ~isempty(descrFamilyLeader)
                    params = fieldnames(config.(reps{i}).(descrs{j}));
                    if isempty(params)
                        if ~isfield(config.(reps{i}), descrFamilyLeader)
                            config.(reps{i}).(descrFamilyLeader) = struct();
                        end
                    else
                        for k = 1:length(params)
                            config.(reps{i}).(eval([descrs{j} '.descrFamilyLeader'])).(params{k}) =...
                                config.(reps{i}).(descrs{j}).(params{k});
                        end
                    end
                    config.(reps{i}) = rmfield(config.(reps{i}), descrs{j});
                end
            end
        end
        if noSpecifiedDescr
            descrs = fieldnames(sound.reps.(reps{i}).descrs);
            for j = 1:length(descrs)
                if isempty(eval([descrs{j} '.descrFamilyLeader']))
                    config.(reps{i}).(descrs{j}) = struct();
                end
            end
        end
    else
        config = rmfield(config, reps{i});
    end
end

end
