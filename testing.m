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


%% mine
clear
close all

timei = 0;
timef = 10;
x = timei:.01:timef;
data = [sin(x) ; cos(x) ; tan(x) ; x/10 ; x.^2/10 ; x.^3/10 ; 0*x + 0.5 ; -x/10];
%data = [sin(x); cos(x); tan(x); x/10; x.^2/10; (x.^3 - x)/10; 0.5; -x/10];

axis_names = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
selected_vars = [1,2,3,4,5];
NUM_VARS = size(selected_vars,2);
plots = zeros(NUM_VARS);

% Manual
% AXIS_LENGTH = 5;
% AXIS_HEIGHT = 4;
% BUFFER = 0.025;
% PROP_WIDTH = 0.5;
% axes = zeros(NUM_VARS);
% for i = 1:NUM_VARS
%     axes(selected_vars(i)) = plot(AXIS_LENGTH, AXIS_HEIGHT, (i-1)*AXIS_HEIGHT+1, ...
%     'color', subplotColor, 'Position', [BUFFER, 1 - i * (1/NUM_VARS - BUFFER), PROP_WIDTH, .1]);
%     %[BUFFER, 1 - i * (1/NUM_VARS - BUFFER), PROP_WIDTH, 1/NUM_VARS - BUFFER]
%     xticks([]); % remove markings
%     yticks([]);
%     ylabel(strcat("Graph ", string(axis_names(selected_vars(i)))))
% end

figureColor = [0,0,0];
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'w','w','w'})

f1 = figure('color', figureColor);
sgtitle("Lap Analysis (1)") 

% Create tiled layout with three vertical sections
T = tiledlayout(1,3, "TileSpacing", "compact", "Padding", "compact");

% First subtile spans two vertical sections, with inner horizontal sections
t1 = tiledlayout(T, "vertical", "TileSpacing", "none", "Padding", "compact");
t1.Layout.Tile = 1;
t1.Layout.TileSpan = [1,2];
% Fill each inner horizontal section with a graph
for i = 1:NUM_VARS
    nexttile(t1)
    plots(i) = plot(x, data(i,:), 'r');
    set(gca,'Color', [.1, .1, .1])
    xticks([])
    yticks([])
    ylabel("Var. " + axis_names(selected_vars(i)))
end
xticks();
xlabel("time (s)")

% Second subtile spans the third vertical section, with five horizontal
% sections
t2 = tiledlayout(T, 5,1, "TileSpacing", "compact", "Padding", "compact");
t2.Layout.Tile = 3;

% The info readout spans three of the inner horizontal sections
nexttile(t2, 1, [3,1])
text(0,0.1, sprintf( ...
    "Time\nSpeed\nThrottle\netc..." ...
    ), "Color", "w", "FontSize", 10)

Ax = gca;
Ax.Visible = 0; % Make current axis invisible (just display text)

% infoBox_str = {['Time: ',num2str(0)], ['Speed: ', num2str(0)], ['Throttle: ', num2str(0)], ['Brake: ', num2str(0)], ['RPM: ', num2str(0)], ['GForce: ', num2str(0)]};
% infoBox_dim = [.915 .375 .75 .2];
% infoBox_color = [1 1 1];
% infoBox = annotation(f1, 'textbox',infoBox_dim,'String',infoBox_str,'FitBoxToText','on', 'color', infoBox_color, 'edgecolor', infoBox_color, 'FontSize', 11);

% The map spans the fourth and fifth horizontal section
nexttile(t2, 4, [2,1])
plot(x, sin(x))


%% old

clear
close all
warning('off','all')

figureColor = [0,0,0];
subplotColor = [0.1,0.1,0.1];
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'w','w','w'})

%figure 1
f1 = figure('color', figureColor);
sgtitle("Lap Analysis (1)")
%set(f1, 'WindowButtonDownFcn', @MovingVerticalLine);

axs_length = 5;
axs_width = 4;
axisHeight = 0.18;
%axisPos = [1-axisHeight, 1-(2*(axisHeight-.001)), 1-(3*(axisHeight-.001)), 1-(4*(axisHeight-.001)), 1-(5*(axisHeight-0.001))] - 0.03;
for i = 1:5
    axisPos(i) = 1-i*(0.2-0.03) - 0.03;
end

axs_SPEED = subplot(axs_length,axs_width, 1, 'color', subplotColor, 'Position', [0.03,axisPos(1),0.65,axisHeight]);
xticks([]);
yticks([]);
ylabel("Speed(mph)")


axs_THROTTLE = subplot(axs_length,axs_width, 5, 'color', subplotColor, 'Position', [0.03,axisPos(2),0.65,axisHeight]);
xticks([]);
yticks([]);
ylabel("Throttle Input(percent)")
set(gca, 'YGrid', 'on', 'XGrid', 'off');

axs_BRAKE = subplot(axs_length,axs_width, 9, 'color', subplotColor, 'Position', [0.03,axisPos(3),0.65,axisHeight]);
xticks([]);
yticks([]);
ylabel("Brake Pressure(psi)")
grid on

axs_RPM = subplot(axs_length,axs_width, 13, 'color', subplotColor, 'Position', [0.03,axisPos(4),0.65,axisHeight]);
xticks([])
yticks([]);
ylabel("RPM")
grid on

axs_GFORCE1 = subplot(axs_length,axs_width, 17, 'color', subplotColor, 'Position', [0.03,axisPos(5),0.65,axisHeight]);
xlabel("time (s)")
yticks([]);
ylabel("Cumulative G-Force")
grid on

axs_map = subplot(axs_length,axs_width, [16,20],'color', subplotColor, 'Position', [0.725,.15,0.25,.45]);

axs = [axs_SPEED, axs_THROTTLE, axs_BRAKE, axs_RPM, axs_GFORCE1];

%information readout
infoBox_str = {['Time: ',num2str(0)], ['Speed: ', num2str(0)], ['Throttle: ', num2str(0)], ['Brake: ', num2str(0)], ['RPM: ', num2str(0)], ['GForce: ', num2str(0)]};
infoBox_dim = [.915 .375 .75 .2];
infoBox_color = [1 1 1];
infoBox = annotation(f1, 'textbox',infoBox_dim,'String',infoBox_str,'FitBoxToText','on', 'color', infoBox_color, 'edgecolor', infoBox_color, 'FontSize', 11);

warning('on','all')