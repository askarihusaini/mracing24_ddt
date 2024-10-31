%% File input
disp("Select log file")
[file, location] = uigetfile('*.txt');

% Check if file exists
if isequal(file, 0)
    disp('No file selected. Exiting...')
    return
end
    
disp('start')
fid = fopen([location file]);
numLines = 0;
while ~feof(fid)
    [~,c]=textscan(fid,'%*[^\r\n]%*[\r\n]',1,'Delimiter','','Whitespace','','EndOfLine','');
    if c > 0 % if c==0, then there wasn't a line there. this may happen at the end of the file.
        numLines = numLines + 1;
    end
end
fclose(fid);
disp(numLines)


% disp("start")
% disp(height(readtable([location, file], 'ReadVariableNames', false)))

% opts = detectImportOptions([location, file]);
% opts.SelectedVariableNames = "Dash_3_Lap_Number_None_";
% data1 = readtable([location, file], opts);

%data = data(:,relevant_vars);
% disp(data{1,"Dash_3_Lap_Number_None_"})
% disp(data{end,"Dash_3_Lap_Number_None_"})
    
   