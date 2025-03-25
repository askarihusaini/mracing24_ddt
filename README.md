# MRacing Driver Data Feedback Tool  
*v2.0.0 dev-25.03.25.2*  

## **Instructions**  
Download and unzip **"MRacing_DDT.zip"** into a folder.  

1) Open `mrXX_data_visualizer.m` in MATLAB and run the script.  
	- MR23 data and MR24 data can be used with their respective scripts
2) Upload a log file to be visualized.  
	- If the log file begins with `ddt_`, no reformatting is needed.  
	- Otherwise, check the **"Reformat File"** button to enable faster loading next time.  
3) *(Optional)* Select specific lap(s) (Lap A and/or B) to visualize.  
4) Choose the variables to visualize.  
5) Select the domain (time or distance traveled).  
6) *(Optional)* Export the visualized data to a `.csv` file.  
   - **Note:** Exported files **cannot** be used by the visualizer. They are solely for human readability.  

## **Interactions**  
- 🖐️ **Drag**: Use the hand symbol to move around within any plot.  
- 🔍 **Zoom**: Use the magnifying glass icons to zoom in/out.  
- 📍 **Click Interaction**: Click anywhere on a **non-variance plot** to activate the info readout (top right).  
	- Use **arrow keys** to scrub through the data more precisely.  
	- Use **`,` (comma) and `.` (period)** for even finer adjustments.  

## **Resources**  
📂 **Source Code:** [GitHub Repo](https://github.com/askarihusaini/mracing24_ddt) (or click "Github Repo" in the top right of the app).  
📝 **Changelog:** [CHANGELOG.md](https://github.com/askarihusaini/mracing24_ddt/blob/master/CHANGELOG.md).
📨 **Questions?** DM me on Slack :D