function [Fx, Fy] = sobel_xy(input_image)
    % In this function you have to implement a Sobel filter 
    % that calculates the image gradient in x- and y- direction of a grayscale image.
    solberHorizontal = [1 0 -1; 2 0 -2; 1 0 -1];
    solberVertical = [1 2 1; 0 0 0 ; -1 -2 -1];
    Fx = conv2(input_image, solberHorizontal,'same');
    Fy = conv2(input_image, solberVertical,'same');   
end