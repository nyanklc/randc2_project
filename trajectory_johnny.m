%% Trajectory Generation Script
% Generates multiple trajectories and saves them for later use

clear; clc; close all;

%% Parameters
nr_trajectories = 5;   % number of trajectories
Ts = 0.01;             % sampling time
N = 1000;              % number of points per trajectory
trajectory_scale = 100; % scaling factor

%% Generate or load trajectories
if isfile("trajectories.mat")
    load("trajectories.mat");
    disp("Loaded trajectories.");
else
    trajectories = struct();
    t = (0:N-1)*Ts;
    for i = 1:nr_trajectories
        % Example: sine wave + random variation
        xd = trajectory_scale*(sin(0.01*i*pi*t) + 0.1*randn(1,N));
        yd = trajectory_scale*(cos(0.01*i*pi*t) + 0.1*randn(1,N));
        xd_ts = timeseries(xd, t);
        yd_ts = timeseries(yd, t);

        trajectories("trajectory" + i).xd_ts = xd_ts;
        trajectories("trajectory" + i).yd_ts = yd_ts;
    end
    save("trajectories.mat", "trajectories");
    disp("Generated trajectories.");
end

%% Plot trajectories
figure; hold on;
x_range = 0; y_range = 0;
for i = 1:nr_trajectories
    xd_ts = trajectories("trajectory"+i).xd_ts;
    yd_ts = trajectories("trajectory"+i).yd_ts;
    plot(xd_ts.Data, yd_ts.Data, 'LineWidth',2, 'DisplayName',"Trajectory "+i);
    x_range = max([x_range, max(xd_ts.Data)]);
    y_range = max([y_range, max(abs([yd_ts.Data]))]);
end
plot(0,0, '>', 'LineWidth',4, 'DisplayName',"Start");
plot(trajectory_scale,0,'o','LineWidth',4,'DisplayName',"End");
hold off; grid minor; axis equal;
xlabel('X'); ylabel('Y'); title('Generated Trajectories');
legend();
