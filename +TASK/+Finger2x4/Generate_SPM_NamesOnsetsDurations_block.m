function [names, onsets, durations] = Generate_SPM_NamesOnsetsDurations_block()
global S


%% Preparation

names = {
    'L4'
    'L3'
    'L2'
    'L1'
    'R1'
    'R2'
    'R3'
    'R4'
    'Rest'
    'Queue'
    'Tap'
    };

% 'onsets' & 'durations' for SPM
onsets    = cell(size(names));
durations = cell(size(names));

name2idx = [];
for n = 1 : length(names)
    name2idx.(names{n}) = n;
end

icol_name     = S.recEvent.icol_name;
icol_onset    = S.recEvent.icol_onset;
icol_duration = S.recEvent.icol_duration;
data = S.recEvent.data; % copy


%% Onsets building

for evt = 1:size(data,1)
    if strcmp(data{evt,icol_name}, S.recEvent.label_start) || strcmp(data{evt,icol_name}, S.recEvent.label_end)
        %pass
    else
        onsets{name2idx.(data{evt,icol_name})} = [onsets{name2idx.(data{evt,icol_name})} ; data{evt,icol_onset}];
    end
end


%% Durations building

for evt = 1:size(data,1)
    if strcmp(data{evt,1}, S.recEvent.label_start) || strcmp(data{evt,1}, S.recEvent.label_end)
        %pass
    else
        durations{name2idx.(data{evt,icol_name})} = [ durations{name2idx.(data{evt,icol_name})} ; data{evt,icol_duration}];
    end
end


%% Add Clicks as regressor

for k = 1 : 8

    keyname = names{k};
    idx = strcmp(S.recKeylogger.data(:,S.recKeylogger.icol_name), keyname);
    onsets   {name2idx.(keyname)} = cell2mat(S.recKeylogger.data(idx,S.recKeylogger.icol_onset   ));
    durations{name2idx.(keyname)} = cell2mat(S.recKeylogger.data(idx,S.recKeylogger.icol_duration));

end


%% Debuging

% UTILS.plotSPMnod(names, onsets, durations)


end % fcn