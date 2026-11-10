function R = centroidProfile(obj)

E = bwperim(obj, 8);
[yObj, xObj] = find(obj);
xc = mean(xObj);
yc = mean(yObj);

[y, x] = find(E);
dx = x - xc;
dy = y - yc;
radius = hypot(dx, dy);
angleDeg = atan2d(dy, dx);
bin = mod(round(angleDeg), 360) + 1;

R = zeros(360, 1);
for j = 1:numel(bin)
    R(bin(j)) = max(R(bin(j)), radius(j));
end

good = find(R > 0);
if numel(good) < 2
    R = ones(360, 1);
    return;
end
R = interp1([good-360; good; good+360], ...
    [R(good); R(good); R(good)], (1:360)', 'linear');
R = R ./ mean(R);
end
