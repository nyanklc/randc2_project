function dx = unicycle_model(t,x, ...
    xd_fun,yd_fun, ...
    xd_dot_fun,yd_dot_fun, ...
    xd_ddot_fun,yd_ddot_fun)

%% ---------------- State ----------------
X = x(1);
Y = x(2);
theta = x(3);

%% ---------------- Desired trajectory ----------------
xd = xd_fun(t);
yd = yd_fun(t);

xd_dot  = xd_dot_fun(t);
yd_dot  = yd_dot_fun(t);
xd_ddot = xd_ddot_fun(t);
yd_ddot = yd_ddot_fun(t);

v_d = sqrt(xd_dot^2 + yd_dot^2);
theta_d = atan2(yd_dot,xd_dot);

omega_d = (xd_dot*yd_ddot - yd_dot*xd_ddot) / ...
          (xd_dot^2 + yd_dot^2 + 1e-6);

%% ---------------- Tracking errors ----------------
e1 =  cos(theta)*(xd - X) + sin(theta)*(yd - Y);
e2 = -sin(theta)*(xd - X) + cos(theta)*(yd - Y);
e3 = wrapToPi(theta_d - theta);

%% ---------------- Linearized error controller ----------------
% === IMPROVEMENT #2: pole-placement gains ====================
xi = 0.9;        % damping
a  = 1.2;        % natural frequency

k1 = 2*xi*a;
k3 = 2*xi*a;
k2 = (a^2 - omega_d^2)/(v_d + 1e-6);

u1 = -k1*e1;
u2 = -k2*e2 - k3*e3;

%% ---------------- Input transformation ----------------
v = v_d*cos(e3) - u1;
omega = omega_d - u2;

% === IMPROVEMENT #3: actuator saturation ====================
v = max(min(v,1.5),-1.5);
omega = max(min(omega,2.5),-2.5);

%% ---------------- Unicycle dynamics ----------------
dx = zeros(3,1);
dx(1) = v*cos(theta);
dx(2) = v*sin(theta);
dx(3) = omega;

end
