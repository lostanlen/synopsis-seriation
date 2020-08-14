%% 11 bits sounds best
for entropy = [9, 11, 13]
    disp(entropy);
    entropy_str = sprintf('%02d', entropy);
    load(['channel_changepoints_entropy-', entropy_str, 'bit.mat']);
    N = 2^17;
    hop_length = N/2;

    data_folder = 'data/original_waveforms/';
    synopsis_prefix = 'Synopsis_Seriation_dataset_Synopsis_Seriation_';

    %
    segment_dir = fullfile('data', ...
        ['segments_entropy-', entropy_str, 'bit']);
    mkdir(segment_dir);
    
    for channel_id = 1:12
        wav_name = [synopsis_prefix, int2str(channel_id), '.wav'];
        wav_path = fullfile(data_folder, wav_name);
        [waveform, sr] = audioread(wav_path);
        changepoint_samples = channel_changepoints{channel_id} * hop_length;
        changepoint_samples = [0, changepoint_samples, length(waveform)];
        n_segments = length(changepoint_samples) - 1;

        for segment_id = 1:n_segments
            disp([channel_id, segment_id, n_segments]);
            segment_start = 1 + changepoint_samples(segment_id);
            segment_stop = changepoint_samples(1+segment_id);
            segment = waveform(segment_start:segment_stop);
            segment_name = [ ...
                'channel-', sprintf('%02d', channel_id), '_', ...
                'segment-', sprintf('%02d', segment_id), ...
                '-of-', sprintf('%02d', n_segments), '.wav'];
            segment_path = fullfile(segment_dir, segment_name);
            audiowrite(segment_path, segment, sr, 'BitsPerSample', 32);
        end
    end
end