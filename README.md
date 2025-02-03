MRacing Suspension Driver Data Feedback Tool

HOW TO USE:
1) Download and unzip "MRacing_DDT" into a folder
2) Open data_visualizer.m in MATLAB and run the script
3) Upload a log file to be visualized
    - NOTE: As of right now, only log data from MR23 works. Once MR25 exists, the app will be updated
    - If the log file begins with ddt_, no need to reformat the file
    - Otherwise, check the "Reformat File" button so it load faster next time
4) (Optional) Select a specific lap(s) (Lap A & B) to be visualized
5) Select which variables to be visualized
6) Select what the domain should be (time or distance traveled)
7) (Optional) Enable graphs displaying the variance between laps A and B
    - A positive value for the variance graphs indicates lap B having a higher value
    - Note: This only works when plotting w.r.t time for now

All source code can be found by clicking the "Github Repo" link in the top right
For any inquiries, DM me on slack :)