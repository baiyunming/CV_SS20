function [correspondences_robust, largest_set_F] = F_ransac(correspondences, varargin)
    % This function implements the RANSAC algorithm to determine 
    % robust corresponding image points
    
 %% Input parser
    % Known variables:
    % epsilon       estimated probability
    % p             desired probability
    % tolerance     tolerance to belong to the consensus-set
    % x1_pixel      homogeneous pixel coordinates
    % x2_pixel      homogeneous pixel coordinates
    
    default_epsilon = 0.5;
    default_p = 0.5;
    default_tolerance = 0.01;
    
    pp = inputParser;
    valid_epsilon = @(x) isnumeric(x) && (x>0) && (x<1);
    addParameter(pp,'epsilon',default_epsilon,valid_epsilon);
    
    valid_p = @(x) isnumeric(x) && (x>0) && (x<1);
    addParameter(pp,'p',default_p,valid_p);
   
    valid_tolerance = @(x) isnumeric(x) ;
    addParameter(pp,'tolerance',default_tolerance,valid_tolerance);
   
    parse(pp,varargin{:});
   
    epsilon = pp.Results.epsilon;
    p =  pp.Results.p;
    tolerance = pp.Results.tolerance;
    
    
    x1_pixel = correspondences(1:2,:);
    x2_pixel = correspondences(3:4,:);    
    x1_pixel(3,:) = 1;
    x2_pixel(3,:) = 1;

%% RANSAC algorithm preparation

    k = 8;
    s = log(1-p)/log(1-(1-epsilon)^k);
    largest_set_size = 0;
    largest_set_dist = Inf;
    largest_set_F = zeros(3);
     
 %% RANSAC algorithm
    for i = 1:s

        index = randi([1,size(correspondences,2)],1,k);
        corre_random_chosen = correspondences(:,index);

        F_estimate = epa(corre_random_chosen);
        sampson_distance = sampson_dist(F_estimate, x1_pixel, x2_pixel);

        inlier_index = find(sampson_distance<tolerance);
        curren_set_size = numel(inlier_index);
        current_sd = sum(sampson_distance(inlier_index));

        if curren_set_size > largest_set_size | (curren_set_size > largest_set_size & current_sd<largest_set_dist)
            largest_set_size = curren_set_size;
            largest_set_dist = current_sd;
            largest_set_F = F_estimate;
            largest_set_index = inlier_index;
        end
       
    end
    
    correspondences_robust = correspondences(:,largest_set_index);
    
    
end


