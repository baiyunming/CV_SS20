function [T1, R1, T2, R2, U, V] = TR_from_E(E)
    % This function calculates the possible values for T and R 
    % from the essential matrix
    [U,S,V] = svd(E);
    if det(U) < 0  
    U = U*diag([1,1,-1]);
    end
    
    if det(U) < 0  
    U = U*diag([1,1,-1]);
    end
    
    if det(V) < 0  
    V = V*diag([1,1,-1]);
    end

    Rz1 = [0 -1 0; 1 0 0 ; 0 0 1];
    Rz2 = [0  1 0;-1 0 0 ; 0 0 1];
    
    R1 = U*Rz1'*V';
    R2 = U*Rz2'*V';
    
    T1hat = U*Rz1*S*U';
    T2hat = U*Rz2*S*U';
    
    T1 = [T1hat(3,2);T1hat(1,3);T1hat(2,1)];
    T2 = [T2hat(3,2);T2hat(1,3);T2hat(2,1)];
    
    
end