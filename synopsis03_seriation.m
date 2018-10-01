tic();
load('/beegfs/vl1019/synopsis_seriation_data/channel_changepoints.mat');
mkdir('/beegfs/vl1019/synopsis_seriation_data/permutations');

%% Compute summary statistics (average) for each segment
% Left segments correspond to channels 1 to 6
% Right segments correspond to channels 7 to 12

X_channels = cell(1, 12);
X_frames = cell(1, 12);
for channel_id = 1:12
    scattering_name = ['Synopsis_scattering_ch-', ...
        sprintf('%0.2d', channel_id), '.mat'];
    load( ...
        ['/beegfs/vl1019/synopsis_seriation_data/scattering_transforms/', scattering_name]);
    X = bsxfun(@rdivide, X, sum(X, 1));
    [n_features, n_frames] = size(X);
    changepoints = ...
        [1, channel_changepoints{channel_id}, 1+n_frames];
    n_segments = length(changepoints) - 1;
    X_struct = struct( ...
        'X', [], 'segment_id', [], ...
        'start', [], 'stop', [], 'channel_id', []);
    X_struct(1:n_segments) = struct( ...
        'X', [], 'segment_id', [], ...
        'start', [], 'stop', [], 'channel_id', []);
    for segment_id = 1:n_segments
        segment_start = changepoints(segment_id);
        segment_stop = changepoints(1+segment_id) - 1;
        X_struct(segment_id) = struct( ...
            'X', sum(X(:, segment_start:segment_stop), 2), ...
            'segment_id', segment_id, ...
            'start', segment_start, ...
            'stop', segment_stop, ...
            'channel_id', channel_id);
    end
    X_channels{channel_id} = X_struct;
    X_frames{channel_id} = X;
end
X_left = [X_channels{1:6}];
X_right = [X_channels{7:12}];
X_tensor = cat(3, X_frames{:});


%% Set random seed
rng(trial_id);
disp(trial_id);
mkdir( ...
    ['/beegfs/vl1019/synopsis_seriation_data/permutations/', ...
    sprintf('permutations_trial%03d', trial_id)]);
s_left = randperm(length(X_left));
s_right = randperm(length(X_right));

n_iterations = 100;
history = zeros(1, n_iterations);
n = 0;

objective = compute_seriation_objective( ...
   s_left, s_right, X_left, X_right, X_tensor);


while (n < n_iterations)
    history(1+n) = objective;

    pair_left = randsample(length(X_left), 2);
    alt_s_left = s_left;
    alt_s_left(pair_left) = s_left(pair_left(2:-1:1));

    pair_right = randsample(length(X_right), 2);
    alt_s_right = s_right;
    alt_s_right(pair_right) = s_right(pair_right(2:-1:1));

    alt_objective = compute_seriation_objective( ...
        alt_s_left, alt_s_right, X_left, X_right, X_tensor);

    if alt_objective < objective
        s_left = alt_s_left;
        s_right = alt_s_right;
        objective = alt_objective;
        fprintf('%03d %4.3f\n', n, objective);
    end

    if mod(n, 1) == 0
        S = struct( ...
            'trial_id', trial_id, ...
            'n', n, ...
            's_left' ,s_left, ...
            's_right', s_right, ...
            'objective', objective);
        save(sprintf([ ...
            '/beegfs/vl1019/synopsis_seriation_data/permutations/permutations_trial%03d/', ...
            'permutations_trial%03d_it%04d.mat'], trial_id, trial_id, n), ...
            'S', '-v7.3');
        toc();
        tic();
    end

    n = n + 1;
end
