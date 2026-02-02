function dx = posture_regulation(t, x, xd, yd, thetad)
    X = x(1)
    Y = x(2)
    theta = x(3)
    e_x = xd - X
    e_y = y_d - Y
    e_theta = thetad - theta
    % change of coordinates
    rho = sqrt(e_x^2 + e_y^2)
    gamma = atan2(e_y, e_x) + pi - theta
    delta = gamma + e_theta
    gamma = wrapToPi(gamma);
    delta = wrapToPi(delta);
    k1 = 0.8
    k2 = 1.5
    k3 = 0.5
    v = k1*rho*cos(gamma)
    omega = k2*gamma + (k1*sin(gamma)*cos(gamma)/gamma*(gamma + k3*delta)
    dx = zeros(3,1);
    dx(1) = v*cos(theta);
    dx(2) = v*sin(theta);
    dx(3) = omega;

