%% Load Data
cd("C:\Users\askar\docs\MATLAB\mracing24_ddt\ddt_old")

%% Initialize Figure
close all
warning('off','all')

figureColor = [0,0,0];
subplotColor = [0.1,0.1,0.1];
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'w','w','w'})

%figure 1
f1 = figure('color', figureColor);
sgtitle("Lap Analysis (1)")
%set(f1, 'WindowButtonDownFcn', @MovingVerticalLine);

%axis vars
axs_length = 5;
axs_width = 4;
axisHeight = 0.18;
axisPos = [1-axisHeight, 1-(2*(axisHeight-.001)), 1-(3*(axisHeight-.001)), 1-(4*(axisHeight-.001)), 1-(5*(axisHeight-0.001))] - 0.03;

axs_SPEED = subplot(axs_length,axs_width, [1:3], 'color', subplotColor, 'Position', [0.03,axisPos(1),0.65,axisHeight]);
xticks([]);
yticks([]);
ylabel("Speed(mph)")


axs_THROTTLE = subplot(axs_length,axs_width, [5:7], 'color', subplotColor, 'Position', [0.03,axisPos(2),0.65,axisHeight]);
xticks([]);
yticks([]);
ylabel("Throttle Input(percent)")
set(gca, 'YGrid', 'on', 'XGrid', 'off');

axs_BRAKE = subplot(axs_length,axs_width, [9:11], 'color', subplotColor, 'Position', [0.03,axisPos(3),0.65,axisHeight]);
xticks([]);
yticks([]);
ylabel("Brake Pressure(psi)")
grid on

axs_RPM = subplot(axs_length,axs_width, [13:15], 'color', subplotColor, 'Position', [0.03,axisPos(4),0.65,axisHeight]);
xticks([])
yticks([]);
ylabel("RPM")
grid on

axs_GFORCE1 = subplot(axs_length,axs_width, [17:19], 'color', subplotColor, 'Position', [0.03,axisPos(5),0.65,axisHeight]);
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

%% Format Log
prompt0 = "Name of Log File Needing Reformatting[Enter to Skip]: ";
txt = input(prompt0,"s");
     if ~isempty(txt)
         %read in values
         var_names = readtable('Variables.txt');
         var_names = var_names.Properties.VariableNames;
         data = readtable(txt);
         
         param_idx = zeros(1,length(var_names));
         for n = 1:length(var_names)
            param_idx(n) = find(string(data.Properties.VariableNames) == var_names(n));
         end
         
         param_idx = setdiff([1:length(data.Properties.VariableNames)], param_idx);
         data = removevars(data,param_idx);
         data = renamevars(data, var_names, {'lap_number', 'lap_time', 'speed', 'rpm', ...
                        'brake', 'throttle', 'latg', 'longg', 'zg', 'time', 'yaw'});
         writetable(data, strcat(txt,'_ddt','.txt'));
     end
%% Log/Lap Data Request

for n = 1:2
%Request Log File
    prompt1 = "Name of Log File[Enter to Close]: ";
    txt = input(prompt1,"s");
    if isempty(txt)
%          %plot map marker
%          mapMark = plot(ypos(1), xpos(1), 'ro', 'linewidth', 2);
% 
%          MovingVerticalLine(f1, axs_SPEED, axs_THROTTLE, axs_BRAKE, axs_RPM, axs_GFORCE1, axs_map, data_pile1, data_pile2, infoBox, mapMark)
         return;
    else
         data = readtable(txt);
    end
     
%request lap number
    prompt2 = "Lap Number[Enter For Fastest Lap]: ";
    input_lap_num = input(prompt2);
    
%Determining Fastest Lap
    if isempty(input_lap_num)
        lap_idx = find_fastest_lap(data.lap_time, data.lap_number);
    else
        lap_idx = find(data.lap_number == input_lap_num);
    end
    
%CONCATENATE DATA AND TRACK TABLES
    track = trackDecomposition(data.time(lap_idx), data.speed(lap_idx), data.yaw(lap_idx));

%% Plot Data
    set(0, 'currentfigure', f1)
    set(f1, 'currentaxes', axs_THROTTLE); 
    hold on
    plot(data.time(lap_idx) - data.time(lap_idx(1)), data.throttle(lap_idx));

    set(f1, 'currentaxes', axs_SPEED); 
    hold on
    plot(data.time(lap_idx) - data.time(lap_idx(1)),data.speed(lap_idx));

    set(f1, 'currentaxes', axs_RPM);
    hold on
    plot(data.time(lap_idx) - data.time(lap_idx(1)),data.rpm(lap_idx));

    set(f1, 'currentaxes', axs_BRAKE);
    hold on
    plot(data.time(lap_idx) - data.time(lap_idx(1)),data.brake(lap_idx));

    set(f1, 'currentaxes', axs_GFORCE1);
    hold on
    GForceP = smoothdata(sqrt((data.latg(lap_idx)).^2 + (data.longg(lap_idx)).^2 + (data.zg(lap_idx)).^2), 'gaussian');
    plot(data.time(lap_idx) - data.time(lap_idx(1)),GForceP);

    set(0,'currentFigure', f1);
    set(f1, 'currentaxes', axs_map);
    hold on
    plot(track.ypos_m, track.xpos_m);

%% Data Pile
    
    if n == 1
        data_pile1 = [data.speed(lap_idx), data.throttle(lap_idx), data.brake(lap_idx), data.rpm(lap_idx), GForceP, data.time(lap_idx) - data.time(lap_idx(1))]; %, , dist, xpos, ypos];
        data_pile2 = zeros(size(data_pile1));
    elseif n == 2
        data_pile2 = [data.speed(lap_idx), data.throttle(lap_idx), data.brake(lap_idx), data.rpm(lap_idx), GForceP, data.time(lap_idx) - data.time(lap_idx(1))];
    end

    MovingVerticalLine (f1, axs, data_pile1, data_pile2, infoBox);
    hlink = linkprop(axs,'xlim');

end

%% Functions
function [lap_idx] = find_fastest_lap(lap_time, lap_number)
    %Fastest Lap Time/Number
    P_fastestLap_time = min(lap_time(lap_time > (mean(lap_time) - 7)));
    P_fastestLap_num = find(lap_time == P_fastestLap_time);
    P_fastestLap_num = lap_number(P_fastestLap_num(1)) - 1;
    
    %Fastest Lap Index
    lap_idx = find(lap_number == P_fastestLap_num);
    disp(P_fastestLap_time) 
    disp(P_fastestLap_num)
end


function MovingVerticalLine (Fig, axs, data_c1, data_c2, txtBox)

    %vars
    VertLineWidth = 1.5;
    %currentPoint = axs(1).CurrentPoint;
    Fig.UserData = 0;

    VertLine1 = xline(axs(1), 0, 'LineWidth', 0.1);
    VertLine2 = xline(axs(2), 0, 'LineWidth', 0.1);
    VertLine3 = xline(axs(3), 0, 'LineWidth', 0.1);
    VertLine4 = xline(axs(4), 0, 'LineWidth', 0.1);
    VertLine5 = xline(axs(5), 0, 'LineWidth', 0.1);
    VertMarker1 = xline(axs(1), 0, 'LineWidth', 0.1);
    VertMarker2 = xline(axs(1), 0, 'LineWidth', 0.1);
    VertMarker3 = xline(axs(1), 0, 'LineWidth', 0.1);
    VertMarker4 = xline(axs(1), 0, 'LineWidth', 0.1);
    VertMarker5 = xline(axs(1), 0, 'LineWidth', 0.1);

    set(Fig,'WindowButtonDownFcn', @mouseDown);
    set(Fig, 'KeyPressFcn', @translateLine);

    function mouseDown(hObject,~)
        
        % is the mouse down event within the axes?
        if IsCursorInControl(hObject, axs(1))
        
            currentPoint = get(axs(1),'CurrentPoint');
            xCurrentPoint = currentPoint(2,1);
        
        elseif IsCursorInControl(hObject, axs(2))
        
            currentPoint = get(axs(2),'CurrentPoint');
            xCurrentPoint = currentPoint(2,1);
            
         elseif IsCursorInControl(hObject, axs(3))
        
            currentPoint = get(axs(3),'CurrentPoint');
            xCurrentPoint = currentPoint(2,1);
            
         elseif IsCursorInControl(hObject, axs(4))
        
            currentPoint = get(axs(4),'CurrentPoint');
            xCurrentPoint = currentPoint(2,1);
            
         elseif IsCursorInControl(hObject, axs(5))
        
            currentPoint = get(axs(5),'CurrentPoint');
            xCurrentPoint = currentPoint(2,1);
            
        end

        renderVertLine(xCurrentPoint);
        
        txtBox = renderTxtBox(hObject, xCurrentPoint, data_c1, data_c2, txtBox);
        %marker = renderMapMark(hObject, axs(6), xCurrentPoint, data_c1, marker);

        hObject.UserData = xCurrentPoint;      

    end

    function [status] = IsCursorInControl(hCursor, hControl)
        
        status = false;
        
        % get the position of the mouse
        figCurrentPoint = get(hCursor, 'CurrentPoint');
        position      = get(hCursor, 'Position');
        xCursor       = figCurrentPoint(1,1)/position(1,3); % normalize
        yCursor       = figCurrentPoint(1,2)/position(1,4); % normalize

        % get the position of the axes within the GUI
        controlPos = get(hControl,'Position');
        minx    = controlPos(1);
        miny    = controlPos(2);
        maxx    = minx + controlPos(3);
        maxy    = miny + controlPos(4);
            
        % is the mouse down event within the axes?
        if xCursor >= minx && xCursor <= maxx && yCursor >= miny && yCursor <= maxy
            status = true;
        end
    end

    function translateLine(src, event)
        
        xCurrentPoint = src.UserData;
        jumpDistMajor = 1;
        jumpDistMinor = .2;
        
        if strcmp(event.Key,'rightarrow')
            xCurrentPoint = xCurrentPoint + jumpDistMajor;
            renderVertLine(xCurrentPoint);
            
        elseif strcmp(event.Key,'leftarrow')
            xCurrentPoint = xCurrentPoint - jumpDistMajor;
            renderVertLine(xCurrentPoint);
            
        elseif strcmp(event.Key,'uparrow')
            xCurrentPoint = xCurrentPoint + jumpDistMinor;
            renderVertLine(xCurrentPoint);
            
        elseif strcmp(event.Key,'downarrow')
            xCurrentPoint = xCurrentPoint - jumpDistMinor;
            renderVertLine(xCurrentPoint);

        elseif strcmp(event.Key,'space')
            renderVertMarker(xCurrentPoint); 

        elseif strcmp(event.Key,'escape')
            delete(VertMarker1);
            delete(VertMarker2);
            delete(VertMarker3);
            delete(VertMarker4);
            delete(VertMarker5);
        end
        
        src.UserData = xCurrentPoint;
        
        txtBox = renderTxtBox(src, xCurrentPoint, data_c1, data_c2, txtBox);
        %marker = renderMapMark(src, axs(6), xCurrentPoint, data_c1, marker);
    end

    function renderVertLine(xCurrentPoint)
        delete(VertLine1);
        delete(VertLine2);
        delete(VertLine3);
        delete(VertLine4);
        delete(VertLine5);
        VertLine1 = xline(axs(1), xCurrentPoint, ':w', 'LineWidth', VertLineWidth);
        VertLine2 = xline(axs(2), xCurrentPoint, ':w', 'LineWidth', VertLineWidth);
        VertLine3 = xline(axs(3), xCurrentPoint, ':w', 'LineWidth', VertLineWidth);
        VertLine4 = xline(axs(4), xCurrentPoint, ':w', 'LineWidth', VertLineWidth);
        VertLine5 = xline(axs(5), xCurrentPoint, ':w', 'LineWidth', VertLineWidth);
    end

    function renderVertMarker(xCurrentPoint)
        if (axs(1).Children(1).Color(2) == 0.65 || axs(1).Children(2).Color(2) == 0.65)
            delete(VertMarker1);
            delete(VertMarker2);
            delete(VertMarker3);
            delete(VertMarker4);
            delete(VertMarker5);
        end
        
        VertMarker1 = xline(axs(1), xCurrentPoint, ':', 'LineWidth', VertLineWidth, 'Color',[1 0.65 0]);
        VertMarker2 = xline(axs(2), xCurrentPoint, ':', 'LineWidth', VertLineWidth, 'Color',[1 0.65 0]);
        VertMarker3 = xline(axs(3), xCurrentPoint, ':', 'LineWidth', VertLineWidth, 'Color',[1 0.65 0]);
        VertMarker4 = xline(axs(4), xCurrentPoint, ':', 'LineWidth', VertLineWidth, 'Color',[1 0.65 0]);
        VertMarker5 = xline(axs(5), xCurrentPoint, ':', 'LineWidth', VertLineWidth, 'Color',[1 0.65 0]);

    end

    function outBox = renderTxtBox(fig, xCurrentPoint, data1, data2, txtBox)
        xCurrentPoint = interp1(data1(:,6), 1:length(data1(:,6)),xCurrentPoint,'nearest');
        delete(txtBox);
        txtBox_str = {['Speed_1: ', num2str(data1(xCurrentPoint, 1))],...
                      ['Speed_2: ', num2str(data2(xCurrentPoint, 1))],...
                      ['Throttle_1: ', num2str(data1(xCurrentPoint, 2))],...
                      ['Throttle_2: ', num2str(data2(xCurrentPoint, 2))],...
                      ['Brake_1: ', num2str(data1(xCurrentPoint, 3))],...
                      ['Brake_2: ', num2str(data2(xCurrentPoint, 3))],...
                      ['RPM_1: ', num2str(data1(xCurrentPoint, 4))],...
                      ['RPM_2: ', num2str(data2(xCurrentPoint, 4))],...
                      ['GForce_1: ', num2str(data1(xCurrentPoint, 5))],...
                      ['GForce_2: ', num2str(data2(xCurrentPoint, 5))]};
        txtBox_dim = [.815 .775 .7 .2];
        txtBox_color = [1 1 1];
        outBox = annotation(fig, 'textbox',txtBox_dim,'String',txtBox_str,'FitBoxToText','on', 'color', txtBox_color, 'edgecolor', txtBox_color, 'FontSize', 11);
       
    end
    
    function outMark = renderMapMark(fig, axs, xCurrentPoint, data1, marker)
        delete(marker)
        xCurrentPoint = data(interp1(data1(:,6), 1:length(data1(:,6)),xCurrentPoint),6);
        set(0,'CurrentFigure', fig);
        set(fig, "CurrentAxes", axs);
        outMark = plot(data1(xCurrentPoint, 8), data1(xCurrentPoint, 7), 'ro', 'linewidth', 2);
    end

end

function trackDetails = trackDecomposition(time, velocity, yawVel)

    velocity = velocity*(1609.34/3600);                             % m/s
    %yawVel = yawVel(lapNum_index)*(3.1415/180);                     % rad/s

    numVals = length(time);
    vehicleHeading = zeros(numVals,1);
    xpos = zeros(numVals,1);
    ypos = zeros(numVals,1);   

    % first pass of vehicle heading
    for t = 2:numVals
        prevHeading = vehicleHeading(t-1);  % rad
        timeDelta = time(t) - time(t-1);    % s
        vehicleHeading(t) = prevHeading + yawVel(t)*timeDelta;
    end

    % correct vehicle heading


    % calculate xpos and ypos
    for t = 2:numVals
        timeDelta = time(t) - time(t-1);
        vehicleHeading(t) = vehicleHeading(t);
        avgHeading = (vehicleHeading(t)+vehicleHeading(t-1))/2;
        xpos(t) = xpos(t-1) + velocity(t)*cos(avgHeading)*timeDelta;
        ypos(t) = ypos(t-1) + velocity(t)*sin(avgHeading)*timeDelta;

    end

    dx = xpos(numVals) - xpos(1);
    dy = ypos(numVals) - ypos(1);

    for n = 1:numVals
        xpos(n) = xpos(n) - (dx/numVals)*n;
        ypos(n) = ypos(n) - (dy/numVals)*n;
    end


    % format the output
    trackDetails = [vehicleHeading(:,1), xpos(:,1), ypos(:,1)];
    varNames = ["vehicleHeading", "xpos_m", "ypos_m"];
    trackDetails = array2table(trackDetails);
    trackDetails.Properties.VariableNames = varNames;
    
end