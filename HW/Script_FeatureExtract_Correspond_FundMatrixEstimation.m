%% Load images
Image1 =imread('sceneL.png');
IGray1 = rgb_to_gray(Image1);
Image2 =imread('sceneR.png');
IGray2 = rgb_to_gray(Image2);

%% Calculate Harris features
features1 = harris_detector(IGray1,'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);
features2 = harris_detector(IGray2,'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);

%% Correspondence estimation
correspondences = point_correspondence(IGray1,IGray2,features1,features2,'window_length',25,'min_corr',0.9,'do_plot',false);

%% Determine robust corresponding image points with the RANSAC algorithm
correspondences_robust= F_ransac(correspondences, 'tolerance', 0.04)

%% Visualize robust corresponding image points
overlap_img = 0.5*double(IGray1) + 0.5*double(IGray2);
figure,imshow(uint8(overlap_img));  
hold on;
plot(correspondences_robust(1,:), correspondences_robust(2,:),'o');  %用来标记点的核心语句
plot(correspondences_robust(3,:), correspondences_robust(4,:),'o');
for i = 1: size(correspondences_robust,2)
    plot([correspondences_robust(1,i) correspondences_robust(3,i)],[correspondences_robust(2,i) correspondences_robust(4,i)],'b')
end

%% Calculate essential matrix
load('K.mat');
E = epa(correspondences_robust,K);
disp(E);
%% 
[T1, R1, T2, R2, ~, ~] = TR_from_E(E);
%% 
x1_uncalibrate = correspondences_robust(1:2,:);
x1_uncalibrate(3,:) = 1;
x1 = inv(K)*x1_uncalibrate;

x2_uncalibrate = correspondences_robust(3:4,:);
x2_uncalibrate(3,:) = 1;
x2 = inv(K)*x2_uncalibrate;

N =size(correspondences_robust,2);
T_cell = {T1,T2,T1,T2};
R_cell = {R1,R1,R2,R2};

intial_depth = zeros(N,2);
d_cell = {intial_depth,intial_depth,intial_depth,intial_depth};
%% 
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

%% 

 for i = 1:size(x1,2)
    P1(:,i) = x1(:,i)*lambda(i,1);
 end 
 
 P2_world = R*P1 + T;
 P2_backprojected = P2_world./repmat(P2_world(end,:),3,1);
 x2_repro = K*P2_backprojected;
 
 sum(sqrt(sum((x2_uncalibrate-x2_repro).^2)))/size(x2_repro,2)