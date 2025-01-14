classdef data_visualizer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        PUBLIC_VER = 'v0.1.0+';
        PRIVATE_VER = 'dev-25.01.14.2';
        
        MRacing2024DataVisualizerUIFigure  matlab.ui.Figure
        time_check               matlab.ui.control.CheckBox
        distance_check           matlab.ui.control.CheckBox
        variance_check           matlab.ui.control.CheckBox
        plot_wrt_group           matlab.ui.container.ButtonGroup
        distance_button          matlab.ui.control.ToggleButton
        time_button              matlab.ui.control.ToggleButton
        vert_gs_check            matlab.ui.control.CheckBox
        lat_gs_check             matlab.ui.control.CheckBox
        long_gs_check            matlab.ui.control.CheckBox
        yaw_rate_check           matlab.ui.control.CheckBox
        pitch_rate_check         matlab.ui.control.CheckBox
        roll_rate_check          matlab.ui.control.CheckBox
        vehichle_heading_check   matlab.ui.control.CheckBox
        vehicle_speed_check      matlab.ui.control.CheckBox
        avg_speed_check          matlab.ui.control.CheckBox
        rr_speed_check           matlab.ui.control.CheckBox
        rl_speed_check           matlab.ui.control.CheckBox
        fr_speed_check           matlab.ui.control.CheckBox
        fl_speed_check           matlab.ui.control.CheckBox
        brake_bias_check         matlab.ui.control.CheckBox
        read_brakes_check        matlab.ui.control.CheckBox
        front_brakes_check       matlab.ui.control.CheckBox
        brake_position_check     matlab.ui.control.CheckBox
        throttle_position_check  matlab.ui.control.CheckBox
        github_link              matlab.ui.control.Hyperlink
        variables_header         matlab.ui.control.Label
        log_file_header          matlab.ui.control.Label
        version_label            matlab.ui.control.Label
        lapB_edit                matlab.ui.control.NumericEditField
        LapBLabel                matlab.ui.control.Label
        lapA_edit                matlab.ui.control.NumericEditField
        Lap1Label                matlab.ui.control.Label
        ddvt_header              matlab.ui.control.Label
        mracing_logo             matlab.ui.control.Image
        upload_log_button        matlab.ui.control.Button
        reformat_file_check      matlab.ui.control.CheckBox
        file_label               matlab.ui.control.Label
        run_visualizer_button    matlab.ui.control.Button
        Image                    matlab.ui.control.Image
    end

    
    properties (Access = private)
        file = ""
        location = ""

        % lap_min % Smallest lap number (should be 0?)
        % lap_max % Biggest lap number
        % lapA % Lap 1 number
        % lapA_t % Lap 1 time
        % lapB % Lap 2 number
        % lapB_t % Lap 2 time
        % lapf % Fast lap number
        % lapf_t % Fast lap time

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: run_visualizer_button
        function run_visualizer(app, event)
            
            w = warning ('off','all');
            msg = msgbox("Please wait :)");

            %% Reformat file
            if get(app.reformat_file_check, 'Value') == 1
                % These are the variables we want to keep in the reformatted file
                % Make sure 'variables_select' has no carriage returns (\r)!!!!
                relevant_vars = fileread('variables_relevant.txt');
                relevant_vars = strsplit(relevant_vars, '\n');

                % readtable replaces [ ] / with _ and removes whitespace
                relevant_vars = strrep(relevant_vars, '[', '_');
                relevant_vars = strrep(relevant_vars, ']', '_');
                relevant_vars = strrep(relevant_vars, '/', '_');
                relevant_vars = strrep(relevant_vars, ' ', '');

                data = readtable([app.location, app.file]);
                data = data(:,relevant_vars);

                % Throttle and brake percentages arent actual percentages lol
                throttle_max = max(data{:,"Pedals_APS_A_percent_"});
                brake_max = max(data{:,"Pedals_APS_B_percent_"});
                data{:,"Pedals_APS_A_percent_"} = data{:,"Pedals_APS_A_percent_"} / throttle_max;
                data{:,"Pedals_APS_B_percent_"} = data{:,"Pedals_APS_B_percent_"} / brake_max;


                % create new file with same name + ddt_
                app.file = strcat("ddt_", app.file);
                writetable(data, strcat(app.location, app.file));
            else
                data = readtable([app.location, app.file]);
            end

            %% Grab the variable data of the checkbox ones
            % Again, MAKE SURE NO \r!!! Only \n!!!!
            checkbox_vars = fileread('variables_checkbox.txt');
            checkbox_vars = strsplit(checkbox_vars, '\n');
            checkbox_vars = strrep(checkbox_vars, '[', '_');
            checkbox_vars = strrep(checkbox_vars, ']', '_');
            checkbox_vars = strrep(checkbox_vars, '/', '_');
            checkbox_vars = strrep(checkbox_vars, ' ', '');
            data_checkbox = data(:, checkbox_vars);

            %% Grab min & max lap and user inputted laps
            lap_min = data{1, "Dash_3_Lap_Number_None_"};
            lap_max = data{end, "Dash_3_Lap_Number_None_"};
            lapA = app.lapA_edit.Value;
            lapB = app.lapB_edit.Value;

            % %% Calc fastest lap
            % lap_times = data{:,"Dash_3_Lap_Time_s_"};
            % % Find smallest non-zero lap time
            % lapf_t = min(lap_times(lap_times>0));
            % % Edge case: If lap time is always 0
            % if isempty(lapf_t)
            %     lapf_t = 0;
            % end
            % % Grab row of lapf_t and use it to find lapf number
            % lapf = data{lap_times==lapf_t, "Dash_3_Lap_Number_None_"}(1);

            %% Default lap A and B
            if (isempty(lapA))
                % lapA = lapf;
                % lapA_t = lapf_t;
                lapA = false;
                lapA_time = false;
            end
            if (isempty(lapB))
                lapB = false;
                lapB_time = false;
            end

            % Error message if segmentation fault
            if (lapA < lap_min || lapA > lap_max || ...
                    (lapB < lap_min && lapB ~= -1) || lapB > lap_max)
                delete(msg)
                msgbox(["Error: Lap number out of bounds", ...
                        "Lap number must be between " + lap_min + " and " + lap_max], ...
                        "Error: Segmentation Fault")
                return
            end
           
            %% Which variables to plot?
            % xtime [s]
            % xdist [m]
            % Pedals_APS_A [percent]
            % Pedals_APS_B [percent]
            % Pedals_F_Brake [psi]
            % Pedals_R_Brake [psi]
            % AMK_ActVal_1_FL_AMK_ActualVelocity [rpm]
            % AMK_ActVal_1_FR_AMK_ActualVelocity [rpm]
            % AMK_ActVal_1_RL_AMK_ActualVelocity [rpm]
            % AMK_ActVal_1_RR_AMK_ActualVelocity [rpm]
            % Dash_3_Vehicle_Speed [mph]
            % Dash_4_Brake_Bias [None]
            % Average_IMU_Long [g]
            % Average_IMU_Lat [g]
            % Average_IMU_Vert [g]
            % Average_IMU_Roll [deg/s]
            % Average_IMU_Pitch [deg/s]
            % Average_IMU_Yaw [deg/s]

            % Needs to be in same order as appears in log file
            axis_checkboxes = [ app.time_check, app.distance_check, ... 
                                app.throttle_position_check, app.brake_position_check, app.front_brakes_check, app.read_brakes_check, ...
                                app.fl_speed_check, app.fr_speed_check, app.rl_speed_check, app.rr_speed_check, ...
                                app.vehicle_speed_check, app.brake_bias_check, ...
                                app.long_gs_check, app.lat_gs_check, app.vert_gs_check, ...
                                app.roll_rate_check, app.pitch_rate_check, app.yaw_rate_check];

            axis_names = string(size(axis_checkboxes));
            axis_values = zeros(size(axis_checkboxes));
            for i = 1:size(axis_checkboxes, 2)
                txt = convertCharsToStrings(get(axis_checkboxes(i), 'Text')); % HOLY SHIT THIS IS FUNNY LMFAOOOOO
                value = get(axis_checkboxes(i), 'Value');
                axis_names(i) = txt;
                if value
                    axis_values(i) = 1;
                end
            end

            selected_vars = 1:size(axis_checkboxes, 2);
            selected_vars = transpose(nonzeros(selected_vars .* axis_values));
            NUM_VARS = size(selected_vars,2);

            wrt_time = get(app.time_button, "Value");

            if lapA == false
                % Grab data across all laps
                if wrt_time
                    lapA_x = data{:,"xtime_s_"};
                else
                    lapA_x = data{:,"xdist_m_"};
                end
                lapA_selected_data = data_checkbox{:, selected_vars}';

            else
                % Grab data specific to only laps specified
                lapA_data = data(data.Dash_3_Lap_Number_None_ == lapA, :);
                if lapB
                    lapB_data = data(data.Dash_3_Lap_Number_None_ == lapB, :);
                end

                lapA_data{:,"xtime_s_"} = lapA_data{:,"xtime_s_"} - lapA_data{1,"xtime_s_"};
                if lapB
                    lapB_data{:,"xtime_s_"} = lapB_data{:,"xtime_s_"} - lapB_data{1,"xtime_s_"};
                end

                lapA_data{:,"xdist_m_"} = lapA_data{:,"xdist_m_"} - lapA_data{1,"xdist_m_"};
                if lapB
                    lapB_data{:,"xdist_m_"} = lapB_data{:,"xdist_m_"} - lapB_data{1,"xdist_m_"};
                end

                % Grab time/distance of lapA and lapB data for domain input
                if wrt_time
                    lapA_x = lapA_data{:,"xtime_s_"};
                    if lapB
                        lapB_x = lapB_data{:,"xtime_s_"};
                    end
                else
                    lapA_x = lapA_data{:,"xdist_m_"};
                    if lapB
                        lapB_x = lapB_data{:,"xdist_m_"};
                    end
                end
    
                % Grab checkbox variables of lapA and lapB data for range input
                lapA_data_checkbox = lapA_data(:, checkbox_vars);
                lapA_selected_data = lapA_data_checkbox{:, selected_vars}';
                if lapB
                    lapB_data_checkbox = lapB_data(:, checkbox_vars);
                    lapB_selected_data = lapB_data_checkbox{:, selected_vars}';
                end

            end

            %% Variance
            plot_variances = get(app.variance_check, "Value");
            if plot_variances && ~lapB
                delete(msg)
                msgbox("Error: Input a second lap to display variance", ...
                        "Error: Variance Conflict")
                return
            end
            if plot_variances && ~wrt_time
                delete(msg)
                msgbox("Error: Variance display only works when plotting w.r.t time", ...
                        "Error: Variance Conflict")
                return
            end

            % Make both data ranges the same size
            if plot_variances
                if lapA_x(end) > lapB_x(end)
                    variance_x = lapA_x;
                else
                    variance_x = lapB_x;
                end
                resize_size = max(size(lapA_selected_data, 2), size(lapB_selected_data, 2));
                resized_lapA = resize(lapA_selected_data, [NUM_VARS, resize_size], Pattern="edge"); % Is edge the best??? Or 0???
                resized_lapB = resize(lapB_selected_data, [NUM_VARS, resize_size], Pattern="edge");
                variance_selected_data = resized_lapB - resized_lapA;
            end

            % May be smart to have a separate matrix for the variance
            % values to make stuff easier for infobox and whatnot?

            %% Plot!

            % timei = 0;
            % timef = 10;
            % x = timei:.01:timef;
            % data1 = [sin(x) ; cos(x) ; tan(x) ; x/10 ; x.^2/10 ; x.^3/10 ; 0*x + 0.5 ; -x/10];
            % data2 = data1 - 1;
            % axis_names = ["Var A", "Var B", "Var C", "Var D", "Var E", "Var F", "Var G", "Var H"];
            % selected_vars = [1,2,3,4,5,6,7,8];

            figureColor = [.94,.94,.94];
            tileColor = [.9,.9,.9];
            textColor = [0,0,0];
            outlineColor = [0,0,0];
            lapAColor = [235/255, 52/255, 52/255]; %[0, .49, .96];
            lapBColor = [52/255, 128/255, 235/255]; %[.89, .09, .04];
            varianceColor = [128/255, 52/255, 235/255];
            ylineColor = [.5,.5,.5];
            set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{outlineColor,outlineColor,outlineColor})
            
            f1 = uifigure('color', figureColor);
            
            % T Tiled layout
            T = tiledlayout(f1, 1,3, "TileSpacing", "compact", "Padding", "compact");
            
            % t1 Tile 1: Tiled layout: Graphs of variables
            t1 = tiledlayout(T, "vertical", "TileSpacing", "compact", "Padding", "compact");
            t1.Layout.Tile = 1;
            t1.Layout.TileSpan = [1,2];

            plot_axes = zeros([1, NUM_VARS]);
            if plot_variances
                variance_axes = zeros([1, NUM_VARS]);
            end
            
            % Subtiles: Individual graphs of variables
            for i = 1:NUM_VARS
                ax = nexttile(t1);
                hold(ax, "on")
                plot(ax, lapA_x, lapA_selected_data(i,:), "Color", lapAColor);
                if lapB
                    plot(ax, lapB_x, lapB_selected_data(i,:), "Color", lapBColor);
                end
                hold(ax, "off")
                yline(ax, 0, "Color", ylineColor);
            
                %curr.ButtonDownFcn = @(h,e) disp(e.IntersectionPoint);
        
                ax.XGrid = "on";
                ax.YGrid = "on";
                ax.XMinorGrid = "on";
                ax.YMinorGrid = "on";
                ax.Color = tileColor;
                %ax.XTick = 0:25:indep_var(end);
                xticklabels(ax, "");
                ax.YLabel.String = axis_names(selected_vars(i));

                plot_axes(i) = ax;

                if plot_variances
                    ax = nexttile(t1);
                    
                    plot(ax, variance_x, variance_selected_data(i,:), "Color", varianceColor);
                    yline(ax, 0, "Color", ylineColor);

                    ax.XGrid = "on";
                    ax.YGrid = "on";
                    ax.XMinorGrid = "on";
                    ax.YMinorGrid = "on";
                    ax.Color = tileColor;
                    %ax.XTick = 0:25:indep_var(end);
                    xticklabels(ax, "");
                    ax.YLabel.String = "Variance";

                    YL = get(ax, 'YLim');
                    maxlim = max(abs(YL));
                    set(ax, 'YLim', [-maxlim maxlim]);

                    variance_axes(i) = ax;
                end

            end
            xticklabels(ax, "auto"); % Enable tick labels for bottom graph
            ax.XTickLabelRotation = 45;
            if wrt_time
                ax.XLabel.String = "Time (s)";
            else
                ax.XLabel.String = "Distance (m)";
            end

            if plot_variances
                linkaxes([plot_axes, variance_axes], 'x')
            else
                linkaxes(plot_axes, 'x')
            end
            
            % t2 Tile 2: Tiled layout: Infobox and map
            t2 = tiledlayout(T, 2,1, "TileSpacing", "compact", "Padding", "none");
            t2.Layout.Tile = 3;
            
            x_selected = 0;
            
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
                ax.Color = tileColor;
                ax.Box = "on";
            
                infoBox_string = "Lap " + i + ":\n@ t = " + x_selected(1) + "\n";
                infoBox_data = zeros(NUM_VARS);
                for j = 1:NUM_VARS
                    infoBox_string = infoBox_string + axis_names(selected_vars(j)) + ": " + infoBox_data(j) + "\n";
                end
            
                infoBox_string = regexprep(infoBox_string, "%", "%%"); % % is an escape character
                text(ax, 0.05,.975,sprintf(infoBox_string), 'Horiz','left', 'Vert','top', ...
                    "Color", textColor, 'fontsize',5,'fontunits','normalized')
            end
            
            % Subtile B: GG Diagram
            ax = nexttile(t2, 2, [1,1]);

            lat_g = data_checkbox{:, "Average_IMU_Lat_g_"};
            long_g = data_checkbox{:, "Average_IMU_Long_g_"};
            throttle_pos = data_checkbox{:, "Pedals_APS_A_percent_"};

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
        end

        % Button pushed function: upload_log_button
        function upload_file(app, event)
            dummy = figure('Renderer', 'painters', 'Position', [-100 -100 0 0]); % create a dummy figure so that uigetfile doesn't minimize our GUI
            [f, l] = uigetfile('*.txt', "Select log file");
            delete(dummy); % delete the dummy figure
            if isequal(f, 0)
                return
            else
                app.file = f;
                app.location = l;
                %app.upload_log_button.Text = app.file;
                app.file_label.Text = strcat(app.location, app.file);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create MRacing2024DataVisualizerUIFigure and hide until all components are created
            app.MRacing2024DataVisualizerUIFigure = uifigure('Visible', 'off');
            app.MRacing2024DataVisualizerUIFigure.Position = [100 100 480 720];
            app.MRacing2024DataVisualizerUIFigure.Name = 'MRacing 2024 Data Visualizer';

            % Create Image
            app.Image = uiimage(app.MRacing2024DataVisualizerUIFigure);
            app.Image.Position = [1 1 480 720];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'app_resources', 'background.png');

            % Create run_visualizer_button
            app.run_visualizer_button = uibutton(app.MRacing2024DataVisualizerUIFigure, 'push');
            app.run_visualizer_button.ButtonPushedFcn = createCallbackFcn(app, @run_visualizer, true);
            app.run_visualizer_button.BackgroundColor = [0 0.149 0.302];
            app.run_visualizer_button.FontSize = 14;
            app.run_visualizer_button.FontWeight = 'bold';
            app.run_visualizer_button.FontColor = [1 0.8 0.0196];
            app.run_visualizer_button.Position = [20 20 120 30];
            app.run_visualizer_button.Text = 'Run Visualizer';

            % Create file_label
            app.file_label = uilabel(app.MRacing2024DataVisualizerUIFigure);
            app.file_label.FontSize = 10;
            app.file_label.Tooltip = {''};
            app.file_label.Position = [25 485 430 15];
            app.file_label.Text = 'No file selected';

            % Create reformat_file_check
            app.reformat_file_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.reformat_file_check.Text = 'Reformat file';
            app.reformat_file_check.FontSize = 10;
            app.reformat_file_check.Position = [25 460 80 25];

            % Create upload_log_button
            app.upload_log_button = uibutton(app.MRacing2024DataVisualizerUIFigure, 'push');
            app.upload_log_button.ButtonPushedFcn = createCallbackFcn(app, @upload_file, true);
            app.upload_log_button.BackgroundColor = [0.902 0.902 0.902];
            app.upload_log_button.FontSize = 10;
            app.upload_log_button.Position = [20 505 100 25];
            app.upload_log_button.Text = 'Upload log file';

            % Create mracing_logo
            app.mracing_logo = uiimage(app.MRacing2024DataVisualizerUIFigure);
            app.mracing_logo.Position = [20 620 300 80];
            app.mracing_logo.ImageSource = fullfile(pathToMLAPP, 'app_resources', 'mracing_logo.png');

            % Create ddvt_header
            app.ddvt_header = uilabel(app.MRacing2024DataVisualizerUIFigure);
            app.ddvt_header.FontName = 'Century Gothic';
            app.ddvt_header.FontSize = 18;
            app.ddvt_header.FontWeight = 'bold';
            app.ddvt_header.FontColor = [0 0.149 0.302];
            app.ddvt_header.Position = [20 590 305 24];
            app.ddvt_header.Text = 'DRIVER DATA VISUALIZATION TOOL';

            % Create Lap1Label
            app.Lap1Label = uilabel(app.MRacing2024DataVisualizerUIFigure);
            app.Lap1Label.HorizontalAlignment = 'right';
            app.Lap1Label.FontSize = 10;
            app.Lap1Label.Position = [130 505 33 25];
            app.Lap1Label.Text = 'Lap A:';

            % Create lapA_edit
            app.lapA_edit = uieditfield(app.MRacing2024DataVisualizerUIFigure, 'numeric');
            app.lapA_edit.RoundFractionalValues = 'on';
            app.lapA_edit.AllowEmpty = 'on';
            app.lapA_edit.FontSize = 10;
            app.lapA_edit.Placeholder = 'Default all';
            app.lapA_edit.Position = [170 507 80 21];
            app.lapA_edit.Value = [];

            % Create LapBLabel
            app.LapBLabel = uilabel(app.MRacing2024DataVisualizerUIFigure);
            app.LapBLabel.HorizontalAlignment = 'right';
            app.LapBLabel.FontSize = 10;
            app.LapBLabel.Position = [259 505 34 25];
            app.LapBLabel.Text = 'Lap B:';

            % Create lapB_edit
            app.lapB_edit = uieditfield(app.MRacing2024DataVisualizerUIFigure, 'numeric');
            app.lapB_edit.RoundFractionalValues = 'on';
            app.lapB_edit.AllowEmpty = 'on';
            app.lapB_edit.FontSize = 10;
            app.lapB_edit.Placeholder = 'Default ignore';
            app.lapB_edit.Position = [300 507 80 21];
            app.lapB_edit.Value = [];

            % Create version_label
            app.version_label = uilabel(app.MRacing2024DataVisualizerUIFigure);
            app.version_label.HorizontalAlignment = 'right';
            app.version_label.FontName = 'Century Gothic';
            app.version_label.FontColor = [0.502 0.502 0.502];
            app.version_label.Position = [375 656 85 44];
            app.version_label.Text = {'Askari Husaini'; app.PUBLIC_VER; app.PRIVATE_VER};

            % Create log_file_header
            app.log_file_header = uilabel(app.MRacing2024DataVisualizerUIFigure);
            app.log_file_header.FontName = 'Century Gothic';
            app.log_file_header.FontSize = 14;
            app.log_file_header.FontWeight = 'bold';
            app.log_file_header.FontColor = [0 0.149 0.302];
            app.log_file_header.Position = [20 540 206 25];
            app.log_file_header.Text = 'Log File & Lap(s) Analyzed';

            % Create variables_header
            app.variables_header = uilabel(app.MRacing2024DataVisualizerUIFigure);
            app.variables_header.FontName = 'Century Gothic';
            app.variables_header.FontSize = 14;
            app.variables_header.FontWeight = 'bold';
            app.variables_header.FontColor = [0 0.149 0.302];
            app.variables_header.Position = [20 410 183 25];
            app.variables_header.Text = 'Variables to Visualize';

            % Create github_link
            app.github_link = uihyperlink(app.MRacing2024DataVisualizerUIFigure);
            app.github_link.VisitedColor = [0.502 0.502 0.502];
            app.github_link.HorizontalAlignment = 'right';
            app.github_link.FontName = 'Century Gothic';
            app.github_link.FontColor = [0.502 0.502 0.502];
            app.github_link.URL = 'https://github.com/askarihusaini/mracing24_ddt';
            app.github_link.Position = [386 635 74 22];
            app.github_link.Text = 'Github repo';

            % Create throttle_position_check
            app.throttle_position_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.throttle_position_check.Text = 'Throttle Position (%)';
            app.throttle_position_check.FontSize = 10;
            app.throttle_position_check.Position = [25 380 113 22];

            % Create brake_position_check
            app.brake_position_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.brake_position_check.Text = 'Brake Position (%)';
            app.brake_position_check.FontSize = 10;
            app.brake_position_check.Position = [25 359 105 22];

            % Create front_brakes_check
            app.front_brakes_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.front_brakes_check.Text = 'Front Brakes (psi)';
            app.front_brakes_check.FontSize = 10;
            app.front_brakes_check.Position = [25 338 101 22];

            % Create read_brakes_check
            app.read_brakes_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.read_brakes_check.Text = 'Rear Brakes (psi)';
            app.read_brakes_check.FontSize = 10;
            app.read_brakes_check.Position = [25 317 100 22];

            % Create brake_bias_check
            app.brake_bias_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.brake_bias_check.Text = 'Brake Bias (#)';
            app.brake_bias_check.FontSize = 10;
            app.brake_bias_check.Position = [25 296 85 22];

            % Create fl_speed_check
            app.fl_speed_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.fl_speed_check.Text = 'FL Tyre Speed (rpm)';
            app.fl_speed_check.FontSize = 10;
            app.fl_speed_check.Position = [180 380 114 22];

            % Create fr_speed_check
            app.fr_speed_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.fr_speed_check.Text = 'FR Tyre Speed (rpm)';
            app.fr_speed_check.FontSize = 10;
            app.fr_speed_check.Position = [180 359 116 22];

            % Create rl_speed_check
            app.rl_speed_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.rl_speed_check.Text = 'RL Tyre Speed (rpm)';
            app.rl_speed_check.FontSize = 10;
            app.rl_speed_check.Position = [180 338 115 22];

            % Create rr_speed_check
            app.rr_speed_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.rr_speed_check.Text = 'RR Tyre Speed (rpm)';
            app.rr_speed_check.FontSize = 10;
            app.rr_speed_check.Position = [180 317 117 22];

            % Create avg_speed_check
            app.avg_speed_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.avg_speed_check.Text = 'Average Tyre Speed (rpm)';
            app.avg_speed_check.FontSize = 10;
            app.avg_speed_check.Position = [180 296 139 22];

            % Create vehicle_speed_check
            app.vehicle_speed_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.vehicle_speed_check.Text = 'Vehichle Speed (mph)';
            app.vehicle_speed_check.FontSize = 10;
            app.vehicle_speed_check.Position = [335 380 120 22];

            % Create vehichle_heading_check
            app.vehichle_heading_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.vehichle_heading_check.Text = 'Vehichle Heading (deg)';
            app.vehichle_heading_check.FontSize = 10;
            app.vehichle_heading_check.Position = [335 359 126 22];

            % Create roll_rate_check
            app.roll_rate_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.roll_rate_check.Text = 'Roll Rate (deg/s)';
            app.roll_rate_check.FontSize = 10;
            app.roll_rate_check.Position = [180 265 97 22];

            % Create pitch_rate_check
            app.pitch_rate_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.pitch_rate_check.Text = 'Pitch Rate (deg/s)';
            app.pitch_rate_check.FontSize = 10;
            app.pitch_rate_check.Position = [180 244 102 22];

            % Create yaw_rate_check
            app.yaw_rate_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.yaw_rate_check.Text = 'Yaw Rate (deg/s)';
            app.yaw_rate_check.FontSize = 10;
            app.yaw_rate_check.Position = [180 223 99 22];

            % Create long_gs_check
            app.long_gs_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.long_gs_check.Text = 'Longitudinal Gs (g)';
            app.long_gs_check.FontSize = 10;
            app.long_gs_check.Position = [25 265 106 22];

            % Create lat_gs_check
            app.lat_gs_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.lat_gs_check.Text = 'Lateral Gs (g)';
            app.lat_gs_check.FontSize = 10;
            app.lat_gs_check.Position = [25 244 83 22];

            % Create vert_gs_check
            app.vert_gs_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.vert_gs_check.Text = 'Vertical Gs (g)';
            app.vert_gs_check.FontSize = 10;
            app.vert_gs_check.Position = [25 223 85 22];

            % Create plot_wrt_group
            app.plot_wrt_group = uibuttongroup(app.MRacing2024DataVisualizerUIFigure);
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

            % Create variance_check
            app.variance_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.variance_check.Text = 'Variance Graphs';
            app.variance_check.Position = [25 85 111 22];

            % Create distance_check
            app.distance_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.distance_check.Text = 'Lap Distance (m)';
            app.distance_check.FontSize = 10;
            app.distance_check.Position = [335 338 100 22];

            % Create time_check
            app.time_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.time_check.Text = 'Lap Time (s)';
            app.time_check.FontSize = 10;
            app.time_check.Position = [335 317 100 22];

            % Show the figure after all components are created
            app.MRacing2024DataVisualizerUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = data_visualizer

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.MRacing2024DataVisualizerUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MRacing2024DataVisualizerUIFigure)
        end
    end
end