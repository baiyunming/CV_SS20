Computer Vision Challenge 2020
Group Number: G18


************************* MATLAB interface  ************************************
1) run config.m: initialise all required variables: src (relative path or absolute path possible), L, R, start, N, dest (path of output video, relative path or absolute path possible), bg (static background or videoreader), render_mode, store, loop
2) run chanllenge.m: processing speed: folder with 5000 images, circa 10mins	



************************* About GUI ************************************
1) RUN GUI.m in Matlab, GUI should pop up.

2) Choose the dataset: click "Import Path" in panel Settings and select directory of Database (Original Image-stream)

3) Select Background (video or image): click "Import Background" in panel Settings and select directory of Background. Background can be image or video. ('*.jpg *.tif *.png *.bmp *.avi *.mp4' are acceptable formats)

4) Select path of output video: click "Save Video Path" in panel Settings and select the directory of Output Video. 
** Please note that if you want to save the processing result as a video, you should select the directory before image processing. The video will be saved automatically after the process stops.

5) Choose the Start frame, Mode, Camera and loop. (default_Start = 1, default_Mode = Background, default_Camera = Left 1 Right 2, default loop = false)

6) Press "Start", the image in the left is the processing image and the right image is the result.

7) Press "Stop" to stop the running program and save the video. When "loop" mode is selected, the program will process the first image after processing the last one until stop is pressed. When loop mode is not selected, the program will end and save the video after processing the last one.

8) You can change your settings in steps (1) - (5) when and only when the process stops/ends. Please note that changing the settings while processing will not affect your current result.


