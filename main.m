%{
NOTES:
- The derivatives of the trajectories are also calculated, offline.
%}

clear all;

%% parameters
nr_trajectories = 5; % number of trajectories to be generated
Ts = 0.01; % sampling time
N = 1000; % nr of points on the trajectory
trajectory_scale = 100; % scaling to be applied to trajectories

%% trajectories
% generate trajectories if they don't exist
if isfile("trajectories.mat")
    load("trajectories.mat");
    disp("Loaded trajectories.");
else
    generate_trajectories(nr_trajectories, Ts, N, trajectory_scale);
    load("trajectories.mat");
    disp("Generated trajectories.");
end
disp("nr_trajectories=" + nr_trajectories);
disp("Ts=" + Ts);
disp("N=" + N);
disp("trajectory_scale=" + trajectory_scale);
disp("(simulation duration=" + Ts*N + ")");

% plot
figure;
subplot(2, 1, 1);
hold on;
len = 0;
x_range = 0;
y_range = 0;
for i = 1:nr_trajectories
    xd_ts = trajectories("trajectory"+i).xd_ts;
    yd_ts = trajectories("trajectory"+i).yd_ts;
    setpoint = trajectories("trajectory"+i).setpoint;
    len = numel(xd_ts.Data);

    plot(xd_ts.Data, yd_ts.Data, "LineWidth", 2.0, "DisplayName", "Trajectory "+i);
    x_range = max([max(xd_ts.Data), x_range]);
    y_range = max([max([abs(max(yd_ts.Data)), abs(min(yd_ts.Data))]), y_range]);

    plot(setpoint(1), setpoint(2), "o", "LineWidth", 3.0, "DisplayName", "Setpoint "+i);
end
plot(0, 0, ">", "LineWidth", 4.0, "DisplayName", "Start");
plot(trajectory_scale, 0, "o", "LineWidth", 4.0, "DisplayName", "End");
hold off;
grid minor;
title("Trajectories, length=" + len);
xlabel("X");
ylabel("Y");
xlim([-0.1*x_range, 1.25*x_range]);
ylim([-1.1*y_range, 1.1*y_range]);
legend();

%% sim
sim_trajectory_id = 3;

% plot
subplot(2, 1, 2);
hold on;
len = 0;
x_range = 0;
y_range = 0;
i = sim_trajectory_id;
xd_ts = trajectories("trajectory"+i).xd_ts;
yd_ts = trajectories("trajectory"+i).yd_ts;
setpoint = trajectories("trajectory"+i).setpoint;
len = numel(xd_ts.Data);

plot(xd_ts.Data, yd_ts.Data, "LineWidth", 2.0, "DisplayName", "Trajectory "+i);
x_range = max([max(xd_ts.Data), x_range]);
y_range = max([max([abs(max(yd_ts.Data)), abs(min(yd_ts.Data))]), y_range]);

plot(setpoint(1), setpoint(2), "o", "LineWidth", 3.0, "DisplayName", "Setpoint "+i);
plot(0, 0, ">", "LineWidth", 4.0, "DisplayName", "Start");
plot(trajectory_scale, 0, "o", "LineWidth", 4.0, "DisplayName", "End");
hold off;
grid minor;
title("Trajectory to be simulated, length=" + len);
xlabel("X");
ylabel("Y");
xlim([-0.1*x_range, 1.25*x_range]);
ylim([-1.1*y_range, 1.1*y_range]);
legend();
