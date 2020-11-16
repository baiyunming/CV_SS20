function [T, R, lambda]  = reconstruction(T1, T2, R1, R2, correspondences, K)
    %% Preparation
    x1_uncalibrate = correspondences(1:2,:);
    x1_uncalibrate(3,:) = 1;
    x1 = inv(K)*x1_uncalibrate;

    x2_uncalibrate = correspondences(3:4,:);
    x2_uncalibrate(3,:) = 1;
    x2 = inv(K)*x2_uncalibrate;

    N =size(correspondences,2);
    
    T_cell = {T1,T2,T1,T2};
    R_cell = {R1,R1,R2,R2};

    intial_depth = zeros(N,2);
    d_cell = {intial_depth,intial_depth,intial_depth,intial_depth};
    
%% Reconstruction
for m = 1:4
    M1 = zeros(3*N,N+1);
    M2 = zeros(3*N,N+1);
    for i = 1:N
        M1(1+(i-1)*3:i*3,i) = hat(x2(:,i))*R_cell{1,m}*x1(:,i);
        M1(1+(i-1)*3:i*3,N+1)=  hat(x2(:,i))* T_cell{1,m};
    end

    for j = 1:N
        M2(1+(j-1)*3:j*3,j) = hat(x1(:,j))*R_cell{1,m}'*x2(:,j);
        M2(1+(j-1)*3:j*3,N+1)=  -hat(x1(:,j))* R_cell{1,m}'*T_cell{1,m};
    end

    [~,~,V1] = svd(M1);
    r1 = V1(:,end)/V1(end,end);

    [~,~,V2] = svd(M2);
    r2 = V2(:,end)/V2(end,end);

    d_cell{1,m}(:,1) = r1(1:end-1,:);
    d_cell{1,m}(:,2) = r2(1:end-1,:);
end

num_positive = zeros(1,4);
for i = 1:4
     num_positive(1,i) = length(nonzeros(d_cell{1,i}(d_cell{1,i}>0)));
end

[~,ind] = max(num_positive);
T = T_cell{1,ind}; 
R = R_cell{1,ind};
lambda = d_cell{1,ind};

    %% Calculation and visualization of the 3D points and the cameras
    for i = 1:size(x1,2)
    P1(:,i) = x1(:,i)*lambda(i,1);
    end 

    scatter3(P1(1,:),P1(2,:), P1(3,:));
    for i = 1:size(P1,2)
        text(P1(1,i),P1(2,i), P1(3,i),int2str(i));
    end
    hold on;
    camC1 = [-0.2,0.2,0.2,-0.2;0.2,0.2,-0.2,-0.2;1,1,1,1];
    camC2 = [R'*camC1(:,1)-R'*T,R'*camC1(:,2)-R'*T,R'*camC1(:,3)-R'*T,R'*camC1(:,4)-R'*T];

    plot3([camC1(1,:),camC1(1,1)],[camC1(2,:),camC1(2,1)],[camC1(3,:),camC1(3,1)],'b');
    text(camC1(1,1),camC1(2,1),camC1(3,1),'Cam1');
    plot3([camC2(1,:),camC2(1,1)],[camC2(2,:),camC2(2,1)],[camC2(3,:),camC2(3,1)],'r');
    text(camC2(1,1),camC2(2,1),camC2(3,1),'Cam2')

    xlabel('Z');
    ylabel('X');
    zlabel('Y');
    grid on;
    
    campos([43, -22,-87]);
    camup([0,-1,0]);    
end