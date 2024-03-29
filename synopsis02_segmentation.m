%% Setup wavelet filterbanks.
% Import toolboxes.
addpath(genpath('~/Documents/MATLAB/scattering.m'));
addpath(genpath('~/Documents/MATLAB/export_fig'));

% This threshold is an activation entropy in bits
for threshold = [9, 11, 13]

    % Load time-frequency scattering features for every Synopsis channel
    data_dir = 'data';
    scattering_dir = fullfile(data_dir, 'scattering_transforms');
    n_channels = 12;
    S_channels = cell(1, n_channels);

    for channel_id = 1:12
        channel_str = sprintf('%0.2d', channel_id);
        scattering_name = ['Synopsis_scattering_ch-', channel_str, '.mat'];
        scattering_path = fullfile(scattering_dir, scattering_name);
        disp(channel_str);
        scattering_mat = load(scattering_path);
        S_channels{channel_id} = scattering_mat.X;
    end


    % Sort paths by l1 norm for nicer visualization
    X = cat(3, S_channels{:}).^2;
    [n_features, T, n_channels] = size(X);

    X_l1norms = sum(sum(abs(X), 2), 3);
    [sorted_norms, sorting_indices] = sort(X_l1norms);
    X = X(sorting_indices, :, :);

    % Renormalize
    X = bsxfun(@rdivide, X, eps()+sum(abs(X), 1));


    % Run GLR-based online segmentation with Kullback-Leibler divergences


    channel_changepoints = cell(1, n_channels);

    % Loop over channels
    for channel_id = 1:n_channels
        disp(channel_id);
        t0 = 1;
        t1 = t0 + 1;
        changepoints = [1];

        while t1 < size(X, 2)

            t1 = t1 + 1;

            % Define range of temporal samples.
            t = (t0:(t1-1));

            % Compute cumulative sums
            Xp = cumsum(X(:, t, channel_id), 2);
            Xpf = Xp(:, end) + X(:, t1, channel_id);
            Xf = bsxfun(@minus, Xpf, Xp);

            % Compute half-logarithm of generalized likelihood ratio.
            offset = eps();
            glr = ...
                (t1 - t0 + 1) * entropy(Xpf / (t1-t0), offset) - ...
                (t - t0 + 1) .* entropy(Xp ./ (1:(length(t))), offset) - ...
                (t1 - t) .* entropy(Xf ./ ((length(t):-1:1)), offset);

            % Maximize entropy.
            [max_entropy, delta_t] = max(glr);
            %fprintf('%3d %3d %5.2f %3d %3d\n', ...
            %    t0, t1, max_entropy, delta_t, length(segments));


            % Test alternate hypothesis.
            if max_entropy > threshold
                %disp(max_entropy);

                t0 = t0 + delta_t;
                t1 = t0 + 1;
                changepoints = cat(2, changepoints, t0);
            end
        end

        channel_changepoints{channel_id} = changepoints;
        disp(length(changepoints));
    end
    
    save(sprintf('channel_changepoints_entropy-%02dbit.mat', threshold));
end