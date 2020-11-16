clc;
clear all;
close all;

img = imread('sceneL.png');
gray = rgb_to_gray(img);
min_dist = 40;
N = 20;
tile_size = [200, 200];

% Run learner solution.
[features ,acc_array]= harris_detector(gray, 'min_dist', min_dist, 'N', N, 'tile_size', tile_size, 'do_plot', true);
title('Your Solution')