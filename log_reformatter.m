disp("Select log file to reformat")
[file, location] = uigetfile('*.txt');

if isequal(file, 0)
    disp('No file selected. Exiting...')
    return
end

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