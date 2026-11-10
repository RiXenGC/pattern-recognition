clear; close all; clc;

A0 = imread('rice.png');
if ndims(A0) == 3
    A0 = rgb2gray(A0);
end
A0 = im2uint8(A0);

figure; imshow(A0, []); title('Original rice image');

% Median filtering before thresholding
A = medfilt2(A0, [3 3]);

% Local binarization, following the lab example (split at row 180)
cut = min(180, size(A,1)-1);
A1 = A(1:cut, :);
A2 = A(cut+1:end, :);
L1 = graythresh(A1);
L2 = graythresh(A2);
B1 = im2bw(A1, L1);
B2 = im2bw(A2, L2);
B = false(size(A));
B(1:cut, :) = B1;
B(cut+1:end, :) = B2;

figure; imshow(B); title('Local binarization');

% Morphological filtering to remove small noise and tidy grain regions
se = ones(3,3);

C = imopen(B, se);
C = imclose(C, se);
C = bwareaopen(C, 20);
figure; imshow(C); title('Filtered binary image');

% Label connected foreground components
[D, nObjects] = bwlabel(C, 8);
fprintf('\nConnected components after filtering: %d\n', nObjects);
figure; imshow(D, []); title('Connected-component labels');

% Display the object whose label is 5 times the roll-call number
journalNo = 9;  % Your roll-call number; run without prompting
k = journalNo * 5;
fprintf('Roll-call number: %d; target component label: %d\n', journalNo, k);
if k >= 1 && k <= nObjects
    targetGrain = (D == k);
    figure('Name', sprintf('Component label %d', k));
    imshow(targetGrain);
    title(sprintf('Component label %d', k));
    hold on;
    text(5, 15, sprintf('Label %d', k), 'Color', 'y', ...
        'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', 'k', 'Margin', 2);
    hold off;
else
    fprintf('Component label %d does not exist. The current label count is %d.\n', k, nObjects);
end

% Flag unusually large components as possible clusters of touching grains
% This is a visual screening heuristic; verify each candidate in the crops.
if nObjects > 0
    stats = regionprops(D, 'Area', 'BoundingBox', 'Centroid');
    areas = [stats.Area];
    medianArea = median(areas);
    mergeFactor = 1.5;
    mergedLabels = find(areas >= mergeFactor * medianArea);

    fprintf('Suspected merged components (area >= %.2f x median area): %d\n', ...
        mergeFactor, numel(mergedLabels));
    if ~isempty(mergedLabels)
        fprintf('Candidate labels: ');
        fprintf('%d ', mergedLabels);
        fprintf('\n');

        figure; imshow(A0, []); hold on;
        for q = 1:numel(mergedLabels)
            i = mergedLabels(q);
            rectangle('Position', stats(i).BoundingBox, ...
                'EdgeColor', 'r', 'LineWidth', 1.5);
            text(stats(i).Centroid(1), stats(i).Centroid(2), ...
                sprintf('%d', i), 'Color', 'y', 'FontSize', 10, ...
                'FontWeight', 'bold');
        end
        title('Possible touching-grain clusters');
        hold off;

        nCols = 4;
        nRows = ceil(numel(mergedLabels) / nCols);
        figure;
        for q = 1:numel(mergedLabels)
            i = mergedLabels(q);
            bb = stats(i).BoundingBox;
            x1 = max(1, floor(bb(1)));
            y1 = max(1, floor(bb(2)));
            x2 = min(size(A0,2), ceil(bb(1) + bb(3)));
            y2 = min(size(A0,1), ceil(bb(2) + bb(4)));
            subplot(nRows, nCols, q);
            imshow(A0(y1:y2, x1:x2), []);
            title(sprintf('Label %d, area %.0f', i, areas(i)));
        end
        sgtitle('Inspect these crops for merged rice grains');
    else
        fprintf('No unusually large components were flagged by the area heuristic.\n');
    end
end

fprintf(['Note: nObjects is the number of connected components, not always the true grain count. ' ...
    'If grains touch, inspect the flagged crops and account for the extra grains after splitting them.\n']);
