function EvalRep(sound, config)
%EVALREP Evaluates all selected representations.
%   In the given configuration structure are specified all selected
%   representations for evaluation, possibly with specified non-default
%   parameter values.

wtbar = waitbar(0, 'Reading Audio Signal Representation', 'Name', 'Evaluating Representations...');
if ~isa(sound.reps.AudioSignal, 'Rep') || ~sound.reps.AudioSignal.HasSameConfig(config.AudioSignal)
    sound.reps.AudioSignal = AudioSignal(sound, config.AudioSignal);
end
config = rmfield(config, 'AudioSignal');
reps = fieldnames(config);
for i = 1:length(reps)
    if ~isa(sound.reps.(reps{i}), 'Rep') || ~sound.reps.(reps{i}).HasSameConfig(config.(reps{i}))
        waitbar(i/(length(reps)+1), wtbar, ['Evaluating ' reps{i} ' Representation...']);
        sound.reps.(reps{i}) = eval([reps{i} '(sound, config.(reps{i}))']);
    end
end
close(wtbar);

end