function [features ]= harris_detector(input_image, varargin)
 % In this function you are going to implement a Harris detector that extracts features
 % from the input_image.
 
 %% Input parser
   % segment_length    size of the image segment
   % k                 weighting between corner- and edge-priority
   % tau               threshold value for detection of a corner
   % do_plot           image display variable
   % min_dist          the minimal distance in pixels of two features (standard value: 20)
   % tile_size         defines the tile size; depending on the input either the side length of a quadratic tile or a vector with two entries for height and width of the tile (standard value: 200)
   % N                 the maximal number of features per tile (standard value: 5)
   
   default_Segment_length = 15;
   default_K = 0.05;
   default_Tau = 10^6;
   default_doPlot = false;
   default_min_dist = 20;
   default_tile_size = [200 200];
   default_N = 5;
   
   p = inputParser;
   
   validSegment = @(x) isnumeric(x) && (mod(x,2)==1) && (x > 1);
   addParameter(p,'segment_length',default_Segment_length,validSegment);
   
   validK = @(x) isnumeric(x) && (x<=1) && (x >= 0);
   addParameter(p,'k',default_K,validK);
   
   validTau = @(x) isnumeric(x) && (x > 0);
   addParameter(p,'tau',default_Tau,validTau);
    
   validdoPlot = @(x) islogical(x) ;
   addParameter(p,'do_plot',default_doPlot,validdoPlot);
   
   validmin_dist = @(x) isnumeric(x) && (x > 1);
   addParameter(p,'min_dist',default_min_dist,validmin_dist);
   
   valid_tile_size = @(x) isnumeric(x);
   addParameter(p,'tile_size',default_tile_size,valid_tile_size);
   
   valid_N = @(x) isnumeric(x) && (x > 1);
   addParameter(p,'N',default_N,valid_N);
   
   parse(p,varargin{:});
   
   % Extrahiere die Variablen aus dem Input-Parser
   segment_length= p.Results.segment_length; 
   k =  p.Results.k;
   tau = p.Results.tau;
   do_plot = p.Results.do_plot;
   min_dist =  p.Results.min_dist;
   N = p.Results.N;
   
   % Falls bei der Kachelgr??e nur die Kantenl?nge angegeben wird, verwende
   % quadratische Kachel
   tile_size = p.Results.tile_size;
   if numel(tile_size) == 1
    tile_size=[tile_size,tile_size];
   end
   
%% Preparation for feature extraction
    % Ix, Iy            image gradient in x- and y-direction
    % w                 weighting vector
    % G11, G12, G22     entries of the Harris matrix
    
    % Check if it is a grayscale image
    channel = size(input_image, 3);
    if channel == 3
        error("Image format has to be NxMx1")
        return; 
    end
    
    % Approximation of the image gradient
    input_image = double(input_image);
    [Ix, Iy] = sobel_xy(input_image);
    G11_unfilter = Ix.*Ix;
    G12_unfilter = Ix.*Iy;
    G22_unfilter = Iy.*Iy;
    % Weighting
    w = fspecial('gaussian',[segment_length 1] ,segment_length/4);
    % Harris Matrix G
    G11 = conv2(G11_unfilter,w*w','same');
    G12 = conv2(G12_unfilter,w*w','same');
    G22 = conv2(G22_unfilter,w*w','same');
    
 %% Feature extraction with the Harris measurement
    H = G11.*G22 - G12.^2 - k * (G11 +G22).^2;
    
    % Bei der vorherigen Faltung wurden die R?nder automatisch mit Nullen
    % aufgef¨¹llt, wodurch die Harrismessung im Randbereicht des Bildes hohe
    % Ausschl?ge liefert. Diese Werte werden nun mit Null ¨¹berschrieben.
    %H = H.*zeroBorder(H,ceil(segment_length/2));

    %Schwellwertbildung der Merkmale
    corners = H .* (H>tau);
    
    [row, column] = find(corners);
    features(1,:) = column;
    features(2,:) = row; 
       
%% Feature preparation
    % add zero border
    corners_with_border = zeros(size(corners,1)+2*min_dist,size(corners,2)+2*min_dist);
    corners_with_border((min_dist+1:min_dist+size(corners,1)),min_dist+1:min_dist+size(corners,2)) = corners;
    corners =  corners_with_border;
    
    % sort all elemnts in corners
    [sort_array, sort_index_all] = sort(corners(:), 'descend');
    
    sorted_index = sort_index_all(sort_array~=0);

 %% Accumulator array
    row_acc_array = ceil(size(input_image,1)/tile_size(1));
    column_acc_array = ceil(size(input_image,2)/tile_size(2));
    acc_array = zeros( row_acc_array, column_acc_array );
    
    maximal_features = row_acc_array * column_acc_array * N ;
    num_detected_feature = numel(sorted_index);
    
    features = zeros(2,min(maximal_features,num_detected_feature ));

 %% 
    num_detected_feature = numel(sorted_index);
    Cake = cake(min_dist);
    feature_counter = 1 ;
    
    for ind = 1:num_detected_feature
        if corners(sorted_index(ind)) == 0
            continue;
        else
            [row, col] = ind2sub(size(corners),sorted_index(ind)); 
            
            tile_row = ceil((row-min_dist)/tile_size(1));
            tile_col = ceil((col-min_dist)/tile_size(2));
    
            corners(row-min_dist:row+min_dist, col-min_dist:col+min_dist) = corners(row-min_dist:row+min_dist, col-min_dist:col+min_dist) .* Cake;
            acc_array(tile_row,tile_col) =  acc_array(tile_row,tile_col) +1 ;
            features(1,feature_counter) = col-min_dist;
            features(2,feature_counter) = row-min_dist;
            feature_counter = feature_counter + 1;
                
            if  acc_array(tile_row,tile_col) == N
                corners((((tile_row-1)*tile_size(1))+1+min_dist):min(size(corners,1),tile_row*tile_size(1)+min_dist),(((tile_col-1)*tile_size(2))+1+min_dist):min(size(corners,2),tile_col*tile_size(2)+min_dist))=0;   
            end
                    
        end
    end
    
    
    features = features(:,1: feature_counter-1);
   
%% Plot
 if do_plot
            imshow(uint8(input_image));
            hold on; 
            plot(features(1,:),features(2,:),'r+', 'MarkerSize', 10, 'LineWidth', 2)
        
    
end