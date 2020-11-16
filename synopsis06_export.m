
%% Load best seriation
data_dir = "/Users/vl238/synopsis_seriation_data";
mat_path = fullfile( ...
    data_dir, "permutations_v2_trial027_it19300_obj0079020922.mat");
load(mat_path);
best_X = S;

%% Load changepoints
load(fullfile(data_dir, 'channel-changepoints_entropy-11bit.mat'));

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
    right_channels{i} = 6 + i * ones(1, right_n_segments(i));
    right_segments{i} = 1:(right_n_segments(i));
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
        audioread(fullfile(data_dir, 'original_waveforms', ...
        ['Synopsis_Seriation_dataset_Synopsis_Seriation_', ...
        sprintf('%d', channel_waveform_id), '.wav']));
end

%%

seriated_left_y = cell(1, length(seriated_left_channels));
for i = 1:length(seriated_left_channels)
    left_channel = seriated_left_channels(i);
    left_segment = seriated_left_segments(i);
    
    left_start = channel_changepoints{left_channel}(left_segment);
    left_start_y = 1 + (left_start-1) * 2^16;
    
    if length(channel_changepoints{left_channel}) == left_segment
        left_stop_y = length(channel_waveforms{left_channel});
    else
        left_stop = channel_changepoints{left_channel}(left_segment+1) - 1;
        left_stop_y = left_stop * 2^16;
    end

    segment_left_y = channel_waveforms{left_channel}( ...
        left_start_y:left_stop_y);
    disp([i, length(segment_left_y)]);
    seriated_left_y{i} = segment_left_y;
end

%%

seriated_right_y = cell(1, length(seriated_right_channels));
for i = 1:length(seriated_right_channels)
    disp(i);
    right_channel = seriated_right_channels(i);
    right_segment = seriated_right_segments(i);

    if right_segment == 1
        right_start_y = 1;
    else
        right_start = channel_changepoints{right_channel}(right_segment-1);
        right_start_y = 1+ (right_start-1) * 2^16;
    end

    if length(channel_changepoints{right_channel}) == (right_segment-1)
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
y_cat_left = cat(1, y_cat_left, zeros(length(y_cat_right)-length(y_cat_left), 1));

%%
y_out = cat(2, y_cat_left, y_cat_right);

%%
audiowrite('Synopsis_Seriation_2020-08-18.wav', y_out, 48000, ...
    'BitsPerSample', 32);