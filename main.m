clear all;

%% parameters
Ts = 0.01; % sampling time
N = 1000; % nr of points on the trajectory
trajectory_scale = 100; % scaling to be applied to trajectories

%% trajectories
%{

NOTES:
    - the derivatives of the trajectories are also calculated, offline.
    - the trajectories are initially normalized between [0, 1], then scaled
    with 'trajectory_scale'.

xd_i: trajectories (test)
xd_simple_i: simple trajectories (validation)

%}
% generate trajectories if they don't exist
if isfile("trajectory.mat")
    load("trajectory.mat");
    disp("Loaded trajectory.");
else
    generate_trajectories(Ts, N, trajectory_scale);
    disp("Generated trajectory.");
end
disp("Ts=" + Ts);
disp("N=" + N);
disp("trajectory_scale=" + trajectory_scale);
disp("(simulation duration=" + Ts*N + ")");

% plot
figure;
plot(xd_ts.Data, yd_ts.Data, "LineWidth", 2.0);
title("Trajectory, length=" + numel(xd_ts.Data));
grid minor;
xlabel("X");
ylabel("Y");
x_range = max(xd_ts.Data);
y_range = max(yd_ts.Data);
xlim([-0.1*x_range, 1.1*x_range]);
ylim([-1.1*y_range, 1.1*y_range]);
hold on;
plot(0, 0, ">", "LineWidth", 4.0);
plot(xd_ts.Data(end), yd_ts.Data(end), "o", "LineWidth", 4.0);

%%
