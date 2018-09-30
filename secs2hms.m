%SECS2HMS - converts a time in seconds to a string giving the time in hours, minutes and second
%Usage TIMESTRING = SECS2HMS(TIME)]);
%Example 1: >> secs2hms(7261)
%>> ans = 2 hours, 1 min, 1.0 sec
%Example 2: >> tic; pause(61); disp(['program took ' secs2hms(toc)]);
%>> program took 1 min, 1.0 secs

function time_string=secs2hms(time_in_secs)
    time_string='';
    nhours = 0;
    nmins = 0;
    if time_in_secs >= 3600
        nhours = floor(time_in_secs/3600);
        if nhours > 1
            hour_string = ' hours, ';
        else
            hour_string = ' hour, ';
        end
        time_string = [num2str(nhours, '%02.0f') hour_string];
    end
    nmins = floor((time_in_secs - 3600*nhours)/60);
    minute_string = ' min(s), ';
    time_string = [time_string num2str(nmins, '%02.0f') minute_string];
    nsecs = time_in_secs - 3600*nhours - 60*nmins;
    time_string = [time_string sprintf('%02.1f', nsecs) ' secs'];
end