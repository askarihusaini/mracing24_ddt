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

% The below code will all get replaced by actual data
timei = 0;
timef = 10;
x = timei:.01:timef;
data1 = [sin(x) ; cos(x) ; tan(x) ; x/10 ; x.^2/10 ; x.^3/10 ; 0*x + 0.5 ; -x/10];
data2 = data1 - 1;

axis_names = ["Var A", "Var B", "Var C", "Var D", "Var E", "Var F", "Var G", "Var H"];
selected_vars = [1,2,3,4,5,6,7,8];

NUM_VARS = size(selected_vars,2);
axes = zeros(NUM_VARS);

figureColor = [0,0,0];
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'w','w','w'})

f1 = uifigure('color', figureColor);

% T Tiled layout
T = tiledlayout(f1, 1,3, "TileSpacing", "compact", "Padding", "compact");

% t1 Tile 1: Tiled layout: Graphs of variables
t1 = tiledlayout(T, "vertical", "TileSpacing", "compact", "Padding", "compact");
t1.Layout.Tile = 1;
t1.Layout.TileSpan = [1,2];
% Subtiles: Individual graphs of variables
for i = 1:NUM_VARS
    ax = nexttile(t1);
    curr = axes(i);
    hold(ax, "on")
    curr(1) = plot(ax, x, data1(i,:), "Color", [1,0,0]);
    curr(2) = plot(ax, x, data2(i,:), "Color", [0,0.5,1]);
    hold(ax, "off")

    %curr.ButtonDownFcn = @(h,e) disp(e.IntersectionPoint);

    ax.Color = [.1,.1,.1];
    ax.XTick = [];
    ax.YTick = [];
    ax.YLabel.String = axis_names(selected_vars(i));
end
ax.XTick = timei:timef;
ax.XLabel.String = "time (s)";

% t2 Tile 2: Tiled layout: Infobox and map
t2 = tiledlayout(T, 2,1, "TileSpacing", "compact", "Padding", "none");
t2.Layout.Tile = 3;

t_slider = uislider(f1,"range");
t_slider.Limits = [timei, timef];
t_selected = get(t_slider, 'value'); % t from both ends of the slider range

% t2a Subtile A: Tiled layout: 2 columns for track data of both laps
ax = nexttile(t2, 1, [1,1]);
ax.Visible = 0; % Make axes invisible for text display
t2a = tiledlayout(t2, 1,2, "TileSpacing", "none", "Padding", "none");
t2a.Layout.Tile = 1;

% Subsubtile i & ii: Lap data of track 1 & 2
for i = [1,2]
    ax = nexttile(t2a, i, [1,1]);
    ax.XTick = [];
    ax.YTick = [];
    ax.Color = [.1,.1,.1];
    ax.Box = "on";

    infoBox_string = "Lap " + i + ":\n@ t = " + t_selected(1) + "\n";
    infoBox_data = zeros(NUM_VARS);
    for j = 1:NUM_VARS
        infoBox_string = infoBox_string + axis_names(selected_vars(j)) + ": " + infoBox_data(j) + "\n";
    end

    text(ax, 0.05,.975,sprintf(infoBox_string), 'Horiz','left', 'Vert','top', ...
        "Color", "w", 'fontsize',8,'fontunits','normalized')

end

% Subtile B: Map
ax = nexttile(t2, 2, [1,1]);
ax.XTick = [];
ax.YTick = [];
ax.Color = [.1,.1,.1];
ax.Box = "on";



%% old

% clear
% close all
% warning('off','all')
% 
% figureColor = [0,0,0];
% subplotColor = [0.1,0.1,0.1];
% set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'w','w','w'})
% 
% %figure 1
% f1 = figure('color', figureColor);
% sgtitle("Lap Analysis (1)")
% %set(f1, 'WindowButtonDownFcn', @MovingVerticalLine);
% 
% axs_length = 5;
% axs_width = 4;
% axisHeight = 0.18;
% %axisPos = [1-axisHeight, 1-(2*(axisHeight-.001)), 1-(3*(axisHeight-.001)), 1-(4*(axisHeight-.001)), 1-(5*(axisHeight-0.001))] - 0.03;
% for i = 1:5
%     axisPos(i) = 1-i*(0.2-0.03) - 0.03;
% end
% 
% axs_SPEED = subplot(axs_length,axs_width, 1, 'color', subplotColor, 'Position', [0.03,axisPos(1),0.65,axisHeight]);
% xticks([]);
% yticks([]);
% ylabel("Speed(mph)")
% 
% 
% axs_THROTTLE = subplot(axs_length,axs_width, 5, 'color', subplotColor, 'Position', [0.03,axisPos(2),0.65,axisHeight]);
% xticks([]);
% yticks([]);
% ylabel("Throttle Input(percent)")
% set(gca, 'YGrid', 'on', 'XGrid', 'off');
% 
% axs_BRAKE = subplot(axs_length,axs_width, 9, 'color', subplotColor, 'Position', [0.03,axisPos(3),0.65,axisHeight]);
% xticks([]);
% yticks([]);
% ylabel("Brake Pressure(psi)")
% grid on
% 
% axs_RPM = subplot(axs_length,axs_width, 13, 'color', subplotColor, 'Position', [0.03,axisPos(4),0.65,axisHeight]);
% xticks([])
% yticks([]);
% ylabel("RPM")
% grid on
% 
% axs_GFORCE1 = subplot(axs_length,axs_width, 17, 'color', subplotColor, 'Position', [0.03,axisPos(5),0.65,axisHeight]);
% xlabel("time (s)")
% yticks([]);
% ylabel("Cumulative G-Force")
% grid on
% 
% axs_map = subplot(axs_length,axs_width, [16,20],'color', subplotColor, 'Position', [0.725,.15,0.25,.45]);
% 
% axs = [axs_SPEED, axs_THROTTLE, axs_BRAKE, axs_RPM, axs_GFORCE1];
% 
% %information readout
% infoBox_str = {['Time: ',num2str(0)], ['Speed: ', num2str(0)], ['Throttle: ', num2str(0)], ['Brake: ', num2str(0)], ['RPM: ', num2str(0)], ['GForce: ', num2str(0)]};
% infoBox_dim = [.915 .375 .75 .2];
% infoBox_color = [1 1 1];
% infoBox = annotation(f1, 'textbox',infoBox_dim,'String',infoBox_str,'FitBoxToText','on', 'color', infoBox_color, 'edgecolor', infoBox_color, 'FontSize', 11);
% 
% warning('on','all')