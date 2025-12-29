clc;
clear;
close all;

% -------- SELECT --------
trajectory_type = "square";   % "line" | "circle" | "square"
controller_type = 1;          % 1 | 2 | 3
% ------------------------

tspan = [0 20];
x0 = [0; 0; 0];

[t, x] = ode45(@(t,x) unicycle(t,x,trajectory_type,controller_type), tspan, x0);

% Desired trajectory for plotting
[xd, yd] = trajectory_generator(t, trajectory_type);

figure;
plot(x(:,1), x(:,2),'b','LineWidth',2); hold on;
plot(xd, yd,'r--','LineWidth',2);
legend('Actual','Desired');
title(['Trajectory: ',trajectory_type,' | Controller ',num2str(controller_type)]);
xlabel('x'); ylabel('y');
grid on; axis equal;

function dx = unicycle(t, x, traj_type, ctrl_type)

    X = x(1); Y = x(2); theta = x(3);

    %% ===== TRAJECTORY + FLATNESS =====
    [xd, yd, xd_dot, yd_dot, xd_ddot, yd_ddot] = flatness_block(t, traj_type);

    v_d = sqrt(xd_dot^2 + yd_dot^2);
    theta_d = atan2(yd_dot, xd_dot);
    omega_d = (xd_dot*yd_ddot - yd_dot*xd_ddot)/(xd_dot^2 + yd_dot^2 + 1e-6);

    %% ===== ERROR (Eq. 1.203) =====
    e1 =  cos(theta)*(xd - X) + sin(theta)*(yd - Y);
    e2 = -sin(theta)*(xd - X) + cos(theta)*(yd - Y);
    e3 = wrapToPi(theta_d - theta);

    %% ===== CONTROLLERS =====
    switch ctrl_type
        case 1  % General state-error feedback
            k1=1; k2=2; k3=2;
            u1 = -k1*e1;
            u2 = -k2*e2 - k3*e3;

        case 2  % Linearized error dynamics
            xi = 0.9; a = 1.2;
            k1 = 2*xi*a;
            k3 = 2*xi*a;
            k2 = (a^2 - omega_d^2)/(v_d + 1e-6);

            u1 = -k1*e1;
            u2 = -k2*e2 - k3*e3;

        case 3  % Nonlinear controller
            k1=1.5; k2=3; k3=2;
            u1 = -k1*e1;
            u2 = -k2*e2 - k3*sin(e3);
    end

    %% ===== INVERSE TRANSFORMATION =====
    v = v_d*cos(e3) - u1;
    omega = omega_d - u2;

    %% ===== UNICYCLE MODEL =====
    dx = zeros(3,1);
    dx(1) = v*cos(theta);
    dx(2) = v*sin(theta);
    dx(3) = omega;
end

function [xd, yd, xd_dot, yd_dot, xd_ddot, yd_ddot] = flatness_block(t, type)

    switch type

        case "line"
            xd = 0.2*t;
            yd = 0;

            xd_dot = 0.2;
            yd_dot = 0;

            xd_ddot = 0;
            yd_ddot = 0;

        case "circle"
            r = 1; w = 0.2;
            xd = r*cos(w*t);
            yd = r*sin(w*t);

            xd_dot = -r*w*sin(w*t);
            yd_dot =  r*w*cos(w*t);

            xd_ddot = -r*w^2*cos(w*t);
            yd_ddot = -r*w^2*sin(w*t);

        case "square"
            T = mod(t,8);
            v = 100;

            if T < 2
                xd = v*T; yd = 0;
                xd_dot = v; yd_dot = 0;
            elseif T < 4
                xd = v*2; yd = v*(T-2);
                xd_dot = 0; yd_dot = v;
            elseif T < 6
                xd = v*(6-T); yd = v*2;
                xd_dot = -v; yd_dot = 0;
            else
                xd = 0; yd = v*(8-T);
                xd_dot = 0; yd_dot = -v;
            end

            xd_ddot = 0;
            yd_ddot = 0;
    end
end

function [xd, yd] = trajectory_generator(t, type)
    xd = zeros(size(t));
    yd = zeros(size(t));
    for i = 1:length(t)
        [xd(i), yd(i),~,~,~,~] = flatness_block(t(i), type);
    end
end
