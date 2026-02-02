function dx = posture_regulation(t, x, xd, yd, thetad) % t probably is useless cause posture regulation does not
% depend on time t but idkkkkk
    X = x(1);
    Y = x(2);
    theta = x(3);
    e_x = xd - X;
    e_y = yd - Y;
    e_theta = wrapToPi(thetad - theta);
    % change of coordinates
    rho = sqrt(e_x^2 + e_y^2):
    gamma = atan2(e_y, e_x) + pi - theta;
    delta = gamma + e_theta;
    gamma = wrapToPi(gamma);
    delta = wrapToPi(delta);
    k1 = 0.8; % random values 
    k2 = 1.5;
    k3 = 0.5;
    v = k1*rho*cos(gamma);
    omega = k2*gamma + (k1*sin(gamma)*cos(gamma)/(gamma+1e-6))*(gamma + k3*delta);
    % === IMPROVEMENT: actuator saturation ====================
    v = max(min(v,1.5),-1.5);
    omega = max(min(omega,2.5),-2.5);
    if rho < 0.05 && abs(delta) < 0.05 % desired pose reached, stop unicycle motion
        v = 0;
        omega = 0;
    end
    dx = zeros(3,1);
    dx(1) = v*cos(theta);
    dx(2) = v*sin(theta);
    dx(3) = omega;
end

