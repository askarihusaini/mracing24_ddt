% %% File input
% disp("Select log file")
% [file, location] = uigetfile('*.txt');
% 
% % Check if file exists
% if isequal(file, 0)
%     disp('No file selected. Exiting...')
%     return
% end
% 
% data = readtable([location, file]);

figureColor = [0,0,0]; % Black figure
subplotColor = [0.1,0.1,0.1]; % Dark gray graph background
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'w','w','w'}) % White axes

f1 = figure('color', figureColor);
sgtitle("Lap Analysis (1)")

%axis vars
axs_length = 5;
axs_width = 4;
NUM_VARS = 5; % Number of variables we are plotting

axisHeight = 1/(NUM_VARS + 0.1);

axisPos = [1-axisHeight, 1-(2*(axisHeight-.001)), 1-(3*(axisHeight-.001)), 1-(4*(axisHeight-.001)), 1-(5*(axisHeight-0.001))] - 0.03;

axs_SPEED = subplot(axs_length,axs_width, [1:3], 'color', subplotColor, 'Position', [0.03,axisPos(1),0.65,axisHeight]);
xticks([]);
yticks([]);
ylabel("Speed(mph)")


% lap_times = data{:,"Dash_3_Lap_Time_s_"};
% % Find smallest non-zero lap time
% lapf_t = min(lap_times(lap_times>0));
% if isempty(lapf_t)
%     lapf_t = 0;
% end
% % Grab row of lapf_t and use it to find lapf number
% lapf = data{lap_times==lapf_t, "Dash_3_Lap_Number_None_"}(1);
% f = msgbox("Operation Completed");


% data = readtable([location, file]);
% lap_min = data{1, "Dash_3_Lap_Number_None_"};
% lap_max = data{end, "Dash_3_Lap_Number_None_"};
% disp(lap_min)
% disp(strcat(" Min lap: ", string(lap_min), ...
%     " Map lap: ", string(lap_max)));

%data = data(:,relevant_vars);
% disp(data{1,"Dash_3_Lap_Number_None_"})
% disp(data{end,"Dash_3_Lap_Number_None_"})
    
   