%% File input
disp("Select log file")
[file, location] = uigetfile('*.txt');

% Check if file exists
if isequal(file, 0)
    disp('No file selected. Exiting...')
    return
end
    

data = readtable([location, file]);

                lap_times = data{:,"Dash_3_Lap_Time_s_"};
                % Find smallest non-zero lap time
                lapf_t = min(lap_times(lap_times>0));
                if isempty(lapf_t)
                    lapf_t = 0;
                end
                % Grab row of lapf_t and use it to find lapf number
                lapf = data{lap_times==lapf_t, "Dash_3_Lap_Number_None_"}(1);


% data = readtable([location, file]);
% lap_min = data{1, "Dash_3_Lap_Number_None_"};
% lap_max = data{end, "Dash_3_Lap_Number_None_"};
% disp(lap_min)
% disp(strcat(" Min lap: ", string(lap_min), ...
%     " Map lap: ", string(lap_max)));

%data = data(:,relevant_vars);
% disp(data{1,"Dash_3_Lap_Number_None_"})
% disp(data{end,"Dash_3_Lap_Number_None_"})
    
   