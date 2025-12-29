%% ============================================================
%  UNICYCLE TRAJECTORY TRACKING
%  State-error linearization controller (Fig. 1.12 - middle)
%  ============================================================

clear; clc; close all;

%% ---------------- Simulation parameters ---------------------
Ts = 0.01;          % Sampling time
t_end = 40;         % Simulation duration
tspan = [0 t_end];

%% ---------------- Desired trajectory (closed) ----------------
t_ref = 0:Ts:t_end;

R = 10;             % radius
w_traj = 0.2;       % angular speed

xd_ref = R*cos(w_traj*t_ref);
yd_ref = R*sin(w_traj*t_ref);

% === IMPROVEMENT #1: smooth derivatives ======================
xd_dot_ref = gradient(xd_ref, Ts);
yd_dot_ref = gradient(yd_ref, Ts);

xd_dot_ref = smoothdata(xd_dot_ref,'movmean',15);
yd_dot_ref = smoothdata(yd_dot_ref,'movmean',15);

xd_ddot_ref = gradient(xd_dot_ref, Ts);
yd_ddot_ref = gradient(yd_dot_ref, Ts);

xd_ddot_ref = smoothdata(xd_ddot_ref,'movmean',15);
yd_ddot_ref = smoothdata(yd_ddot_ref,'movmean',15);

% Interpolants
xd_fun      = @(t) interp1(t_ref,xd_ref,t,'linear','extrap');
yd_fun      = @(t) interp1(t_ref,yd_ref,t,'linear','extrap');
xd_dot_fun  = @(t) interp1(t_ref,xd_dot_ref,t,'linear','extrap');
yd_dot_fun  = @(t) interp1(t_ref,yd_dot_ref,t,'linear','extrap');
xd_ddot_fun = @(t) interp1(t_ref,xd_ddot_ref,t,'linear','extrap');
yd_ddot_fun = @(t) interp1(t_ref,yd_ddot_ref,t,'linear','extrap');

%% ---------------- Initial condition --------------------------
x0 = [-5; -5; pi/4];

%% ---------------- Simulation --------------------------------
[t,x] = ode45(@(t,x) unicycle_model( ...
    t,x, ...
    xd_fun,yd_fun, ...
    xd_dot_fun,yd_dot_fun, ...
    xd_ddot_fun,yd_ddot_fun), tspan, x0);

%% ---------------- Plot trajectory ---------------------------
figure;
plot(x(:,1),x(:,2),'b','LineWidth',2); hold on;
plot(xd_fun(t),yd_fun(t),'r--','LineWidth',2);
legend('Actual','Desired');
axis equal; grid on;
xlabel('x [m]'); ylabel('y [m]');
title('Unicycle trajectory tracking (state-error linearization)');

%% ---------------- Plot tracking error -----------------------
e_norm = zeros(length(t),1);

for k = 1:length(t)
    X = x(k,1); Y = x(k,2); theta = x(k,3);
    xd = xd_fun(t(k)); yd = yd_fun(t(k));
    e1 =  cos(theta)*(xd - X) + sin(theta)*(yd - Y);
    e2 = -sin(theta)*(xd - X) + cos(theta)*(yd - Y);
    e3 = 0; % only position error norm shown
    e_norm(k) = sqrt(e1^2 + e2^2);
end

figure;
plot(t,e_norm,'LineWidth',2);
grid on;
xlabel('Time [s]');
ylabel('||e_p||');
title('Position tracking error norm');
