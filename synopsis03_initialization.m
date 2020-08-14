tic();
addpath(genpath('tsp_ga'));
data_dir = '/Users/vl238/synopsis_seriation_data/';
load([data_dir, 'X_entropy-11bit.mat']);
data_dir = '/Users/vl238/synopsis_seriation_data/';
%mkdir([data_dir, 'permutations']);

%% Compute summary statistics (average) for each segment
% Left segments correspond to channels 1 to 6
% Right segments correspond to channels 7 to 12

X_channels = cell(1, 12);
X_frames = cell(1, 12);
for channel_id = 1:12
    disp(channel_id);
    scattering_name = ['Synopsis_scattering_ch-', ...
        sprintf('%0.2d', channel_id), '.mat'];
    load([data_dir, '/scattering_transforms/', scattering_name]);
    X_sum = sum(X, 1);
    X = bsxfun(@rdivide, X, eps() + X_sum);
    [n_features, n_frames] = size(X);
    changepoints = ...
        [1, channel_changepoints{channel_id}, 1+n_frames];
    n_segments = length(changepoints) - 1;
    X_struct = struct( ...
        'X', [], 'X_sum', [], 'segment_id', [], ...
        'start', [], 'stop', [], 'channel_id', [], 'is_silent', []);
    X_struct(1:n_segments) = struct( ...
        'X', [], 'X_sum', [], 'segment_id', [], ...
        'start', [], 'stop', [], 'channel_id', [], 'is_silent', []);
    for segment_id = 1:n_segments
        segment_start = changepoints(segment_id);
        segment_stop = changepoints(1+segment_id) - 1;
        segment_X = sum(X(:, segment_start:segment_stop), 2);
        segment_X_sum = mean(X_sum(segment_start:segment_stop));
        duration = segment_stop - segment_start;
        is_silent = (duration < 8) || (segment_X_sum < 1e2);
        disp(segment_X_sum);
        X_struct(segment_id) = struct( ...
            'X', segment_X, ...
            'X_sum', segment_X_sum, ...
            'segment_id', segment_id, ...
            'start', segment_start, ...
            'stop', segment_stop, ...
            'channel_id', channel_id, ...
            'is_silent', is_silent);
    end
    X_channels{channel_id} = X_struct(~[X_struct.is_silent]);
    disp([X_struct.is_silent])
    X_frames{channel_id} = X;
end


%%
X_left = [X_channels{1:6}];
X_right = [X_channels{7:12}];

X_left = [X_left.X];
X_right = [X_right.X];

%% This takes about 2 minutes
X = cat(2, X_left, X_right);
X = max(eps(), X);
X = bsxfun(@rdivide, X, sum(X, 2));
dist_matrix = squareform(pdist(X.', @jensen_shannon_divergence));

%% This takes about 3 minutes
xy = [ ...
    linspace(0, 1, size(X_left, 2)), linspace(0, 1, size(X_right, 2)); ...
    zeros(1, size(X_left, 2)), ones(1, size(X_right, 2))].';

userconfig = struct('xy', xy, 'dmat', dist_matrix, 'numiter', 50000);
tic();
resultStruct = tsp_ga(userconfig);
toc();

%%
left_route = ...
    resultStruct.optRoute(resultStruct.optRoute <= size(X_left, 2));
right_route = ...
    resultStruct.optRoute(resultStruct.optRoute > size(X_left, 2)) - ...
    size(X_left, 2);

X_left = [X_channels{1:6}];
X_right = [X_channels{7:12}];

seriated_X_left = X_left(left_route);
seriated_X_right = X_right(right_route);

save('curly_initialization.mat', 'resultStruct', ...
    'seriated_X_left', 'seriated_X_right', 'dist_matrix');


%% Export initialized segments.

entropy = 11;
disp(entropy);
entropy_str = sprintf('%02d', entropy);
load(fullfile(data_dir, ['channel-changepoints_entropy-', entropy_str, 'bit.mat']));

%%
N = 2^17;
hop_length = N/2;

in_folder = fullfile([data_dir, '/original_waveforms/']);
out_folder = fullfile([data_dir, '/curly_initialization/']);
synopsis_prefix = 'Synopsis_Seriation_v2_';



% Left segment
n_left_segments = length(seriated_X_left);
seriated_left_waveforms = cell(1, n_left_segments);

for left_segment_id = 1:n_left_segments
    left_segment = seriated_X_left(left_segment_id);
    channel_id = left_segment.channel_id;
    wav_name = ['Synopsis_Seriation_dataset_Synopsis_Seriation_', int2str(channel_id), '.wav'];
    wav_path = fullfile(in_folder, wav_name);
    [waveform, sr] = audioread(wav_path);
    segment_start = 1 + (left_segment.start-1) * hop_length;
    segment_stop = min(length(waveform), left_segment.stop * hop_length);
    segment = waveform(segment_start:segment_stop);
    seriated_left_waveforms{left_segment_id} = segment;
    disp([left_segment_id, channel_id, segment_start, segment_stop]);
end

left_waveform = cat(1, seriated_left_waveforms{:});

%%
% Right segment
n_right_segments = length(seriated_X_right);
seriated_right_waveforms = cell(1, n_right_segments);

for right_segment_id = 1:n_right_segments
    right_segment = seriated_X_right(right_segment_id);
    channel_id = right_segment.channel_id;
    wav_name = ['Synopsis_Seriation_dataset_Synopsis_Seriation_', int2str(channel_id), '.wav'];
    wav_path = fullfile(in_folder, wav_name);
    [waveform, sr] = audioread(wav_path);
    segment_start = 1 + (right_segment.start-1) * hop_length;
    segment_stop = min(length(waveform), right_segment.stop * hop_length);
    segment = waveform(segment_start:segment_stop);
    seriated_right_waveforms{right_segment_id} = segment;
    disp([right_segment_id, channel_id, segment_start, segment_stop]);
end

right_waveform = cat(1, seriated_right_waveforms{:});

