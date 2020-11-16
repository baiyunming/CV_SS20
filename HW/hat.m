function W = hat(w)
    % This function implements the ^-operator.
    % It converts a 3x1-vector into a skew symmetric matrix.
    w1 = w(1);
    w2 = w(2);
    w3 = w(3);
    W = [0 -w3 w2; w3 0 -w1; -w2 w1 0];
end
