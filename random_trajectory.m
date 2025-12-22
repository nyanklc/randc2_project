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

end
