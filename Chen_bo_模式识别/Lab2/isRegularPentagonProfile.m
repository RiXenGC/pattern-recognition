function tf = isRegularPentagonProfile(R)

R = R(:);
Rpad = [R(end-4:end); R; R(1:5)];
Rsm = conv(Rpad, ones(11,1)/11, 'valid');
candidates = find(Rsm > circshift(Rsm, 1) & Rsm >= circshift(Rsm, -1));

tf = false;
if isempty(candidates)
    return;
end

[~, order] = sort(Rsm(candidates), 'descend');
selected = [];
for j = 1:numel(order)
    p = candidates(order(j));
    if isempty(selected)
        selected = p;
    else
        dist = abs(selected - p);
        dist = min(dist, 360 - dist);
        if all(dist >= 25)
            selected(end+1) = p; %#ok<AGROW>
        end
    end
end

selected = sort(selected);
if numel(selected) == 5
    angles = [selected(:); selected(1) + 360];
    gaps = diff(angles);
    peakRadii = Rsm(selected);
    tf = max(abs(gaps - 72)) < 18 && ...
        max(peakRadii) / min(peakRadii) < 1.35;
end
end
