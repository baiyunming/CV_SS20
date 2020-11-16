function cor = point_correspondence(I1, I2, Ftp1, Ftp2, varargin)
    % In this function you are going to compare the extracted features of a stereo recording
    % with NCC to determine corresponding image points.
    
    %% Input parser
    default_WindowLength = 25;
    default_min_corr = 0.95;
    default_doPlot = false;
    
    p = inputParser;
    valid_WindowLength = @(x) isnumeric(x) && (mod(x,2)==1) && (x > 1);
    addParameter(p,'window_Length',default_WindowLength,valid_WindowLength);
   
    valid_min_corr = @(x) isnumeric(x) && (x > 0)&& (x < 1);
    addParameter(p,'min_corr',default_min_corr,valid_min_corr);
    
    validdoPlot = @(x) islogical(x) ;
    addParameter(p,'do_plot',default_doPlot,validdoPlot);
   
    parse(p,varargin{:});
   
    window_length = p.Results.window_Length;
    min_corr =  p.Results.min_corr;
    do_plot = p.Results.do_plot;
    Im1 = double(I1);
    Im2 = double(I2);

%% Feature preparation

for i = 1:size(Ftp1,2)
    if Ftp1(1,i)<((1+window_length)/2) |  Ftp1(1,i)> (size(I1,2)-(window_length-1)/2) | Ftp1(2,i)<((1+window_length)/2) | Ftp1(2,i)> (size(I1,1)-(window_length-1)/2)
        Ftp1(1,i) = 0;
        Ftp1(2,i) = 0;
    end
end

colsWithZeros = any(Ftp1==0);
Ftp1 = Ftp1(:, ~colsWithZeros);
no_pts1 = size(Ftp1,2);

for i = 1:size(Ftp2,2)
    if Ftp2(1,i)<((1+window_length)/2) | Ftp2(1,i)> (size(I1,2)-(window_length-1)/2) | Ftp2(2,i)<((1+window_length)/2) | Ftp2(2,i)> (size(I1,1)-(window_length-1)/2)
        Ftp2(1,i) = 0;
        Ftp2(2,i) = 0;
    end
end

colsWithZeros = any(Ftp2==0);
Ftp2 = Ftp2(:, ~colsWithZeros);
no_pts2 = size(Ftp2,2);
%% Normalization
    Mat_feat_1 = zeros(window_length^2,size(Ftp1,2));
    block = zeros(window_length, window_length);
    a = (window_length-1)/2;
    for i = 1: size(Ftp1,2)
        block = Im1((Ftp1(2,i)-a):(Ftp1(2,i)+a),(Ftp1(1,i)-a):(Ftp1(1,i)+a));
        block = block - mean(block(:));
        block = block/std(double(block),0,'all');
        Mat_feat_1(:,i) = block(:);
    end
    
    Mat_feat_2 = zeros(window_length^2,size(Ftp2,2));
    for i = 1: size(Ftp2,2)
        block = Im2((Ftp2(2,i)-a):(Ftp2(2,i)+a),(Ftp2(1,i)-a):(Ftp2(1,i)+a));
        block = block - mean(block(:));
        block = block/std(double(block),0,'all');
        Mat_feat_2(:,i) = block(:);
    end    
    
%% NCC calculations
    NCC_matrix = zeros(no_pts2, no_pts1);
    for i = 1: no_pts2
        for j = 1: no_pts1
            NCC_matrix(i,j) = dot(Mat_feat_2(:,i),Mat_feat_1(:,j))/(window_length^2-1);
        end
    end
    
    NCC_matrix(NCC_matrix < min_corr) = 0;
    
    [sort_array, sort_index_all] = sort(NCC_matrix(:), 'descend');
    sorted_index = sort_index_all(sort_array~=0);

%% Correspondeces matrix 

 cor = [];
 ind = 1;
 
    while ind <= numel(sorted_index) 
        [ind_p2, ind_p1] = ind2sub(size(NCC_matrix),sorted_index(ind)); 
        point_pair = [Ftp1(:,ind_p1);Ftp2(:,ind_p2)];
        cor = [cor point_pair];
       
       
        nonzero_p1 = sum(NCC_matrix(:,ind_p1)~=0);
        nonzero_p2 = sum(NCC_matrix(ind_p2,:)~=0);
        NCC_matrix(:,ind_p1) = 0;
        NCC_matrix(ind_p2,:) = 0;
        
        ind = ind+1;
        
        if nonzero_p1  ~= 1 |nonzero_p2 ~= 1
             [sort_array, sort_index_all] = sort(NCC_matrix(:), 'descend');
             sorted_index = sort_index_all(sort_array~=0);
             ind =1;
        end
        
        if numel(sorted_index) == 0
            break;
        end
   
    end

%% Visualize the correspoinding image point pairs
if do_plot
    K = 0.5*Im1 + 0.5*Im2;
    figure,imshow(uint8(K));  
   
    hold on;
    plot(cor(1,:), cor(2,:),'o');  %用来标记点的核心语句
    plot(cor(3,:), cor(4,:),'o');
    for i = 1: size(cor,2)
        plot([cor(1,i) cor(3,i)],[cor(2,i) cor(4,i)],'b')
    end
end
   

end