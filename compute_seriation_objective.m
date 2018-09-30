function objective = compute_seriation_objective( ...
    s_left, s_right, X_left, X_right, X_tensor)

n_features = size(X_tensor, 1);
n_frames = size(X_tensor, 2);
X_frames_left = zeros(n_features, 6*n_frames);

frame_id = 1;
for n = 1:length(X_left)
    X_segment = X_left(s_left(n));
    segment_length = X_segment.stop - X_segment.start + 1;
    channel_id = X_segment.channel_id;
    segment_range = X_segment.start:X_segment.stop;
    X_frames_left(:, frame_id:(frame_id+segment_length-1)) = ...
        X_tensor(:, segment_range, channel_id);
    frame_id = frame_id + segment_length;
end


X_frames_right = zeros(n_features, 6*n_frames);
frame_id = 1;
for n = 1:length(X_right)
    X_segment = X_right(s_right(n));
    segment_length = X_segment.stop - X_segment.start + 1;
    channel_id = X_segment.channel_id;
    segment_range = X_segment.start:X_segment.stop;
    X_frames_right(:, frame_id:(frame_id+segment_length-1)) = ...
        X_tensor(:, segment_range, channel_id);
    frame_id = frame_id + segment_length;
end


X_frames_mono = 0.5 * (X_frames_left + X_frames_right);
X_jensen_shannon = ... 
    X_frames_left .* log(X_frames_left ./ X_frames_mono) + ...
    X_frames_right .* log(X_frames_right ./ X_frames_mono);
X_jensen_shannon(isnan(X_jensen_shannon)) = 0;
stereo_objective = 0.5 * sum(X_jensen_shannon(:));

Xhat_frames_left_past = X_frames_left(:, 1:(end-1));
Xhat_frames_left_future = X_frames_right(:, 2:end);
Xhat_frames_left_present = 0.5 * ...
    (Xhat_frames_left_past + Xhat_frames_left_future);
Xhat_left_jensen_shannon = ...
    Xhat_frames_left_past .* ...
    log(Xhat_frames_left_past ./ Xhat_frames_left_present) + ...
    Xhat_frames_left_future .* ...
    log(Xhat_frames_left_future ./ Xhat_frames_left_present);
Xhat_left_jensen_shannon(isnan(Xhat_left_jensen_shannon)) = 0;
left_objective = 0.5 * sum(Xhat_left_jensen_shannon(:));

Xhat_frames_right_past = X_frames_right(:, 1:(end-1));
Xhat_frames_right_future = X_frames_right(:, 2:end);
Xhat_frames_right_present = 0.5 * ...
    (Xhat_frames_right_past + Xhat_frames_right_future);
Xhat_right_jensen_shannon = ...
    Xhat_frames_right_past .* ...
    log(Xhat_frames_right_past ./ Xhat_frames_right_present) + ...
    Xhat_frames_right_future .* ...
    log(Xhat_frames_right_future ./ Xhat_frames_right_present);
Xhat_right_jensen_shannon(isnan(Xhat_right_jensen_shannon)) = 0;
right_objective = 0.5 * sum(Xhat_right_jensen_shannon(:));

objective = stereo_objective  + left_objective + right_objective;
end