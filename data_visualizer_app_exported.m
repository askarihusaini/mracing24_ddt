classdef data_visualizer_app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MRacing2024DataVisualizerUIFigure  matlab.ui.Figure
        reformat_file_chk   matlab.ui.control.CheckBox
        upload_log_lbl      matlab.ui.control.Label
        upload_log_btn      matlab.ui.control.Button
        run_visualizer_btn  matlab.ui.control.Button
    end

    
    properties (Access = private)
        file = "" % Description
        location = "" % Description
        reformatFlag % Description
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: run_visualizer_btn
        function run_visualizer(app, event)
            if get(app.reformat_file_chk, 'Value') == 1
                disp('Reformatting log data...')

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
                
                disp("Writing to new file...")
                % create new file with same name + ddt_
                app.file = strcat("ddt_", app.file);
                writetable(data, strcat(app.location, app.file));
                disp('Finished reformatting')
            end
        end

        % Button pushed function: upload_log_btn
        function upload_file(app, event)
            [app.file, app.location] = uigetfile('*.txt');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MRacing2024DataVisualizerUIFigure and hide until all components are created
            app.MRacing2024DataVisualizerUIFigure = uifigure('Visible', 'off');
            app.MRacing2024DataVisualizerUIFigure.Position = [100 100 360 540];
            app.MRacing2024DataVisualizerUIFigure.Name = 'MRacing 2024 Data Visualizer';

            % Create run_visualizer_btn
            app.run_visualizer_btn = uibutton(app.MRacing2024DataVisualizerUIFigure, 'push');
            app.run_visualizer_btn.ButtonPushedFcn = createCallbackFcn(app, @run_visualizer, true);
            app.run_visualizer_btn.BackgroundColor = [0 0.149 0.302];
            app.run_visualizer_btn.FontSize = 14;
            app.run_visualizer_btn.FontWeight = 'bold';
            app.run_visualizer_btn.FontColor = [1 0.8 0.0196];
            app.run_visualizer_btn.Position = [20 20 120 30];
            app.run_visualizer_btn.Text = 'Run Visualizer';

            % Create upload_log_btn
            app.upload_log_btn = uibutton(app.MRacing2024DataVisualizerUIFigure, 'push');
            app.upload_log_btn.ButtonPushedFcn = createCallbackFcn(app, @upload_file, true);
            app.upload_log_btn.Position = [20 495 90 25];
            app.upload_log_btn.Text = 'Upload log file';

            % Create upload_log_lbl
            app.upload_log_lbl = uilabel(app.MRacing2024DataVisualizerUIFigure);
            app.upload_log_lbl.FontSize = 10;
            app.upload_log_lbl.Position = [49 462 28 22];
            app.upload_log_lbl.Text = strcat(app.location, app.file);

            % Create reformat_file_chk
            app.reformat_file_chk = uicheckbox(app.MRacing2024DataVisualizerUIFigure);
            app.reformat_file_chk.Text = 'Reformat file';
            app.reformat_file_chk.FontSize = 10;
            app.reformat_file_chk.Position = [120 495 80 25];

            % Show the figure after all components are created
            app.MRacing2024DataVisualizerUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = data_visualizer_app_exported

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