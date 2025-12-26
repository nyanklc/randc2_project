clear all;

%% parameters
nr_trajectories = 5; % number of trajectories to be generated
Ts = 0.01; % sampling time
N = 1000; % nr of points on the trajectory
trajectory_scale = 100; % scaling to be applied to trajectories

%%
function path = random_trajectory(step, x_start, y_start, x_goal, y_min, y_max)

%% TODO: this is not a good generation algorithm but whatever
x = x_start;
y = y_start;
path = [x, y];

last_dir = -1; % 0: right, 1: up, 2: down
first_step = 1;

% reach the boundary
while x < x_goal
    r = rand();
    if first_step || r < 0.4 % right
        first_step = 0;
        x = x + step;
        last_dir = 0;
    elseif r < 0.7 % up
        if last_dir == 2 || y == y_max
            continue;
        end
        y = y + step;
        last_dir = 1;
    else % down
        if last_dir == 1 || y == y_min
            continue;
        end
        y = y - step;
        last_dir = 2;
    end
    path(end+1, :) = [x, y];
end

% connect to end goal
while y ~= y_start
    if y > y_start
        y = y - step;
    else
        y = y + step;
    end
    path(end+1, :) = [x, y];
end

% finally add a small line piece at the end
path(end+1, :) = [path(end, 1)+step, path(end, 2)];
end

%% trajectories
% generate trajectories if they don't exist
if isfile("random_trajectories.mat") % just load
    load("random_trajectories.mat");
    disp("Loaded trajectories.");
else % generate
    step = 1;
    x_start = 0;
    y_start = 5;
    x_goal  = 10;
    y_min = 0;
    y_max = 10;
    random_trajectories = {};
    for i = 1:nr_trajectories+1
        random_trajectories{i} = random_trajectory(step, x_start, y_start, x_goal, y_min, y_max);
    end
    trajectories = process_trajectories(random_trajectories, Ts, N, true, trajectory_scale);
    % generate random setpoints for the regulation task
    end_point = [trajectory_scale, 0]; % where the trajectories end
    for i = 1:nr_trajectories
        r = rand();
        rsign = rand();
        sign = 1;
        if rsign < 0.5
            sign = -1;
        end
        trajectories("trajectory"+i).setpoint = end_point + [trajectory_scale/10, sign*r*trajectory_scale/2.5];
    end
    save("random_trajectories.mat", "nr_trajectories", "Ts", "N", "trajectory_scale", "trajectories");
    load("random_trajectories.mat");
    disp("Generated trajectories.");
end

disp("nr_trajectories=" + nr_trajectories);
disp("Ts=" + Ts);
disp("N=" + N);
disp("trajectory_scale=" + trajectory_scale);
disp("(simulation duration=" + Ts*N + ")");

%% plot
figure;
len = 0;
x_range = 0;
y_range = 0;
for i = 1:nr_trajectories
    xd_ts = trajectories("trajectory"+i).xd_ts;
    yd_ts = trajectories("trajectory"+i).yd_ts;
    setpoint = trajectories("trajectory"+i).setpoint;
    len = numel(xd_ts.Data);

    subplot(5, 1, i);
    hold on;
    plot(xd_ts.Data, yd_ts.Data, "LineWidth", 2.0, "DisplayName", "Trajectory "+i);
    plot(setpoint(1), setpoint(2), "o", "LineWidth", 3.0, "DisplayName", "Setpoint "+i);
    plot(0, 0, ">", "LineWidth", 4.0, "DisplayName", "Start");
    plot(trajectory_scale, 0, "o", "LineWidth", 4.0, "DisplayName", "End");
    hold off;

    grid minor;
    title("Trajectory " + i);
    xlabel("X");
    ylabel("Y");

    x_range = max([max(xd_ts.Data), x_range]);
    y_range = max([max([abs(max(yd_ts.Data)), abs(min(yd_ts.Data))]), y_range]);
    xlim([-0.1*x_range, 1.3*x_range]);
    ylim([-1.1*y_range, 1.1*y_range]);

    legend();
end
