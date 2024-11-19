classdef data_visualizer_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MRacing2024DataVisualizerUIFigure  matlab.ui.Figure
        vert_gs_check           matlab.ui.control.CheckBox
        lat_gs_check            matlab.ui.control.CheckBox
        long_gs_check           matlab.ui.control.CheckBox
        yaw_rate_check          matlab.ui.control.CheckBox
        pitch_rate_check        matlab.ui.control.CheckBox
        roll_rate_check         matlab.ui.control.CheckBox
        vehichle_heading_check  matlab.ui.control.CheckBox
        vehicle_speed_check     matlab.ui.control.CheckBox
        avg_speed_check         matlab.ui.control.CheckBox
        rr_speed_check          matlab.ui.control.CheckBox
        rl_speed_check          matlab.ui.control.CheckBox
        fr_speed_check          matlab.ui.control.CheckBox
        fl_speed_check          matlab.ui.control.CheckBox
        brake_bias_check        matlab.ui.control.CheckBox
        read_brakes_check       matlab.ui.control.CheckBox
        front_brakes_check      matlab.ui.control.CheckBox
        brake_pedal_check       matlab.ui.control.CheckBox
        gas_pedal_check         matlab.ui.control.CheckBox
        github_link             matlab.ui.control.Hyperlink
        variables_header        matlab.ui.control.Label
        log_file_header         matlab.ui.control.Label
        version_label           matlab.ui.control.Label
        lapB_edit               matlab.ui.control.NumericEditField
        LapBLabel               matlab.ui.control.Label
        lapA_edit               matlab.ui.control.NumericEditField
        Lap1Label               matlab.ui.control.Label
        title                   matlab.ui.control.Label
        mracing_logo            matlab.ui.control.Image
        upload_log_button       matlab.ui.control.Button
        reformat_file_check     matlab.ui.control.CheckBox
        file_label              matlab.ui.control.Label
        run_visualizer_button   matlab.ui.control.Button
        Image                   matlab.ui.control.Image
    end

    
    properties (Access = private)
        file = ""
        location = ""
        data

        lap_min % Smallest lap number (should be 0?)
        lap_max % Biggest lap number
        lapA % Lap 1 number
        lapA_t % Lap 1 time
        lapB % Lap 2 number
        lapB_t % Lap 2 time
        lapf % Fast lap number
        lapf_t % Fast lap time

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: run_visualizer_button
        function run_visualizer(app, event)
            w = waitbar(0, "Reading data...");
            
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
                
                app.data = readtable([app.location, app.file]);
                waitbar(.2, w, "Reformatting file...");
                app.data = app.data(:,relevant_vars);

                waitbar(.4, w, "Writing new file...");
                % create new file with same name + ddt_
                app.file = strcat("ddt_", app.file);
                writetable(app.data, strcat(app.location, app.file));
            else
                app.data = readtable([app.location, app.file]);
            end
            
            %% Grab min & max lap and user inputted laps
            app.lap_min = app.data{1, "Dash_3_Lap_Number_None_"};
            app.lap_max = app.data{end, "Dash_3_Lap_Number_None_"};
            app.lapA = app.lapA_edit.Value;
            app.lapB = app.lapB_edit.Value;

            %% Calc fastest lap
            waitbar(.6, w, "Calculating lap data...");
            lap_times = app.data{:,"Dash_3_Lap_Time_s_"};
            % Find smallest non-zero lap time
            app.lapf_t = min(lap_times(lap_times>0));
            % Edge case: If lap time is always 0
            if isempty(app.lapf_t)
                app.lapf_t = 0;
            end
            % Grab row of lapf_t and use it to find lapf number
            app.lapf = app.data{lap_times==app.lapf_t, "Dash_3_Lap_Number_None_"}(1);

            %% Default lap A and B
            if (isempty(app.lapA))
                app.lapA = app.lapf;
                app.lapA_t = app.lapf_t;
            end
            if (isempty(app.lapB))
                app.lapB = -1;
                app.lapB_t = -1;
            end

            waitbar(1, w, "Finished");
            pause(0.5)
            close(w)

            % Error message if segmentation fault
            if (app.lapA < app.lap_min || app.lapA > app.lap_max || ...
                    (app.lapB < app.lap_min && app.lapB ~= -1) || app.lapB > app.lap_max)
                msgbox(["Error: Lap number out of bounds", ...
                        "Lap number must be between " + app.lap_min + " and " + app.lap_max], ...
                        "Error: Segmentation Fault")
                return
            end

            %% Lap data message box
            if app.lapB == -1
                lap2msg = "B: Lap ignored";
            else
                lap2msg = "B: Lap " + app.lapB + ", " + app.lapB_t + " seconds";
            end
            msgbox(["Fastest: Lap " + app.lapf + ", " + app.lapf_t + " seconds", ...
                    "A: Lap " + app.lapA + ", " + app.lapA_t + " seconds", ...
                    lap2msg], ...
                    "Lap Summary");
            
            %% Plot!
            

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

            % Create title
            app.title = uilabel(app.MRacing2024DataVisualizerUIFigure);
            app.title.FontName = 'Century Gothic';
            app.title.FontSize = 18;
            app.title.FontWeight = 'bold';
            app.title.FontColor = [0 0.149 0.302];
            app.title.Position = [20 590 305 24];
            app.title.Text = 'DRIVER DATA VISUALIZATION TOOL';

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
            app.lapA_edit.Placeholder = 'Default fastest';
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
            app.version_label.Position = [375 670 85 30];
            app.version_label.Text = {'Askari Husaini'; 'V24.11.18'};

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
            app.github_link.Position = [386 649 74 22];
            app.github_link.Text = 'Github repo';

            % Create gas_pedal_check
            app.gas_pedal_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.gas_pedal_check.Text = 'Gas Pedal (%)';
            app.gas_pedal_check.FontSize = 10;
            app.gas_pedal_check.Position = [25 380 87 22];

            % Create brake_pedal_check
            app.brake_pedal_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.brake_pedal_check.Text = 'Brake Pedal (%)';
            app.brake_pedal_check.FontSize = 10;
            app.brake_pedal_check.Position = [25 359 95 22];

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
            app.roll_rate_check.Position = [335 338 97 22];

            % Create pitch_rate_check
            app.pitch_rate_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.pitch_rate_check.Text = 'Pitch Rate (deg/s)';
            app.pitch_rate_check.FontSize = 10;
            app.pitch_rate_check.Position = [335 317 102 22];

            % Create yaw_rate_check
            app.yaw_rate_check = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.yaw_rate_check.Text = 'Yaw Rate (deg/s)';
            app.yaw_rate_check.FontSize = 10;
            app.yaw_rate_check.Position = [335 296 99 22];

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

            % Show the figure after all components are created
            app.MRacing2024DataVisualizerUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = data_visualizer_exported

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