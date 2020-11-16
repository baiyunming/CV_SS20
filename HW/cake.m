function Cake = cake(min_dist)
    % The cake function creates a "cake matrix" that contains a circular set-up of zeros
    % and fills the rest of the matrix with ones. 
    % This function can be used to eliminate all potential features around a stronger feature
    % that don't meet the minimal distance to this respective feature.
    [X,Y]=meshgrid(-min_dist:min_dist,-min_dist:min_dist);
    Cake=sqrt(X.^2+Y.^2)>min_dist;
    
    
end