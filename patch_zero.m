function inputs = patch_zero(velocities,err)
d = 1/sqrt(2);
a = 10;

vd = velocities(1);
wd = velocities(2);

if abs(vd) < 1e-4
    if vd >= 0
        vd = 1e-4;
    else
        vd = -1e-4;
    end
end

k1 = 2*d*a;
k2 = (a^2 - wd^2)/vd;
k3 = k1;

k = [-k1, 0,  0;
     0,   -k2,-k3];

inputs = k*err;
