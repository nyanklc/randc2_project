function generate_trajectories(Ts, N, trajectory_scale)

%% generate trajectory
step = 0.1;
x_start = 0;
y_start = 0.5;
x_goal  = 1;
y_min = 0;
y_max = 1;
pts = random_trajectory(step, x_start, y_start, x_goal, y_min, y_max);

%% pre-processing
% normalize
x_diff = max(pts(:, 1)) - min(pts(:, 1));
y_diff = max(pts(:, 2)) - min(pts(:, 2));
pts(:, 1) = pts(:, 1) / x_diff;
pts(:, 2) = pts(:, 2) / y_diff;
% start from (0, 0)
offset = pts(1, :);
pts(:, 1) = pts(:, 1) - offset(1);
pts(:, 2) = pts(:, 2) - offset(2);
% scale
pts = pts * trajectory_scale;
% interpolate
pts = interpolate_trajectory(pts, N, "linear");

%% convert to timeseries
t = (0:N-1)' * Ts;

xd = pts(:, 1);
yd = pts(:, 2);
xd_dot  = gradient(xd, Ts);
yd_dot  = gradient(yd, Ts);
xd_dot_dot = gradient(xd_dot, Ts);
yd_dot_dot = gradient(yd_dot, Ts);

% figure;
% hold on;
% plot(t, xd, "Tag", "xd");
% plot(t, yd, "Tag", "yd");
% plot(t, xd_dot, "Tag", "xd_dot");
% plot(t, yd_dot, "Tag", "yd_dot");
% plot(t, xd_dot_dot, "Tag", "xd_dot_dot");
% plot(t, yd_dot_dot, "Tag", "yd_dot_dot");
% hold off;
% legend();

xd_ts = timeseries(xd, t);
yd_ts = timeseries(yd, t);
xd_dot_ts = timeseries(xd_dot, t);
yd_dot_ts = timeseries(yd_dot, t);
xd_dot_dot_ts = timeseries(xd_dot_dot, t);
yd_dot_dot_ts = timeseries(yd_dot_dot, t);
save("trajectory.mat", "Ts", "N", "trajectory_scale", "xd_ts", "yd_ts", "xd_dot_ts", "yd_dot_ts", "xd_dot_dot_ts", "yd_dot_dot_ts");

end
