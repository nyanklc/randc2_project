function P_interp = interpolate_trajectory(P, M, method)
    % we use linear interpolation for now
    if nargin < 3
        method = 'pchip';
    end
    d = sqrt(sum(diff(P).^2, 2));
    s = [0; cumsum(d)];
    s_new = linspace(0, s(end), M);
    x_new = interp1(s, P(:,1), s_new, method);
    y_new = interp1(s, P(:,2), s_new, method);
    P_interp = [x_new(:), y_new(:)];
end
