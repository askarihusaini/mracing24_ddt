%% File input
disp("Select log file")
[file, location] = uigetfile('*.txt');

% Check if file exists
if isequal(file, 0)
    disp('No file selected. Exiting...')
    return
end

% Prompt user to reformat file
answer = questdlg("Does this file need reformatting?",file, "Yes", "No", "No");

%% Log reformatter
if answer == "Yes"
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
    
    data = readtable([location, file]);
    data = data(:,relevant_vars);
    
    disp("Writing to new file...")
    % create new file with same name + ddt_
    file = strcat("ddt_", file);
    writetable(data, strcat(location, file));
    disp('Finished reformatting')
end

%% GUI

screenSize = get(0,'ScreenSize');
GUI_WIDTH = 400;
GUI_HEIGHT = 600;

GUI.f = figure("Name", "2024 MRacing Driver Data Visualizer", "NumberTitle","off", ...
    "MenuBar","none", "ToolBar","none", ...
    "Units","pixels", "Position",[100,screenSize(4)-GUI_HEIGHT - 100,GUI_WIDTH,GUI_HEIGHT]);

GUI.run = uicontrol('Style','pushbutton', 'String','Visualize Data',...
    'Units','pixels', 'Position',[20, 20, 100, 30], ...
    'Callback', @(src, event) run_visualizer(src, event, GUI));

function run_visualizer(src, event, GUI)
    %disp(get(GUI.speedBox, 'Value'))
end

% % Create yes/no checkboxes
% GUI.c(1) = uicontrol('style','checkbox','units','pixels',...
%                 'position',[10,30,50,15],'string','yes');
% GUI.c(2) = uicontrol('style','checkbox','units','pixels',...
%                 'position',[90,30,50,15],'string','no');    
% % Create OK pushbutton   
% GUI.p = uicontrol('style','pushbutton','units','pixels',...
%                 'position',[40,5,70,20],'string','OK');
% set(GUI.p, 'callback', @(src, event) p_call(src, event, GUI));
% 
% Pushbutton callback