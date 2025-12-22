% TODO: remove dummy

N = 10; % number of paths
paths = cell(N,1);

figure; hold on; axis equal;
for i = 1:N
    paths{i} = dum();
    plot(paths{i}(:,1), paths{i}(:,2), '-o');
end

plot(50,200,'go','MarkerSize',10,'LineWidth',2);   % start
plot(500,200,'ro','MarkerSize',10,'LineWidth',2);  % goal
title('Random 90°-Turn Trajectories');