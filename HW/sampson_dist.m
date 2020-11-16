function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % This function calculates the Sampson distance based on the fundamental matrix F

    e3_hat=[0   -1   0 ;
        1    0   0 ;
        0    0   0  ];
    
    sd = (diag(x2_pixel'*F*x1_pixel).^2)./(vecnorm(e3_hat*F*x1_pixel).^2 + (vecnorm((x2_pixel'*F*e3_hat)').^2))';
    sd = sd';
    
end