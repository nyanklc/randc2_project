%% ============================================================
%  UNICYCLE POSTURE REGULATION
%  ============================================================

clear; clc; close all;

%% ---------------- Simulation parameters ---------------------
Ts = 0.01;          % Sampling time
t_end = 40;         % Simulation duration
tspan = [0 t_end];


%% ---------------- Initial condition --------------------------
x0 = [-5; -5; pi/4]; %random values
%% ---------------- Desired pose --------------------------
xd = [idk];
yd = [idk];
thetad = [idk];

%% ---------------- Simulation --------------------------------
[t, x] = ode45(@(t,x) posture_regulation(t,x,xd,yd,thetad), tspan, x0);

%% ---------------- Plot --------------------------------------
figure;
plot(x(:,1), x(:,2),'b','LineWidth',2); hold on;
plot(xd, yd,'ro','MarkerSize',10,'LineWidth',2);
legend('Robot','Target (Box)');
axis equal; grid on;
xlabel('x'); ylabel('y');
title('Unicycle Posture Regulation (Parking)');


