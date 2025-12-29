clc; clear; close all;

%% =======================
% PARAMETERS
%% =======================
Ts = 0.05;          % sampling time
M  = 300;           % interpolated points
step = 20;

x_start = 50;
y_start = 200;
x_goal  = 500;
y_min   = 100;
y_max   = 300;

%% =======================
% GENERATE TRAJECTORY
%% =======================
P = random_trajectory(step, x_start, y_start, x_goal, y_min, y_max);
P = interpolate_trajectory(P, M);

x_ref = P(:,1);
y_ref = P(:,2);

% Reference orientation
dx = diff(x_ref);
dy = diff(y_ref);
theta_ref = atan2(dy, dx);
theta_ref(end+1) = theta_ref(end);

% Reference velocities
vd = sqrt(dx.^2 + dy.^2)/Ts;
vd(end+1) = vd(end);

wd = diff(theta_ref)/Ts;
wd(end+1) = 0;

%% =======================
% INITIAL STATE
%% =======================
x = x_ref(1);
y = y_ref(1);
theta = theta_ref(1);

X = []; Y = [];

k = 1;

%% =======================
% MAIN LOOP
%% =======================
while k < M

    % --- Reference ---
    xd = x_ref(k);
    yd = y_ref(k);
    thetad = theta_ref(k);

    % --- Tracking error (robot frame) ---
    ex =  cos(theta)*(xd - x) + sin(theta)*(yd - y);
    ey = -sin(theta)*(xd - x) + cos(theta)*(yd - y);
    et = thetad - theta;

    err = [ex; ey; et];

    % --- Controller ---
    u = patch_zero([vd(k); wd(k)], err);

    v = vd(k) + u(1);
    w = wd(k) + u(2);

    % --- Unicycle model ---
    x     = x + Ts*v*cos(theta);
    y     = y + Ts*v*sin(theta);
    theta = theta + Ts*w;

    % --- Save ---
    X(end+1) = x;
    Y(end+1) = y;

    % --- Move along trajectory ---
    if norm([xd - x, yd - y]) < 5
        k = k + 1;
    end
end

%% =======================
% PLOT
%% =======================
figure; hold on; axis equal; grid on;
plot(x_ref, y_ref, 'r--', 'LineWidth', 2);
plot(X, Y, 'b', 'LineWidth', 2);
legend('Reference trajectory', 'Tracked trajectory');
title('Trajectory Tracking with Unicycle Controller');
