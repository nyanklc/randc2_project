%% Unicycle Controller Following Predefined Trajectory
clear; clc; close all;

%% Select trajectory and controller
sim_trajectory_id = 3;  % Which trajectory to track
controller_type = 3;    % 1, 2, or 3

%% Load trajectory
load('trajectories.mat');
traj = trajectories("trajectory" + sim_trajectory_id);

% Time and position
t_data = traj.xd_ts.Time;
xd_data = traj.xd_ts.Data;
yd_data = traj.yd_ts.Data;

% Velocity approximation
xd_dot_data = gradient(xd_data, t_data);
yd_dot_data = gradient(yd_data, t_data);

% Interpolation functions
xd_fun = @(t) interp1(t_data, xd_data, t, 'linear', 'extrap');
yd_fun = @(t) interp1(t_data, yd_data, t, 'linear', 'extrap');
xd_dot_fun = @(t) interp1(t_data, xd_dot_data, t, 'linear', 'extrap');
yd_dot_fun = @(t) interp1(t_data, yd_dot_data, t, 'linear', 'extrap');

%% Simulation
x0 = [0;0;0];          % initial state
tspan = [t_data(1), t_data(end)];

[t, x] = ode45(@(t,x) unicycle(t,x,controller_type,xd_fun,yd_fun,xd_dot_fun,yd_dot_fun), tspan, x0);

%% Plot results
xd_plot = xd_fun(t);
yd_plot = yd_fun(t);

figure;
plot(x(:,1), x(:,2),'b','LineWidth',2); hold on;
plot(xd_plot, yd_plot,'r--','LineWidth',2);
legend('Actual','Desired');
xlabel('X'); ylabel('Y'); grid on; axis equal;
title(['Trajectory Tracking | Controller ',num2str(controller_type)]);

%% ===== Unicycle Dynamics =====
function dx = unicycle(t,x,ctrl_type,xd_fun,yd_fun,xd_dot_fun,yd_dot_fun)
    X = x(1); Y = x(2); theta = x(3);

    % Desired trajectory
    xd = xd_fun(t); 
    yd = yd_fun(t);
    xd_dot = xd_dot_fun(t); 
    yd_dot = yd_dot_fun(t);
    % Approximate acceleration as zero (or compute from derivative if needed)
    xd_ddot = 0;
    yd_ddot = 0;

    % Desired speed and orientation
    v_d = sqrt(xd_dot^2 + yd_dot^2);
    theta_d = atan2(yd_dot, xd_dot);
    omega_d = (xd_dot*yd_ddot - yd_dot*xd_ddot)/(xd_dot^2 + yd_dot^2 + 1e-6);

    % Tracking errors in robot frame
    e1 =  cos(theta)*(xd - X) + sin(theta)*(yd - Y);
    e2 = -sin(theta)*(xd - X) + cos(theta)*(yd - Y);
    e3 = wrapToPi(theta_d - theta);

    % Controllers
    switch ctrl_type
        case 1
            k1=1; 
            k2=2; 
            k3=2;
            u1 = -k1*e1; 
            u2 = -k2*e2 - k3*e3;
        case 2
            xi=0.9; a=1.2;
            k1=2*xi*a; k3=2*xi*a;
            k2=(a^2 - omega_d^2)/(v_d+1e-6);
            u1 = -k1*e1; 
            u2 = -k2*e2 - k3*e3;
        case 3
            k1=1.5; k2=3; k3=2;
            u1 = -k1*e1;
            u2 = -k2*e2 - k3*sin(e3);
    end

    % Inverse transformation to control inputs
    v = v_d*cos(e3) - u1;
    omega = omega_d - u2;

    % Unicycle model
    dx = zeros(3,1);
    dx(1) = v*cos(theta);
    dx(2) = v*sin(theta);
    dx(3) = omega;
end
