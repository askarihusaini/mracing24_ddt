disp("Select log file")
[file, location] = uigetfile('*.txt');
answer = questdlg("Does this file need reformatting?",file);