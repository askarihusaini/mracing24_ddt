classdef mr25_data_visualizer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        PUBLIC_VER = 'v2.2.0';
        PRIVATE_VER = 'dev-25.06.19.2';
       
        MRacingDDT               matlab.ui.Figure
        miguel_quote             matlab.ui.control.Label
        export_data_check        matlab.ui.control.CheckBox
        plot_wrt_group           matlab.ui.container.ButtonGroup
        distance_button          matlab.ui.control.ToggleButton
        time_button              matlab.ui.control.ToggleButton
        yaw_deg_check            matlab.ui.control.CheckBox
        lat_pos_check            matlab.ui.control.CheckBox
        long_pos_check           matlab.ui.control.CheckBox
        yaw_rate_check           matlab.ui.control.CheckBox
        lat_gs_check             matlab.ui.control.CheckBox
        long_gs_check            matlab.ui.control.CheckBox
        brake_bias_check         matlab.ui.control.CheckBox
        vehicle_speed_check      matlab.ui.control.CheckBox
        rr_speed_check           matlab.ui.control.CheckBox
        rl_speed_check           matlab.ui.control.CheckBox
        fr_speed_check           matlab.ui.control.CheckBox
        fl_speed_check           matlab.ui.control.CheckBox
        read_brakes_check        matlab.ui.control.CheckBox
        front_brakes_check       matlab.ui.control.CheckBox
        brake_position_check     matlab.ui.control.CheckBox
        throttle_position_check  matlab.ui.control.CheckBox
        distance_check           matlab.ui.control.CheckBox
        time_check               matlab.ui.control.CheckBox
        variables_header         matlab.ui.control.Label
        LapBLabel                matlab.ui.control.Label
        Lap1Label                matlab.ui.control.Label
        lapB_edit                matlab.ui.control.NumericEditField
        lapA_edit                matlab.ui.control.NumericEditField
        file_label               matlab.ui.control.Label
        upload_log_button        matlab.ui.control.Button
        log_file_header          matlab.ui.control.Label
        github_link              matlab.ui.control.Hyperlink
        version_label            matlab.ui.control.Label
        ddvt_header              matlab.ui.control.Label
        mracing_logo             matlab.ui.control.Image
        run_visualizer_button    matlab.ui.control.Button
        Image                    matlab.ui.control.Image
    end

    
    properties (Access = private)
        NUM_CHECKBOXES = 16; % For checkbox_states.mat size
        file = "";
        location = "";
        wrt_time
        smallArrowKeyIncrement = 0.1;
        arrowKeyIncrement = 1;
        clickedX
        vlines
        PRECISION = 3; % Decimal places
        infoBox_data
        infoBox_text_1
        infoBox_text_2
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: run_visualizer_button
        function run_visualizer(app, event)
            
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % No file submitted lol
            if app.file == ""
                msgbox("Error: No file uploaded... how did you mess that up bro", ...
                        "Error")
                return
            end

            w = warning ('off','all');
            msg = msgbox("Loading log data...", "Please wait :)");

            % %% Reformat file
            % if get(app.reformat_file_check, 'Value') == 1
            %     % These are the variables we want to keep in the reformatted file
            %     % Make sure 'variables_select' has no carriage returns (\r)!!!!
            %     relevant_vars = fileread(fullfile(pathToMLAPP, 'mr25_app_resources', 'variables_relevant.txt'));
            %     relevant_vars = strsplit(relevant_vars, '\n');
            % 
            %     % readtable replaces [ ] / with _ and removes whitespace
            %     relevant_vars = strrep(relevant_vars, '[', '_');
            %     relevant_vars = strrep(relevant_vars, ']', '_');
            %     relevant_vars = strrep(relevant_vars, '/', '_');
            %     relevant_vars = strrep(relevant_vars, '°', '_');
            %     relevant_vars = strrep(relevant_vars, ' ', '');
            % 
            %     data = readtable([app.location, app.file]);
            %     data = data(:,relevant_vars);
            % 
            %     % Funky stuff for tire temps
            % 
            % 
            %     % Throttle and brake percentages arent actual percentages lol
            %     throttle_max = max(data{:,"Pedals_APS_A_percent_"});
            %     brake_max = max(data{:,"Pedals_APS_B_percent_"});
            %     data{:,"Pedals_APS_A_percent_"} = data{:,"Pedals_APS_A_percent_"} / throttle_max;
            %     data{:,"Pedals_APS_B_percent_"} = data{:,"Pedals_APS_B_percent_"} / brake_max;
            % 
            % 
            %     % create new file with same name + ddt_
            %     writetable(data, strcat(app.location, replace(strcat("ddt_", app.file), ".txt", ".csv")));
            % else
            %     data = readtable([app.location, app.file]);
            % end

            %% Load .mat
            load('C:\Users\askar\docs\MATLAB\mracing24_ddt\mr25_log_data\log_2025-06-01_0540_comp.mat', 'signal_names', 'signals', 'time');
            data = array2table(signals, VariableNames=signal_names);
            data.("elapsed_time") = time';

            % Throttle and brake percentages arent actual percentages lol
            throttle_max = max(data{:,"Pedals.APS_A"});
            brake_max = max(data{:,"Pedals.APS_B"});
            data{:,"Pedals.APS_A"} = data{:,"Pedals.APS_A"} / throttle_max;
            data{:,"Pedals.APS_B"} = data{:,"Pedals.APS_B"} / brake_max;

            %% Grab the variable data of the checkbox ones
            % This is important because of how we index through the
            % checkbox variables
            % Again, MAKE SURE NO \r!!! Only \n!!!!
            checkbox_vars = fileread(fullfile(pathToMLAPP, 'mr25_app_resources', 'variables_checkbox.txt'));
            checkbox_vars = strsplit(checkbox_vars, '\n');
            checkbox_vars = strrep(checkbox_vars, '[', '_');
            checkbox_vars = strrep(checkbox_vars, ']', '_');
            checkbox_vars = strrep(checkbox_vars, '/', '_');
            checkbox_vars = strrep(checkbox_vars, '°', '_');
            checkbox_vars = strrep(checkbox_vars, ' ', '');
            data_checkbox = data(:, checkbox_vars);
            % There's a better way to do this using replace() lol

            %% Grab min & max lap and user inputted laps
            lap_min = data{1, "Dash_3.Lap_Number"};
            lap_max = data{end, "Dash_3.Lap_Number"};
            lapA = app.lapA_edit.Value;
            lapB = app.lapB_edit.Value;

            %% Default lap A and B
            if (isempty(lapA))
                lapA = false;
            end
            if (isempty(lapB))
                lapB = false;
            end

            % Error message if segmentation fault
            if ((lapA < lap_min && lapA ~= false) || lapA > lap_max || ...
                    (lapB < lap_min && lapB ~= false) || lapB > lap_max)
                delete(msg)
                msgbox(["Error: Lap number out of bounds", ...
                        "Lap number must be between " + lap_min + " and " + lap_max], ...
                        "Error")
                return
            end
           
            %% Tire temps
            % Append 12 more columns in the data for tire temps calculated
            % as averages of multiple channels for each tire. Then
            % hopefully it'll just work with the rest of the code as long
            % as i format stuff correctly ?!!!!

            %% Which variables to plot?
            
            % Needs to be in same order as in log file
            axis_checkboxes = [app.fl_speed_check, app.fr_speed_check, app.rl_speed_check, app.rr_speed_check, ...
                            app.vehicle_speed_check, app.brake_bias_check, ...
                            app.throttle_position_check, app.brake_position_check, app.front_brakes_check, app.read_brakes_check, ...
                            app.lat_gs_check, app.long_gs_check, app.yaw_rate_check, app.yaw_deg_check, ...
                            app.distance_check, app.time_check];

            % Vector of each variable's data/name
            axis_names = string(size(axis_checkboxes));
            axis_values = zeros(size(axis_checkboxes));
            for i = 1:size(axis_checkboxes, 2)
                txt = convertCharsToStrings(get(axis_checkboxes(i), 'Text'));
                value = get(axis_checkboxes(i), 'Value');
                axis_names(i) = txt;
                if value
                    axis_values(i) = 1;
                end
            end

            % Write axis_values to checkbox_memory.txt
            save(fullfile(pathToMLAPP, 'mr25_app_resources', 'checkbox_states.mat'), "axis_values");

            % Checkbox variables filtered to only those selected
            selected_vars = 1:size(axis_checkboxes, 2);
            selected_vars = transpose(nonzeros(selected_vars .* axis_values));
            NUM_VARS = size(selected_vars,2);

            if NUM_VARS == 0
                delete(msg)
                msgbox("Error: No variables selected to display", ...
                        "Error")
                return
            end

            app.wrt_time = get(app.time_button, "Value");

            % Grabbing lap-specific data and domain ranges
            lapB_x = 0;
            lapB_selected_data = 0;
            % Grab data w.r.t. all laps if no lap inputted
            if lapA == false
                if app.wrt_time
                    lapA_x = data{:,"elapsed_time"};
                else
                    lapA_x = data{:,"Veh_Status.DistanceDriven"};
                end
                lapA_selected_data = data_checkbox{:, selected_vars}';

            % Else, do it to specific laps(s)
            else
                lapA_data = data(data.Dash_3_Lap_Number_None_ == lapA, :);
                if lapB
                    lapB_data = data(data.Dash_3_Lap_Number_None_ == lapB, :);
                end

                % Normalize laps so time & distance always starts at 0
                lapA_data{:,"elapsed_time"} = lapA_data{:,"elapsed_time"} - lapA_data{1,"elapsed_time"};
                if lapB
                    lapB_data{:,"elapsed_time"} = lapB_data{:,"elapsed_time"} - lapB_data{1,"elapsed_time"};
                end

                lapA_data{:,"Veh_Status.DistanceDriven"} = lapA_data{:,"Veh_Status.DistanceDriven"} - lapA_data{1,"Veh_Status.DistanceDriven"};
                if lapB
                    lapB_data{:,"Veh_Status.DistanceDriven"} = lapB_data{:,"Veh_Status.DistanceDriven"} - lapB_data{1,"Veh_Status.DistanceDriven"};
                end

                % New variable just for domain
                if app.wrt_time
                    lapA_x = lapA_data{:,"elapsed_time"};
                    if lapB
                        lapB_x = lapB_data{:,"elapsed_time"};
                    end
                else
                    lapA_x = lapA_data{:,"Veh_Status.DistanceDriven"};
                    if lapB
                        lapB_x = lapB_data{:,"Veh_Status.DistanceDriven"};
                    end
                end
    
                % Selected variables, but for specific laps
                lapA_data_checkbox = lapA_data(:, checkbox_vars);
                lapA_selected_data = lapA_data_checkbox{:, selected_vars}';
                if lapB
                    lapB_data_checkbox = lapB_data(:, checkbox_vars);
                    lapB_selected_data = lapB_data_checkbox{:, selected_vars}';
                end
            end

            % This is useful when we need domains to be compatible
            if size(lapA_x,1) > size(lapB_x,1)
                full_x = lapA_x;
            else
                full_x = lapB_x;
            end
            full_lapA_selected_data = resize(lapA_selected_data, [NUM_VARS, size(full_x,1)], Pattern="edge"); % Is edge the best??? Or 0???
            full_lapB_selected_data = resize(lapB_selected_data, [NUM_VARS, size(full_x,1)], Pattern="edge");

            plot_distance_variance = app.wrt_time && axis_values(2) == 1 && lapB;

            %% Variance
            % plot_variances = get(app.variance_check, "Value");
            % if plot_variances && ~lapB
            %     delete(msg)
            %     msgbox("Error: Input a second lap to display variance", ...
            %             "Error")
            %     return
            % end
            % if plot_variances && ~app.wrt_time
            %     delete(msg)
            %     msgbox("Error: Variance display only works when plotting w.r.t time", ...
            %             "Error")
            %     return
            % end
            % % NOTE: The issue with variance when plotting w.r.t time is
            % % that there doesnt exist a function between distance and the
            % % variables. This is because the log data grabs values of each
            % % sensor ever 0.01 seconds, but this means the car can have the
            % % same distance value for multiple instances of time. As a
            % % result, we can't just subtract the two laps from eachother as
            % % their domains don't match (i.e. lap A will have the car at 5m
            % % for three logs, but lap B will have the car at 5m for four
            % % logs, so which values do we subtract?) In the future, this
            % % can probably be fixed by scrapping all log instances but one
            % % for each x value to make a function.
            %
            % if plot_variances
            %     variance_size = max(size(lapA_selected_data, 2), size(lapB_selected_data, 2));
            %     variance_lapA = resize(lapA_selected_data, [NUM_VARS, variance_size], Pattern="edge"); % Is edge the best??? Or 0???
            %     variance_lapB = resize(lapB_selected_data, [NUM_VARS, variance_size], Pattern="edge");
            % end

            %% Exporting Visualized Data
            % full_x, lapA_selected_data, lapB_selected_data

            if get(app.export_data_check, 'Value') == 1
                if lapB
                    exported_data = cat(2, full_x, full_lapA_selected_data', full_lapB_selected_data');
                else
                    exported_data = cat(2, full_x, full_lapA_selected_data');
                end
    
                % Duplicate columns for two laps
                if lapB
                    VariableNames = {'Time (s)', axis_names{selected_vars}, axis_names{selected_vars}};
                else
                    VariableNames = {'Time (s)', axis_names{selected_vars}};
                end
    
                % If we need to actually denote which lap the data comes from
                if lapA
                    for i = 2:NUM_VARS+1
                        VariableNames{i} = strcat('Lap', num2str(lapA), '_', VariableNames{i});
                        if lapB
                            VariableNames{i+NUM_VARS} = strcat('Lap', num2str(lapB), '_', VariableNames{i+NUM_VARS});
                        end
                    end
                end
                if ~app.wrt_time
                    VariableNames{1} = 'Distance (m)';
                end
                exported_table = array2table(exported_data, 'VariableNames', VariableNames);

                % Make it named nicely (???? lol kinda nice but ugly)
                exported_file = strcat("vizdata_", app.file);
                exported_file = replace(exported_file, {'.txt', '.csv'}, {'', ''});

                if app.wrt_time
                    exported_file = strcat(exported_file, "wrttime_");
                else
                    exported_file = strcat(exported_file, "wrtdist_");
                end

                if lapB
                    exported_file = strcat(exported_file, "_lap", num2str(lapA), "_lap", num2str(lapB));
                elseif lapA
                    exported_file = strcat(exported_file, "_lap", num2str(lapA));
                else
                    exported_file = strcat(exported_file, "_full");
                end

                exported_file = strcat(exported_file, "_", axis_names{selected_vars}, ".csv");
                exported_file = eraseBetween(exported_file, '(', ')');
                exported_file = replace(exported_file, {' ', '(', ')'}, {'', '', '_'});

                % Write it
                writetable(exported_table, strcat(app.location, exported_file));

            end
            
            %% Plot!
            set(findobj(msg,'Tag','MessageBox'),'String', 'Generating figure...')

            figureColor = [.94,.94,.94];
            tileColor = [.9,.9,.9];
            textColor = [0,0,0];
            outlineColor = [0,0,0];
            lapAColor = [235/255, 52/255, 52/255];
            lapBColor = [52/255, 128/255, 235/255];
            varianceColor = [128/255, 52/255, 235/255];
            ylineColor = [.5,.5,.5];
            lineWidth = 1.25;
            % Vertical line color defined in below function
            set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{outlineColor,outlineColor,outlineColor})
            
            f1 = uifigure('color', figureColor);

            % OVERVIEW OF TILING
            % Tile 1: All plots
            %   Tile 1x: Each plot within tile 1 is its own unique tile
            % Tile 2: Right hand side
            %   Tile 2A: Info box
            %     2Ai: Lap A info
            %     2Aii: Lap B info
            %   Tile 2B: GG diagram
            %   Tile 2C: Track map (TODO)
            
            % T Layout
            T = tiledlayout(f1, 1,3, "TileSpacing", "compact", "Padding", "compact");
            
            % T1 Layout: Graphs of variables
            t1 = tiledlayout(T, "vertical", "TileSpacing", "compact", "Padding", "compact");
            t1.Layout.Tile = 1;
            t1.Layout.TileSpan = [1,2];

            % T1x: Individual graphs of variables
            for i = 1:NUM_VARS
                ax = nexttile(t1);
                hold(ax, "on");
                p1 = plot(ax, lapA_x, lapA_selected_data(i,:), "Color", lapAColor, 'LineWidth', lineWidth);
                if lapB
                    p2 = plot(ax, lapB_x, lapB_selected_data(i,:), "Color", lapBColor, 'LineWidth', lineWidth);
                end
                hold(ax, "off");
                yline(ax, 0, "Color", ylineColor);
            
                % Configure HitTest and PickableParts
                p1.HitTest = "off";
                if lapB
                    p2.HitTest = "off";
                end
                ax.PickableParts = "all";
                ax.HitTest = "on";
            
                ax.XGrid = "on";
                ax.YGrid = "on";
                ax.XMinorGrid = "on";
                ax.YMinorGrid = "on";
                ax.Color = tileColor;
                xticklabels(ax, "");
                ax.YLabel.String = axis_names(selected_vars(i));

                set(ax, 'XLim', [0, max(max(lapA_x), max(lapB_x))]);
            
                % Add to plot_axes so we can link them all after the fact
                plot_axes(i) = ax;

                % If this iteration is plotting distance w.r.t time between 2 laps...
                if selected_vars(i) == 2 && plot_distance_variance
                    ax = nexttile(t1);

                    % resized_lapA_dist = resize(lapA_data{:,"Veh_Status.DistanceDriven"}', [1, size(full_x, 1)], Pattern="edge"); % Is edge the best??? Or 0???
                    % resized_lapB_dist = resize(lapB_data{:,"Veh_Status.DistanceDriven"}', [1, size(full_x, 1)], Pattern="edge");

                    plot(ax, full_x, full_lapB_selected_data(i,:) - full_lapA_selected_data(i,:), "Color", varianceColor, 'LineWidth', lineWidth);
                    yline(ax, 0, "Color", ylineColor);

                    ax.XGrid = "on";
                    ax.YGrid = "on";
                    ax.XMinorGrid = "on";
                    ax.YMinorGrid = "on";
                    ax.Color = tileColor;
                    xticklabels(ax, "");
                    ax.YLabel.String = "Variance (m)";

                    % Same distance above and below horizontal axis
                    YL = get(ax, 'YLim');
                    maxlim = max(abs(YL));
                    set(ax, 'YLim', [-maxlim maxlim]);
                    set(ax, 'XLim', [0, max(max(lapA_x), max(lapB_x))]);

                    % Similar for linking
                    variance_axis = ax;
                end

                % if plot_variances
                %     ax = nexttile(t1);
                % 
                %     plot(ax, full_x, variance_lapB(i,:) - variance_lapA(i,:), "Color", varianceColor);
                %     yline(ax, 0, "Color", ylineColor);
                % 
                %     ax.XGrid = "on";
                %     ax.YGrid = "on";
                %     ax.XMinorGrid = "on";
                %     ax.YMinorGrid = "on";
                %     ax.Color = tileColor;
                %     xticklabels(ax, "");
                %     ax.YLabel.String = "Variance";
                % 
                %     % Same distance above and below horizontal axis
                %     YL = get(ax, 'YLim');
                %     maxlim = max(abs(YL));
                %     set(ax, 'YLim', [-maxlim maxlim]);
                % 
                %     % Similar for linking
                %     variance_axes(i) = ax
                % end

            end

            xticklabels(ax, "auto"); % Enable tick labels for bottom graph
            %ax.XTickLabelRotation = 90;
            if app.wrt_time
                ax.XLabel.String = "Time (s)";
            else
                ax.XLabel.String = "Distance (m)";
            end

            % Link all axes
            if plot_distance_variance
                linkaxes([plot_axes, variance_axis], 'x')
            else
                linkaxes(plot_axes, 'x')
            end
            % if plot_variances
            %     linkaxes([plot_axes, variance_axes], 'x')
            % else
            %     linkaxes(plot_axes, 'x')
            % end

            % Enable user input for each plot
            for i = 1:NUM_VARS
                ax = plot_axes(i);
                ax.ButtonDownFcn = @(src, event) handlePlotClick(app, event, full_x, lapA_selected_data, lapB_selected_data, lapB, NUM_VARS, axis_names, selected_vars, plot_axes);
            end
            
            % T2 Layout: Right hand side
            t2 = tiledlayout(T, 2,1, "TileSpacing", "compact", "Padding", "none");
            t2.Layout.Tile = 3;
            
            % T2A Layout: Info box
            ax = nexttile(t2, 1, [1,1]);
            ax.Visible = 0; % Make axes invisible for text display
            t2a = tiledlayout(t2, 1,2, "TileSpacing", "none", "Padding", "none");
            t2a.Layout.Tile = 1;
            
            % T2Ai & T2Aii: Lap A and Lap B info
            for i = [1,2]
                ax = nexttile(t2a, i, [1,1]);
                ax.XTick = [];
                ax.YTick = [];
                ax.Color = tileColor;
                ax.Box = "on";
            
                app.infoBox_data = zeros(2,NUM_VARS);
                if app.wrt_time
                    infoBox_string = "Lap " + i + ":\n@ t = " + 0 + "\n";
                else
                    infoBox_string = "Lap " + i + ":\n@ x = " + 0 + "\n";
                end
                for j = 1:NUM_VARS
                   infoBox_string = infoBox_string + axis_names(selected_vars(j)) + ": " + round(app.infoBox_data(i,j), app.PRECISION) + "\n";
                end
                infoBox_string = regexprep(infoBox_string, "%", "%%"); % % is an escape character
                
                if i == 1
                    app.infoBox_text_1 = text(ax, 0.05,.975,sprintf(infoBox_string), 'Horiz','left', 'Vert','top', ...
                    "Color", textColor, 'fontsize',5,'fontunits','normalized');
                else
                    app.infoBox_text_2 = text(ax, 0.05,.975,sprintf(infoBox_string), 'Horiz','left', 'Vert','top', ...
                    "Color", textColor, 'fontsize',5,'fontunits','normalized');
                end
            end
            
            % T2B: GG Diagram
            ax = nexttile(t2, 2, [1,1]);

            lat_g = data_checkbox{:, "VNAV_Accel_Corr.X_Corr"};
            long_g = data_checkbox{:, "VNAV_Accel_Corr.Y_Corr"};
            throttle_pos = data_checkbox{:, "Pedals.APS_A"};

            scatter(ax, lat_g, long_g, 20, throttle_pos, "Marker",".")
            ax.XGrid = "on";
            ax.YGrid = "on";
            ax.XMinorGrid = "on";
            ax.YMinorGrid = "on";
            ax.XDir = 'reverse';
            ax.Color = tileColor;
            ax.Box = "on";

            title(ax, "G-G Diagram");
            colorbar(ax);
            
            delete(msg)

            f1.KeyPressFcn = @(src, event) UIFigureKeyPressFcn(app, event, full_x, lapA_selected_data, lapB_selected_data, lapB, NUM_VARS, axis_names, selected_vars, plot_axes);
        end
        
        function handlePlotClick(app, event, full_x, lapA_selected_data, lapB_selected_data, lapB, NUM_VARS, axis_names, selected_vars, plot_axes)           
            % Get the click location
            clickPosition = event.IntersectionPoint;
            app.clickedX = clickPosition(1); % X-coordinate of the click

            generateVLine(app, event, full_x, lapA_selected_data, lapB_selected_data, lapB, NUM_VARS, axis_names, selected_vars, plot_axes)

            % % Debugging Purposes
            % disp(['x = ', num2str(clickedX)]

            % for i = 1:NUM_VARS
            %     if lapB
            %         disp([axis_names(selected_vars(i)), lapA_selected_data(i, idx), lapB_selected_data(i, idx)])
            %     else
            %         disp([axis_names(selected_vars(i)), lapA_selected_data(i, idx)])
            %     end
            % end
        end

        function UIFigureKeyPressFcn(app, event, full_x, lapA_selected_data, lapB_selected_data, lapB, NUM_VARS, axis_names, selected_vars, plot_axes)
            try
                % disp(event.Key) % Debugging
                switch event.Key
                    case 'leftarrow'
                        app.clickedX = app.clickedX - app.arrowKeyIncrement;
                    case 'rightarrow'
                        app.clickedX = app.clickedX + app.arrowKeyIncrement;
                    case 'comma'
                        app.clickedX = app.clickedX - app.smallArrowKeyIncrement;
                    case 'period'
                        app.clickedX = app.clickedX + app.smallArrowKeyIncrement;
                    otherwise
                        return
                end
                generateVLine(app, event, full_x, lapA_selected_data, lapB_selected_data, lapB, NUM_VARS, axis_names, selected_vars, plot_axes)
            catch
            end
        end

        function generateVLine(app, event, full_x, lapA_selected_data, lapB_selected_data, lapB, NUM_VARS, axis_names, selected_vars, plot_axes)
            vlineColor = [52/255, 235/255, 128/255];

            % Get domain index corresponding to the point clicked
            [~, idx] = min(abs(full_x - app.clickedX));
            
            % Delete old vertical line (if it exists) and replace it
            try
                delete(app.vlines)
            catch
            end
            for i = 1:size(plot_axes,2)
                app.vlines(i) = xline(plot_axes(i), app.clickedX, "Color", vlineColor, "LineWidth", 2);
            end

            % Grab data from plots at domain index
            for j = 1:NUM_VARS
                app.infoBox_data(1,j) = lapA_selected_data(j, idx);
                if lapB
                    app.infoBox_data(2,j) = lapB_selected_data(j, idx);
                end
            end
            
            % Update infobox string
            for i = [1,2]
                if app.wrt_time
                    infoBox_string = "Lap " + i + ":\n@ t = " + app.clickedX + "\n";
                else
                    infoBox_string = "Lap " + i + ":\n@ x = " + app.clickedX + "\n";
                end
                for j = 1:NUM_VARS
                   infoBox_string = infoBox_string + axis_names(selected_vars(j)) + ": " + round(app.infoBox_data(i,j), app.PRECISION) + "\n";
                end
                infoBox_string = regexprep(infoBox_string, "%", "%%"); % % is an escape character
                
                if i == 1
                    app.infoBox_text_1.String = sprintf(infoBox_string);
                else
                    app.infoBox_text_2.String = sprintf(infoBox_string);
                end
            end
        end

        % Button pushed function: upload_log_button
        function upload_file(app, event)
            dummy = figure('Renderer', 'painters', 'Position', [-100 -100 0 0]); % create a dummy figure so that uigetfile doesn't minimize our GUI
            [f, l] = uigetfile({'*.mat;'}, "Select log file");
            delete(dummy); % delete the dummy figure
            if isequal(f, 0)
                return
            else
                app.file = f;
                app.location = l;
                app.file_label.Text = strcat(app.location, app.file);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            pathToMLAPP = fileparts(mfilename('fullpath'));

            if isfile(fullfile(pathToMLAPP, 'mr25_app_resources', 'checkbox_states.mat')) % Check if file exists
                loadedData = load(fullfile(pathToMLAPP, 'mr25_app_resources', 'checkbox_states.mat'), 'axis_values'); % Load data
                checkbox_states = loadedData.axis_values; % Extract the variable
            else
                axis_values = zeros(1, app.NUM_CHECKBOXES); % Default state if no file exists
                save(fullfile(pathToMLAPP, 'mr25_app_resources', 'checkbox_states.mat'), "axis_values");
                checkbox_states = axis_values; % "Extract" the variable (its all just zeroes)
            end

            % Create MRacingDDT and hide until all components are created
            app.MRacingDDT = uifigure('Visible', 'off');
            app.MRacingDDT.Position = [100 100 480 720];
            app.MRacingDDT.Name = 'MRacing Driver Data Tool';

            % Create Image
            app.Image = uiimage(app.MRacingDDT);
            app.Image.Position = [1 1 480 720];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'mr25_app_resources', 'background.png');

            % Create run_visualizer_button
            app.run_visualizer_button = uibutton(app.MRacingDDT, 'push');
            app.run_visualizer_button.ButtonPushedFcn = createCallbackFcn(app, @run_visualizer, true);
            app.run_visualizer_button.BackgroundColor = [0 0.149 0.302];
            app.run_visualizer_button.FontSize = 14;
            app.run_visualizer_button.FontWeight = 'bold';
            app.run_visualizer_button.FontColor = [1 0.8 0.0196];
            app.run_visualizer_button.Position = [20 20 120 30];
            app.run_visualizer_button.Text = 'Run Visualizer';

            % Create mracing_logo
            app.mracing_logo = uiimage(app.MRacingDDT);
            app.mracing_logo.Position = [20 620 300 80];
            app.mracing_logo.ImageSource = fullfile(pathToMLAPP, 'mr25_app_resources', 'mracing_logo.png');

            % Create ddvt_header
            app.ddvt_header = uilabel(app.MRacingDDT);
            app.ddvt_header.FontName = 'Century Gothic';
            app.ddvt_header.FontSize = 18;
            app.ddvt_header.FontWeight = 'bold';
            app.ddvt_header.FontColor = [0 0.149 0.302];
            app.ddvt_header.Position = [20 590 305 24];
            app.ddvt_header.Text = 'DRIVER DATA VISUALIZATION TOOL';

            % Create version_label
            app.version_label = uilabel(app.MRacingDDT);
            app.version_label.HorizontalAlignment = 'right';
            app.version_label.FontName = 'Century Gothic';
            app.version_label.FontColor = [0.502 0.502 0.502];
            app.version_label.Position = [375 656 85 44];
            app.version_label.Text = {'Askari Husaini'; app.PUBLIC_VER; app.PRIVATE_VER};

            % Create github_link
            app.github_link = uihyperlink(app.MRacingDDT);
            app.github_link.VisitedColor = [0.502 0.502 0.502];
            app.github_link.HorizontalAlignment = 'right';
            app.github_link.FontName = 'Century Gothic';
            app.github_link.FontColor = [0.502 0.502 0.502];
            app.github_link.URL = 'https://github.com/askarihusaini/mracing24_ddt';
            app.github_link.Position = [386 635 74 22];
            app.github_link.Text = 'Github repo';

            % Create log_file_header
            app.log_file_header = uilabel(app.MRacingDDT);
            app.log_file_header.FontName = 'Century Gothic';
            app.log_file_header.FontSize = 14;
            app.log_file_header.FontWeight = 'bold';
            app.log_file_header.FontColor = [0 0.149 0.302];
            app.log_file_header.Position = [20 540 206 25];
            app.log_file_header.Text = 'Log File & Lap(s) Analyzed';

            % Create upload_log_button
            app.upload_log_button = uibutton(app.MRacingDDT, 'push');
            app.upload_log_button.ButtonPushedFcn = createCallbackFcn(app, @upload_file, true);
            app.upload_log_button.BackgroundColor = [0.902 0.902 0.902];
            app.upload_log_button.FontSize = 10;
            app.upload_log_button.Position = [20 505 100 25];
            app.upload_log_button.Text = 'Upload log file';

            % Create file_label
            app.file_label = uilabel(app.MRacingDDT);
            app.file_label.FontSize = 10;
            app.file_label.Tooltip = {''};
            app.file_label.Position = [25 485 430 15];
            app.file_label.Text = 'No file selected';

            % Create lapA_edit
            app.lapA_edit = uieditfield(app.MRacingDDT, 'numeric');
            app.lapA_edit.RoundFractionalValues = 'on';
            app.lapA_edit.AllowEmpty = 'on';
            app.lapA_edit.FontSize = 10;
            app.lapA_edit.Placeholder = 'Default all';
            app.lapA_edit.Position = [170 507 80 21];
            app.lapA_edit.Value = [];

            % Create lapB_edit
            app.lapB_edit = uieditfield(app.MRacingDDT, 'numeric');
            app.lapB_edit.RoundFractionalValues = 'on';
            app.lapB_edit.AllowEmpty = 'on';
            app.lapB_edit.FontSize = 10;
            app.lapB_edit.Placeholder = 'Default ignore';
            app.lapB_edit.Position = [300 507 80 21];
            app.lapB_edit.Value = [];

            % Create Lap1Label
            app.Lap1Label = uilabel(app.MRacingDDT);
            app.Lap1Label.HorizontalAlignment = 'right';
            app.Lap1Label.FontSize = 10;
            app.Lap1Label.Position = [130 505 33 25];
            app.Lap1Label.Text = 'Lap A:';

            % Create LapBLabel
            app.LapBLabel = uilabel(app.MRacingDDT);
            app.LapBLabel.HorizontalAlignment = 'right';
            app.LapBLabel.FontSize = 10;
            app.LapBLabel.Position = [259 505 34 25];
            app.LapBLabel.Text = 'Lap B:';

            % Create variables_header
            app.variables_header = uilabel(app.MRacingDDT);
            app.variables_header.FontName = 'Century Gothic';
            app.variables_header.FontSize = 14;
            app.variables_header.FontWeight = 'bold';
            app.variables_header.FontColor = [0 0.149 0.302];
            app.variables_header.Position = [20 410 183 25];
            app.variables_header.Text = 'Variables to Visualize';

            % Create time_check
            app.time_check = uicheckbox(app.MRacingDDT);
            app.time_check.Text = 'Time (s)';
            app.time_check.FontSize = 10;
            app.time_check.Position = [335 317 58 22];
            app.time_check.Value = checkbox_states(1);

            % Create distance_check
            app.distance_check = uicheckbox(app.MRacingDDT);
            app.distance_check.Text = 'Distance (m)';
            app.distance_check.FontSize = 10;
            app.distance_check.Position = [335 338 79 22];
            app.distance_check.Value = checkbox_states(2);

            % Create throttle_position_check
            app.throttle_position_check = uicheckbox(app.MRacingDDT);
            app.throttle_position_check.Text = 'Throttle Position (%)';
            app.throttle_position_check.FontSize = 10;
            app.throttle_position_check.Position = [25 380 113 22];
            app.throttle_position_check.Value = checkbox_states(3);

            % Create brake_position_check
            app.brake_position_check = uicheckbox(app.MRacingDDT);
            app.brake_position_check.Text = 'Brake Position (%)';
            app.brake_position_check.FontSize = 10;
            app.brake_position_check.Position = [25 359 105 22];
            app.brake_position_check.Value = checkbox_states(4);

            % Create front_brakes_check
            app.front_brakes_check = uicheckbox(app.MRacingDDT);
            app.front_brakes_check.Text = 'Front Brakes (psi)';
            app.front_brakes_check.FontSize = 10;
            app.front_brakes_check.Position = [25 338 101 22];
            app.front_brakes_check.Value = checkbox_states(5);

            % Create read_brakes_check
            app.read_brakes_check = uicheckbox(app.MRacingDDT);
            app.read_brakes_check.Text = 'Rear Brakes (psi)';
            app.read_brakes_check.FontSize = 10;
            app.read_brakes_check.Position = [25 317 100 22];
            app.read_brakes_check.Value = checkbox_states(6);

            % Create fl_speed_check
            app.fl_speed_check = uicheckbox(app.MRacingDDT);
            app.fl_speed_check.Text = 'FL Tire Speed (rpm)';
            app.fl_speed_check.FontSize = 10;
            app.fl_speed_check.Position = [180 380 114 22];
            app.fl_speed_check.Value = checkbox_states(7);

            % Create fr_speed_check
            app.fr_speed_check = uicheckbox(app.MRacingDDT);
            app.fr_speed_check.Text = 'FR Tire Speed (rpm)';
            app.fr_speed_check.FontSize = 10;
            app.fr_speed_check.Position = [180 359 116 22];
            app.fr_speed_check.Value = checkbox_states(8);

            % Create rl_speed_check
            app.rl_speed_check = uicheckbox(app.MRacingDDT);
            app.rl_speed_check.Text = 'RL Tire Speed (rpm)';
            app.rl_speed_check.FontSize = 10;
            app.rl_speed_check.Position = [180 338 115 22];
            app.rl_speed_check.Value = checkbox_states(9);

            % Create rr_speed_check
            app.rr_speed_check = uicheckbox(app.MRacingDDT);
            app.rr_speed_check.Text = 'RR Tire Speed (rpm)';
            app.rr_speed_check.FontSize = 10;
            app.rr_speed_check.Position = [180 317 117 22];
            app.rr_speed_check.Value = checkbox_states(10);

            % Create vehicle_speed_check
            app.vehicle_speed_check = uicheckbox(app.MRacingDDT);
            app.vehicle_speed_check.Text = 'Vehichle Speed (mph)';
            app.vehicle_speed_check.FontSize = 10;
            app.vehicle_speed_check.Position = [335 380 120 22];
            app.vehicle_speed_check.Value = checkbox_states(11);

            % Create brake_bias_check
            app.brake_bias_check = uicheckbox(app.MRacingDDT);
            app.brake_bias_check.Text = 'Brake Bias (#)';
            app.brake_bias_check.FontSize = 10;
            app.brake_bias_check.Position = [335 359 85 22];
            app.brake_bias_check.Value = checkbox_states(12);

            % Create long_gs_check
            app.long_gs_check = uicheckbox(app.MRacingDDT);
            app.long_gs_check.Text = 'Longitudinal Gs (g)';
            app.long_gs_check.FontSize = 10;
            app.long_gs_check.Position = [25 286 106 22];
            app.long_gs_check.Value = checkbox_states(13);

            % Create lat_gs_check
            app.lat_gs_check = uicheckbox(app.MRacingDDT);
            app.lat_gs_check.Text = 'Lateral Gs (g)';
            app.lat_gs_check.FontSize = 10;
            app.lat_gs_check.Position = [25 265 83 22];
            app.lat_gs_check.Value = checkbox_states(14);

            % Create yaw_rate_check
            app.yaw_rate_check = uicheckbox(app.MRacingDDT);
            app.yaw_rate_check.Text = 'Yaw Rate (deg/s)';
            app.yaw_rate_check.FontSize = 10;
            app.yaw_rate_check.Position = [25 244 100 22];
            app.yaw_rate_check.Value = checkbox_states(15);

            % Create yaw_deg_check
            app.yaw_deg_check = uicheckbox(app.MRacingDDT);
            app.yaw_deg_check.Text = 'Yaw Position (deg)';
            app.yaw_deg_check.FontSize = 10;
            app.yaw_deg_check.Position = [25 223 115 22];
            app.yaw_deg_check.Value = checkbox_states(16);

            % Create plot_wrt_group
            app.plot_wrt_group = uibuttongroup(app.MRacingDDT);
            app.plot_wrt_group.Title = 'Plot w.r.t';
            app.plot_wrt_group.Position = [20 114 123 85];

            % Create time_button
            app.time_button = uitogglebutton(app.plot_wrt_group);
            app.time_button.Text = 'time';
            app.time_button.Position = [11 31 100 23];
            app.time_button.Value = true;

            % Create distance_button
            app.distance_button = uitogglebutton(app.plot_wrt_group);
            app.distance_button.Text = 'distance';
            app.distance_button.Position = [11 10 100 23];

            % Create export_data_check
            app.export_data_check = uicheckbox(app.MRacingDDT);
            app.export_data_check.Text = 'Export Data';
            app.export_data_check.Position = [152 24 85 22];

            % Create miguel_quote
            app.miguel_quote = uilabel(app.MRacingDDT);
            app.miguel_quote.HorizontalAlignment = 'right';
            app.miguel_quote.FontName = 'Century Gothic';
            app.miguel_quote.FontAngle = 'italic';
            app.miguel_quote.FontColor = [0.502 0.502 0.502];
            app.miguel_quote.Position = [336 20 124 30];
            app.miguel_quote.Text = {'" This makes me nut "'; 'Miguel Bigott -'};

            % Show the figure after all components are created
            app.MRacingDDT.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mr25_data_visualizer

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.MRacingDDT)

            app.MRacingDDT.AutoResizeChildren = 'off';

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MRacingDDT)
        end
    end
end