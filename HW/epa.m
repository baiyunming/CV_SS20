function EF = epa(correspondences, K)
    % Depending on whether a calibrating matrix 'K' is given,
    % this function calculates either the essential or the fundamental matrix
    % with the eight-point algorithm.

    if nargin==1
        K = [1,0,0;0,1,0;0,0,1];
    end
        
    x1 = correspondences(1:2,:);
    x2 = correspondences(3:4,:);    
    x1(3,:) = 1;
    x2(3,:) = 1;
    
    x1 = inv(K)*x1;
    x2 = inv(K)*x2;
    
    for i = 1: size(correspondences,2)
        A(i,:) = kron(x1(:,i),x2(:,i));
    end
    
    [~,~,V] = svd(A);
    
 %% Estimation of the matrices
    % x1, x2        homogeneous (calibrated) coordinates       
    % A             matrix A for the eight-point algorithm
    % V             right-singular vectors
    
    last_sigular_vector = V(:,end);
    reshaped_matrix = reshape(last_sigular_vector,3,3);
    [ess_u,ess_sigma,ess_v] =  svd(reshaped_matrix);
    
    if nargin==1
        EF = ess_u*[ess_sigma(1,1) 0 0;0 ess_sigma(2,2) 0 ;0 0 0]*ess_v';
    else
        EF = ess_u*[1 0 0; 0 1 0; 0 0 0]*ess_v';   
    end
    
    
    
end