%% Computer Vision Challenge 2020 challenge.m

%% Start timer here
tic
%% Generate Movie
movie_writer = VideoWriter(dest,'Motion JPEG AVI');
movie_writer.FrameRate=10;
open(movie_writer);
movie_index = 1;

% global variable frame_counter
global frame_counter;
frame_counter = 0;

while loop ~= 1
 
%if first loop or frame_counter reach threhold: update update background by reading next N (for example 60) images
if frame_counter==0 |frame_counter==100
    ir.N = 100;
    frame_counter=1;
else
%no need to update the background, only read next 1 image
    ir.N =1;
end

% Get next image tensors
[left,right,loop] = ir.next();

 % Generate binary mask
mask = segmentation(left,right);

% Render new frame
result = render(left(:,:,1:3),mask,bg,mode);

%variable movie cell, each entry contain the result of each image  
movie{movie_index} = result; 
movie_index = movie_index+1;

%% Write Movie to Disk
  if store   
  writeVideo(movie_writer, uint8(result));
  end
  
frame_counter=frame_counter+1;

end
close(movie_writer);

%% Stop timer here
elapsed_time = 0;
toc;
