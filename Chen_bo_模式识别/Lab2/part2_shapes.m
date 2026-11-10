clear; close all; clc;

A = imread('tupian.jpg');
if ndims(A) == 3
    A = rgb2gray(A);
end
A = im2uint8(A);
A = medfilt2(A, [3 3]);

% Black shapes become foreground (1); the white background becomes 0.
B = imcomplement(im2bw(A, graythresh(A)));
se = ones(3,3);
B = imopen(B, se);
B = imclose(B, se);
B = bwareaopen(B, 50);

figure; imshow(B); title('Binary foreground shapes');
[D, nObjects] = bwlabel(B, 8);
figure; imshow(D, []); title('Connected-component labels');
fprintf('Connected components found: %d\n', nObjects);

holeCounts = zeros(nObjects, 1);
pentagonLabels = [];
fourHoleLabels = [];

for i = 1:nObjects
    obj = (D == i);

    % Count enclosed holes in this component
    filled = imfill(obj, 'holes');
    holeMask = filled & ~obj;
    [~, nHoles] = bwlabel(holeMask, 8);
    holeCounts(i) = nHoles;

    % The pentagon should be a solid component. Identify its five radial-profile peaks.
    if nHoles == 0
        R = centroidProfile(obj);
        if isRegularPentagonProfile(R)
            pentagonLabels(end+1) = i; %#ok<SAGROW>
        end
    end

    fprintf('Component %d: area = %d pixels, enclosed holes = %d\n', ...
        i, nnz(obj), nHoles);
    if nHoles == 4
        fourHoleLabels(end+1) = i; %#ok<SAGROW>
    end
end

if isempty(pentagonLabels)
    warning(['No pentagon was detected automatically. Check that the pentagon is large, ' ...
        'regular, solid, and clearly separated from other shapes.']);
else
    fprintf('Pentagon candidate label(s): ');
    fprintf('%d ', pentagonLabels);
    fprintf('\n');
end

if isempty(fourHoleLabels)
    warning('No component with exactly four enclosed holes was detected. Check the hole sizes and that none is open to the background.');
else
    fprintf('Four-hole component label(s): ');
    fprintf('%d ', fourHoleLabels);
    fprintf('\n');
end

% Color the detected pentagon red and the four-hole component green.
% The holes themselves remain white because they are background pixels.
RGB = repmat(A, [1 1 3]);
Rch = RGB(:,:,1);
Gch = RGB(:,:,2);
Bch = RGB(:,:,3);

for q = 1:numel(pentagonLabels)
    mask = (D == pentagonLabels(q));
    Rch(mask) = 255; Gch(mask) = 0; Bch(mask) = 0;
end
for q = 1:numel(fourHoleLabels)
    mask = (D == fourHoleLabels(q));
    Rch(mask) = 0; Gch(mask) = 255; Bch(mask) = 0;
end
RGB = cat(3, Rch, Gch, Bch);

figure; imshow(RGB); title('Pentagon red; four-hole component green');
imwrite(RGB, 'details_result.png');
fprintf('Saved colored result to details_result.png\n');

