[file, location] = uigetfile('*.txt');

if isequal(file, 0)
    disp('No file selected. Exiting...')
    return
end

% These are the variables we want to keep in the reformatted file
% Make sure 'variables_select' has no carriage returns (\r)!!!!
relevant_vars = fileread('variables_relevant.txt');
relevant_vars = strsplit(relevant_vars, '\n');

% readtable replaces [ ] / with _ and removes whitespace
relevant_vars = strrep(relevant_vars, '[', '_');
relevant_vars = strrep(relevant_vars, ']', '_');
relevant_vars = strrep(relevant_vars, '/', '_');
relevant_vars = strrep(relevant_vars, ' ', '');

disp('Reformatting log data...')
data = readtable([location, file]);
dataClean = data(:,relevant_vars);
disp('Finished')