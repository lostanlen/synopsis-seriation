
%% Find best seriation
n_trials = 200;
n_steps = 100;
X(1:n_trials, 1:n_steps) = struct( ...
    'trial_id', 0, 'n', 0, 's_left', [], 's_right', [], ...
    'objective', 0.0);

for trial_id = 0:(n_trials-1)
    trial_str = sprintf('%03d', trial_id);
    disp(trial_id)
    
    for it_id = 0:(n_steps-1)
        it = 100*it_id;
        it_str = sprintf('%05d', it);
        folder_str = ['permutations_trial', trial_str];
        file_str = strcat(folder_str, ['_it', it_str, '.mat']);
        file_path = strcat('~/datasets/permutations/', ...
            folder_str, '/', file_str);
        x = load(file_path);
        X(1+trial_id, 1+it_id) = x.S;
    end
end

objectives = arrayfun(@(x) x.objective, X);
[sorted_objectives, argsort_objectives] = sort(objectives(:,end));

best_X = X(argsort_objectives(1), end);

%% Load changepoints
load('channel_changepoints.mat');

%%


left_n_segments = cellfun(@length, channel_changepoints(1:6));
left_channels = cell(1, length(left_n_segments));
left_segments = cell(1, length(left_n_segments));
for i = 1:length(left_n_segments)
    left_channels{i} = i * ones(1, left_n_segments(i));
    left_segments{i} = 1:(left_n_segments(i));
end
left_channels = [left_channels{:}];
left_segments = [left_segments{:}];

seriated_left_channels = left_channels([best_X.s_left]);
seriated_left_segments = left_segments([best_X.s_left]);


right_n_segments = cellfun(@length, channel_changepoints(7:12));
right_channels = cell(1, length(right_n_segments));
right_segments = cell(1, length(right_n_segments));
for i = 1:length(right_n_segments)
    right_channels{i} = 6 + i * ones(1, right_n_segments(i)+1);
    right_segments{i} = 1:(right_n_segments(i)+1);
end
right_channels = [right_channels{:}];
right_segments = [right_segments{:}];

seriated_right_channels = right_channels([best_X.s_right]);
seriated_right_segments = right_segments([best_X.s_right]);



%%
channel_waveforms = cell(1, 12);
for channel_waveform_id = 1:12
    disp(channel_waveform_id);
    channel_waveforms{channel_waveform_id} = ...
        audioread(['original_waveforms/', ...
        'Synopsis_Seriation_dataset_Synopsis_Seriation_', ...
        sprintf('%d', channel_waveform_id), '.wav']);
end

%%

seriated_left_y = cell(1, length(seriated_left_channels));
for i = 1:length(seriated_left_channels)
    disp(i);
    left_channel = seriated_left_channels(i);
    left_segment = seriated_left_segments(i);
    if left_segment == 1
        continue
    end
    left_start = channel_changepoints{left_channel}(left_segment-1);
    left_start_y = 1+ (left_start-1) * 2^16;
    if left_segment > length(channel_changepoints{left_channel})
        left_stop_y = length(channel_waveforms{left_channel});
    else
        left_stop = channel_changepoints{left_channel}(left_segment) - 1;
        left_stop_y = left_stop * 2^16;
    end

    segment_left_y = channel_waveforms{left_channel}( ...
        left_start_y:left_stop_y);
    seriated_left_y{i} = segment_left_y;
end

%%

seriated_right_y = cell(1, length(seriated_right_channels));
for i = 1:length(seriated_right_channels)
    disp(i);
    right_channel = seriated_right_channels(i);
    right_segment = seriated_right_segments(i);
    if right_segment == 1
        continue
    end
    right_start = channel_changepoints{right_channel}(right_segment-1);
    right_start_y = 1+ (right_start-1) * 2^16;
    if right_segment > length(channel_changepoints{right_channel})
        right_stop_y = length(channel_waveforms{right_channel});
    else
        right_stop = channel_changepoints{right_channel}(right_segment) - 1;
        right_stop_y = right_stop * 2^16;
    end

    segment_right_y = channel_waveforms{right_channel}( ...
        right_start_y:right_stop_y);
    seriated_right_y{i} = segment_right_y;
end

%%
y_cat_left = cat(1, seriated_left_y{:});
y_cat_right = cat(1, seriated_right_y{:});
y_out = cat(2, y_cat_left, y_cat_right);

%%