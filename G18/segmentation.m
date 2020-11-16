function [mask] = segmentation(left,right)
% Add function description here
%% extract the background
persistent mode_backgrond;
if size(left,3) > 6                                                                         %% tell if the background need to be updated
    cell_image = mat2cell(left,size(left,1),size(left,2),repmat(3,1,size(left,3)/3));       %% read the pictures and save as gray form
     for i = 1:size(cell_image,3)
        matrix_image_gray(:,:,i) = rgb2gray(cell_image{i});
     end
      mode_backgrond= mode(matrix_image_gray,3);                                            %% the pixel intensity with the highest frequency are regarded as background
end
%% set conditions to take out the frontground
current_frame =rgb2gray(left(:,:,1:3));                                                     %% the picture to be process
back_subtraction  = uint8(abs(double(current_frame)-double(mode_backgrond)));               %% the intensity between the picture and the background
back_subtraction = medfilt2(back_subtraction,[6 6]);                                        %% use Median filter to remove noise
thresh_tell = double(back_subtraction)./min(double(mode_backgrond),double(current_frame));  %% add weight to the change of pixel intensity 
index1 = find(thresh_tell>0.5);                                                             %% tell if the change of intensity is bigger than threshhold 
index2 = find(back_subtraction>20);                                                         %% tell if the weighted change of intensity is bigger than threshhold
%%  take out the pixels that satify both conditions
index= intersect(index1,index2);                                                            %% index of pixels satisfy both conditons
mask = zeros(size(back_subtraction));                                                       %% establish the mask
mask(index) = 1;
%% post-processing
se = strel('disk',2);
mask=imdilate(mask,se);                                                                     %% dilate the mask 
se = strel('disk',4);
mask =imclose(mask,se);                                                                     %% performs morphological closing on the mask
mask = bwareaopen(mask,4000);                                                               %% Remove small objects from mask
mask =imfill(mask,'hole');                                                                  %% fills holes
se = strel('disk',16);                                                                      %% performs morphological closing on the mask with bigger tructuring element
mask=uint8(imfill((imclose(mask,se)),'hole'));                                              %% fills holes
mask = uint8(mask);                                                                         %% return mask in uint8 form, in order to directly process the image by multiplication
end