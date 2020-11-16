function [repro_error, x2_repro] = backprojection(correspondences, P1, Image2, T, R, K)
    % This function calculates the mean error of the back projection
    % of the world coordinates P1 from image 1 in camera frame 2
    % and visualizes the correct feature coordinates as well as the back projected ones.
    P2_world = R*P1 + T;
    P2_backprojected = P2_world./repmat(P2_world(end,:),3,1);
    x2_repro = K*P2_backprojected;
    
    x2 = correspondences(3:4,:);
    x2(3,:) = 1;
    
    repro_error = sum(sqrt(sum((x2-x2_repro).^2)))/size(x2_repro,2);
    
    figure,imshow(uint8(Image2));  
    hold on;
   
    
    for i = 1: size(x2,2)
         plot(x2(1,i), x2(2,i),'o');
         text(x2(1,i), x2(2,i),int2str(i));
         plot(x2_repro(1,:), x2_repro(2,:),'o');
         text(x2_repro(1,i), x2_repro(2,i),int2str(i));
         plot([x2(1,i) x2_repro(1,i)],[x2(2,i) x2_repro(2,i)],'b')
    end

    
end