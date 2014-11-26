function time = ConvertToTime(sec)
%CONVERTTOTIME Convert a duration in seconds and sends it back divided in hours,
% minutes and seconds.

hours = floor(sec/3600);
minutes = floor((sec - hours * 3600)/60);
seconds = sec - hours * 3600 - minutes * 60;
time = [hours, minutes, seconds];