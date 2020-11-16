%% Computer Vision Challenge 2020 config.m

%% Generall Settings
% Group number:
group_number = 18;

% Group members:
members = {'Yunming Bai', 'Di Wu','Qiufan Zhu', 'Yue Gao','Bowen Song'};

% Email-Address (from Moodle!):
mail = {'ge75lup@mytum.de', 'di.wu@tum.de','Qiufan.zhu@tum.de','ge35riy@tum.de','bowen.song@tum.de'};


%% Setup Image Reader
% Specify Scene Folder, absolue or relative path possible
src =  'F:\TUM Learning Material\20SS\Computer Vision\database\P1E_S1';
%src = '.\P2E_S2';

% Select Cameras
L =1;
R =2;

% Choose a start point
start = 20;

% Choose the number of succseeding frames
N =100;

% Instantiate object Imagereader
ir = ImageReader(src, L, R, start, N);
%ir = ImageReader(src, L, R, N);

%% Output Settings
% Output Path
dest = '.\output_P1E_S1.avi';

% Load Virual Background static image
bg = imread("background.jpg");

% if background videom, set bg as a videoreader
%bg = VideoReader('bg_video.mp4');

% Select rendering mode
mode = "foreground";

% Store Output?
store = true;

loop=0;
